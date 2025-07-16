local assets =
{
    Asset("ANIM", "anim/moontree_plant_fx.zip"),
}

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("ungrow_"..tostring(inst.variation)) then
        inst:Remove()
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        local moontree_healing = TheSim:FindEntities(x, y, z, 10, {"moontree_healing"})
        
        -- 检查是否存在符合条件的实体，或者随机50%概率
        if #moontree_healing > 0 or math.random() < 0.5 then  -- ✅ 修复语法
            inst.AnimState:PlayAnimation("idle_"..tostring(inst.variation))
            return
        end
        
        inst.AnimState:PlayAnimation("ungrow_"..tostring(inst.variation))
    end
end

local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        inst.variation = variation
        inst.AnimState:PlayAnimation("grow_"..tostring(variation))
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("moontree_plant_fx")

    inst.Transform:SetScale(1.5, 1.5, 1.5)
    inst.AnimState:SetBuild("moontree_plant_fx")
    inst.AnimState:SetBank("moontree_plant_fx")
    inst.AnimState:PlayAnimation("grow_1")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    -- inst.AnimState:SetMultColour(0.8, 0.9, 0.9, 0.8) 
    -- inst.AnimState:SetAddColour(0.3, 0.8, 0.8, 0.1) 

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.variation = 1
    inst.SetVariation = SetVariation

    inst:ListenForEvent("animover", OnAnimOver)
    inst.persists = false

    return inst
end

return Prefab("moontree_plant_fx", fn, assets)
