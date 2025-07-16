GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

local pets_damage_absorb = tonumber(GetModConfigData("pets_damage_absorb"))
-- local pets_piko_sleep_atnight = tostring(GetModConfigData("pets_piko_sleep_atnight"))
local pets_flytrap_sleep_onday = tostring(GetModConfigData("pets_flytrap_sleep_onday"))
local pets_mandrakeman_sleep_onday = tostring(GetModConfigData("pets_mandrakeman_sleep_onday"))

local pets_num_carrat = tonumber(GetModConfigData("pets_num_carrat"))
local pets_num_lightflier = tonumber(GetModConfigData("pets_num_lightflier"))
local pets_num_piko = tonumber(GetModConfigData("pets_num_piko"))
local pets_num_piko_orange = tonumber(GetModConfigData("pets_num_piko_orange"))
local pets_num_fruitdragon = tonumber(GetModConfigData("pets_num_fruitdragon"))
local pets_num_grassgator = tonumber(GetModConfigData("pets_num_grassgator"))
local pets_num_flytrap = tonumber(GetModConfigData("pets_num_flytrap"))
local pets_num_mandrakeman = tonumber(GetModConfigData("pets_num_mandrakeman"))

local PETS_PREFABS = {
    "wormwood_carrat",
    "wormwood_lightflier",
    "wormwood_fruitdragon",
    "wormwood_piko",
    "wormwood_piko_orange",
    "wormwood_grassgator",
    "wormwood_flytrap",
    "wormwood_mandrakeman",
}


-- 低血量闪烁效果函数
local function HealthFlash(inst)
    if inst.lowhealth then
        -- 使用正弦函数控制闪烁周期（3秒完整周期）
        local time = GetTime()
        local cycle = 2 * math.pi * time / 1  
        local intensity = 0.3 + 0.2 * math.sin(cycle)  -- 亮度范围0.1~0.5（更暗）
        
        -- 设置暗红色 (R=0.8, G=0, B=0)
        inst.AnimState:SetAddColour(intensity * 0.8, 0, 0, 0)
    end
end

-- 检查血量状态
local function CheckHealth(inst)
    local islow = inst.components.health:GetPercent() <= inst.lowhealththreshold
    
    if islow and not inst.lowhealth then
        -- 进入低血量状态
        inst.lowhealth = true
        if not inst.flashtask then
            inst.flashtask = inst:DoPeriodicTask(FRAMES, HealthFlash) -- 每帧刷新闪烁
        end
    elseif not islow and inst.lowhealth then
        -- 离开低血量状态
        inst.lowhealth = false
        if inst.flashtask then
            inst.flashtask:Cancel()
            inst.flashtask = nil
        end
        inst.AnimState:SetAddColour(0, 0, 0, 0) -- 重置颜色
    end
end

-- 低生命周期闪烁
local function LifeFlash(inst)
    if inst.lifeflashtask then
        inst.lifeflashtask:Cancel()
        inst.lifeflashtask = nil
    end
    local start_time = GetTime()
    inst.lifeflashtask = inst:DoPeriodicTask(FRAMES, function(inst)
        local t = GetTime() - start_time
        -- 1秒一个周期，透明度从1->0->1
        local alpha = 0.5 * (1 + math.cos(2 * math.pi * t / 1)) * 0.75 + 0.25
        inst.AnimState:SetMultColour(1, 1, 1, alpha)
    end)
end

local function StopLifeFlash(inst)
    if inst.lifeflashtask then
        inst.lifeflashtask:Cancel()
        inst.lifeflashtask = nil
    end
    inst.AnimState:SetMultColour(1, 1, 1, 1)
end

local function OnDeath(inst, item)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local loot = SpawnPrefab(item)
    loot.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(loot)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetPosition(ix, iy, iz)

    inst:Remove()
end

for _, pet in ipairs(PETS_PREFABS) do
    AddPrefabPostInit(pet, function(inst)
        if not TheWorld.ismastersim then return end

        inst.components.health.externalabsorbmodifiers:SetModifier("wormwood_pet", pets_damage_absorb)

        if not inst.components.damagetypebonus then inst:AddComponent("damagetypebonus") end
        if not inst.components.damagetyperesist then inst:AddComponent("damagetyperesist") end
        inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.1, "wormwood_pet")
        inst.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.9, "wormwood_pet")
        
        -- 添加低血量闪烁特效逻辑
        inst.lowhealththreshold = 0.2  -- 20%血量阈值
        inst.lowhealth = false
        inst.flashtask = nil

        -- if not inst:HasTag("character") then
        --     inst:AddTag("character")
        -- end
        inst:AddTag("companion")
        if not inst:HasTag("notraptrigger") then
            inst:AddTag("notraptrigger")
        end
        if not inst:HasTag("soulless") then
            inst:AddTag("soulless")
        end
        
        -- 监听血量变化
        inst:ListenForEvent("healthdelta", CheckHealth)
        inst:DoTaskInTime(0, CheckHealth)

        inst:DoPeriodicTask(0.5, function(inst)
            local timer = inst.components.timer
            if timer and timer:TimerExists("finish_transformed_life") and not timer:IsPaused("finish_transformed_life") then
                local left = timer:GetTimeLeft("finish_transformed_life")
                if left and left < 120 then
                    if not inst.lifeflashtask then
                        LifeFlash(inst)
                    end
                else
                    if inst.lifeflashtask then
                        StopLifeFlash(inst)
                    end
                end
            else
                if inst.lifeflashtask then
                    StopLifeFlash(inst)
                end
            end
        end)
        inst:ListenForEvent("timerdone", function(inst, data)
            if data.name == "finish_transformed_life" then
                StopLifeFlash(inst)
            end
        end)

        -- 群体仇恨
        local function CanShareTarget(dude)
            return (dude:HasTag("wormwood_pet")) -- 必须是同类
                and not dude:IsInLimbo()   -- 不在传送状态
        end

        inst:ListenForEvent("attacked", function(inst, data)
            if data.attacker ~= nil and not inst.components.health:IsDead() then
                inst.components.combat:ShareTarget(data.attacker, 30, CanShareTarget, 999)
            end
        end)
    end)
end

local function OnEat(inst, data)
    -- 每次喂食延长生命周期
    local food = data.food
    local timer = inst.components.timer
    
    inst.components.health:DoDelta(math.max(food.components.edible.healthvalue * 4, 0) + food.components.edible.hungervalue * 2)
    if timer then
        if timer:TimerExists("finish_transformed_life") then
            timer:SetTimeLeft("finish_transformed_life", timer:GetTimeLeft("finish_transformed_life") + food.components.edible.hungervalue / 25 * TUNING.TOTAL_DAY_TIME)
        end
    end

    if food.prefab == "moon_tree_blossom_charged" then
        if not inst.components.planarentity then
            inst:AddComponent("planarentity")
        end
        if not inst.components.planardamage then
            inst:AddComponent("planardamage")
        end
        if timer:TimerExists("buff_planarentity") then
            timer:SetTimeLeft("buff_planarentity", timer:GetTimeLeft("buff_planarentity") + TUNING.TOTAL_DAY_TIME)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        else
            timer:StartTimer("buff_planarentity", TUNING.TOTAL_DAY_TIME)
        end
        inst.components.planardamage:SetBaseDamage(16)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.has_planarentity = true
    end
end


local function OnChargedExpire(inst, data)
    if data.name == "buff_planarentity" then
        inst:RemoveComponent("planarentity")
        inst:RemoveComponent("planardamage")
        inst.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
    end
end

local function OnDropped(inst)
    inst.components.sleeper:WakeUp()
    inst.sg:GoToState("idle")
    if inst.prefab == "wormwood_fruitdragon" and not inst._is_ripe and not inst.components.timer:TimerExists("doripe") then
        inst.components.timer:StartTimer("doripe", 5)
    end
end

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(5, 2.5)
    else
        inst.components.health:StopRegen()
    end
end

local function OnSave(inst, data)
    data.has_planarentity = inst.has_planarentity
end

local function OnLoad(inst, data)
    if not data then
        return
    end

    inst.has_planarentity = data.has_planarentity
    if inst.has_planarentity then
        if not inst.components.planarentity then
            inst:AddComponent("planarentity")
        end
        if not inst.components.planardamage then
            inst:AddComponent("planardamage")
            inst.components.planardamage:SetBaseDamage(15)
        end
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local wormwood_carratbrain = require("brains/wormwood_carratbrain")

AddPrefabPostInit("wormwood_carrat", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetBrain(wormwood_carratbrain)
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.pushlandedevents = false
    inst.components.inventoryitem.grabbableoverridetag = "wormwood_pets_carrat_pickup"
    inst.components.inventoryitem.imagename = "wormwood_carrat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_carrat.xml" 
    inst.components.inventoryitem:SetSinks(true)

    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("death", function(inst)
        OnDeath(inst, "carrot")
    end)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.SEEDS, FOODTYPE.VEGGIE}, {FOODTYPE.SEEDS, FOODTYPE.VEGGIE})
    inst.components.eater:SetStrongStomach(true)
    inst:ListenForEvent("oneat", OnEat)
    
    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME * 2, nil, OnDropped)
    inst:ListenForEvent("timerdone", OnChargedExpire)

    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"carrot"})

    inst.has_planarentity = false
    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end

        OnSave(inst, data)
    end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end
        
        OnHealthDelta(inst)
        OnLoad(inst, data)
    end
end)

AddPrefabPostInit("wormwood_lightflier", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "faster", 1.5)

    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("death", function(inst)
        OnDeath(inst, "lightbulb")
    end)

    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"lightbulb"})

    inst.has_planarentity = false
    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end

        OnSave(inst, data)
    end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end

        OnHealthDelta(inst)
        OnLoad(inst, data)
    end
end)

-- 控制直接设置为成熟 build
local function MakeRipe(inst, force)
	if inst._ripen_pending or force then
		inst._ripen_pending = false
		inst._is_ripe = true

		inst.components.combat:SetDefaultDamage(TUNING.FRUITDRAGON.UNRIPE_DAMAGE * 1.5)

		inst.AnimState:SetBuild("fruit_dragon_ripe_build")
	end
end

local function MakeUnripe(inst, force)
	if inst._unripen_pending or force then
		inst._unripen_pending = false
		inst._is_ripe = false

		inst.components.combat:SetDefaultDamage(TUNING.FRUITDRAGON.UNRIPE_DAMAGE)

		inst.AnimState:SetBuild("fruit_dragon_build")
	end
end

-- 控制播放成熟动画
local function QueueRipen(inst) 
    inst._ripen_pending = not inst._is_ripe
    inst._unripen_pending = false
    inst.components.combat:SetDefaultDamage(50)
end

local function QueueUnripe(inst)
    -- 这个函数理论上是不会调用的，仅留作以后用
    inst._ripen_pending = false
    inst._unripen_pending = inst._is_ripe
    inst.components.combat:SetDefaultDamage(40)
end

local function Sleeper_OnSleep(inst)
end

local function Sleeper_OnWakeUp(inst)
	if not inst._sleep_interrupted then
		if not inst.components.timer:TimerExists("doripe") and not inst._ripen_pending and not inst._is_ripe then
			QueueRipen(inst)
		end
	end
	inst._sleep_interrupted = true -- reseting it
end

local function OnEntitySleep(inst)
	inst._entitysleeptime = GetTime()
    inst.components.timer:PauseTimer("doripe") 
end

local function OnEntityWake(inst)
    inst.components.timer:ResumeTimer("doripe")
	if inst._entitysleeptime == nil then
		return
	end
    if inst._is_ripe then
        inst:MakeRipe(true)
    -- elseif not inst.components.timer:TimerExists("doripe") then
    --     inst.components.timer:StartTimer("doripe", 10)
    -- else
    --     inst.components.timer:SetTimeLeft("doripe", 10) -- 双重保险
    end
end

local function doripe(inst, data)
    if data.name == "checkripe" then
        if not inst._is_ripe then
            inst.components.timer:StartTimer("doripe", 5)
        end
    end
    if data.name == "doripe" then
        if (inst.components.combat and inst.components.combat.target) or inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists("panicing") then
            inst.components.timer:StartTimer("doripe", 10)
            inst.components.timer:SetTimeLeft("doripe", 10) -- 双重保险
        else
            inst.components.sleeper:GoToSleep(15)
            inst.components.timer:StartTimer("checkripe", 20)   -- 确保在加载范围外时，蝾螈成熟任务被中断后能够恢复
        end
        -- 处理意外情况
        inst:DoTaskInTime(3, function(inst)
            if not inst.components.sleeper:IsAsleep() and not inst.components.timer:TimerExists("doripe") then
                inst.components.timer:StartTimer("doripe", 7)
                inst.components.timer:SetTimeLeft("doripe", 7)
            end
        end)
    end
end

local wormwood_fruitdragonbrain = require("brains/wormwood_fruitdragonbrain")
local SGwormwood_fruitdragon_ex = require("stategraphs/SGwormwood_fruitdragon_ex")

AddPrefabPostInit("wormwood_fruitdragon", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddTag("wormwood_pet_battle")

    inst:SetBrain(wormwood_fruitdragonbrain)
    inst.entity:AddLight()

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.pushlandedevents = false
    inst.components.inventoryitem.grabbableoverridetag = "wormwood_pets_fruitdragon_pickup"
    inst.components.inventoryitem.imagename = "wormwood_fruitdragon"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_fruitdragon.xml" 
    inst.components.inventoryitem:SetSinks(true)
    
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.SEEDS, FOODTYPE.VEGGIE}, {FOODTYPE.SEEDS, FOODTYPE.VEGGIE})
    inst.components.eater:SetStrongStomach(true)
    inst:ListenForEvent("oneat", OnEat)
    inst:ListenForEvent("death", function(inst)
        OnDeath(inst, "dragonfruit")
    end)
    
    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME * 2, nil, OnDropped)
    inst:ListenForEvent("timerdone", OnChargedExpire)
    
    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"dragonfruit"})

    inst.has_planarentity = false
    
    inst:SetStateGraph("SGwormwood_fruitdragon_ex")
	inst.MakeRipe = MakeRipe
	inst.MakeUnripe = MakeUnripe
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
	inst:ListenForEvent("gotosleep", Sleeper_OnSleep)
	inst:ListenForEvent("onwakeup", Sleeper_OnWakeUp)

    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end

	    data._is_ripe = inst._is_ripe
        OnSave(inst, data)
    end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end

        inst._is_ripe = data._is_ripe
        if data ~= nil and data._is_ripe then
            inst:MakeRipe(true)
            inst.components.combat:SetDefaultDamage(50)
            inst.components.inventoryitem.imagename = "wormwood_fruitdragon_ripe"
            inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_fruitdragon_ripe.xml" 
            if inst.components.timer:TimerExists("doripe") then
                inst.components.timer:StopTimer("doripe")
            end
        end
        OnLoad(inst, data)
    end

    if not inst._is_ripe and not inst.components.timer:TimerExists("doripe") then
        inst.components.timer:StartTimer("doripe", TUNING.TOTAL_DAY_TIME * 2)
    end
    inst:ListenForEvent("timerdone", doripe)
end)

-- 草鳄鱼添加容器功能代码来自宠物箱子 mod：https://steamcommunity.com/sharedfiles/filedetails/?id=2878207237  我的救星 QAQ
local _G = GLOBAL
local Vector3 = _G.Vector3

local containers = require "containers"
local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end


params.pet_container = 
{
    widget =
    {
        slotpos = {
            -- 第一行
            Vector3(-75, 64 + 8, 0),  -- 左上
            Vector3(0, 64 + 8, 0),    -- 中上
            Vector3(75, 64 + 8, 0),   -- 右上
            
            -- 第二行
            Vector3(-75, 0, 0),       -- 左中
            Vector3(0, 0, 0),         -- 正中
            Vector3(75, 0, 0),        -- 右中
            
            -- 第三行
            Vector3(-75, -64 - 8, 0), -- 左下
            Vector3(0, -64 - 8, 0),   -- 中下
            Vector3(75, -64 - 8, 0)   -- 右下
        },
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 150, 0),
    },
    type = "chest",
    itemtestfn = function(inst, item, slot) -- 容器里可以装的物品的条件
        return not item:HasTag("_container") and not item:HasTag("irreplaceable")
    end
}

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

AddPrefabPostInit("wormwood_grassgator", function(inst)
    if not _G.TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst) 
			inst.replica.container:WidgetSetup("pet_container") 
		end
    elseif not inst.components.container then
        inst:AddComponent("container")
        inst.components.container:WidgetSetup("pet_container")
        inst.components.container.canbeopened = true
    end
end)


local function Sleeper_SleepTest(inst)
    return false
end

local function Sleeper_WakeTest(inst)
    return true
end

AddPrefabPostInit("wormwood_flytrap", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if pets_flytrap_sleep_onday == "false" then
        -- inst.components.sleeper:SetNocturnal(false)
        inst.components.sleeper:SetWakeTest(Sleeper_WakeTest)
        inst.components.sleeper:SetSleepTest(Sleeper_SleepTest)
    else
        inst:WakeIfFarFromLeader()
    end

--     local old_inspect_fn = inst.components.inspectable.GetStatus
--     inst.components.inspectable.GetStatus = function(inst, viewer)
--         local status = old_inspect_fn and old_inspect_fn(inst, viewer) or ""
--         if not viewer then return end
--         if viewer:HasTag("wormwood_pets_flytrap") then
--             viewer:DoTaskInTime(FRAMES, function()
--                 print(string.format("stage & health & time: %d %d %d", inst.stage_plus, inst.components.health:GetPercent(), inst.components.timer:GetTimeLeft("finish_transformed_life")))
    
--                 if inst.stage_plus == 50 and inst.components.health:GetPercent() == 1 
--                     and inst.components.timer:GetTimeLeft("finish_transformed_life") > TUNING.TOTAL_DAY_TIME * 5 then
--                     viewer.components.talker:Say("吃饱了")
--                 else
--                     viewer.components.talker:Say("想要吃的")
--                 end
--             end)
--         else
--             viewer.components.talker:Say("想要能填饱肚子的东西")
--         end
        
--         return status
--     end
end)

AddPrefabPostInit("wormwood_mandrakeman", function(inst)
    if not TheWorld.ismastersim then return end
    if pets_mandrakeman_sleep_onday == "false" then
        -- inst.components.sleeper:SetNocturnal(false)
        inst.components.sleeper:SetWakeTest(Sleeper_WakeTest)
        inst.components.sleeper:SetSleepTest(Sleeper_SleepTest)
    else
        inst:WakeIfFarFromLeader()
    end
end)

AddPrefabPostInit("mandrake_active", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.no_spawn_fx = true
end)

local ALLY_TAGS = {
    "player",
    "wormwood_pet",
    "wormwood_lunarplant",
    "wormwood_gestalt_guard",
    "wormwood_lunar_grazer",
    "wormwood_deciduous",
	"companion",
}

local CHECK_DIST = 20
local RETARGET_DIST = 15
local RETARGET_TAGS = { "_health" }
local RETARGET_NO_TAGS = {"FX", "NOCLICK", "INLIMBO", "wall", "structure", "aquatic", "notarget"}

local function Aggressive_RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end
    
    return FindEntity(inst, CHECK_DIST, function(guy)
         -- 确保ent有效
        if not guy or not guy:IsValid() then
            return false
        end

		-- 排除月蛾
		if guy.prefab == "moonbutterfly" then 
			return false
		end

        -- 检查是否是玩家的追随者
        if guy.components.follower and guy.components.follower:GetLeader() 
           and guy.components.follower:GetLeader():HasTag("player") then
            return false
        end
          
        -- 修正为检查玩家附近的实体
		if guy:IsNear(inst.components.follower.leader, RETARGET_DIST) then
        	return inst.components.combat:CanTarget(guy)
		end
    end, RETARGET_TAGS, ConcatArrays(ALLY_TAGS, RETARGET_NO_TAGS))
end

local function Defensive_RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    return inst.components.combat.target
end

local function OnSave_pet_control(inst, data)
    data.pets_pickable = inst.pets_pickable
    data.pets_standstill = inst.pets_standstill
    data.pets_atk_mode = inst.pets_atk_mode
    data.pets_moving_combat = inst.pets_moving_combat
    data.pets_mandrake_sound = inst.pets_mandrake_sound
end

local function OnLoad_pet_control(inst, data)
    -- 似乎不生效，先默认可拾取吧
    -- if data.pets_pickable ~= nil then
    --     inst.pets_pickable = data.pets_pickable
    --     if inst.pets_pickable == false then
    --         inst:RemoveTag("wormwood_pets_carrat_pickup")
    --         inst:RemoveTag("wormwood_pets_piko_pickup")
    --         inst:RemoveTag("wormwood_pets_fruitdragon_pickup")
    --     end
    -- end
    if data.pets_standstill ~= nil then
        inst.pets_standstill = data.pets_standstill
    end
    if data.pets_atk_mode ~= nil then
        inst.pets_atk_mode = data.pets_atk_mode
        if inst.pets_atk_mode == "aggressive" then
            -- 等待随从加载
            inst:DoTaskInTime(2, function(inst)
                local pets_battle = inst.components.leader:GetFollowersByTag("wormwood_pet_battle")
                for _, pet in ipairs(pets_battle) do
                    if pet ~= nil then
                        pet.components.combat:SetRetargetFunction(1, Aggressive_RetargetFn)
                    end
                end
            end)
        end
    end
    if data.pets_moving_combat ~= nil then
        inst.pets_moving_combat = data.pets_moving_combat
    end
    if data.pets_mandrake_sound ~= nil then
        inst.pets_mandrake_sound = data.pets_mandrake_sound
    end
end

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.pets_pickable = true
    inst.pets_standstill = false
    inst.pets_atk_mode = "defensive"
    inst.pets_moving_combat = false
    inst.pets_mandrake_sound = true

    inst.components.petleash:SetMaxPetsForPrefab("wormwood_carrat", pets_num_carrat)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_lightflier", pets_num_lightflier)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_piko", pets_num_piko)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_piko_orange", pets_num_piko_orange)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_fruitdragon", pets_num_fruitdragon)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_grassgator", pets_num_grassgator)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_flytrap", pets_num_flytrap)
    inst.components.petleash:SetMaxPetsForPrefab("wormwood_mandrakeman", pets_num_mandrakeman)
    inst.components.petleash:SetMaxPetsForPrefab("mandrake_active", 999)

    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then
            old_OnSave(inst, data)
        end

        OnSave_pet_control(inst, data)
    end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then
            old_OnLoad(inst, data)
        end

        OnLoad_pet_control(inst, data)
    end
end)
