extends Node

var location : String
var bribe_cost_scale := 5.0
var currency := "silver_coins"


func init(city,_location):
	var node
	location = _location
	Main.set_title(tr("CITY_GATE_ENCOUNTER").format({"city":city.name}))
	Main.update_landscape(city.landscape)
	Main.add_text(tr("CITY_GATE_ENCOUNTER_INTRO"))
	Main.add_text(tr("CITY_GATE_ENCOUNTER_NOT_WELCOME").format({"city":city.name,"race":tr(Characters.player.race.to_upper()+"_PLURAL")}))
	Main.add_action(Game.Action.new(tr("CITY_GATE_ENCOUNTER_CONVINCE"),self,{5:{"method":"convince","grade":1},0:{"method":"convince_fail","grade":0}},"charisma","wisdom",4,5,int(floor(Characters.relations[city.faction]/2))))
	node = Main.add_action(Game.Action.new(tr("CITY_GATE_ENCOUNTER_BRIBE"),self,{2:{"method":"bribe","grade":1},0:{"method":"bribe_fail","grade":0}},"cunning","intelligence",4,2,int(floor(Characters.relations[city.faction]/2))))
	if Items.get_item_amount(currency)<10*bribe_cost_scale:
		node.get_node("Button").disabled = true
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func convince_fail(_actor,_action,_roll):
	Main.add_text(tr("CITY_GATE_ENCOUNTER_CONVINCING"))
	Main.add_text(tr("CITY_GATE_ENCOUNTER_CONVINCE_FAIL"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func convince(_actor,_action,_roll):
	Main.add_text(tr("CITY_GATE_ENCOUNTER_CONVINCING"))
	Main.add_text(tr("CITY_GATE_ENCOUNTER_CONVINCE_SUCCESS"))
	enter(_actor,_action,_roll)

func bribe_fail(_actor,_action,_roll):
	Main.add_text(tr("CITY_GATE_ENCOUNTER_BIBING"))
	Main.add_text(tr("CITY_GATE_ENCOUNTER_BIBING_FAIL"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func bribe(_actor,_action,roll):
	var amount = bribe_cost_scale*min(max(Game.MAX_ROLL-roll,5),10)
	Main.add_text(tr("CITY_GATE_ENCOUNTER_BIBING"))
	Main.add_text(tr("CITY_GATE_ENCOUNTER_BIBING_SUCCESS"))
	Main.add_text(tr("LOST_GOLD").format({"amount":amount,"currency":tr(currency.to_upper())}))
	Items.remove_items(currency, amount)
	enter(_actor,_action,roll)

func leave(_actor,_action,_roll):
	Game.entry_forbidden = true
	Game.leave_location()

func enter(_actor,_action,_roll):
	Game.entry_forbidden = false
	Game.enter_location(location)
