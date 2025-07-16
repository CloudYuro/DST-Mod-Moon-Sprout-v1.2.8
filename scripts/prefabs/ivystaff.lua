local assets =
{
    Asset("ANIM", "anim/ivystaff.zip"),
    Asset("ANIM", "anim/swap_ivystaff.zip"),
    Asset("IMAGE", "images/inventoryimages/ivystaff.tex"),
    Asset("ATLAS", "images/inventoryimages/ivystaff.xml"),
}

local function onperish(inst)
    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetScale(1.5, 1.5, 1.5)
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end


local function OnThrown(inst, attacker)
	inst:AddTag("NOCLICK")
	inst.persists = true

	inst.ispvp = attacker ~= nil and attacker:IsValid() and attacker:HasTag("player")
	inst.components.inventoryitem.canbepickedup = false

	-- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:PlayAnimation("projectile_loop", true)

	inst.SoundEmitter:PlaySound("dontstarve/common/waterballoon_throw", "toss")
	inst.SoundEmitter:PlaySound("wilson_rework/torch/torch_spin", "spin_loop")

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

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ivystaff")
    inst.AnimState:SetBuild("ivystaff")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("ivystaff")

    local floater_swap_data =
    {
        sym_build = "swap_ivystaff",
        sym_name = "swap_ivystaff",
        bank = "ivystaff",
        anim = "ivystaff"
    }

    MakeInventoryFloatable(inst, "med", 0.1, {0.9, 0.4, 0.9}, true, -13, floater_swap_data)
    inst.components.floater:SetBankSwapOnFloat(true, -9.5, floater_swap_data)
    inst.components.floater:SetScale({0.85, 0.4, 0.85})

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true
    inst.components.reticule.ispassableatallpoints = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2, 0))
    inst.components.complexprojectile:SetOnLaunch(OnThrown)
	inst.components.complexprojectile.ismeleeweapon = true
    -- 为实现荆棘魔杖可配置，onhit 函数已转移至 skill_thorn.lua 中实现

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED) 
    inst.components.perishable:StartPerishing() 
    inst.components.perishable:SetOnPerishFn(onperish) 
    inst:AddTag("show_spoilage") 

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ivystaff.xml" 

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable.walkspeedmult = 1.10
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_ivystaff", "swap_ivystaff")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        if owner:HasTag("wormwood_thorn_ivystaff") then
            if owner.components.bloomness.level == 3 then
                inst.components.equippable.walkspeedmult = 1.25
            elseif owner.components.bloomness.level == 2 then
                inst.components.equippable.walkspeedmult = 1.15
            elseif owner.components.bloomness.level == 1 then
                inst.components.equippable.walkspeedmult = 1.12
            else
                inst.components.equippable.walkspeedmult = 1.10
            end
        end
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        inst.components.equippable.walkspeedmult = 1.10
    end)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("ivystaff", fn, assets)