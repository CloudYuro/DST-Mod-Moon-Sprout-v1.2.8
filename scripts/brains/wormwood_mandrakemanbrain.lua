require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"

local BrainCommon = require("brains/braincommon")

local AGGRESSIVE_FOLLOW_DISTANCE_MIN = 0
local AGGRESSIVE_FOLLOW_DISTANCE_TARGET = 8
local AGGRESSIVE_FOLLOW_DISTANCE_MAX = 20

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 8
local FOLLOW_DISTANCE_MAX = 15

local MAX_WANDER_DIST = 20

local STOP_RUN_DIST = 30

local MAX_CHASE_TIME      = 6
local MAX_CHASE_DIST      = 12
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local TRADE_DIST = 20
local SEE_FOOD_DIST = 10

local SEE_PLAYER_DIST = 6

local SCARER_MUST_TAGS = {"manrabbitscarer"}
local SEE_SCARER_DIST = TUNING.RABBITKINGSPEAR_SCARE_RADIUS
local STOP_SCARER_DIST = SEE_SCARER_DIST + 6

local GETTRADER_MUST_TAGS = { "player" }
local FINDFOOD_CANT_TAGS = { "INLIMBO", "outofreach" }

local function GetTraderFn(inst)
    return FindEntity(inst, TRADE_DIST,
        function(target)
            return inst.components.trader:IsTryingToTradeWithMe(target)
        end, GETTRADER_MUST_TAGS)
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    inst._can_eat_test = inst._can_eat_test or function(item)
        return inst.components.eater:CanEat(item)
    end

    local target =
        (inst.components.inventory ~= nil and
        inst.components.eater ~= nil and
        inst.components.inventory:FindItem(inst._can_eat_test)) or
        nil

    -- if not target then
    --     local time_since_eat = inst.components.eater:TimeSinceLastEating()
    --     if not time_since_eat or (time_since_eat > 2 * TUNING.PIG_MIN_POOP_PERIOD) then
    --         local noveggie = time_since_eat ~= nil and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD * 4
    --         target = FindEntity(inst,
    --             SEE_FOOD_DIST,
    --             function(item)
    --                 return item.prefab ~= "mandrake"
    --                     and item.components.edible ~= nil
    --                     and (not noveggie or item.components.edible.foodtype == FOODTYPE.MEAT)
    --                     and inst.components.eater:CanEat(item)
    --                     and item:GetTimeAlive() >= 8
    --                     and item:IsOnPassablePoint()
    --             end,
    --             nil,
    --             FINDFOOD_CANT_TAGS
    --         )
    --     end
    -- end

    return (target ~= nil and BufferedAction(inst, target, ACTIONS.EAT)) or nil
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function FindNearbyScarer(inst)
    local leader = inst.components.follower and inst.components.follower:GetLeader() or nil
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_SCARER_DIST, SCARER_MUST_TAGS)
    for _, ent in ipairs(ents) do
        if ent:HasTag("INLIMBO") then
            if ent.components.equippable and ent.components.equippable:IsEquipped() then
                if ent.components.inventoryitem == nil or ent.components.inventoryitem:GetGrandOwner() ~= leader then
                    return ent
                end
            end
        end
        return ent
    end
    return nil
end

local Wormwood_MandrakemanBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local hunterparams_scarer = {
    tags = { "manrabbitscarer" },
    notags = { "NOCLICK" },
    seeequipped = true,
}

function Wormwood_MandrakemanBrain:OnStart()
    local function ShouldFight(inst)
        return GetLeader(self.inst).pets_atk_mode ~= "passive"
    end

    local function ShouldRunAway(guy)
        return guy:HasTag("hostile") 
    end

    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "RABBIT_PANICBOSS"),
            WhileNode(function() return GetLeader(self.inst).pets_standstill end, "Check Stand Still",
                StandStill(self.inst)),
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted",
                ChattyNode(self.inst, "RABBIT_PANICHAUNT",
                    Panic(self.inst))),
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                ChattyNode(self.inst, "RABBIT_PANICFIRE",
                    Panic(self.inst))),
            
            WhileNode(function() return GetLeader(self.inst).pets_atk_mode == "aggressive" end, "Aggressive Follow",
                Follow(self.inst, GetLeader, AGGRESSIVE_FOLLOW_DISTANCE_MIN, AGGRESSIVE_FOLLOW_DISTANCE_TARGET, AGGRESSIVE_FOLLOW_DISTANCE_MAX)),
            WhileNode(function() return GetLeader(self.inst).pets_atk_mode ~= "aggressive" end, "Defensive/Passive Follow",
                Follow(self.inst, GetLeader, FOLLOW_DISTANCE_MIN, FOLLOW_DISTANCE_TARGET, FOLLOW_DISTANCE_MAX)),

            WhileNode(function() return self.inst.components.health:GetPercent() < 0.20 end, "LowHealth",
                ChattyNode(self.inst, "RABBIT_RETREAT",
                    -- RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST))),
                    RunAway(self.inst, ShouldRunAway, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST))),

            -- moving combat
            WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "Attack Momentarily",
                ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
            WhileNode(function() return ShouldFight(self.inst) and GetLeader(self.inst).pets_moving_combat and self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

            -- sticking combat
            WhileNode(function() return ShouldFight(self.inst) and not GetLeader(self.inst).pets_moving_combat end, "Sticking Attack",
                ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST)),
                
            ChattyNode(self.inst, "RABBIT_RETREAT",
                RunAway(self.inst, hunterparams_scarer, SEE_SCARER_DIST, STOP_SCARER_DIST)),
            FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
            DoAction(self.inst, FindFoodAction),
            Wander(self.inst, nil, MAX_WANDER_DIST)  -- 移除了GetNoLeaderHomePos参数
        }, .5)

    self.bt = BT(self.inst, root)
end

return Wormwood_MandrakemanBrain