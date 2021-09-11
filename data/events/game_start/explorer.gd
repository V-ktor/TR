extends Node

var location : String
var story : String
var found_dead_adventurers := false
var dead_body_examined := false
var canteen_visited := false
var canteen_searched := false
var armory_corridor_trap := false
var armory_known := false
var armory_chest := false
var barracks_known := false
var barracks_searched := false
var storage_known := false
var storage_searched := false
var shrine_known := false
var chalice_examined := false
var chalice_used := false
var workshop_known := false
var door_opened := false

# /-T-\
#B+A  W
# ||  |
# C++-M-S
#   |
#   E

func init(_city : Map.Location, _location : String, _class : String):
	location = _location
	story = _class
	Items.add_items("torch")
	Main.set_title(tr("DEEP_FOREST"))
	Main.add_text(tr("EXPLORER_"+story.to_upper())+"\n"+tr("EXPLORER_INIT")+"\n"+tr("EXPLORER_RUINS_LOCATION"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"forest_encounter","grade":1}},"","",4))

func forest_encounter(actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_FOREST_ENCOUNTER").format({"name":tr("BOAR")}))
	Main.add_action(Game.Action.new(tr("ATTACK_IT"),self,{0:{"method":"forest_encounter_attack","grade":1}},"","",2))
	if actor.proficiency.has("survival"):
		Main.add_action(Game.Action.new(tr("MOVE_AROUND"),self,{9:{"method":"forest_encounter_evade","grade":1},0:{"method":"forest_encounter_spotted","grade":0}},"agility","dexterity",5,10))
	if actor.proficiency.has("arcane_magic") || actor.proficiency.has("light_magic") || actor.proficiency.has("fire_magic") || actor.proficiency.has("wind_magic"):
		Main.add_action(Game.Action.new(tr("DISTRACT_IT_SPELL"),self,{10:{"method":"forest_encounter_spell","grade":1},0:{"method":"forest_encounter_spotted","grade":0}},"intelligence","cunning",3,10))
	if actor.proficiency.has("bow") || actor.proficiency.has("crossbow"):
		Main.add_action(Game.Action.new(tr("SNIPE_IT_DOWN_BOW"),self,{16:{"method":"forest_encounter_kill","grade":2},8:{"method":"forest_encounter_hit","grade":1},0:{"method":"forest_encounter_missed","grade":0}},"dexterity","cunning",3,8))
	if actor.proficiency.has("stealth"):
		Main.add_action(Game.Action.new(tr("SNEAK_PAST_IT"),self,{10:{"method":"forest_encounter_sneak","grade":1},0:{"method":"forest_encounter_spotted","grade":0}},"cunning","agility",5,10))

func forest_encounter_attack(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_ENGAGE").format({"name":tr("BOAR")}))
	start_forest_battle(_actor,_action,_roll)

func forest_encounter_spotted(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_SPOTTED").format({"name":tr("BOAR")}))
	start_forest_battle(_actor,_action,_roll)

func forest_encounter_miss(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_MISS").format({"name":tr("BOAR")}))
	start_forest_battle(_actor,_action,_roll)

func forest_encounter_hit(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_HIT").format({"name":tr("BOAR")}))
	start_forest_battle(_actor,_action,_roll,true)

func forest_encounter_kill(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_KILL").format({"name":tr("BOAR")}))
	find_ruins(_actor,_action,_roll)

func forest_encounter_evade(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_AVOID").format({"name":tr("BOAR")}))
	find_ruins(_actor,_action,_roll)

func forest_encounter_spell(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_SPELL").format({"name":tr("BOAR")}))
	find_ruins(_actor,_action,_roll)

func forest_encounter_sneak(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_ENCOUNTER_SNEAK").format({"name":tr("BOAR")}))
	find_ruins(_actor,_action,_roll)

func start_forest_battle(_actor,_action,_roll,damage:=false):
	var script = load("res://data/events/game_start/explorer_forest_fight.gd").new()
	script.init(self)
	if damage:
		script.enemy[0].damaged(5)

func find_ruins(_actor,_action,_roll):
	Map.time += 60*20
	Main.set_title("RUINS")
	Main.add_text("\n"+tr("EXPLORER_RUINS_FOUND"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"reach_ruins","grade":1}},"","",4))

func reach_ruins(_actor,_action,_roll):
	Map.time += 60*15
	Main.add_text(tr("EXPLORER_RUINS_REACHED"))
	Main.add_action(Game.Action.new(tr("EXPLORER_RUINS_EXAMINE_DOOR"),self,{0:{"method":"examine_ruins_door","grade":1}},"","",4))

func examine_ruins_door(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_DOOR"))
	Main.add_action(Game.Action.new(tr("EXPLORER_RUINS_ENTER"),self,{0:{"method":"enter_ruins","grade":1}},"","",4))

func enter_ruins(_actor,_action,_roll):
	Map.time += 60*2
	Main.add_text("\n"+tr("EXPLORER_RUINS_ENTERED")+"\n"+tr("EXPLORER_RUINS_DUST"))
	Main.add_action(Game.Action.new(tr("GO_DOWNSTAIRS"),self,{0:{"method":"go_downstairs","grade":1}},"","",3))

func go_downstairs(_actor,_action,_roll):
	Map.time += 60*2
	Main.add_text("\n"+tr("EXPLORER_RUINS_GOING_DOWNSTAIRS"))
	Main.add_action(Game.Action.new(tr("EXAMINE_CORPSE"),self,{0:{"method":"examine_corpse","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("MOVE_FORWARD"),self,{0:{"method":"continue_trap","grade":1}},"","",3))

func examine_corpse(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_CORPSE"))
	Main.add_action(Game.Action.new(tr("PROCEED_CAREFULLY"),self,{0:{"method":"continue_carefully","grade":1}},"","",3))

func continue_trap(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_TRAP_TRIGGERED"))
	Characters.player.damaged()
	Main.add_action(Game.Action.new(tr("PROCEED_CAREFULLY"),self,{0:{"method":"continue_carefully","grade":1}},"","",3))

func continue_carefully(_actor,_action,_roll):
	Map.time += 60
	Main.set_title("CORRIDOR")
	Main.add_text(tr("EXPLORER_RUINS_CORRIDORS"))
	Main.add_action(Game.Action.new(tr("GO_LEFT"),self,{0:{"method":"go_left","grade":1}},"","",3))
	if storage_known:
		Main.add_action(Game.Action.new(tr("ENTER_STORAGE"),self,{0:{"method":"enter_storage","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_RIGHT"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func go_left(_actor,_action,_roll):
	Main.set_title("CORRIDOR")
	if !found_dead_adventurers:
		found_dead_adventurers = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_DEAD_ADVENTURERS"))
	Main.add_text(tr("EXPLORER_RUINS_CORRIDOR_STRAIGT_RIGHT"))
	if canteen_visited:
		Main.add_action(Game.Action.new(tr("ENTER_CANTEEN"),self,{0:{"method":"enter_canteen","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_WEST"),self,{0:{"method":"enter_canteen","grade":1}},"","",3))
	if armory_known && armory_corridor_trap:
		Main.add_action(Game.Action.new(tr("ENTER_ARMORY"),self,{0:{"method":"enter_armory","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_NORTH"),self,{0:{"method":"enter_armory_corridor","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"continue_carefully","grade":1}},"","",3))

func enter_canteen(_actor,_action,_roll):
	Map.time += 30
	Main.set_title("CANTEEN")
	if canteen_visited:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_CANTEEN"))
	else:
		canteen_visited = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_CANTEEN"))
	if !canteen_searched:
		Main.add_action(Game.Action.new(tr("SEARCH_ROOM"),self,{10:{"method":"search_canteen","grade":1},0:{"method":"search_canteen_failed","grade":0}},"cunning","intelligence",4,10))
	Main.add_action(Game.Action.new(tr("GO_NORTH"),self,{0:{"method":"enter_junction","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"go_left","grade":1}},"","",3))

func search_canteen(_actor,_action,roll):
	Map.time += 60*4
	canteen_searched = true
	Items.add_items("silver_coins",50+roll)
	Main.add_text(tr("EXPLORER_RUINS_CANTEEN_SEARCH").format({"name":tr("SILVER_COINS")}))
	enter_canteen(_actor,_action,roll)

func search_canteen_failed(_actor,_action,_roll):
	Map.time += 60*5
	canteen_searched = true
	Main.add_text(tr("EXPLORER_RUINS_CANTEEN_SEARCH_FAILED"))
	enter_canteen(_actor,_action,_roll)

func enter_armory_corridor(_actor,_action,_roll):
	Main.set_title("CORRIDOR")
	if armory_corridor_trap:
		enter_armory(_actor,_action,_roll)
	else:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ARMORY_FLOOR"))
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"armory_corridor_trap","grade":0}},"","",3))
		Main.add_action(Game.Action.new(tr("EXPLORER_RUINS_ARMORY_LOOK_FOR_TRAPS"),self,{8:{"method":"armory_corridor_trap_defused","grade":1},0:{"method":"armory_corridor_trap","grade":0}},"cunning","dexterity",3,8))

# warning-ignore:function_conflicts_variable
func armory_corridor_trap(_actor,_action,_roll):
	Map.time += 60
	armory_corridor_trap = true
	Characters.player.damaged()
	Characters.player.stressed()
	Characters.player.drained()
	Main.add_text(tr("EXPLORER_RUINS_ARMORY_TRAP"))
	if armory_known:
		Main.add_action(Game.Action.new(tr("CONTINUE"),self,{0:{"method":"go_left","grade":1}},"","",3))
	else:
		Main.add_text(tr("EXPLORER_RUINS_ARMORY_CORRIDOR_END"))
		Main.add_action(Game.Action.new(tr("ENTER_ROOM"),self,{0:{"method":"enter_armory","grade":1}},"","",3))

func armory_corridor_trap_defused(_actor,_action,_roll):
	Map.time += 60*2
	armory_corridor_trap = true
	Main.add_text(tr("EXPLORER_RUINS_ARMORY_LOOK_FOR_TRAPS")+"\n"+tr("EXPLORER_RUINS_ARMORY_CORRIDOR_END"))
	if armory_known:
		Main.add_action(Game.Action.new(tr("CONTINUE"),self,{0:{"method":"go_left","grade":1}},"","",3))
	else:
		Main.add_text(tr("EXPLORER_RUINS_ARMORY_CORRIDOR_END"))
		Main.add_action(Game.Action.new(tr("ENTER_ROOM"),self,{0:{"method":"enter_armory","grade":1}},"","",3))

func enter_armory(_actor,_action,_roll):
	Map.time += 30
	Main.set_title("ARMORY")
	if armory_known:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_ARMORY"))
	else:
		armory_known = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_ARMORY"))
	if !armory_chest && Characters.player.proficiency.has("lock_picking"):
		Main.add_action(Game.Action.new(tr("PICK_LOCK"),self,{8:{"method":"armory_lockpick_success","grade":1},0:{"method":"armory_lockpick_failed","grade":0}},"cunning","",3,8))
	if armory_corridor_trap:
		Main.add_action(Game.Action.new(tr("GO_SOUTH"),self,{0:{"method":"go_left","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_SOUTH"),self,{0:{"method":"armory_corridor_trap","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_WEST"),self,{0:{"method":"enter_junction","grade":1}},"","",3))

func armory_lockpick_success(_actor,_action,_roll):
	Map.time += 60
	armory_chest = true
	Items.add_items("silver_coins", 75)
	Main.add_text(tr("EXPLORER_RUINS_ARMORY_CHEST").format({"name":tr("SILVER_COINS")}))
	enter_armory(_actor,_action,_roll)

func armory_lockpick_failed(_actor,_action,_roll):
	Map.time += 60*2
	armory_chest = true
	Main.add_text(tr("EXPLORER_RUINS_ARMORY_CHEST_FAILED"))
	enter_armory(_actor,_action,_roll)

func enter_junction(_actor,_action,_roll):
	Map.time += 20
	Main.set_title("CROSSROADS")
	Main.add_text("\n"+tr("EXPLORER_RUINS_JUNCTION"))
	Main.add_action(Game.Action.new(tr("GO_NORTH"),self,{0:{"method":"enter_temple","grade":1}},"","",3))
	if barracks_known:
		Main.add_action(Game.Action.new(tr("ENTER_BARRACKS"),self,{0:{"method":"enter_barracks","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_WEST"),self,{0:{"method":"enter_barracks","grade":1}},"","",3))
	if armory_known:
		Main.add_action(Game.Action.new(tr("ENTER_ARMORY"),self,{0:{"method":"enter_armory","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_EAST"),self,{0:{"method":"enter_armory","grade":1}},"","",3))
	if canteen_visited:
		Main.add_action(Game.Action.new(tr("ENTER_CANTEEN"),self,{0:{"method":"enter_canteen","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_SOUTH"),self,{0:{"method":"enter_canteen","grade":1}},"","",3))

func enter_barracks(_actor,_action,_roll):
	Map.time += 30
	Main.set_title("BARRACKS")
	if barracks_known:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_BARRACKS"))
	else:
		barracks_known = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_BARRACKS"))
	if !barracks_searched:
		Main.add_action(Game.Action.new(tr("SEARCH_ROOM"),self,{12:{"method":"search_barracks","grade":1},0:{"method":"search_barracks_failed","grade":0}},"cunning","intelligence",4,12))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_junction","grade":1}},"","",3))

func search_barracks(_actor,_action,roll):
	Map.time += 60*5
	barracks_searched = true
	Items.add_items("lever")
	Items.add_items("silver_coins",40+roll)
	Main.add_text(tr("EXPLORER_RUINS_BARRACKS_SEARCHED").format({"name":tr("SILVER_COINS")}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_junction","grade":1}},"","",3))

func search_barracks_failed(_actor,_action,_roll):
	Map.time += 60*8
	barracks_searched = true
	Items.add_items("lever")
	Main.add_text(tr("EXPLORER_RUINS_BARRACKS_SEARCHED_FAILED"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_junction","grade":1}},"","",3))

func enter_storage(_actor,_action,_roll):
	Map.time += 30
	Main.set_title("STORAGE_ROOM")
	if barracks_known:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_STORAGE"))
	else:
		storage_known = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_STORAGE"))
	if !storage_searched:
		Main.add_action(Game.Action.new(tr("SEARCH_ROOM"),self,{10:{"method":"search_storage","grade":1},0:{"method":"search_storage_failed","grade":0}},"cunning","intelligence",4,10))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"continue_carefully","grade":1}},"","",3))
	if shrine_known:
		Main.add_action(Game.Action.new(tr("ENTER_SHRINE"),self,{0:{"method":"enter_shrine","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_EAST"),self,{0:{"method":"enter_shrine","grade":1}},"","",3))
	if workshop_known:
		Main.add_action(Game.Action.new(tr("ENTER_WORKSHOP"),self,{0:{"method":"enter_workshop","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_NORTH"),self,{0:{"method":"enter_workshop","grade":1}},"","",3))

func search_storage(_actor,_action,_roll):
	Map.time += 60*5
	storage_searched = true
	Main.add_text(tr("EXPLORER_RUINS_STORAGE_SEARCH").format({"item":tr("SMALL_HEALTH_POTION")}))
	Items.add_items("small_health_potion")
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func search_storage_failed(_actor,_action,_roll):
	Map.time += int(60*7.5)
	storage_searched = true
	Main.add_text(tr("EXPLORER_RUINS_STORAGE_SEARCH_FAILED"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func enter_shrine(_actor,_action,_roll):
	Main.set_title("SHRINE")
	Map.time += 30
	if shrine_known:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_SHRINE"))
	else:
		shrine_known = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_SHRINE"))
	if !chalice_examined:
		Main.add_text(tr("EXPLORER_RUINS_CHALICE"))
		Main.add_action(Game.Action.new(tr("EXPLORER_RUINS_EXAMINE_CHALICE"),self,{10:{"method":"chalice_toxic","grade":2},0:{"method":"examine_chalice","grade":1}},"wisdom","intelligence",3,10))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func examine_chalice(_actor,_action,_roll):
	chalice_examined = true
	Main.add_text(tr("EXPLORER_RUINS_CHALICE_DESC")+"\n"+tr("EXPLORER_RUINS_CHALICE_DELICIOUS"))
	Main.add_action(Game.Action.new(tr("DRINK_IT"),self,{0:{"method":"drink_chalice","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func drink_chalice(_actor,_action,_roll):
	chalice_used = true
	Main.add_text(tr("EXPLORER_RUINS_DRINK_CHALICE"))
	Characters.player.damaged(4)
	Characters.player.stressed()
	Characters.player.drained()
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func chalice_toxic(_actor,_action,_roll):
	chalice_examined = true
	chalice_used = true
	Main.add_text(tr("EXPLORER_RUINS_CHALICE_DESC")+"\n"+tr("EXPLORER_RUINS_CHALICE_POISONOUS"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_storage","grade":1}},"","",3))

func enter_workshop(_actor,_action,_roll):
	Main.set_title("WORKSHOP")
	Map.time += 30
	if workshop_known:
		Main.add_text("\n"+tr("EXPLORER_RUINS_ENTER_WORKSHOP"))
	else:
		workshop_known = true
		Main.add_text("\n"+tr("EXPLORER_RUINS_WORKSHOP"))
	if !dead_body_examined:
		Main.add_action(Game.Action.new(tr("EXAMINE_CORPSE"),self,{0:{"method":"examine_workshop_adventurer","grade":1}},"","",4))
		return
	if Items.has_item("lever") && !door_opened:
		Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_LEVER"))
		Main.add_action(Game.Action.new(tr("EXPLORER_ATTACH_LEVER"),self,{0:{"method":"insert_lever","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_storage","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_NORTH"),self,{0:{"method":"enter_temple","grade":1}},"","",3))

func examine_workshop_adventurer(_actor,_action,_roll):
	Map.time += 30
	dead_body_examined = true
	Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_ADVENTURER"))
	if found_dead_adventurers:
		Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_ANOTHER_ADVENTURER"))
	Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_ADVENTURER_SCROLL"))
	Main.add_action(Game.Action.new(tr("SCROLL_TAKE_LOOK"),self,{0:{"method":"examine_scroll","grade":1}},"","",2))

func examine_scroll(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_SCROLL"))
	Main.add_action(Game.Action.new(tr("TAKE_SCROLL"),self,{0:{"method":"take_scroll","grade":1}},"","",2))

func take_scroll(_actor,_action,_roll):
	Journal.add_entry(tr("FOUND_MYSTERIOUS_SCROLL"), tr("FOUND_MYSTERIOUS_SCROLL"), ["quests"], tr("FOUND_MYSTERIOUS_SCROLL_TEXT"), "", Map.time)
	Items.add_items("mysterious_scroll")
	Main.add_text(tr("EXPLORER_TAKE_SCROLL"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_workshop","grade":1}},"","",2))

func insert_lever(_actor,_action,_roll):
	door_opened = true
	Main.add_text(tr("EXPLORER_RUINS_WORKSHOP_INSERT_LEVER"))
	Items.remove_items("lever")
	enter_workshop(_actor,_action,_roll)

func enter_temple(_actor,_action,_roll):
	Map.time += 30
	Main.set_title("CORRIDOR")
	if door_opened:
		Main.add_text("\n"+tr("EXPLORER_RUINS_TEMPLE_ENCOUNTER")+"\n"+tr("EXPLORER_RUINS_TEMPLE_CREATURE"))
		Main.add_action(Game.Action.new(tr("RUN"),self,{9:{"method":"run_escape","grade":1},0:{"method":"run_slow","grade":0}},"agility","",5,9))
		return
	else:
		Main.add_text("\n"+tr("EXPLORER_RUINS_TEMPLE_LOCKED"))
	Main.add_action(Game.Action.new(tr("GO_WEST"),self,{0:{"method":"enter_junction","grade":1}},"","",3))
	if workshop_known:
		Main.add_action(Game.Action.new(tr("ENTER_WORKSHOP"),self,{0:{"method":"enter_workshop","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_EAST"),self,{0:{"method":"enter_workshop","grade":1}},"","",3))

func run_escape(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_TEMPLE_RUN")+"\n"+tr("EXPLORER_RUINS_TEMPLE_RUN_ESCAPE"))
	Main.add_action(Game.Action.new(tr("RUN"),self,{0:{"method":"run_failed","grade":0}},"","",3))

func run_failed(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_TEMPLE_RUN_ESCAPE_FAILED"))
	no_escape(_actor,_action,_roll)

func run_slow(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_RUINS_TEMPLE_RUN")+"\n"+tr("EXPLORER_RUINS_TEMPLE_RUN_FOLLOWED"))
	no_escape(_actor,_action,_roll)

func no_escape(_actor,_action,_roll):
	Items.add_remove("torch")
	Main.add_text(tr("EXPLORER_RUINS_TEMPLE_NO_ESCAPE"))
	Main.add_action(Game.Action.new(tr("READ_SCROLL"),self,{0:{"method":"read_scroll","grade":1}},"","",4,1))

func read_scroll(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_READ_SCROLL"))
	if story=="fighter" || story=="archer" || story=="rogue":
		Main.add_text(tr("MERCENARY_SCROLL_ILITERATE"))
	elif story=="wizard" || story=="cleric" || story=="druid":
		Main.add_text(tr("MERCENARY_SCROLL_MAGICAL"))
	else:
		Main.add_text(tr("MERCENARY_SCROLL_UNMAGICAL"))
	Main.add_text(tr("MERCENARY_SCROLL_SHIFTING"))
	Main.add_action(Game.Action.new(tr("TRY_HARDER"),self,{0:{"method":"continue_reading_scroll","grade":1}},"","",3,1))

func continue_reading_scroll(_actor,_action,_roll):
	Items.remove_items("mysterious_scroll")
	Items.add_items("scroll_handles")
	Main.add_text(tr("MERCENARY_SCROLL_LOCK_IN")+"\n"+tr("WIZARD_SCROLL_DISINTEGRATING"))
	Main.add_text(tr("EXPLORER_BLACK_OUT"))
	Main.add_action(Game.Action.new(tr("WAKE_UP"),self,{0:{"method":"wake_up","grade":1}},"","",3,1))

func wake_up(_actor,_action,_roll):
	Journal.add_entry(tr("SCROLL_ESCAPED_RUINS_SOMEHOW"), tr("SCROLL_ESCAPED_RUINS_SOMEHOW"), ["quests"], tr("SCROLL_ESCAPED_RUINS_SOMEHOW_TEXT"), "", Map.time)
	Main.set_title("UNKNOWN_ROOM")
	Map.time += 4*60*60
	Main.add_text("\n"+tr("EXPLORER_WAKE_UP"))
	Main.add_action(Game.Action.new(tr("GO_OUTSIDE"),self,{0:{"method":"enter_inn","grade":1}},"","",3))

func enter_inn(_actor,_action,_roll):
	Main.set_title("INN")
	Main.add_text(tr("EXPLORER_ENTER_INN"))
	Main.add_action(Game.Action.new(tr("ASK_WHAT_HAPPENED"),self,{0:{"method":"ask_what","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("ASK_WHERE_AM_I"),self,{0:{"method":"ask_where","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave_inn","grade":1}},"","",4))

func ask_what(_actor,_action,_roll):
	var name := Names.get_random_name(0, Characters.player.race)
	Main.add_text(tr("EXPLORER_INN_WHAT").format({"name":name.first}))
	Main.add_action(Game.Action.new(tr("ASK_WHERE_AM_I"),self,{0:{"method":"ask_where","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SAY_DONT_KNOW"),self,{0:{"method":"say_dont_know","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SHOW_HER_SCROLL"),self,{0:{"method":"show_scroll","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SAY_NONE_BUSINESS"),self,{0:{"method":"leave_inn","grade":1}},"","",4))

func ask_where(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_INN_WHERE"))
	Main.add_action(Game.Action.new(tr("ASK_WHAT_HAPPENED").format({"city":Map.get_location(location).name}),self,{0:{"method":"ask_what","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SAY_DONT_KNOW"),self,{0:{"method":"say_dont_know","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SHOW_HER_SCROLL"),self,{0:{"method":"show_scroll","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("SAY_NONE_BUSINESS"),self,{0:{"method":"leave_inn","grade":1}},"","",4))

func say_dont_know(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_INN_DONT_KNOW"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave_inn","grade":1}},"","",4))

func show_scroll(_actor,_action,_roll):
	Main.add_text(tr("EXPLORER_INN_SCROLL"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave_inn","grade":1}},"","",4))

func leave_inn(_actor,_action,_roll):
	Main.set_title(Map.get_location(location).name)
	Map.time += 25*60
	Main.add_text("\n"+tr("EXPLORER_CITY"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_action,_roll):
	Game.location = location
	Map.time += 5*60
	Map.get_location(location).traits.push_back("summoned")
	Game.enter_location(Game.location)
	Game._save()
