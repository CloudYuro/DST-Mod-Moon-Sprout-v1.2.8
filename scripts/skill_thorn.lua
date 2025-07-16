GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

local bramblefx_consume_val_1 = tonumber(GetModConfigData("bramblefx_consume_val_1"))
local bramblefx_consume_val_2 = tonumber(GetModConfigData("bramblefx_consume_val_2"))
local vine_consume_val = tonumber(GetModConfigData("vine_consume_val"))
local vine_chance_val = tonumber(GetModConfigData("vine_chance_val"))
local deciduoustree_consume_val = tonumber(GetModConfigData("deciduoustree_consume_val"))
local deciduoustree_time = tonumber(GetModConfigData("deciduoustree_time"))
local ivystaff_lunarplant_consume_val = tonumber(GetModConfigData("ivystaff_lunarplant_consume_val"))
local ivystaff_lunarplant_time = tonumber(GetModConfigData("ivystaff_lunarplant_time"))

AddPrefabPostInit("bee", function(inst)
    if inst.components.inventoryitem then 
        inst.components.inventoryitem.grabbableoverridetag = "wormwood_bugs"
    end
end)

AddPrefabPostInit("butterfly", function(inst)
    if inst.components.inventoryitem then 
        inst.components.inventoryitem.grabbableoverridetag = "wormwood_bugs"
    end
end)

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return end
    
    local function addbuff_cactus(inst, data)
        if not inst:HasTag("wormwood_thorn_cactus") or not data or not data.food or data.food.prefab ~= "cactus_meat" then return end
        
        if not inst.components.timer then
            inst:AddComponent("timer")
        end
        
        if not inst:HasTag("buff_cactus") then
            inst:AddTag("buff_cactus")
            inst.components.timer:StartTimer("buff_cactus", 30)
            inst.components.talker:Say(STRINGS.EAT_CACTUS_MEAT.eat_first)
        else
            if inst.components.timer:TimerExists("buff_cactus") then
                local time_left = inst.components.timer:GetTimeLeft("buff_cactus") or 0
                inst.components.timer:SetTimeLeft("buff_cactus", 30)
                inst.components.talker:Say(STRINGS.EAT_CACTUS_MEAT.eat_again)
            else
                inst.components.timer:StartTimer("buff_cactus", 30)
            end
        end
    end

    local function removebuff_cactus(inst, data)
        if data.name == "buff_cactus" then
            inst:RemoveTag("buff_cactus")
            inst.components.talker:Say(STRINGS.EAT_CACTUS_MEAT.eat_finish)
        end
    end

    inst:ListenForEvent("oneat", addbuff_cactus)
    inst:ListenForEvent("timerdone", removebuff_cactus)
end)

local MAXRANGE = 3
local NO_TAGS_NO_PLAYERS =	{ "bramble_resistant", "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion" }
local NO_TAGS =				{ "bramble_resistant", "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "playerghost" }
local COMBAT_TARGET_TAGS = { "_combat" }

local function OnUpdateThorns_with_cactus(inst)
    inst.range = inst.range + .75

    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, inst.range + 3, COMBAT_TARGET_TAGS, inst.canhitplayers and NO_TAGS or NO_TAGS_NO_PLAYERS)) do
        if not inst.ignore[v] and
            v:IsValid() and
            v.entity:IsVisible() and
            v.components.combat ~= nil and
            not (v.components.inventory ~= nil and
                v.components.inventory:EquipHasTag("bramble_resistant")) then
            local range = inst.range + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if inst.owner ~= nil and not inst.owner:IsValid() then
                    inst.owner = nil
                end
                if inst.owner ~= nil then
                    if inst.owner.components.combat ~= nil and
                        inst.owner.components.combat:CanTarget(v) and
                        not inst.owner.components.combat:IsAlly(v)
                    then
                        inst.ignore[v] = true
                        local cactus_damage = 0
                        if inst.owner:HasTag("buff_cactus") then
                            cactus_damage = 5
                        end
                        v.components.combat:GetAttacked(v.components.follower and v.components.follower:GetLeader() == inst.owner and inst or inst.owner, inst.damage + cactus_damage, nil, nil, inst.spdmg)
                        --V2C: wisecracks make more sense for being pricked by picking
                        --v:PushEvent("thorns")
                    end
                elseif v.components.combat:CanBeAttacked() then
                    -- NOTES(JBK): inst.owner is nil here so this is for non worn things like the bramble trap.
                    local isally = false
                    if not inst.canhitplayers then
                        --non-pvp, so don't hit any player followers (unless they are targeting a player!)
                        local leader = v.components.follower ~= nil and v.components.follower:GetLeader() or nil
                        isally = leader ~= nil and leader:HasTag("player") and
                            not (v.components.combat ~= nil and
                                v.components.combat.target ~= nil and
                                v.components.combat.target:HasTag("player"))
                    end
                    if not isally then
                        inst.ignore[v] = true
                        v.components.combat:GetAttacked(inst, inst.damage, nil, nil, inst.spdmg)
                        --v:PushEvent("thorns")
                    end
                end
            end
        end
    end

    if inst.range >= MAXRANGE then
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateThorns_with_cactus)
    end
end

AddPrefabPostInit("bramblefx_armor", function(inst)
    if not TheWorld.ismastersim then return end
    inst:DoTaskInTime(0, function(inst)
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateThorns_with_cactus)
    end)
end)

AddPrefabPostInit("bramblefx_armor_upgrade", function(inst)
    if not TheWorld.ismastersim then return end
    inst:DoTaskInTime(0, function(inst)
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateThorns_with_cactus)
    end)
end)

---------------------------------- 复制源码 ---------------------------------------
local builds =
{
    normal = { --Green
        leavesbuild="tree_leaf_green_build",
        prefab_name="deciduoustree",
        normal_loot = {"log", "log"},
        short_loot = {"log"},
        tall_loot = {"log", "log", "log", "acorn"},
        drop_acorns=true,
        fx="green_leaves",
        chopfx="green_leaves_chop",
        shelter=true,
    },
    barren = {
        leavesbuild=nil,
        prefab_name="deciduoustree",
        normal_loot = {"log", "log"},
        short_loot = {"log"},
        tall_loot = {"log", "log", "log"},
        drop_acorns=false,
        fx=nil,
        chopfx=nil,
        shelter=false,
    },
    red = {
        leavesbuild="tree_leaf_red_build",
        prefab_name="deciduoustree",
        normal_loot = {"log", "log"},
        short_loot = {"log"},
        tall_loot = {"log", "log", "log", "acorn"},
        drop_acorns=true,
        fx="red_leaves",
        chopfx="red_leaves_chop",
        shelter=true,
    },
    orange = {
        leavesbuild="tree_leaf_orange_build",
        prefab_name="deciduoustree",
        normal_loot = {"log", "log"},
        short_loot = {"log"},
        tall_loot = {"log", "log", "log", "acorn"},
        drop_acorns=true,
        fx="orange_leaves",
        chopfx="orange_leaves_chop",
        shelter=true,
    },
    yellow = {
        leavesbuild="tree_leaf_yellow_build",
        prefab_name="deciduoustree",
        normal_loot = {"log", "log"},
        short_loot = {"log"},
        tall_loot = {"log", "log", "log", "acorn"},
        drop_acorns=true,
        fx="yellow_leaves",
        chopfx="yellow_leaves_chop",
        shelter=true,
    },
    poison = {
        leavesbuild="tree_leaf_poison_build",
        prefab_name="deciduoustree",
        normal_loot = {"livinglog", "acorn", "acorn"},
        short_loot = {"livinglog", "acorn"},
        tall_loot = {"livinglog", "acorn", "acorn", "acorn"},
        drop_acorns=true,
        fx="purple_leaves",
        chopfx="purple_leaves_chop",
        shelter=true,
    },
}

local function makeanims(stage)
    if stage == "monster" then
        return {
            idle="idle_tall",
            sway1="sway_loop_agro",
            sway2="sway_loop_agro",
            swayaggropre="sway_agro_pre",
            swayaggro="sway_loop_agro",
            swayaggropst="sway_agro_pst",
            swayaggroloop="idle_loop_agro",
            swayfx="swayfx_tall",
            chop="chop_tall_monster",
            fallleft="fallleft_tall_monster",
            fallright="fallright_tall_monster",
            stump="stump_tall_monster",
            burning="burning_loop_tall",
            burnt="burnt_tall",
            chop_burnt="chop_burnt_tall",
            idle_chop_burnt="idle_chop_burnt_tall",
            dropleaves = "drop_leaves_tall",
            growleaves = "grow_leaves_tall",
        }
    else
        return {
            idle="idle_"..stage,
            sway1="sway1_loop_"..stage,
            sway2="sway2_loop_"..stage,
            swayaggropre="sway_agro_pre",
            swayaggro="sway_loop_agro",
            swayaggropst="sway_agro_pst",
            swayaggroloop="idle_loop_agro",
            swayfx="swayfx_"..stage,
            chop="chop_"..stage,
            fallleft="fallleft_"..stage,
            fallright="fallright_"..stage,
            stump="stump_"..stage,
            burning="burning_loop_"..stage,
            burnt="burnt_"..stage,
            chop_burnt="chop_burnt_"..stage,
            idle_chop_burnt="idle_chop_burnt_"..stage,
            dropleaves = "drop_leaves_"..stage,
            growleaves = "grow_leaves_"..stage,
        }
    end
end

local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local normal_anims = makeanims("normal")
local monster_anims = makeanims("monster")

local function GetBuild(inst)
    return builds[inst.build] or builds.normal
end

local function SpawnLeafFX(inst, waittime, chop)
    if (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or
        inst:HasTag("stump") or
        inst:HasTag("burnt") or
        inst:IsAsleep() then
        return
    elseif waittime ~= nil then
        inst:DoTaskInTime(waittime, SpawnLeafFX, nil, chop)
        return
    end

    local fx = nil
    if chop then
        if GetBuild(inst).chopfx ~= nil then
            fx = SpawnPrefab(GetBuild(inst).chopfx)
        end
    elseif GetBuild(inst).fx ~= nil then
        fx = SpawnPrefab(GetBuild(inst).fx)
    end
    if fx ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst.components.growable ~= nil then
            if inst.components.growable.stage == 1 then
                --y = y + 0 --Short FX height
            elseif inst.components.growable.stage == 2 then
                y = y - .3 --Normal FX height
            elseif inst.components.growable.stage == 3 then
                --y = y + 0 --Tall FX height
            end
        end
        --Randomize height a bit for chop FX
        fx.Transform:SetPosition(x, chop and y + math.random() * 2 or y, z)
    end
end

local function PushSway(inst, monster, monsterpost, skippre)
    if monster then
        inst.sg:GoToState("gnash_pre", { push = true, skippre = skippre })
    elseif monsterpost then
        inst.sg:GoToState(inst.sg:HasStateTag("gnash") and "gnash_pst" or "gnash_idle")
    elseif inst.monster then
        inst.sg:GoToState("gnash_idle")
    else
        inst.AnimState:PushAnimation(math.random() < .5 and inst.anims.sway1 or inst.anims.sway2, true)
    end
end

local function Sway(inst, monster, monsterpost)
    if inst.sg:HasStateTag("burning") or inst:HasTag("stump") then
        return
    elseif monster then
        inst.sg:GoToState("gnash_pre", { push = false, skippre = false })
    elseif monsterpost then
        inst.sg:GoToState(inst.sg:HasStateTag("gnash") and "gnash_pst" or "gnash_idle")
    elseif inst.monster then
        inst.sg:GoToState("gnash_idle")
    else
        inst.AnimState:PlayAnimation(math.random() < .5 and inst.anims.sway1 or inst.anims.sway2, true)
    end
end

local function UpdateIdleLeafFx(inst)
	if inst.leaf_state == "colorful" and inst.entity:IsAwake() then
		if inst.spawnleaffxtask == nil then
			inst.spawnleaffxtask = inst:DoPeriodicTask(math.random(TUNING.MIN_SWAY_FX_FREQUENCY, TUNING.MAX_SWAY_FX_FREQUENCY), SpawnLeafFX)
		end
	elseif inst.spawnleaffxtask ~= nil then
		inst.spawnleaffxtask:Cancel()
		inst.spawnleaffxtask = nil
	end
end

local function GrowLeavesFn(inst, monster, monsterout)
    if (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or
        inst:HasTag("stump") or
        inst:HasTag("burnt") then
        inst:RemoveEventCallback("animover", GrowLeavesFn)
        return
    end

    if inst.leaf_state == "barren" or inst.target_leaf_state == "barren" then
        inst:RemoveEventCallback("animover", GrowLeavesFn)
        if inst.target_leaf_state == "barren" then
            inst.build = "barren"
        end
    end

    if GetBuild(inst).leavesbuild then
        inst.AnimState:OverrideSymbol("swap_leaves", GetBuild(inst).leavesbuild, "swap_leaves")
    else
        inst.AnimState:ClearOverrideSymbol("swap_leaves")
    end

    if inst.components.growable ~= nil then
        if inst.components.growable.stage == 1 then
            inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
        elseif inst.components.growable.stage == 2 then
            inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)
        else
            inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)
        end
    end

    inst.leaf_state = inst.target_leaf_state
	UpdateIdleLeafFx(inst)
    if inst.leaf_state == "barren" then
        inst.AnimState:ClearOverrideSymbol("mouseover")
    else
        if inst.build == "barren" then
            inst.build = inst.leaf_state == "normal" and "normal" or "red"
        end
        inst.AnimState:OverrideSymbol("mouseover", "tree_leaf_trunk_build", "toggle_mouseover")
    end

    if monster ~= true and monsterout ~= true then
        Sway(inst)
    end
end

local function OnChangeLeaves(inst, monster, monsterout)
    if (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or
        inst:HasTag("stump") or
        inst:HasTag("burnt") then
        inst.targetleaveschangetime = nil
        inst.leaveschangetask = nil
        return
    elseif not monster and inst.components.workable and inst.components.workable.lastworktime and inst.components.workable.lastworktime < GetTime() - 10 then
        inst.targetleaveschangetime = GetTime() + 11
        inst.leaveschangetask = inst:DoTaskInTime(11, OnChangeLeaves)
        return
    else
        inst.targetleaveschangetime = nil
        inst.leaveschangetask = nil
    end

    if inst.target_leaf_state ~= "barren" then
        if inst.target_leaf_state == "colorful" then
            local rand = math.random()
            inst.build = ({ "red", "orange", "yellow" })[math.random(3)]
            inst.AnimState:SetMultColour(1, 1, 1, 1)
        elseif inst.target_leaf_state == "poison" then
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.build = "poison"
        else
            inst.AnimState:SetMultColour(inst.color, inst.color, inst.color, 1)
            inst.build = "normal"
        end

        if inst.leaf_state == "barren" then
            if GetBuild(inst).leavesbuild then
                inst.AnimState:OverrideSymbol("swap_leaves", GetBuild(inst).leavesbuild, "swap_leaves")
            else
                inst.AnimState:ClearOverrideSymbol("swap_leaves")
            end
            inst.AnimState:PlayAnimation(inst.anims.growleaves)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            inst:ListenForEvent("animover", GrowLeavesFn)
        else
            GrowLeavesFn(inst, monster, monsterout)
        end
    else
        inst.AnimState:PlayAnimation(inst.anims.dropleaves)
        SpawnLeafFX(inst, 11 * FRAMES)
        inst.SoundEmitter:PlaySound("dontstarve/forest/treeWilt")
        inst:ListenForEvent("animover", GrowLeavesFn)
    end
    if GetBuild(inst).shelter then
        inst:AddTag("shelter")
    else
        inst:RemoveTag("shelter")
    end

    if monster then
        inst:RemoveComponent("waxable")

    elseif inst.components.waxable == nil then
        MakeWaxablePlant(inst)
    end
end

local function ChangeSizeFn(inst)
    inst:RemoveEventCallback("animover", ChangeSizeFn)
    if inst.components.growable ~= nil then
        inst.anims =
            (inst.components.growable.stage == 1 and short_anims) or
            (inst.components.growable.stage == 2 and normal_anims) or
            (inst.monster and monster_anims) or
            tall_anims
    end
    Sway(inst, nil, inst.monster)
end

local function SetShort(inst)
    if not inst.monster then
        inst.anims = short_anims
        if inst.components.workable ~= nil then
           inst.components.workable:SetWorkLeft(TUNING.DECIDUOUS_CHOPS_SMALL)
        end
        inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
    end
end

local function GrowShort(inst)
    if not inst.monster then
        inst.AnimState:PlayAnimation("grow_tall_to_short")
        if inst.leaf_state == "colorful" then
            SpawnLeafFX(inst, 17 * FRAMES)
        end
        inst:ListenForEvent("animover", ChangeSizeFn)
        inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    end
end

local function SetNormal(inst)
    inst.anims = normal_anims
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(TUNING.DECIDUOUS_CHOPS_NORMAL)
    end
    inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)
end

local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    if inst.leaf_state == "colorful" then
        SpawnLeafFX(inst, 10 * FRAMES)
    end
    inst:ListenForEvent("animover", ChangeSizeFn)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
end

local function SetTall(inst)
    inst.anims = tall_anims
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(TUNING.DECIDUOUS_CHOPS_TALL)
    end
    inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)
end

local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    if inst.leaf_state == "colorful" then
        SpawnLeafFX(inst, 10 * FRAMES)
    end
    inst:ListenForEvent("animover", ChangeSizeFn)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
end

local growth_stages =
{
    { name = "short", time = function(inst) return GetRandomWithVariance(TUNING.DECIDUOUS_GROW_TIME[1].base, TUNING.DECIDUOUS_GROW_TIME[1].random) end, fn = SetShort, growfn = GrowShort },
    { name = "normal", time = function(inst) return GetRandomWithVariance(TUNING.DECIDUOUS_GROW_TIME[2].base, TUNING.DECIDUOUS_GROW_TIME[2].random) end, fn = SetNormal, growfn = GrowNormal },
    { name = "tall", time = function(inst) return GetRandomWithVariance(TUNING.DECIDUOUS_GROW_TIME[3].base, TUNING.DECIDUOUS_GROW_TIME[3].random) end, fn = SetTall, growfn = GrowTall },
    --{ name = "old", time = function(inst) return GetRandomWithVariance(TUNING.DECIDUOUS_GROW_TIME[4].base, TUNING.DECIDUOUS_GROW_TIME[4].random) end, fn = SetOld, growfn = GrowOld },
}

local FINDTREETOTRANSFORM_MUST_TAGS = { "birchnut" }
local FINDTREETOTRANSFORM_CANT_TAGS = { "fire", "stump", "burnt", "monster", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local ALLY_TAGS = {
    "player",
    "wormwood_pet",
    "wormwood_lunarplant",
    "wormwood_gestalt_guard",
    "wormwood_lunar_grazer",
    "wormwood_deciduous",
}

local function IsAllyTarget(inst)
    if inst:HasOneOfTags(ALLY_TAGS)
    or (inst.components.follower 
    and inst.components.follower:GetLeader() 
    and inst.components.follower:GetLeader():HasTag("player")) then
        return true
    end
    return false
end

local function IsEnemyTarget(inst)
    if inst:HasOneOfTags(ALLY_TAGS) then
        return false
    end
    if inst.components.combat and inst.components.combat.target then
        local target = inst.components.combat.target
        if target:HasOneOfTags(ALLY_TAGS)
        or (target.components.follower 
        and target.components.follower:GetLeader() 
        and target.components.follower:GetLeader():HasTag("player")) then
            return true
        end
    end
    return false
end

local DRAKESPAWNTARGET_MUST_TAGS = { "_combat" } --see entityreplica.lua
local DRAKESPAWNTARGET_CANT_TAGS = { "flying", "birchnutdrake", "wall" }

local function OnPassDrakeSpawned_allydrake(passdrake)
    if passdrake.components.combat ~= nil then
        local target = FindEntity(
                passdrake,
                TUNING.DECID_MONSTER_TARGET_DIST * 4,
                function(guy)
                    -- 修改索敌逻辑
                    if guy:HasOneOfTags({"nightmarecreature", "shadowcreature"}) then
                        return nil
                    end
                    if guy:HasTag("hostile") then 
                        return true
                    end
                    local guy_target = guy.components.combat and guy.components.combat.target
                    if guy_target ~= nil and IsAllyTarget(guy_target) and IsEnemyTarget(guy) then
                        return passdrake.components.combat:CanTarget(guy)
                    end
                end,
                DRAKESPAWNTARGET_MUST_TAGS,
                DRAKESPAWNTARGET_CANT_TAGS
            )
        if target ~= nil then
            passdrake.components.combat:SuggestTarget(target)
        end
    end
end

local function OnDrakeSpawnTask_allydrake(inst, self, pos, sectorsize)
    if self.numdrakes > 0 then
        local drake = SpawnPrefab("birchnutdrake")
        drake:AddTag("companion")
        drake:AddTag("wormwood_deciduous")
        drake.components.lootdropper:ClearRandomLoot()
        local minang = sectorsize * (self.numdrakes - 1) >= 0 and sectorsize * (self.numdrakes - 1) or 0
        local maxang = sectorsize * self.numdrakes <= 360 and sectorsize * self.numdrakes or 360
        local offset = FindWalkableOffset(pos, math.random(minang, maxang) * DEGREES, GetRandomMinMax(2, TUNING.DECID_MONSTER_TARGET_DIST), 30, false, false, NoHoles)
        if offset ~= nil then
            drake.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
        else
            drake.Transform:SetPosition(pos:Get())
        end
        drake.target = self.monster_target or self.last_monster_target
        drake:DoTaskInTime(0, OnDrakeSpawned)
        self.numdrakes = self.numdrakes - 1
    else
        self.drakespawntask:Cancel()
        self.drakespawntask = nil
    end
end

function OnUpdate_allytree(self, dt)
    if self.monster and self.inst.monster_start_time and ((GetTime() - self.inst.monster_start_time) > self.inst.monster_duration) then
        self.monster = false
        if self.inst.monster_start_task ~= nil then
            self.inst.monster_start_task:Cancel()
            self.inst.monster_start_task = nil
        end
        if self.inst.monster and
            not (self.inst.components.burnable ~= nil and
                self.inst.components.burnable:IsBurning()) and
            not self.inst:HasTag("stump") and
            not self.inst:HasTag("burnt") then
            if self.inst.monster_stop_task == nil then
                self.inst.monster_stop_task = self.inst:DoTaskInTime(math.random(0, 2), OnStopMonster)
            end
        end
        return
    end

    if self.monster then
        -- We want to spawn drakes at some interval
        if self.time_to_passive_drake <= 0 then
            if self.num_passive_drakes <= 0 then
                self.num_passive_drakes = math.random() < .33 and TUNING.PASSIVE_DRAKE_SPAWN_NUM_LARGE or TUNING.PASSIVE_DRAKE_SPAWN_NUM_NORMAL
                self.passive_drakes_spawned = 0
            elseif self.passive_drakes_spawned < self.num_passive_drakes then
                local passdrake = SpawnPrefab("birchnutdrake")
                passdrake:AddTag("companion")
                passdrake:AddTag("wormwood_deciduous")
                passdrake.components.lootdropper:ClearRandomLoot()
                local pos = self.inst:GetPosition()
                local passoffset = FindWalkableOffset(pos, math.random() * TWOPI, GetRandomMinMax(2, TUNING.DECID_MONSTER_TARGET_DIST * 1.5), 30, false, false, NoHoles)
                if passoffset ~= nil then
                    passdrake.Transform:SetPosition(pos.x + passoffset.x, 0, pos.z + passoffset.z)
                else
                    passdrake.Transform:SetPosition(pos:Get())
                end
                passdrake.range = TUNING.DECID_MONSTER_TARGET_DIST * 4
                passdrake:DoTaskInTime(0, OnPassDrakeSpawned_allydrake)
                self.passive_drakes_spawned = self.passive_drakes_spawned + 1
            else
                self.num_passive_drakes = 0
                self.time_to_passive_drake = GetRandomWithVariance(TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL,TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE)
            end
        else
            self.time_to_passive_drake = self.time_to_passive_drake - dt
        end

        -- We only want to do the thinking for roots and proximity-drakes so often
        if self.monsterTime > 0 then
            self.monsterTime = self.monsterTime - dt
        else
            local targdist = TUNING.DECID_MONSTER_TARGET_DIST
            -- Look for nearby targets (anything not flying, a wall or a drake)
            self.monster_target =
                self.inst.components.combat ~= nil and
                FindEntity(
                    self.inst,
                    targdist * 1.5,
                    function(guy)
                        -- 修改索敌逻辑
                        if guy:HasOneOfTags({"nightmarecreature", "shadowcreature"}) then
                            return nil
                        end
                        if guy:HasTag("hostile") then 
                            return true
                        end
                        local guy_target = guy.components.combat and guy.components.combat.target
                        if guy_target ~= nil and IsAllyTarget(guy_target) and IsEnemyTarget(guy) then
                            return self.inst.components.combat:CanTarget(guy)
                        end
                    end,
                    DRAKESPAWNTARGET_MUST_TAGS, --see entityreplica.lua
                    DRAKESPAWNTARGET_CANT_TAGS
                ) or nil

            if self.monster_target ~= nil and self.last_monster_target ~= nil and GetTime() - self.last_attack_time > TUNING.DECID_MONSTER_ATTACK_PERIOD then
                -- Spawn a root spike and give it a target
                self.last_attack_time = GetTime()
                self.root = SpawnPrefab("wormwood_deciduous_root")
                local x, y, z = self.inst.Transform:GetWorldPosition()
                local mx, my, mz = self.monster_target.Transform:GetWorldPosition()
                local mdistsq = distsq(x, z, mx, mz)
                local targdistsq = targdist * targdist
                local rootpos = Vector3(mx, 0, mz)
                local angle = self.inst:GetAngleToPoint(rootpos) * DEGREES
                if mdistsq > targdistsq then
                    rootpos.x = x + math.cos(angle) * targdist
                    rootpos.z = z - math.sin(angle) * targdist
                end

                self.root.Transform:SetPosition(x + 1.75 * math.cos(angle), 0, z - 1.75 * math.sin(angle))
                self.root:PushEvent("givetarget", { target = self.monster_target, targetpos = rootpos, targetangle = angle, owner = self.inst })

                -- If we haven't spawned drakes yet and the player is close enough, spawn drakes
                if not self.spawneddrakes and mdistsq < targdistsq * .25 then
                    self.spawneddrakes = true
                    self.time_to_passive_drake = GetRandomWithVariance(TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL,TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE)
                    self.numdrakes = math.random(TUNING.MIN_TREE_DRAKES, TUNING.MAX_TREE_DRAKES)
                    if self.drakespawntask ~= nil then
                        self.drakespawntask:Cancel()
                    end
                    self.drakespawntask = self.numdrakes > 0 and self.inst:DoPeriodicTask(6 * FRAMES, OnDrakeSpawnTask_allydrake, nil, self, Vector3(x, y, z), 360 / self.numdrakes) or nil
                end
            end

            if self.monster_target ~= nil and self.last_monster_target == nil and not self.inst.sg:HasStateTag("burning") then
                self.inst:PushEvent("sway", {monster=true, monsterpost=nil})
            elseif self.monster_target == nil and self.last_monster_target ~= nil and not self.inst.sg:HasStateTag("burning") then
                self.inst:PushEvent("sway", {monster=nil, monsterpost=true})
            end
            self.last_monster_target = self.monster_target
            self.monsterTime = self.monsterFreq
        end
    end
end


local function DoStartMonster(inst, starttimeoffset)
	inst.dostartmonster_task = nil
    if inst.components.workable ~= nil then
       inst.components.workable:SetWorkLeft(TUNING.DECIDUOUS_CHOPS_MONSTER)
    end
    inst.AnimState:SetBank("tree_leaf_monster")
    inst.AnimState:PlayAnimation("transform_in")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/transform_in")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/transform_voice")
    SpawnLeafFX(inst, 7 * FRAMES)
    local leavesbuild = GetBuild(inst).leavesbuild
    if leavesbuild ~= nil then
        inst.AnimState:OverrideSymbol("legs", leavesbuild, "legs")
        inst.AnimState:OverrideSymbol("legs_mouseover", leavesbuild, "legs_mouseover")
        inst.AnimState:OverrideSymbol("eye", leavesbuild, "eye")
        inst.AnimState:OverrideSymbol("mouth", leavesbuild, "mouth")
    else
        inst.AnimState:ClearOverrideSymbol("legs")
        inst.AnimState:ClearOverrideSymbol("legs_mouseover")
        inst.AnimState:ClearOverrideSymbol("eye")
        inst.AnimState:ClearOverrideSymbol("mouth")
    end
    if inst.components.combat == nil then
        inst:AddComponent("combat")
    end
    if inst.components.deciduoustreeupdater == nil then
        inst:AddComponent("deciduoustreeupdater")
    end
    -- 修改索敌逻辑
    inst:AddTag("wormwood_deciduous")
    inst.components.deciduoustreeupdater.OnUpdate = OnUpdate_allytree
    inst.components.deciduoustreeupdater:StartMonster(starttimeoffset)
end

local function DoStartMonsterChangeLeaves(inst)
    OnChangeLeaves(inst, true)
    inst.components.growable:StopGrowing()
end

local function StartMonster(inst, force, starttimeoffset)
    -- Become a monster. Requires tree to have leaves and be medium size (it will grow to large size when become monster)
    if force or (inst.anims == normal_anims and inst.leaf_state ~= "barren") then
        inst.monster = true
        inst.target_leaf_state = "poison"
        inst:RemoveTag("cattoyairborne")

        if inst.leaveschangetask ~= nil then
            inst.leaveschangetask:Cancel()
            inst.leaveschangetask = nil
        end

        if force then
            OnChangeLeaves(inst, true)
        else
            inst.components.growable:DoGrowth()
            inst:DoTaskInTime(12 * FRAMES, DoStartMonsterChangeLeaves)
        end

		inst.dostartmonster_task = inst:DoTaskInTime(26 * FRAMES, DoStartMonster, starttimeoffset)
    end
end

local function DoStopMonster(inst)
    inst.domonsterstop_task = nil
    inst.AnimState:ClearOverrideSymbol("eye")
    inst.AnimState:ClearOverrideSymbol("mouth")
    if not inst:HasTag("stump") then
        inst.AnimState:ClearOverrideSymbol("legs")
        inst.AnimState:ClearOverrideSymbol("legs_mouseover")
        inst.components.growable:StartGrowing()
    end
    inst.AnimState:SetBank("tree_leaf")
    inst:AddTag("cattoyairborne")

    inst.target_leaf_state =
        (TheWorld.state.isautumn and "colorful") or
        (TheWorld.state.iswinter and "barren") or
        "normal"

    inst.components.growable:DoGrowth()
    inst:DoTaskInTime(12 * FRAMES, OnChangeLeaves, false, true)
end

local function StopMonster(inst)
    -- Return to normal tree behavior (also grow from tall to short)
    if inst.monster then
        inst.monster = false
        inst.monster_start_time = nil
        inst.monster_duration = nil
        inst:RemoveComponent("deciduoustreeupdater")
        inst:RemoveComponent("combat")
        if not (inst:HasTag("stump") or inst:HasTag("burnt")) then
            inst.AnimState:PlayAnimation("transform_out")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/transform_out")
            SpawnLeafFX(inst, 8 * FRAMES)
            inst.sg:GoToState("empty")
        end
        if inst.domonsterstop_task ~= nil then
            inst.domonsterstop_task:Cancel()
        end
        inst.domonsterstop_task = inst:DoTaskInTime(16 * FRAMES, DoStopMonster)
    end
end

---------------------------------------------------------------------------

AddPrefabPostInit("deciduoustree", function(inst)
    if not TheWorld.ismastersim then return end

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
            if old_onload then
                old_onload(inst, data)
            end
        if inst.components.timer:TimerExists("expire_monster") then
            -- 修改索敌逻辑
            inst:AddTag("wormwood_deciduous")
            inst:AddComponent("combat")
            inst:AddComponent("deciduoustreeupdater")
            inst.components.deciduoustreeupdater.OnUpdate = OnUpdate_allytree
            inst:ListenForEvent("timerdone", function(inst, data)
                if data.name == "expire_monster" then
                    StopMonster(inst)
                end
            end)
        end
    end
end)

-- 种植桦树精
AddPrefabPostInit("acorn", function(inst)
    if not inst.components.deployable then return end
    inst.components.deployable.ondeploy = function(inst, pt, deployer)
        inst = inst.components.stackable:Get()
        inst:Remove()

        local timeToGrow = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
        -- plant(pt, timeToGrow)
        
        local sapling = SpawnPrefab("acorn_sapling")
        sapling:StartGrowing()
        sapling.Transform:SetPosition(pt:Get())
        sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")

        -- Pacify a nearby monster tree
        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.DECID_MONSTER_ACORN_CHILL_RADIUS, PACIFYTARGET_MUST_TAGS, PACIFYTARGET_CANT_TAGS)
        local ent
        for i, v in ipairs(ents) do
            if v.entity:IsVisible() then
                ent = v
                break
            end
        end

        if ent ~= nil then
            if ent.monster_start_task ~= nil then
                ent.monster_start_task:Cancel()
                ent.monster_start_task = nil
            end
            if ent.monster and
                ent.monster_stop_task == nil and
                not (ent.components.burnable ~= nil and ent.components.burnable:IsBurning()) and
                not (ent:HasTag("stump") or ent:HasTag("burnt")) then
                ent.monster_stop_task = ent:DoTaskInTime(math.random(0, 3), domonsterstop)
            end
        end

        if not deployer:HasTag("wormwood_thorn_deciduoustree") or not deployer:HasTag("moon_charged_1")
            or deployer.components.bloomness.timer < deciduoustree_consume_val then return end

        deployer:RemoveTag("moon_charged_1")
        deployer.components.bloomness.timer = deployer.components.bloomness.timer - deciduoustree_consume_val

        local tree = sapling
        tree:DoTaskInTime(1, function()
            tree = SpawnPrefab("deciduoustree_short")
            tree.Transform:SetPosition(sapling.Transform:GetWorldPosition())
            tree.AnimState:PlayAnimation("grow_seed_to_short")
            tree.components.growable:SetStage(1)
            if tree.leaf_state == "colorful" then
                SpawnLeafFX(tree, 5 * FRAMES)
            end
            tree.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            tree.anims = short_anims

            UpdateIdleLeafFx(tree)
            PushSway(tree)

            sapling:Remove()

            tree:DoTaskInTime(tree.AnimState:GetCurrentAnimationLength(), function()
                GrowNormal(tree)
                SetNormal(tree)
                tree.components.growable:SetStage(2)

                tree:DoTaskInTime(tree.AnimState:GetCurrentAnimationLength(), function()
                    GrowTall(tree)
                    SetTall(tree)
                    tree.components.growable:SetStage(3)

                    tree.components.timer:StartTimer("expire_monster", deciduoustree_time)
                    tree:ListenForEvent("timerdone", function(inst, data)
                        if data.name == "expire_monster" then
                            StopMonster(tree)
                        end
                    end)
                    StartMonster(tree, true)
                end)
            end)
        end)
    end
end)

AddPrefabPostInit("wormwood", function(inst)
    if not TheWorld.ismastersim then return end

    inst.deciduous_available = true

    local function TreeAssist(inst, can_assist)
        if not (inst.deciduous_available and can_assist) then return end
        inst.deciduous_available = false

        inst.components.timer:StartTimer("deciduous_available", 480)

        local tree = FindEntity(
            inst,
            15,
            function(tree)
                if tree.monster ~= true 
                and tree.components.growable.stage > 1 
                and not (tree.components.burnable ~= nil and tree.components.burnable:IsBurning()) then
                    return tree
                end
            end,
            {"deciduoustree"},
            {"stump", "burnt"}
        )
        if tree ~= nil then
        else
        end

        if tree then
            if tree.components.growable.stage == 2 then
                GrowTall(tree)
                SetTall(tree)
                tree.components.growable:SetStage(3)
            end
            tree.components.timer:StartTimer("expire_monster", deciduoustree_time)
            tree:ListenForEvent("timerdone", function(inst, data)
                if data.name == "expire_monster" then
                    StopMonster(tree)
                end
            end)
            StartMonster(tree, true)
            
            if math.random() < 0.33 then
                inst.components.talker:Say(STRINGS.DECIDUOUS_ASSIST.announce_1)
            elseif math.random() < 0.66 then
                inst.components.talker:Say(STRINGS.DECIDUOUS_ASSIST.announce_2)
            else
                inst.components.talker:Say(STRINGS.DECIDUOUS_ASSIST.announce_3)
            end
        end
    end

    -- 挨打时摇人
    inst:ListenForEvent("attacked", function(inst, data)
        if not inst:HasTag("wormwood_thorn_deciduoustree") then return end

        local can_assist = false

        -- 设置可触发桦树支援的条件
        if data.attacker ~= nil 
        and not data.attacker:HasOneOfTags({"nightmarecreature", "shadowcreature"}) 
        and inst.components.health:GetPercent() < 0.5
        and math.random() < 0.5 then
            can_assist = true
        end

        TreeAssist(inst, can_assist)
    end)

    -- 揍人时摇人
    inst:ListenForEvent("onattackother", function(inst, data)
        if not inst:HasTag("wormwood_thorn_deciduoustree") then return end

        local can_assist = false

        -- 设置可触发桦树支援的条件
        local probability = math.random()
        -- GLOBAL.TheNet:Announce("Probability:" .. probability)
        if probability < 0.1 then
            can_assist = true
        end

        TreeAssist(inst, can_assist)
    end)

    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "deciduous_available" then
            inst.deciduous_available = true
        end
    end)
end)

AddPrefabPostInit("ivystaff", function(inst)
    if not TheWorld.ismastersim then return end
    
    local function KillOffSnares(inst)
        local snares = inst.snares
        if snares ~= nil then
            inst.snares = nil

            for _, v in ipairs(snares) do
                if v:IsValid() then
                    v.owner = nil
                    v:KillOff()
                end
            end
        end
    end

    local function onsnaredeath(snare)
        local inst = (snare.owner ~= nil and snare.owner:IsValid()) and snare.owner or nil
        if inst ~= nil then
            KillOffSnares(inst)
        end
    end

    local function dosnaredamage(inst, target)
        if target:IsValid() and target.components.health ~= nil and not target.components.health:IsDead() and target.components.combat ~= nil then
            if target:HasTag("player") then
                target.components.combat:GetAttacked(inst, 10)
            else
                target.components.combat:GetAttacked(inst, 30)
            end
            target:PushEvent("snared", { attacker = inst, announce = "ANNOUNCE_SNARED_IVY" })
        end
    end

    local function SpawnSnare(inst, x, z, r, num, target)
        local count = 0
        local dtheta = TWOPI / num
        local delaytoggle = 0
        local map = TheWorld.Map
        for theta = math.random() * dtheta, TWOPI, dtheta do
            local x1 = x + r * math.cos(theta)
            local z1 = z + r * math.sin(theta)
            if map:IsPassableAtPoint(x1, 0, z1, false, true) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
                local snare = SpawnPrefab("ivy_snare")
                -- if not target:HasTag("player") then
                --     snare.components.health:SetMaxHealth(300)
                -- end
                snare.Transform:SetPosition(x1, 0, z1)
                snare:AddComponent("timer")
                -- snare:AddTag("NOCLICK")  -- 避免强制攻击锁定荆棘
                snare:AddTag("companion")
                snare.components.timer:StartTimer("expire", 30)
                snare:ListenForEvent("timerdone", function(inst)
                    snare:KillOff()
                end)

                local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
                delaytoggle = delaytoggle == 1 and -1 or 1

                snare.owner = inst
                snare.target = target
                snare.target_max_dist = r + 1.0
                snare:RestartSnare(delay)

                table.insert(inst.snares, snare)
                inst:ListenForEvent("death", onsnaredeath, snare)
                count = count + 1
            end
        end

        return count > 0
    end

    local function SpawnSealedBrambleWall(inst, center_pos, radius, thickness, count, height_offset)
        local spawned = {}
        local angle_step = (2 * PI) / count
        
        for i = 1, count do
            inst:DoTaskInTime((i-1)*0.05, function() -- 保留生成延迟（非持久化部分）
                local angle = angle_step * i
                local base_pos = center_pos + Vector3(
                    radius * math.cos(angle),
                    height_offset or 0,
                    radius * math.sin(angle))
                
                local offset_angle = angle + (math.random() * 0.5 - 0.25) * PI
                local offset_length = math.random() * thickness
                local final_pos = base_pos + Vector3(
                    offset_length * math.cos(offset_angle),
                    0,
                    offset_length * math.sin(offset_angle))
                
                if TheWorld.Map:IsPassableAtPoint(final_pos:Get()) then
                    local bramble = SpawnPrefab("bramblespike")
                    bramble.Transform:SetPosition(final_pos:Get())
                    bramble.Transform:SetRotation((angle + math.random() * 0.5) * RADIANS)
                    table.insert(spawned, bramble)
                end

                inst.components.perishable:SetPercent(inst.components.perishable:GetPercent() - 0.005)
            end)
        end
        return spawned
    end

    local function onattack(inst, attacker, target)

        -- attacker.SoundEmitter:PlaySound(inst.skin_sound)
        if not target:IsValid() then
            --target killed or removed in combat damage phase
            return
        end


        inst.snares = {}
        local x, y, z = target.Transform:GetWorldPosition()
        local islarge = target:HasTag("largecreature")
        local r = target:GetPhysicsRadius(0) + (islarge and 1.4 or .4)
        local num = islarge and 12 or 6
        if SpawnSnare(inst, x, z, r, num, target) then
            attacker:DoTaskInTime(0.25, dosnaredamage, target)
        end

        inst.components.perishable:SetPercent(inst.components.perishable:GetPercent() - 0.05)  -- 每次消耗 5% 新鲜度
    
        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
            target.components.sleeper:WakeUp()
        end

        if target.components.combat ~= nil then
            target.components.combat:SuggestTarget(attacker)
        end

        if not (attacker:HasTag("wormwood_thorn_ivystaff") or attacker.components.inventory:EquipHasTag("bramble_resistant")) then 
            inst.snares = {}
            local x, y, z = attacker.Transform:GetWorldPosition()
            local islarge = attacker:HasTag("largecreature")
            local r = attacker:GetPhysicsRadius(0) + (islarge and 1.4 or .4)
            local num = islarge and 12 or 6
            if SpawnSnare(inst, x, z, r, num, attacker) then
                attacker:DoTaskInTime(0.25, dosnaredamage, attacker)
            end
        end
    end

    local function OnHit(inst, attacker)
        inst.persists = true
        inst:RemoveTag("NOCLICK")
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:KillSound("spin_loop")
        inst.SoundEmitter:PlaySound("wilson_rework/torch/stick_ground")
        inst.components.inventoryitem.canbepickedup = true

        if  attacker.components.bloomness and attacker.components.bloomness.timer >= ivystaff_lunarplant_consume_val 
            and attacker:HasTag("moon_charged_2") and attacker:HasTag("wormwood_thorn_ivystaff") then
            attacker.components.bloomness.timer = attacker.components.bloomness.timer - ivystaff_lunarplant_consume_val
            attacker:RemoveTag("moon_charged_2")
            attacker.AnimState:ClearBloomEffectHandle("shaders/anim.ksh")
            
            -- 生成亮茄
            local lunarthrall_plant = SpawnPrefab("wormwood_lunarthrall_plant")
            lunarthrall_plant.Transform:SetPosition(inst.Transform:GetWorldPosition())
            lunarthrall_plant.sg:GoToState("spawn")
            local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
            fx.Transform:SetScale(1.5, 1.5, 1.5)
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:Remove()
            
        else
            local pos = inst:GetPosition()

            SpawnSealedBrambleWall(inst, pos, 4.5, 1.2, 24, 0)
            inst:DoTaskInTime(0.5, function() SpawnSealedBrambleWall(inst, pos, 6.0, 1.5, 32, 0) end)
        end

        
        if not (attacker:HasTag("wormwood_thorn_ivystaff") or attacker.components.inventory:EquipHasTag("bramble_resistant")) then 
            inst.snares = {}
            local x, y, z = attacker.Transform:GetWorldPosition()
            local islarge = attacker:HasTag("largecreature")
            local r = attacker:GetPhysicsRadius(0) + (islarge and 1.4 or .4)
            local num = islarge and 12 or 6
            if SpawnSnare(inst, x, z, r, num, attacker) then
                attacker:DoTaskInTime(0.25, dosnaredamage, attacker)
            end
        end
    end

    inst.components.weapon:SetOnAttack(onattack)    
    inst.components.complexprojectile:SetOnHit(OnHit)
end)

AddPrefabPostInit("wormwood_lunarthrall_plant", function(inst)
    if not TheWorld.ismastersim then return end

    inst.components.timer:StartTimer("expire", ivystaff_lunarplant_time)
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "expire" then
            local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
            fx.Transform:SetScale(1.5, 1.5, 1.5)
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            local eggplant = SpawnPrefab("eggplant")
            eggplant.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:Remove() 
        end
    end)
end)

AddPrefabPostInit("armor_bramble", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local function OnCooldown(inst)
        inst._cdtask = nil
    end

    local function DoThorns(inst, owner)
        --V2C: tiny CD to limit chain reactions
        inst._cdtask = inst:DoTaskInTime(.3, OnCooldown)

        if inst._hitcount then
            inst._hitcount = 0
        end

        SpawnPrefab("bramblefx_armor"):SetFXOwner(owner)

        if owner.SoundEmitter ~= nil then
            owner.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
        end
    end

    inst._onattackother = function(owner, data)
        if owner.components.bloomness and owner.components.bloomness.level == 3 then
            if owner:HasTag("moon_charged_1") and owner:HasTag("wormwood_armor_bramble") then 
                owner.components.bloomness.timer = owner.components.bloomness.timer - bramblefx_consume_val_1
                inst._hitcount = inst._hitcount + 1
            elseif owner:HasTag("moon_charged_2") and owner:HasTag("wormwood_allegiance_lunar_plant_gear_1") then 
                owner.components.bloomness.timer = owner.components.bloomness.timer - bramblefx_consume_val_2
                DoThorns(inst, owner)
                return
            end
        end

        if inst._cdtask == nil and
            owner.components.skilltreeupdater and
            owner.components.skilltreeupdater:IsActivated("wormwood_armor_bramble")
        then
            inst._hitcount = inst._hitcount + 1

            if inst._hitcount >= TUNING.WORMWOOD_ARMOR_BRAMBLE_RELEASE_SPIKES_HITCOUNT then
                DoThorns(inst, owner)
            end
        else
            inst._hitcount = 0
        end
    end
end)


AddPrefabPostInit("armor_lunarplant_husk", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local function OnCooldown(inst)
        inst._cdtask = nil
    end

    local function DoThorns(inst, owner)
        --V2C: tiny CD to limit chain reactions
        inst._cdtask = inst:DoTaskInTime(.3, OnCooldown)

        if inst._hitcount then
            inst._hitcount = 0
        end
        
        SpawnPrefab("bramblefx_armor_upgrade"):SetFXOwner(owner)        

        if owner.SoundEmitter ~= nil then
            owner.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
        end
    end

    inst._onattackother = function(owner, data)
        if owner.components.bloomness and owner.components.bloomness.level == 3 then
            if owner:HasTag("moon_charged_1") and owner:HasTag("wormwood_armor_bramble") then 
                owner.components.bloomness.timer = owner.components.bloomness.timer - bramblefx_consume_val_1
                inst._hitcount = inst._hitcount + 1
            elseif owner:HasTag("moon_charged_2") and owner:HasTag("wormwood_allegiance_lunar_plant_gear_1") then 
                owner.components.bloomness.timer = owner.components.bloomness.timer - bramblefx_consume_val_2
                DoThorns(inst, owner)
                return
            end
        end

        if inst._cdtask == nil and
            owner.components.skilltreeupdater and
            owner.components.skilltreeupdater:IsActivated("wormwood_armor_bramble")
        then
            inst._hitcount = inst._hitcount + 1

            if inst._hitcount >= TUNING.WORMWOOD_ARMOR_BRAMBLE_RELEASE_SPIKES_HITCOUNT then
                DoThorns(inst, owner)
            end
        else
            inst._hitcount = 0
        end
    end
end)

AddComponentPostInit("lunarplant_tentacle_weapon", function(self)
    local old_OnAttack = self.OnAttack
    
    function self:OnAttack(owner, attack_data)
        if attack_data == nil or attack_data.weapon ~= self.inst then
            return
        elseif self.should_do_tentacles_fn and not self.should_do_tentacles_fn(self.inst, owner, attack_data) then
            return
        end

        local target = attack_data.target
        local spawn_chance = self.spawn_chance
        if owner.components.bloomness and owner.components.bloomness.level == 3 
            and owner:HasTag("moon_charged_2") and owner:HasTag("wormwood_allegiance_lunar_plant_gear_2") then
            spawn_chance = vine_chance_val
            owner.components.bloomness.timer = owner.components.bloomness.timer - vine_consume_val
        end
        
        if target and target:IsValid() and math.random() <= spawn_chance then
            local pt = target:GetPosition()
            local offset = FindWalkableOffset(pt, TWOPI * math.random(), 2, 3, false, true, NoHoles, false, true)
            if offset then
                local tentacle = SpawnPrefab(self.tentacle_prefab)
                if tentacle then
                    tentacle.owner = owner
                    tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
                    tentacle.components.combat:SetTarget(target)
                end
            end
        end
    end
end)