require("prefabutil")

local assets_cork =
{
    Asset("ANIM", "anim/treasure_chest_cork.zip"),
    Asset("ANIM", "anim/treasure_chest_cork_upgraded_32_20.zip"),
}

local prefabs_cork =
{
    "collapse_small",
}

local assets_root =
{
    Asset("ANIM", "anim/treasure_chest_roottrunk.zip"),
}

local prefabs_root =
{
    "roottrunk_container",
    "collapse_small",
}

local function OnOpen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        if inst.prefab == "wormwood_corkchest" then
            inst.AnimState:PushAnimation("open_loop", true)
            inst.last_upgrade = inst.saltbox_upgrade
        end

        inst.SoundEmitter:PlaySound(inst.skin_open_sound or inst.open_sound or "dontstarve/wilson/chest_open")
    end
end

local function OnClose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)

        inst.SoundEmitter:PlaySound(inst.skin_close_sound or inst.close_sound or "dontstarve/wilson/chest_close")
    end
end

local function OnHammered(inst, worker)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    if inst.saltbox_upgrade then
        local saltrock = SpawnPrefab("saltrock")
        saltrock.components.stackable:SetStackSize(12)
        saltrock.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.components.lootdropper:FlingItem(saltrock)

        local bluegem = SpawnPrefab("bluegem")
        bluegem.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.components.lootdropper:FlingItem(bluegem)
    end

    inst:Remove()
end

local function OnHit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
    end
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)

    inst.SoundEmitter:PlaySound(inst.skin_place_sound or inst.place_sound or "dontstarve/common/chest_craft")
end

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
    if inst.prefab == "wormwood_corkchest" then
        if not inst.saltbox_upgrade then
            inst.saltbox_upgrade = false
        end
        data.saltbox_upgrade = inst.saltbox_upgrade
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
    if inst.prefab == "wormwood_corkchest" then
        if not inst.saltbox_upgrade then
            inst.saltbox_upgrade = false
        end
        inst.saltbox_upgrade = data.saltbox_upgrade
        if inst.saltbox_upgrade then
            inst.components.preserver:SetPerishRateMultiplier(.25)
            inst.AnimState:SetBank("treasure_chest_cork_upgraded_32_20")
            inst.AnimState:SetBuild("treasure_chest_cork_upgraded_32_20")
        end
    end
end

local function cork_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- inst.MiniMapEntity:SetIcon(name ..".tex")

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("pogproof")

    inst.AnimState:SetBank("treasure_chest_cork")
    inst.AnimState:SetBuild("treasure_chest_cork")
    inst.AnimState:PlayAnimation("closed")

    -- inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("wormwood_corkchest")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.open_sound = "dontstarve_DLC003/common/crafted/cork_chest/open"
    inst.close_sound = "dontstarve_DLC003/common/crafted/cork_chest/close"
    inst.place_sound = "dontstarve_DLC003/common/crafted/cork_chest/place"

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(1)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", OnBuilt)

    inst.saltbox_upgrade = false
    -- Save / load is extended by some prefab variants
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end


--[[ Root Trunk ]]--

-- local function AttachRootContainer(inst)
--     inst.components.container_proxy:SetMaster(TheWorld:GetPocketDimensionContainer("root"))
-- end

local function roottrunk_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- inst.MiniMapEntity:SetIcon("root_chest_child.tex")

    inst:AddTag("structure")
    -- inst:AddTag("chest")

    inst.AnimState:SetBank("roottrunk")
    inst.AnimState:SetBuild("treasure_chest_roottrunk")
    inst.AnimState:PlayAnimation("closed")

    -- inst:AddComponent("container_proxy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    -- inst.components.container_proxy:SetOnOpenFn(OnOpen)
    -- inst.components.container_proxy:SetOnCloseFn(OnClose)

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", OnBuilt)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("wormwood_roottrunk")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.canbeopened = true

    inst.open_sound = "dontstarve_DLC003/common/crafted/root_trunk/open"
    inst.close_sound = "dontstarve_DLC003/common/crafted/root_trunk/open"
    inst.place_sound = "dontstarve_DLC003/common/crafted/root_trunk/place"

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    -- inst.OnLoadPostPass = AttachRootContainer

    -- if not POPULATING then
    --     AttachRootContainer(inst)
    -- end

    return inst
end

return Prefab("wormwood_corkchest", cork_fn, assets_cork, prefabs_cork),
       Prefab("wormwood_roottrunk", roottrunk_fn, assets_root, prefabs_root),
       MakePlacer("wormwood_corkchest_placer", "chest", "treasure_chest_cork", "closed"),
       MakePlacer("wormwood_roottrunk_placer", "roottrunk", "treasure_chest_roottrunk", "closed")
