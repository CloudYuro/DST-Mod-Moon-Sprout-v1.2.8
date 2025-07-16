GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

local language_setting = tonumber(GetModConfigData("language_setting"))
local lan = (GLOBAL.LanguageTranslator.defaultlang == "zh") and "zh" 
        or (GLOBAL.LanguageTranslator.defaultlang == "ru") and "ru" 
        or "en"
local isCh = lan == "zh" or lan == "zhr"
local isRu = lan == "ru"
local isEn = not isCh and not isRu
if language_setting == 1 then
    isCh = true
elseif language_setting == 2 then
    isRu = true
elseif language_setting == 3 then
    isEn = true
end
if isCh then
    modimport("languages/chs")
elseif isRu then
    modimport("languages/ru")
elseif isEn then
    modimport("languages/en")
else
    modimport("languages/en")
end

GLOBAL.WORMWOOD_SKILLTREESTRINGSEX = GLOBAL.SKILLTREESTRINGSEX

Assets = {
    Asset("IMAGE", "images/inventoryimages/moon_tree_blossom_charged.tex"),
    Asset("ATLAS", "images/inventoryimages/moon_tree_blossom_charged.xml"),
    Asset("IMAGE", "images/inventoryimages/book_moonpets.tex"),
    Asset("ATLAS", "images/inventoryimages/book_moonpets.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_carrat.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_carrat.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_fruitdragon.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_fruitdragon.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_fruitdragon_ripe.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_fruitdragon_ripe.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_piko.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_piko.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_piko_orange.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_piko_orange.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_grassgator.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_grassgator.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_flytrap.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_flytrap.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_mandrakeman.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_mandrakeman.xml"),
    Asset("IMAGE", "images/inventoryimages/mandrake_planted.tex"),
    Asset("ATLAS", "images/inventoryimages/mandrake_planted.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_mushroombomb.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_mushroombomb.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_mushroombomb_gas.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_mushroombomb_gas.xml"),
    Asset("IMAGE", "images/inventoryimages/wormwood_moon_mushroomhat.tex"),
    Asset("ATLAS", "images/inventoryimages/wormwood_moon_mushroomhat.xml"),
    Asset("IMAGE", "images/inventoryimages/ivystaff.tex"),
    Asset("ATLAS", "images/inventoryimages/ivystaff.xml"),
    Asset("IMAGE", "images/inventoryimages/corkchest.tex"),
    Asset("ATLAS", "images/inventoryimages/corkchest.xml"),

    
    Asset("ANIM", "anim/ui_largechest_5x5.zip"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_seed.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_seed.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_background.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_background.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_pets_piko.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_pets_piko.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_pets_grassgator.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_pets_grassgator.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_pets_flytrap.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_pets_flytrap.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_mushroom_mushroombomb.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_mushroom_mushroombomb.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_mushroom_shroomcake.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_mushroom_shroomcake.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_mushroom_mushroomhat.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_mushroom_mushroomhat.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_thorn_cactus.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_thorn_cactus.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_thorn_deciduoustree.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_thorn_deciduoustree.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_thorn_ivystaff.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_thorn_ivystaff.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_blooming_lunartree.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_blooming_lunartree.xml"),
    Asset("IMAGE", "images/skilltree_icons/wormwood_blooming_opalstaff.tex"),
    Asset("ATLAS", "images/skilltree_icons/wormwood_blooming_opalstaff.xml"),


    Asset("SOUND", "sound/DLC003_sfx.fsb"),
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
}

PrefabFiles = {
    "wormwood_mushroombomb",
    "wormwood_mushroombomb_gas",
    "moontree_plant_fx",
    "moon_tree_blossom_charged",
    "wormwood_chest",
    "book_moonpets",
    "wormwood_piko",
    "wormwood_mutantproxy_piko",
    "wormwood_grassgator",
    "wormwood_mutantproxy_grassgator",
    "wormwood_flytrap",
    "wormwood_mutantproxy_flytrap",
    "wormwood_mandrakeman",
    "wormwood_mutantproxy_mandrakeman",
    "wormwood_mutantproxy_mandrake_active",
    "wormwood_moon_mushroomhat",
    "wormwood_spore_moon",
    "wormwood_deciduous_root",
    "ivystaff",
    "bramble",
    "wormwood_lunarthrall_plant",
    "wormwood_meteor_terraformer",
    "wormwood_gestalt_guard",
    "wormwood_gestalt_head",
    "wormwood_lunar_grazer",
}

modimport("scripts/recipe") 
modimport("scripts/build_skilltree") 
modimport("scripts/skill_farming")
modimport("scripts/skill_pets")
modimport("scripts/skill_mushroom")
modimport("scripts/skill_thorn")
modimport("scripts/skill_blooming")
-- modimport("scripts/compatibility")
