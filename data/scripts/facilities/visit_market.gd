extends "res://data/scripts/base_shop.gd"

func goto(_actor,_action,_roll):
	var c = Map.cities[Game.location]
	rng.seed = c.shop_seed
	type_filter = ["misc","fuel","currency","commodities"]
	min_items = 2
	max_items = 4
	gather_items()
	add_items()
	add_commodities()
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("MARKET")}))
	update_actions()
	Map.time += 60*2
