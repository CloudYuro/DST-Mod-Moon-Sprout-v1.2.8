require("stategraphs/commonstates")

local ATTACK_FIRE_CANT_TAGS = {"fruitdragon", "INLIMBO", "invisible", "player", "wormwood_pet", "wormwood_lunarplant", "companion", "wall", "structure"}
local ATTACK_FIRE_ONEOF_TAGS = {"_combat"}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),

    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then

            inst.sg:GoToState((inst._is_ripe and not inst.components.timer:TimerExists("fire_cd")) and "attack_fire" or "attack")
        end
    end),

	EventHandler("attacked", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead()
			and (not inst.sg:HasStateTag("busy") or
				inst.sg:HasStateTag("caninterrupt") or
				inst.sg:HasStateTag("frozen")) then
			inst.sg:GoToState("hit")
		end
	end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "do_ripen",
        tags = {"busy", "waking"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_ripe_pst")
            inst.components.inventoryitem.imagename = "wormwood_fruitdragon_ripe"
            inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_fruitdragon_ripe.xml"
        end,

        --[[timeline=
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.do_ripen) end),
        },]]

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

		onexit = function(inst)
			if not inst._is_ripe then
				inst:MakeRipe()
			end
		end,
    },

    State{
        name = "do_unripen",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_ripe_pre")
            inst.components.inventoryitem.imagename = "wormwood_fruitdragon"
            inst.components.inventoryitem.atlasname = "images/inventoryimages/wormwood_fruitdragon.xml"
			if inst._is_ripe then
				inst:MakeUnripe()
			end
        end,

        timeline=
        {
            TimeEvent(36*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.do_unripen)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

	State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
			TimeEvent(22*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(28*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
	State{
        name = "attack_fire",
        tags = { "attack", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack_fire")
            inst.components.combat:StartAttack()
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack_fire) end),
			TimeEvent(16*FRAMES, function(inst)
				inst.Light:Enable(true)
				inst.DynamicShadow:Enable(false)
			end),
			TimeEvent(20*FRAMES, function(inst)
                inst.components.timer:StopTimer("fire_cd")
                inst.components.timer:StartTimer("fire_cd", 6)

				local x, y, z = inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 3 + 6, nil, ATTACK_FIRE_CANT_TAGS, ATTACK_FIRE_ONEOF_TAGS)
				for _, ent in ipairs(ents) do
					if inst:IsNear(ent, ent:GetPhysicsRadius(0) + 3) then
						if ent.components.health ~= nil and not ent.components.health:IsDead()
                        and not (ent.components.follower and ent.components.follower:GetLeader() 
                        and ent.components.follower:GetLeader():HasTag("player")) then
							ent.components.health:DoFireDamage(20, inst, true)
                            ent.components.combat:GetAttacked(inst, 10)
                            ent:DoTaskInTime(0.5, function(ent)
							    ent.components.health:DoFireDamage(30, inst, true)
                                ent.components.combat:GetAttacked(inst, 20)
                            end)
						end
						-- if ent.components.burnable and ent.components.fueled == nil then
						-- 	ent.components.burnable:Ignite(true, inst)
						-- end
					end
				end
			end),

			TimeEvent(37*FRAMES, function(inst)
				inst.Light:Enable(false)
				inst.DynamicShadow:Enable(true)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

		onexit = function(inst)
			inst.Light:Enable(false)
			inst.DynamicShadow:Enable(true)
		end
    },

}
CommonStates.AddHitState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.onhit) end),
})

CommonStates.AddDeathState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.death) end),
    TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/body_fall") end),
})

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
    },
    walktimeline =
    {
        TimeEvent(0,            PlayFootstep),
        TimeEvent(4*FRAMES,     PlayFootstep),
        TimeEvent(12*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
}
, nil, nil, true)

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(6*FRAMES,     PlayFootstep),
        TimeEvent(10*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end)
    },

    sleeptimeline =
    {
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
        TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
    },

    waketimeline =
    {
        TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end),
    },
},
{
	onsleep = function(inst)
		if inst._unripen_pending then
            inst.sg:GoToState("do_unripen")
		end
	end,

	onwake = function(inst)
		if inst._ripen_pending then
            inst.sg:GoToState("do_ripen")
		end
	end,
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)

return StateGraph("fruit_dragon", states, events, "idle")
