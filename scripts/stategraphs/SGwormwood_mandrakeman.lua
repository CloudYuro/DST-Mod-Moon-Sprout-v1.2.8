require("stategraphs/commonstates")

-- local pets_sound_mandrakeman = GetModConfigData("pets_sound_mandrakeman", ThePlayer)

local function IsMandrakeSoundOn(inst)
    if inst.components.follower and inst.components.follower.leader then
        return inst.components.follower.leader.pets_mandrake_sound
    else
        return true
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(nil, TUNING.CHARACTER_MAX_STUN_LOCKS),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
}

TUNING.MANDRAKEMAN_PANIC_THRESH = .333

local states=
{-- 在states表中添加以下状态
    State{
        name = "boat_jump_pre",
        tags = { "doing", "busy", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("boat_jump_loop")
            end),
        },
    },

    State{
        name = "boat_jump_loop",
        tags = { "doing", "busy", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("boat_jump_pst")
        end,
    },

    State{
        name = "boat_jump_pst",
        tags = { "doing", "busy", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pst")
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    State{
        name= "funnyidle",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()

            if inst.components.health:GetPercent() < TUNING.MANDRAKEMAN_PANIC_THRESH then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() < 0.05 then
                inst.AnimState:PlayAnimation("hungry")
                if IsMandrakeSoundOn(inst) then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
                end
            elseif inst.components.combat.target then
                inst.AnimState:PlayAnimation("idle_angry")
                if IsMandrakeSoundOn(inst) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/angry_idle")
                end
            elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() > 0.3 then
                inst.AnimState:PlayAnimation("idle_happy")
                if IsMandrakeSoundOn(inst) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/idle_happy")
                end
            else
                inst.AnimState:PlayAnimation("idle_creepy")
                if IsMandrakeSoundOn(inst) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/idle_creepy")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "happy",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("idle_happy")
        end,

        timeline =
        {
            -- if IsMandrakeSoundOn(inst) then
                TimeEvent(4  * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(22 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(28 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(34 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(40 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(46 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
                TimeEvent(52 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
            -- end
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            if IsMandrakeSoundOn(inst) then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/death")
            end
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot()
        end,
    },

    State{
        name = "abandon",
        tags = {"busy"},

        onenter = function(inst, leader)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("abandon")
            if IsMandrakeSoundOn(inst) then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/no")
            end
            inst:FacePoint(Vector3(leader.Transform:GetWorldPosition()))
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst)
            if IsMandrakeSoundOn(inst) then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/eat")
            end
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            if IsMandrakeSoundOn(inst) then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/eat")
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)

            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        timeline =
        {
            -- if IsMandrakeSoundOn(inst) then
                TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hit") end),
            -- end
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline = {
        TimeEvent(0 * FRAMES, PlayFootstep ),
        -- if IsMandrakeSoundOn(inst) then
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/foley") end),
        -- end
    },
}, nil, true)

CommonStates.AddRunStates(states,
{
    runtimeline = {
        TimeEvent(0*FRAMES, PlayFootstep ),
        -- if IsMandrakeSoundOn(inst) then
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/foley") end),
        -- end
    },
}, nil, true)
CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        -- if IsMandrakeSoundOn(inst) then
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/sleep") end),
        -- end
    },
})

CommonStates.AddIdle(states, "funnyidle")
CommonStates.AddSimpleState(states, "refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, {"busy"})
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, {"busy"})
CommonStates.AddHopStates(states, true, {
    pre = "walk_pre",
    loop = "idle_loop",
    pst = "walk_pst"
})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)

return StateGraph("wormwood_mandrakeman", states, events, "idle", actionhandlers)
