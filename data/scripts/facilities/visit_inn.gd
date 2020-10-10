extends Node

var cost := 20
var currency := "silver_coins"


func goto(_actor,_action,_roll):
	var node
	var c = Map.cities[Game.location]
	var total_cost := cost*Characters.party.size()
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("INN")}))
	node = Main.add_action(Game.Action.new(tr("REST_PRICE").format({"cost":total_cost,"currency":currency}),self,{0:{"method":"rest","grade":1}},"","",3))
	if Items.get_item_amount(currency)<total_cost:
		node.get_node("Button").disabled = true
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	Map.time += 60*2

func rest(_actor,_action,_roll):
	Main.add_text("\n"+tr("STAY_INN"))
	Items.remove_items(currency,cost*Characters.party.size())
	Map.time += 60*60*8
	for k in Characters.party:
		var c = Characters.characters[k]
		c.health = min(c.health+ceil(c.max_health/2),c.max_health)
		c.stamina = c.max_stamina
		c.mana = c.max_mana
		c.morale += 5.0+float(Game.do_roll(Characters.player,"charisma"))/2.0
	leave(_actor,_action,_roll)

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
