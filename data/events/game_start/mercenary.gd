extends Node

const COMPANION_CLASS = ["knight","archer"]

var location : String
var story : String
var num_zombie_fights := 0
var lab_known := false
var lab_searched := false
var lab_switch_pulled := false
var forge_known := false
var forge_searched := false
var workroom_known := false
var workroom_open := false


func create_mercenary(cl : String) -> Characters.Character:
	var actor := Characters.create_npc({"background":["mercenary"]}, cl)
	actor.hired = true
	actor.hired_until = Map.time+int(12*60*60)
	Journal.add_entry(actor.ID, actor.get_name(), ["persons","companions"], "MERCENARY_COMPANION", "", Map.time)
	return actor


func init(_city : Map.Location, _location : String, _class : String):
	location = _location
	story = _class
	Main.set_title(tr("MAGE_TOWER"))
	Main.add_text(tr("MERCENARY_"+story.to_upper())+"\n"+tr("MERCENARY_INIT")+"\n"+tr("MERCENARY_SPLIT"))
	
	for i in range(2):
		var actor : Characters.Character
		var cl : String = COMPANION_CLASS[i]
		if cl==_class:
			cl = "fighter"
		actor = create_mercenary(cl)
		Characters.party.push_back(actor.ID)
	Main.add_text(tr("MERCENARY_ZOMBIE_NOISE").format({"name":Characters.characters[Characters.party[1]].get_name()}))
	
	var script = load("res://data/events/game_start/mercenary_zombie_fight.gd").new()
	script.init(self)

func zombies_defeated(_actor,_action,_roll):
	Map.time += 600
	num_zombie_fights += 1
	if num_zombie_fights<2:
		Main.add_text(tr("MERCENARY_ROOKIE").format({"name":Characters.characters[Characters.party[1]].get_name()}))
		Main.add_action(Game.Action.new(tr("MERCENARY_GREAT"),self,{0:{"method":"chat_great","grade":1}},"","",2))
		Main.add_action(Game.Action.new(tr("MERCENARY_DIEING"),self,{0:{"method":"chat_dieing","grade":1}},"","",2))
	else:
		Main.add_text(tr("MERCENARY_GROUP_NOT_BACK")+"\n"+tr("MERCENARY_START_TO_WORRY").format({"name":Characters.characters[Characters.party[2]].get_name(),"leader":Characters.characters[Characters.party[1]].get_name()}))
		Main.add_action(Game.Action.new(tr("ENTER_LOCATION").format({"name":tr("TOWER")}),self,{0:{"method":"enter_tower","grade":1}},"","",4))

func chat_great(_actor,_action,_roll):
	Main.add_text(tr("MERCENARY_GREAT_RESPONSE").format({"item":tr("SMALL_HEALTH_POTION")}))
	continue_battle(_actor,_action,_roll)

func chat_dieing(_actor,_action,_roll):
	Main.add_text(tr("MERCENARY_GREAT_RESPONSE").format({"item":tr("SMALL_HEALTH_POTION")}))
	continue_battle(_actor,_action,_roll)

func continue_battle(_actor,_action,_roll):
	var script = load("res://data/events/game_start/mercenary_zombie_fight.gd").new()
	Items.add_items("small_health_potion")
	Main.add_text("\n"+tr("MERCENARY_MORE_ZOMBIES"))
	script.init(self, "weak_zombie")

func enter_tower(_actor,_action,_roll):
	Main.add_text(tr("MERCENARY_ENTER_TOWER")+"\n"+tr("MERCENARY_HALL"))
	Main.add_text(tr("MERCENARY_POCKET").format({"name":Characters.characters[Characters.party[2]].get_name()}))
	Main.add_action(Game.Action.new(tr("MERCENARY_NO_TIME"),self,{0:{"method":"tower_continue","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("MERCENARY_LEAVE_SOMETHING"),self,{0:{"method":"tower_continue","grade":1}},"","",2))

func tower_continue(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("MERCENARY_INTERVENE").format({"name":Characters.characters[Characters.party[1]].get_name()}))
	Main.add_text(tr("MERCENARY_STAIRCASE"))
	Main.add_action(Game.Action.new(tr("ENTER_THE_BASEMENT"),self,{0:{"method":"enter_basement","grade":1}},"","",3))

func enter_basement(_actor,_action,_roll):
	Main.add_text(tr("MERCENARY_BASEMENT")+"\n")
	goto_crossroads(_actor,_action,_roll)

func goto_crossroads(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("CROSSROADS"))
	Main.add_text(tr("APPROACH_CROSSROADS"))
	if !workroom_open && forge_searched && lab_switch_pulled:
		Main.add_text(tr("MERCENARY_WORKROOM_OPEN"))
		workroom_open = true
	if workroom_known:
		Main.add_action(Game.Action.new(tr("GO_UPSTAIRS"),self,{0:{"method":"go_back","grade":0}},"","",2))
		Main.add_action(Game.Action.new(tr("ENTER_WORKROOM"),self,{0:{"method":"enter_basement_workroom","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_STRAIGHTFORWARD"),self,{0:{"method":"enter_basement_workroom","grade":1}},"","",3))
	if lab_known:
		Main.add_action(Game.Action.new(tr("ENTER_LAB"),self,{0:{"method":"enter_lab","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_LEFT"),self,{0:{"method":"enter_lab","grade":1}},"","",3))
	if forge_known:
		Main.add_action(Game.Action.new(tr("ENTER_FORGE"),self,{0:{"method":"enter_forge","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_RIGHT"),self,{0:{"method":"enter_forge","grade":1}},"","",3))

func enter_lab(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("LABORATORY"))
	Main.add_text(tr("WIZARD_BASEMENT_ENTER_LAB"))
	if !lab_known:
		Main.add_text(tr("MERCENARY_ENTER_LAB")+"\n"+tr("MERCENARY_NECRO").format({"name":Characters.characters[Characters.party[1]].get_name()}))
		lab_known = true
	if !lab_searched:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_SEARCH_LAB"),self,{10:{"method":"lab_search","grade":1},0:{"method":"lab_search_failed","grade":0}},"cunning","intelligence",4,10))
	elif !lab_switch_pulled:
		Main.add_action(Game.Action.new(tr("TRIGGER_SWITCH"),self,{0:{"method":"trigger_switch","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func lab_search(_actor,_action,_roll):
	Map.time += 60*3
	lab_searched = true
	Main.add_text(tr("MERCENARY_LAB_SEARCH").format({"item":tr("SMALL_HEALTH_POTION")}))
	Items.add_items("small_health_potion")
	Main.add_action(Game.Action.new(tr("TRIGGER_SWITCH"),self,{0:{"method":"trigger_switch","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func lab_search_failed(_actor,_action,_roll):
	Map.time += 60*5
	lab_searched = true
	Main.add_text(tr("MERCENARY_LAB_SEARCH_FAILED"))
	Main.add_action(Game.Action.new(tr("TRIGGER_SWITCH"),self,{0:{"method":"trigger_switch","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func trigger_switch(_actor,_action,_roll):
	lab_switch_pulled = true
	Main.add_text(tr("MERCENARY_LAB_SWITCH"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func enter_forge(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("FORGE"))
	if forge_known:
		Main.add_text(tr("WIZARD_BASEMENT_ENTER_FORGE"))
	else:
		Main.add_text(tr("MERCENARY_BASEMENT_FORGE_DOOR")+"\n"+tr("WIZARD_BASEMENT_FORGE_OPERATION"))
		forge_known = true
	if !forge_searched:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_SEARCH_FORGE"),self,{10:{"method":"forge_search","grade":1},0:{"method":"forge_search_failed","grade":0}},"cunning","intelligence",4,10))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func forge_search(_actor,_action,_roll):
	Map.time += 60*3
	forge_searched = true
	Main.add_text(tr("MERCENARY_FORGE_SEARCH").format({"item":tr("LONG_SWORD"),"name":Characters.characters[Characters.party[2]].get_name()}))
	Items.add_items("long_sword")
	forge_battle()

func forge_search_failed(_actor,_action,_roll):
	Map.time += 60*5
	forge_searched = true
	Main.add_text(tr("MERCENARY_FORGE_SEARCH_FAILED").format({"name":Characters.characters[Characters.party[2]].get_name()}))
	forge_battle()

func forge_battle():
	var script = load("res://data/events/game_start/mercenary_imp_fight.gd").new()
	script.init(self)

func imps_defeated(_actor,_action,_roll):
	Map.time += 60*5
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))


func enter_basement_workroom(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("WORKROOM"))
	if !workroom_open:
		Main.add_text(tr("MERCENARY_WORKROOM_LOCKED"))
	elif workroom_known:
		Main.add_text(tr("WIZARD_BASEMENT_ENTER_WORKROOM"))
	else:
		workroom_known = true
		Main.add_text(tr("MERCENARY_ENTER_WORKROOM")+"\n"+tr("WIZARD_WORKROOM_MESS"))
		if story=="fighter" || story=="archer" || story=="rogue":
			Main.add_text(tr("MERCENARY_ILITERATE"))
		Main.add_text(tr("MERCENARY_SEE_SCROLL"))
		Main.add_action(Game.Action.new(tr("TAKE_SCROLL"),self,{0:{"method":"take_scroll","grade":1}},"","",3,0))
		return
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func take_scroll(_actor,_action,_roll):
	Journal.add_entry(tr("FOUND_MYSTERIOUS_SCROLL"), tr("FOUND_MYSTERIOUS_SCROLL"), ["quests"], tr("FOUND_MYSTERIOUS_SCROLL_TEXT"), "", Map.time)
	Items.add_items("mysterious_scroll")
	Main.add_text(tr("MERCENARY_GRAB_SCROLL").format({"name":Characters.characters[Characters.party[2]].get_name(),"leader":Characters.characters[Characters.party[1]].get_name()}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))


# end #

func go_back(_actor,_action,_roll):
	Main.add_text(tr("MERCENARY_GO_UPSTAIRS")+"\n"+tr("MERCENARY_DEAD").format({"name":Characters.characters[Characters.party[2]].get_name(),"leader":Characters.characters[Characters.party[1]].get_name()})+"\n"+tr("MERCENARY_STILL_ALIVE"))
	Characters.characters.erase(Characters.party[1])
	Characters.characters.erase(Characters.party[2])
	Characters.party.resize(1)
	Main.add_action(Game.Action.new(tr("READ_SCROLL"),self,{0:{"method":"read_scroll","grade":1}},"","",4,1))

func read_scroll(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("MERCENARY_READ_SCROLL"))
	if story=="fighter" || story=="archer" || story=="rogue":
		Main.add_text(tr("MERCENARY_SCROLL_ILITERATE"))
	elif story=="wizard" || story=="cleric" || story=="druid":
		Main.add_text(tr("MERCENARY_SCROLL_MAGICAL"))
	else:
		Main.add_text(tr("MERCENARY_SCROLL_UNMAGICAL"))
	Main.add_text(tr("MERCENARY_SCROLL_SHIFTING"))
	Main.add_text(tr("MERCENARY_SCROLL_COMENT").format({"race":tr(Characters.player.race.to_upper())}))
	Main.add_action(Game.Action.new(tr("TRY_HARDER"),self,{0:{"method":"continue_reading_scroll","grade":1}},"","",3,1))

func continue_reading_scroll(_actor,_action,_roll):
	Items.remove_items("mysterious_scroll")
	Items.add_items("scroll_handles")
	Main.add_text(tr("MERCENARY_SCROLL_LOCK_IN")+"\n"+tr("MERCENARY_SCROLL_IMPOSSIBLE"))
	Main.add_text(tr("MERCENARY_SCROLL_DISINTEGRATING")+"\n"+tr("MERCENARY_SCROLL_WIZARD_GONE")+"\n"+tr("MERCENARY_SCROLL_CLOUDS"))
	Main.add_action(Game.Action.new(tr("WAIT"),self,{0:{"method":"ending_wait","grade":1}},"","",6,1))
	Main.add_action(Game.Action.new(tr("TRY_TO_MOVE"),self,{0:{"method":"ending_move","grade":1}},"","",6,1))

func ending_wait(_actor,_action,_roll):
	Map.time += 60*5
	Main.add_text(tr("MERCENARY_ENDING_WAIT")+"\n"+tr("MERCENARY_DONE"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func ending_move(_actor,_action,_roll):
	Map.time += 60*5
	Main.add_text(tr("MERCENARY_ENDING_MOVE")+"\n"+tr("MERCENARY_DONE"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_action,_roll):
	Journal.add_entry(tr("SCROLL_ESCAPED_WIZARD_SOMEHOW"), tr("SCROLL_ESCAPED_WIZARD_SOMEHOW"), ["quests"], tr("SCROLL_ESCAPED_WIZARD_SOMEHOW_TEXT"), "", Map.time)
	Game.location = location
	Map.time += 2*60*60
	Main.add_text(tr("MERCENARY_ENDING_RETURNED"))
	Game.enter_location(Game.location)
	Game._save()
