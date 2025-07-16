local brain = require("brains/wormwood_grassgatorbrain")
local SGwormwood_grassgator = require("stategraphs/SGwormwood_grassgator")

local assets =
{
    Asset("ANIM", "anim/grass_gator.zip"),
    Asset("ANIM", "anim/grass_gator_basic.zip"),
    Asset("ANIM", "anim/grass_gator_basic_water.zip"),
    Asset("ANIM", "anim/grass_gator_actions.zip"),
    Asset("ANIM", "anim/grass_gator_actions_water.zip"),
}

local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return DefaultWakeTest(inst) or IsAnyPlayerInRange(x, y, z, WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return DefaultSleepTest(inst) and not IsAnyPlayerInRange(x, y, z, SLEEP_NEAR_ENEMY_DISTANCE)
end

local function RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    return inst.components.combat.target
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.KOALEFANT_CHASE_DIST)
end

local function ShareTargetFn(dude)
    return dude:HasTag("grassgator") and not dude:HasTag("player") and not dude.components.health:IsDead()
end

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    -- 掉落容器中的所有物品
    if inst.components.container then
        for i = 1, inst.components.container:GetNumSlots() do
            local item = inst.components.container:GetItemInSlot(i)
            if item then
                inst.components.container:DropItemBySlot(i)
                item.Transform:SetPosition(ix, iy, iz)
            end
        end
    end

    local fig = SpawnPrefab("fig")
    fig.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(fig)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.5, 1.5, 1.5)
    fx.Transform:SetPosition(ix, iy, iz)
    inst:Remove()
end


local function OnDeath(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    -- 掉落容器中的所有物品
    if inst.components.container then
        inst.components.container:DropEverything(true)
    end

    local fig = SpawnPrefab("fig")
    fig.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(fig)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.5, 1.5, 1.5)
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
        elseif data.attacker.components.combat then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end

    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 5)
end

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(5, 2.5)
    else
        inst.components.health:StopRegen()
    end
end

local function OnTimerDone(inst, data)
    if data and data.name == "shed" then
        inst.shed_ready = true
    end
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
    if data.name == "planarentity" then
        if inst.components.planardamage then
        inst:RemoveComponent("planardamage")
        end
        if inst.components.planarentity then
        inst:RemoveComponent("planarentity")
        end
        inst.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
    end
end

local function OnSave(inst, data)
    if inst.shed_ready then
        data.shed_ready = inst.shed_ready
    end

    if inst.components.timer:TimerExists("shed") then
        data.shed_timer = inst.components.timer:GetTimeLeft("shed")
    end

    data.has_planarentity = inst.has_planarentity
end

local function OnLoad(inst, data)
    OnHealthDelta(inst)
    if data ~= nil then
        if data.shed_ready ~= nil then
            inst.shed_ready = data.shed_ready           
        elseif data.shed_timer ~= nil then
            if inst.components.timer:TimerExists("shed") then
                inst.components.timer:SetTimeLeft("shed",data.shed_timer)
            else                
                inst.components.timer:StartTimer("shed", data.shed_timer)
            end
        end
    end

    inst.has_planarentity = data.has_planarentity
    if inst.has_planarentity then
        if not inst.components.planarentity then
            inst:AddComponent("planarentity")
        end
        if not inst.components.planardamage then
            inst:AddComponent("planardamage")
            inst.components.planardamage:SetBaseDamage(20)
        end
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function isovershallowwater(inst)
    local tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())
    if tile then
        local tile_info = GetTileInfo(tile)
        if tile_info ~= nil and tile_info.ocean_depth ~= nil then                   
            if tile_info.ocean_depth == "SHALLOW" then
                return true
            end
        end
    end
end

local function checkforshallowwater(inst)    

    local x,y,z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        return
    end


    if inst:IsValid() and not inst.components.sleeper:IsAsleep() and (not inst.sg or not inst.sg:HasStateTag("diving")) then
        if not isovershallowwater(inst) then 

            --inst.movetoshallow = true       
            inst:PushEvent("diveandrelocate")
        end         
    end
end

local TILEDEPTH_LOOKUP = TUNING.ANCHOR_DEPTH_TIMES -- FIXME(JBK): Relying on an arbitrary tuning table for winch instead of having a number value for depths in the tiledefs themselves.
local function findnewshallowlocation(inst, range)
    if not range then 
        range = 15 + (math.random()*5) -- Keep in sync with SGgrassgator [GGRANGECHECK]
    end
    inst.surfacelocation = nil
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local angle = (inst.Transform:GetRotation()-180) * DEGREES 
    local finaloffset = FindValidPositionByFan(angle, range, 8, function(offset)
        local x, z = pos.x + offset.x, pos.z + offset.z

        local tile = TheWorld.Map:GetTileAtPoint(x,0,z)
        if tile then
            local tile_info = GetTileInfo(tile)
            local iswater = not TheWorld.Map:IsVisualGroundAtPoint(x,0,z)
            if iswater and tile_info ~= nil and tile_info.ocean_depth ~= nil then
                local depth_value = TILEDEPTH_LOOKUP[tile_info.ocean_depth]
                if depth_value and depth_value <= TILEDEPTH_LOOKUP.SHALLOW then
                    return true
                end
            end
        end
    end)
    if finaloffset then
        return pos+finaloffset
    end
end

local function OnEntitySleep(inst)
    local pos = inst:GetPosition()
    inst.Transform:SetPosition(pos.x,0,pos.z)
end

local function ShouldEat(inst)
    if inst.components.container then
        local item = inst.components.container:GetItemInSlot(5)
        if not item or not item.components.edible then return end
        local stacksize = 1
        if item and item.components.stackable and item.components.stackable.stacksize > 0 then
            stacksize = item.components.stackable.stacksize
        end

        inst.components.health:DoDelta((math.max(item.components.edible.healthvalue * 4, 0) + item.components.edible.hungervalue) * 2 * stacksize)

        if item and item.prefab == "moon_tree_blossom_charged" then
            if not inst.components.planarentity then
                inst:AddComponent("planarentity")
            end
            if not inst.components.planardamage then
                inst:AddComponent("planardamage")
            end
            if inst.components.timer:TimerExists("buff_planarentity") then
                inst.components.timer:SetTimeLeft("buff_planarentity", inst.components.timer:GetTimeLeft("buff_planarentity") + stacksize * TUNING.TOTAL_DAY_TIME)
            end
            inst.components.timer:StartTimer("buff_planarentity", stacksize * TUNING.TOTAL_DAY_TIME)
            inst.components.planardamage:SetBaseDamage(20)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.has_planarentity = true
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/eat_treat")
            item:Remove()
        elseif item and item.components.edible and item.components.edible.foodtype == FOODTYPE.VEGGIE then
            inst.components.timer:SetTimeLeft("finish_transformed_life", inst.components.timer:GetTimeLeft("finish_transformed_life") + stacksize * item.components.edible.hungervalue / 25 * TUNING.TOTAL_DAY_TIME)
            if item.components.edible.healthvalue > 0 then
                inst.components.health:DoDelta(item.components.edible.healthvalue * stacksize * 4)
            end
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/eat_treat")
            item:Remove()
        end
    end
end

local function ShouldFight(inst)
    if inst.components.container and inst.components.container:NumItems() == 0 then 
        inst.shouldfight = true
    else
        inst.shouldfight = false
    end
end

local function ShouldFollow(inst)
    local should_sleep = false
    local leader = inst.components.follower and inst.components.follower:GetLeader()
    if leader and leader:IsValid() then
        local dist_sq = inst:GetDistanceSqToInst(leader)
        should_sleep = dist_sq < 20 * 20  
    end

    if not should_sleep then
        inst.components.sleeper:WakeUp()
    end
end

-- local function EquipHammer(inst)
--     if not inst.components.inventory then
--         inst:AddComponent("inventory")
--         inst.components.inventory.maxslots = 1
--     end
--     if not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
--         local tool = CreateEntity()
--         tool.entity:AddTransform()
--         tool:AddComponent("inventoryitem")
--         tool.persists = false
--         tool.components.inventoryitem:SetOnDroppedFn(inst.Remove)
--         tool:AddTag("nosteal")
--         tool:AddComponent("equippable")
--         tool:AddComponent("tool")
--         tool.components.tool:SetAction(ACTIONS.HAMMER, 0.5)
--         inst.components.inventory:Equip(tool)
--     end
-- end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close")
end

local function create_base(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .75)

    inst.DynamicShadow:SetSize(4.5, 2)
    inst.Transform:SetSixFaced()

    inst:AddTag("grassgator")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst:AddTag("wormwood_pet")
    inst:AddTag("wormwood_pet_battle")
    inst:AddTag("lunar_aligned")

    --saltlicker (from saltlicker component) added to pristine state for optimization
    -- inst:AddTag("saltlicker")

    inst.AnimState:SetBank("grass_gator")
    inst.AnimState:SetBuild("grass_gator")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "grass_gator_body"
    inst.components.combat:SetDefaultDamage(50)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAttackPeriod(2)
    -- inst.components.combat:SetRange(3, 4)

    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.GRASSGATOR_HEALTH)
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"fig"})
    
    inst:AddComponent("worker") -- 允许执行采集和敲击等动作

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
--[[
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
]]


    -- inst:AddComponent("saltlicker")
    -- inst.components.saltlicker:SetUp(TUNING.SALTLICK_GRASSGATOR_USES)

    MakeLargeBurnableCharacter(inst, "grass_gator_body")
    MakeLargeFreezableCharacter(inst, "grass_gator_body")

    MakeHauntablePanic(inst)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.GRASSGATOR_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.GRASSGATOR_RUNSPEED
    inst.components.locomotor:CanPathfindOnWater()


    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwormwood_grassgator")

    inst:AddComponent("embarker")
    inst.components.embarker.embark_speed = inst.components.locomotor.runspeed

    inst.components.locomotor:SetAllowPlatformHopping(true)


    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetBanks("grass_gator", "grass_gator_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(
            function(inst)
                inst.landspeed = inst.components.locomotor.runspeed
                inst.components.locomotor.runspeed = TUNING.GRASSGATOR_RUNSPEED_WATER
                inst.hop_distance = inst.components.locomotor.hop_distance
                inst.components.locomotor.hop_distance = 4
            end)
    inst.components.amphibiouscreature:SetExitWaterFn(
            function(inst)
                if inst.landspeed then
                    inst.components.locomotor.runspeed = TUNING.GRASSGATOR_RUNSPEED
                end
                if inst.hop_distance then
                    inst.components.locomotor.hop_distance = inst.hop_distance
                end
            end)

    inst.components.locomotor.pathcaps = { allowocean = true }

    -- inst:DoPeriodicTask(2, checkforshallowwater)
    -- inst.findnewshallowlocation = findnewshallowlocation
    -- inst.isovershallowwater = isovershallowwater

    inst.shouldfight = false

    -- inst:DoTaskInTime(0, EquipHammer)
    
    inst:DoPeriodicTask(2, function(inst)
        ShouldFight(inst)
        ShouldFollow(inst)
    end)

    local timer = inst:AddComponent("timer")
    inst.components.timer:StartTimer("shed", TUNING.GRASSGATOR_SHEDTIME_SET + (math.random()* TUNING.GRASSGATOR_SHEDTIME_VAR))
    timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_FRUITDRAGON_LIFETIME * 2)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("itemget",function(inst,data) 
        ShouldEat(inst)
    end)
        
    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.no_spawn_fx = true
    inst.has_planarentity = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep    
    inst.RemoveWormwoodPet = finish_transformed_life

    return inst
end

return Prefab("wormwood_grassgator", create_base, assets, prefabs)
