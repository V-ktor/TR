extends Node

var location : String
var quest : Quests.Quest
var currency := "silver_coins"
var amount := 0


func init(_location,_quest):
	var city = Map.get_location(_location)
	location = _location
	quest = _quest
	Main.set_title(tr("DELIVER_PACKAGE"))
	Main.update_landscape(city.landscape)
	if quest.data.damaged:
		if randf()<0.5:
			Main.add_text(tr("DELIVER_PACKAGE_DAMAGED_NOT_NOTICED"))
			receive_reward()
		else:
			Main.add_text(tr("DELIVER_PACKAGE_DAMAGED"))
			Main.add_action(Game.Action.new(tr("SAY_SORRY"),self,{12:{"method":"convince","grade":1},0:{"method":"fail_to_convince","grade":0}},"charisma","",3),12)
			if quest.data.illegal:
				Main.add_action(Game.Action.new(tr("ACTION_POINT_OUT_ILLEGAL"),self,{14:{"method":"convince","grade":1},0:{"method":"fail_to_convince","grade":0}},"cunning","charisma",3),14)
			Main.add_action(Game.Action.new(tr("SAY_HAVE_TO_GO"),self,{8:{"method":"run","grade":1},0:{"method":"fail_to_run","grade":0}},"agility","",3),8)
	else:
		receive_reward()

func convince(_actor,_action,_roll):
	Main.add_text(tr("DELIVER_PACKAGE_CONVINCE"))
	if Characters.player.proficiency.has("bargaining") && Game.do_roll(Characters.player,"charisma","cunning",Characters.player.proficiency.bargaining)>11:
		Main.add_text(tr("DELIVER_PACKAGE_CONVINCE_PAYMENT"))
		receive_reward(0.333)
		return
	Game.finish_quest(quest)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func fail_to_convince(_actor,_action,_roll):
	amount = int(rand_range(25,50))
	Main.add_text(tr("DELIVER_PACKAGE_CONVINCE_FAIL").format({"amount":str(amount),"currency":currency}))
	if Items.get_item_amount(currency)>=amount:
		Main.add_action(Game.Action.new(tr("ACTION_PAY_THEM"),self,{0:{"method":"pay","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("ACTION_DECLINE_TO_PAY"),self,{0:{"method":"dont_pay","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("SAY_HAVE_TO_GO"),self,{14:{"method":"run","grade":1},0:{"method":"fail_to_run","grade":0}},"agility","",3),14)

func pay(_actor,_action,_roll):
	Main.add_text(tr("DELIVER_PACKAGE_PAY").format({"amount":str(amount),"currency":currency}))
	Items.remove_items(currency, amount)
	Game.finish_quest(quest)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func dont_pay(_actor,_action,_roll):
	if Characters.relations.has(quest.faction):
		Main.add_text(tr("DELIVER_PACKAGE_DONT_PAY_FACTION_HINT").format({"faction":tr(quest.faction.to_upper()+"_PLURAL")}))
		Characters.relations[quest.faction] -= 1.0
	else:
		Main.add_text(tr("DELIVER_PACKAGE_DONT_PAY"))
	Game.fail_quest(quest)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func run(_actor,_action,_roll):
	Main.add_text(tr("DELIVER_PACKAGE_RUN"))
	Game.fail_quest(quest)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func fail_to_run(_actor,_action,_roll):
	amount = int(rand_range(25,50))
	Main.add_text(tr("DELIVER_PACKAGE_FAIL_RUN").format({"amount":str(amount),"currency":currency}))
	if Characters.relations.has(quest.faction):
		Characters.relations[quest.faction] -= 1.0
	if Items.get_item_amount(currency)>=amount:
		Main.add_action(Game.Action.new(tr("ACTION_PAY_THEM"),self,{0:{"method":"pay","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("ACTION_DECLINE_TO_PAY"),self,{0:{"method":"dont_pay","grade":1}},"","",2))

func receive_reward(factor:= 1.0):
	var reward_str := ""
	for i in range(quest.reward.size()-1):
		var k = quest.reward.keys()[i]
# warning-ignore:shadowed_variable
		var amount := int(max(factor*quest.reward[k],1.0))
		reward_str += str(amount)+"x "+tr(k.to_upper())+", "
		Items.add_items(k,amount)
	var k = quest.reward.keys()[quest.reward.size()-1]
# warning-ignore:shadowed_variable
	var amount := int(max(factor*quest.reward[k],1.0))
	reward_str += tr("AND")+" "+str(amount)+"x "+tr(k.to_upper())
	Items.add_items(k,amount)
	if reward_str=="":
		Main.add_text(tr("COMPLETE_JOB"))
	else:
		Main.add_text(tr("COMPLETE_JOB_REWARD").format({"reward":reward_str}))
	Game.finish_quest(quest)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_action,_roll):
	Game.enter_location(location)
