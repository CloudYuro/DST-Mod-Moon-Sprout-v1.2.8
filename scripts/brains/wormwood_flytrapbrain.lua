require("behaviours/wander")
require("behaviours/chaseandattack")
require("behaviours/panic")
require("behaviours/attackwall")
require("behaviours/minperiod")
require("behaviours/faceentity")
require("behaviours/doaction")
require("behaviours/standstill")

local BrainCommon = require("brains/braincommon")

local MAX_CHASE_TIME      = 6
local MAX_CHASE_DIST      = 12
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local SEE_FOOD_DIST = 15
local EAT_FOOD_NO_TAGS = {"INLIMBO", "irreplaceable", "outofreach", "smolder", "FX", "NOCLICK", "DECOR", "aquatic"}

local AGGRESSIVE_FOLLOW_DISTANCE_MIN = 0
local AGGRESSIVE_FOLLOW_DISTANCE_TARGET = 8
local AGGRESSIVE_FOLLOW_DISTANCE_MAX = 20

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 6
local FOLLOW_DISTANCE_MAX = 15

local MAX_WANDER_DIST = 15

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader() or nil
end

local function GetLeaderLocation(inst)
    local leader = GetLeader(inst)
    if leader == nil then
        return nil
    end

    return leader:GetPosition()
end

local function EatFoodAction(inst)
    -- print(string.format("stage & health & time: %d %d %d", inst.stage_plus, inst.components.health:GetPercent(), inst.components.timer:GetTimeLeft("finish_transformed_life")))
    if inst.sg:HasStateTag("busy") or (inst.stage_plus == 50 and inst.components.health:GetPercent() >= 0.85 
        and inst.components.timer:GetTimeLeft("finish_transformed_life") > 480 * 5) then
        return
    end

    local target = FindEntity(inst, SEE_FOOD_DIST, function(item)
        return inst.components.eater:CanEat(item)
            and item:IsOnValidGround()
            and item:GetTimeAlive() > TUNING.SPIDER_EAT_DELAY
            and item.prefab ~= "deerclops_eyeball"     -- 不准吃巨鹿眼球
            and item.prefab ~= "pigskin"
            and item.prefab ~= "manrabbit_tail"
    end, nil, EAT_FOOD_NO_TAGS)

    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local FlytrapBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function FlytrapBrain:OnStart()
    local function ShouldFight(inst)
        return GetLeader(self.inst).pets_atk_mode ~= "passive"
    end

    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),
        WhileNode(function() return GetLeader(self.inst).pets_standstill end, "Check Stand Still",
            StandStill(self.inst)),

        WhileNode(function() return GetLeader(self.inst).pets_atk_mode == "aggressive" end, "Aggressive Follow",
            Follow(self.inst, GetLeader, AGGRESSIVE_FOLLOW_DISTANCE_MIN, AGGRESSIVE_FOLLOW_DISTANCE_TARGET, AGGRESSIVE_FOLLOW_DISTANCE_MAX)),
        WhileNode(function() return GetLeader(self.inst).pets_atk_mode ~= "aggressive" end, "Defensive/Passive Follow",
            Follow(self.inst, GetLeader, FOLLOW_DISTANCE_MIN, FOLLOW_DISTANCE_TARGET, FOLLOW_DISTANCE_MAX)),

        DoAction(self.inst, function() return EatFoodAction(self.inst) end ),

        -- moving combat
        WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "Attack Momentarily",
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
        WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

        -- sticking combat
        WhileNode(function() return ShouldFight(self.inst) and not GetLeader(self.inst).pets_moving_combat end, "Sticking Attack",
            ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST)),

        -- Wander(self.inst, GetLeaderLocation, MAX_WANDER_DIST),
        StandStill(self.inst),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return FlytrapBrain
