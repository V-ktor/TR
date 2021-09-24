extends Node

var location : Map.Location
var parent_script
var quest
var character : Characters.Character


func init(_location,_parent_script,_quest):
	location = _location
	parent_script = _parent_script
	quest = _quest
	character = Characters.characters[Characters.party[randi()%Characters.party.size()]]
	
	if randf()<0.1:
		Main.add_text(tr("DELIVER_PACKAGE_NOISE"))
		Main.add_action(Game.Action.new(tr("ACTION_OPEN_PACKAGE"),self,{0:{"method":"open_alive_package","grade":1}},"","",3))
		Main.add_action(Game.Action.new(tr("REST"),self,{0:{"method":"rest","grade":1}},"","",3))
		return
	if quest.data=="dont_open":
		Main.add_text(tr("DELIVER_PACKAGE_WANT_TO_OPEN"))
	else:
		Main.add_text(tr("DELIVER_PACKAGE_CHECK_TO_BE_SURE"))
	if character!=Characters.player:
		if "curious" in character.personality || "bold" in character.personality:
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_PARTY").format({"name":character.name.first,"he/she":tr(Characters.HE_SHE[character.gender])}))
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_CURIOUS"))
		elif "evil" in character.personality || "cynical" in character.personality:
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_PARTY").format({"name":character.name.first,"he/she":tr(Characters.HE_SHE[character.gender])}))
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_EVIL"))
		elif "lawful" in character.personality || "shy" in character.personality:
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_PARTY").format({"name":character.name.first,"he/she":tr(Characters.HE_SHE[character.gender])}))
			if quest.data=="dont_open":
				Main.add_text(tr("DELIVER_PACKAGE_OPEN_LAWFUL"))
			else:
				Main.add_text(tr("DELIVER_PACKAGE_OPEN_LAWFUL_ALT"))
		else:
			Main.add_text(tr("DELIVER_PACKAGE_OPEN_NEUTRAL").format({"name":character.name.first}))
	else:
		Main.add_text(tr("DELIVER_PACKAGE_OPEN_NO_ONE"))
	Main.add_action(Game.Action.new(tr("ACTION_OPEN_PACKAGE"),self,{0:{"method":"open_package","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("REST"),self,{0:{"method":"rest","grade":1}},"","",3))

func open_package(_actor,_action,_roll):
	var type := randi()%8
	match type:
		0,1:
			if randf()<0.33:
				# Illegal content.
				quest.data.illegal = true
				if Characters.player.proficiency.has("alchemy"):
					Main.add_text(tr("OPEN_PACKAGE_ILLEGAL_HERBS"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"ignore_illegal_cargo","grade":1}},"","",2))
					Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_illegal_cargo","grade":1}},"","",3))
				elif Characters.player.proficiency.has("survival"):
					Main.add_text(tr("OPEN_PACKAGE_TOXIC_HERBS"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
					Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_unknown_cargo","grade":1}},"","",3))
				else:
					character = Characters.has_proficiency("alchemy")
					if character:
						Main.add_text(tr("OPEN_PACKAGE_ILLEGAL_HERBS_PARTY").format({"name":character.name.first}))
						if "lawful" in character.personality:
							Main.add_text(tr("OPEN_PACKAGE_ILLEGAL_HERBS_PARTY_LAWFUL"))
						elif "evil" in character.personality:
							Main.add_text(tr("OPEN_PACKAGE_ILLEGAL_HERBS_PARTY_EVIL"))
						else:
							Main.add_text(tr("OPEN_PACKAGE_ILLEGAL_HERBS_PARTY_ILLEGAL"))
						Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"ignore_illegal_cargo","grade":1}},"","",2))
						Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_illegal_cargo","grade":1}},"","",3))
					else:
						Main.add_text(tr("OPEN_PACKAGE_UNFAMILIAR_HERBS"))
						Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
						Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_unknown_cargo","grade":1}},"","",3))
			else:
				if Characters.has_proficiency("alchemy"):
					Main.add_text(tr("OPEN_PACKAGE_REGULAR_HERBS"))
					Main.add_action(Game.Action.new(tr("DELIVER_PACKAGE_CLOSE_PACKAGE_LEGAL"),self,{0:{"method":"close_package_legal","grade":1}},"","",2))
				else:
					Main.add_text(tr("OPEN_PACKAGE_UNFAMILIAR_HERBS"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
					Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_unknown_cargo","grade":1}},"","",3))
		2:
			Main.add_text(tr("OPEN_PACKAGE_WHITE_POWDER"))
			if randf()<0.5:
				character = Characters.has_proficiency("alchemy")
				Main.add_text(tr("POWDER_COLOR_CHANGE"))
				if character && character!=Characters.player:
					Main.add_text(tr("POWDER_COLOR_CHANGE_PARTY").format({"name":character.name.first}))
				else:
					Main.add_text(tr("THAT_COULD_BE_A_PROBLEM"))
				quest.data.damaged = true
			else:
				character = Characters.has_proficiency("alchemy")
				Main.add_text(tr("OPEN_PACKAGE_UNFAMILIAR_POWDER"))
				if character && character!=Characters.player:
					Main.add_text(tr("OPEN_PACKAGE_UNFAMILIAR_POWDER_PARTY").format({"name":character.name.first,"he/she":tr(Characters.HE_SHE[character.gender])}))
				if randf()<0.5:
					quest.data.illegal = true
			Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
			Main.add_action(Game.Action.new(tr("ACTION_GET_RID_PACKAGE"),self,{0:{"method":"get_rid_of_unknown_cargo","grade":1}},"","",3))
		3,4:
			Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS"))
			if character==Characters.player:
				character = Characters.has_proficiency("alchemy")
			if character!=Characters.player:
				Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_PARTY").format({"name":character.name.first}))
				if "alchemy" in character.proficiency:
					Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_ALCHEMY"))
				elif "lawful" in character.personality:
					Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_LAWFUL"))
				elif "chaotic" in character.personality || "cynical" in character.personality:
					Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_CHAOTIC"))
				elif "evil" in character.personality:
					Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_EVIL"))
				else:
					Main.add_text(tr("OPEN_PACKAGE_MYSTERIOUS_POTIONS_RATIONAL"))
			Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
			Main.add_action(Game.Action.new(tr("ACTION_STEAL_PACKAGE"),self,{0:{"method":"steal_potions","grade":1}},"","",2))
		5:
			var t := randi()%3
			Main.add_text(tr("OPEN_PACKAGE_NOTE"))
			match t:
				0:
					Main.add_text(tr("OPEN_PACKAGE_NOTE1"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package_fire","grade":1}},"","",2))
				1:
					Main.add_text(tr("OPEN_PACKAGE_NOTE2"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
				2:
					Main.add_text(tr("OPEN_PACKAGE_NOTE3"))
					Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
		6:
			Main.add_text(tr("OPEN_PACKAGE_FIGURINE"))
			if Characters.player.proficiency.has("ice_magic") && Characters.player.proficiency.has("arcane_magic"):
				Main.add_text(tr("OPEN_PACKAGE_FIGURINE_SEAL"))
				Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package_broken","grade":1}},"","",2))
				Main.add_action(Game.Action.new(tr("ACTION_REPAIR_SEAL"),self,{10:{"method":"repair_seal","grade":1},0:{"method":"repair_seal_fail","grade":1}},"wisdom","intelligence",3,10))
			else:
				Main.add_text(tr("OPEN_PACKAGE_FIGURINE_TOUCH"))
				quest.data.damaged = true
				Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
		7:
			Main.add_text(tr("OPEN_PACKAGE_GAS").format({"color":tr(["CYAN","GREENISH","BROWNISH","BLACK","GREY","PURPLE"][randi()%6])}))
			if Characters.player.proficiency.has("wind_magic"):
				if Characters.player.proficiency.has("shielding_magic") || Characters.player.proficiency.has("nature_magic"):
					Main.add_action(Game.Action.new(tr("ACTION_CAPTURE_GAS"),self,{10:{"method":"capture_gas_magic_succeed","grade":1},0:{"method":"capture_gas_magic_fail","grade":0}},"intelligence","cunning",4,10))
				else:
					Main.add_action(Game.Action.new(tr("ACTION_CAPTURE_GAS"),self,{14:{"method":"capture_gas_magic_succeed","grade":1},0:{"method":"capture_gas_magic_fail","grade":0}},"intelligence","cunning",4,14))
			else:
				Main.add_action(Game.Action.new(tr("ACTION_CAPTURE_GAS"),self,{0:{"method":"try_capture_gas","grade":0}},"agility","dexterity",4,15))
			Main.add_action(Game.Action.new(tr("ACTION_TOXIC_GAS"),self,{0:{"method":"ignore_gas","grade":1}},"","",2))
		

func open_alive_package(_actor,_action,_roll):
	var type := randi()%5
	match type:
		0,1:
			Main.add_text(tr("OPEN_PACKAGE_CAT"))
			Characters.player.damaged()
			if Characters.player.proficiency.has("unarmed"):
				Main.add_text(tr("PACKAGE_CAT_GRASP"))
				Main.add_action(Game.Action.new(tr("ACTION_FEED_CAT"),self,{0:{"method":"feed_cat","grade":1}},"","",3))
				Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
			else:
				Main.add_action(Game.Action.new(tr("ACTION_CHASE_CAT"),self,{14:{"method":"catch_cat","grade":1},0:{"method":"lost_cat","grade":0}},"agility","",5,14))
				Main.add_action(Game.Action.new(tr("ACTION_GIVE_UP"),self,{0:{"method":"ignore_cat","grade":1}},"","",2))
		2,3:
			Main.add_text(tr("OPEN_PACKAGE_SNAKES"))
			var script = preload("res://data/events/can_of_snakes.gd").new()
			script.init(self)
		4:
			Main.add_text(tr("OPEN_PACKAGE_BIRD_EGGS"))
			quest.data.damaged = true
			Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))
		

func close_package(_actor,_action,_roll):
	Main.add_text(tr("CLOSE_PACKAGE"))
	parent_script.rest_high(_actor,_action,_roll)

func close_package_broken(_actor,_action,_roll):
	Main.add_text(tr("CLOSE_PACKAGE"))
	quest.data.damaged = true
	parent_script.rest_high(_actor,_action,_roll)

func close_package_legal(_actor,_action,_roll):
	Main.add_text(tr("CLOSE_PACKAGE_LEGAL"))
	parent_script.rest_high(_actor,_action,_roll)

func close_package_fire(_actor,_action,_roll):
	Main.add_text(tr("CLOSE_PACKAGE_FIRE"))
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,_roll)

func ignore_illegal_cargo(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_IGNORE_ILLEGAL_CARGO"))
	Characters.add_morale( 5.0,"evil")
	Characters.add_morale(-5.0,"lawful")
	parent_script.rest_high(_actor,_action,_roll)

func get_rid_of_illegal_cargo(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_GET_RID_OF_ILLEGAL_CARGO"))
	Game.fail_quest(quest)
	Characters.add_morale( 5.0,"lawful")
	Characters.add_morale(-5.0,"evil")
	parent_script.rest_high(_actor,_action,_roll)

func get_rid_of_unknown_cargo(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_GET_RID_OF_ILLEGAL_CARGO"))
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,_roll)

func steal_potions(_actor,_action,_roll):
	Main.add_text(tr("STEAL_PACKAGE_MYSTERIOUS_POTIONS"))
	Items.add_items("mysterious_potion", 2+randi()%3)
	Characters.add_morale(  5.0,"evil")
	Characters.add_morale(-10.0,"lawful")
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,_roll)

func repair_seal(_actor,_action,_roll):
	Main.add_text(tr("REPAIR_PACKAGE_FIGURINE_SEAL"))
	Characters.player.drained(2)
	parent_script.rest_high(_actor,_action,_roll)

func try_capture_gas(_actor,_action,roll):
	Main.add_text(tr("PACKAGE_TRY_CAPTURE_GAS"))
	if roll<8 || randf()<0.5:
		Main.add_text(tr("PACKAGE_GAS_TOXIC"))
		Characters.player.damaged()
		Characters.player.stressed()
		Characters.player.drained()
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,roll)

func capture_gas_magic_succeed(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_CAPTURE_GAS_MAGIC")+"\n"+tr("PACKAGE_CAPTURE_GAS_MAGIC_SUCCEED"))
	Characters.player.drained(2)
	Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))

func capture_gas_magic_fail(_actor,_action,roll):
	Main.add_text(tr("PACKAGE_CAPTURE_GAS_MAGIC")+"\n"+tr("PACKAGE_CAPTURE_GAS_MAGIC_FAIL"))
	Characters.player.drained()
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,roll)

func ignore_gas(_actor,_action,roll):
	Main.add_text(tr("SIGH_GIVE_UP"))
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,roll)

func feed_cat(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_CAT_FEED"))
	Items.remove_items("supplies")
	Characters.add_morale(2.0,"shy")
	Characters.add_morale(2.0,"cheerful")
	if randf()<0.2 && !Items.has_item("cat"):
		character = Characters.characters[Characters.party[(randi()%(Characters.party.size()-1))+1]]
		Main.add_text(tr("PACKAGE_CAT_PARTY_KEEP").format({"name":character.name.first}))
		Main.add_action(Game.Action.new(tr("ACTION_KEEP_CAT"),self,{0:{"method":"keep_cat","grade":1}},"","",2))
		Main.add_action(Game.Action.new(tr("ACTION_NOT_KEEP_CAT"),self,{0:{"method":"not_keep_cat","grade":1}},"","",2))
		return
	parent_script.rest_high(_actor,_action,_roll)

func catch_cat(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_CAT_CATCH"))
	Characters.player.stressed(2)
	Main.add_action(Game.Action.new(tr("ACTION_FEED_CAT"),self,{0:{"method":"feed_cat","grade":1}},"","",3))
	Main.add_action(Game.Action.new(tr("ACTION_CLOSE_PACKAGE"),self,{0:{"method":"close_package","grade":1}},"","",2))

func lost_cat(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_CAT_LOST"))
	Characters.player.stressed()
	character = Characters.has_proficiency("unarmed")
	if character!=null && character!=Characters.player && Characters.get_proficiency_level("unarmed")>1:
		Main.add_text(tr("PACKAGE_CAT_PARTY").format({"name":character.name.first}))
		if "cheerful" in character.personality:
			Main.add_text(tr("PACKAGE_CAT_PARTY_CHEERFUL").format({"he/she":tr(Characters.HE_SHE[character.gender])}))
			if randf()<0.5 && !Items.has_item("cat"):
				Main.add_text(tr("PACKAGE_CAT_PARTY_KEEP").format({"name":character.name.first}))
				Main.add_action(Game.Action.new(tr("ACTION_KEEP_CAT"),self,{0:{"method":"keep_cat","grade":1}},"","",2))
				Main.add_action(Game.Action.new(tr("ACTION_NOT_KEEP_CAT"),self,{0:{"method":"not_keep_cat","grade":1}},"","",2))
				return
		elif "bold" in character.personality || "reckless" in character.personality:
			Main.add_text(tr("PACKAGE_CAT_PARTY_BOLD"))
		elif "curious" in character.personality:
			Main.add_text(tr("PACKAGE_CAT_PARTY_CURIOUS"))
		else:
			Main.add_text(tr("PACKAGE_CAT_PARTY_FINALLY"))
		parent_script.rest_low(_actor,_action,_roll)
	else:
		Game.fail_quest(quest)
		parent_script.rest_high(_actor,_action,_roll)

func ignore_cat(_actor,_action,_roll):
	Main.add_text(tr("SIGH_GIVE_UP")+"\n"+tr("PACKAGE_CAT_GIVE_UP"))
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,_roll)

func keep_cat(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_KEEP_CAT"))
	Items.add_items("cat")
	Game.fail_quest(quest)
	parent_script.rest_high(_actor,_action,_roll)

func not_keep_cat(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_NOT_KEEP_CAT"))
	parent_script.rest_high(_actor,_action,_roll)

func defeat_snakes(_actor,_action,_roll):
	Main.add_text(tr("PACKAGE_SNAKES_DEAD"))
	Game.fail_quest(quest)
	parent_script.rest_low(_actor,_action,_roll)

func escape_snakes(_actor,_action,_roll):
	var array := []
	for item in Characters.inventory:
		if item.type=="supplies":
			array.push_back(item)
	if array.size()>0:
		var item = array[randi()%array.size()]
		var amount := int(min(rand_range(6,10)+rand_range(0.09,1.1)*item.amount,max(item.amount-1,0)))
		item.amount -= amount
		Main.add_text(tr("CAMP_ENCOUNTER_LOST_RATIONS").format({"type":tr(item.name.to_upper()),"amount":amount}))
	parent_script.rest_low(_actor,_action,_roll)

func rest(_actor,_action,_roll):
	Main.add_text(tr("DONT_OPEN_PACKAGE"))
	parent_script.rest_high(_actor,_action,_roll)
