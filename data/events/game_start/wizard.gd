extends Node

var location : String
var story : String
var workroom_known := false
var workroom_locked := true
var workroom_entered := false
var workroom_searched := false
var lab_known := false
var lab_entered := false
var lab_imp := true
var lab_access := false
var lab_no_access := false
var lab_illuminated := false
var lab_devices_investigated := false
var lab_corpses_investigated := false
var lab_searched := false
var lab_reexamined := false
var burned_hand := false
var forge_known := false
var forge_metal_examined := false
var forge_hammer_examined := false
var forge_contraptions_examined := false
var forge_searched := false
var forge_searched_again := false
var look_for_key := false


func init(_city : Map.Location,_location,_cl=null):
	location = _location
	if Characters.player.background.size()>0:
		story = Characters.player.background[0]
	match story:
		"drifter":
			Main.add_text(tr("DRIFTER_WIZARD")+"\n"+tr("DRIFTER_WIZARD_INIT")+"\n")
			Main.add_text(tr("DRIFTER_WIZARD_NO_REASON_TO_STAY")+"\n"+tr("DRIFTER_WIZARD_SPELL_BOOK_THEFT")+"\n")
		"slave":
			Main.add_text(tr("DRIFTER_WIZARD")+"\n"+tr("DRIFTER_WIZARD_INIT")+"\n")
			Main.add_text(tr("DRIFTER_WIZARD_NO_REASON_TO_STAY")+"\n"+tr("DRIFTER_WIZARD_SPELL_BOOK_THEFT")+"\n")
	
	Main.add_action(Game.Action.new(tr("ENTER_THE_BASEMENT"),self,{0:{"method":"enter_basement","grade":1}},"","",3))

func enter_basement(_actor,_action,_roll):
	Main.add_text(tr("DRIFTER_WIZARD_BASEMENT"))
	goto_crossroads(_actor,_action,_roll)

func goto_crossroads(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("CROSSROADS"))
	Main.add_text("\n"+tr("APPROACH_CROSSROADS"))
	
	if lab_illuminated && forge_searched && (!look_for_key):
		Main.add_text(tr("WIZARD_BASEMENT_WHERE_KEY"))
		match story:
			"drifter":
				look_for_key = true
				Main.add_text(tr("WIZARD_BASEMENT_LOOK_FOR_KEY"))
			_:
				pass
	
	if lab_reexamined:
		Main.add_action(Game.Action.new(tr("GO_UPSTAIRS"),self,{0:{"method":"go_upstairs","grade":0}},"","",3),1)
	if lab_known:
		Main.add_action(Game.Action.new(tr("ENTER_LAB"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_LEFT"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",3))
	if workroom_known:
		Main.add_action(Game.Action.new(tr("ENTER_WORKROOM"),self,{0:{"method":"enter_basement_workroom","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_STRAIGHTFORWARD"),self,{0:{"method":"enter_basement_workroom","grade":1}},"","",3))
	if forge_known:
		Main.add_action(Game.Action.new(tr("ENTER_FORGE"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("GO_RIGHT"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",3))


# lab #

func enter_basement_lab(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("LABORATORY"))
	Main.add_text("\n"+tr("WIZARD_BASEMENT_ENTER_LAB"))
	if !lab_entered:
		Main.add_text(tr("WIZARD_BASEMENT_LAB").format({"race":tr(Characters.player.race.to_upper())}))
		lab_entered = true
	Main.add_text("")
	
	if !lab_access:
		Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_APPROACHING"))
		match story:
			"drifter":
				Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_KNOWN")+"\n")
				Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_NOT_ALLOWED"))
				Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_WHAT_DOING")+"\n")
				if !lab_no_access:
					Main.add_action(Game.Action.new(tr("MAKE_UP_EXCUSE"),self,{15:{"method":"imp_access_allowed","grade":1},0:{"method":"imp_access_forbidden","grade":0}},"charisma","cunning",4,15))
				Main.add_action(Game.Action.new(tr("ACTION_ATTACK"),self,{0:{"method":"attack_lab_imp","grade":1}},"","",2))
				Main.add_action(Game.Action.new(tr("SAY_SORRY"),self,{0:{"method":"imp_go_back","grade":1}},"","",2))
				return
			_:
				Main.add_text("\n"+tr("WIZARD_BASEMENT_LAB_IMP_INTRUDER"))
				Main.add_action(Game.Action.new(tr("ACTION_ATTACK"),self,{0:{"method":"attack_lab_imp","grade":1}},"","",2))
				return
	
	lab_known = true
	
	if Items.has_item("metallic_contraptions") && Items.has_item("faintly_glowing_crystal"):
		Items.add_items("magical_device")
		Items.remove_items("metallic_contraptions")
		Items.remove_items("faintly_glowing_crystal")
		Main.add_text(tr("WIZARD_BASEMENT_COMBINE_DEVICE"))
	
	if !lab_illuminated:
		Main.add_text(tr("WIZARD_BASEMENT_LAB_DARK")+"\n")
		if Characters.player.proficiency.has("light_magic"):
			Main.add_action(Game.Action.new(tr("WIZARD_CAST_LIGHT"),self,{0:{"method":"lab_light","grade":1}},"","",2))
		if Characters.player.proficiency.has("fire_magic"):
			Main.add_action(Game.Action.new(tr("WIZARD_CAST_FIRE"),self,{10:{"method":"lab_fire","grade":1},0:{"method":"lab_fire_burn","grade":0}},"intelligence","cunning",4,10))
		if Items.has_item("candle"):
			Main.add_action(Game.Action.new(tr("LIGHT_CANDLE"),self,{0:{"method":"lab_candle","grade":1}},"","",2))
	else:
		if !lab_devices_investigated:
			Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_LAB_INVESTIGATE_DEVICES"),self,{0:{"method":"investigate_devices","grade":1}},"","",3))
		if !lab_corpses_investigated:
			Main.add_action(Game.Action.new(tr("INVESTIGATE_CORPSES"),self,{0:{"method":"lab_corpses","grade":1}},"","",4))
		if look_for_key && !lab_searched:
			Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_SEARCH_LAB"),self,{10:{"method":"lab_search","grade":1},0:{"method":"lab_search_failed","grade":0}},"cunning","intelligence",4,10))
	if Items.has_item("magical_device") && lab_corpses_investigated && lab_devices_investigated && !lab_reexamined:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_LAB_REEXAMINE"),self,{0:{"method":"lab_reexamine","grade":1}},"","",4))
	
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func imp_access_allowed(_actor,_action,_roll):
	lab_access = true
	Map.time += 60*2
	Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_LAB_ACCESS")+"\n")
	enter_basement_lab(_actor,_action,_roll)

func imp_access_forbidden(_actor,_action,_roll):
	if story=="drifter":
		Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_BACK_TO_WORK")+"\n")
	else:
		Main.add_text(tr("WIZARD_IMP_LOST_SIGHT")+"\n")
	lab_no_access = true
	Main.add_action(Game.Action.new(tr("ACTION_ATTACK"),self,{0:{"method":"attack_lab_imp","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func attack_lab_imp(_actor,_action,_roll):
	var script = load("res://data/events/game_start/wizard_basement_fight.gd").new()
	script.init(self)

func lab_imp_defeated(_actor,_action,_roll):
	lab_access = true
	lab_imp = false
	Map.time += 60*5
	if story=="mercenary":
		Main.add_text(tr("WIZARD_IMP_KEY"))
		Items.add_items("workroom_key")
	enter_basement_lab(_actor,_action,_roll)

func imp_go_back(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_BASEMENT_LAB_IMP_BACK_TO_WORK")+"\n")
	goto_crossroads(_actor,_action,_roll)

func investigate_devices(_actor,_action,_roll):
	lab_devices_investigated = true
	Map.time += 60*2
	Main.add_text(tr("WIZARD_BASEMENT_LAB_CRYSTAL_DEVICES")+"\n"+tr("WIZARD_BASEMENT_LAB_CRYSTAL_DEVICES_FAMILIAR"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",2))

func lab_light(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_LAB_LIGHT_BLOB")+"\n")
	lab_visible()

func lab_fire(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_LAB_FLAME")+"\n")
	lab_visible()

func lab_fire_burn(_actor,_action,_roll):
	Map.time += 60
	burned_hand = true
	Characters.player.damaged()
	Main.add_text(tr("WIZARD_LAB_FLAME_FAILED")+"\n")
	lab_visible()

func lab_candle(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_LAB_CANDLE")+"\n")
	Items.remove_items("candle")
	lab_visible()

func lab_visible():
	lab_illuminated = true
	Main.add_text(tr("WIZARD_BASEMENT_LAB_ILLUMINATED")+"\n"+tr("WIZARD_BASEMENT_LAB_CORPSES"))
	Main.add_action(Game.Action.new(tr("INVESTIGATE_CORPSES"),self,{0:{"method":"lab_corpses","grade":1}},"","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func lab_corpses(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_BASEMENT_LAB_APPROACH_CORPSES"))
	Main.add_action(Game.Action.new(tr("FIGHT_NAUSEA"),self,{10:{"method":"lab_corpses_continue","grade":1},0:{"method":"lab_corpses_vomit","grade":0}},"constitution","wisdom",3,10))
	Main.add_action(Game.Action.new(tr("BACK_OFF"),self,{0:{"method":"goto_crossroads","grade":1}},"","",2))

func lab_corpses_vomit(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_BASEMENT_LAB_VOMIT"))
	if lab_imp:
		Main.add_text(tr("WIZARD_BASEMENT_LAB_VOMIT_IMP"))
	lab_corpses_continue(_actor,_action,_roll)

func lab_corpses_continue(_actor,_action,_roll):
	Map.time += 60*2
	lab_corpses_investigated = true
	Main.add_text(tr("WIZARD_BASEMENT_LAB_CORPSES_STATUS"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",3))

func lab_search(_actor,_action,_roll):
	Map.time += 60*3
	lab_searched = true
	Main.add_text(tr("WIZARD_BASEMENT_LAB_SEARCHED").format({"item":tr("SMALL_HEALTH_POTION")}))
	Items.add_items("small_health_potion")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",3))

func lab_search_failed(_actor,_action,_roll):
	Map.time += 60*5
	lab_searched = true
	Main.add_text(tr("WIZARD_BASEMENT_LAB_SEARCHED_FAILED"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_lab","grade":1}},"","",3))

func lab_reexamine(_actor,_action,_roll):
	Map.time += 60*2
	lab_reexamined = true
	Main.add_text(tr("WIZARD_LAB_MACHINERY")+"\n"+tr("WIZARD_LAB_REACTION"))
	Main.add_action(Game.Action.new(tr("TAKE_CLOSER_LOOK"),self,{0:{"method":"lab_corpse_reanimate","grade":0}},"","",2,1))

func lab_corpse_reanimate(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_LAB_REANIMATE"))
	if lab_imp:
		Main.add_text(tr("WIZARD_LAB_IMP_CORPSE"))
	Main.add_text(tr("WIZARD_LAB_MACHINES_ACTIVE"))
	if lab_imp:
		Main.add_text(tr("WIZARD_LAB_IMP_ANGRY"))
	Items.remove_items("magical_device")
	Main.add_action(Game.Action.new(tr("TAKE_CLOSER_LOOK"),self,{0:{"method":"lab_investigate_machine","grade":1}},"","",4,0))

func lab_investigate_machine(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_LAB_MACHINE")+"\n"+tr("WIZARD_LAB_SCROLL"))
	Main.add_action(Game.Action.new(tr("TAKE_SCROLL"),self,{0:{"method":"lab_take_scroll","grade":1}},"","",3,0))

func lab_take_scroll(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_LAB_TAKE_SCROLL"))
	Items.add_items("mysterious_scroll")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))
	Journal.add_entry(tr("FOUND_MYSTERIOUS_SCROLL"), tr("FOUND_MYSTERIOUS_SCROLL"), ["quests"], tr("FOUND_MYSTERIOUS_SCROLL_TEXT"), "", Map.time)


# forge #

func enter_basement_forge(_actor,_action,_roll):
	Map.time += 30
	Main.set_title(tr("FORGE"))
	
	if !forge_known:
		Main.add_text("\n"+tr("WIZARD_BASEMENT_FORGE_DOOR")+"\n"+tr("WIZARD_BASEMENT_FORGE_OPERATION"))
		forge_known = true
	else:
		Main.add_text("\n"+tr("WIZARD_BASEMENT_ENTER_FORGE"))
	
	if !forge_hammer_examined:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_FORGE_EXAMINE_HAMMER"),self,{0:{"method":"examine_hammer","grade":1}},"","",4))
	if !forge_metal_examined:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_FORGE_EXAMINE_METAL"),self,{0:{"method":"examine_metal","grade":1}},"","",2))
	if !forge_contraptions_examined && forge_searched:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_FORGE_EXAMINE_CONTRAPTION"),self,{0:{"method":"examine_contraptions","grade":1}},"","",2))
	if !forge_searched:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_SEARCH_FORGE"),self,{12:{"method":"search_forge","grade":2},0:{"method":"search_forge_failed","grade":1}},"cunning","intelligence",4,12))
	if look_for_key && !forge_searched_again:
		Main.add_action(Game.Action.new(tr("WIZARD_BASEMENT_SEARCH_FORGE_AGAIN"),self,{10:{"method":"forge_second_search","grade":2},0:{"method":"forge_second_search_failed","grade":1}},"cunning","intelligence",4,10))
	
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func examine_metal(_actor,_action,_roll):
	forge_metal_examined = true
	Map.time += 60
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_METAL"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func examine_hammer(_actor,_action,_roll):
	forge_hammer_examined = true
	Map.time += 60
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_HAMMER"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func examine_contraptions(_actor,_action,_roll):
	forge_contraptions_examined = true
	Map.time += 60
	Items.add_items("metallic_contraptions")
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_CONTRAPTION"))
	if lab_devices_investigated:
		Main.add_text(tr("WIZARD_BASEMENT_FORGE_CONTRAPTION_REMIND"))
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_CONTRAPTION_GAINED"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func search_forge(_actor,_action,_roll):
	Map.time += 60*2
	forge_searched = true
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_SEARCHED").format({"item":tr("DAGGER")}))
	if burned_hand:
		Main.add_text(tr("WIZARD_BASEMENT_BURNED_HAND_CANDLE"))
	Items.add_items("dagger")
	Items.add_items("candle")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func search_forge_failed(_actor,_action,_roll):
	Map.time += 60*4
	forge_searched = true
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_FAILED_SEARCHED"))
	if burned_hand:
		Main.add_text(tr("WIZARD_BASEMENT_BURNED_HAND_CANDLE"))
	Items.add_items("candle")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func forge_second_search(_actor,_action,_roll):
	Map.time += 60*3
	forge_searched_again = true
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_SEARCHED_AGAIN").format({"item":tr("SMALL_HEALTH_POTION")}))
	Items.add_items("small_health_potion")
	Items.add_items("workroom_key")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))

func forge_second_search_failed(_actor,_action,_roll):
	Map.time += 60*5
	forge_searched_again = true
	Main.add_text(tr("WIZARD_BASEMENT_FORGE_SEARCHED_AGAIN_FAILED"))
	Items.add_items("workroom_key")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"enter_basement_forge","grade":1}},"","",2))


# workroom #

func enter_basement_workroom(_actor,_action,_roll):
	Map.time += 30
	workroom_known = true
	Main.set_title(tr("WORKROOM"))
	if workroom_locked:
		Main.add_text(tr("WIZARD_BASEMENT_LOCKED"))
		if Items.has_item("workroom_key"):
			Main.add_action(Game.Action.new(tr("UNLOCK_KEY"),self,{0:{"method":"open_workroom","grade":1}},"","",2))
		Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))
		return
	
	Main.add_text("\n"+tr("WIZARD_BASEMENT_ENTER_WORKROOM"))
	if !workroom_entered:
		Map.time += 60*15
		workroom_entered = true
		Main.add_text(tr("WIZARD_WORKROOM_MESS")+"\n"+tr("WIZARD_WORKROOM_SHELVES"))
	
	if !workroom_searched:
		Main.add_action(Game.Action.new(tr("WIZARD_WORKROOM_SEARCH_DRAWERS"),self,{10:{"method":"workroom_search","grade":2},0:{"method":"workroom_search_failed","grade":1}},"cunning","intelligence",4,10))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func open_workroom(_actor,_action,_roll):
	workroom_locked = false
	Main.add_text(tr("WIZARD_BASEMENT_OPEN_WORKROOM"))
	Items.remove_items("workroom_key")
	enter_basement_workroom(_actor,_action,_roll)

func workroom_search(_actor,_action,_roll):
	Map.time += 60*3
	workroom_searched = true
	Main.add_text(tr("WIZARD_WORKROOM_DRAWERS").format({"item":tr("SMALL_MANA_POTION")}))
	Items.add_items("small_mana_potion")
	Items.add_items("faintly_glowing_crystal")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))

func workroom_search_failed(_actor,_action,_roll):
	Map.time += 60*5
	workroom_searched = true
	Main.add_text(tr("WIZARD_WORKROOM_DRAWERS_FAILED"))
	Items.add_items("faintly_glowing_crystal")
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"goto_crossroads","grade":1}},"","",3))


# end #

func go_upstairs(_actor,_action,_roll):
	Main.add_text("\n"+tr("WIZARD_APPEARING"))
	match story:
		"drifter":
			Main.add_text(tr("WIZARD_REPLY_KNOWN"))
		_:
			Main.add_text(tr("WIZARD_REPLY_UNKNOWN"))
	Main.add_text(tr("WIZARD_SCROLL_NOTICED"))
	Main.add_action(Game.Action.new(tr("ASK_WHY_HE_DID"),self,{9:{"method":"question_why","grade":1},0:{"method":"question_failed","grade":0}},"charisma","wisdom",3,9))
	Main.add_action(Game.Action.new(tr("ASK_WHAT_HE_DID"),self,{9:{"method":"question_what","grade":1},0:{"method":"question_failed","grade":0}},"charisma","cunning",3,9))

func question_why(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_ANSWER_WHY").format({"race":tr(Characters.player.race.to_upper()+"_PLURAL")}))
	Main.add_action(Game.Action.new(tr("ASK_MORE"),self,{0:{"method":"question_failed","grade":0}},"charisma","",3,10))

func question_what(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_ANSWER_WHAT"))
	Main.add_action(Game.Action.new(tr("ASK_MORE"),self,{0:{"method":"question_failed","grade":0}},"charisma","",3,10))

func question_failed(_actor,_action,_roll):
	Main.add_text(tr("WIZARD_ANSWER_NO"))
	Main.add_action(Game.Action.new(tr("READ_SCROLL"),self,{0:{"method":"read_scroll","grade":1}},"","",4,1))

func read_scroll(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("MERCENARY_READ_SCROLL")+"\n"+tr("WIZARD_SCROLL_EXAMINE")+"\n"+tr("MERCENARY_SCROLL_SHIFTING")+"\n"+tr("WIZARD_SCROLL_COMENT"))
	Main.add_action(Game.Action.new(tr("TRY_HARDER"),self,{0:{"method":"continue_reading_scroll","grade":1}},"","",3,1))

func continue_reading_scroll(_actor,_action,_roll):
	Items.remove_items("mysterious_scroll")
	Items.add_items("scroll_handles")
	Main.add_text(tr("MERCENARY_SCROLL_LOCK_IN")+"\n"+tr("MERCENARY_SCROLL_IMPOSSIBLE")+"\n"+tr("WIZARD_SCROLL_DISINTEGRATING")+"\n"+tr("WIZARD_WHAT_DONE")+"\n"+tr("WIZARD_BLACK_OUT"))
	Main.add_action(Game.Action.new(tr("WAKE_UP"),self,{0:{"method":"wake_up","grade":1}},"","",3))

func wake_up(_actor,_action,_roll):
	Main.set_title(tr("UNFAMILIAR_ROOM"))
	Map.time += 60*35
	Main.add_text("\n"+tr("WIZARD_WAKE_UP"))
	Main.add_action(Game.Action.new(tr("EXAMINE_ROOM"),self,{0:{"method":"examine_room","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("GO_UPSTAIRS"),self,{0:{"method":"leave_go_upstrairs","grade":1}},"","",3))
	Journal.add_entry(tr("SCROLL_ESCAPED_WIZARD_SOMEHOW"), tr("SCROLL_ESCAPED_WIZARD_SOMEHOW"), ["quests"], tr("SCROLL_ESCAPED_WIZARD_SOMEHOW_TEXT"), "", Map.time)

func examine_room(_actor,_action,_roll):
	Map.time += 60
	Main.add_text(tr("WIZARD_NEW_ROOM"))
	Main.add_action(Game.Action.new(tr("GO_UPSTAIRS"),self,{0:{"method":"leave_go_upstrairs","grade":1}},"","",3))

func leave_go_upstrairs(_actor,_action,_roll):
	Main.set_title(tr("UNFAMILIAR_BUILDING"))
	Map.time += 60*2
	Main.add_text(tr("WIZARD_NEW_BUILDING"))
	Main.add_action(Game.Action.new(tr("LEAVE_BUILDING"),self,{0:{"method":"go_outside","grade":1}},"","",3))

func go_outside(_actor,_action,_roll):
	Main.set_title(tr("UNFAMILIAR_CITY"))
	Map.time += 60
	Main.add_text(tr("WIZARD_OUTSIDE"))
	Main.add_action(Game.Action.new(tr("EXPLORE_CITY"),self,{0:{"method":"explore","grade":1}},"","",3))

func explore(_actor,_action,_roll):
	Main.set_title(Map.get_location(location).name)
	Map.time += 60*15
	Main.add_text(tr("WIZARD_CITY"))
	Main.add_action(Game.Action.new(tr("ASK_AROUND"),self,{0:{"method":"ask_around","grade":1}},"","",5,1))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func ask_around(_actor,_action,_roll):
	Map.time += 60*10
	Main.add_text(tr("WIZARD_ASK_AROUND"))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_action,_roll):
	Game.location = location
	Map.get_location(location).traits.push_back("reshaped")
	Map.time += 60*5
	Game.enter_location(Game.location)
	Game._save()
