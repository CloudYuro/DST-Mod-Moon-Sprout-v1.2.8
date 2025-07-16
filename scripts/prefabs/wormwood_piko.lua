local assets = {
    Asset("ANIM", "anim/ds_squirrel_basic.zip"),
    Asset("ANIM", "anim/squirrel_cheeks_build.zip"),
    Asset("ANIM", "anim/squirrel_build.zip"),
    Asset("ANIM", "anim/orange_squirrel_cheeks_build.zip"),
    Asset("ANIM", "anim/orange_squirrel_build.zip"),
}

local SGwormwood_piko = require("stategraphs/SGwormwood_piko")

local PIKO_HEALTH = 100
local PIKO_RESPAWN_TIME = 480 * 4
local PIKO_RUN_SPEED = 4
local PIKO_DAMAGE = 2
local PIKO_ATTACK_PERIOD = 2
local PIKO_TARGET_DIST = 20
local PIKO_ENABLED = true
local brain = require("brains/wormwood_pikobrain")

local INTENSITY = .5


local function Retarget(inst)
    return FindEntity(inst, PIKO_TARGET_DIST, function(guy)
        return not guy:HasTag("piko") and inst.components.combat:CanTarget(guy) and guy.components.inventory and (guy.components.inventory:NumItems() > 0)
    end)
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and inst.is_rabid
end

-- region animation
local function UpdateBuild(inst, cheeks)
    local build = "squirrel_build"
    if cheeks then
        build = "squirrel_cheeks_build"
    end
    if inst:HasTag("orange") then
        build = "orange_" .. build
    end
    inst.AnimState:SetBuild(build)
end

local function RefreshBuild(inst)
    UpdateBuild(inst, inst.components.inventory:NumItems() > 0)
end

local function FadeIn(inst)
    inst.components.fader:StopAll()
    inst.AnimState:Show("eye_red")
    inst.AnimState:Show("eye2_red")
    inst.Light:Enable(true)
    if inst:IsAsleep() then
        inst.Light:SetIntensity(INTENSITY)
    else
        inst.Light:SetIntensity(0)
        inst.components.fader:Fade(0, INTENSITY, 3 + math.random() * 2, function(v) inst.Light:SetIntensity(v) end)
    end
end

local function FadeOut(inst)
    inst.components.fader:StopAll()
    inst.AnimState:Hide("eye_red")
    inst.AnimState:Hide("eye2_red")
    if inst:IsAsleep() then
        inst.Light:SetIntensity(0)
    else
        inst.components.fader:Fade(INTENSITY, 0, 0.75 + math.random(), function(v) inst.Light:SetIntensity(v) end)
    end
end

local function UpdateLight(inst)
    -- 移除了与家相关的判断
    local outside = not inst.components.inventoryitem.owner

    if inst.is_rabid and outside then
        if not inst.lighton then
            inst:DoTaskInTime(math.random() * 2, FadeIn)
        else
            inst.Light:Enable(true)
            inst.Light:SetIntensity(INTENSITY)
        end
        inst.lighton = true
        inst.AnimState:Show("eye_red")
        inst.AnimState:Show("eye2_red")
    else
        if inst.lighton then
            inst:DoTaskInTime(math.random() * 2, FadeOut)
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end
        inst.AnimState:Hide("eye_red")
        inst.AnimState:Hide("eye2_red")
        inst.lighton = false
    end
end

local function SetAsRabid(inst, rabid)
    inst.is_rabid = rabid
    inst.components.sleeper:SetNocturnal(rabid)
    UpdateLight(inst)
end
-- endregion

-- region event handlers
local MUST_TAGS = {"piko"}


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

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    -- 掉落容器中的所有物品
    if inst.components.inventory then
        inst.components.inventory:DropEverything(true)
    end

    
    local drop = "pinecone"
    local loot = nil
    if inst.prefab == "wormwood_piko_orange" then
        loot = SpawnPrefab("acorn")
    else
        loot = SpawnPrefab("pinecone")
    end

    loot.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(loot)
    
    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetPosition(ix, iy, iz)
    inst:Remove()
end

local function OnDeath(inst)
    inst.Light:Enable(false)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    -- 掉落容器中的所有物品
    if inst.components.inventory then
        inst.components.inventory:DropEverything(true)
    end

    local drop = "pinecone"
    local loot = nil
    if inst.prefab == "wormwood_piko_orange" then
        loot = SpawnPrefab("acorn")
    else
        loot = SpawnPrefab("pinecone")
    end

    loot.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(loot)
    
    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
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

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, MUST_TAGS)
    local max_friend_num = 5
    for i = 1, max_friend_num do
        if not ents[i] then
            break
        end
        ents[i]:PushEvent("gohome")
    end
end

local function OnCooked(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/piko/scream")
end


local function OnDropped(inst)
    RefreshBuild(inst)
    UpdateLight(inst)
    inst.sg:GoToState("stunned")
end

local function OnPickupedorTrapped(inst)
    inst.components.inventory:DropEverything(false, false)
end

local function OnPickup(inst)
    UpdateBuild(inst, true)
end

local function OnEat(inst, data)
    -- 每次喂食延长生命周期
    local food = data.food
    local timer = inst.components.timer
    if timer then
        if timer:TimerExists("finish_transformed_life") then
            timer:SetTimeLeft("finish_transformed_life", timer:GetTimeLeft("finish_transformed_life") + food.components.edible.hungervalue / 25 * 480)
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
        inst.components.planardamage:SetBaseDamage(5)
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

local function OnTimerDone(inst, data)
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
end

local function OnPhaseChange(inst)
    if TheWorld.state.phase == "night" and (TheWorld.state.moonphase == "full" or TheWorld.state.moonphase == "blood") then
        if not inst.is_rabid then
            inst:DoTaskInTime(1 + math.random(), SetAsRabid, true)
        end
    else
        if inst.is_rabid then
            inst:DoTaskInTime(1 + math.random(), SetAsRabid, false)
        end
    end
end
-- endregion

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
    RefreshBuild(inst)
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
        inst.components.planardamage:SetBaseDamage(5)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank("squirrel")
    inst.AnimState:SetBuild("squirrel_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.DynamicShadow:SetSize(1, 0.75)

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetColour(150/255, 40/255, 40/255)
    inst.Light:SetFalloff(0.9)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)

    MakeCharacterPhysics(inst, 1, 0.12)

    inst:AddTag("animal")
    -- inst:AddTag("canbetrapped")
    inst:AddTag("cannotstealequipped")
    inst:AddTag("catfood")
    inst:AddTag("cattoy")
    inst:AddTag("piko")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("wormwood_pet")
    inst:AddTag("lunar_aligned")

    -- inst.Transform:SetScale(1.1, 1.1, 1.1)

    MakeFeedableSmallLivestockPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.is_rabid = false
    inst:AddComponent("thief")
    inst:AddComponent("fader")

    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = 5

    inst:AddComponent("knownlocations")
    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    
    inst.WakeIfFarFromLeader = WakeIfFarFromLeader
    inst:WakeIfFarFromLeader()

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.CARRAT.RUN_SPEED

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.SEEDS, FOODTYPE.VEGGIE}, {FOODTYPE.SEEDS, FOODTYPE.VEGGIE})

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupedorTrapped)
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.pushlandedevents = false
    inst.components.inventoryitem.grabbableoverridetag = "wormwood_pets_piko_pickup"
    inst.components.inventoryitem.imagename = "wormwood_piko"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_piko.xml" 

    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedsmallmeat"
    inst.components.cookable:SetOnCookedFn(OnCooked)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(PIKO_DAMAGE)
    inst.components.combat:SetAttackPeriod(PIKO_ATTACK_PERIOD)
    inst.components.combat:SetRange(0.7)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat.hiteffectsymbol = "chest"
    inst.components.combat.onhitotherfn = function(inst, other) inst.components.thief:StealItem(other) end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(PIKO_HEALTH)
    inst.components.health.murdersound = "dontstarve_DLC003/creatures/piko/death"
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("drownable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.droprecipeloot = false  -- 禁止配方掉落
    inst.components.lootdropper:SetLoot({"pinecone"})
    
    local timer = inst:AddComponent("timer")
    timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_CARRAT_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("timerdone", OnChargedExpire)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwormwood_piko")

    inst:WatchWorldState("phase", OnPhaseChange)
    inst:WatchWorldState("moonphase", OnPhaseChange)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("ondropped", UpdateLight)
    inst:ListenForEvent("trapped", OnPickupedorTrapped)
    inst:ListenForEvent("onpickupitem", OnPickup)
    inst:ListenForEvent("oneat", OnEat)

    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.pickup_blocked = false    -- 是否阻止拾取动作
    inst.no_spawn_fx = true
    inst.has_planarentity = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.UpdateLight = UpdateLight
    inst.RemoveWormwoodPet = finish_transformed_life

    MakeSmallBurnableCharacter(inst, "torso")
    MakeTinyFreezableCharacter(inst, "torso")
    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME * 4, nil, OnDropped)
    MakeHauntablePanic(inst)

    SetAsRabid(inst, false)
    OnPhaseChange(inst)
    

    return inst
end

local function orangefn()
    local inst = fn()
    inst:AddTag("orange")
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.inventoryitem.imagename = "wormwood_piko_orange"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_piko_orange.xml" 
    inst.components.lootdropper:SetLoot({"acorn"})
    UpdateBuild(inst)
    return inst
end

return Prefab("wormwood_piko", fn, assets, prefabs),
       Prefab("wormwood_piko_orange", orangefn, assets, prefabs)