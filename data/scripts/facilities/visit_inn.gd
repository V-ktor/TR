extends Node

var cost := 20
var currency := "silver_coins"


func goto(_actor,_action,_roll):
	var node
	var c = Map.cities[Game.location]
	var total_cost := cost*Characters.party.size()
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("INN")}))
	node = Main.add_action(Game.Action.new(tr("REST_PRICE").format({"cost":str(total_cost),"currency":tr(currency.to_upper())}),self,{0:{"method":"rest","grade":1}},"","",3))
	if Items.get_item_amount(currency)<total_cost:
		node.get_node("Button").disabled = true
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	Map.time += 60*2

func rest(_actor,_action,_roll):
	var date:= OS.get_datetime_from_unix_time(Map.time)
	var hour: float = date.hour+date.minute/60.0
	var delay:= min(hour, 3.0)
	if hour>16.0:
		delay = -min(19.0-hour, 3.0)
	Main.add_text("\n"+tr("STAY_INN"))
	Items.remove_items(currency,cost*Characters.party.size())
	Map.time += (8.0-delay+rand_range(-0.05,0.05))*60*60
	Characters.rest(0.5)
	leave(_actor,_action,_roll)

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
