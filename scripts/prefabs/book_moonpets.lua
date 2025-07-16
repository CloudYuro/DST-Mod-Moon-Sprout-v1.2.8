local assets =
{
    Asset("ANIM", "anim/book_moonpets.zip"),
	Asset("ATLAS", "images/spell_icons_switch_pickable.xml"),
	Asset("IMAGE", "images/spell_icons_switch_pickable.tex"),
	Asset("ATLAS", "images/spell_icons_switch_follow.xml"),
	Asset("IMAGE", "images/spell_icons_switch_follow.tex"),
	Asset("ATLAS", "images/spell_icons_switch_aggressive.xml"),
	Asset("IMAGE", "images/spell_icons_switch_aggressive.tex"),
	Asset("ATLAS", "images/spell_icons_switch_defensive.xml"),
	Asset("IMAGE", "images/spell_icons_switch_defensive.tex"),
	Asset("ATLAS", "images/spell_icons_switch_passive.xml"),
	Asset("IMAGE", "images/spell_icons_switch_passive.tex"),
	Asset("ATLAS", "images/spell_icons_switch_moving_combat.xml"),
	Asset("IMAGE", "images/spell_icons_switch_moving_combat.tex"),
	
	-- Asset("ATLAS", "images/spell_icons_switch_aggressive_ON.xml"),
	-- Asset("IMAGE", "images/spell_icons_switch_aggressive_ON.tex"),
	-- Asset("ATLAS", "images/spell_icons_switch_defensive_ON.xml"),
	-- Asset("IMAGE", "images/spell_icons_switch_defensive_ON.tex"),
	-- Asset("ATLAS", "images/spell_icons_switch_passive_ON.xml"),
	-- Asset("IMAGE", "images/spell_icons_switch_passive_ON.tex"),
	-- Asset("ATLAS", "images/spell_icons_switch_moving_combat_ON.xml"),
	-- Asset("IMAGE", "images/spell_icons_switch_moving_combat_ON.tex"),
	-- Asset("ATLAS", "images/spell_icons_powerup.xml"),
	-- Asset("IMAGE", "images/spell_icons_powerup.tex"),
}

local function ReticuleTargetAllowWaterFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Cast range is 30, leave room for error
	--15 is the aoe range
	for r = 10, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function SayRandomString(inst, key_prefix)
    local strings = STRINGS.BOOK_MOONPETS
    local candidates = {}

    -- 收集所有以 key_prefix 开头的字符串
    for k, v in pairs(strings) do
        if string.find(k, key_prefix .. "_") == 1 then
            table.insert(candidates, v)
        end
    end

    -- 随机选择一个
    if #candidates > 0 then
        local sentence = candidates[math.random(#candidates)]
		inst:DoTaskInTime(FRAMES, function(inst)
        	inst.components.talker:Say(sentence)
		end)
    end
end

local function SwitchPickableFn(inst, doer)
    if doer.pets_pickable == true then
        doer.pets_pickable = false
        doer:RemoveTag("wormwood_pets_carrat_pickup")
        doer:RemoveTag("wormwood_pets_piko_pickup")
        doer:RemoveTag("wormwood_pets_fruitdragon_pickup")
		-- 不知道为什么沃姆伍德读书后一定要说一个“不”......先用这个宣告覆盖这个“不”吧
		SayRandomString(doer, "announce_unenable_pickable")
    else
        doer.pets_pickable = true
        doer:AddTag("wormwood_pets_carrat_pickup")
        doer:AddTag("wormwood_pets_piko_pickup")
        doer:AddTag("wormwood_pets_fruitdragon_pickup")
		SayRandomString(doer, "announce_enable_pickable")
    end
    doer.components.talker:Say("Hello!")
end

local function SwitchStandstillFn(inst, doer)
    if doer.pets_standstill == true then
        doer.pets_standstill = false
		SayRandomString(doer, "announce_follow")
    else
        doer.pets_standstill = true
		SayRandomString(doer, "announce_standstill")
    end
end

local ALLY_TAGS = {
    "player",
    "wormwood_pet",
    "wormwood_lunarplant",
    "wormwood_gestalt_guard",
    "wormwood_lunar_grazer",
    "wormwood_deciduous",
	"companion",
}

local CHECK_DIST = 25
local RETARGET_DIST = 15
local RETARGET_TAGS = { "_health" }
local RETARGET_NO_TAGS = {"FX", "NOCLICK", "INLIMBO", "wall", "structure", "aquatic", "notarget"}

local function Aggressive_RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end
    
    return FindEntity(inst, CHECK_DIST, function(guy)
         -- 确保ent有效
        if not guy or not guy:IsValid() then
            return false
        end

		-- 排除月蛾
		if guy.prefab == "moonbutterfly" then 
			return false
		end

        -- 检查是否是玩家的追随者
        if guy.components.follower and guy.components.follower:GetLeader() 
           and guy.components.follower:GetLeader():HasTag("player") then
            return false
        end
          
        -- 修正为检查玩家附近的实体
		if guy:IsNear(inst.components.follower.leader, RETARGET_DIST) then
        	return inst.components.combat:CanTarget(guy)
		end
    end, RETARGET_TAGS, ConcatArrays(ALLY_TAGS, RETARGET_NO_TAGS))
end

local function Defensive_RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    return inst.components.combat.target
end

local function SwitchAggressiveFn(inst, doer)
	local pets_battle = doer.components.leader:GetFollowersByTag("wormwood_pet_battle")
	if doer.pets_atk_mode ~= "aggressive" then
		doer.pets_atk_mode = "aggressive"
		inst.book_atk_mode = doer.pets_atk_mode
	end
	for _, pet in ipairs(pets_battle) do
		if pet ~= nil then
			pet.components.combat:SetRetargetFunction(1, Aggressive_RetargetFn)
		end
	end
	SayRandomString(doer, "announce_aggressive")
end

local function SwitchDefensiveFn(inst, doer)
	local pets_battle = doer.components.leader:GetFollowersByTag("wormwood_pet_battle")
	if doer.pets_atk_mode ~= "defensive" then
		doer.pets_atk_mode = "defensive"
		inst.book_atk_mode = doer.pets_atk_mode
	end
	for _, pet in ipairs(pets_battle) do
		if pet ~= nil then
			pet.components.combat:SetRetargetFunction(1, Defensive_RetargetFn)
		end
	end
	SayRandomString(doer, "announce_defensive")
end

local function SwitchPassiveFn(inst, doer)
	local pets_battle = doer.components.leader:GetFollowersByTag("wormwood_pet_battle")
	if doer.pets_atk_mode ~= "passive"  then
		doer.pets_atk_mode = "passive"
		inst.book_atk_mode = doer.pets_atk_mode
		for _, pet in ipairs(pets_battle) do
			if pet ~= nil then
    			pet.components.combat:SetRetargetFunction(1, Defensive_RetargetFn)
			end
		end
	end
	SayRandomString(doer, "announce_passive")
end

local function SwitchMovingCombatFn(inst, doer)
	if doer.pets_moving_combat ~= true then
		doer.pets_moving_combat = true
		inst.book_moving_combat = doer.pets_moving_combat
		SayRandomString(doer, "announce_moving_combat")
	else
		doer.pets_moving_combat = false
		inst.book_moving_combat = doer.pets_moving_combat
		SayRandomString(doer, "announce_sticking_combat")
	end
end

local function SwitchMandrakeSoundFn(inst, doer)
	if doer.pets_mandrake_sound ~= true then
		doer.pets_mandrake_sound = true
		inst.book_mandrake_sound = doer.pets_mandrake_sound
		SayRandomString(doer, "announce_mandrake_sound_on")
	else
		doer.pets_mandrake_sound = false
		inst.book_mandrake_sound = doer.pets_mandrake_sound
		SayRandomString(doer, "announce_mandrake_sound_off")
	end
end

-- 攻速提升 25%，受伤减少 25%
local powerup_atk_period = 1.6
local powerup_damage_mult = 1.25
local powerup_absorb_mult = 0.25
local powerup_timer = 60

local function PowerupFn(inst, doer)
	local pets_battle = doer.components.leader:GetFollowersByTag("wormwood_pet_battle")
	for _, pet in ipairs(pets_battle) do
		if pet ~= nil then
			pet.original_atk_period = pet.original_atk_period or 2
    		pet.components.combat:SetAttackPeriod(powerup_atk_period)
			-- pet.components.combat.externaldamagemultipliers:SetModifier(pet, powerup_damage_mult, "book_moonpets_powerup")
			pet.components.health.externalabsorbmodifiers:SetModifier("book_moonpets_powerup", powerup_absorb_mult)
			if pet.components.timer:TimerExists("book_moonpets_powerup") then
				pet.components.timer:SetTimeLeft("book_moonpets_powerup", powerup_timer)
			else
				pet.components.timer:StartTimer("book_moonpets_powerup", powerup_timer)
			end
			pet:ListenForEvent("timerdone", function(pet, data)
				if data.name == "book_moonpets_powerup" then
					local original_atk_period = pet.original_atk_period or 2
					pet.original_atk_period = nil
					pet.components.combat:SetAttackPeriod(original_atk_period)
					-- pet.components.combat.externaldamagemultipliers:RemoveModifier("book_moonpets_powerup")
					pet.components.health.externalabsorbmodifiers:RemoveModifier("book_moonpets_powerup")
				end
			end)
		end
	end
	SayRandomString(doer, "announce_powerup")
end

local SPELL_ORDER = {
	"switch_defensive",
	"switch_aggressive",
	"switch_standstill",
	"switch_moving_combat",
	"switch_pickable",
	-- "powerup",
	-- "switch_mandrake_sound",
	"switch_passive",
}

local ICON_SCALE = .6
local ICON_RADIUS = 50
local SPELLBOOK_RADIUS = 100

local SPELL_DEFS =
{
	["switch_pickable"] = 
	{
		label = STRINGS.BOOK_MOONPETS.switch_pickable,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_pickable)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchPickableFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_pickable.xml",
		normal = "spell_icons_switch_pickable.tex",
		widget_scale = ICON_SCALE,
	},

	["switch_standstill"] =
	{
		label = STRINGS.BOOK_MOONPETS.switch_standstill,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_standstill)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchStandstillFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_follow.xml",
		normal = "spell_icons_switch_follow.tex",
		widget_scale = ICON_SCALE,
	},

	["switch_aggressive"] =
	{
		label = STRINGS.BOOK_MOONPETS.switch_aggressive,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_aggressive)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchAggressiveFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_aggressive.xml",
		normal = "spell_icons_switch_aggressive.tex",
		widget_scale = ICON_SCALE,
	},

	["switch_defensive"] = 
	{
		label = STRINGS.BOOK_MOONPETS.switch_defensive,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_defensive)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchDefensiveFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_defensive.xml",
		normal = "spell_icons_switch_defensive.tex",
		widget_scale = ICON_SCALE,
	},

	["switch_passive"] = 
	{
		label = STRINGS.BOOK_MOONPETS.switch_passive,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_passive)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchPassiveFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_passive.xml",
		normal = "spell_icons_switch_passive.tex",
		widget_scale = ICON_SCALE,
	},
	
	["switch_moving_combat"] = 
	{
		label = STRINGS.BOOK_MOONPETS.switch_moving_combat,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_moving_combat)
			inst.components.spellbook:SetSpellAction(nil)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(SwitchMovingCombatFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
        end,
		atlas = "images/spell_icons_switch_moving_combat.xml",
		normal = "spell_icons_switch_moving_combat.tex",
		widget_scale = ICON_SCALE,
	},

	-- ["switch_mandrake_sound"] = 
	-- {
	-- 	label = STRINGS.BOOK_MOONPETS.switch_mandrake_sound,
	-- 	onselect = function(inst)
	-- 		inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.switch_mandrake_sound)
	-- 		inst.components.spellbook:SetSpellAction(nil)
	-- 		if TheWorld.ismastersim then
	-- 			inst.components.aoespell:SetSpellFn(nil)
	-- 			inst.components.spellbook:SetSpellFn(SwitchMandrakeSoundFn)
	-- 		end
	-- 	end,
	-- 	execute = function(inst)
	-- 		local inventory = ThePlayer.replica.inventory
	-- 		if inventory ~= nil then
	-- 			inventory:CastSpellBookFromInv(inst)
	-- 		end
    --     end,
	-- 	atlas = "images/spell_icons_switch_passive.xml",
	-- 	normal = "spell_icons_switch_passive.tex",
	-- 	widget_scale = ICON_SCALE,
	-- },
	-- {
	-- 	label = STRINGS.BOOK_MOONPETS.powerup,
	-- 	onselect = function(inst)
	-- 		inst.components.spellbook:SetSpellName(STRINGS.BOOK_MOONPETS.powerup)
	-- 		inst.components.spellbook:SetSpellAction(nil)
	-- 		if TheWorld.ismastersim then
	-- 			inst.components.aoespell:SetSpellFn(nil)
	-- 			inst.components.spellbook:SetSpellFn(PowerupFn)
	-- 		end
	-- 	end,
	-- 	execute = function(inst)
	-- 		local inventory = ThePlayer.replica.inventory
	-- 		if inventory ~= nil then
	-- 			inventory:CastSpellBookFromInv(inst)
	-- 		end
    --     end,
	-- 	atlas = "images/spell_icons_powerup.xml",
	-- 	normal = "spell_icons_powerup.tex",
	-- 	widget_scale = ICON_SCALE,
	-- },
}

local INITSPELLS = {}
for _, v in ipairs(SPELL_ORDER) do
	table.insert(INITSPELLS, SPELL_DEFS[v])
end


local function UpdateAttackModeIcons(inst, spell_defs)
    -- 互斥指令及其激活图标
    local mode_defs = {
        aggressive = {
            key = "switch_aggressive",
            atlas_on = "images/spell_icons_switch_aggressive_ON.xml",
            normal_on = "spell_icons_switch_aggressive_ON.tex",
            atlas_off = "images/spell_icons_switch_aggressive.xml",
            normal_off = "spell_icons_switch_aggressive.tex",
        },
        defensive = {
            key = "switch_defensive",
            atlas_on = "images/spell_icons_switch_defensive_ON.xml",
            normal_on = "spell_icons_switch_defensive_ON.tex",
            atlas_off = "images/spell_icons_switch_defensive.xml",
            normal_off = "spell_icons_switch_defensive.tex",
        },
        passive = {
            key = "switch_passive",
            atlas_on = "images/spell_icons_switch_passive_ON.xml",
            normal_on = "spell_icons_switch_passive_ON.tex",
            atlas_off = "images/spell_icons_switch_passive.xml",
            normal_off = "spell_icons_switch_passive.tex",
        },
    }

    for mode, def in pairs(mode_defs) do
        local spell = spell_defs[def.key]
        if spell then
            if inst.book_atk_mode == mode then
                spell.atlas = def.atlas_on
                spell.normal = def.normal_on
            else
                spell.atlas = def.atlas_off
                spell.normal = def.normal_off
            end
        end
    end

    -- 刷新 spellbook 图标
    if inst.components.spellbook then
        local spells = {}
		print("set items")
        for _, v in ipairs(SPELL_ORDER) do
            table.insert(spells, spell_defs[v])
			print("atlas: " .. spell_defs[v].atlas .. "        normal: " .. spell_defs[v].normal)
        end
        inst.components.spellbook:SetItems(spells)
		print("check items")
		for _, v in ipairs(inst.components.spellbook.items) do
			print("spell: " .. v.label)
			print("atlas: " .. v.atlas .. "        normal: " .. v.normal)
		end
    end
end

local function OnOpenSpellBook(inst)
	-- local inventoryitem = inst.replica.inventoryitem
    -- local owner = inventoryitem:IsHeldBy(ThePlayer) and ThePlayer
	-- if owner ~= nil then
	-- 	UpdateAttackModeIcons(inst, owner)
	-- 	print("UpdateAttackModeIcons Success")
	-- 	print("doer.pets_atk_mode: " .. owner.pets_atk_mode)
	-- end
	-- local inventoryitem = inst.replica.inventoryitem
	-- if inventoryitem ~= nil then
	-- 	inventoryitem:OverrideImage("waxwelljournal_open")
	-- end
end

local function OnCloseSpellBook(inst)
	-- local inventoryitem = inst.replica.inventoryitem
	-- if inventoryitem ~= nil then
	-- 	inventoryitem:OverrideImage(nil)
	-- end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    MakeInventoryPhysics(inst) -- so it can be dropped as loot

    inst.AnimState:SetBank("book_moonpets")
    inst.AnimState:SetBuild("book_moonpets")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

	inst:AddTag("book")

    MakeInventoryFloatable(inst)

    inst:AddTag("book_moonpets")
    
    local spellbook = inst:AddComponent("spellbook")
    spellbook:SetRequiredTag("wormwood_pets_carrat")
    spellbook:SetRadius(SPELLBOOK_RADIUS)
    spellbook:SetFocusRadius(SPELLBOOK_RADIUS)
    spellbook:SetItems(INITSPELLS)
    spellbook:SetOnOpenFn(OnOpenSpellBook)
    spellbook:SetOnCloseFn(OnCloseSpellBook)
	spellbook.opensound = "dontstarve/common/together/book_maxwell/use"
	spellbook.closesound = "dontstarve/common/together/book_maxwell/close"

	inst:AddComponent("aoetargeting")
	inst.components.aoetargeting:SetAllowWater(true)
	inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
	inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
	inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
	inst.components.aoetargeting.reticule.ease = true
	inst.components.aoetargeting.reticule.mouseenabled = true
	inst.components.aoetargeting.reticule.twinstickmode = 1
	inst.components.aoetargeting.reticule.twinstickrange = 8
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/book_moonpets.xml"

	-- 搞不定刷新 UI 的代码，燃尽了
	-- inst:DoPeriodicTask(1, function(inst)
	-- 	UpdateAttackModeIcons(inst, SPELL_DEFS)
	-- end)

	inst.swap_build = "book_moonpets"

	inst.book_atk_mode = "defensive"

    inst:AddComponent("tradable")

	inst:AddComponent("aoespell")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("book_moonpets", fn, assets)
