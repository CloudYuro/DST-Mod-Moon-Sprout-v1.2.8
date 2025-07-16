local assets = {
    Asset("ANIM", "anim/wormwood_mushroombomb.zip"),
    Asset("ANIM", "anim/wormwood_mushroombomb_base.zip"),
    Asset("ANIM", "anim/swap_wormwood_mushroombomb.zip"),
    Asset("IMAGE", "images/inventoryimages/wormwood_mushroombomb.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_mushroombomb.xml"),
}


local prefabs =
{
	"wormwood_mushroombomb_explodefx"
}

-- local FADE_INTENSITY = .8
-- local FADE_RADIUS = 1.5
-- local FADE_FALLOFF = .5

local FADE_FRAMES = 5        -- 淡入淡出的帧数
local FADE_INTENSITY = 0.8   -- 光源强度
local FADE_RADIUS = 1.5      -- 光源半径
local FADE_FALLOFF = 0.5     -- 光源衰减

-- 光源更新函数
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

-- 网络同步函数
local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

-- 淡出函数
local function FadeOut(inst)
    inst._fade:set(FADE_FRAMES + 1)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
end

local wormwood_mushroombomb_damage = 100

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

			SpawnPrefab("wormwood_mushroombomb_explodefx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), inst.Remove)
            local x, y, z = inst.Transform:GetWorldPosition()
            local range = 4 -- 爆炸范围
            local ents = TheSim:FindEntities(x, y, z, range, nil, { "player", "companion", "wall" }) -- 排除玩家和同伴

            for _, ent in ipairs(ents) do
                if ent ~= inst and ent:IsValid() and ent.components.health and not ent.components.health:IsDead() and 
                    not (ent.components.follower and ent.components.follower:GetLeader() 
					and ent.components.follower:GetLeader():HasTag("player"))  then
                    ent.components.combat:GetAttacked(attacker, wormwood_mushroombomb_damage, inst)
                end
            end
        end)
    end)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wormwood_mushroombomb", "swap_wormwood_mushroombomb")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onperish(inst)
    if not TheWorld.ismastersim then
        return -- 仅在主机端执行
    end

    local owner = inst.components.inventoryitem:GetGrandOwner()
    local stacksize = inst.components.stackable:StackSize() -- 获取堆叠数量


    -- 生成对应数量的毒气炸弹
    if owner ~= nil and owner.components.inventory then
        -- 在玩家/容器中 → 放入物品栏（自动堆叠）
        for i = 1, stacksize do
            local gas = SpawnPrefab("wormwood_mushroombomb_gas")
            owner.components.inventory:GiveItem(gas)
        end
    else
        -- 在地面 → 生成一个堆叠组
        local gas = SpawnPrefab("wormwood_mushroombomb_gas")
        gas.components.stackable:SetStackSize(stacksize) -- 设置堆叠数量
        gas.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
	
    -- 移除原炸弹（整个堆叠）
    inst:Remove()
end

-- local function CreateSpinCore()
-- 	local inst = CreateEntity()

-- 	inst:AddTag("FX")
-- 	--[[Non-networked entity]]
-- 	if not TheWorld.ismastersim then
-- 		inst.entity:SetCanSleep(false)
-- 	end
-- 	inst.persists = false

-- 	inst.entity:AddTransform()
-- 	inst.entity:AddAnimState()
-- 	inst.entity:AddFollower()

-- 	inst.AnimState:SetBank("wormwood_mushroombomb")
-- 	inst.AnimState:SetBuild("wormwood_mushroombomb")
-- 	inst.AnimState:PlayAnimation("projectile_loop")
-- 	-- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    

-- 	return inst
-- end

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
	
	inst.AnimState:SetBank("mushroombomb") -- 使用原始的蘑菇炸弹动画，不知道为什么，我的动画文件在经过自动编译后，烟雾贴图会跑偏
	inst.AnimState:SetBuild("mushroombomb")  
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

	inst.AnimState:SetBank("wormwood_mushroombomb")
	inst.AnimState:SetBuild("wormwood_mushroombomb")
	inst.AnimState:PlayAnimation("idle")

    -- 网络同步变量
    inst._fade = net_smallbyte(inst.GUID, "wormwood_mushroombomb._fade", "fadedirty")
    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	MakeInventoryFloatable(inst, "small", 0.1, 0.8)


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
	inst.components.weapon:SetDamage(wormwood_mushroombomb_damage)
	inst.components.weapon:SetRange(8, 10)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_mushroombomb.xml" 
	inst:AddComponent("stackable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST) -- 设置耐久度
    inst.components.perishable:StartPerishing() -- 当物体生成的时候就开始腐烂
    inst.components.perishable:SetOnPerishFn(onperish) -- 设置耐久度归零的回调函数
    inst:AddTag("show_spoilage")

	MakeHauntableLaunch(inst)

	return inst
end


local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	inst.Transform:SetTwoFaced()

    inst:AddTag("FX")


    inst.AnimState:SetBank("wormwood_mushroombomb_base")
    inst.AnimState:SetBuild("wormwood_mushroombomb_base")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("wormwood_mushroombomb", fn, assets, prefabs),
	   Prefab("wormwood_mushroombomb_explodefx", fxfn, assets, prefabs)