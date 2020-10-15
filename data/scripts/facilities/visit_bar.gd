extends Node

var character_ID := ""
var character_type := ""
var currency := "silver_coins"
var price_scale := 2.0
var known := false


func goto(_actor,_action,_roll):
	var character : Characters.Character
	var chars := []
	var c = Map.cities[Game.location]
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("BAR")}))
	Map.time += 60*2
	
	if randf()<0.2:
		for ID in Characters.characters.keys():
			if !(ID in Characters.party):
				chars.push_back(Characters.characters[ID])
	if chars.size()>0:
		character = chars[randi()%chars.size()]
		known = true
	else:
		character = create_mercenary()
	encounter_init(character)
	
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func create_mercenary() -> Characters.Character:
	var race
	var cl
	var actor
	var name
	var city = Map.cities[Game.location]
	var level := int(max(Characters.player.level*rand_range(0.9,1.1)+rand_range(-2.0,2.0), 1))
	var gender := int(2.1*randf())
	var stat_offset := {}
	var main_stats := []
	var equip := []
	var proficiency := {}
	var appearance := {}
	var personality := []
	var knowledge := []
	var stats := {}
	
	if randf()<0.5:
		race = Menu.races[Map.cities[Game.location].faction]
	else:
		race = Menu.races.values()[randi()%Menu.races.size()]
	if race.has("stats"):
		stat_offset = race.stats
	if race.has("proficiency"):
		for k in race.proficiency.keys():
			proficiency[k] = race.proficiency[k]
	if race.has("appearance"):
		appearance = race.appearance.duplicate(true)
	if gender==1 && race.has("no_female") && race.no_female:
		gender = 0
	if gender==0 && race.has("no_male") && race.no_male:
		gender = 1
	cl = Menu.classes.values()[randi()%Menu.classes.size()]
	if cl.has("main_stats"):
		main_stats = cl.main_stats
	if cl.has("equipment"):
		equip = cl.equipment
	if cl.has("proficiency"):
		for k in cl.proficiency.keys():
			if proficiency.has(k):
				proficiency[k] += cl.proficiency[k]
			else:
				proficiency[k] = cl.proficiency[k]
	name = Names.get_random_name(gender,race.name)
	stats = Characters.distribute_stat_points(stat_offset, main_stats, 0)
	if randf()<0.5:
		if randf()<0.5:
			personality.push_back("young")
			level = int(max(level-2,1))
			stats.constitution += 1
			stats.charisma += 1
			stats.wisdom -= 1
		else:
			personality.push_back("old")
			level += 2
			stats.constitution -= 2
			stats.wisdom += 1
	
	actor = Characters.add_character(name, level, 0, gender, race.name, stats, equip, proficiency, appearance, [], knowledge, 0, int(max(level-1-int("young" in personality)+int("old" in personality), 0)))
	Characters.distribute_prof_points(actor)
	actor.base_type = cl.name
	personality.push_back(Characters.PERSONALITIES[randi()%Characters.PERSONALITIES.size()])
	personality.push_back(Characters.ALIGNMENTS[randi()%Characters.ALIGNMENTS.size()])
	actor.personality = personality
	actor.payment_currency = currency
	actor.payment_cost = int(rand_range(7,9)+level-2*int("young" in personality)-int("old" in personality))
	actor.morale = 50.0+10.0*float("young" in personality)
	actor.hired = true
	actor.hired_until = Map.time+int(rand_range(5.0,7.0)*24*60*60)
	if city.faction==actor.race && ("young" in personality || !("old" in personality) || randf()<0.5):
		actor.home = Game.location
	else:
		var cities := Map.get_faction_cities(actor.race)
		if cities.size()==0:
			actor.home = Map.cities.keys()[randi()%Map.cities.size()]
		else:
			actor.home = cities[randi()%cities.size()]
	character_ID = actor.ID
	return actor

func encounter_init(actor:Characters.Character):
	var adjective := tr("UNREMARKABLE")
	var action := tr("SITTING_AT_THE_COUNTER")
	character_type = tr(actor.race.to_upper())
	
	if actor.stats.constitution>=15 && (!actor.appearance.has("body") || actor.appearance.body=="tall"):
		adjective = tr("TOWERING")
	elif actor.stats.strength>=15:
		adjective = tr("MUSCULAR")
	elif actor.appearance.has("skin") && actor.appearance.skin in ["pale","tanned","green","purple"]:
		adjective = tr(actor.appearance.skin.to_upper())
	elif actor.appearance.has("hair") && actor.appearance.hair in ["bald"]:
		adjective = tr(actor.appearance.hair.to_upper())
	elif actor.appearance.has("hair_color") && actor.appearance.hair_color in ["blond"]:
		adjective = tr(actor.appearance.hair_color.to_upper())
	elif actor.stats.constitution<10 && actor.appearance.has("body") && actor.appearance.body=="small":
		adjective = tr("SMALL")
	elif actor.appearance.has("hair_color") && actor.appearance.hair_color in ["brown","white","red"]:
		adjective = tr("HAIRED").format({"color":tr(actor.appearance.hair_color.to_upper())})
	elif actor.appearance.has("skin") && actor.appearance.skin in ["none","rotting"]:
		adjective = tr("UNDEAD")
	elif actor.personality.size()>0 && !("young" in actor.personality) && !("old" in actor.personality):
		adjective = tr(actor.personality[randi()%actor.personality.size()].to_upper())
	
	if (actor.race=="human" || actor.race=="elf") && actor.gender==0:
		character_type = tr("MAN")
	elif (actor.race=="human" || actor.race=="elf") && actor.gender==1:
		character_type = tr("GIRL")
	elif (actor.race=="human" || actor.race=="elf") && actor.gender==2:
		character_type = tr("PERSON")
	elif actor.base_type!="":
		character_type = tr(actor.race.to_upper())+" "+tr(actor.base_type.to_upper())
		if adjective==character_type:
			adjective = tr("UNREMARKABLE")
	if "young" in actor.personality:
		character_type = tr("YOUNG")+" "+character_type
	if "old" in actor.personality:
		if (actor.race=="human" || actor.race=="elf") && actor.gender==1:
			character_type = tr("WOMAN")
		else:
			character_type = tr("OLD")+" "+character_type
	
	if has_heavy_armor(actor):
		action = tr("CLAD_IN_HEAVY_ARMOR")
	elif actor.stats.cunning>=15:
		action = tr("STANDING_IN_A_CORNER")
	elif actor.stats.intelligence>=15 || actor.stats.wisdom>=15:
		action = tr("READING_A_BOOK")
	elif "shy" in actor.personality:
		action = tr("SITTING_IN_A_CORNER")
	elif actor.appearance.has("head") && actor.appearance.head in ["elven_ears","cat_ears","wolf_ears","horns"]:
		action = tr("WITH_SOMETHING").format({"name":tr(actor.appearance.head.to_upper())})
	elif actor.appearance.has("skin") && actor.appearance.skin in ["fur","scales"]:
		action = tr("WITH_SOMETHING").format({"name":tr(actor.appearance.skin.to_upper())})
	elif actor.appearance.has("head") && actor.appearance.head=="skull":
		action = tr("WITH_SKULL_AS_HEAD")
	elif "claws" in actor.traits:
		action = tr("WITH_SOMETHING").format({"name":tr("CLAWS")})
	elif "horns" in actor.traits:
		action = tr("WITH_SOMETHING").format({"name":tr("HORNS")})
	elif actor.appearance.has("legs") && actor.appearance.legs=="hooves":
		action = tr("WITH_SOMETHING").format({"name":tr("HOOVES")})
	elif actor.appearance.has("tail") && actor.appearance.tail in ["cat_tail","wolf_tail","lizzard_tail"]:
		action = tr("WITH_SOMETHING").format({"name":tr(actor.appearance.tail.to_upper())})
	
	Main.add_text(tr("BAR_ENCOUNTER_INIT").format({"adjective":adjective,"person":character_type,"action":action}))
	if known:
		Main.add_text(tr("BAR_ENCOUNTER_KNOWN").format({"name":actor.get_name()}))
	Main.add_action(Game.Action.new(tr("APPROACH_CHARACTER").format({"name":character_type}),self,{8:{"method":"approach_success","grade":1},0:{"method":"approach_failed","grade":0}},"charisma","",4,8))
	


func has_heavy_armor(actor) -> bool:
	for equipment in actor.equipment:
		if equipment==null:
			continue
		if equipment.has("proficiency") && equipment.proficiency=="heavy_armor":
			return true
	return false


func approach_success(_actor,_action,_roll):
	var character : Characters.Character = Characters.characters[character_ID]
	var gender : int = Characters.characters[character_ID].gender
	if character.hired && character.base_type!="":
		if known:
			Main.add_text(tr("APPROACH_MERCENARY_KNOWN").format({"name":character.get_name()}))
			if "cynical" in character.personality:
				Main.add_text(tr("APPROACH_MERCENARY_NOT_AGAIN"))
			elif "cheerful" in character.personality:
				Main.add_text(tr("APPROACH_MERCENARY_MISSED_YOU").format({"name":Characters.player.get_name()}))
			elif "bold" in character.personality || "reckless" in character.personality:
				Main.add_text(tr("APPROACH_MERCENARY_FINALLY"))
			else:
				Main.add_text(tr("APPROACH_MERCENARY_HAVE_JOB").format({"name":Characters.player.get_name()}))
		else:
			Main.add_text(tr("APPROACH_MERCENARY").format({"name":character_type,"he/she":tr(Characters.HE_SHE[gender]),"type":tr(character.base_type.to_upper())}))
			if "shy" in character.personality:
				Main.add_text(tr("APPROACH_MERCENARY_YES"))
			elif "cheerful" in character.personality or "curious" in character.personality:
				Main.add_text(tr("APPROACH_MERCENARY_HELP"))
			else:
				Main.add_text(tr("APPROACH_MERCENARY_SERVICE"))
			Main.add_action(Game.Action.new(tr("ASK_NAME").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_for_name","grade":1}},"charisma","",2))
		Main.add_action(Game.Action.new(tr("ASK_JOB"),self,{0:{"method":"ask_job","grade":1}},"charisma","",2))
		Main.add_action(Game.Action.new(tr("ASK_WHY_ACCOMPANY").format({"he/she":tr(Characters.HE_SHE[gender])}),self,{0:{"method":"ask_why","grade":1}},"charisma","",2))
		Main.add_action(Game.Action.new(tr("ASK_PRICE_SERVICE").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_price","grade":1}},"charisma","",2))
	else:
		Main.add_text(tr("APPROACH_SUCCESS").format({"name":character_type,"he/she":tr(Characters.HE_SHE[gender])}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func approach_failed(_actor,_action,_roll):
	var gender = Characters.characters[character_ID].gender
	Main.add_text(tr("APPROACH_FAILED").format({"name":character_type,"he/she":tr(Characters.HE_SHE[gender]),"is/are":tr(Characters.IS_ARE[gender])}))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func ask_for_name(_actor,_action,_roll):
	var node
	var character : Characters.Character = Characters.characters[character_ID]
	var gender : int = Characters.characters[character_ID].gender
	var price := int(price_scale*character.payment_cost)
	Main.add_text(tr("CHARACTER_INFO").format({"name":character.name.get_full(),"he/she":tr(Characters.HE_SHE[gender]),"him/her":tr(Characters.HIM_HER[gender])}))
	if character.appearance.has("skin") && character.appearance.skin=="rotting":
		Main.add_text(tr("MERCENARY_ROTTEN_FLESH").format({"his/her":tr(Characters.HIS_HER[gender])}))
	elif character.appearance.has("skin") && character.appearance.skin=="skull":
		Main.add_text(tr("MERCENARY_SKULL_FACE").format({"his/her":tr(Characters.HIS_HER[gender])}))
	elif character.appearance.has("skin") && character.appearance.skin=="scales" && character.appearance.has("hair_color") && character.appearance.hair_color in ["brown","red","grey"]:
		Main.add_text(tr("MERCENARY_SCALES_SHIMMER").format({"his/her":tr(Characters.HIS_HER[gender]),"color":tr(character.appearance.hair_color.to_upper())}))
	elif character.appearance.has("tail"):
		Main.add_text(tr("MERCENARY_WAGS_TAIL").format({"he/she":tr(Characters.HE_SHE[gender]),"his/her":tr(Characters.HIS_HER[gender]),"tail":tr(character.appearance.tail.to_upper())}))
	elif character.appearance.has("hair") && character.appearance.hair=="long":
		Main.add_text(tr("MERCENARY_PUSH_HAIR").format({"he/she":tr(Characters.HE_SHE[gender]),"his/her":tr(Characters.HIS_HER[gender]),"color":tr(character.appearance.hair_color.to_upper())}))
	elif character.appearance.has("hair_color") && character.appearance.hair_color=="black" && character.appearance.has("skin") && character.appearance.skin=="pale":
		Main.add_text(tr("MERCENARY_CONTRAST").format({"his/her":tr(Characters.HIS_HER[gender]),"color":tr(character.appearance.hair_color.to_upper()),"skin":tr(character.appearance.skin.to_upper())}))
	elif character.appearance.has("hair_color") && character.appearance.hair_color in ["blond","white"] && character.appearance.has("skin") && character.appearance.skin=="tanned":
		Main.add_text(tr("MERCENARY_CONTRAST").format({"his/her":tr(Characters.HIS_HER[gender]),"color":tr(character.appearance.hair_color.to_upper()),"skin":tr(character.appearance.skin.to_upper())}))
	elif character.appearance.has("hair_color") && character.appearance.hair_color=="blond" && character.appearance.has("skin") && character.appearance.skin=="purple":
		Main.add_text(tr("MERCENARY_CONTRAST").format({"his/her":tr(Characters.HIS_HER[gender]),"color":tr(character.appearance.hair_color.to_upper()),"skin":tr(character.appearance.skin.to_upper())}))
	elif character.appearance.has("head") && character.appearance.head in ["elven_ears","cat_ears","wolf_ears"]:
		Main.add_text(tr("MERCENARY_EARS_TWITCH").format({"his/her":tr(Characters.HIS_HER[gender])}))
	elif character.appearance.has("head") && character.appearance.head=="bearded":
		Main.add_text(tr("MERCENARY_STROKES_BEARD").format({"he/she":tr(Characters.HE_SHE[gender]),"his/her":tr(Characters.HIS_HER[gender])}))
	if !known:
		Main.add_action(Game.Action.new(tr("ASK_JOB"),self,{0:{"method":"ask_job","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_WHY_ACCOMPANY").format({"he/she":tr(Characters.HE_SHE[gender])}),self,{0:{"method":"ask_why","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_PRICE_SERVICE").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_price","grade":1}},"charisma","",2))
	node = Main.add_action(Game.Action.new(tr("HIRE_MERCENARY").format({"name":character_type}),self,{4+4*int(!known):{"method":"hire","grade":1},0:{"method":"fail_hire","grade":0}},"charisma","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	if Items.get_item_amount(currency)<price:
		node.get_node("Button").disabled = true

func ask_job(_actor,_action,_roll):
	var node
	var character : Characters.Character = Characters.characters[character_ID]
	var gender : int = Characters.characters[character_ID].gender
	var price := int(price_scale*character.payment_cost)
# warning-ignore:integer_division
	Main.add_text(tr("CHARACTER_JOB").format({"he/she":tr(Characters.HE_SHE[gender]),"grade":tr("PROF_LEVEL"+str(clamp(int(1+character.level/5)+int("bold" in character.personality)-int("shy" in character.personality),1,4))),"class":tr(character.base_type.to_upper())}))
	if "shy" in character.personality || "curious" in character.personality:
		Main.add_text(tr("MERCENARY_NEED_HELP"))
	elif "bold" in character.personality || "reckless" in character.personality:
		Main.add_text(tr("MERCENARY_NO_BETTER"))
	else:
		Main.add_text(tr("MERCENARY_FOR_HIRE"))
	if !known:
		Main.add_action(Game.Action.new(tr("ASK_NAME").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_for_name","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_WHY_ACCOMPANY").format({"he/she":tr(Characters.HE_SHE[gender])}),self,{0:{"method":"ask_why","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_PRICE_SERVICE").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_price","grade":1}},"charisma","",2))
	node = Main.add_action(Game.Action.new(tr("HIRE_MERCENARY").format({"name":character_type}),self,{4+4*int(!known):{"method":"hire","grade":1},0:{"method":"fail_hire","grade":0}},"charisma","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	if Items.get_item_amount(currency)<price:
		node.get_node("Button").disabled = true

func ask_why(_actor,_action,_roll):
	var node
	var character : Characters.Character = Characters.characters[character_ID]
	var gender : int = Characters.characters[character_ID].gender
	var price := int(price_scale*character.payment_cost)
	if "old" in character.personality:
		if "curious" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_TRAVEL"))
		elif "reckless" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_DECREPITUDE"))
		elif "cynical" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_GUIDANCE"))
		else:
			Main.add_text(tr("ACCOMPANY_REASON_OLD_TRAVELER"))
	else:
		if "curious" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_CURIOUS"))
		elif "reckless" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_ADVENTURE"))
		elif "cynical" in character.personality:
			Main.add_text(tr("ACCOMPANY_REASON_MONEY"))
		else:
			Main.add_text(tr("ACCOMPANY_REASON_STRONG"))
	if !known:
		Main.add_action(Game.Action.new(tr("ASK_NAME").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_for_name","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_JOB"),self,{0:{"method":"ask_job","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_PRICE_SERVICE").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_price","grade":1}},"charisma","",2))
	node = Main.add_action(Game.Action.new(tr("HIRE_MERCENARY").format({"name":character_type}),self,{4+4*int(!known):{"method":"hire","grade":1},0:{"method":"fail_hire","grade":0}},"charisma","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	if Items.get_item_amount(currency)<price:
		node.get_node("Button").disabled = true

func ask_price(_actor,_action,_roll):
	var node
	var character : Characters.Character = Characters.characters[character_ID]
	var gender : int = Characters.characters[character_ID].gender
	var price := int(price_scale*character.payment_cost)
	Main.add_text(tr("MERCENARY_PRICE").format({"amount":price,"rate":character.payment_cost,"currency":tr(character.payment_currency.to_upper())}))
	if !known:
		Main.add_action(Game.Action.new(tr("ASK_NAME").format({"his/her":tr(Characters.HIS_HER[gender])}),self,{0:{"method":"ask_for_name","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_JOB"),self,{0:{"method":"ask_job","grade":1}},"charisma","",2))
	Main.add_action(Game.Action.new(tr("ASK_WHY_ACCOMPANY").format({"he/she":tr(Characters.HE_SHE[gender])}),self,{0:{"method":"ask_why","grade":1}},"charisma","",2))
	node = Main.add_action(Game.Action.new(tr("HIRE_MERCENARY").format({"name":character_type}),self,{4+4*int(!known):{"method":"hire","grade":1},0:{"method":"fail_hire","grade":0}},"charisma","",4))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	if Items.get_item_amount(currency)<price:
		node.get_node("Button").disabled = true

func fail_hire(_actor,_action,_roll):
	var character : Characters.Character = Characters.characters[character_ID]
	if "reckless" in character.personality:
		Main.add_text(tr("MERCENARY_FAIL_HIRE_EXP"))
	elif "shy" in character.personality || "curious" in character.personality:
		Main.add_text(tr("MERCENARY_FAIL_HIRE_DANGEROUS"))
	elif "cynical" in character.personality:
		Main.add_text(tr("MERCENARY_FAIL_HIRE_PAYMENT"))
	else:
		Main.add_text(tr("MERCENARY_FAIL_HIRE"))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func hire(_actor,_action,_roll):
	var character : Characters.Character = Characters.characters[character_ID]
	var price := int(price_scale*character.payment_cost)
	Main.add_text(tr("MERCENARY_HIRE").format({"name":character_type}))
	if "bold" in character.personality || "curious" in character.personality:
		Main.add_text(tr("MERCENARY_HIRE_JOURNEY"))
	elif "cynical" in character.personality:
		Main.add_text(tr("MERCENARY_HIRE_NOTHING_STUPID"))
	elif "cheerful" in character.personality:
		Main.add_text(tr("MERCENARY_HIRE_GLAD"))
	else:
		Main.add_text(tr("MERCENARY_HIRE_READY"))
	Items.remove_items(currency, price)
	Characters.party.push_back(character_ID)
	Main.update_party()
	character_ID = ""
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))


func leave(_actor,_action,_roll):
	if character_ID!="":
		Characters.characters.erase(character_ID)
	Game.enter_location(Game.location)
	Map.time += 60*2
