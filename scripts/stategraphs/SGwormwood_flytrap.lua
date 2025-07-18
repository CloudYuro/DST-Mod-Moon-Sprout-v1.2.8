require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events=
{
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnHop(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
}

local states=
{
    -- 在states表中添加以下状态
    State{
        name = "boat_jump_pre",
        tags = { "doing", "busy", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pre")
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
            inst.AnimState:PlayAnimation("idle", true)
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
            inst.AnimState:PlayAnimation("run_pst")
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "gohome",
        tags = {"busy"},

        onenter = function(inst, playanim)
            if inst.components.homeseeker and
               inst.components.homeseeker.home and
               inst.components.homeseeker.home:IsValid() then

                inst.components.homeseeker.home.AnimState:PlayAnimation("chop", false)
            end
            inst:PerformBufferedAction()
        end,
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/4/breath_out") end),
            TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/4/breath_in") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.AnimState:PushAnimation("atk_pst", false)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                if inst.components.combat.target then
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                end
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.combat.target then
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                end
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/".. inst.stage .."/attack")
            end),

            TimeEvent(15 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                if inst.components.combat.target then
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/attack")
            inst.AnimState:PushAnimation("atk", false)
        end,

        onexit = function(inst, cb)
            if not inst.animdone then
                inst:ClearBufferedAction()
            end
            inst.animdone = nil
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/attack") end),
            TimeEvent(18 * FRAMES, function(inst) if inst:PerformBufferedAction() then inst.components.combat:SetTarget(nil) end end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.animdone = true inst.sg:GoToState("idle","atk_pst")  end),
        },
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/breath_out")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/taunt") end),

        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot()
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/death_pre", nil, 0.5) end),
            TimeEvent(13 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/death") end),
        },
    },

    -- leftover code from frog sg?
    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0, -20 + math.random() * 10, 0)
            inst.AnimState:PlayAnimation("idle", true)
        end,

        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
                inst.Physics:SetMotorVel(0,0,0)
            end

            if pt.y <= .1 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.SoundEmitter:PlaySound("dontstarve/frog/splat")
                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            local pt = inst:GetPosition()
            pt.y = 0
            inst.Transform:SetPosition(pt:Get())
        end,
    },

    State{
        name = "enter",
        tags = {"busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
        end,

        timeline =
        {

        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "grow",
        tags = {"busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_pre")
        end,

        timeline=
        {
            TimeEvent(1  * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/death_pre") end),
            TimeEvent(5  * FRAMES, function(inst) inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*1), inst.start_scale + (inst.inc_scale*1), inst.start_scale + (inst.inc_scale*1)) end),
            TimeEvent(10 * FRAMES, function(inst) inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*2), inst.start_scale + (inst.inc_scale*2), inst.start_scale + (inst.inc_scale*2))end),
            TimeEvent(15 * FRAMES, function(inst) inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*3), inst.start_scale + (inst.inc_scale*3), inst.start_scale + (inst.inc_scale*3))end),
            TimeEvent(20 * FRAMES, function(inst) inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*4), inst.start_scale + (inst.inc_scale*4), inst.start_scale + (inst.inc_scale*4))end),
            TimeEvent(25 * FRAMES, function(inst) inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*5), inst.start_scale + (inst.inc_scale*5), inst.start_scale + (inst.inc_scale*5))end),
        },

        onexit = function(inst, target)
            inst.AnimState:SetBuild(inst.new_build)
            inst.Transform:SetScale(inst.start_scale + (inst.inc_scale*5), inst.start_scale + (inst.inc_scale*5), inst.start_scale + (inst.inc_scale*5))
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle", "transform_pst") end),
        },
    },
}

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(14 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/step") end),
    },

    sleeptimeline =
    {
        TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/breath_in") end),
        TimeEvent(20 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/breath_out") end),
    },

    waketimeline =
    {
        TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/wake") end),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        ---fast
        TimeEvent(5 * FRAMES, function(inst) if inst:HasTag("usefastrun") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/breath_out")  end end),
        TimeEvent(12 * FRAMES, function(inst) if inst:HasTag("usefastrun") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/step") end end),
        ---slow
        TimeEvent(19 * FRAMES, function(inst) if not inst:HasTag("usefastrun") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/step") end end),
        TimeEvent(7 * FRAMES, function(inst)  if not inst:HasTag("usefastrun") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/" .. inst.stage .. "/breath_out") end end),
    }
})

CommonStates.AddFrozenStates(states)
-- 替换原有的CommonStates.AddHopStates调用
CommonStates.AddHopStates(states, true, {
    pre = "run_pre",
    loop = "idle",
    pst = "run_pst"
})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)

return StateGraph("mean_flytrap", states, events, "taunt", actionhandlers)
