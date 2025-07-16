local assets =
{
    Asset("ANIM", "anim/elderdrake_basic.zip"),
    Asset("ANIM", "anim/elderdrake_actions.zip"),
    Asset("ANIM", "anim/elderdrake_attacks.zip"),
    Asset("ANIM", "anim/elderdrake_build.zip"),
}

local SGwormwood_mandrakeman = require("stategraphs/SGwormwood_mandrakeman")

local MANDRAKEMAN_DAMAGE = 40
local MANDRAKEMAN_HEALTH = 800
local MANDRAKEMAN_ATTACK_PERIOD = 2
local MANDRAKEMAN_RUN_SPEED = 6
local MANDRAKEMAN_WALK_SPEED = 3
local MANDRAKEMAN_PANIC_THRESH = .333
local MANDRAKEMAN_HEALTH_REGEN_PERIOD = 5
local MANDRAKEMAN_HEALTH_REGEN_AMOUNT = (200/120) * 5 
local MANDRAKEMAN_SEE_MANDRAKE_DIST = 8


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

    local mandrake = SpawnPrefab("mandrake")
    mandrake.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(mandrake)
    
    if math.random() < 0.02 then
        local mandrake_2 = SpawnPrefab("mandrake")
        mandrake_2.Transform:SetPosition(ix, iy, iz)
        inst.components.lootdropper:FlingItem(mandrake_2)
    end

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.2, 1.2, 1.2)
    fx.Transform:SetPosition(ix, iy, iz)
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
end

local function GetStatus(inst)
    if inst.components.follower.leader then
        return "FOLLOWER"
    end
end

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/dissy")
end

local function CalcSanityAura(inst, observer)
    if inst.components.follower and inst.components.follower.leader == observer then
        return TUNING.SANITYAURA_SMALL
    end

    return 0
end

local function ShouldAcceptItem(inst, item)
    -- if inst:HasTag("grumpy") then
    --     return false
    -- end

    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    end

    if inst.components.eater:CanEat(item) then
        return (inst.components.eater:PrefersToEat(item)
            -- and inst.components.follower.leader
            -- and inst.components.follower:GetLoyaltyPercent() > 0.9
            )
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food
    local timer = inst.components.timer
    if item.prefab == "moon_tree_blossom_charged" then
        inst:DoTaskInTime(0.5, function()
            if not inst.components.planarentity then
                inst:AddComponent("planarentity")
            end
            if not inst.components.planardamage then
                inst:AddComponent("planardamage")
            end
            if timer:TimerExists("buff_planarentity") then
                timer:SetTimeLeft("buff_planarentity", timer:GetTimeLeft("buff_planarentity") + TUNING.TOTAL_DAY_TIME)
            else
                timer:StartTimer("buff_planarentity", TUNING.TOTAL_DAY_TIME)
            end
            inst.components.planardamage:SetBaseDamage(16)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.has_planarentity = true
        end)
    end

    if inst.components.eater:CanEat(item) then
        if inst.components.eater:PrefersToEat(item) then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader then
                giver:PushEvent("makefriend")
                giver.components.leader:AddFollower(inst)
                -- inst.components.follower:AddLoyaltyTime(TUNING.RABBIT_CARROT_LOYALTY)
                inst.components.timer:SetTimeLeft("finish_transformed_life", inst.components.timer:GetTimeLeft("finish_transformed_life") + item.components.edible.hungervalue / 25 * 480)
                inst.components.health:DoDelta(math.max(item.components.edible.healthvalue * 4, 0) + item.components.edible.hungervalue * 2)
            end
        end

        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end

    --I wear hats
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current then
            inst.components.inventory:DropItem(current)
        end

        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnChargedExpire(inst, data)
    if data.name == "buff_planarentity" then
        inst:RemoveComponent("planarentity")
        inst:RemoveComponent("planardamage")
        inst.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
    end
end

local function OnRefuseItem(inst, item)
    if not inst.components.combat.target and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("refuse")
    end
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30
local RETARGET_DIST = 10
local RETARGET_MUST_TAGS = {"_combat"}
local RETARGET_NO_TAGS = {"player", "mandrakeman", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO"}

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
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(ent) return ent:HasTag("mandrakeman") end, MAX_TARGET_SHARES)
end

local function onattackother(inst, data)
    local target = data ~= nil and data.target or nil

    if target.components.sleeper then   
        target.components.sleeper:AddSleepiness(1, 10)
    elseif target.components.grogginess then
        target.components.grogginess:AddGrogginess(1, 10)
    end
end

local function OnNewTarget(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(ent) return ent:HasTag("mandrakeman") end, MAX_TARGET_SHARES)
end

local function RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    return inst.components.combat.target
end

local function KeepTargetFn(inst, target)

    return inst.components.combat:CanTarget(target)
end

-- local function GetGiveUpString(combatcmp, target)
--     return "MANDRAKEMAN_GIVEUP", math.random(#STRINGS.MANDRAKEMAN_GIVEUP)
-- end

-- local function GetBattleCryString(combatcmp, target)
--     local strtbl =
--         target and
--         target.components.inventory and
--         target.components.inventory:FindItem(function(item) return item:HasTag("mandrake") end) and
--         "MANDRAKEMAN_MANDRAKE_BATTLECRY" or
--         "MANDRAKEMAN_BATTLECRY"
--     return strtbl, math.random(#STRINGS[strtbl])
-- end

local function OnDeath(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.MANDRAKE_SLEEP_RANGE, nil, {"playerghost", "FX", "DECOR", "INLIMBO"}, {"sleeper", "player"})
    for _, v in pairs(ents) do
        if v.components.sleeper then
            v.components.sleeper:AddSleepiness(10, TUNING.MANDRAKE_SLEEP_TIME)
        end
        if v.components.grogginess then
            v.components.grogginess:AddGrogginess(2, TUNING.MANDRAKE_SLEEP_TIME)
        end
    end

    local mandrake = SpawnPrefab("mandrake")
    mandrake.Transform:SetPosition(x, y, z)
    inst.components.lootdropper:FlingItem(mandrake)

    if math.random() < 0.02 then
        local mandrake_2 = SpawnPrefab("mandrake")
        mandrake_2.Transform:SetPosition(x, y, z)
        inst.components.lootdropper:FlingItem(mandrake_2)
    end

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.2, 1.2, 1.2)
    fx.Transform:SetPosition(x, y, z)
    inst:Remove()
end


local function transform(inst, grumpy)
    if grumpy then
        inst.AnimState:Show("head_angry")
        inst.AnimState:Hide("head_happy")
        inst:AddTag("grumpy")
    else
        inst.AnimState:Hide("head_angry")
        inst.AnimState:Show("head_happy")
        inst.sg:GoToState("happy")
        inst:RemoveTag("grumpy")
    end
end

local function OnPhaseChange(inst)
    if TheWorld.state.phase == "night" and (TheWorld.state.moonphase == "full" or TheWorld.state.moonphase == "blood") then
        if inst:HasTag("grumpy") then
            inst:DoTaskInTime(1 + math.random(), function() transform(inst, false) end )
        end
    else
        if not inst:HasTag("grumpy") then
            inst:DoTaskInTime(1 + math.random(), function() transform(inst,true) end )
        end
    end
end

local function OnEntityWake(inst)
    OnPhaseChange(inst)
end

local function OnEntitySleep(inst)
    if inst.checktask then
        inst.checktask:Cancel()
        inst.checktask = nil
    end
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
    OnHealthDelta(inst)
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
        end
        inst.components.planardamage:SetBaseDamage(10)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local brain = require("brains/wormwood_mandrakemanbrain")

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("elderdrake_build")
    inst.AnimState:SetBank("elderdrake")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("head_happy")

    inst.DynamicShadow:SetSize(1.5, 0.75)

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst:AddTag("plantcreature")
    inst:AddTag("character")
    inst:AddTag("mandrakeman")
    inst:AddTag("scarytoprey")
    inst:AddTag("grumpy")
    inst:AddTag("trader") -- trader (from trader component) added to pristine state for optimization
    inst:AddTag("_named") -- Sneak these into pristine state for optimization
    inst:AddTag("wormwood_pet")
    inst:AddTag("wormwood_pet_battle")
    inst:AddTag("lunar_aligned")

    MakeCharacterPhysics(inst, 50, 0.5)

    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk -- OnTalk ? ontalkfn?
    inst.components.talker.fontsize = 24
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("inventory")

    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = MANDRAKEMAN_RUN_SPEED
    inst.components.locomotor.walkspeed = MANDRAKEMAN_WALK_SPEED
    -- inst.components.locomotor.hop_distance = 3.5 -- 跳跃距离
    -- inst.components.locomotor.hop_height = 0.5 -- 跳跃高度
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.VEGGIE}, {FOODTYPE.VEGGIE})
    inst.components.eater:SetCanEatRaw()

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat.panic_thresh = MANDRAKEMAN_PANIC_THRESH
    -- inst.components.combat.GetBattleCryString = GetBattleCryString
    -- inst.components.combat.GetGiveUpString = GetGiveUpString
    inst.components.combat:SetDefaultDamage(MANDRAKEMAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(MANDRAKEMAN_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)

    -- inst:AddComponent("named")
    -- inst.components.named.possiblenames = STRINGS.MANDRAKEMANNAMES
    -- inst.components.named:PickNewName()

    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true
    -- inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME


    inst:AddComponent("health")
    inst.components.health:StartRegen(MANDRAKEMAN_HEALTH_REGEN_AMOUNT, MANDRAKEMAN_HEALTH_REGEN_PERIOD)
    inst.components.health:SetMaxHealth(MANDRAKEMAN_HEALTH)
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"mandrake"})

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false
    inst.components.trader:Enable()

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetNocturnal(true)
    inst.WakeIfFarFromLeader = WakeIfFarFromLeader

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    local timer = inst:AddComponent("timer")
    timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_FRUITDRAGON_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("timerdone", OnChargedExpire)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwormwood_mandrakeman")

    MakeMediumFreezableCharacter(inst, "torso")
    MakeMediumBurnableCharacter(inst, "torso")
    -- MakePoisonableCharacter(inst, "torso")
    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("death", OnDeath)
	inst:ListenForEvent("onattackother", onattackother)

    inst:WatchWorldState("phase", OnPhaseChange)
    OnPhaseChange(inst)
    

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst.RemoveWormwoodPet = finish_transformed_life
    inst.no_spawn_fx = true
    inst.has_planarentity = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end


return Prefab("wormwood_mandrakeman", fn, assets, prefabs)
