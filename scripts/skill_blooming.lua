-- 主要为开花线的内容，但也含有一些其他技能线中涉及开花的内容
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

local moon_charged_1_time = tonumber(GetModConfigData("moon_charged_1_time"))
local moon_charged_2_time = tonumber(GetModConfigData("moon_charged_2_time"))

local fertilizer_healing_multi = tonumber(GetModConfigData("fertilizer_healing_multi"))
local photosynthesis_light_healing_multi = tonumber(GetModConfigData("photosynthesis_light_healing_multi"))
local photosynthesis_moisture_consume_multi = tonumber(GetModConfigData("photosynthesis_moisture_consume_multi"))
local photosynthesis_moisture_healing_multi = tonumber(GetModConfigData("photosynthesis_moisture_healing_multi"))
local photosynthesis_timer_multi = tonumber(GetModConfigData("photosynthesis_timer_multi"))
local photosynthesis_energy_cost_multi = tonumber(GetModConfigData("photosynthesis_energy_cost_multi"))
local overheatprotection_buff_multi = tonumber(GetModConfigData("overheatprotection_buff_multi"))
local lunartree_consume_val = tonumber(GetModConfigData("lunartree_consume_val"))
local lunartree_healing_multi = tonumber(GetModConfigData("lunartree_healing_multi"))
local opalstaff_frozen_consume_val = tonumber(GetModConfigData("opalstaff_frozen_consume_val"))
local opalstaff_frozen_exist_val = tonumber(GetModConfigData("opalstaff_frozen_exist_val"))
local opalstaff_summon_consume_val = tonumber(GetModConfigData("opalstaff_summon_consume_val"))
local opalstaff_summon_exist_val = tonumber(GetModConfigData("opalstaff_summon_exist_val"))
local pets_damage_absorb = tonumber(GetModConfigData("pets_damage_absorb"))
local pets_healing_multi_base = tonumber(GetModConfigData("pets_healing_multi_base"))

local butter_produce_need = 100 * photosynthesis_timer_multi / 2.5
local butterfly_produce_need = 85 * photosynthesis_timer_multi / 2.5
local moonbutterfly_produce_need = 125 * photosynthesis_timer_multi / 2.5
    
-- 月相加成配置表
local MOON_PHASE_BONUS = {
    new = 1,
    quarter = 1.03,
    half = 1.05,
    threequarter = 1.07,
    full = 1.10,
}

-- 获取当前月相加成
local function GetMoonPhaseBonus()
    local phase = TheWorld.state.moonphase or 0
    return MOON_PHASE_BONUS[phase] or 0
end

-- 尝试根据月相强化沃姆伍德月亮亲和效果，但是有 bug
AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return inst end

    inst:WatchWorldState("isnight", function(inst)
        if not inst:HasTag("farmplantidentifier") then return end
        inst:DoTaskInTime(5, function(inst)
            if TheWorld.state.isday then return end
            local bonus = GetMoonPhaseBonus()
            -- 移除旧效果
            inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "night_bonus")       -- 确保旧 buff 移除
            inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "night_bonus")
            
            -- 应用新效果
            inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, bonus, "night_bonus")
            inst.components.damagetyperesist:AddResist("lunar_aligned", inst, bonus, "night_bonus")
            -- GLOBAL.TheNet:Announce("夜晚加成添加" .. GetMoonPhaseBonus())
        end)
    end)

    inst:WatchWorldState("isday", function(inst)
        if not inst:HasTag("farmplantidentifier") then return end
        inst:DoTaskInTime(5, function(inst)
            inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "night_bonus")
            inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "night_bonus")
            
        end)
    end)
end)

-- 激活光合作用技能后，玩家在光照条件下，如白天、黄昏或者在矮星附近时，能够获得能量，默认情况下，沃姆伍德在白天每秒获得 0.25 的能量，若激活了Nohatbonus技能，则每秒获得0.5的能量，获得的能量将根据任务优先级流向不同的地方，以下是这些任务的优先级。
-- 1. 沃姆伍德生命值不满时，将全部能量用于恢复生命值，该功能已在脚本中基本实现。
-- 2. 沃姆伍德开花值低于 1800 点时，将全部能量用于恢复开花值。
-- 沃姆伍德开花值处于 1800 ~ 3600点时，最多将一半的能量供给其他地方，开花值到达上限（高于3550）时，可将全部能量用于供能其他地方：
-- 3. 给物品栏和背包栏中的注能月树花和月蛾供能，每一片注能月树花需要 0.010 的能量，每只月蛾需要 0.001 的能量，每秒为它恢复新鲜度。
-- 4. 给装备栏中的荆棘魔杖(ivystaff)和各类蘑菇帽供能(mushroomhat)，每个装备需要 0.005 的能量，每秒为它恢复新鲜度。
-- 5. 给召唤的随从供能，使其存活计时器和位面属性计时器暂停，不同的随从所需能量不同，以下是对应的需要能量的列表
-- (1)胡萝卜鼠（默认数量4个）：0.001
-- (2)球状光虫（默认数量6个）、松鼠（默认数量2个）：0.002
-- (3)沙拉蝾螈（默认数量2个）：0.005
-- (4)草鳄鱼（默认数量1个）：0.010
-- (5)捕蝇草（默认数量3个）、曼德拉长者（默认数量4个）：0.005
-- 当随从获得注能状态时，它的供能需求提高额外 50%。当没有多余能量分配给某一名随从时，继续它的存活计时器和位面属性计时器
-- 6. 将剩下的可分配能量全部用于产出黄油，每秒进入producebutter函数中结算
-- 通常情况下，任务3~4基本可一直保持供能，而任务5可能会出现负载过高无法完全供能的问题，任务6可能因为无可分配能量而停止运行。

-- MOONGLASS_CHARGED_PERISH_TIME = total_day_time*1.5,
-- PERISH_ONE_DAY = 1*total_day_time*perish_warp,
-- PERISH_TWO_DAY = 2*total_day_time*perish_warp,
-- PERISH_SUPERFAST = 3*total_day_time*perish_warp,
-- PERISH_FAST = 6*total_day_time*perish_warp,
-- PERISH_FASTISH = 8*total_day_time*perish_warp,
-- PERISH_MED = 10*total_day_time*perish_warp,
-- PERISH_SLOW = 15*total_day_time*perish_warp,
-- PERISH_PRESERVED = 20*total_day_time*perish_warp,
-- PERISH_SUPERSLOW = 40*total_day_time*perish_warp,

local ENERGY_COST = {
    moon_tree_blossom_charged = 0.010 * photosynthesis_energy_cost_multi,
    low_cost_item = 0.001 * photosynthesis_energy_cost_multi,

    ivystaff = 0.005 * photosynthesis_energy_cost_multi,
    mushroomhat = 0.005 * photosynthesis_energy_cost_multi,

    wormwood_carrat = 0.001 * photosynthesis_energy_cost_multi,
    wormwood_lightflier = 0.002 * photosynthesis_energy_cost_multi,
    wormwood_piko = 0.002 * photosynthesis_energy_cost_multi,
    wormwood_piko_orange = 0.002 * photosynthesis_energy_cost_multi,
    wormwood_fruitdragon = 0.005 * photosynthesis_energy_cost_multi,
    wormwood_grassgator = 0.010 * photosynthesis_energy_cost_multi,
    wormwood_flytrap = 0.005 * photosynthesis_energy_cost_multi,
    wormwood_mandrakeman = 0.005 * photosynthesis_energy_cost_multi,
}

local function NoHatBonus(inst) -- 获取无帽增益
    local NoHatBonus = 1
    -- 检查是否有头部防具

    if inst:HasTag("wormwood_blooming_overheatprotection") and inst.components.inventory then
        local hat = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
        if not hat or hat.prefab == "alterguardianhat" then
            NoHatBonus = overheatprotection_buff_multi 
        else
            NoHatBonus = 1
        end
    end
    return NoHatBonus
end

local function GetBuddingBonus(inst) -- 获取当前萌芽增益，用于乘算
    -- 根据开花等级和标签计算增益
    local level = inst.components.bloomness:GetLevel()
    local level_bonus = {
        [3] = 1.0,
        [2] = inst:HasTag("wormwood_blooming_farmrange1") and 0.5 or 0,
        [1] = inst:HasTag("wormwood_blooming_farmrange1") and 0.25 or 0,
        [0] = 0
    }

    return (level_bonus[level] or 0) 
end

AddPrefabPostInit("petals", function(inst)
    if not TheWorld.ismastersim then return end

    local function OnEatPetals(inst, eater)
        if eater:HasTag("moon_charged_1") then
            eater:RemoveTag("moon_charged_1")
            eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.lose_moon_charged_1)
        end
        if eater:HasTag("moon_charged_2") then
            eater:RemoveTag("moon_charged_2")
            eater.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
            eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.lose_moon_charged_2)
        end
    end

    inst.components.edible:SetOnEatenFn(OnEatPetals)

end)

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return end

    inst.last_bloomness = 0
    inst.current_bloomness = 0
    inst.bloomness_timer_delta = 0
end)

local function FormatDelta(delta, len)
    -- 默认格式化为3位小数
    len = len or 3
    local fmt = "%." .. tostring(len) .. "f"
    local str = string.format(fmt, delta)
    
    -- 移除末尾的0（保留到第二位）
    str = str:gsub("0$", ""):gsub("%.$", "")
    
    -- 确保至少有2位小数
    if not str:find("%.") then
        return str .. ".00"
    elseif #str:match("%.(.*)$") == 1 then
        return str .. "0"
    end
    return str
end

AddPrefabPostInit("moon_tree_blossom", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local function OnEatMoontree_blossom(inst, eater)
        if not eater.components.bloomness or eater.components.bloomness.level < 3 then return end 
        if eater:HasTag("farmplantidentifier") then
            -- 取消现有任务
            if eater.mooncharge_1_task then 
                eater.mooncharge_1_task:Cancel()
                eater.mooncharge_1_task = nil
            end
            
            if eater:HasTag("moon_charged_2") then 
                eater:RemoveTag("moon_charged_2")
                eater.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
            end
            eater:AddTag("moon_charged_1")
            
            -- 显示对话（如果有talker组件）
            if eater.components.talker then
                eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.get_moon_charged_1)
            end
            
            -- 设置定时取消效果
            eater.mooncharge_1_task = eater:DoTaskInTime(moon_charged_1_time, function(inst)
                if eater:HasTag("moon_charged_1") then
                    eater:RemoveTag("moon_charged_1")
                    eater.mooncharge_1_task = nil
                    if not eater:HasTag("moon_charged_2") then
                        eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.lose_moon_charged_1)
                    end
                end
            end)
        end
    end

    inst.components.edible:SetOnEatenFn(OnEatMoontree_blossom)


    -- 保存原始检查函数
    local old_inspect_fn = inst.components.inspectable.GetStatus
    
    inst.components.inspectable.GetStatus = function(inst, viewer)
        local status = old_inspect_fn and old_inspect_fn(inst, viewer) or ""

        if viewer and viewer.prefab == "wormwood" then
            viewer:DoTaskInTime(FRAMES, function()
                local report_delta = ""
                if viewer.bloomness_timer_delta >= 0 then
                    report_delta = "+"
                else
                    report_delta = ""
                end

                if viewer:HasTag("wormwood_blooming_max_upgrade") then
                    if viewer.components.bloomness.timer < 3590 then
                        viewer.components.talker:Say(STRINGS.MOON_TREE_BLOSSOM_INSPECT.bloom_point .. FormatDelta(viewer.components.bloomness.timer, 2) .. 
                            "(" .. report_delta .. FormatDelta(viewer.bloomness_timer_delta, 4) .. "/s)" .. 
                            STRINGS.MOON_TREE_BLOSSOM_INSPECT.butter_produce .. FormatDelta(viewer.butter_produce, 3) .. "/" .. FormatDelta(butter_produce_need, 2) ..
                            "(+" .. FormatDelta(viewer.butter_produce_vel, 4) .. "/s)")
                    else
                        viewer.components.talker:Say(STRINGS.MOON_TREE_BLOSSOM_INSPECT.bloom_point_max .. FormatDelta(viewer.components.bloomness.timer, 2) .. 
                            "(" .. report_delta .. FormatDelta(viewer.bloomness_timer_delta, 4) .. "/s)" .. 
                            STRINGS.MOON_TREE_BLOSSOM_INSPECT.butter_produce .. FormatDelta(viewer.butter_produce, 3) .. "/" .. FormatDelta(butter_produce_need, 2) .. 
                            "(+" .. FormatDelta(viewer.butter_produce_vel, 4) .. "/s)")
                    end
                else
                    if viewer.components.bloomness.timer < 2390 then
                        viewer.components.talker:Say(STRINGS.MOON_TREE_BLOSSOM_INSPECT.bloom_point .. FormatDelta(viewer.components.bloomness.timer, 2) .. 
                            "(" .. report_delta .. FormatDelta(viewer.bloomness_timer_delta, 4) .. "/s)")
                    else
                        viewer.components.talker:Say(STRINGS.MOON_TREE_BLOSSOM_INSPECT.bloom_point_max .. FormatDelta(viewer.components.bloomness.timer, 2) .. 
                            "(" .. report_delta .. FormatDelta(viewer.bloomness_timer_delta, 4) .. "/s)")
                    end
                end
            end)
        end
        
        return status
    end

end)

AddPrefabPostInit("moon_tree_blossom_charged", function(inst)
    if not TheWorld.ismastersim then return end

    local function OnEatenFn(inst, eater)
        if not eater.components.bloomness or eater.components.bloomness.level < 3 then return end 
        if eater:HasTag("farmplantidentifier") then
            -- 取消现有任务
            if eater.mooncharge_2_task then 
                eater.mooncharge_2_task:Cancel()
                eater.mooncharge_2_task = nil
            end
            
            if eater:HasTag("moon_charged_1") then 
                eater:RemoveTag("moon_charged_1")
            end
            eater:AddTag("moon_charged_2")
            eater.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            -- eater.Light:SetColour(111/255, 111/255, 227/255)
            -- eater.Light:SetIntensity(0.75)
            -- eater.Light:SetFalloff(0.25)
            -- eater.Light:SetRadius(1)
            -- eater.Light:Enable(true)
            
            -- 显示对话（如果有talker组件）
            if eater.components.talker then
                eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.get_moon_charged_2)
            end
            
            -- 设置定时取消效果
            eater.mooncharge_2_task = eater:DoTaskInTime(moon_charged_2_time, function(inst)
                if eater:HasTag("moon_charged_2") then
                    eater:RemoveTag("moon_charged_2")
                    eater.mooncharge_2_task = nil
                    eater.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
                    eater.components.talker:Say(STRINGS.WORMWOOD_SKILL.lose_moon_charged_2)
                    -- eater.Light:Enable(false)
                end
            end)
        end
    end

    inst.components.edible:SetOnEatenFn(OnEatenFn)
end)

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return end

    ------------------------ 施肥收益增加 ------------------------

    local old_OnFertilizedWithFormula = inst.OnFertilizedWithFormula
    inst.OnFertilizedWithFormula = function(inst, value) -- 将施肥加速30%技能整合到一技能
        if value > 0 and inst.components.bloomness then
            if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wormwood_quick_selffertilizer")
                and not inst:HasTag("wormwood_blooming_max_upgrade") then
                value = value * 1.3
            end
            -- GLOBAL.TheNet:Announce("泥嚎")
            inst.components.bloomness:Fertilize(value)
        end
    end

    inst.OnFertilizedWithCompost = function(inst, value) -- 提高堆肥回血量
        if value > 0 and inst.components.health and not inst.components.health:IsDead() then
            local healing = TUNING.WORMWOOD_COMPOST_HEAL_VALUES[math.ceil(value / 8)] or TUNING.WORMWOOD_COMPOST_HEAL_VALUES[1]
            if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wormwood_quick_selffertilizer") then
                healing = healing * fertilizer_healing_multi
            end
            inst:AddDebuff("compostheal_buff", "compostheal_buff", {duration = healing * (TUNING.WORMWOOD_COMPOST_HEALOVERTIME_TICK/TUNING.WORMWOOD_COMPOST_HEALOVERTIME_HEALTH)})
            -- GLOBAL.TheNet:Announce("泥嚎")
        end
    end

    inst.OnFertilizedWithManure = function(inst, value, src) -- 提高粪肥回血量
        if value > 0 and inst.components.bloomness then
            local healing = TUNING.WORMWOOD_MANURE_HEAL_VALUES[math.ceil(value / 8)] or TUNING.WORMWOOD_MANURE_HEAL_VALUES[1]
            if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wormwood_quick_selffertilizer") then
                healing = healing * fertilizer_healing_multi
            end
            inst.components.health:DoDelta(healing, false, src.prefab)
            -- GLOBAL.TheNet:Announce("泥嚎")
        end
    end
    
    ---------------------------------------------------------------------------
    
    
    ------------------------ 开花速度提升，花苞阶段加移速 ------------------------
    -- “急不可耐”技能的部分代码已移动至 inst.stat_check_task 计时器中实现

    inst.ExternalSpeedMutiply = function(inst)
        if inst:HasTag("wormwood_blooming_farmrange1") and inst.components.locomotor then
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "bloom_speed")
            -- GLOBAL.TheNet:Announce("技能判断通过")
            local base_speed = TUNING.WILSON_RUN_SPEED
            local speed_bonus = 1
            local stage = inst.components.bloomness.level

            -- 根据开花阶段设置加成
            if stage == 0 then
                speed_bonus = 0
            elseif stage == 1 then
                speed_bonus = 0.05  -- 5%
            elseif stage == 2 then
                speed_bonus = 0.15   -- 15%
            else
                speed_bonus = 0.25     
            end
            -- GLOBAL.TheNet:Announce("加成设置完毕")
            
            -- 应用移速修改（保留其他可能的移速加成）
            if stage < 2 then
                -- GLOBAL.TheNet:Announce("应用花苞移速加成")
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "bloom_speed", 1 + speed_bonus * NoHatBonus(inst))
            elseif stage == 2 then
                -- GLOBAL.TheNet:Announce("应用花苞移速加成")
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "bloom_speed", (1 + speed_bonus * NoHatBonus(inst)) / 1.15) -- 修正二阶段移速
            elseif stage == 3 then
                -- GLOBAL.TheNet:Announce("应用开花移速加成")
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "bloom_speed", (1 + speed_bonus * NoHatBonus(inst)) / 1.25) -- 修正三阶段移速
            end
            -- GLOBAL.TheNet:Announce("移速加成应用完毕")
        end
        -- GLOBAL.TheNet:Announce("更新结束")
    end
    
    local old_onlevelchangedfn = inst.components.bloomness.onlevelchangedfn
    inst.components.bloomness.onlevelchangedfn = function(inst, stage)
        -- GLOBAL.TheNet:Announce("触发 onlevelchangedfn ")
        if old_onlevelchangedfn then
            old_onlevelchangedfn(inst, stage)
        end

        -- 更新沃姆伍德移速
        inst:ExternalSpeedMutiply()

        -- 更新荆棘魔杖移速
        local staff = inst.components.inventory and inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
        if staff and staff.prefab == "ivystaff" and inst:HasTag("wormwood_thorn_ivystaff") then
            if inst.components.bloomness.level == 3 then
                staff.components.equippable.walkspeedmult = 1.25
            elseif inst.components.bloomness.level == 2 then
                staff.components.equippable.walkspeedmult = 1.15
            elseif inst.components.bloomness.level == 1 then
                staff.components.equippable.walkspeedmult = 1.12
            else
                staff.components.equippable.walkspeedmult = 1.10
            end
        end
    end
    -------------------------------------------------------------------------------

    
    ---------------------- 光合作用、供能系统、食物回复开花值 ------------------------
    inst.energy_from_mothling = 0
    inst.unused_energy = 0
    inst.butter_produce_vel = 0

    inst.butter_produce = 0
    inst.butterfly_produce= 0
    inst.moonbutterfly_produce = 0
    -- 退出时需要存储 butter_produce 等的值
    local function producebutter(inst, energy_input)
        if inst.components.bloomness.timer < 1800 or energy_input <= 0 then 
            return 0 
        end

        local k_butter = 0
        local k_butterfly = 0
        local k_moonbutterfly = 1
        if inst.components.bloomness.timer > 3590 then
            k_butter = 1
        elseif inst.components.bloomness.timer > 3000 then
            k_butter = 0.5
        elseif inst.components.bloomness.timer > 2400 then
            k_butter = 0.25
        elseif inst.components.bloomness.timer > 1800 then
            k_butter = 0.10
        end

        inst.butter_produce = inst.butter_produce + energy_input * k_butter
        if inst.butter_produce > butter_produce_need then
           inst.butter_produce = inst.butter_produce - butter_produce_need + math.random() * 25 * (-1) ^ math.random(1, 2)
            if inst.components.inventory then
                local butter = SpawnPrefab("butter")  -- 生成黄油
                inst.components.inventory:GiveItem(butter)  -- 放入物品栏
            end
        end

        -- GLOBAL.TheNet:Announce(string.format(
        --     "黄油值：%.2f 蝴蝶值：%.2f 月蛾值：%.2f 月蛾数：%d 系数：%.2f energy_input：%.2f", 
        --     inst.butter_produce,
        --     inst.butterfly_produce,
        --     inst.moonbutterfly_produce,
        --     moonbutterfly_num,
        --     k_moonbutterfly,
        --     energy_input
        -- ))
        local energy_output = energy_input - energy_input * k_butter
        return energy_output
    end

    local function producebutterfly(inst, timer_delta)
        local k_butterfly = 0
        local k_moonbutterfly = 1
        if inst.components.bloomness.timer > 3590 then
            k_butterfly = 1
            -- k_moonbutterfly = 1
        elseif inst.components.bloomness.timer > 3000 then
            k_butterfly = 0.5
            -- k_moonbutterfly = 0.9
        elseif inst.components.bloomness.timer > 2400 then
            k_butterfly = 0.25
            -- k_moonbutterfly = 0.8
        elseif inst.components.bloomness.timer > 1800 then
            k_butterfly = 0.10
        --     k_moonbutterfly = 0.5
        end

        inst.butterfly_produce = inst.butterfly_produce + timer_delta * k_butterfly
        if inst.butterfly_produce > butterfly_produce_need then
           inst.butterfly_produce = inst.butterfly_produce - butterfly_produce_need + math.random() * 25 * (-1) ^ math.random(1, 2)
            local butterfly = SpawnPrefab("butterfly")
            butterfly.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end

        if not inst:HasTag("wormwood_blooming_lunartree") then return end
        local moonbutterfly_num = 0
        for i = 1, inst.components.inventory:GetNumSlots() do
            local item = inst.components.inventory:GetItemInSlot(i)
            if item and item.prefab == "moonbutterfly" then
                moonbutterfly_num = moonbutterfly_num + item.components.stackable:StackSize()
            end
        end

        local backpack = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
        if backpack and backpack.components.container then
            for i = 1, backpack.components.container:GetNumSlots() do
                local item = backpack.components.container:GetItemInSlot(i)
                if item and item.prefab == "moonbutterfly" then
                    moonbutterfly_num = moonbutterfly_num + item.components.stackable:StackSize()
                end 
            end
        end

        k_moonbutterfly = (k_moonbutterfly / (1 + moonbutterfly_num)) ^ 2
        inst.moonbutterfly_produce = inst.moonbutterfly_produce + timer_delta * k_moonbutterfly
        if inst.moonbutterfly_produce > moonbutterfly_produce_need then
            inst.moonbutterfly_produce = inst.moonbutterfly_produce - moonbutterfly_produce_need + math.random() * 25 * (-1) ^ math.random(1, 2)
            local moonbutterfly = SpawnPrefab("moonbutterfly")
            moonbutterfly.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end

        -- GLOBAL.TheNet:Announce(string.format(
        --     "黄油值：%.2f 蝴蝶值：%.2f 月蛾值：%.2f 月蛾数：%d 系数：%.2f timer_delta：%.2f", 
        --     inst.butter_produce,
        --     inst.butterfly_produce,
        --     inst.moonbutterfly_produce,
        --     moonbutterfly_num,
        --     k_moonbutterfly,
        --     timer_delta
        -- ))
    end

    -- 在角色初始化代码中（如 master_postinit）
    local old_OnSave = inst.OnSave  -- 保存原有函数
    local old_OnLoad = inst.OnLoad

    inst.OnSave = function(inst, data)
        -- 先执行原有保存逻辑
        if old_OnSave then
            old_OnSave(inst, data)
        end
        
        -- 添加新数据存储
        data.butter_produce = inst.butter_produce
        data.butterfly_produce = inst.butterfly_produce
        data.moonbutterfly_produce = inst.moonbutterfly_produce
    end

    inst.OnLoad = function(inst, data)
        -- 先执行原有加载逻辑
        if old_OnLoad then
            old_OnLoad(inst, data)
        end
        
        -- 恢复新数据
        if data then
            inst.butter_produce = data.butter_produce or 0
            inst.butterfly_produce = data.butterfly_produce or 0
            inst.moonbutterfly_produce = data.moonbutterfly_produce or 0
        end
    end

    -- 该计时器管理多个技能
    inst.stat_check_task = inst:DoPeriodicTask(1, function() 
        local bloomness = inst.components.bloomness
        inst.current_bloomness = bloomness.timer
        inst.bloomness_timer_delta = inst.current_bloomness - inst.last_bloomness
        inst.last_bloomness = inst.current_bloomness 

        local bloom_percent = 0
        -- 计算开花百分比（0~1）
        if inst.components.bloomness.level == 3 then
            bloom_percent = inst.components.bloomness.timer / 3600
        elseif inst.components.bloomness.level > 0 then
            -- 开花阶段1或2：使用 stage_duration 计算
            bloom_percent = inst.components.bloomness.timer / inst.components.bloomness.stage_duration
        end

        if inst.components.bloomness.level == 3 then
            -- 设置物品栏中月树花的新鲜度为开花百分比
            for i = 1, inst.components.inventory:GetNumSlots() do
                local item = inst.components.inventory:GetItemInSlot(i)
                if item and item.prefab == "moon_tree_blossom" then
                    -- 设置月树花和月蛾的新鲜度为开花百分比
                    if item.components.perishable then
                        item.components.perishable:SetPercent(bloom_percent)
                    end
                end
            end

            -- 设置背包栏中月树花的新鲜度为开花百分比
            local backpack = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
            if backpack and backpack.components.container then
                for i = 1, backpack.components.container:GetNumSlots() do
                    local item = backpack.components.container:GetItemInSlot(i)
                    if item and item.prefab == "moon_tree_blossom" then
                        -- 设置月树花的新鲜度为开花百分比
                        if item.components.perishable then
                            item.components.perishable:SetPercent(bloom_percent)
                        end
                    end
                end
            end
        end

        -- 监听潮湿度变化，加速开花
        if inst:HasTag("wormwood_blooming_farmrange1") and bloomness.level > 0 and bloomness.level ~= 3 then

            local daytime_bonus = 0          
            if not TheWorld:HasTag("cave") then 
                if TheWorld.state.isday then
                    daytime_bonus = 0.5
                elseif TheWorld.state.isdusk then
                    daytime_bonus = 0.25 
                else
                    daytime_bonus = 0
                end
            end

            -- 计算矮星加成
            local stafflight_bonus = 0
            local x, y, z = inst.Transform:GetWorldPosition()     
            if daytime_bonus < 0.5 then                                   -- 自然光与矮星不叠加
                for k, v in pairs(TheSim:FindEntities(x, y, z, 20)) do
                    if v.prefab == "stafflight" then
                        stafflight_bonus = 0.5
                        break
                    end
                end
            end

            local moisture_bonus = 0
            if inst.components.moisture:GetMoisture() > 0 and (daytime_bonus + stafflight_bonus > 0) then
                moisture_bonus = inst.components.moisture:GetMoisture() * 0.005
            end

            local season_mult = 1
            if TheWorld.state.season == "spring" then
                season_mult = TUNING.WORMWOOD_SPRING_BLOOM_MOD
            elseif TheWorld.state.season == "winter" then
                season_mult = TUNING.WORMWOOD_WINTER_BLOOM_MOD
            end

            bloomness.rate = season_mult * (1 + bloomness.fertilizer * TUNING.WORMWOOD_FERTILIZER_RATE_MOD + moisture_bonus + daytime_bonus + stafflight_bonus)
            -- GLOBAL.TheNet:Announce("潮湿度:" .. tostring(inst.components.moisture:GetMoisture()))
            -- GLOBAL.TheNet:Announce("潮湿增益:" .. tostring(moisture_bonus) .. " 光照增益：" .. tostring(daytime_bonus) .. " 季节增益：" .. tostring(season_mult))
            -- GLOBAL.TheNet:Announce("开花速率:" .. tostring(inst.components.bloomness.rate) .. " 时间: " .. tostring(GetTime()))
        end


        -- ====================== 供能系统核心逻辑 ======================
        if inst:HasTag("wormwood_blooming_max_upgrade") then       -- 根据潮湿度和光照回复血量和开花值
            -- GLOBAL.TheNet:Announce("时间：" .. tostring(GetTime()))
                
            -- 计算每秒获得的能量
            -- 计算自然日光加成
            local daytime_bonus = 0
            if not TheWorld:HasTag("cave") then           -- 洞穴世界无自然光加成
                if TheWorld.state.isday then 
                    daytime_bonus = 0.10              
                elseif TheWorld.state.isdusk then
                    daytime_bonus = 0.05
                else
                    daytime_bonus = 0
                end
            end

            -- 计算矮星加成
            local stafflight_bonus = 0
            local x, y, z = inst.Transform:GetWorldPosition()     
            if daytime_bonus < 0.10 then                                   -- 自然光与矮星不叠加
                for k, v in pairs(TheSim:FindEntities(x, y, z, 20)) do
                    if v.prefab == "stafflight" then
                        stafflight_bonus = 0.10
                        break
                    end
                end
            end

            -- 计算潮湿度加成
            local moisture_bonus = 0
            if inst.components.moisture then             
                local moisture = inst.components.moisture:GetMoisture()
                local moisture_decline_val = 0
                if inst.components.moisture:GetMoisture() > 0 and (daytime_bonus + stafflight_bonus > 0) then     -- 仅在强光照条件下允许消耗潮湿度回血
                    if moisture < 25 then
                        moisture_decline_val = 0.1
                    elseif moisture < 50 then
                        moisture_decline_val = 0.2
                    elseif moisture < 75 then
                        moisture_decline_val = 0.5
                    else
                        moisture_decline_val = 1.0
                    end
                    moisture_decline_val = moisture_decline_val * photosynthesis_moisture_consume_multi
                    moisture_bonus = moisture_decline_val / 4
                    inst.components.moisture:DoDelta(-moisture_decline_val)
                end
            end

            -- 生命值能量
            local total_energy = ((math.max(daytime_bonus, stafflight_bonus)) + moisture_bonus * photosynthesis_moisture_healing_multi) * GetBuddingBonus(inst) * NoHatBonus(inst) * photosynthesis_timer_multi
            local remaining_energy = total_energy + inst.energy_from_mothling + inst.unused_energy
            inst.energy_from_mothling = 0

            local energy_for_bloom = 0
            local energy_for_blossom_charged = 0
            local energy_for_items = 0
            local energy_for_ivystaff = 0
            local energy_for_mushroomhat = 0
            local energy_for_pets = 0

            -- 根据能量速率生成蝴蝶
            producebutterfly(inst, remaining_energy)

            -- 优先级1: 生命值不满，全部能量用于恢复生命值
            if inst.components.health.currenthealth < TUNING.WORMWOOD_HEALTH then
                inst.components.health:DoDelta(remaining_energy * photosynthesis_light_healing_multi / photosynthesis_timer_multi)
                remaining_energy = 0
            end

            -- 优先级2: 开花值不满，恢复开花值
            -- 换算为开花值能量
            remaining_energy = remaining_energy

            energy_for_bloom = remaining_energy
            if bloomness.level == 3 then 

                -- 开花值低于 1800 点时，能量全部用于恢复开花值
                if bloomness.timer < 1800 then
                    energy_for_bloom = energy_for_bloom * 1

                -- 开花值高于 1800 点时，至少分配一半能量用于恢复开花值
                elseif bloomness.timer + energy_for_bloom * 0.5 < 3599 then
                    energy_for_bloom = energy_for_bloom * 0.5

                -- 开花值接近上限时，不再恢复开花值，并直接将开花值设置为 3600
                else
                    energy_for_bloom = 0
                    -- bloomness.timer = 3600
                end

                -- 修正不同季节开花值变化速率
                local season_offset = 1
                if TheWorld.state.season == "spring" then
                    season_offset = 0
                elseif TheWorld.state.season == "winter" then
                    season_offset = 2
                end
                
                if energy_for_bloom > 0 then
                    bloomness.timer = bloomness.timer + energy_for_bloom + season_offset
                end
                remaining_energy = remaining_energy - energy_for_bloom
            end
            
            -- GLOBAL.TheNet:Announce("开花值恢复："..tostring(energy_for_bloom) .. "  剩余能量：" .. tostring(remaining_energy))
            -- print("开花值恢复："..tostring(energy_for_bloom) .. "  剩余能量：" .. tostring(remaining_energy))
            
            -- 为物品供能
            if inst.components.inventory and inst.components.bloomness then      
                local seasonmodifier = 1
                if TheWorld.state.issummer then
                    seasonmodifier = 1.25
                elseif TheWorld.state.iswinter then
                    seasonmodifier = 0.75
                end

                -- 优先级3.1：为注能月树花供能
                if remaining_energy > 0 then
                    local blossom_count = 0
                    -- 查找物品栏
                    for i = 1, inst.components.inventory:GetNumSlots() do
                        local item = inst.components.inventory:GetItemInSlot(i)
                        if item and item.prefab == "moon_tree_blossom_charged" then
                            blossom_count = blossom_count + item.components.stackable.stacksize
                            energy_for_blossom_charged = energy_for_blossom_charged + ENERGY_COST.moon_tree_blossom_charged * item.components.stackable.stacksize
                            if item.components.perishable then
                                item.components.perishable:SetPercent(item.components.perishable:GetPercent() + 2 / item.components.perishable.perishtime * seasonmodifier)
                            end
                        end
                    end

                    -- 查找背包
                    local backpack = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
                    if backpack and backpack.components.container then
                        for i = 1, backpack.components.container:GetNumSlots() do
                            local item = backpack.components.container:GetItemInSlot(i)
                            if item and item.prefab == "moon_tree_blossom_charged" then
                            blossom_count = blossom_count + item.components.stackable.stacksize
                                energy_for_blossom_charged = energy_for_blossom_charged + ENERGY_COST.moon_tree_blossom_charged * item.components.stackable.stacksize
                                if item.components.perishable then
                                    item.components.perishable:SetPercent(item.components.perishable:GetPercent() + 2 / item.components.perishable.perishtime * seasonmodifier)
                                end
                            end
                        end
                    end
                    remaining_energy = remaining_energy - energy_for_blossom_charged
                else
                    remaining_energy = 0
                end

                -- 优先级3.2：为月蛾、蘑菇、仙人掌供能
                if remaining_energy > 0 then
                    local item_count = 0
                    -- 查找物品栏
                    for i = 1, inst.components.inventory:GetNumSlots() do
                        local item = inst.components.inventory:GetItemInSlot(i)
                        if item and item.components.perishable
                        and (item.prefab == "moonbutterfly" 
                        or item:HasTag("mushroom")
                        or item.prefab == "cactus_meat") then
                            item_count = item_count + item.components.stackable.stacksize
                            energy_for_items = energy_for_items + ENERGY_COST.low_cost_item * item.components.stackable.stacksize
                            if item.components.perishable then
                                item.components.perishable:SetPercent(item.components.perishable:GetPercent() + 2 / item.components.perishable.perishtime * seasonmodifier)
                            end
                        end
                    end

                    -- 查找背包
                    local backpack = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
                    if backpack and backpack.components.container then
                        for i = 1, backpack.components.container:GetNumSlots() do
                            local item = backpack.components.container:GetItemInSlot(i)
                            if item and item.components.perishable
                            and (item.prefab == "moonbutterfly" 
                            or item:HasTag("mushroom")
                            or item.prefab == "cactus_meat") then
                                item_count = item_count + item.components.stackable.stacksize
                                energy_for_items = energy_for_items + ENERGY_COST.low_cost_item * item.components.stackable.stacksize
                                if item.components.perishable then
                                    item.components.perishable:SetPercent(item.components.perishable:GetPercent() + 2 / item.components.perishable.perishtime * seasonmodifier)
                                end
                            end
                        end
                    end
                    remaining_energy = remaining_energy - energy_for_items
                else
                    remaining_energy = 0
                end

                -- 优先级4: 荆棘魔杖供能
                if remaining_energy > 0 then
                    local hand_equipped = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
                    if hand_equipped and hand_equipped.components.perishable and inst.components.bloomness.timer > 1800 then
                        if hand_equipped.prefab == "ivystaff" then
                            if hand_equipped.components.perishable then
                                hand_equipped.components.perishable:SetPercent(hand_equipped.components.perishable:GetPercent() + 2 / hand_equipped.components.perishable.perishtime * seasonmodifier)
                                remaining_energy = remaining_energy - ENERGY_COST.ivystaff
                                energy_for_ivystaff = ENERGY_COST.ivystaff
                            else
                                hand_equipped.components.perishable:SetLocalMultiplier(1)
                            end
                        end
                    end
                else
                    remaining_energy = 0
                end

                -- 优先级5: 蘑菇帽供能
                if remaining_energy > 0 then
                    local head_equipped = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
                    if head_equipped and head_equipped.components.perishable and inst.components.bloomness.timer > 1800 then
                        if head_equipped.prefab == "red_mushroomhat"
                        or head_equipped.prefab == "blue_mushroomhat"
                        or head_equipped.prefab == "green_mushroomhat"
                        or head_equipped.prefab == "moon_mushroomhat" then
                            if head_equipped.components.perishable then
                                head_equipped.components.perishable:SetPercent(head_equipped.components.perishable:GetPercent() + 2 / head_equipped.components.perishable.perishtime * seasonmodifier)   -- 每秒缓慢恢复荆棘魔杖新鲜度
                            end
                            remaining_energy = remaining_energy - ENERGY_COST.mushroomhat
                            energy_for_mushroomhat = ENERGY_COST.mushroomhat
                        end
                    end
                else
                    remaining_energy = 0
                end
            end
            
            -- 优先级6：随从供能
            local pets = inst.components.leader:GetFollowersByTag("wormwood_pet")
            -- 优先给球状光虫供能
            for _, pet in ipairs(pets) do
                if pet.prefab == "wormwood_lightflier" and ENERGY_COST[pet.prefab] then
                    local energy_for_this_pet = ENERGY_COST[pet.prefab]
                    if remaining_energy > 0 then
                        if pet.components.timer:TimerExists("finish_transformed_life") then
                            pet.components.timer:PauseTimer("finish_transformed_life")
                            if pet.components.timer:GetTimeLeft("finish_transformed_life") < TUNING.TOTAL_DAY_TIME * 2 then
                                pet.components.timer:SetTimeLeft("finish_transformed_life", pet.components.timer:GetTimeLeft("finish_transformed_life") + 2)
                                energy_for_this_pet = energy_for_this_pet * 2
                            end
                        end
                        remaining_energy = remaining_energy - energy_for_this_pet
                        energy_for_pets = energy_for_pets + energy_for_this_pet
                    else
                        if pet.components.timer:IsPaused("finish_transformed_life") then
                            pet.components.timer:ResumeTimer("finish_transformed_life")
                        end
                    end
                end
            end
            
            -- 然后给其他随从供能
            for _, pet in pairs(pets) do
                if pet.prefab ~= "wormwood_lightflier" and ENERGY_COST[pet.prefab] then
                    local energy_for_this_pet_alive = ENERGY_COST[pet.prefab]
                    local energy_for_this_pet_planarentity = 0
                    if remaining_energy > 0 then
                        if pet.components.timer:TimerExists("finish_transformed_life") then
                            pet.components.timer:PauseTimer("finish_transformed_life")
                            if pet.components.timer:GetTimeLeft("finish_transformed_life") < TUNING.TOTAL_DAY_TIME * 2 then
                                pet.components.timer:SetTimeLeft("finish_transformed_life", pet.components.timer:GetTimeLeft("finish_transformed_life") + 2)
                                energy_for_this_pet_alive = energy_for_this_pet_alive * 2
                            end
                        end
                        if pet.components.timer:TimerExists("buff_planarentity") then
                            pet.components.timer:PauseTimer("buff_planarentity")
                            energy_for_this_pet_planarentity = ENERGY_COST[pet.prefab] / 2
                            if pet.components.timer:GetTimeLeft("buff_planarentity") < TUNING.TOTAL_DAY_TIME * 2 then
                                pet.components.timer:SetTimeLeft("buff_planarentity", pet.components.timer:GetTimeLeft("buff_planarentity") + 2)
                                energy_for_this_pet_planarentity = energy_for_this_pet_planarentity * 2
                            end
                        end
                        remaining_energy = remaining_energy - energy_for_this_pet_alive - energy_for_this_pet_planarentity
                        energy_for_pets = energy_for_pets + energy_for_this_pet_alive + energy_for_this_pet_planarentity
                    else
                        remaining_energy = 0
                        if pet.components.timer:IsPaused("finish_transformed_life") then
                            pet.components.timer:ResumeTimer("finish_transformed_life")
                        end
                        if pet.components.timer:IsPaused("buff_planarentity") then
                            pet.components.timer:ResumeTimer("buff_planarentity")
                        end
                    end
                end
            end

            -- 优先级7：黄油产出供能
            if remaining_energy > 0 then
                inst.unused_energy = producebutter(inst, remaining_energy)
                inst.overload = false
            else
                remaining_energy = 0
                inst.unused_energy = 0
                inst.overload = true
            end
            inst.butter_produce_vel = remaining_energy

            -- GLOBAL.TheNet:Announce("energy_for_bloom: " .. tostring(energy_for_bloom) .. "  energy_for_items: " .. tostring(energy_for_items))
            -- GLOBAL.TheNet:Announce("energy_for_ivystaff: " .. tostring(energy_for_ivystaff) .. "  energy_for_mushroomhat: " .. tostring(energy_for_mushroomhat))
            -- GLOBAL.TheNet:Announce("energy_for_pets: " .. tostring(energy_for_pets))
            -- GLOBAL.TheNet:Announce("energy_for_butter: " .. tostring(inst.butter_produce_vel) .. "  inst.unused_energy: " .. tostring(inst.unused_energy))
            
            -- print("energy_for_bloom: " .. tostring(energy_for_bloom))
            -- print("energy_for_items: " .. tostring(energy_for_items))
            -- print("energy_for_ivystaff: " .. tostring(energy_for_ivystaff))
            -- print("energy_for_mushroomhat: " .. tostring(energy_for_mushroomhat))
            -- print("energy_for_pets: " .. tostring(energy_for_pets))
            -- print("energy_for_butter: " .. tostring(inst.butter_produce_vel))
            -- print("inst.unused_energy: " .. tostring(inst.unused_energy))
        end
    end)

    inst:ListenForEvent("oneat", function(inst, data)    -- 从食物中回复开花值
        local bloomness = inst.components.bloomness
        if bloomness.level == 3 then 
            local food = data.food
            local healthvalue = food.components.edible.healthvalue
            if food and food.components.edible and healthvalue > 0 then
                if inst:HasTag("wormwood_blooming_max_upgrade") then
                    if bloomness.timer + healthvalue * 4 < 3600 then
                        bloomness.timer = bloomness.timer + healthvalue  * 4 * GetBuddingBonus(inst)
                        -- GLOBAL.TheNet:Announce("吃饭回复了 " .. tostring(healthvalue * 4) .. " 点开花值！")
                    else
                        bloomness.timer = 3600
                    end
                else
                    if bloomness.timer + healthvalue * 4 < 2400 then
                        bloomness.timer = bloomness.timer + healthvalue  * 4 * GetBuddingBonus(inst)
                    else
                        bloomness.timer = 2400
                    end
                end
                if inst:HasTag("wormwood_blooming_max_upgrade") then
                    producebutter(inst, healthvalue / 2)
                end
            end
        end
    end)

    -------------------------------------------------------------------


    ----------------- 不佩戴头部装备时，开花增益翻倍 -------------------
    -- 增益加成已在该脚本顶部实现，只需在穿戴和卸除头部装备时刷新各类 buff 即可
    inst:ListenForEvent("equip", function(inst, data)
        -- GLOBAL.TheNet:Announce("触发装备头盔事件！")
        if inst:HasTag("wormwood_blooming_overheatprotection") and inst.components.inventory 
            and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
            inst:ExternalSpeedMutiply()             -- 刷新移速
            -- inst:UpdatePhotosynthesisState(nil, true)        -- 刷新光合作用
            -- 潮湿度回血，已在对应函数中实现
            -- 靠近矮星回血，已在对应函数中实现
        end
    end)

    inst:ListenForEvent("unequip", function(inst, data)
        -- GLOBAL.TheNet:Announce("触发卸除头盔事件！")
        if inst:HasTag("wormwood_blooming_overheatprotection") and inst.components.inventory 
            and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
            inst:ExternalSpeedMutiply()             -- 刷新移速
            -- inst:UpdatePhotosynthesisState(nil, true)        -- 刷新光合作用
            -- 潮湿度回血，已在对应函数中实现
            -- 靠近矮星回血，已在对应函数中实现
        end
    end)

    -- inst:DoTaskInTime(2, function()
    --     inst:ExternalSpeedMutiply()
    --     -- inst:UpdatePhotosynthesisState(nil, true)
    -- end)
end)

-- 治愈灵魂特效
local function HealingFx(inst)
    local height = 0
    if inst.prefab == "critter_lunarmothling" then
        height = 1.5
    elseif inst.prefab == "wormwood_lightflier" then
        height = 0.5
    end

    local fx = SpawnPrefab("wortox_soul_heal_fx")
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(0, height, 0)
    fx.Transform:SetScale(1.25, 1.25, 1.25)
    fx.AnimState:SetMultColour(0.6, 0.95, 0.95, 0.7) 
    fx.AnimState:SetAddColour(0.3, 0.8, 0.8, 0.3)  
    fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
end

-- 治愈闪烁效果函数
local function HealingFlash(inst)
    if inst.flashtask then
        inst.flashtask:Cancel()
        inst.flashtask = nil
    end
    local start_time = GetTime()
    inst.flashtask = inst:DoPeriodicTask(FRAMES, function(inst)
        local t = GetTime() - start_time
        local cycle = 2 * math.pi * t / 0.9
        local intensity = 0.25 * math.sin(cycle)
        inst.AnimState:SetAddColour(intensity, intensity, intensity, 0)
    end)
    inst:DoTaskInTime(0.9, function(inst)
        if inst.flashtask then
            inst.flashtask:Cancel()
            inst.flashtask = nil
        end
        inst.AnimState:SetAddColour(0, 0, 0, 0) -- 恢复正常
    end)
end

-- 监听月蛾种植事件
AddPrefabPostInit("moonbutterfly", function(inst)
    if not TheWorld.ismastersim then return end

    if inst.components.inventoryitem then 
        inst.components.inventoryitem.grabbableoverridetag = "wormwood_blooming_lunartree"
    end

    local HEAL_RADIUS = 10 -- 治疗半径
    local HEAL_AMOUNT = 150 -- 治疗总量
    local HEAL_DURATION = 30 -- 持续时间(秒)
    local HEAL_PER_TICK = HEAL_AMOUNT / HEAL_DURATION -- 每秒治疗量

    
    -- 定义治疗范围和效果
    inst.components.deployable.ondeploy = function(inst, pt, deployer)
        local moontree = SpawnPrefab("moonbutterfly_sapling")
        if moontree then
            moontree.Transform:SetPosition(pt:Get())
            moontree.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
            inst.components.stackable:Get():Remove()
        end

        if not deployer:HasTag("wormwood_blooming_lunartree") or not deployer:HasTag("moon_charged_1")
            or deployer.components.bloomness.timer < lunartree_consume_val then return end
        deployer:RemoveTag("moon_charged_1")
        deployer.components.bloomness.timer = deployer.components.bloomness.timer - lunartree_consume_val
        moontree.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        
        
        local function makeanims(stage)
            return {
                idle="idle_"..stage,
                sway1="sway1_loop_"..stage,
                sway2="sway2_loop_"..stage,
                chop="chop_"..stage,
                fallleft="fallleft_"..stage,
                fallright="fallright_"..stage,
                stump="stump_"..stage,
                burning="burning_loop_"..stage,
                burnt="burnt_"..stage,
                chop_burnt="chop_burnt_"..stage,
                idle_chop_burnt="idle_chop_burnt_"..stage,
            }
        end

        local SHORT = "short"
        local NORMAL = "normal"
        local TALL = "tall"

        local moon_tree_anims = {
            [SHORT] = makeanims(SHORT),
            [TALL] = makeanims(TALL),
            [NORMAL] = makeanims(NORMAL),
        }

        local function on_moon_tree_burnt(inst)
            on_moon_tree_burnt_immediate_helper(inst, false)
        end

        local function push_sway(inst)
            local anim_to_play = (math.random() > .5 and moon_tree_anims[inst.size].sway1) or moon_tree_anims[inst.size].sway2
            inst.AnimState:PushAnimation(anim_to_play, true)
        end

        local function set_normal_burnable(inst)
            if inst.components.burnable == nil then
                inst:AddComponent("burnable")
                inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
            end
            inst.components.burnable:SetBurnTime(TUNING.TREE_BURN_TIME)
            inst.components.burnable:SetFXLevel(3)
            inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
            inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
            inst.components.burnable:SetOnBurntFn(on_moon_tree_burnt)

            -- Equivalent to MakeSmallPropagator
            if inst.components.propagator == nil then
                inst:AddComponent("propagator")
            end
            inst.components.propagator.acceptsheat = true
            inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
            inst.components.propagator.flashpoint = 5 + math.random()*5
            inst.components.propagator.decayrate = 0.5
            inst.components.propagator.propagaterange = 5
            inst.components.propagator.heatoutput = 5
            inst.components.propagator.damagerange = 2
            inst.components.propagator.damages = true
        end

        local function set_tall_burnable(inst)
            if inst.components.burnable == nil then
                inst:AddComponent("burnable")
                inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
            end
            inst.components.burnable:SetFXLevel(5)
            inst.components.burnable:SetBurnTime(TUNING.TREE_BURN_TIME * 1.5)
            inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
            inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
            inst.components.burnable:SetOnBurntFn(on_moon_tree_burnt)

            -- Equivalent to MakeMediumPropagator
            if inst.components.propagator == nil then
                inst:AddComponent("propagator")
            end
            inst.components.propagator.acceptsheat = true
            inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
            inst.components.propagator.flashpoint = 15+math.random()*10
            inst.components.propagator.decayrate = 0.5
            inst.components.propagator.propagaterange = 7
            inst.components.propagator.heatoutput = 8.5
            inst.components.propagator.damagerange = 3
            inst.components.propagator.damages = true
        end

        -- 在树周围随机位置生成月蛾的函数
        local function SpawnButterflyNearTree(tree)
            if not tree or not tree:IsValid() then return end
            
            local x, y, z = tree.Transform:GetWorldPosition()
            tree:DoTaskInTime(math.random() * 2, function()
                -- 计算随机位置
                local angle = math.random() * 2 * math.pi
                local radius = math.max(2, math.random() * 10)
                local offset = Vector3(radius * math.cos(angle), 0, radius * math.sin(angle))
                local spawn_pos = Vector3(x + offset.x, y, z + offset.z)
                
                -- 生成月蛾
                local butterfly = GLOBAL.SpawnPrefab("moonbutterfly")
                if butterfly then
                    butterfly.Transform:SetPosition(spawn_pos:Get())
                end
            end)
        end

        local ANGLE = 0
        local PLANTS_DENSITY = 0.8

        local function SpawnPlantsAroundTreeRing(tree, r)
            local x, y, z = tree.Transform:GetWorldPosition()
            x = x + math.random() 
            z = z + math.random()
            
            local radius = r
            local c = 2 * math.pi * radius
            local num = math.ceil(c / PLANTS_DENSITY)
            local ANGLE_DELTA = (180 - 360 / num ) / 180 * 2 * math.pi
            
            local offset = Vector3(
                radius * math.cos(ANGLE),
                0,
                radius * math.sin(ANGLE) * (-1) ^ r
            )
            local spawn_pos = Vector3(x + offset.x, y, z + offset.z)
            
            -- 检查位置是否有效
            if TheWorld.Map:IsPassableAtPoint(spawn_pos.x, spawn_pos.y, spawn_pos.z) 
                and not TheWorld.Map:IsOceanAtPoint(spawn_pos.x, spawn_pos.y, spawn_pos.z) 
                and TheWorld.Map:CanPlantAtPoint(spawn_pos.x, 0, spawn_pos.z)
                and #TheSim:FindEntities(spawn_pos.x, 0, spawn_pos.z, .5, "moontree_plant_fx") < 3
                and TheWorld.Map:IsDeployPointClear(spawn_pos, nil, .5)
                and not TheWorld.Map:IsPointNearHole(spawn_pos, .4) 
                and not TileGroupManager:IsTemporaryTile(current_tile) then
                local plant = SpawnPrefab("moontree_plant_fx")
                if plant then
                    plant:SetVariation(math.random(1, 4))
                    plant.Transform:SetPosition(spawn_pos:Get())
                end
            end
            ANGLE = ANGLE + ANGLE_DELTA
        end

        local flower_spawn_time = 0.5

        local function SpawnRing(moontree, r)
            -- 方法1：通过upvalue传递
            local task
            task = moontree:DoPeriodicTask(flower_spawn_time, function()
                SpawnPlantsAroundTreeRing(moontree, r)
                
                -- 计算停止时间（半圈后停止）
                local stop_delay = math.ceil(2 * math.pi * r / PLANTS_DENSITY) / 2 * flower_spawn_time
                moontree:DoTaskInTime(stop_delay, function()
                    if task then 
                        task:Cancel()
                        task = nil
                    end
                end)
            end)
        end

        local grow_interval = 3
        moontree:DoTaskInTime(grow_interval, function()
            local moontree_sapling = moontree
            moontree = SpawnPrefab("moon_tree_short")

            -- moontree:RemoveComponent("workable")
            -- moontree:RemoveComponent("burnable")
            -- moontree:RemoveComponent("plantregrowth")
            -- moontree.Physics:SetCollides(false)
            -- -- 添加不可点击标签
            -- moontree:AddTag("NOCLICK")
            -- moontree:AddTag("NOBLOCK")  -- 防止被其他实体阻挡

            -- -- 设置透明发光效果
            -- moontree.AnimState:SetLightOverride(0.8)  -- 增加光照
            -- moontree.AnimState:SetAddColour(0.5, 1, 1, 1)  -- 浅青色(RGB:0.5,1,1)透明度0.3
            -- moontree.AnimState:SetMultColour(1, 1, 1, 0.1)

            moontree.components.timer:StartTimer("healing_expire", 61)
            moontree:ListenForEvent("timerdone", function(inst, data)
                if data.name == "healing_expire" then
                    if moontree.components.growable.stage ~= 1 then
                        moontree.components.growable:SetStage(1)
                        moontree.AnimState:PlayAnimation("grow_tall_to_short")
                        moontree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
                    end
                end
            end)

            moontree.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            
            -- 启动治疗任务
            local heal_count = 0
            local heal_range = 10
            local mothling_charge_rete = 0.5
            moontree:DoTaskInTime(0, function()
                moontree.heal_task = moontree:DoPeriodicTask(1, function()
                    if not moontree:IsValid() then return end  -- 检查实体有效性
                    
                    local x, y, z = moontree.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, heal_range, nil, { "hostile", "INLIMBO" })


                    for _, ent in ipairs(ents) do
                        if ent.components.health and not ent.components.health:IsDead() 
                            and (ent:HasTag("player") or ent:HasTag("wormwood_lunarplant") 
                            or (ent.components.follower 
                            and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player"))) then
                            local healing_pets_multi = (ent:HasTag("wormwood_pet") or ent:HasTag("wormwood_lunarplant")) and pets_healing_multi_base or 1
                            ent.components.health:DoDelta((8 - 0.2 * heal_count) * lunartree_healing_multi * healing_pets_multi)
                            -- GLOBAL.TheNet:Announce("治疗中#1")
                            HealingFx(ent)
                            HealingFlash(ent)
                        elseif ent.prefab == "critter_lunarmothling" and ent.power then
                            ent.power = ent.power + ((8 - 0.2 * heal_count) * lunartree_healing_multi) * mothling_charge_rete
                            HealingFx(ent)
                            HealingFlash(ent)
                        end
                    end
                    heal_count = heal_count + 1
                end)
            end)
            
            moontree:DoTaskInTime(HEAL_DURATION + 1, function()
                if moontree.heal_task then
                    moontree.heal_task:Cancel()  -- 停止第一次治疗
                    moontree.heal_task = nil
                end
            end)

            -- 30秒后切换到第二种治疗
            moontree:DoTaskInTime(HEAL_DURATION, function()
                -- 启动第二种治疗
                moontree.heal_task2 = moontree:DoPeriodicTask(1, function()
                    if not moontree:IsValid() then return end
                    
                    local x, y, z = moontree.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, heal_range, nil, { "hostile", "INLIMBO" })

                    for _, ent in ipairs(ents) do
                        if ent.components.health and not ent.components.health:IsDead() 
                            and (ent:HasTag("player") or ent:HasTag("wormwood_lunarplant") 
                            or (ent.components.follower 
                            and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player"))) then
                            local healing_pets_multi = (ent:HasTag("wormwood_pet") or ent:HasTag("wormwood_lunarplant")) and pets_healing_multi_base or 1
                            ent.components.health:DoDelta(2 * lunartree_healing_multi * healing_pets_multi)
                            -- GLOBAL.TheNet:Announce("治疗中#2")
                            HealingFx(ent)
                            HealingFlash(ent)
                        elseif ent.prefab == "critter_lunarmothling" and ent.power then
                            ent.power = ent.power + (2 * lunartree_healing_multi) * mothling_charge_rete
                            HealingFx(ent)
                            HealingFlash(ent)
                        end
                    end
                end)

                -- 再持续30秒后停止
                moontree:DoTaskInTime(HEAL_DURATION - 2, function()
                    if moontree.heal_task2 then
                        moontree.heal_task2:Cancel()
                        moontree.heal_task2 = nil
                    end
                end)
            end)

            moontree.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            moontree:AddTag("moontree_healing")
            moontree.Transform:SetPosition(moontree_sapling.Transform:GetWorldPosition())
            moontree_sapling:Remove()
            moontree:DoTaskInTime(5.1, function() SpawnRing(moontree, 2) end)
            moontree:DoTaskInTime(1.2, function() SpawnRing(moontree, 3) end)
            moontree:DoTaskInTime(2.3, function() SpawnRing(moontree, 4) end)
            moontree:DoTaskInTime(3.4, function() SpawnRing(moontree, 5) end)
            moontree:DoTaskInTime(0.5, function() SpawnRing(moontree, 6) end)
            moontree:DoTaskInTime(1.6, function() SpawnRing(moontree, 7) end)
            moontree:DoTaskInTime(4.7, function() SpawnRing(moontree, 8) end)
            moontree:DoTaskInTime(2.8, function() SpawnRing(moontree, 9) end)
            moontree:DoTaskInTime(0.0, function() SpawnRing(moontree, 10) end)

            moontree.components.growable:SetStage(1)
            moontree.AnimState:PlayAnimation("grow_seed_to_short")
            moontree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            push_sway(moontree)
            SpawnButterflyNearTree(moontree)

            moontree:DoTaskInTime(grow_interval, function()
                moontree.components.growable:SetStage(2)
                moontree.AnimState:PlayAnimation("grow_short_to_normal")
                moontree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
                set_normal_burnable(moontree)
                push_sway(moontree)
                SpawnButterflyNearTree(moontree)

                moontree:DoTaskInTime(grow_interval, function()
                    moontree.components.growable:SetStage(3)
                    moontree.AnimState:PlayAnimation("grow_normal_to_tall")
                    moontree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
                    set_tall_burnable(moontree)
                    push_sway(moontree)
                    SpawnButterflyNearTree(moontree)
                    
                    moontree:DoTaskInTime(50 - grow_interval * 3, function()
                        moontree:RemoveTag("moontree_healing") 
                        moontree:DoTaskInTime(10, function()
                            moontree.components.growable:SetStage(1)
                            moontree.AnimState:PlayAnimation("grow_tall_to_short")
                            moontree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
                            moontree.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")

                            -- moontree:AddComponent("workable")
                            -- moontree:AddComponent("burnable")
                            -- moontree:AddComponent("plantregrowth")
                            -- moontree.Physics:SetCollides(true)

                            -- -- 添加不可点击标签
                            -- moontree:RemoveTag("NOCLICK")
                            -- moontree:RemoveTag("NOBLOCK")  -- 防止被其他实体阻挡

                            if moontree.spawn_plant_task then
                                moontree.spawn_plant_task:Cancel()
                                moontree.spawn_plant_task = nil
                            end
                        end)
                    end)
                end)
            end)
        end)
        
    end
end)

local function OnSave_lunarmothling(inst, data)

    data.power = inst.power
end

local function OnLoad_lunarmothling(inst, data)
    
    if data.power then
        inst.power = data.power
    end
end

-- 小蛾子需要月光进行充能，和沃姆伍德正好相反，并且充能强度和时段、月相、饥饿度有关
-- 当沃姆伍德负载过高时，小蛾子可以输送一些能量给沃姆伍德
-- 小蛾子的能量越多，发光范围越大
-- 小蛾子存储的月能可用于治疗玩家，每次为玩家恢复 20 点血量，它会自动为附近生命值低于 66% 的玩家玩家治疗，生命值较高的玩家也可以主动抚摸它来恢复生命值

-- 充能上限，类似于沃姆伍德的开花值，因此在数值上做相似处理
local MOTHLING_POWER_CAPACITY = 100

-- 充能速度：在秋季时期，夜晚和黄昏的时长约为 3 ~ 4 分钟，等效夜晚时长约为 2 ~ 3 分钟，平均每天月相为半月，
-- 则每天充能量约为 1 * 150 * 1.5 = 225, 充满 1000 能量大概需要 4.5 个夜晚，但是它同时还要承担给沃姆伍德供能的任务
local MOTHLING_POWER_CHARGE_RATE = 0.15

-- 能量转换治疗量的比例
local MOTHLING_POWER_TO_HEAL_CONVERT = 1

-- 每次治疗量上限 
local MOTHLING_HEALING_PER_TIME = 20       

-- 每次传输能量的大小，可使沃姆伍德的负载能力提升
local MOTHLING_TRANSFER_ENERGY_PER_TIME = MOTHLING_POWER_CHARGE_RATE

local LIGHT_INTENSITY = 0.9
local LIGHT_FALLOFF = 0.5
local LIGHT_RADIUS = 3

local function Mothling_UpdateLight_Fadeout(inst)
    inst._powerlight.fading = true
    -- 渐变特效参数
    local duration = 0.5 -- 渐变持续时间（秒）
    local interval = FRAMES -- 每帧更新
    local target_intensity = inst.power / MOTHLING_POWER_CAPACITY

    -- 如果已有渐变任务，先取消
    if inst._light_tween_task then
        inst._light_tween_task:Cancel()
        inst._light_tween_task = nil
    end

    -- 获取当前强度
    local light = inst._powerlight and inst._powerlight.Light
    if not light then return end
    local start_intensity = light:GetIntensity() or 0

    -- 如果目标强度和当前强度几乎一样，直接设置
    if math.abs(target_intensity - start_intensity) < 0.01 then
        light:SetIntensity(target_intensity)
        return
    end

    local elapsed = 0
    inst._light_tween_task = inst:DoPeriodicTask(interval, function()
        elapsed = elapsed + interval
        local percent = math.min(elapsed / duration, 1)
        local new_intensity = start_intensity + (target_intensity - start_intensity) * percent
        light:SetIntensity(new_intensity * LIGHT_INTENSITY)
        if percent >= 1 then
            inst._light_tween_task:Cancel()
            inst._light_tween_task = nil
            inst._powerlight.fading = false
        end
    end)
end

local function Mothling_UpdateLight(inst)
    -- 如果正在渐变发光，则不更新
    if inst._powerlight.fading then return end 
    inst._powerlight.Light:SetIntensity(inst.power / MOTHLING_POWER_CAPACITY * LIGHT_INTENSITY)
end

local function GetHungerBonus_Pet(inst)
    return inst.components.perishable:GetPercent() * 0.25 + 1
end

local function Mothling_ReCharge(inst, intensity)
    local energy = MOTHLING_POWER_CHARGE_RATE * GetHungerBonus_Pet(inst) * intensity
    local leader = inst.components.follower.leader

    -- 默认全部能量给自己
    local energy_for_mothling = energy
    local energy_for_leader = 0

    -- 如果沃姆伍德超载，分一半能量给沃姆伍德
    if leader and leader.overload then
        if inst.power >= MOTHLING_POWER_CAPACITY then
            energy_for_leader = energy
            energy_for_mothling = energy - energy_for_leader
        else
            energy_for_leader = energy * 0.5
            energy_for_mothling = energy - energy_for_leader
        end
    end

    -- 给自己充能，不能超过上限
    local can_add = MOTHLING_POWER_CAPACITY - inst.power
    if energy_for_mothling > can_add then
        energy_for_leader = energy_for_leader + (energy_for_mothling - can_add)
        energy_for_mothling = can_add
    end
    inst.power = inst.power + energy_for_mothling

    -- 给沃姆伍德充能
    if energy_for_leader > 0 then
        leader.energy_from_mothling = (leader.energy_from_mothling or 0) + energy_for_leader
    end
end

local function Mothling_Transfer_Energy(inst)
    -- if inst.components.sleeper:IsAsleep() then return end
    -- 给沃姆伍德供能
    local leader = inst.components.follower.leader
    -- 检查沃姆伍德是否超载或自身能量是否已满
    if leader and leader.components.bloomness.level == 3 and leader.overload and inst.power > MOTHLING_TRANSFER_ENERGY_PER_TIME or inst.power >= MOTHLING_POWER_CAPACITY then
        leader.energy_from_mothling = leader.energy_from_mothling + MOTHLING_TRANSFER_ENERGY_PER_TIME 
        inst.power = inst.power - MOTHLING_TRANSFER_ENERGY_PER_TIME
    end
end

local function Mothling_DoHealing(inst, target)
    -- 生成一个治疗特效
    HealingFx(target, 0)
    HealingFlash(target)
    local health = target.components.health
    if health.currenthealth + MOTHLING_HEALING_PER_TIME <= health.maxhealth then
        inst.power = inst.power - MOTHLING_HEALING_PER_TIME / MOTHLING_POWER_TO_HEAL_CONVERT
        health:DoDelta(MOTHLING_HEALING_PER_TIME)
    else
        local health_delta = health.maxhealth - health.currenthealth
        inst.power = inst.power - health_delta / MOTHLING_POWER_TO_HEAL_CONVERT
        health:DoDelta(health_delta)
    end
    Mothling_UpdateLight_Fadeout(inst)
    inst.components.timer:StartTimer("healing_cd", 5)
    inst.ready_to_heal = false
    -- inst.sg:GoToState("cute")
end

local function Mothling_Auto_Healing(inst)
    -- 睡着的时候不干活
    if inst.components.sleeper:IsAsleep() then return end

    -- 可治疗量低于 20 时返回
    if inst.power * MOTHLING_POWER_TO_HEAL_CONVERT < MOTHLING_HEALING_PER_TIME then return end

    local healing_target = FindEntity(
        inst,
        8,
        function(guy)
            if guy.components.health.maxhealth - guy.components.health.currenthealth >= MOTHLING_HEALING_PER_TIME then
                return guy
            end
        end,
        {"player"},
        {"playerghost"})

    if healing_target and inst.ready_to_heal then
        Mothling_DoHealing(inst, healing_target)
    end
end

local MOON_PHASE_BONUS_PET = {
    new = 0,
    quarter = 0.25,
    half = 0.5,
    threequarter = 0.75,
    full = 1.0,
}

-- 获取当前月相加成
local function GetMoonPhaseBonus_Pet()
    local phase = TheWorld.state.moonphase or 0
    return MOON_PHASE_BONUS_PET[phase] or 0
end

AddPrefabPostInit("critter_lunarmothling", function(inst)
    if not TheWorld.ismastersim then return end

    inst.power = 0
    inst.last_power = 0
    inst.current_power = 0
    inst.power_delta = 0

    if inst.components.follower.leader and inst.components.follower.leader:HasTag("wormwood_blooming_lunartree") then
        if inst._powerlight == nil or not inst._powerlight:IsValid() then
            inst._powerlight = SpawnPrefab("yellowamuletlight")
            inst._powerlight.Light:SetFalloff(LIGHT_FALLOFF)
            inst._powerlight.Light:SetRadius(LIGHT_RADIUS)
            inst.components.follower.leader.mothling = inst
        end
        inst._powerlight.entity:SetParent(inst.entity)
        Mothling_UpdateLight(inst)
    end

    -- 自动治疗有 CD
    if not inst.components.timer:TimerExists("healing_cd") then
        inst.ready_to_heal = true
    else
        inst.ready_to_heal = false
    end
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "healing_cd" then
            inst.ready_to_heal = true
        end
    end)

    inst.stat_check_task = inst:DoPeriodicTask(1, function()
        if inst.components.follower.leader and inst.components.follower.leader:HasTag("wormwood_blooming_lunartree") then
            if inst._powerlight == nil or not inst._powerlight:IsValid() then
                inst._powerlight = SpawnPrefab("yellowamuletlight")
                inst._powerlight.Light:SetFalloff(LIGHT_FALLOFF)
                inst._powerlight.Light:SetRadius(LIGHT_RADIUS)
                inst.components.follower.leader.mothling = inst
            end
            inst._powerlight.entity:SetParent(inst.entity)

            -- 充能任务
            -- 寻找极光
            local found_coldlight = false
            local x, y, z = inst.Transform:GetWorldPosition()     
            for k, v in pairs(TheSim:FindEntities(x, y, z, 20)) do
                if v.prefab == "staffcoldlight" then
                    found_coldlight = true
                    break
                end
            end

            if found_coldlight then
                Mothling_ReCharge(inst, 1)
            elseif not TheWorld:HasTag("cave") then
                if TheWorld.state.isnight then
                    Mothling_ReCharge(inst, GetMoonPhaseBonus_Pet())
                elseif TheWorld.state.isdusk then
                    Mothling_ReCharge(inst, 0.5 * GetMoonPhaseBonus_Pet())       -- 黄昏的充能效率为一半
                end
            end

            -- 输送能量任务，这个功能还没整好，会出现数值脉冲现象，先阉割
            -- Mothling_Transfer_Energy(inst)

            -- 更新发光任务
            Mothling_UpdateLight(inst)

            -- 自动搜索和治疗任务，睡觉的时候不治疗
            Mothling_Auto_Healing(inst)
            inst.current_power = inst.power
            inst.power_delta = inst.current_power - inst.last_power
            inst.last_power = inst.current_power
        end
    end)

    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then
            old_onsave(inst, data)
        end
        OnSave_lunarmothling(inst, data)
    end

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then
            old_onload(inst, data)
        end
        OnLoad_lunarmothling(inst, data)
    end 
    
    -- 保存原始检查函数
    local old_inspect_fn = inst.components.inspectable.GetStatus
    
    inst.components.inspectable.GetStatus = function(inst, viewer)
        local status = old_inspect_fn and old_inspect_fn(inst, viewer) or ""
        if viewer and viewer.prefab == "wormwood" and viewer.mothling then
            viewer:DoTaskInTime(FRAMES, function(viewer)
                local report_delta = ""
                if viewer.mothling.power_delta >= 0 then
                    report_delta = "+"
                else
                    report_delta = ""
                end

                if viewer:HasTag("wormwood_blooming_max_upgrade") then
                    viewer:DoTaskInTime(FRAMES, function(viewer)
                        viewer.components.talker:Say(STRINGS.WORMWOOD_MOTHLING.inspect_cut_1 .. FormatDelta(viewer.mothling.power, 2) .. "/" .. FormatDelta(MOTHLING_POWER_CAPACITY, 2) .. "(" .. report_delta .. FormatDelta(viewer.mothling.power_delta, 3) .. "/s)")
                    end)
                end
            end)
        end
        
        return status
    end
end)

AddPrefabPostInit("staffcoldlight", function(inst)
    if not TheWorld.ismastersim then return end
    
    local light = inst
    light.active_tasks = {}
    -- 应用亲和增益
    local function ApplyAttackBoost(light)
        light.active_tasks.attack_boost = true
        light.components.timer:StartTimer("attack_boost", 5)

        light:ListenForEvent("timerdone", function(inst, data)
            if data.name == "attack_boost" then
                local x, y, z = light.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 15, nil, { "playerghost", "INLIMBO" })

                for _, ent in ipairs(ents) do
                    if ent ~= light and ent:IsValid() then
                        -- 检查是否为玩家或跟随沃姆伍德的单位
                        if ent:HasTag("player") or ent:HasTag("companion")
                            or (ent.components.follower and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player")) then
                            
                            -- 刷新 buff
                            if ent.bufftask then 
                                ent.bufftask:Cancel() 
                                ent.bufftask = nil
                            end
                            -- 添加月亮亲和加成
                            if not ent.components.damagetypebonus then ent:AddComponent("damagetypebonus") end
                            if not ent.components.damagetyperesist then ent:AddComponent("damagetyperesist") end
                            ent.components.damagetypebonus:AddBonus("shadow_aligned", ent, 1.1, "staffcoldlight")
                            ent.components.damagetyperesist:AddResist("lunar_aligned", ent, 0.9, "staffcoldlight")
                            
                            -- 一段时间后移除加成
                            ent.bufftask = ent:DoTaskInTime(5.1, function()
                                if ent.components.combat then
                                    ent.components.damagetypebonus:RemoveBonus("shadow_aligned", ent, "staffcoldlight")
                                    ent.components.damagetyperesist:RemoveResist("lunar_aligned", ent, "staffcoldlight")
                                end
                            end)
                        end
                    end
                end
                light.components.timer:StartTimer("attack_boost", 5)
            end
        end)
        
    end

    local function FrozenTask(light)
        local frozen_fx = SpawnPrefab("deerclopseyeball_sentryward_fx")
        frozen_fx.Transform:SetPosition(light.Transform:GetWorldPosition())

        if not frozen_fx.components.timer then
            frozen_fx:AddComponent("timer")
        end

        frozen_fx.components.timer:StartTimer("expire", light.components.timer:GetTimeLeft("frozen_task"))
        frozen_fx:ListenForEvent("timerdone", function(frozen_fx, data)
            if data.name == "expire" then
                frozen_fx.AnimState:PlayAnimation("pst")
                frozen_fx:DoTaskInTime(frozen_fx.AnimState:GetCurrentAnimationLength() + .25, frozen_fx.Remove)
            end
        end)

        -- 标记任务为活跃
        light.active_tasks.frozen_task = true
        
        -- 第一次使用时立刻冻结所有敌人
        local x, y, z = light.Transform:GetWorldPosition()
        local enemies = GLOBAL.TheSim:FindEntities(
            x, y, z, 
            15, 
            { "_combat", "freezable" },
            { "player", "INLIMBO", "companion", "FX", "structure" }
        )
        
        for _, enemy in ipairs(enemies) do
            if enemy:IsValid() and not enemy:IsInLimbo() and enemy.components.freezable and not enemy.components.freezable:IsFrozen()
                and not (enemy.components.follower and enemy.components.follower:GetLeader() 
                    and enemy.components.follower:GetLeader():HasTag("player")) then
                enemy.components.freezable:AddColdness(5) 
            end
        end

        light.components.timer:StartTimer("frozen_effect", 1)
        light:ListenForEvent("timerdone", function(inst, data)
            if data.name == "frozen_effect" then
                local enemies = GLOBAL.TheSim:FindEntities(
                    x, y, z, 
                    15, 
                    { "_combat", "freezable" },
                    { "player", "INLIMBO", "companion", "FX", "structure" }
                )
                
                for _, enemy in ipairs(enemies) do
                    if enemy.components.freezable and not enemy.components.freezable:IsFrozen()
                        and not (enemy.components.follower and enemy.components.follower:GetLeader() 
                            and enemy.components.follower:GetLeader():HasTag("player")) then
                        enemy.components.freezable:AddColdness(math.random() / 4) -- 随机冰冻值
                    end
                end
                light.components.timer:StartTimer("frozen_effect", 1)
            elseif data.name == "frozen_task" then
                -- 任务结束，清理状态
                light:RemoveTag("FrozenTask")
                light.active_tasks.frozen_task = nil
                light.components.timer:StopTimer("frozen_effect")
            end
        end)
    end

    local function EnableLunarStrike(light)
        local x, y, z = light.Transform:GetWorldPosition()

        light._gestalt_task = light:DoPeriodicTask(4, function(inst) 
            local guard_count = 0
            for k, v in pairs(TheSim:FindEntities(x, y, z, 20)) do
                if v.prefab == "wormwood_gestalt_guard" then
                    guard_count = guard_count + 1
                    if guard_count > 3 then           
                        return
                    end
                end
            end

            local angle = math.random() * 2 * math.pi
            local radius = math.max(2, math.random() * 15)
            local offset = Vector3(radius * math.cos(angle), 0, radius * math.sin(angle))
            local spawn_pos = Vector3(x + offset.x, y, z + offset.z)

            local guard = SpawnPrefab("wormwood_gestalt_guard")
            guard.Transform:SetPosition(spawn_pos:Get())
            guard.AnimState:PlayAnimation("emerge")
        end)

        -- deepseek 是伟大的发明 QAQ
        light.tracked_players = {}
        light._sanity_task = light:DoPeriodicTask(1, function(inst)
            local players = TheSim:FindEntities(x, y, z, 22, { "player" }, { "playerghost", "INLIMBO"})
            local current_players = {}
            
            -- 标记当前范围内的玩家
            for _, v in ipairs(players) do
                current_players[v] = true
                if not light.tracked_players[v] then
                    -- 新玩家进入范围
                    v.components.sanity:EnableLunacy(true, "lunacyarea_"..tostring(light.GUID))
                    light.tracked_players[v] = true
                end
            end
            
            -- 检查离开范围的玩家
            for player, _ in pairs(light.tracked_players) do
                if not current_players[player] then
                    -- 玩家离开范围
                    player.components.sanity:EnableLunacy(false, "lunacyarea_"..tostring(light.GUID))
                    light.tracked_players[player] = nil
                end
            end
        end)

        light:DoTaskInTime(light.components.timer:GetTimeLeft("lunar_strike"), function()
            if light._gestalt_task then light._gestalt_task:Cancel() end
            if light._sanity_task then light._sanity_task:Cancel() end
            -- 清理玩家状态
            for player in pairs(light.tracked_players) do
                player.components.sanity:EnableLunacy(false, "lunacyarea_"..tostring(light.GUID))
            end
            light:RemoveTag("EnableLunarStrike")
        end)
    end

    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then
            old_onsave(inst, data)
        end
        data.active_tasks = inst.active_tasks
        data.tags = {}
        if inst:HasTag("ApplyAttackBoost") then table.insert(data.tags, "ApplyAttackBoost") end
        if inst:HasTag("FrozenTask") then table.insert(data.tags, "FrozenTask") end
        if inst:HasTag("EnableLunarStrike") then table.insert(data.tags, "EnableLunarStrike") end
        if inst.tracked_players then
            data.tracked_players = {}
            for player in pairs(inst.tracked_players) do
                if player:IsValid() then
                    table.insert(data.tracked_players, player.GUID)
                end
            end
        end
    end

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then
            old_onload(inst, data)
        end
        if data then
            inst.active_tasks = data.active_tasks or {}
            for _, tag in ipairs(data.tags or {}) do
                inst:AddTag(tag)
            end
            if inst:HasTag("ApplyAttackBoost") then inst:ApplyAttackBoost() end
            if inst:HasTag("FrozenTask") then inst:FrozenTask() end
            if inst:HasTag("EnableLunarStrike") then inst:EnableLunarStrike() end
            if data.tracked_players then
                inst.tracked_players = {}
                for _, guid in ipairs(data.tracked_players) do
                    local player = Ents[guid]
                    if player then
                        player.components.sanity:EnableLunacy(true, "lunacyarea_"..tostring(inst.GUID))
                        inst.tracked_players[player] = true
                    end
                end
            end
        end
    end

    inst.ApplyAttackBoost = ApplyAttackBoost
    inst.FrozenTask = FrozenTask
    inst.EnableLunarStrike = EnableLunarStrike
end)

AddPrefabPostInit("opalstaff", function(inst)
    if not TheWorld.ismastersim then return end

    local function createlight_new(staff, target, pos)
        local light = SpawnPrefab("staffcoldlight")
        light.Transform:SetPosition(pos:Get())
        staff.components.finiteuses:Use(1)

        -- 初始化任务状态

        local caster = staff.components.inventoryitem.owner
        if caster ~= nil then
            -- 保存caster信息以便恢复
            light.caster_guid = caster.GUID
            if caster.components.staffsanity then
                caster.components.staffsanity:DoCastingDelta(-TUNING.SANITY_MEDLARGE)
            elseif caster.components.sanity ~= nil then
                caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
            end
        end

        local function GetCaster()
            return caster or (light.caster_guid and Ents[light.caster_guid]) or nil
        end


        local current_caster = GetCaster()
        if current_caster and current_caster:HasTag("wormwood_blooming_opalstaff") then
            light:AddTag("ApplyAttackBoost")
            light:ApplyAttackBoost()
            if current_caster:HasTag("moon_charged_1") and current_caster.components.bloomness.timer >= opalstaff_frozen_consume_val then
                current_caster.components.bloomness.timer = current_caster.components.bloomness.timer - opalstaff_frozen_consume_val 
                current_caster:RemoveTag("moon_charged_1")

                light:AddTag("FrozenTask")
                light.components.timer:StartTimer("frozen_task", opalstaff_frozen_exist_val)
                light:FrozenTask()

            elseif current_caster:HasTag("moon_charged_2") and caster.components.bloomness.timer >= opalstaff_summon_consume_val then
                caster.components.bloomness.timer = caster.components.bloomness.timer - opalstaff_summon_consume_val
                caster:RemoveTag("moon_charged_2")
                caster.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")

                light:AddTag("EnableLunarStrike")
                light.components.timer:StartTimer("lunar_strike", opalstaff_summon_exist_val)
                light:EnableLunarStrike()

                local terraformer = SpawnPrefab("wormwood_meteor_terraformer")
                terraformer.Transform:SetPosition(light.Transform:GetWorldPosition())
                terraformer:SetType("LUNAR") 
                terraformer:DoTerraform()
                terraformer.components.timer:SetTimeLeft("undo_terraforming", opalstaff_summon_exist_val)

                local x, y, z = light.Transform:GetWorldPosition()
                local grazer_angle = math.random() * 2 * math.pi
                local grazer_radius = math.max(4, math.random() * 10)
                local grazer_offset = Vector3(grazer_radius * math.cos(grazer_angle), 0, grazer_radius * math.sin(grazer_angle))
                local grazer_spawn_pos_1 = Vector3(x + grazer_offset.x, y, z + grazer_offset.z)
                local grazer_spawn_pos_2 = Vector3(x + grazer_offset.x * (-1), y, z + grazer_offset.z * (-1))
                light:DoTaskInTime(3, function(inst)
                    local fx_1 = SpawnPrefab("wormwood_lunar_transformation_finish")
                    fx_1.Transform:SetPosition(grazer_spawn_pos_1:Get())
                    local grazer_1 = SpawnPrefab("wormwood_lunar_grazer")
                    grazer_1.Transform:SetPosition(grazer_spawn_pos_1:Get())
                    grazer_1.components.timer:StartTimer("expire", opalstaff_summon_exist_val)
                end)

                light:DoTaskInTime(5, function(inst)
                    local fx_2 = SpawnPrefab("wormwood_lunar_transformation_finish")
                    fx_2.Transform:SetPosition(grazer_spawn_pos_2:Get())
                    local grazer_2 = SpawnPrefab("wormwood_lunar_grazer")
                    grazer_2.Transform:SetPosition(grazer_spawn_pos_2:Get())
                    grazer_2.components.timer:StartTimer("expire", opalstaff_summon_exist_val)
                end)
            end
        end
    end

    inst.components.spellcaster:SetSpellFn(createlight_new)
end)
