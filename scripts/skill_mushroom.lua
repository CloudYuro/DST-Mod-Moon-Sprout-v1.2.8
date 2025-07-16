local mushroom_buff_time = tonumber(GetModConfigData("mushroom_buff_time"))
local shroomcake_buff_time = tonumber(GetModConfigData("shroomcake_buff_time"))
local shroombait_buff_time = tonumber(GetModConfigData("shroombait_buff_time"))
local shroombait_common_multi = tonumber(GetModConfigData("shroombait_common_multi"))
local shroombait_epic_multi = tonumber(GetModConfigData("shroombait_epic_multi"))
local shroombait_affect_teammate = GetModConfigData("shroombait_affect_teammate")
local mushroomhat_unlock_chance = tonumber(GetModConfigData("mushroomhat_unlock_chance"))
local mushroomhat_damage_absorb = tonumber(GetModConfigData("mushroomhat_damage_absorb"))
local mushroomhat_consume_val = tonumber(GetModConfigData("mushroomhat_consume_val"))
local moon_mushroomhat_consume_val = tonumber(GetModConfigData("moon_mushroomhat_consume_val"))
local moon_mushroomhat_buff_time = tonumber(GetModConfigData("moon_mushroomhat_buff_time"))
local overheatprotection_buff_multi = tonumber(GetModConfigData("overheatprotection_buff_multi"))

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

local function GetBloomingBonus(inst) -- 获取当前开花增益，用于乘算
    if not inst:HasTag("wormwood_moon_cap_eating") then return 1 end
    -- 根据开花等级和标签计算增益
    local level = inst.components.bloomness:GetLevel()
    local level_bonus = {
        [3] = 1.5,
        -- [2] = inst:HasTag("wormwood_blooming_farmrange1") and 1.5 or 1,
        -- [1] = inst:HasTag("wormwood_blooming_farmrange1") and 1.25 or 1,
    }

    return (level_bonus[level] or 1) * NoHatBonus(inst)
end

-- 负责管理多种 buff，包括蘑菇、蘑菇帽、开花增益
local BuffManager = {
    active_buffs = {},
    buff_definitions = {},
    mushroom_types = {"red_mushroom", "blue_mushroom", "green_mushroom"}, -- 所有互斥类型
    mushroom_dishes_types = {"shroomcake", "shroombait"}, -- 蘑菇菜肴类型
}

function BuffManager.RegisterBuff(buff_type, definition)
    BuffManager.buff_definitions[buff_type] = definition
end

function BuffManager.AddBuff(inst, buff_type)
    local guid = inst.GUID
    local key = buff_type.."_"..guid
    local definition = BuffManager.buff_definitions[buff_type]
    
    if not definition then return end
    
    -- 食用红绿蓝蘑菇时，移除所有其他蘑菇效果（互斥逻辑）
    if buff_type == "red_mushroom" or buff_type == "blue_mushroom" or buff_type == "green_mushroom" then
        for _, other_type in ipairs(BuffManager.mushroom_types) do
            if other_type ~= buff_type then
                BuffManager.RemoveBuff(inst, other_type)
            end
        end
    end

    if buff_type == "shroomcake" or buff_type == "shroombait" then
        for _, other_type in ipairs(BuffManager.mushroom_dishes_types) do
            if other_type ~= buff_type then
                BuffManager.RemoveBuff(inst, other_type)
            end
        end
    end
    
    --获取开花增益
    local BloomingBonus = inst:HasTag("wormwood_mushroom_shroomcake") and GetBloomingBonus(inst) * NoHatBonus(inst) or 1

    -- 已有同类型buff则重置
    if BuffManager.active_buffs[key] then
        BuffManager.active_buffs[key].task:Cancel()
        BuffManager.active_buffs[key] = nil
    end
    
    -- 执行buff添加效果
    if definition.on_add then
        definition.on_add(inst)
    end
    
    -- 记录新buff
    BuffManager.active_buffs[key] = {
        type = buff_type,
        inst = inst,
        task = inst:DoTaskInTime(definition.duration * BloomingBonus, function()
            BuffManager.RemoveBuff(inst, buff_type)
        end),
        expires = GetTime() + definition.duration * BloomingBonus
    }
end

function BuffManager.RemoveBuff(inst, buff_type)
    local key = buff_type.."_"..inst.GUID
    local buff = BuffManager.active_buffs[key]
    
    if buff then
        if buff.task then 
            buff.task:Cancel() 
            buff.task = nil
        end
        
        local definition = BuffManager.buff_definitions[buff_type]
        if definition and definition.on_remove then
            definition.on_remove(inst)
        end
        
        BuffManager.active_buffs[key] = nil
    end
end

function BuffManager.TrackCharacter(inst)
    if inst.prefab ~= "wormwood" then return end
    
    inst:ListenForEvent("onremove", function()
        for k, buff in pairs(BuffManager.active_buffs) do
            if k:sub(-32) == inst.GUID then
                BuffManager.RemoveBuff(inst, buff.type)
            end
        end
    end)
end

-- 初始化角色追踪
AddPlayerPostInit(function(inst)
    BuffManager.TrackCharacter(inst)
end)


local function GetRandomizedPosition(inst, range)
    local x, y, z = inst.Transform:GetWorldPosition() -- 获取当前位置
    local random_offset_x = math.random() * range - (range / 2) -- 生成范围内的随机增量
    local random_offset_z = math.random() * range - (range / 2)
    return x + random_offset_x, y, z + random_offset_z -- 返回新的位置
end

-- 生成漂浮孢子并让它快速腐烂从而消失
local function SpawnRandomizedSpore(prefab_name, inst, perish_time, range)
    local x, y, z = GetRandomizedPosition(inst, range) -- 获取随机位置
    local spore = SpawnPrefab(prefab_name) -- 生成孢子
    if spore and spore.Transform then
        spore.Transform:SetPosition(x, y, z) -- 设置孢子的位置
    end

    if spore and spore.components.perishable then
        spore:DoTaskInTime(perish_time - 1, function(inst)    -- perish_time - 1 让孢子在视觉效果上快一些消失
        spore.components.perishable:SetPercent(0)
        end)
    end

    return spore
end

BuffManager.RegisterBuff("red_mushroom", {
    duration = mushroom_buff_time,
    on_add = function(inst)
        local definition = BuffManager.buff_definitions["red_mushroom"]
        local duration = definition.duration -- 从 definition 中获取 duration
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1.1, "red_mushroom")

        if not inst.components.builder:KnowsRecipe("wormwood_red_mushroomhat") then
            local days = TheWorld.state.cycles
            -- 计算概率（1% + (天数 / 100) * 19%）
            local chance = mushroomhat_unlock_chance + math.min(days / 100, 1) * 0.19
            -- 随机数触发
            if math.random() < chance then
                -- 解锁红蘑菇帽配方
                inst.components.builder:UnlockRecipe("wormwood_red_mushroomhat")
                inst:PushEvent("unlockrecipe", { recipe = "wormwood_red_mushroomhat" })
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.know_red_mushroomhat)
            else 
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_red_buff)
            end
        else 
            inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_red_buff)
        end
        SpawnRandomizedSpore("spore_medium", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 1)
    end,
    on_remove = function(inst)
        inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "red_mushroom")
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.deactivate_red_buff)
    end
})

BuffManager.RegisterBuff("blue_mushroom", {
    duration = mushroom_buff_time,
    on_add = function(inst)
        local definition = BuffManager.buff_definitions["blue_mushroom"]
        local duration = definition.duration        
        inst.components.health.externalabsorbmodifiers:SetModifier("blue_mushroom", 0.15) -- 增加 15% 吸收       

        if not inst.components.builder:KnowsRecipe("wormwood_blue_mushroomhat") then
            local days = TheWorld.state.cycles
            -- 计算概率（1% + (天数 / 100) * 19%）
            local chance = mushroomhat_unlock_chance + math.min(days / 100, 1) * 0.19
            -- 随机数触发
            if math.random() < chance then
                -- 解锁蓝蘑菇帽配方
                inst.components.builder:UnlockRecipe("wormwood_blue_mushroomhat")
                inst:PushEvent("unlockrecipe", { recipe = "wormwood_blue_mushroomhat" })
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.know_blue_mushroomhat)
            else 
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_blue_buff)
            end
        else 
            inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_blue_buff)
        end
        SpawnRandomizedSpore("spore_tall", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 1)
    end,
    on_remove = function(inst)
        inst.components.health.externalabsorbmodifiers:RemoveModifier("blue_mushroom") -- 移除吸收
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.deactivate_blue_buff)
    end
})

BuffManager.RegisterBuff("green_mushroom", {
    duration = mushroom_buff_time,
    on_add = function(inst)
        local definition = BuffManager.buff_definitions["green_mushroom"]
        local duration = definition.duration
        -- 对暗影阵营生物伤害增加20%，对月亮阵营生物获得减伤20%
        inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.2, "green_mushroom")
        inst.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.8, "green_mushroom")

        if not inst.components.builder:KnowsRecipe("wormwood_green_mushroomhat") then
            local days = TheWorld.state.cycles
            -- 计算概率（1% + (天数 / 100) * 19%）
            local chance = mushroomhat_unlock_chance + math.min(days / 100, 1) * 0.19
            -- 随机数触发
            if math.random() < chance then
                -- 解锁绿蘑菇帽配方
                inst.components.builder:UnlockRecipe("wormwood_green_mushroomhat")
                inst:PushEvent("unlockrecipe", { recipe = "wormwood_green_mushroomhat" })
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.know_green_mushroomhat)
            else 
                inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_green_buff)
            end
        else 
            inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_green_buff)
        end
        SpawnRandomizedSpore("spore_small", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 1)
    end,

    on_remove = function(inst)
        inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "green_mushroom")
        inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "green_mushroom")
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.deactivate_green_buff)
    end
})


local function OnEatMoonCap(eater, shroomcake_adjust)  -- 引用源代码，并调整蘑菇蛋糕的催眠强度
    if not shroomcake_adjust then shroomcake_adjust = 1 end

    if not (eater.components.freezable and eater.components.freezable:IsFrozen()) and
            not (eater.components.pinnable and eater.components.pinnable:IsStuck()) and
            not (eater.components.fossilizable and eater.components.fossilizable:IsFossilized()) then

        local sleeptime = TUNING.MOON_MUSHROOM_SLEEPTIME * shroomcake_adjust

        local mount = (eater.components.rider ~= nil and eater.components.rider:GetMount()) or nil
        if mount then
            mount:PushEvent("ridersleep", { sleepiness = 4 * shroomcake_adjust, sleeptime = sleeptime })
        end

		if eater.components.skilltreeupdater and eater.components.skilltreeupdater:IsActivated("wormwood_moon_cap_eating") then
			local cloud = SpawnPrefab("sleepcloud_lunar")
			cloud.Transform:SetPosition(eater.Transform:GetWorldPosition())
			cloud:SetOwner(eater)
		elseif eater.components.sleeper then
            eater.components.sleeper:AddSleepiness(4, sleeptime)
        elseif eater.components.grogginess then
            eater.components.grogginess:AddGrogginess(2, sleeptime)
        else
            eater:PushEvent("knockedout")
        end
    end
end

BuffManager.RegisterBuff("shroomcake", {
    duration = shroomcake_buff_time,
    on_add = function(inst)
        local definition = BuffManager.buff_definitions["shroomcake"]
        local duration = definition.duration
        inst._base_damage = inst.components.combat.damagemultiplier or 1
        inst.components.combat.damagemultiplier = inst._base_damage * 1.05
        inst.components.health.externalabsorbmodifiers:SetModifier("shroomcake", 0.075) -- 增加 7.5% 伤害吸收
        inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.1, "shroomcake")
        inst.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.9, "shroomcake")
        SpawnRandomizedSpore("spore_small", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 5)
        SpawnRandomizedSpore("spore_medium", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 5)
        SpawnRandomizedSpore("spore_tall", inst, duration * GetBloomingBonus(inst) * NoHatBonus(inst), 5)
        OnEatMoonCap(inst, 0.5)          
    end,
    on_remove = function(inst)
        if inst._base_damage then
            inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier / 1.05
        end
        inst.components.health.externalabsorbmodifiers:RemoveModifier("shroomcake") -- 移除吸收
        inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "shroomcake")
        inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "shroomcake")
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.deactivate_shroomcake_buff)
    end
})

local CLOUD_RADIUS = 2.5
local PHYSICS_PADDING = 3
local SLEEPER_TAGS = { "sleeper" }
local SLEEPER_NO_TAGS = { "playerghost", "lunar_aligned", "INLIMBO" }

local function OnClearCloudProtection(ent)
	ent._lunargrazercloudprot = nil
end

local function SetCloudProtection(inst, ent, duration)
	if ent:IsValid() then
		if ent._lunargrazercloudprot ~= nil then
			ent._lunargrazercloudprot:Cancel()
		end
		ent._lunargrazercloudprot = ent:DoTaskInTime(duration, OnClearCloudProtection)
	end
end

local function DoCloudTask(inst)
    inst.components.grogginess.grog_amount = 1
	local x, y, z = inst.Transform:GetWorldPosition()
    if not shroombait_affect_teammate then
        table.insert(SLEEPER_NO_TAGS, "player")
    end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, CLOUD_RADIUS + PHYSICS_PADDING, nil, SLEEPER_NO_TAGS, SLEEPER_TAGS)) do
		if v._lunargrazercloudprot == nil and
			v:IsValid() and v.entity:IsVisible() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			not (v.sg ~= nil and v.sg:HasStateTag("waking"))
			then
			local range = v:GetPhysicsRadius(0) + CLOUD_RADIUS
			if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if v.shroombait_debuff_task then
                    v.shroombait_debuff_task:Cancel()
                    v.shroombait_debuff_task = nil
                end
				if v.components.grogginess ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("knockout")) then
                        if v:HasTag("epic") then
						    v.components.grogginess:AddGrogginess(TUNING.LUNAR_GRAZER_GROGGINESS * shroombait_epic_multi, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
                        else
						    v.components.grogginess:AddGrogginess(TUNING.LUNAR_GRAZER_GROGGINESS * shroombait_common_multi, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
                        end
						SetCloudProtection(inst, v, .5)
					end
				elseif v.components.sleeper ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("sleeping")) then
                        if v:HasTag("epic") then
						    v.components.sleeper:AddSleepiness(TUNING.LUNAR_GRAZER_GROGGINESS * shroombait_epic_multi, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
                        else
						    v.components.sleeper:AddSleepiness(TUNING.LUNAR_GRAZER_GROGGINESS * shroombait_common_multi, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
                        end
						SetCloudProtection(inst, v, .5)
					end
				end
                v.components.combat.externaldamagemultipliers:SetModifier(v, 0.75, "shroombait")
                v.shroombait_debuff_task = v:DoTaskInTime(1.1, function(inst)
                    v.components.combat.externaldamagemultipliers:RemoveModifier(v, 0.75, "shroombait")
                    v.shroombait_debuff_task:Cancel()
                    v.shroombait_debuff_task = nil
                end)
			end
		end
	end
end

local function StartCloudTask(inst)
	if inst.cloudtask == nil then
		inst.cloudtask = inst:DoPeriodicTask(1, DoCloudTask, math.random())
	end
end

local function StopCloudTask(inst)
	if inst.cloudtask ~= nil then
		inst.cloudtask:Cancel()
		inst.cloudtask = nil
	end
end

BuffManager.RegisterBuff("shroombait", {
    duration = shroombait_buff_time,
    on_add = function(inst)
        local definition = BuffManager.buff_definitions["shroombait"]
        local duration = definition.duration
        inst.cloud = SpawnPrefab("lunar_goop_cloud_fx")
        inst.cloud.entity:SetParent(inst.entity)

        local x, y, z = inst.Transform:GetWorldPosition()
        local creatures = TheSim:FindEntities(x, y, z, 25, nil, SLEEPER_NO_TAGS, SLEEPER_TAGS)
        for _, v in ipairs(creatures) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible() then
				if v.components.grogginess ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("knockout")) then
						v.components.grogginess:AddGrogginess(30, 30)   
					end
				elseif v.components.sleeper ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("sleeping")) then
						v.components.sleeper:AddSleepiness(30, 30)
					end
				end
            end
        end
        StartCloudTask(inst)
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, 0.75, "shroombait")
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.activate_shroombait_buff)
    end,
    on_remove = function(inst)
        StopCloudTask(inst)
        inst.components.grogginess.grog_amount = 0
        inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "shroombait")
        inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.deactivate_green_buff)
        inst.cloud:Remove() 
    end
})

local function TryUnlockMoonMushroomHat(inst)
    inst:DoTaskInTime(0.1, function(inst)
        if inst:HasTag("wormwood_mushroomplanter_upgrade")
        and inst.components.builder:KnowsRecipe("wormwood_red_mushroomhat") 
        and inst.components.builder:KnowsRecipe("wormwood_blue_mushroomhat")
        and inst.components.builder:KnowsRecipe("wormwood_green_mushroomhat") 
        and not inst.components.builder:KnowsRecipe("wormwood_moon_mushroomhat") then
            inst.components.builder:UnlockRecipe("wormwood_moon_mushroomhat")
            if inst:HasTag("wormwood_moon_cap_eating") then
                inst:DoTaskInTime(0.9, function(inst)
                    inst:PushEvent("unlockrecipe", { recipe = "wormwood_moon_mushroomhat" })
                    inst.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.know_moon_mushroomhat)
                end)
            end
        end
    end)
end

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("oneat", function(inst, data)
        local food = data.food
        local buff_type

        if inst:HasTag("wormwood_mushroomplanter_upgrade") then
            if food.prefab == "red_cap" then
                buff_type = "red_mushroom"
            elseif food.prefab == "blue_cap" then
                buff_type = "blue_mushroom"
            elseif food.prefab == "green_cap" then
                buff_type = "green_mushroom"
            end
        end

        if inst:HasTag("wormwood_mushroom_shroomcake") then
            if food.prefab == "shroomcake" then
                buff_type = "shroomcake"
            elseif food.prefab == "shroombait" then
                buff_type = "shroombait"
            end
        end
        
        if buff_type then
            BuffManager.AddBuff(inst, buff_type)
        end
    end)

    inst:ListenForEvent("unlockrecipe", function(inst, data)
        if data.recipe == "wormwood_red_mushroomhat" and not inst.components.builder:KnowsRecipe("red_mushroomhat") then
            inst.components.builder:UnlockRecipe("red_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "red_mushroomhat" })
        elseif data.recipe == "wormwood_blue_mushroomhat" and not inst.components.builder:KnowsRecipe("blue_mushroomhat") then
            inst.components.builder:UnlockRecipe("blue_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "blue_mushroomhat" })
        elseif data.recipe == "wormwood_green_mushroomhat" and not inst.components.builder:KnowsRecipe("green_mushroomhat") then
            inst.components.builder:UnlockRecipe("green_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "green_mushroomhat" })
        elseif data.recipe == "red_mushroomhat" and not inst.components.builder:KnowsRecipe("wormwood_red_mushroomhat") then
            inst.components.builder:UnlockRecipe("wormwood_red_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "wormwood_red_mushroomhat" })
        elseif data.recipe == "blue_mushroomhat" and not inst.components.builder:KnowsRecipe("wormwood_blue_mushroomhat") then
            inst.components.builder:UnlockRecipe("wormwood_blue_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "wormwood_blue_mushroomhat" })
        elseif data.recipe == "green_mushroomhat" and not inst.components.builder:KnowsRecipe("wormwood_green_mushroomhat") then
            inst.components.builder:UnlockRecipe("wormwood_green_mushroomhat")
            inst:PushEvent("unlockrecipe", { recipe = "wormwood_green_mushroomhat" })
        end

        TryUnlockMoonMushroomHat(inst)
    end)
end)


local function GetHat(inst)
    if inst.components.inventory then
        return inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
    end
end

local function IsMushroomhat(hat)
    if hat then
        return (hat.prefab == "red_mushroomhat" or hat.prefab == "blue_mushroomhat" 
            or hat.prefab == "green_mushroomhat" or hat.prefab == "moon_mushroomhat" or hat.prefab == "wormwood_moon_mushroomhat")
    end
    return false  -- 显式返回 false（可选）
end

-- 添加蘑菇帽刷新加载事件，避免在游戏开始时蘑菇帽减伤和buff不生效
AddPlayerPostInit(function(player)
    local function CheckMushroomHat()
        if player:HasTag("wormwood_mushroom_mushroomhat") then 
            local hat = GetHat(player)
            if not hat or not IsMushroomhat(hat) then return end
            player.components.inventory:Unequip(EQUIPSLOTS.HEAD)
            player.components.inventory:Equip(hat)
            -- player.components.talker:Say("蘑菇帽效果已刷新！")
        end
    end
    
    -- 等待角色初始化完成，并初始检查
    player:DoTaskInTime(2, CheckMushroomHat)
end)

--为所有蘑菇帽增加伤害吸收buff
local function AddMushroomHatFunctionality(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)   
        if not GLOBAL.TheWorld.ismastersim then
            return
        end

        -- 添加装备事件
        inst:ListenForEvent("equipped", function(inst, data)
            local owner = data.owner
            if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
                if IsMushroomhat(inst) then
                    owner.components.health.externalabsorbmodifiers:SetModifier(inst, mushroomhat_damage_absorb, "mushroomhat")
                    if inst.prefab == "red_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.put_on_red)
                    elseif inst.prefab == "blue_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.put_on_blue)
                    elseif inst.prefab == "green_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.put_on_green)
                    elseif inst.prefab == "moon_mushroomhat" or inst.prefab == "wormwood_moon_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.put_on_moon)
                    end
                end
            end
        end)

        -- 添加卸下事件
        inst:ListenForEvent("unequipped", function(inst, data)
            local owner = data.owner
            if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
                if IsMushroomhat(inst) then
                    owner.components.health.externalabsorbmodifiers:RemoveModifier(inst, "mushroomhat")
                    if inst.prefab == "red_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.take_off_red)
                    elseif inst.prefab == "blue_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.take_off_blue)
                    elseif inst.prefab == "green_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.take_off_green)
                    elseif inst.prefab == "moon_mushroomhat" or inst.prefab == "wormwood_moon_mushroomhat" then
                        owner.components.talker:Say(STRINGS.WORMWOOD_MUSHROOMHAT.take_off_moon)
                    end
                end
            end
        end)
    end)
end

--蘑菇帽受击降低新鲜度
AddPrefabPostInit("wormwood", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    -- 监听角色受到攻击的事件
    inst:ListenForEvent("attacked", function(inst, data)
        -- 检查是否佩戴蘑菇帽
        local hat = GetHat(inst)
        if not hat or not IsMushroomhat(hat) then return end
        -- 根据伤害量降低蘑菇帽的新鲜度
        local current_percent = hat.components.perishable:GetPercent()
        local reduction = data.damage * mushroomhat_damage_absorb * 0.0025 -- 蘑菇帽默认吸收 50% 的伤害，每 1 点伤害降低 0.002 的新鲜度, 等价于最多吸收 400 点伤害
        local new_percent = math.max(current_percent - reduction, 0)
        hat.components.perishable:SetPercent(new_percent)
    end)

    TryUnlockMoonMushroomHat(inst)
end)

--为红蘑菇帽、蓝蘑菇帽和绿蘑菇帽统一添加减伤buff
AddMushroomHatFunctionality("red_mushroomhat")
AddMushroomHatFunctionality("blue_mushroomhat")
AddMushroomHatFunctionality("green_mushroomhat")
AddMushroomHatFunctionality("moon_mushroomhat")
AddMushroomHatFunctionality("wormwood_moon_mushroomhat")

--为红蘑菇帽增加团体增伤buff
AddPrefabPostInit("red_mushroomhat", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    -- 添加装备事件
    inst:ListenForEvent("equipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            -- 为周围友方单位添加攻击加成
            owner.components.combat.externaldamagemultipliers:SetModifier(inst, 1.1, "red_mushroomhat")
            -- 定义周期性执行的函数（复用逻辑）
            local function ApplyAttackBoost(inst, owner)
                -- 检查是否仍佩戴蘑菇帽
                local hat = GetHat(owner)
                if not (owner and owner:IsValid() and hat and hat.prefab == "red_mushroomhat") then
                    if inst._attack_boost_task then
                        inst._attack_boost_task:Cancel()
                        inst._attack_boost_task = nil
                    end
                    return
                end

                if not owner:HasTag("moon_charged_1") then return end
                owner.components.bloomness.timer = owner.components.bloomness.timer - mushroomhat_consume_val
                -- 范围检测和buff逻辑
                local x, y, z = owner.Transform:GetWorldPosition()
                local range = 10
                local ents = TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "INLIMBO" })

                for _, ent in ipairs(ents) do
                    if ent ~= owner and ent:IsValid() and ent.components.combat then
                        -- 检查是否为玩家或跟随沃姆伍德的单位
                        if ent:HasTag("player") or ent:HasTag("companion")
                            or (ent.components.follower and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player")) then
                            
                            -- 刷新 buff
                            if ent.bufftask then 
                                ent.bufftask:Cancel() 
                                ent.bufftask = nil
                            end
                            -- 添加攻击加成
                            ent.components.combat.externaldamagemultipliers:SetModifier(inst, 1.1, "red_mushroomhat")
                            ent:DoTaskInTime(math.random() * 0.5, function(ent)
                                if math.random() < 0.25 then
                                    SpawnRandomizedSpore("spore_medium", ent, 1, 1)
                                end
                            end)
                            
                            -- 一段时间后移除加成
                            ent.bufftask = ent:DoTaskInTime(1.1, function()
                                if ent.components.combat then
                                    ent.components.combat.externaldamagemultipliers:RemoveModifier(inst, "red_mushroomhat")
                                end
                            end)
                        end
                    end
                end
            end

            -- 立即执行一次
            -- ApplyAttackBoost(inst, owner)

            -- 启动周期性任务（1秒间隔）
            inst._attack_boost_task = inst:DoPeriodicTask(1, function()
                ApplyAttackBoost(inst, owner)
            end)
        end
    end)

    
    -- 添加卸下事件
    inst:ListenForEvent("unequipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            owner.components.combat.externaldamagemultipliers:RemoveModifier(inst, "red_mushroomhat")
        end
    end)
end)

--为蓝蘑菇帽增加团体减伤buff
AddPrefabPostInit("blue_mushroomhat", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- 添加装备事件
    inst:ListenForEvent("equipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            owner.components.health.externalabsorbmodifiers:SetModifier(inst, 0.15, "blue_mushroomhat")
            -- 定义周期性执行的函数（复用逻辑）
            local function ApplyAttackBoost(inst, owner)
                -- 检查是否仍佩戴蘑菇帽
                local hat = GetHat(owner)
                if not (owner and owner:IsValid() and hat and hat.prefab == "blue_mushroomhat") then
                    if inst._attack_boost_task then
                        inst._attack_boost_task:Cancel()
                        inst._attack_boost_task = nil
                    end
                    return
                end

                if not owner:HasTag("moon_charged_1") then return end
                owner.components.bloomness.timer = owner.components.bloomness.timer - mushroomhat_consume_val
                -- 范围检测和buff逻辑
                local x, y, z = owner.Transform:GetWorldPosition()
                local range = 10
                local ents = TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "INLIMBO" })

                for _, ent in ipairs(ents) do
                    if ent ~= owner and ent:IsValid() and ent.components.health then
                        -- 检查是否为玩家或跟随沃姆伍德的单位
                        if ent:HasTag("player") or ent:HasTag("companion")
                            or (ent.components.follower and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player"))  then
                            
                            -- 刷新 buff
                            if ent.bufftask then 
                                ent.bufftask:Cancel() 
                                ent.bufftask = nil
                            end
                            -- 添加减伤加成
                            ent.components.health.externalabsorbmodifiers:SetModifier(inst, 0.15, "blue_mushroomhat")
                            ent:DoTaskInTime(math.random() * 0.5, function(ent) 
                                if math.random() < 0.25 then
                                    SpawnRandomizedSpore("spore_tall", ent, 1, 1) 
                                end
                            end)
                            
                            -- 一段时间后移除加成
                            ent.bufftask = ent:DoTaskInTime(1.1, function()
                                if ent.components.health then
                                    ent.components.health.externalabsorbmodifiers:RemoveModifier(inst, "blue_mushroomhat")
                                end
                            end)
                        end
                    end
                end
            end

            -- 立即执行一次
            -- ApplyAttackBoost(inst, owner)

            -- 启动周期性任务（1秒间隔）
            inst._attack_boost_task = inst:DoPeriodicTask(1, function()
                ApplyAttackBoost(inst, owner)
            end)
        end
    end)

    
    -- 添加卸下事件
    inst:ListenForEvent("unequipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            local owner = data.owner
            owner.components.health.externalabsorbmodifiers:RemoveModifier(inst, "blue_mushroomhat")
        end
    end)
end)

--为绿蘑菇帽增加团体月亮亲和buff
AddPrefabPostInit("green_mushroomhat", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- 添加装备事件
    inst:ListenForEvent("equipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            owner.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.2, "green_mushroomhat")
            owner.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.8, "green_mushroomhat")
            -- 定义周期性执行的函数（复用逻辑）
            local function ApplyAttackBoost(inst, owner)
                -- 检查是否仍佩戴蘑菇帽
                local hat = GetHat(owner)
                if not (owner and owner:IsValid() and hat and hat.prefab == "green_mushroomhat") then
                    if inst._attack_boost_task then
                        inst._attack_boost_task:Cancel()
                        inst._attack_boost_task = nil
                    end
                    return
                end

                if not owner:HasTag("moon_charged_1") then return end
                owner.components.bloomness.timer = owner.components.bloomness.timer - mushroomhat_consume_val
                -- 范围检测和buff逻辑
                local x, y, z = owner.Transform:GetWorldPosition()
                local range = 10
                local ents = TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "INLIMBO" })

                for _, ent in ipairs(ents) do
                    if ent ~= owner and ent:IsValid() and ent.components.combat then
                        -- 检查是否为玩家或跟随沃姆伍德的单位
                        if ent:HasTag("player") or ent:HasTag("companion")
                            or (ent.components.follower and ent.components.follower:GetLeader() 
                            and ent.components.follower:GetLeader():HasTag("player"))  then
                            
                            -- 刷新 buff
                            if ent.bufftask then 
                                ent.bufftask:Cancel() 
                                ent.bufftask = nil
                            end
                            -- 添加月亮亲和加成
                            if not ent.components.damagetypebonus then ent:AddComponent("damagetypebonus") end
                            if not ent.components.damagetyperesist then ent:AddComponent("damagetyperesist") end
                            ent.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.2, "green_mushroomhat")
                            ent.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.8, "green_mushroomhat")
                            ent:DoTaskInTime(math.random() * 0.5, function(ent) 
                                if math.random() < 0.25 then
                                    SpawnRandomizedSpore("spore_small", ent, 1, 1) 
                                end
                            end)
                            
                            -- 一段时间后移除加成
                            ent.bufftask = ent:DoTaskInTime(1.1, function()
                                if ent.components.combat then
                                    ent.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "green_mushroomhat")
                                    ent.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "green_mushroomhat")
                                end
                            end)
                        end
                    end
                end
            end

            -- 立即执行一次
            -- ApplyAttackBoost(inst, owner)

            -- 启动周期性任务（1秒间隔）
            inst._attack_boost_task = inst:DoPeriodicTask(1, function()
                ApplyAttackBoost(inst, owner)
            end)
        end
    end)

    -- 添加卸下事件
    inst:ListenForEvent("unequipped", function(inst, data)
        local owner = data.owner
        if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
            owner.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "green_mushroomhat")
            owner.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "green_mushroomhat")
        end
    end)
end)

-- -- 为月亮蘑菇帽增加关闭友伤功能
-- AddPrefabPostInit("moon_mushroomhat", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return
--     end

--     inst:ListenForEvent("equipped", function(inst, data)
--         local owner = data.owner
--         if owner and owner:HasTag("wormwood_mushroom_mushroomhat") then
--             -- 定义周期性执行的函数（复用逻辑）
--             local function ApplyMoonSporeProtection(inst, owner)
--                 -- 检查是否仍佩戴蘑菇帽
--                 local hat = GetHat(owner)
--                 if not (owner and owner:IsValid() and hat and hat.prefab == "moon_mushroomhat") then
--                     if inst._spore_protect_task then
--                         inst._spore_protect_task:Cancel()
--                         inst._spore_protect_task = nil
--                     end
--                     return
--                 end

--                 -- 范围检测和buff逻辑
--                 local x, y, z = owner.Transform:GetWorldPosition()
--                 local range = 20
--                 local ents = TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "INLIMBO" })

--                 for _, ent in ipairs(ents) do
--                     if ent ~= owner and ent:IsValid() and ent.components.combat then
--                         -- 检查是否为玩家或跟随沃姆伍德的单位
--                         if ent:HasTag("player") or ent:HasTag("companion")
--                             or (ent.components.follower and ent.components.follower:GetLeader() 
--                             and ent.components.follower:GetLeader():HasTag("player"))  then
                            
--                             if ent.tagtask then 
--                                 ent.tagtask:Cancel() 
--                                 ent.tagtask = nil
--                             end

--                             if not ent:HasTag("moon_spore_protection") then
--                                 ent:AddTag("moon_spore_protection")
--                             end
                            
--                             -- 一段时间后移除加成
--                             ent.tagtask = ent:DoTaskInTime(1.1, function()
--                                 local hat = GetHat(ent)
--                                 if hat and hat.prefab == "moon_mushroomhat" then
--                                     return
--                                 end
--                                 if ent:HasTag("moon_spore_protection") then
--                                     ent:RemoveTag("moon_spore_protection")
--                                 end
--                             end)
--                         end
--                     end
--                 end
--             end

--             -- 立即执行一次
--             ApplyMoonSporeProtection(inst, owner)

--             -- 启动周期性任务（1秒间隔）
--             inst._spore_protect_task = inst:DoPeriodicTask(1, function()
--                 ApplyMoonSporeProtection(inst, owner)
--             end)
--         end
--     end)
-- end)

local function ActivateMoonMushroomHatEffect(inst, buff_time, range, hat)
    local random_effect = math.random()
    if random_effect < 0.25 then 
        -- 小型孢子效果
        SpawnRandomizedSpore("spore_small", inst, buff_time, range)
        inst.buff_count_spore_small = inst.buff_count_spore_small + 1
        local buff_id = "spore_small_" .. inst.buff_count_spore_small
        
        if inst.components.damagetypebonus then
            inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, 1.2, buff_id)
        end
        if inst.components.damagetyperesist then
            inst.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.8, buff_id)
        end
        
        inst:DoTaskInTime(buff_time, function()
            if inst.components.damagetypebonus then
                inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, buff_id)
            end
            if inst.components.damagetyperesist then
                inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, buff_id)
            end
        end)
        
    elseif random_effect < 0.5 then
        -- 中型孢子效果
        SpawnRandomizedSpore("spore_medium", inst, buff_time, range)
        inst.buff_count_spore_medium = inst.buff_count_spore_medium + 1
        local buff_id = "spore_medium_" .. inst.buff_count_spore_medium
            
        if inst.components.combat then
            inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1.1, buff_id)
            inst:DoTaskInTime(buff_time, function()
                if inst.components.combat then
                    inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, buff_id)
                end
            end)
        end
        
    elseif random_effect < 0.75 then
        -- 大型孢子效果
        SpawnRandomizedSpore("spore_tall", inst, buff_time, range)
            
        inst.buff_count_spore_tall = inst.buff_count_spore_tall + 1
        local buff_id = "spore_tall_" .. inst.buff_count_spore_tall
        
        if inst.components.health and inst.components.health.externalabsorbmodifiers then
            inst.components.health.externalabsorbmodifiers:SetModifier(inst, 0.15, buff_id)
            inst:DoTaskInTime(buff_time, function()
                inst.components.health.externalabsorbmodifiers:RemoveModifier(inst, buff_id)
            end)
        end
        
    else
        -- 月亮孢子效果
        if hat.prefab == "moon_mushroomhat" then
            SpawnRandomizedSpore("spore_moon", inst, 1, range)    -- 释放的孢子立刻爆炸
        elseif hat.prefab == "wormwood_moon_mushroomhat" then
            SpawnRandomizedSpore("wormwood_spore_moon", inst, 1, range)
        end
    end
end

--为月亮蘑菇帽增加攻击随机触发孢子效果
AddPlayerPostInit(function(player)
    if not TheWorld.ismastersim or player.prefab ~= "wormwood" then return end
    
    -- 初始化计数器
    if not player.buff_count_spore_small then player.buff_count_spore_small = 0 end
    if not player.buff_count_spore_medium then player.buff_count_spore_medium = 0 end
    if not player.buff_count_spore_tall then player.buff_count_spore_tall = 0 end
    
    -- 监听攻击事件
    player:ListenForEvent("onattackother", function(inst, data)
        
        if not inst:HasTag("wormwood_mushroom_mushroomhat") then return end
        if not (data and data.target) then return end
        
        local hat = GetHat(inst)
        if not (hat and (hat.prefab == "moon_mushroomhat" or hat.prefab == "wormwood_moon_mushroomhat")) then return end

        local buff_time = moon_mushroomhat_buff_time
        local range = 1
        ActivateMoonMushroomHatEffect(inst, buff_time, range, hat)
        if player:HasTag("moon_charged_2") and player.components.bloomness.level == 3 then
            inst:DoTaskInTime(0.1, function(inst)
                ActivateMoonMushroomHatEffect(inst, buff_time, range, hat)
            end)
            player.components.bloomness.timer = player.components.bloomness.timer - moon_mushroomhat_consume_val
        end
    end)
end)