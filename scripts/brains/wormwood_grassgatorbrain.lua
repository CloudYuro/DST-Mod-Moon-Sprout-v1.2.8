require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"

local BrainCommon = require("brains/braincommon")

local WANDER_DIST = TUNING.SHADE_CANOPY_RANGE -2

local MAX_CHASE_TIME      = 6
local MAX_CHASE_DIST      = 12
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local AVOID_COMBAT_DIST       = 8
local STOP_AVOID_COMBAT_DIST  = 12

local START_FACE_DIST = 5
local KEEP_FACE_DIST = 6
local MAX_WANDER_DIST = 15

local AGGRESSIVE_FOLLOW_DISTANCE_MIN = 0
local AGGRESSIVE_FOLLOW_DISTANCE_TARGET = 8
local AGGRESSIVE_FOLLOW_DISTANCE_MAX = 20

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 8
local FOLLOW_DISTANCE_MAX = 15


local WORK_DISTANCE = 15

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

local function HarvestTarget(inst)
    local target = FindEntity(
        inst,
        WORK_DISTANCE, -- 搜索半径
        function(guy)
            return guy:HasTag("farm_plant") and 
                    guy.components.pickable and 
                    guy.components.pickable:CanBePicked()
        end
    )
    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end

local function HammerTarget(inst)
    local target = FindEntity(
        inst,
        WORK_DISTANCE,
        function(guy)
            return guy:HasTag("oversized_veggie")
                   and guy.components.workable
                   and guy.components.workable:GetWorkAction() == ACTIONS.HAMMER
        end
    )
    local hammer = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if target and hammer then
        print("执行敲击" .. tostring(GetTime()))
        return BufferedAction(inst, target, ACTIONS.HAMMER, hammer)
    end
end

local function GetFaceTargetFn(inst)
    if not BrainCommon.ShouldSeekSalt(inst) then
        local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
        if not inst.components.timer:TimerExists("facetarget") then
            inst.components.timer:StartTimer("facetarget",3)
        end
        return target ~= nil and not target:HasTag("notarget") and target or nil
    end
end

local function KeepFaceTargetFn(inst, target)
    return not BrainCommon.ShouldSeekSalt(inst)
        and not target:HasTag("notarget")
        and inst.components.timer:TimerExists("facetarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local GrassgatorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function isonland(inst)
    return TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition())
end

local function getwanderloc(inst)
    return (not isonland(inst) and inst.components.knownlocations:GetLocation("home"))
        or nil
end

function GrassgatorBrain:OnStart()
    local function ShouldFight(inst)
        return self.inst.shouldfight and GetLeader(self.inst).pets_atk_mode ~= "passive"
    end

    local function ShouldRunAway(guy)
        if self.inst.shouldfight then
            return false
        end
        return guy:HasTag("hostile") 
    end

    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("diving") end, "Not Diving",
            PriorityNode(
            {
				BrainCommon.PanicTrigger(self.inst),

                WhileNode(function() return GetLeader(self.inst).pets_standstill end, "Check Stand Still",
                    StandStill(self.inst)),

                WhileNode(function() return GetLeader(self.inst).pets_atk_mode == "aggressive" end, "Aggressive Follow",
                    Follow(self.inst, GetLeader, AGGRESSIVE_FOLLOW_DISTANCE_MIN, AGGRESSIVE_FOLLOW_DISTANCE_TARGET, AGGRESSIVE_FOLLOW_DISTANCE_MAX)),
                WhileNode(function() return GetLeader(self.inst).pets_atk_mode ~= "aggressive" end, "Defensive/Passive Follow",
                    Follow(self.inst, GetLeader, FOLLOW_DISTANCE_MIN, FOLLOW_DISTANCE_TARGET, FOLLOW_DISTANCE_MAX)),

                -- moving combat
                WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and (self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown()) end, "Attack Momentarily",
                    ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
                WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and (self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown()) end, "Dodge",
                    RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

                -- sticking combat
                WhileNode(function() return ShouldFight(self.inst) and not GetLeader(self.inst).pets_moving_combat end, "Sticking Attack",
                    ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST)),   

                SequenceNode{
                    RunAway(self.inst, ShouldRunAway, AVOID_COMBAT_DIST, STOP_AVOID_COMBAT_DIST),
                    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 0.5)
                },
                -- DoAction(self.inst, function() return HarvestTarget(self.inst) end, "pick", true),
                -- DoAction(self.inst, function() return HammerTarget(self.inst) end, "hammer", true),
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
                Wander(self.inst, GetLeaderLocation, MAX_WANDER_DIST),
            }, .25)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return GrassgatorBrain
