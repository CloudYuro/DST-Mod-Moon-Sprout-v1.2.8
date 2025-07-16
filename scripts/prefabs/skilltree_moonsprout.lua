local SKILLTREESTRINGS = STRINGS.SKILLTREE.WORMWOOD
local SKILLTREESTRINGSEX = rawget(_G, "WORMWOOD_SKILLTREESTRINGSEX") or {}

local UI_LEFT, UI_RIGHT = -214, 228
local UI_VERTICAL_MIDDLE = (UI_LEFT + UI_RIGHT) * 0.5
local UI_TOP, UI_BOTTOM = 176, 20
local TILE_SIZE, TILE_HALFSIZE = 34, 16

local ORDERS = {
    { "seed",   { UI_LEFT, UI_TOP } },
    { "pets",    { UI_LEFT, UI_TOP } },
    { "mushroom",   { UI_LEFT, UI_TOP } },
    { "thorn", { UI_LEFT, UI_TOP } },
    { "blooming", { UI_LEFT, UI_TOP } },
    { "lunarplant", {UI_LEFT, UI_TOP} }
}

local function BuildSkillsData(SkillTreeFns)
    local skills = {
        wormwood_identify_plants2 = {
            title = SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_DESC_EX,
            icon = "wormwood_seed",
            pos = {(UI_LEFT + UI_RIGHT) * 0.5, UI_BOTTOM},

            group = "seed",
            tags = {"allegiance", "lunar", "lunar_favor"},
            root = true,
            defaultfocus = true,
            onactivate = function(owner, from_load)
                owner:AddTag("farmplantidentifier")
                local damagetyperesist = owner.components.damagetyperesist
                if damagetyperesist then
                    owner.components.damagetypebonus:AddBonus("shadow_aligned", owner, 1.1, "wormwood_identify_plants2")
                    owner.components.damagetyperesist:AddResist("lunar_aligned", owner, 0.9, "wormwood_identify_plants2")
                end
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("farmplantidentifier")
                local damagetyperesist = owner.components.damagetyperesist
                if damagetyperesist then
                    owner.components.damagetypebonus:RemoveBonus("shadow_aligned", owner, "wormwood_identify_plants2")
                    owner.components.damagetyperesist:RemoveResist("lunar_aligned", owner, "wormwood_identify_plants2")
                end
            end,
            connects = {
                "wormwood_pets_carrat",
                "wormwood_mushroomplanter_ratebonus2",
                "wormwood_thorn_cactus",
                "wormwood_quick_selffertilizer",
                -- "wormwood_allegiance_lunar_plant_gear_1",
            },
        },

        -------------------------------------- 召唤线 ---------------------------------------
        wormwood_pets_carrat = {
            title = SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_DESC_EX,
            icon = "wormwood_lunar_mutations_1",
            pos = {UI_VERTICAL_MIDDLE - 105, UI_BOTTOM + 10},

            group = "pets",
            tags = {"pets"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_carrat")
                owner:AddTag("wormwood_pets_carrat_pickup")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_carrat")
                owner:RemoveTag("wormwood_pets_carrat_pickup")
            end,
            connects = {
                "wormwood_pets_lightflier",
            },
        },
        wormwood_pets_lightflier = {
            title = SKILLTREESTRINGSEX.LUNAR_MUTATIONS_2_TITLE_EX,
            desc = SKILLTREESTRINGS.LUNAR_MUTATIONS_2_DESC,
            icon = "wormwood_lunar_mutations_2",
            pos = {UI_VERTICAL_MIDDLE - 105 - 50, UI_BOTTOM + 10},

            group = "pets",
            tags = {"pets"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_lightflier")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_lightflier")
            end,
            connects = {
                "wormwood_pets_piko",
                "wormwood_pets_fruitdragon",
            },
        },
        wormwood_pets_piko = {
            title = SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_DESC_EX,
            icon = "wormwood_pets_piko",
            pos = {UI_VERTICAL_MIDDLE - 115 - 60, UI_BOTTOM + 58},

            group = "pets",
            tags = {"pets"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_piko")
                owner:AddTag("wormwood_pets_piko_pickup")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_piko")
                owner:RemoveTag("wormwood_pets_piko_pickup")
            end,
        },
        wormwood_pets_fruitdragon = {
            title = SKILLTREESTRINGSEX.LUNAR_MUTATIONS_3_TITLE_EX,
            desc = SKILLTREESTRINGS.LUNAR_MUTATIONS_3_DESC,
            icon = "wormwood_lunar_mutations_3",
            pos = {UI_VERTICAL_MIDDLE - 105 - 100, UI_BOTTOM + 10},

            group = "pets",
            tags = {"pets"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_fruitdragon")
                owner:AddTag("wormwood_pets_fruitdragon_pickup")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_fruitdragon")
                owner:RemoveTag("wormwood_pets_fruitdragon_pickup")
            end,
            connects = {
                "wormwood_pets_grassgator",
            },
        },
        wormwood_pets_grassgator = {
            title = SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_DESC_EX,
            icon = "wormwood_pets_grassgator",
            pos = {UI_VERTICAL_MIDDLE - 115 - 120, UI_BOTTOM + 58},

            group = "pets",
            tags = {"pets"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_grassgator")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_grassgator")
            end,
            connects = {
                "wormwood_pets_flytrap",
            },
        },
        wormwood_pets_flytrap = {
            title = SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_DESC_EX,
            icon = "wormwood_pets_flytrap",
            pos = {UI_VERTICAL_MIDDLE - 115 - 130, UI_BOTTOM + 120},

            group = "pets",
            tags = {"pets", "allegiance", "lunar", "lunar_favor"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_pets_flytrap")
                owner:AddTag("wormwood_pets_mandrakeman")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_pets_flytrap")
                owner:RemoveTag("wormwood_pets_mandrakeman")
            end,
        },
        -------------------------------------- 召唤线 ---------------------------------------

        -------------------------------------- 蘑菇线 ---------------------------------------

        wormwood_mushroomplanter_ratebonus2 = {
            title = SKILLTREESTRINGSEX.MUSHROOMPLANTER_RATEBONUS_2_TITLE_EX,
            desc = SKILLTREESTRINGS.MUSHROOMPLANTER_RATEBONUS_2_DESC,
            icon = "wormwood_mushroomplanter_ratebonus2",
            pos = {UI_VERTICAL_MIDDLE - 35 - 30, UI_BOTTOM + 65},

            group = "mushroom",
            tags = {"mushroom"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_mushroomplanter_ratebonus2")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_mushroomplanter_ratebonus2")
            end,
            connects = {
                "wormwood_mushroomplanter_upgrade",
            },
        },
        wormwood_mushroomplanter_upgrade = {
            title = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_DESC_EX,
            icon = "wormwood_mushroomplanter_upgrade",
            pos = {UI_VERTICAL_MIDDLE - 90 - 20, UI_BOTTOM + 95},

            group = "mushroom",
            tags = {"mushroom"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_mushroomplanter_upgrade")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_mushroomplanter_upgrade")
            end,
            connects = {
                "wormwood_moon_cap_eating",
                "wormwood_mushroom_mushroombomb",
            },
        },
        wormwood_mushroom_mushroombomb = {
            title = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_DESC_EX,
            icon = "wormwood_mushroom_mushroombomb",
            pos = {UI_VERTICAL_MIDDLE - 30 - 30, UI_BOTTOM + 125},

            group = "mushroom",
            tags = {"mushroom"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_mushroom_mushroombomb")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_mushroom_mushroombomb")
            end,
        },
        wormwood_moon_cap_eating = {
            title = SKILLTREESTRINGS.MOON_CAP_EATING_TITLE,
            desc = SKILLTREESTRINGSEX.WORMWOOD_MOON_CAP_EATING_DESC_EX,
            icon = "wormwood_moon_cap_eating",
            pos = {UI_VERTICAL_MIDDLE - 90 - 30, UI_BOTTOM + 145},

            group = "mushroom",
            tags = {"mushroom"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_moon_cap_eating")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_moon_cap_eating")
            end,
            connects = {
                "wormwood_mushroom_mushroomhat",
                "wormwood_mushroom_shroomcake",
            },
        },
        wormwood_mushroom_shroomcake = {
            title = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_DESC_EX,
            icon = "wormwood_mushroom_shroomcake",
            pos = {UI_VERTICAL_MIDDLE - 150 - 40, UI_BOTTOM + 160},

            group = "mushroom",
            tags = {"mushroom"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_mushroom_shroomcake")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_mushroom_shroomcake")
            end,
        },
        wormwood_mushroom_mushroomhat = {
            title = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_DESC_EX,
            icon = "wormwood_mushroom_mushroomhat",
            pos = {UI_VERTICAL_MIDDLE - 70 - 35, UI_BOTTOM + 200},

            group = "mushroom",
            tags = {"mushroom", "allegiance", "lunar", "lunar_favor"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_mushroom_mushroomhat")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_mushroom_mushroomhat")
            end,
        },
        -------------------------------------- 蘑菇线 ---------------------------------------
        
        -------------------------------------- 荆棘线 ---------------------------------------
        wormwood_thorn_cactus = {
            title = SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_DESC_EX,
            icon = "wormwood_thorn_cactus",
            pos = {UI_VERTICAL_MIDDLE + 55 + 20, UI_BOTTOM + 45 + TILE_SIZE},

            group = "thorn",
            tags = {"thorn"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_thorn_cactus")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_thorn_cactus")
            end,
            connects = {
                "wormwood_blooming_trapbramble",
            },
        },
        wormwood_blooming_trapbramble = {
            title = SKILLTREESTRINGS.BLOOMING_TRAPBRAMBLE_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_TRAPBRAMBLE_DESC,
            icon = "wormwood_blooming_trapbramble",
            pos = {UI_VERTICAL_MIDDLE + 95 + 20, UI_BOTTOM + 115},

            group = "thorn",
            tags = {"thorn"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_trapbramble")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_trapbramble")
            end,
            connects = {
                "wormwood_armor_bramble",
                "wormwood_bugs",
            },
        },

        wormwood_bugs = {
            title = SKILLTREESTRINGS.BUGS_TITLE,
            desc = SKILLTREESTRINGSEX.BUGS_DESC_EX,
            icon = "wormwood_bugs",
            pos = {UI_VERTICAL_MIDDLE + 43 + 20, UI_BOTTOM + 150},

            group = "thorn",
            tags = {"thorn"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_bugs")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_bugs")
            end,
        },

        wormwood_armor_bramble = {
            title = SKILLTREESTRINGS.ARMOR_BRAMBLE_TITLE,
            desc = SKILLTREESTRINGSEX.ARMOR_BRAMBLE_DESC_EX,
            icon = "wormwood_armor_bramble",
            pos = {UI_VERTICAL_MIDDLE + 137 + 20, UI_BOTTOM + 145},

            group = "thorn",
            tags = {"thorn"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_armor_bramble")
                owner:AddTag("bramble_resistant")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_armor_bramble")
                owner:RemoveTag("bramble_resistant")
            end,
            connects = {
                "wormwood_thorn_deciduoustree",
                "wormwood_thorn_ivystaff"
            },
        },
        wormwood_thorn_deciduoustree = {
            title = SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_DESC_EX,
            icon = "wormwood_thorn_deciduoustree",
            pos = {UI_VERTICAL_MIDDLE + 200 + 20, UI_BOTTOM + 170},

            group = "thorn",
            tags = {"thorn"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_thorn_deciduoustree")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_thorn_deciduoustree")
            end,
        },

        wormwood_thorn_ivystaff = {
            title = SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_DESC_EX,
            icon = "wormwood_thorn_ivystaff",
            pos = {UI_VERTICAL_MIDDLE + 110 + 25, UI_BOTTOM + 190},

            group = "thorn",
            tags = {"thorn", "allegiance", "lunar", "lunar_favor"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_thorn_ivystaff")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_thorn_ivystaff")
            end,
        },
        -------------------------------------- 荆棘线 ---------------------------------------

        -------------------------------------- 开花线 ---------------------------------------
        wormwood_quick_selffertilizer = {
            title = SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_DESC_EX,
            icon = "wormwood_quick_selffertilizer",
            pos = {UI_VERTICAL_MIDDLE + 105, UI_BOTTOM + 10},

            group = "blooming",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_quick_selffertilizer")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_quick_selffertilizer")
            end,
            connects = {
                "wormwood_blooming_farmrange1",
            },
        },
        wormwood_blooming_farmrange1 = {
            title = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_DESC_EX,
            icon = "wormwood_blooming_speed3",
            pos = {UI_VERTICAL_MIDDLE + 105 + 50, UI_BOTTOM + 10},

            group = "blooming",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_farmrange1")
                local bloomness = owner.components.bloomness      -- 前两个阶段所需开花值-25%
                -- GLOBAL.TheNet:Announce(tostring(bloomness.stage_duration))
                if bloomness then
                    bloomness:SetDurations(TUNING.WORMWOOD_BLOOM_STAGE_DURATION_UPGRADED2, bloomness.full_bloom_duration)
                    -- GLOBAL.TheNet:Announce(tostring(bloomness.full_bloom_duration))
                end
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_farmrange1")
            end,
            connects = {
                "wormwood_blooming_max_upgrade",
                "wormwood_blooming_overheatprotection",
            },
        },
        wormwood_blooming_overheatprotection = {
            title = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_DESC_EX,
            icon = "wormwood_blooming_overheatprotection",
            pos = {UI_VERTICAL_MIDDLE + 165, UI_BOTTOM + 60},

            group = "blooming",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_overheatprotection")
                if owner.fullbloom then
                    owner.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED_LARGE
                end
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_overheatprotection")
                if owner.fullbloom then
                    owner.components.temperature.inherentsummerinsulation = TUNING.INSULATION_SMALL
                else
                    owner.components.temperature.inherentsummerinsulation = 0
                end
            end,
        },
        wormwood_blooming_max_upgrade = {
            title = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_DESC_EX,
            icon = "wormwood_blooming_photosynthesis",
            pos = {UI_VERTICAL_MIDDLE + 105 + 100, UI_BOTTOM + 10},

            group = "blooming",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_max_upgrade")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_max_upgrade")
            end,
            connects = {
                "wormwood_blooming_lunartree",
            },
        },
        wormwood_blooming_lunartree = {
            title = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_DESC_EX,
            icon = "wormwood_blooming_lunartree",
            pos = {UI_VERTICAL_MIDDLE + 165 + 55, UI_BOTTOM + 60},

            group = "blooming",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_lunartree")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_lunartree")
            end,
            connects = {
                "wormwood_blooming_opalstaff",
            },
        },

        wormwood_blooming_opalstaff = {
            title = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_TITLE_EX,
            desc = SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_DESC_EX,
            icon = "wormwood_blooming_opalstaff",
            pos = {UI_VERTICAL_MIDDLE + 165 + 65, UI_BOTTOM + 120},

            group = "blooming",
            tags = {"blooming", "allegiance", "lunar", "lunar_favor"},
            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_blooming_opalstaff")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_blooming_opalstaff")
            end,
        },
        -------------------------------------- 开花线 ---------------------------------------

        -------------------------------------- 亲和线 ---------------------------------------

        wormwood_allegiance_lunar_plant_gear_1 = {
            title = SKILLTREESTRINGS.LUNAR_GEAR_1_TITLE,
            desc = SKILLTREESTRINGSEX.LUNAR_GEAR_1_DESC_EX,
            icon = "wormwood_allegiance_lunar_plant_gear_1",
            pos = {UI_VERTICAL_MIDDLE, UI_BOTTOM + 60},

            group = "lunarplant",
            tags = {"lunarplant", "allegiance", "lunar", "lunar_favor"},
            root = true,

            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_allegiance_lunar_plant_gear_1")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_allegiance_lunar_plant_gear_1")
            end,

            connects = {
                "wormwood_allegiance_lunar_plant_gear_2",
            },
        },

        wormwood_allegiance_lunar_plant_gear_2 = {
            title = SKILLTREESTRINGS.LUNAR_GEAR_2_TITLE,
            desc = SKILLTREESTRINGSEX.LUNAR_GEAR_2_DESC_EX,
            icon = "wormwood_allegiance_lunar_plant_gear_2",
            pos = {UI_VERTICAL_MIDDLE, UI_BOTTOM + 110},

            onactivate = function(owner, from_load)
                owner:AddTag("wormwood_allegiance_lunar_plant_gear_2")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("wormwood_allegiance_lunar_plant_gear_2")
            end,

            group = "lunarplant",
            tags = {"lunarplant", "allegiance", "lunar", "lunar_favor"},
        },
        -------------------------------------- 亲和线 ---------------------------------------
    }
    
    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

return BuildSkillsData