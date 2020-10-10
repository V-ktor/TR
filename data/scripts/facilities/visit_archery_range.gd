extends "res://data/scripts/base_shop.gd"

func goto(_actor,_action,_roll):
	var c = Map.cities[Game.location]
	rng.seed = c.shop_seed
	type_filter = ["weapon"]
	proficiency_filter = ["bow","crossbow"]
	gather_items()
	add_items()
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("ARCHERY_RANGE")}))
	update_actions()
	Map.time += 60*2
