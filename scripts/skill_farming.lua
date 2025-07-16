GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

local farming_cork_energy_consume_mult = tonumber(GetModConfigData("farming_cork_energy_consume_mult"))
local dig_penalty = tostring(GetModConfigData("dig_penalty"))

local CROP_PREFABS = {
    "corn",
    "onion",
    "pomegranate",
    "garlic",
    "tomato",
    "dragonfruit",
    "pumpkin",
    "pepper",
    "carrot",
    "durian",
    "watermelon",
    "eggplant",
    "asparagus",
    "potato",
    "pineananas",
}

local WEED_PREFABS = {
    "weed_forgetmelots",
    "weed_tillweed",
    "weed_ivy",
    "weed_firenettle",
    "farm_plant_randomseed",
}

local SEED_PREFABS = { "seeds" }
local FARM_PLANT_PREFABS = {
    "weed_forgetmelots",
    "weed_tillweed",
    "weed_ivy",
    "weed_firenettle",
    "farm_plant_randomseed",
}

for _, crop in ipairs(CROP_PREFABS) do
    SEED_PREFABS[#SEED_PREFABS + 1] = crop .. "_seeds"
    FARM_PLANT_PREFABS[#FARM_PLANT_PREFABS + 1] = "farm_plant_" .. crop
end

local function call_for_reinforcements(inst, target)
    if target ~= nil and not target:HasTag("plantkin") then
        local x, y, z = inst.Transform:GetWorldPosition()
        local defenders = TheSim:FindEntities(x, y, z, TUNING.FARM_PLANT_DEFENDER_SEARCH_DIST, {"farm_plant_defender"})
        for _, defender in ipairs(defenders) do
            if defender.components.burnable == nil or not defender.components.burnable.burning then
                defender:PushEvent("defend_farm_plant", {source = inst, target = target})
                break
            end
        end
    end
end

local function spawn_certain_seed(inst, plant_type)
    local x, y, z = inst.Transform:GetWorldPosition()
    -- 杂草种子
    if table.contains(WEED_PREFABS, plant_type) then
        local seed = SpawnPrefab("seeds")
        seed.Transform:SetPosition(x, y, z)
        inst.components.lootdropper:FlingItem(seed)
    -- 作物种子
    elseif inst.components.growable and inst.components.growable:GetStage() < 5 then
        -- 获取作物名称（去掉"farm_plant_"前缀）
        if not string.find(plant_type, "^[%a_]+$") then return end
        local crop_name = string.match(plant_type, "^farm_plant_(.+)$")
        if crop_name then
            local seed_prefab = crop_name .. "_seeds"
            if table.contains(SEED_PREFABS, seed_prefab) then
                local seed = SpawnPrefab(seed_prefab)
                seed.Transform:SetPosition(x, y, z)
                inst.components.lootdropper:FlingItem(seed)
            end
        end
    end
end

local function dig_up_seed(inst, worker)
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end

    call_for_reinforcements(inst, worker)

    if inst.components.growable ~= nil then
        local stage_data = inst.components.growable:GetCurrentStageData()
        if stage_data ~= nil and stage_data.dig_fx ~= nil then
            SpawnPrefab(stage_data.dig_fx).Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end

    if worker and worker.prefab == "wormwood" then
        if inst.prefab == "farm_plant_randomseed" then
            -- 处理随机种子    
            local plant_type = nil
            if inst.BeIdentified then
                plant_type = inst:BeIdentified(worker)
            end
            plant_type = inst._identified_plant_type or plant_type or "farm_plant_randomseed"
            spawn_certain_seed(inst, plant_type)
        else
            -- 处理明确种子和长出来的植株
            local plant_type = inst.prefab
            spawn_certain_seed(inst, plant_type)
        end
    end

    inst:Remove()
end

-- 挖植株可以还原为种子
for _, plant in ipairs(FARM_PLANT_PREFABS) do
    AddPrefabPostInit(plant, function(inst)
        if not TheWorld.ismastersim then return end
        inst.components.workable:SetOnFinishCallback(dig_up_seed)
    end)
end

local PLANT_PREFABS = {
    "sapling",
    "sapling_moon",
    "grass",
    "berrybush",
    "berrybush2",
    "berrybush_juicy",
    "rock_avocado_bush",
    "bananabush",
    "monkeytail",
    "lilybush",
    "rosebush",
    "orchidbush",
    "monstrain",
}

local function spawn_dug_plant(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    local dug_plant = SpawnPrefab("dug_" .. inst.prefab)
    dug_plant.Transform:SetPosition(x, y, z)
    inst.components.lootdropper:FlingItem(dug_plant)
end

-- 挖掘干枯植物不会将其摧毁
for _, plant in ipairs(PLANT_PREFABS) do
    AddPrefabPostInit(plant, function(inst)
        if not TheWorld.ismastersim then return end
        
        local workable = inst.components.workable
        if workable then
            local old_finish = workable.onfinish
            workable:SetOnFinishCallback(function(inst, worker)
                local withered = (inst.components.witherable ~= nil and inst.components.witherable:IsWithered())
                local barren = (inst.components.pickable ~= nil and inst.components.pickable:IsBarren())
                -- GLOBAL.TheNet:Announce("withered, barren: " .. tostring(withered) .. " " .. tostring(barren))
                if worker.prefab == "wormwood" and (withered or barren) then
                    -- GLOBAL.TheNet:Announce("妙手回春")
                    spawn_dug_plant(inst, worker)
                    inst:Remove()
                elseif old_finish then
                    old_finish(inst, worker)
                end
            end)
        end
    end)
end

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return end

    inst.extra_sanity_penalty = function(src, data)
        if data.doer == inst and data.workaction and data.workaction == ACTIONS.DIG then
            inst.components.sanity:DoDelta(-5)
        end
    end
    
    if dig_penalty == "true" then
        inst:ListenForEvent("plantkilled", inst.extra_sanity_penalty, TheWorld)
    end
end)

local _G = GLOBAL
local Vector3 = _G.Vector3

local containers = require "containers"
local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

params.wormwood_corkchest = 
{
    widget =
    {
        slotpos = {},
        animbank = "ui_largechest_5x5",
        animbuild = "ui_largechest_5x5",
        pos = Vector3(0, 200, 0),
    },
    type = "chest",
    itemtestfn = function(inst, item, slot) -- 容器里可以装的物品的条件
        return item.prefab == "nitre" 
        or (item.prefab == "saltrock" or item.prefab == "bluegem")
        or item.prefab == "moon_tree_blossom"
        or item.prefab == "lightbulb"
        -- or item.prefab == "butter"
        or item.prefab == "forgetmelots"
        or item.prefab == "tillweed"
        or item.prefab == "firenettles"
        or ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
		and item:HasTag("cookable")
		-- and not item:HasTag("deployable")
		and not item:HasTag("smallcreature")
		and item.replica.health == nil)
		or item:HasTag("saltbox_valid")
    end
}

for y = 1, 5 do
    for x = 1, 5 do
        table.insert(params.wormwood_corkchest.widget.slotpos, Vector3(80 * (x-3), 80 * (3-y), 0))
    end
end

params.wormwood_roottrunk = 
{
    widget =
    {
        slotpos = {},
        animbank = "ui_largechest_5x5",
        animbuild = "ui_largechest_5x5",
        pos = Vector3(0, 200, 0),
    },
    type = "chest",
    itemtestfn = function(inst, item, slot) -- 容器里可以装的物品的条件
        return item.components.edible and (item.components.edible.foodtype == FOODTYPE.SEEDS
            or item.components.edible.foodtype == FOODTYPE.VEGGIE)
    end
}

for y = 1, 5 do
    for x = 1, 5 do
        table.insert(params.wormwood_roottrunk.widget.slotpos, Vector3(80 * (x-3), 80 * (3-y), 0))
    end
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

-- 坐标系定义
local GRID_SIZE = 5  -- 5x5网格
local INDEX_OFFSET = 1 -- Lua表从1开始

-- 坐标转索引（支持多种输入格式）
local function PositionToIndex(x, y, gridSize)
    -- 参数处理
    local posX, posY
    gridSize = gridSize or GRID_SIZE
    
    -- 支持{x=1,y=2}格式
    if type(x) == "table" then
        posX, posY = x.x or x[1], x.y or x[2]
    else
        posX, posY = x, y
    end
    
    -- 边界检查
    assert(posX >= 1 and posX <= gridSize, "X坐标超出范围 (1-"..gridSize..")")
    assert(posY >= 1 and posY <= gridSize, "Y坐标超出范围 (1-"..gridSize..")")
    
    -- 计算公式（行优先存储）
    return (posY - 1) * gridSize + posX + INDEX_OFFSET - 1
end

-- 索引转坐标（返回table和x,y两种形式）
local function IndexToPosition(index, gridSize, asTable)
    gridSize = gridSize or GRID_SIZE
    index = index - INDEX_OFFSET
    
    -- 边界检查
    assert(index >= 0 and index < gridSize * gridSize, "索引超出范围")
    
    local x = index % gridSize + 1
    local y = math.floor(index / gridSize) + 1
    
    if asTable then
        return {x = x, y = y}
    else
        return x, y
    end
end

-- 图案存储结构示例
local PATTERN_DATABASE = {
    corn = {
        name = "玉米",
        -- 用二维数组表示完整网格
        grid = {
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
        },
        input_prefab = "corn",      -- 需要放入的作物
        output_prefab = "corn_seeds" -- 转换得到的种子
    },
    onion = {
        name = "洋葱",
        grid = {
            {1,0,1,0,1},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,0,1,0,0},
        },
        input_prefab = "onion",      
        output_prefab = "onion_seeds" 
    },
    pomegranate = {
        name = "石榴",
        grid = {
            {0,0,0,0,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "pomegranate",      
        output_prefab = "pomegranate_seeds" 
    },
    garlic = {
        name = "大蒜",
        grid = {
            {0,0,0,0,0},
            {0,0,1,0,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "garlic",      
        output_prefab = "garlic_seeds" 
    },
    tomato = {
        name = "番茄",
        grid = {
            {0,0,0,0,0},
            {0,1,0,1,0},
            {1,1,1,1,1},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "tomato",      
        output_prefab = "tomato_seeds" 
    },
    dragonfruit = {
        name = "火龙果",
        grid = {
            {0,0,1,0,0},
            {1,0,1,0,1},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
        },
        input_prefab = "dragonfruit",      
        output_prefab = "dragonfruit_seeds" 
    },
    pumpkin = {
        name = "南瓜",
        grid = {
            {0,0,1,0,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {1,1,1,1,1},
            {1,1,1,1,1},
        },
        input_prefab = "pumpkin",      
        output_prefab = "pumpkin_seeds" 
    },
    pepper = {
        name = "辣椒",
        grid = {
            {0,0,0,0,0},
            {1,0,0,0,1},
            {1,1,1,1,1},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "pepper",      
        output_prefab = "pepper_seeds" 
    },
    carrot = {
        name = "胡萝卜",
        grid = {
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,0,1,0,0},
            {0,0,1,0,0},
            {0,0,1,0,0},
        },
        input_prefab = "carrot",      
        output_prefab = "carrot_seeds" 
    },
    durian = {
        name = "榴莲",
        grid = {
            {0,0,1,0,0},
            {0,1,1,1,0},
            {1,1,1,1,1},
            {0,1,1,1,0},
            {0,0,1,0,0},
        },
        input_prefab = "durian",      
        output_prefab = "durian_seeds" 
    },
    watermelon = {
        name = "西瓜",
        grid = {
            {0,0,0,0,0},
            {0,1,1,1,0},
            {1,1,1,1,1},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "watermelon",      
        output_prefab = "watermelon_seeds" 
    },
    eggplant = {
        name = "茄子",
        grid = {
            {0,0,1,0,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
        },
        input_prefab = "eggplant",      
        output_prefab = "eggplant_seeds" 
    },
    asparagus = {
        name = "芦笋",
        grid = {
            {0,0,1,0,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,0,1,0,0},
        },
        input_prefab = "asparagus",      
        output_prefab = "asparagus_seeds" 
    },
    potato = {
        name = "土豆",
        grid = {
            {0,0,0,0,0},
            {0,1,1,1,0},
            {1,1,1,1,1},
            {1,1,1,1,1},
            {0,0,0,0,0},
        },
        input_prefab = "potato",      
        output_prefab = "potato_seeds" 
    },
    forgetmelots = {
        name = "必忘我转化普通种子",
        grid = {
            {0,0,0,0,0},
            {0,1,1,1,0},
            {0,1,0,1,0},
            {0,1,1,1,0},
            {0,0,0,0,0},
        },
        input_prefab = "forgetmelots",      
        output_prefab = "seeds" 
    },
    tillweed = {
        name = "犁地草转化硝石",
        grid = {
            {0,0,0,0,0},
            {0,0,1,0,0},
            {0,1,1,1,0},
            {0,0,1,0,0},
            {0,0,0,0,0},
        },
        input_prefab = "tillweed",      
        output_prefab = "nitre" 
    },
    pineananas = {
        name = "松萝",
        grid = {
            {1,0,1,0,1},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
            {0,1,1,1,0},
        },
        input_prefab = "pineananas",      
        output_prefab = "pineananas_seeds" 
    },
    saltrock = {
        name = "盐盒升级",
        grid = {
            {1,1,1,1,1},
            {1,1,1,1,1},
            {1,1,0,1,1},
            {1,1,1,1,1},
            {1,1,1,1,1},
        },
        input_prefab = "saltrock",
        output_prefab = nil
    },
}

-- 图案验证函数（支持多种存储格式）
local function ValidatePattern(patternName, corkchestGrid)
    local pattern = PATTERN_DATABASE[patternName]
    if not pattern then return false end
    
    -- 转换不同存储格式为统一比较格式
    local targetGrid = {}
    
    if pattern.grid then
        -- 二维数组格式
        for y=1, #pattern.grid do
            for x=1, #pattern.grid[y] do
                local idx = PositionToIndex(x, y)
                targetGrid[idx] = pattern.grid[y][x] == 1
            end
        end
    end
    
    -- 与实际根箱内容比较
    for idx=1, GRID_SIZE*GRID_SIZE do
        local shouldFill = targetGrid[idx]
        local actualItem = corkchestGrid[idx]
        
        -- 检查月树花位置
        if shouldFill and (not actualItem or actualItem.prefab ~= "moon_tree_blossom") then
            return false
        end
    end
    
    return true
end

-- 实用函数：打印图案可视化
local function PrintPattern(patternName)
    local pattern = PATTERN_DATABASE[patternName]
    if not pattern then return end
    
    print("图案: "..pattern.name)
    
    if pattern.grid then
        -- 二维数组打印
        for y=1, #pattern.grid do
            local line = ""
            for x=1, #pattern.grid[y] do
                line = line..(pattern.grid[y][x] == 1 and "M" or ".")
            end
            print(line)
        end
    end
    print("--------------")
end

local function OnClose(inst, doer)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)

        inst.SoundEmitter:PlaySound(inst.skin_close_sound or inst.close_sound or "dontstarve/wilson/chest_close")
    end

    -- GLOBAL.TheNet:Announce("inst.saltbox_upgrade: " .. tostring(inst.saltbox_upgrade))
    if inst.saltbox_upgrade == false then
        if inst.components and inst.components.container and doer and doer.prefab == "wormwood" then
            local has_salt = false
            local has_bluegem = false
            local salt_count = 0
            for i = 1, 25 do
                local item = inst.components.container.slots[i]
                if item then
                    if item.prefab == "saltrock" then
                        has_salt = true
                        salt_count = salt_count + item.components.stackable.stacksize
                    elseif item.prefab == "bluegem" then
                        has_bluegem = true
                    end
                end
            end
            doer:DoTaskInTime(0.5, function(doer)
                if not has_salt then
                    if math.random() < 0.1 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_salt_1)
                    elseif math.random() < 0.2 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_salt_2)
                    elseif math.random() < 0.3 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_salt_3)
                    elseif math.random() < 0.4 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_salt_4)
                    end
                elseif salt_count < 24 then
                    if math.random() < 0.5 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_more_salt_1)
                    else
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_more_salt_2)
                    end
                elseif salt_count >= 24 and not has_bluegem then
                    if math.random() < 0.5 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_bluegem_1)
                    else
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.need_bluegem_2)
                    end
                elseif salt_count >= 24 and has_bluegem then
                    if math.random() < 0.5 then
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.wrong_position_1)
                    else
                        doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.wrong_position_2)
                    end
                end
            end)
        end
    end
    if inst.saltbox_upgrade ~= inst.last_upgrade and inst.last_upgrade == false then
        doer:DoTaskInTime(0.5, function(doer)
            doer.components.talker:Say(STRINGS.WORMWOOD_CORKCHEST.upgrade_complete)
        end)
    end
end

AddPrefabPostInit("wormwood_corkchest", function(inst)
	if not TheWorld.ismastersim then
        return inst
    end
    
    inst.components.container.onclosefn = OnClose
    inst.is_converting = false -- 标记是否正在转换中

    -- 辅助函数：检查当前容器内容是否符合某个图案
    local function CheckPattern(container, pattern)
        local grid = pattern.grid

        if pattern.output_prefab ~= nil then
            -- 第一种情况：全部关键点都是 input_prefab
            local match1 = true
            for y = 1, 5 do
                for x = 1, 5 do
                    local slot = (y-1)*5 + x
                    local item = container.slots[slot]
                    if grid[y][x] == 1 then
                        if not item or item.prefab ~= pattern.input_prefab then
                            match1 = false
                            break
                        end
                    end
                end
                if not match1 then break end
            end
            if match1 then return 1 end

            -- 第二种情况：0位置是月树花，1位置是非目标种子
            local match2 = true
            for y = 1, 5 do
                for x = 1, 5 do
                    local slot = (y-1)*5 + x
                    local item = container.slots[slot]
                    if grid[y][x] == 0 then
                        if not item or item.prefab ~= "moon_tree_blossom" then
                            match2 = false
                            break
                        end
                    elseif grid[y][x] == 1 then
                        if pattern.name == "犁地草转化硝石" then
                            if not item or item.prefab ~= "tillweed" then
                                match2 = false
                                break
                            end
                        elseif item and item.prefab == pattern.output_prefab then
                            match2 = false
                            break
                        else
                            if not item or not item.components.edible or item.components.edible.foodtype ~= FOODTYPE.SEEDS then
                                match2 = false
                                break
                            end
                        end
                    end
                end
                if not match2 then break end
            end
            if match2 then return 2 end
        else
            local match3 = true
            for y = 1, 5 do
                for x = 1, 5 do
                    local slot = (y-1)*5 + x
                    local item = container.slots[slot]
                    if grid[y][x] == 1 then
                        if not item or item.prefab ~= "saltrock" then
                            match3 = false
                            break
                        end
                    end
                    if grid[y][x] == 0 then
                        if not item or item.prefab ~= "bluegem" then
                            match3 = false
                            break
                        end
                    end
                end
                if not match3 then break end
            end
            if match3 then return 3 end
        end

        return false
    end

    -- 计算月树花拥有的能量
    local function CalcBlossomEnergy(container, grid)
        local total_energy = 0
        local blossom_slots = {}
        for y = 1, 5 do
            for x = 1, 5 do
                if grid[y][x] == 0 then
                    local slot = (y-1)*5 + x
                    local item = container.slots[slot]
                    if item and item.prefab == "moon_tree_blossom" and item.components.perishable then
                        local stacksize = item.components.stackable and item.components.stackable:StackSize() or 1
                        local perish = item.components.perishable:GetPercent()
                        total_energy = total_energy + perish * stacksize
                        table.insert(blossom_slots, {slot=slot, item=item})
                    end
                end
            end
        end
        return total_energy, blossom_slots
    end

    local function PerformConversion(inst, pattern, mode)
        local container = inst.components.container
        local grid = pattern.grid
        
        -- GLOBAL.TheNet:Announce("Mode:" .. tostring(mode))
        if mode == 1 then
            for y = 1, 5 do
                for x = 1, 5 do
                    if grid[y][x] == 1 then
                        local slot = (y-1)*5 + x
                        local item = container.slots[slot]

                        -- 解开谜底
                        if item and item.prefab == pattern.input_prefab then
                            local new_seed = SpawnPrefab(pattern.output_prefab)
                            new_seed.components.stackable.stacksize = item.components.stackable.stacksize
                            if new_seed.components.perishable then
                                new_seed.components.perishable:SetPercent(item.components.perishable:GetPercent())
                            end
                            container:RemoveItemBySlot(slot):Remove()
                            container:GiveItem(new_seed, slot)
                        end
                    end
                    if grid[y][x] == 0 then
                        local slot = (y-1)*5 + x
                        local item = container.slots[slot]

                        -- 解开谜底
                        if item and item.prefab == pattern.input_prefab then
                            local new_blossom = SpawnPrefab("moon_tree_blossom")
                            new_blossom.components.stackable.stacksize = item.components.stackable.stacksize
                            if new_blossom.components.perishable then
                                new_blossom.components.perishable:SetPercent(item.components.perishable:GetPercent())
                            end
                            container:RemoveItemBySlot(slot):Remove()
                            container:GiveItem(new_blossom, slot)
                        end
                    end
                end
            end
        elseif mode == 2 then
            -- 1. 计算总能量和所有月树花位置
            local total_energy, blossom_slots = CalcBlossomEnergy(container, grid)

            -- 2. 收集所有待转化的种子位置
            local seeds_to_convert = {}
            for y = 1, 5 do
                for x = 1, 5 do
                    if grid[y][x] == 1 then
                        local slot = (y-1)*5 + x
                        local item = container.slots[slot]
                        if item and item.prefab ~= pattern.output_prefab then
                            table.insert(seeds_to_convert, {slot=slot, item=item})
                        end
                    end
                end
            end

            -- 3. 逐个消耗能量并转化
            local energy_per_seed = farming_cork_energy_consume_mult -- 例：每转化1个种子消耗0.25能量（你可自定义）
            if pattern.name == "犁地草转化硝石" then
                energy_per_seed = farming_cork_energy_consume_mult * 4
            end
            local converted = 0
            for _, seed in ipairs(seeds_to_convert) do
                if total_energy <= 0 then break end

                local stacksize = seed.item.components.stackable and seed.item.components.stackable:StackSize() or 1
                local perish = seed.item.components.perishable and seed.item.components.perishable:GetPercent() or 1

                -- 计算本组可转化数量
                local can_convert = math.floor(total_energy / energy_per_seed)
                -- if total_energy > 0 and can_convert == 0 then
                --     can_convert = 1 -- 能量不足一组也强制转化一个
                -- end
                local convert_num = math.min(stacksize, can_convert)
                if convert_num <= 0 then break end

                -- 移除原种子
                local removed = container:RemoveItemBySlot(seed.slot)
                if removed then
                    local remain = 0
                    if removed.components.stackable and removed.components.stackable:StackSize() > convert_num then
                        remain = removed.components.stackable:StackSize() - convert_num
                        removed.components.stackable:SetStackSize(convert_num)
                    end
                    removed:Remove()

                    -- 生成新种子
                    local new_seed = SpawnPrefab(pattern.output_prefab)
                    new_seed.components.stackable:SetStackSize(convert_num)
                    if new_seed.components.perishable then
                        new_seed.components.perishable:SetPercent(perish)
                    end
                    container:GiveItem(new_seed, seed.slot)

                    -- 剩余未转化的种子掉落在容器外
                    if remain > 0 then
                        local drop = SpawnPrefab(seed.item.prefab)
                        drop.components.stackable:SetStackSize(remain)
                        if drop.components.perishable then
                            drop.components.perishable:SetPercent(perish)
                        end
                        -- 掉落在箱子旁边
                        drop.Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst.components.lootdropper:FlingItem(drop)
                    end
                end

                total_energy = total_energy - energy_per_seed * convert_num
                converted = converted + convert_num
            end

            -- 4. 按照消耗量扣除月树花新鲜度
            local energy_to_consume = converted * energy_per_seed
            for _, b in ipairs(blossom_slots) do
                if energy_to_consume <= 0 then break end
                local item = b.item
                local stacksize = item.components.stackable and item.components.stackable:StackSize() or 1
                local perish = item.components.perishable:GetPercent()
                local this_energy = perish * stacksize
                if this_energy <= energy_to_consume then
                    container:RemoveItemBySlot(b.slot):Remove()
                    energy_to_consume = energy_to_consume - this_energy
                else
                    -- 只消耗部分新鲜度
                    local consume_percent = energy_to_consume / stacksize
                    item.components.perishable:ReducePercent(consume_percent)
                    energy_to_consume = 0
                end
            end
        elseif mode == 3 then
            local total_stack_saltrock = 0
            local total_stack_bluegem = 0
            for y = 1, 5 do
                for x = 1, 5 do
                    local slot = (y-1)*5 + x
                    local item = container.slots[slot]
                    if grid[y][x] == 1 then
                        total_stack_saltrock = total_stack_saltrock + item.components.stackable.stacksize
                    elseif grid[y][x] == 0 then
                        total_stack_bluegem = total_stack_bluegem + item.components.stackable.stacksize
                    end
                    container:RemoveItemBySlot(slot):Remove()
                end
            end
            total_stack_saltrock = total_stack_saltrock - 24
            if total_stack_saltrock > 0 then
                local saltrock = SpawnPrefab("saltrock")
                saltrock.components.stackable:SetStackSize(total_stack_saltrock)
                saltrock.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.components.lootdropper:FlingItem(saltrock)
            end

            total_stack_bluegem = total_stack_bluegem - 1
            if total_stack_bluegem > 0 then
            local bluegem = SpawnPrefab("bluegem")
                bluegem.components.stackable:SetStackSize(total_stack_bluegem)
                bluegem.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.components.lootdropper:FlingItem(bluegem)
            end
            
            inst.components.container:WidgetSetup("wormwood_corkchest")
	        inst.components.preserver:SetPerishRateMultiplier(0.25)
            inst.AnimState:SetBank("treasure_chest_cork_upgraded_32_20")
            inst.AnimState:SetBuild("treasure_chest_cork_upgraded_32_20")
            inst.saltbox_upgrade = true
            -- fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end

        -- fx
        if mode == 1 or mode == 2 then
            local fx = SpawnPrefab("fx_book_bees")
            fx.entity:SetParent(inst.entity)
            fx.Transform:SetPosition(0, 0, 0)
            fx.Transform:SetScale(1.25, 1.25, 1.25)
        elseif mode == 3 then
            local fx = SpawnPrefab("small_puff")
            fx.entity:SetParent(inst.entity)
            fx.Transform:SetPosition(0, 0, 0)
            fx.Transform:SetScale(2, 2, 2)
        end

        inst.is_converting = false
    end

	inst:ListenForEvent("itemget",function(inst,data) 
        if inst.is_converting then return end
        -- GLOBAL.TheNet:Announce("检测到物品: "..data.item.name)
        local container = inst.components.container
        if not container or not container.slots then return end
        
        -- 检查是否所有格子都已填满
        local is_full = true
        -- GLOBAL.TheNet:Announce("正在检查容器是否已满...")
        for i = 1, 25 do
            if not container.slots[i] then
                is_full = false
                break
            end
        end
        
        if is_full then
            -- 检查所有已知图案
            -- GLOBAL.TheNet:Announce("容器已满，开始检查图案...")
            for pattern_name, pattern_data in pairs(PATTERN_DATABASE) do
                local mode = CheckPattern(container, pattern_data)
                -- GLOBAL.TheNet:Announce("正在检查图案: "..pattern_name)
                if mode then
                    -- GLOBAL.TheNet:Announce("匹配到图案: "..pattern_name)
                    inst.is_converting = true
                    PerformConversion(inst, pattern_data, mode)
                    break -- 每次只匹配一个图案
                end
            end
        end
    end)
end)

-- 使用示例
-- print("玉米图案:")
-- PrintPattern("corn")

-- -- 坐标转换测试
-- local testPos = {x=2, y=3}
-- local index = PositionToIndex(testPos)
-- print(string.format("坐标(%d,%d) → 索引%d", testPos.x, testPos.y, index))

-- local x, y = IndexToPosition(index)
-- print(string.format("索引%d → 坐标(%d,%d)", index, x, y))

-- 验证测试
-- local mockGrid = {
--     [PositionToIndex(3,1)] = {prefab="moon_tree_blossom"},
--     [PositionToIndex(2,2)] = {prefab="moon_tree_blossom"},
--     -- ...其他关键点
-- }

-- print("验证玉米图案:", ValidatePattern("corn", mockGrid))

