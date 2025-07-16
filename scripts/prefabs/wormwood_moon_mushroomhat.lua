local function MakeHat(name)
    local fns = {}
    local fname = "hat_"..name
    local symname = name.."hat"
    local prefabname = symname

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local swap_data = { bank = symname, anim = "anim" }

	-- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
	local function _base_onequip(inst, owner, symbol_override, swap_hat_override)
		local skin_build = inst:GetSkinBuild()
		if skin_build ~= nil then
			owner:PushEvent("equipskinneditem", inst:GetSkinName())
			owner.AnimState:OverrideItemSkinSymbol(swap_hat_override or "swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
		else
			owner.AnimState:OverrideSymbol(swap_hat_override or "swap_hat", fname, symbol_override or "swap_hat")
		end

		if inst.components.fueled ~= nil then
			inst.components.fueled:StartConsuming()
		end

		if inst.skin_equip_sound and owner.SoundEmitter then
			owner.SoundEmitter:PlaySound(inst.skin_equip_sound)
		end
	end

	-- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
    local function _onequip(inst, owner, symbol_override, headbase_hat_override)
		_base_onequip(inst, owner, symbol_override)

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides
        if headbase_hat_override ~= nil then
            local skin_build = owner.AnimState:GetSkinBuild()
            if skin_build ~= "" then
                owner.AnimState:OverrideSkinSymbol("headbase_hat", skin_build, headbase_hat_override )
            else 
                local build = owner.AnimState:GetBuild()
                owner.AnimState:OverrideSymbol("headbase_hat", build, headbase_hat_override)
            end
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Show("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end
    end

    local function _onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip
        if owner.components.skinner ~= nil then
            owner.components.skinner.base_change_cb = owner.old_base_change_cb
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
			owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    -- This is not really implemented, can just use _onequip
	fns.simple_onequip =  function(inst, owner, from_ground)
		_onequip(inst, owner)
	end

    -- This is not really implemented, can just use _onunequip
	fns.simple_onunequip = function(inst, owner, from_ground)
		_onunequip(inst, owner)
	end

    fns.opentop_onequip = function(inst, owner)
		_base_onequip(inst, owner)

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
		owner.AnimState:Hide("HEAD_HAT_NOHELM")
		owner.AnimState:Hide("HEAD_HAT_HELM")
    end

	fns.fullhelm_onequip = function(inst, owner)
		if owner:HasTag("player") then
			_base_onequip(inst, owner, nil, "headbase_hat")

			owner.AnimState:Hide("HAT")
			owner.AnimState:Hide("HAIR_HAT")
			owner.AnimState:Hide("HAIR_NOHAT")
			owner.AnimState:Hide("HAIR")

			owner.AnimState:Hide("HEAD")
			owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Show("HEAD_HAT_HELM")

			owner.AnimState:HideSymbol("face")
			owner.AnimState:HideSymbol("swap_face")
			owner.AnimState:HideSymbol("beard")
			owner.AnimState:HideSymbol("cheeks")

			owner.AnimState:UseHeadHatExchange(true)
		else
			_base_onequip(inst, owner)

			owner.AnimState:Show("HAT")
			owner.AnimState:Hide("HAIR_HAT")
			owner.AnimState:Hide("HAIR_NOHAT")
			owner.AnimState:Hide("HAIR")
		end
	end

	fns.fullhelm_onunequip = function(inst, owner)
		_onunequip(inst, owner)

		if owner:HasTag("player") then
			owner.AnimState:ShowSymbol("face")
			owner.AnimState:ShowSymbol("swap_face")
			owner.AnimState:ShowSymbol("beard")
			owner.AnimState:ShowSymbol("cheeks")

			owner.AnimState:UseHeadHatExchange(false)
		end
	end

    fns.simple_onequiptomodel = function(inst, owner, from_ground)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local _skinfns = { -- NOTES(JBK): These are useful for skins to have access to them instead of sometimes storing a reference to a hat.
        simple_onequip = fns.simple_onequip,
        simple_onunequip = fns.simple_onunequip,
        opentop_onequip = fns.opentop_onequip,
		fullhelm_onequip = fns.fullhelm_onequip,
		fullhelm_onunequip = fns.fullhelm_onunequip,
        simple_onequiptomodel = fns.simple_onequiptomodel,
    }

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

		inst:AddComponent("snowmandecor")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)
        inst.components.floater:SetBankSwapOnFloat(false, nil, swap_data) --Hats default animation is not "idle", so even though we don't swap banks, we need to specify the swap_data for re-skinning to reset properly when floating

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._skinfns = _skinfns

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "moon_mushroomhat"

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(fns.simple_onequip)
        inst.components.equippable:SetOnUnequip(fns.simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)

        MakeHauntableLaunch(inst)

        return inst
    end

    fns.mushroom_onattacked_moonspore_tryspawn = function(hat)
        local periodicspawner = hat.components.periodicspawner
        if periodicspawner == nil then
            hat._moonspore_tryspawn_count = nil
            return
        end

        periodicspawner:TrySpawn()

        hat._moonspore_tryspawn_count = hat._moonspore_tryspawn_count - 1
        if hat._moonspore_tryspawn_count <= 0 then
            hat._moonspore_tryspawn_count = nil
            return
        end

        hat:DoTaskInTime(TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_DELAY, fns.mushroom_onattacked_moonspore_tryspawn)
    end
    fns.mushroom_onattacked_moonspore = function(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil then
            if hat._moonspore_tryspawn_count == nil then
                hat:DoTaskInTime(TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_DELAY, fns.mushroom_onattacked_moonspore_tryspawn)
            end
            hat._moonspore_tryspawn_count = TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_COUNT
        end
    end
    fns.mushroom_spawnpoint_moonspore = function(inst)
        local pos = inst:GetPosition()
        local dist = GetRandomMinMax(0.1, 2.0)
    
        local offset = FindWalkableOffset(pos, math.random() * TWOPI, dist, 8)
    
        if offset ~= nil then
            return pos + offset
        end

        return pos
    end

    local function mushroom_onequip(inst, owner)
        _onequip(inst, owner)
        owner:AddTag("spoiler")
        if inst._ismoonspore then
            owner:AddTag("moon_spore_protection")
            inst:ListenForEvent("attacked", fns.mushroom_onattacked_moonspore, owner)
        end

        inst.components.periodicspawner:Start()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.MUSHROOMHAT_SLOW_HUNGER)
        end

    end

    local function mushroom_onunequip(inst, owner)
        _onunequip(inst, owner)
        owner:RemoveTag("spoiler")
        if inst._ismoonspore then
            owner:RemoveTag("moon_spore_protection")
            inst:RemoveEventCallback("attacked", fns.mushroom_onattacked_moonspore, owner)
        end
        inst.components.periodicspawner:Stop()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end

    fns.mushroom_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)

        owner:RemoveTag("spoiler")
        inst.components.periodicspawner:Stop()
        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end

    local function mushroom_displaynamefn(inst)
        return STRINGS.NAMES[string.upper(inst.prefab)]
    end

    local function mushroom_custom_init(inst)
        inst:AddTag("show_spoilage")

        --Use common inspect strings, but unique display names
        inst:SetPrefabNameOverride("mushroomhat")
        inst.displaynamefn = mushroom_displaynamefn

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.mushroom_onspawn_moonspore = function(inst, spore)
        spore._alwaysinstantpops = true
    end

    local function common_mushroom(spore_prefab)
        local ismoonspore = spore_prefab == "wormwood_spore_moon"
        local inst = simple(mushroom_custom_init)

        if ismoonspore then
            inst._ismoonspore = true
        end

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(mushroom_onequip)
        inst.components.equippable:SetOnUnequip(mushroom_onunequip)
        inst.components.equippable:SetOnEquipToModel(fns.mushroom_onequiptomodel)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        inst:AddComponent("periodicspawner")
        inst.components.periodicspawner:SetPrefab(spore_prefab)
        inst.components.periodicspawner:SetIgnoreFlotsamGenerator(true) -- NOTES(JBK): These spores float and self expire do not flotsam them.
        if ismoonspore then
            inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHROOMHAT_MOONSPORE_TIME, TUNING.MUSHROOMHAT_MOONSPORE_TIME_VARIANCE, true)
            inst.components.periodicspawner:SetOnSpawnFn(fns.mushroom_onspawn_moonspore)
            inst.components.periodicspawner:SetGetSpawnPointFn(fns.mushroom_spawnpoint_moonspore)
        else
            inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHROOMHAT_SPORE_TIME, 1, true)
        end

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    fns.red_mushroom = function()
        local inst = common_mushroom("spore_medium")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.95)

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    fns.green_mushroom = function()
        local inst = common_mushroom("spore_small")

        inst.scrapbook_specialinfo = "MUSHHAT"

        inst.components.floater:SetSize("med")

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    fns.blue_mushroom = function()
        local inst = common_mushroom("spore_tall")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.7)

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end
    
    fns.moon_mushroom = function()
        local inst = common_mushroom("wormwood_spore_moon")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.7)        

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    -----------------------------------------------------------------------------
    local fn = nil
    local assets = { Asset("ANIM", "anim/"..fname..".zip") }
    local prefabs = nil

    -- if name == "red_mushroom" then
    --     fn = fns.red_mushroom
    -- elseif name == "green_mushroom" then
    --     fn = fns.green_mushroom
    -- elseif name == "blue_mushroom" then
    --     fn = fns.blue_mushroom
    -- elseif name == "moon_mushroom" then
    --     fn = fns.moon_mushroom
    -- end

    fn = fns.moon_mushroom

    return Prefab("wormwood_" .. prefabname, fn or default, assets, prefabs)
end

return MakeHat("moon_mushroom")