require("behaviours/wander")
require("behaviours/runaway")
require("behaviours/doaction")
require("behaviours/panic")
require("behaviours/chaseandattack")

local BrainCommon = require("brains/braincommon")

-- 常量定义
local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_STOP = 6
local SEE_BAIT_DIST = 20
local MAX_WANDER_DIST = 8
local SEE_STOLEN_ITEM_DIST = 20
local MAX_CHASE_TIME = 8
local SEE_BAIT_MAXDIST = 20
local MAX_FOOD_STORAGE = 5 -- 松鼠最多私藏的食物数量

local AVOID_COMBAT_DIST       = 8
local STOP_AVOID_COMBAT_DIST  = 12

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 8
local FOLLOW_DISTANCE_MAX = 20

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader() or nil
end

local function GetLeaderLocation(inst)
    local leader = GetLeader(inst)
    return leader and leader:GetPosition() or nil
end

-- 检查物品是否可食用
local function IsItemEdible(inst, item)
    if item.components.edible then
        if item.components.edible.foodtype == FOODTYPE.VEGGIE then 
            return true
        end
    else
        return false
    end
end

local function LeaderFull(inst)
    local leader = GetLeader(inst)
    if not leader or not leader.components.inventory then
        return false
    end
    
    local inventoryfull = leader.components.inventory:NumItems() >= leader.components.inventory.maxslots
    local backpackfull = true

    local backpack = leader.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if backpack and backpack.components.container then
        backpackfull = backpack.components.container:NumItems() >= backpack.components.container.numslots
    end

    -- 检查领导者的物品栏是否已满
    return inventoryfull and backpackfull
end

local function CanGiveToPlayer(inst, item)
    local leader = GetLeader(inst)
    if not leader or not leader.components.inventory or not item then
        return false
    end

    -- 检查主物品栏
    for k, slot_item in pairs(leader.components.inventory.itemslots) do
        if slot_item and slot_item.prefab == item.prefab and
            slot_item.components.stackable and
            slot_item.components.stackable:StackSize() < slot_item.components.stackable.maxsize then
            return true
        end
    end
    -- 检查背包
    local backpack = leader.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if backpack and backpack.components.container then
        for i = 1, backpack.components.container:GetNumSlots() do
            local slot_item = backpack.components.container:GetItemInSlot(i)
            if slot_item and slot_item.prefab == item.prefab and
                slot_item.components.stackable and
                slot_item.components.stackable:StackSize() < slot_item.components.stackable.maxsize then
                return true
            end
        end
    end
    return false
end

-- 给予物品动作（按顺序给予非食物类物品）
local function GiveToPlayerAction(inst)
    -- 获取松鼠的物品栏
    local inventory = inst.components.inventory
    if not inventory then
        return nil
    end

    local leader = GetLeader(inst)
    if LeaderFull(inst) then
        -- 给予可堆叠的同类物品
        for i = 1, inventory.maxslots do
            local item = inventory:GetItemInSlot(i)
            if item and CanGiveToPlayer(inst, item) and not IsItemEdible(inst, item) then
                return BufferedAction(inst, leader, ACTIONS.GIVEALLTOPLAYER, item)
            end
        end
        inst.pickup_blocked = false
        return nil
    end

    -- 遍历所有物品栏位
    for i = 1, inventory.maxslots do
        local item = inventory:GetItemInSlot(i)
        if item and not IsItemEdible(inst, item) then
            return BufferedAction(inst, leader, ACTIONS.GIVEALLTOPLAYER, item)
        end
    end

    inst.pickup_blocked = false
    return nil
end

local function PlayerHasSameItem(leader, target)
    if not leader or not leader.components.inventory or not target then
        return false
    end
    
    local target_prefab = target.prefab
    
    -- 检查玩家物品栏中是否有相同prefab的物品
    for k, item in pairs(leader.components.inventory.itemslots) do
        if item and item.prefab == target_prefab then
            return true
        end
    end
    local backpack = leader.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if backpack and backpack.components.container then
        for i = 1, backpack.components.container:GetNumSlots() do
            local item = backpack.components.container:GetItemInSlot(i)
            if item and item.prefab == target_prefab then
                return true
            end
        end
    end
    return false
end
-- 拾取动作
local PICKUP_MUST_TAGS = {"_inventoryitem"}
local NO_PICKUP_TAGS = {"INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "outofreach", "spider", "piko", "trap", "_container", "smolder"}

local function PickupAction(inst)
    if inst.sg:HasStateTag("trapped") then
        return
    end

    if inst.components.inventory:NumItems() >= inst.components.inventory.maxslots or inst.pickup_blocked then
        inst.pickup_blocked = true
        return GiveToPlayerAction(inst)
    else
        -- 搜索范围内所有可拾取目标
        local x, y, z = inst.Transform:GetWorldPosition()
        local items = TheSim:FindEntities(x, y, z, SEE_STOLEN_ITEM_DIST, PICKUP_MUST_TAGS, NO_PICKUP_TAGS)
        local leader = GetLeader(inst)
        local nearest, nearest_dist = nil, nil

        for _, item in ipairs(items) do
            if (IsItemEdible(inst, item) or 
                (item.components.inventoryitem and
                not item.components.inventoryitem.owner and
                item.components.inventoryitem.canbepickedup and
                item:IsOnValidGround() and
                PlayerHasSameItem(leader, item) and
                not item.components.equippable)) then

                local dist = inst:GetDistanceSqToInst(item)
                if nearest == nil or dist < nearest_dist then
                    nearest = item
                    nearest_dist = dist
                end
            end
        end

        if nearest then
            return BufferedAction(inst, nearest, ACTIONS.PICKUP)
        end
    end
end

-- 吃东西动作
-- local function EatFoodAction(inst)
--     if not inst.components.inventory then
--         return
--     end
    
--     -- 从物品栏中找可吃的食物
--     for k, item in pairs(inst.components.inventory.itemslots) do
--         if IsItemEdible(inst, item) then
--             return BufferedAction(inst, item, ACTIONS.EAT)
--         end
--     end
-- end

local function ShouldRunFromScary(other, inst)
    local isplayer = other:HasTag("player")
    if isplayer and GetLeader(inst) == other then
        return false
    end

    local isplayerpet = isplayer and other.components.petleash and other.components.petleash:IsPet(inst)
    return (isplayer or isplayerpet) and TheNet:GetPVPEnabled()
end


-- local function PickUpFilter(inst, target, leader)
--     return PlayerHasSameItem(leader, target)
-- end

local PikoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local NORMAL_RUNAWAY_DATA = {tags = {"scarytoprey"}, fn = ShouldRunFromScary}

function PikoBrain:OnStart()

    -- local leader = GetLeader(self.inst)

    -- local ignorethese = nil
    -- if leader ~= nil then
    --     ignorethese = leader._brain_pickup_ignorethese or {}
    --     leader._brain_pickup_ignorethese = ignorethese
    -- end

    -- local pickupparams = {
    --     range = SEE_BAIT_MAXDIST,
    --     custom_pickup_filter = PickUpFilter,
    --     ignorethese = ignorethese,
    -- }
    
    local function ShouldRunAway(guy)
        return guy:HasTag("hostile") 
    end

    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),
        WhileNode(function() return GetLeader(self.inst).pets_standstill end, "Check Stand Still",
            StandStill(self.inst)),
        -- RunAway(self.inst, ShouldRunAway, AVOID_COMBAT_DIST, STOP_AVOID_COMBAT_DIST),
        RunAway(self.inst, NORMAL_RUNAWAY_DATA, AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        Follow(self.inst, GetLeader, FOLLOW_DISTANCE_MIN, FOLLOW_DISTANCE_TARGET, FOLLOW_DISTANCE_MAX),
        
        -- 优先吃自己保留的食物
        -- DoAction(self.inst, EatFoodAction, "eat food", true),
        
        -- 拾取物品
        DoAction(self.inst, PickupAction, "pick up item", true),
        
        -- 给予玩家非食物物品
        DoAction(self.inst, GiveToPlayerAction, "give to player", true),
        
        Wander(self.inst, GetLeaderLocation, MAX_WANDER_DIST),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return PikoBrain