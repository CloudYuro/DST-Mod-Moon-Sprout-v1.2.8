-- Uncompromise Mode
local SkillTreeDefs = require("prefabs/skilltree_defs")
if SkillTreeDefs.SKILLTREE_DEFS["wormwood"] then
    -- 兼容Uncompromising Mode的字段名
    SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_photosynthesis = SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_max_upgrade or {}
    SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_speed1 = SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_farmrange1 or {}
    SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_speed2 = SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_farmrange1 or {}
    -- SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_max_upgrade = SkillTreeDefs.SKILLTREE_DEFS["wormwood"].wormwood_blooming_max_upgrade or {}
end
