extends Node

func goto(_actor,_action,_roll):
	Main.add_text("\n"+tr("YOU_APPROACH_UNIQUE_FACILITY").format({"facility":tr("IMPERIAL_PALACE")}))
	Main.add_text(tr("IMPERIAL_PALACE_GUARDED"))
	Main.add_action(Game.Action.new(tr("ENTER_LOCATION").format({"name":tr("IMPERIAL_PALACE")}),self,{0:{"method":"try_to_enter","grade":1}},"","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",2))
	Map.time += 60*2

func try_to_enter(_actor,_acion,_roll):
	Main.add_text("\n"+tr("IMPERIAL_PALACE_STOPPED_BY_GUARDS"))
	Main.add_action(Game.Action.new(tr("IMPERIAL_PALACE_TELL_EMPEROR"),self,{0:{"method":"reject","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("IMPERIAL_PALACE_TELL_TOURIST"),self,{0:{"method":"reject","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",2))

func reject(actor,_action,_roll):
	Main.add_text("\n"+tr("IMPERIAL_PALACE_TELL"))
	Main.add_text(tr("IMPERIAL_PALACE_REJECTED_BY_GUARDS"))
	if actor.race=="human":
		Main.add_text(tr("IMPERIAL_PALACE_GUARD_STOP_WASTING_TIME"))
	elif "startling" in actor.traits:
		Main.add_text(tr("IMPERIAL_PALACE_GUARD_GO_AWAY").format({"race":tr(actor.race.to_upper())}))
	else:
		Main.add_text(tr("IMPERIAL_PALACE_GUARD_OFF_LIMITS").format({"race":tr(actor.race.to_upper())}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",2))

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
