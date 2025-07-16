local assets = {
    Asset("ANIM", "anim/wormwood_mushroombomb_gas.zip"),
    Asset("ANIM", "anim/wormwood_mushroombomb_base.zip"),
    Asset("ANIM", "anim/swap_wormwood_mushroombomb_gas.zip"),
    -- Asset("ANIM", "anim/sporecloud.zip"),
    -- Asset("ANIM", "anim/sporecloud_base.zip"),
    Asset("IMAGE", "images/inventoryimages/wormwood_mushroombomb_gas.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_mushroombomb_gas.xml"),
}

local AURA_EXCLUDE_TAGS = { "toadstool", "playerghost", "ghost", "shadow", "shadowminion", "noauradamage", "INLIMBO", "notarget", "noattack", "flight", "invisible" }

local FADE_FRAMES = 5
local FADE_INTENSITY = .8
local FADE_RADIUS = 1
local FADE_FALLOFF = .5

local sporecloud_time = 15
local wormwood_mushroombomb_gas_damage = 150

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetRadius(FADE_RADIUS * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeOut(inst)
    inst._fade:set(FADE_FRAMES + 1)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
end

local function FadeInImmediately(inst)
    inst._fade:set(FADE_FRAMES)
    OnFadeDirty(inst)
end

local function FadeOutImmediately(inst)
    inst._fade:set(FADE_FRAMES * 2 + 1)
    OnFadeDirty(inst)
end

local OVERLAY_COORDS =
{
    { 0,0,0,               1 },
    { 5/2,0,0,             0.8, 0 },
    { 2.5/2,0,-4.330/2,    0.8 , 5/3*180 },
    { -2.5/2,0,-4.330/2,   0.8, 4/3*180 },
    { -5/2,0,0,            0.8, 3/3*180 },
    { 2.5/2,0,4.330/2,     0.8, 1/3*180 },
    { -2.5/2,0,4.330/2,    0.8, 2/3*180 },
}

-- local FADE_INTENSITY = .8
-- local FADE_RADIUS = 1.5
-- local FADE_FALLOFF = .5

local function SpawnOverlayFX(inst, i, set, isnew)
    if i ~= nil then
        inst._overlaytasks[i] = nil
        if next(inst._overlaytasks) == nil then
            inst._overlaytasks = nil
        end
    end

    local fx = SpawnPrefab("wormwood_sporecloud_overlay")
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(set[1] * .85, 0, set[3] * .85)
    fx.Transform:SetScale(set[4], set[4], set[4])
    if set[5] ~= nil then
        fx.Transform:SetRotation(set[4])
    end

    if not isnew then
        fx.AnimState:PlayAnimation("sporecloud_overlay_loop")
        fx.AnimState:SetTime(math.random() * .7)
    end

    if inst._overlayfx == nil then
        inst._overlayfx = { fx }
    else
        table.insert(inst._overlayfx, fx)
    end
end

local SPOIL_CANT_TAGS = { "small_livestock" }
local SPOIL_ONEOF_TAGS = { "fresh", "stale", "spoiled" }
local function TryPerish(item)
    if item.prefab == "wormwood_mushroombomb_gas" then return end
    if item:IsInLimbo() then
        local owner = item.components.inventoryitem ~= nil and item.components.inventoryitem.owner or nil
        if owner == nil or 
            (   owner.components.container ~= nil and
                not owner.components.container:IsOpen() and
                owner:HasOneOfTags({ "structure", "portablestorage" })
            )
        then
            -- In limbo but not inventory or container?
            -- or in a closed chest/storage.
            return
        end
    end
    item.components.perishable:ReducePercent(TUNING.TOADSTOOL_SPORECLOUD_ROT)
end

local function OnHit(inst, attacker, target)
    inst.AnimState:PlayAnimation("land")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_land")
    
	-- 落地时淡入光源
    inst._fade:set(1)  -- 从第1帧开始淡入
    OnFadeDirty(inst)

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), function(inst)
        inst.AnimState:PlayAnimation("grow1")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_grow")
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), function(inst)
        	inst.AnimState:PlayAnimation("explode")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_explode")
            
            -- 爆炸时淡出光源
            FadeOut(inst)

			SpawnPrefab("wormwood_sporecloud").Transform:SetPosition(inst.Transform:GetWorldPosition())
			SpawnPrefab("wormwood_mushroombomb_explodefx").Transform:SetPosition(inst.Transform:GetWorldPosition())
			local x, y, z = inst.Transform:GetWorldPosition()
            local range = 4
            local initial_ents = TheSim:FindEntities(x, y, z, range, nil, { "player", "companion", "wall" })
            
            for _, ent in ipairs(initial_ents) do
                if ent:IsValid() and ent.components.health and not ent.components.health:IsDead()
					and not (ent.components.follower and ent.components.follower:GetLeader() 
					and ent.components.follower:GetLeader():HasTag("player")) then
                    ent.components.combat:GetAttacked(attacker, wormwood_mushroombomb_gas_damage, inst) 
                end
            end
            
            inst.task = inst:DoPeriodicTask(1, function()
                local x, y, z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, range, nil, nil)
                
                for _, ent in ipairs(ents) do
                    if ent:IsValid() 
                    and ent.components.health 
                    and not ent.components.health:IsDead() 
                    and not ent:HasTag("wall")
                    and ent.prefab ~= "wormwood_lightflier"
                    and not ent:HasTag("debuff_mushroombomb_gas") then  -- 新增检查
                        
                        ent:AddTag("debuff_mushroombomb_gas")  -- 标记实体
                        local damage = 25 + ent.components.health.maxhealth * 0.005
                        
                        ent.components.combat:GetAttacked(attacker, damage, inst)

                        -- 设置清除标记的延迟任务
                        ent:DoTaskInTime(0.95, function() 
                            if ent:IsValid() then
                                ent:RemoveTag("debuff_mushroombomb_gas")
                            end
                        end)
                    end
                end

                local ents = TheSim:FindEntities(x, y, z, range, nil, SPOIL_CANT_TAGS, SPOIL_ONEOF_TAGS)
                for i, v in ipairs(ents) do
                    TryPerish(v)
                end
            end)
            
            -- 持续时间结束后清除
            inst:DoTaskInTime(sporecloud_time, function() 
                if inst.task then 
                    inst.task:Cancel() 
                    inst.task = nil
                end
                inst:Remove() 
            end)
		end)
    end)
end

local function CreateBase(isnew)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("sporecloud_base")
    inst.AnimState:SetBuild("sporecloud_base")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    if isnew then
        inst.AnimState:PlayAnimation("sporecloud_base_pre")
        inst.AnimState:PushAnimation("sporecloud_base_idle", false)
    else
        inst.AnimState:PlayAnimation("sporecloud_base_idle")
    end

    return inst
end


local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wormwood_mushroombomb_gas", "swap_wormwood_mushroombomb_gas")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function CreateSpinCore()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("wormwood_mushroombomb_gas")
	inst.AnimState:SetBuild("wormwood_mushroombomb_gas")
	inst.AnimState:PlayAnimation("projectile_loop")
	-- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    

	return inst
end

local function onthrown(inst, attacker)
	inst:AddTag("NOCLICK")
	inst.persists = false

	inst.ispvp = attacker ~= nil and attacker:IsValid() and attacker:HasTag("player")

    -- 光源参数设置
    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetRadius(FADE_RADIUS)
    inst.Light:SetColour(200/255, 100/255, 170/255)  -- 紫色光（可调整颜色）
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	inst.AnimState:PlayAnimation("projectile_loop", true)

	inst.SoundEmitter:PlaySound("dontstarve/common/waterballoon_throw", "toss")

	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:SetCapsule(.2, .2)

end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Attack range is 8, leave room for error
	--Min range was chosen to not hit yourself (2 is the hit range)
	for r = 6.5, 3.5, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
    inst.entity:AddLight()

	inst.Transform:SetTwoFaced()

	MakeInventoryPhysics(inst)

	-- inst:AddTag("toughworker")
	-- inst:AddTag("explosive")

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")
	inst:AddTag("complexprojectile")

	inst.AnimState:SetBank("wormwood_mushroombomb_gas")
	inst.AnimState:SetBuild("wormwood_mushroombomb_gas")
	inst.AnimState:PlayAnimation("idle")


	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	MakeInventoryFloatable(inst, "small", 0.1, 0.8)

    -- 网络同步变量
    inst._fade = net_smallbyte(inst.GUID, "wormwood_mushroombomb._fade", "fadedirty")
    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)
		return inst
	end

	inst:AddComponent("locomotor")

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
	inst.components.complexprojectile:SetOnLaunch(onthrown)
	inst.components.complexprojectile:SetOnHit(OnHit)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(wormwood_mushroombomb_gas_damage)
	inst.components.weapon:SetRange(8, 10)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_mushroombomb_gas.xml" 
	inst:AddComponent("stackable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true
	
    -- inst:AddComponent("perishable")
    -- inst.components.perishable:SetPerishTime(TUNING.PERISH_MED) -- 设置耐久度
    -- inst.components.perishable:StartPerishing() -- 当物体生成的时候就开始腐烂
    -- inst.components.perishable:SetOnPerishFn(inst.Remove) -- 设置耐久度归零的回调函数
    -- inst:AddTag("show_spoilage")

	MakeHauntableLaunch(inst)

	return inst
end


local function OnStateDirty(inst)
    if inst._state:value() > 0 then
        if inst._inittask ~= nil then
            inst._inittask:Cancel()
            inst._inittask = nil
        end
        if inst._state:value() == 1 then
            if inst._basefx == nil then
                inst._basefx = CreateBase(false)
                inst._basefx.entity:SetParent(inst.entity)
            end
        elseif inst._basefx ~= nil then
            inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
        end
    end
end

local function OnAnimOver(inst)
    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(1)
end

local function OnOverlayAnimOver(fx)
    fx.AnimState:PlayAnimation("sporecloud_overlay_loop")
end

local function KillOverlayFX(fx)
    fx:RemoveEventCallback("animover", OnOverlayAnimOver)
    fx.AnimState:PlayAnimation("sporecloud_overlay_pst")
end

local function DisableCloud(inst)
    -- inst.components.aura:Enable(false)

    if inst._spoiltask ~= nil then
        inst._spoiltask:Cancel()
        inst._spoiltask = nil
    end

    inst:RemoveTag("sporecloud")
end

local function DoDisperse(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    DisableCloud(inst)

    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(2)
    FadeOut(inst)

    inst.AnimState:PlayAnimation("sporecloud_pst")
    inst.SoundEmitter:KillSound("spore_loop")
    inst.persists = false
    inst:DoTaskInTime(3, inst.Remove) --anim len + 1.5 sec

    if inst._basefx ~= nil then
        inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
    end

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:DoTaskInTime(i == 1 and 0 or math.random() * .5, KillOverlayFX)
        end
    end
end

local function OnTimerDone(inst, data)
    if data.name == "disperse" then
        DoDisperse(inst)
    end
end

local function FinishImmediately(inst)
    if inst.components.timer:TimerExists("disperse") then
        inst.components.timer:StopTimer("disperse")
        DoDisperse(inst)
    end
end


local function OnLoad(inst, data)
    --Not a brand new cloud, cancel initial sound and pre-anims
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    inst:RemoveEventCallback("animover", OnAnimOver)

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:Remove()
        end
        inst._overlayfx = nil
    end

    local t = inst.components.timer:GetTimeLeft("disperse")
    if t == nil or t <= 0 then
        DisableCloud(inst)
        inst._state:set(2)
        FadeOutImmediately(inst)
        inst.SoundEmitter:KillSound("spore_loop")
        inst:Hide()
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    else
        inst._state:set(1)
        FadeInImmediately(inst)
        inst.AnimState:PlayAnimation("sporecloud_loop", true)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst._basefx = CreateBase(false)
            inst._basefx.entity:SetParent(inst.entity)
        end

        for i, v in ipairs(OVERLAY_COORDS) do
            SpawnOverlayFX(inst, nil, v, false)
        end
    end
end


local function InitFX(inst)
    inst._inittask = nil

    if TheWorld.ismastersim then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post")
    end

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._basefx = CreateBase(true)
        inst._basefx.entity:SetParent(inst.entity)
    end
end


-- local SPOIL_CANT_TAGS = { "small_livestock" }
-- local SPOIL_ONEOF_TAGS = { "fresh", "stale", "spoiled" }
-- local function DoAreaSpoil(inst)
--     local x, y, z = inst.Transform:GetWorldPosition()
--     local ents = TheSim:FindEntities(x, y, z, inst.components.aura.radius, nil, SPOIL_CANT_TAGS, SPOIL_ONEOF_TAGS)
--     for i, v in ipairs(ents) do
--         TryPerish(v)
--     end
-- end


local function sporecloud_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:PlayAnimation("sporecloud_pre")
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetRadius(FADE_RADIUS)
    inst.Light:SetColour(125 / 255, 200 / 255, 50 / 255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst:AddTag("sporecloud")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")

    inst._state = net_tinybyte(inst.GUID, "sporecloud._state", "statedirty")
    inst._fade = net_smallbyte(inst.GUID, "sporecloud._fade", "fadedirty")

    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

    inst._inittask = inst:DoTaskInTime(0, InitFX)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("statedirty", OnStateDirty)
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst:AddComponent("combat")
    -- inst.components.combat:SetDefaultDamage(TUNING.TOADSTOOL_SPORECLOUD_DAMAGE)

    -- inst:AddComponent("aura")
    -- inst.components.aura.radius = TUNING.TOADSTOOL_SPORECLOUD_RADIUS
    -- inst.components.aura.tickperiod = TUNING.TOADSTOOL_SPORECLOUD_TICK
    -- inst.components.aura.auraexcludetags = AURA_EXCLUDE_TAGS
    -- inst.components.aura:Enable(true)

    -- inst._spoiltask = inst:DoPeriodicTask(inst.components.aura.tickperiod, DoAreaSpoil, inst.components.aura.tickperiod * .5)

    inst.AnimState:PushAnimation("sporecloud_loop", true)
    inst:ListenForEvent("animover", OnAnimOver)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disperse", sporecloud_time)

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnLoad = OnLoad

    inst.FadeInImmediately = FadeInImmediately
    inst.FinishImmediately = FinishImmediately

    inst._overlaytasks = {}
    for i, v in ipairs(OVERLAY_COORDS) do
        inst._overlaytasks[i] = inst:DoTaskInTime(i == 1 and 0 or math.random() * .7, SpawnOverlayFX, i, v, true)
    end

    return inst
end

local function overlayfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:SetLightOverride(.2)

    inst.AnimState:PlayAnimation("sporecloud_overlay_pre")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", OnOverlayAnimOver)

    inst.persists = false

    return inst
end


return Prefab("wormwood_mushroombomb_gas", fn, assets, prefabs),
		Prefab("wormwood_sporecloud", sporecloud_fn, assets, prefabs),
    	Prefab("wormwood_sporecloud_overlay", overlayfn, assets, prefabs)