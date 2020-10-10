extends Node

func goto(_actor,_action,_roll):
	var c = Map.cities[Game.location]
	Main.add_text("\n"+tr("YOU_APPROACH_FACILITY").format({"location":c.name,"facility":tr("ARMORY")}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	Map.time += 60*2

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
