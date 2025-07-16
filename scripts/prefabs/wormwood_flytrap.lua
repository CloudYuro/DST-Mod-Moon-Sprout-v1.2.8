local SGwormwood_flytrap = require("stategraphs/SGwormwood_flytrap")

local assets=
{
    Asset("ANIM", "anim/venus_flytrap_sm_build.zip"),
    Asset("ANIM", "anim/venus_flytrap_lg_build.zip"),
    Asset("ANIM", "anim/venus_flytrap_build.zip"),
    Asset("ANIM", "anim/venus_flytrap.zip"),
}
-- 生长阶段配置生成函数
local function GenerateGrowthStages()
    local stages = {}
    local max_level = 50
    
    -- 特殊处理前几级
    stages[1] = {
        scale = 1.0,
        start_scale = 1.0,
        new_build = "venus_flytrap_child_build",
        name = "FLYTRAP_CHILD_",
    }
    
    stages[2] = {
        scale = 1.2,
        start_scale = 1.0,
        new_build = "venus_flytrap_build",
        name = "FLYTRAP_TEEN_",
    }
    
    stages[3] = {
        scale = 1.4,
        start_scale = 1.2,
        new_build = "venus_flytrap_lg_build",
        name = "FLYTRAP_",
    }
    
    -- 4-50级的通用生成逻辑
    for i = 4, max_level do
        local scale_increase = 0.05  -- 基础增量
        
        -- 10级后增量逐渐减少
        if i > 10 then
            scale_increase = scale_increase * (1 - (i - 10) * 0.1)  -- 每级增量减少2%
            scale_increase = math.max(scale_increase, 0.005)  -- 最小增量为0.005
        end
        
        stages[i] = {
            scale = stages[i-1].scale + scale_increase,
            start_scale = stages[i-1].scale,
            new_build = "venus_flytrap_lg_build",
            name = string.format("FLYTRAP_%d_", i),
        }
    end
    
    return stages
end

local growth_stages = GenerateGrowthStages()

local max_flytrap_speed = 4
-- 属性配置生成函数
local function GenerateTuningValues()
    local tuning = {
        -- 基础属性
        FLYTRAP_CHILD_HEALTH = 250,
        FLYTRAP_CHILD_DAMAGE = 15,
        FLYTRAP_CHILD_SPEED = 4,

        FLYTRAP_TEEN_HEALTH = 300,
        FLYTRAP_TEEN_DAMAGE = 20,
        FLYTRAP_TEEN_SPEED = 4,

        FLYTRAP_HEALTH = 350,
        FLYTRAP_DAMAGE = 25,
        FLYTRAP_SPEED = 4,
        FLYTRAP_ATTACK_PERIOD = 2,
    }
    
    local max_level = 50
    local target_health = 1600  -- 50级目标生命值
    local target_damage = 70  -- 50级目标伤害值
    
    -- 计算基础增长曲线
    local base_health = tuning.FLYTRAP_HEALTH
    local base_damage = tuning.FLYTRAP_DAMAGE
    
    -- 计算需要的总增长量
    local total_health_growth = target_health - base_health
    local total_damage_growth = target_damage - base_damage
    
    -- 生成3-50级的属性
    for i = 3, max_level do
        -- 计算当前等级占总增长的比例（使用缓动函数使增长逐渐放缓）
        local progress = (i - 3) / (max_level - 3)
        local ease_progress = 1 - math.pow(1 - progress, 1.5)  -- 缓动函数使后期增长变慢
        
        -- 计算当前级属性值
        local current_health = base_health + total_health_growth * ease_progress
        local current_damage = base_damage + total_damage_growth * ease_progress
        
        -- 范围增长（从3.0到4.5）
        local current_range = 3.0 + 1.5 * ease_progress
        
        -- 设置当前级属性
        tuning[string.format("FLYTRAP_%d_HEALTH", i)] = math.floor(current_health)
        tuning[string.format("FLYTRAP_%d_DAMAGE", i)] = math.floor(current_damage)
        tuning[string.format("FLYTRAP_%d_SPEED", i)] = max_flytrap_speed  -- 速度保持不变
        tuning[string.format("FLYTRAP_%d_ATTACK_PERIOD", i)] = 2  -- 攻击间隔保持不变
        tuning[string.format("FLYTRAP_%d_RANGE", i)] = tonumber(string.format("%.1f", current_range))
    end
    
    return tuning
end

local TUNING_FLYTRAP = GenerateTuningValues()

local function findfood(inst, target)
    if not target.components.inventory then
        return
    end

    return target.components.inventory:FindItem(function(item)
        return inst.components.eater:CanEat(item)
    end)
end

local RETARGET_DIST = 8
local RETARGET_TAGS = {"hostile"}
local RETARGET_NO_TAGS = {"FX", "NOCLICK", "INLIMBO", "wall", "flytrap", "structure", "aquatic", "notarget"}

local function RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    -- return FindEntity(inst, RETARGET_DIST, function(ent)
    --      -- 确保ent有效且不是玩家
    --     if not ent or not ent:IsValid() or ent:HasTag("player") or ent:HasTag("companion") then
    --         return false
    --     end
        
    --     -- 确保有战斗组件可以判断目标
    --     if not inst.components.combat or not inst.components.combat:CanTarget(ent) then
    --         return false
    --     end
        
    --     -- 检查是否是玩家的追随者
    --     if ent.components.follower and ent.components.follower:GetLeader() 
    --        and ent.components.follower:GetLeader():HasTag("player") then
    --         return false
    --     end
        
    --     -- 优先攻击怪物
    --     if ent:HasTag("hostile") or ent:HasTag("monster") then
    --         return true
    --     end
            
    --     -- 默认不攻击其他单位
    --     return false
    -- end, nil, RETARGET_NO_TAGS)
    
    return inst.components.combat.target
end

function EntityScript:GetShouldBrainStopped()
    local stopped = false
    if self.components.freezable and self.components.freezable:IsFrozen() then
        stopped = true
    end
    if self.components.sleeper and self.components.sleeper:IsAsleep() then
        stopped = true
    end
    return stopped
end

local KEEP_TAGET_DIST = 15
local function KeepTargetFn(inst, target)
    return inst:IsNear(target, KEEP_TAGET_DIST)
    
    -- -- 确保target有效
    -- if not target or not target:IsValid() then
    --     return false
    -- end
    
    -- -- 不保持玩家为目标
    -- if target:HasTag("player") then
    --     return false
    -- end
    
    -- -- 检查距离和是否是怪物
    -- local isMonster = target:HasTag("monster")
    -- local inRange = inst:GetDistanceSqToInst(target) <= KEEP_TAGET_DIST * KEEP_TAGET_DIST
    
    -- return isMonster and inRange and not target:HasTag("aquatic")
    -- return inst.components.combat:CanTarget(target) and inst:GetDistanceSqToInst(target) <= KEEP_TAGET_DIST * KEEP_TAGET_DIST and not target:HasTag("aquatic")
end

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local lureplantbulb = SpawnPrefab("lureplantbulb")
    lureplantbulb.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(lureplantbulb)

    if inst.stage_plus > 2 then
        for i = 1, math.floor(inst.stage_plus / 2) do
            local plantmeat = SpawnPrefab("plantmeat")
            plantmeat.Transform:SetPosition(ix, iy, iz)
            inst.components.lootdropper:FlingItem(plantmeat)
        end
    end

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.2, 1.2, 1.2)
    fx.Transform:SetPosition(ix, iy, iz)
    inst:Remove()
end


local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash and data.attacker.components.petleash:IsPet(inst) then
            local timer = inst.components.timer
            if timer and timer:TimerExists("finish_transformed_life") then
                timer:StopTimer("finish_transformed_life")
				finish_transformed_life(inst)
            end
        end
    end
    
    inst.components.combat:SetTarget(data.attacker)
    inst.keeptargetevenifnofood = true
end

local function OnTimerDone(inst, data)
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
end

local function OnNewTarget(inst, data)
    inst.keeptargetevenifnofood = nil
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end


local function SetStage(inst, stage_plus, instant)
    if inst.components.health and inst.components.health:IsDead() then
        return
    end
    if not inst.stage_plus then
        return
    end

    if inst.stage_plus <= 1 then
        return
    end

    -- if stage >= 4 then
    --     ReplacePrefab(inst, "adult_flytrap")
    --     return
    -- end


    if instant then
        local scale = growth_stages[inst.stage_plus].scale
        inst.Transform:SetScale(scale, scale, scale)
        inst.AnimState:SetBuild(growth_stages[inst.stage_plus].new_build)
    else
        inst.new_build = growth_stages[inst.stage_plus].new_build
        inst.start_scale = growth_stages[inst.stage_plus].start_scale

        inst.inc_scale = (growth_stages[inst.stage_plus].scale - growth_stages[inst.stage_plus].start_scale) / 5
        inst.sg:GoToState("grow")
    end

    inst:RemoveTag("usefastrun")

    inst.components.combat:SetDefaultDamage(TUNING_FLYTRAP[growth_stages[inst.stage_plus].name .. "DAMAGE"])
    inst.components.combat:SetRange(2 + (inst.stage_plus - 3) / 10, 3 + (inst.stage_plus - 3) / 10)
    inst.components.health:SetMaxHealth(TUNING_FLYTRAP[growth_stages[inst.stage_plus].name .. "HEALTH"])
    inst.components.locomotor.runspeed = TUNING_FLYTRAP[growth_stages[inst.stage_plus].name .. "SPEED"]

    
    if stage_plus >= 50 then
        if not inst.components.planarentity then 
            inst:AddComponent("planarentity")
        end
        if not inst.components.planardamage then
            inst:AddComponent("planardamage")
        end
        inst.components.combat:SetDefaultDamage(40)
        inst.components.planardamage:SetBaseDamage(30)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.has_planarentity = true
        return 
    end
end

local function OnEat(inst, food)
    inst.components.timer:SetTimeLeft("finish_transformed_life", inst.components.timer:GetTimeLeft("finish_transformed_life") + food.components.edible.hungervalue / 25 * 480)
    -- If we're not an adult
    if inst.stage < 3 then
        inst:DoTaskInTime(0.5, function()
            inst.stage = inst.stage + 1
            inst.stage_plus = inst.stage
            SetStage(inst, inst.stage_plus)
        end)
    elseif inst.stage_plus < 50 then
        inst.stage_plus = inst.stage_plus + 1
        SetStage(inst, inst.stage_plus)
    else
        inst.stage_plus = 50
    end
    inst.components.health:DoDelta(math.max(food.components.edible.healthvalue * 4, 0) + food.components.edible.hungervalue * 2)
end

local function OnEntitySleep(inst)
    if TheWorld.state.isday then
        if inst.components.homeseeker then -- #FIXME no homeseeker?
            inst.components.homeseeker:ForceGoHome()
        end
    end
end

local function OnSave(inst, data)
    if inst.stage then
        data.stage = inst.stage
        data.stage_plus = inst.stage_plus
    end

    data.has_planarentity = inst.has_planarentity
    data.healthpercent = inst.components.health:GetPercent() or 1
end

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(5, 2.5)
    else
        inst.components.health:StopRegen()
    end
end

local function OnLoad(inst, data)
    OnHealthDelta(inst)
    if not data then
        return
    end

    inst.stage = data.stage or 1
    inst.stage_plus = data.stage_plus or 1
    SetStage(inst, inst.stage_plus, true)
    if data.healthpercent ~= nil then
        inst.components.health:SetPercent(data.healthpercent)
    end
    
    inst.has_planarentity = data.has_planarentity
    if inst.has_planarentity then
        if not inst.components.planarentity then
            inst:AddComponent("planarentity")
        end
        if not inst.components.planardamage then
            inst:AddComponent("planardamage")
            inst.components.planardamage:SetBaseDamage(30)
        end
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function OnDeath(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local lureplantbulb = SpawnPrefab("lureplantbulb")
    lureplantbulb.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(lureplantbulb)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.2, 1.2, 1.2)
    fx.Transform:SetPosition(ix, iy, iz)
    
    if inst.stage_plus > 2 then
        for i = 1, math.floor(inst.stage_plus / 2) do
            local plantmeat = SpawnPrefab("plantmeat")
            plantmeat.Transform:SetPosition(ix, iy, iz)
            inst.components.lootdropper:FlingItem(plantmeat)
        end
    end

    inst:Remove()
end

local function SanityAura(inst, observer)
    return not observer:HasTag("plantkin") and -TUNING_FLYTRAP.SANITYAURA_SMALL or 0
end

local function ShouldSleep(inst)
    return NocturnalSleepTest(inst)
    and not (inst:GetBufferedAction() and inst:GetBufferedAction().action == ACTIONS.EAT)
end

local function ShouldWake(inst)
    return NocturnalWakeTest(inst)
end

local function WakeIfFarFromLeader(inst)
    local should_sleep = false
    inst:DoPeriodicTask(3, function(inst)
        local leader = inst.components.follower and inst.components.follower:GetLeader()
        if leader and leader:IsValid() then
            -- 如果主人距离超过一定范围，唤醒
            local dist_sq = inst:GetDistanceSqToInst(leader)
            should_sleep = dist_sq < 20 * 20  
        end

        if not should_sleep then
            inst.components.sleeper:WakeUp()
        end
    end)
end

local brain = require("brains/wormwood_flytrapbrain")

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("venus_flytrap")
    inst.AnimState:SetBuild("venus_flytrap_sm_build")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("dirt")

    inst.DynamicShadow:SetSize(2.5, 1.5)

    inst.Transform:SetFourFaced()

    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    -- inst:AddTag("monster")
    inst:AddTag("flytrap")
    -- inst:AddTag("hostile")
    inst:AddTag("animal")
    inst:AddTag("usefastrun")
    inst:AddTag("plantcreature")
    inst:AddTag("wormwood_pet")
    inst:AddTag("wormwood_pet_battle")
    inst:AddTag("lunar_aligned")

    MakeCharacterPhysics(inst, 10, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst:AddComponent("knownlocations")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING_FLYTRAP.FLYTRAP_CHILD_SPEED
    inst.components.locomotor:SetAllowPlatformHopping(true)
    -- inst.components.locomotor.hop_distance = 3.5 -- 跳跃距离
    -- inst.components.locomotor.hop_height = 0.5 -- 跳跃高度

    inst:AddComponent("embarker") -- 登船组件
    inst:AddComponent("drownable") -- 防溺水组件

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.MEAT}, {FOODTYPE.MEAT})
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING_FLYTRAP.FLYTRAP_CHILD_HEALTH)
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(25)
    inst.components.combat:SetAttackPeriod(TUNING_FLYTRAP.FLYTRAP_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRange(2, 3)
    -- inst.components.combat:SetTarget(nil)  -- 初始无目标

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"lureplantbulb"})

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst.WakeIfFarFromLeader = WakeIfFarFromLeader
    inst:WakeIfFarFromLeader()

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwormwood_flytrap")

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "stem")
    MakeMediumBurnableCharacter(inst, "stem")

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    local timer = inst:AddComponent("timer")
    timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_FRUITDRAGON_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)
    
    inst.no_spawn_fx = true
    inst.stage = 1
    inst.stage_plus = 1
    inst.OnEntitySleep = OnEntitySleep
    inst.has_planarentity = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.RemoveWormwoodPet = finish_transformed_life

    return inst
end

return Prefab("wormwood_flytrap", fn, assets, prefabs)
