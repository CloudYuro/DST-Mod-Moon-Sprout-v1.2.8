RegisterSkilltreeBGForCharacter("images/skilltree_icons/wormwood_background.xml", "wormwood")

RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_seed.xml", "wormwood_seed.tex")

RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_pets_piko.xml", "wormwood_pets_piko.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_pets_grassgator.xml", "wormwood_pets_grassgator.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_pets_flytrap.xml", "wormwood_pets_flytrap.tex")

RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_mushroom_mushroombomb.xml", "wormwood_mushroom_mushroombomb.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_mushroom_shroomcake.xml", "wormwood_mushroom_shroomcake.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_mushroom_mushroomhat.xml", "wormwood_mushroom_mushroomhat.tex")

RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_thorn_cactus.xml", "wormwood_thorn_cactus.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_thorn_deciduoustree.xml", "wormwood_thorn_deciduoustree.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_thorn_ivystaff.xml", "wormwood_thorn_ivystaff.tex")

RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_blooming_lunartree.xml", "wormwood_blooming_lunartree.tex")
RegisterSkilltreeIconsAtlas("images/skilltree_icons/wormwood_blooming_opalstaff.xml", "wormwood_blooming_opalstaff.tex")


local BuildSkillsData = require("prefabs/skilltree_moonsprout")
local defs = require("prefabs/skilltree_defs")

if BuildSkillsData then
    local data = BuildSkillsData(defs.FN)
    defs.CreateSkillTreeFor("wormwood", data.SKILLS)
    defs.SKILLTREE_ORDERS["wormwood"] = data.ORDERS
end