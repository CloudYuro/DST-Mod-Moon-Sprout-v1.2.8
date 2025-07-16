local assets =
{
    Asset("ANIM", "anim/moon_tree_blossom_charged.zip"),
    Asset("IMAGE", "images/inventoryimages/wormwood_pet_controller.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_pet_controller.xml"),
}

local function OnPutInInventory(inst, pickupguy, src_pos)
    inst.components.perishable:StartPerishing()
    inst.Light:Enable(false)
end

local function ondropped(inst)
    inst.Light:Enable(true)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    MakeInventoryPhysics(inst) -- so it can be dropped as loot

    inst.AnimState:SetBank("moon_tree_blossom_charged")
    inst.AnimState:SetBuild("moon_tree_blossom_charged")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.pickupsound = "vegetation_grassy"

    inst:AddTag("cattoy")
    -- inst:AddTag("vasedecoration")
    
    inst.Light:SetColour(111/255, 111/255, 227/255)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(1)
    inst.Light:Enable(true)

    inst:ListenForEvent("onputininventory", OnPutInInventory)
    inst:ListenForEvent("ondropped", ondropped)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_pet_controller.xml"

    inst:AddComponent("tradable")
    -- inst:AddComponent("vasedecoration")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 3
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 15
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.MOONGLASS_CHARGED_PERISH_TIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("moon_tree_blossom_charged", fn, assets)
