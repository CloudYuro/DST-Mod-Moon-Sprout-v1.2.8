require "behaviours/wander"
require "behaviours/follow"

local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 8

local MAX_CHASE_TIME      = 6
local MAX_CHASE_DIST      = 12
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local AGGRESSIVE_FOLLOW_DISTANCE_MIN = 0
local AGGRESSIVE_FOLLOW_DISTANCE_TARGET = 8
local AGGRESSIVE_FOLLOW_DISTANCE_MAX = 20

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 8
local FOLLOW_DISTANCE_MAX = 15

local FruitDragonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

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

local wander_timing = {minwalktime = 4, randwalktime = 4, randwaittime = 1}

function FruitDragonBrain:OnStart()
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
        
        -- moving combat
        WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "Attack Momentarily",
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
        WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

        -- sticking combat
        WhileNode(function() return ShouldFight(self.inst) and not GetLeader(self.inst).pets_moving_combat end, "Sticking Attack",
            ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST)),

        Wander(self.inst, GetLeaderLocation, MAX_WANDER_DIST, wander_timing),
    }, .25)
    self.bt = BT(self.inst, root)
end


return FruitDragonBrain