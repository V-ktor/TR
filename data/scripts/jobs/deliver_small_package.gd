extends Node

var location : String
var quest : Quests.Quest

func init(_location,_quest):
	var city = Map.get_location(_location)
	var to_city = Map.get_location(_quest.location)
	var rnd := randf()
	location = _location
	quest = _quest
	quest.faction = city.faction
	Main.set_title(tr("DELIVER_PACKAGE"))
	Main.add_text(tr("DELIVER_PACKAGE_INIT"))
	Map.time += 2*60
	
	if rnd<0.15:
		Main.add_text(tr("DELIVER_PACKAGE_DONT_OPEN"))
		quest.data.info = "dont_open"
		Main.add_action(Game.Action.new(tr("ANSWER_YES"),self,{0:{"method":"accept","grade":1}},"","",2))
		Main.add_action(Game.Action.new(tr("ASK_WHY"),self,{0:{"method":"decline","grade":1}},"","",2))
		Main.add_action(Game.Action.new(tr("ASK_ILLEGAL"),self,{0:{"method":"decline","grade":1}},"","",2))
	else:
		var event := {"type":"enter_city", "script":"res://data/events/jobs/deliver_small_package.gd", "quest":quest.ID, "location":quest.location}
		quest.items = [Items.add_item(Items.create_item("small_package"))]
		if randf()<0.25:
			Main.add_text(tr("DELIVER_PACKAGE_TIME"))
		else:
			Main.add_text(tr("DELIVER_PACKAGE_PLEASE_DELIVER").format({"city":to_city.name}))
		Events.register_event(event)
		print("Add quest event "+event.type+"("+event.location+")"+".")
		if randf()<0.25:
			var open := {"type":"set_camp", "script":"res://data/events/jobs/deliver_small_package_camp.gd", "quest":quest.ID, "location":"camp"}
			Events.register_event(open)
			print("Add quest event "+open.type+".")
			quest.data.info = "none"
	

func accept(_actor,_action,_roll):
	var deliver := {"type":"enter_city", "script":"res://data/events/jobs/deliver_small_package.gd", "quest":quest.ID, "location":quest.location}
	Events.register_event(deliver)
	print("Add quest event "+deliver.type+"("+deliver.location+")"+".")
	if randf()<0.667:
		var open := {"type":"set_camp", "script":"res://data/events/jobs/deliver_small_package_camp.gd", "quest":quest.ID, "location":"camp"}
		Events.register_event(open)
		print("Add quest event "+open.type+".")
	quest.items = [Items.add_item(Items.create_item("mysterious_package"))]
	Main.add_text(tr("DELIVER_PACKAGE_GLAD_TO_HEAR"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func decline(_actor,_action,_roll):
	Main.add_text(tr("DELIVER_PACKAGE_NEVERMIND"))
	Game.fail_quest(quest)
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))


func leave(_actor,_action,_roll):
	Map.time += 2*60
	Game.enter_location(location)
