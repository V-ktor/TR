extends Node

var character_ID := ""
var character_type := ""
var currency := "silver_coins"
var price_scale := 2.0
var known := false


func goto(_actor,_action,_roll):
	var character : Characters.Character
	var chars := []
	var c : Map.Location = Map.cities[Game.location]
	Main.add_text("\n"+tr("YOU_ENTER_FACILITY").format({"location":c.name,"facility":tr("BAR")}))
	Map.time += 60*2
	
	if !Game.vars.has("last_bar_visit") || Map.time-Game.get_var("last_bar_visit")>60*60:
		if randf()<0.2:
			for ID in Characters.characters.keys():
				if !(ID in Characters.party):
					chars.push_back(Characters.characters[ID])
		if chars.size()>0:
			character = chars[randi()%chars.size()]
			character.hired_until = Map.time+int(rand_range(5.0,10.0)*24*60*60)
			character.morale = (character.morale+60.0)/2.0
			known = true
		else:
			character = create_mercenary()
		encounter_init(character)
		Game.set_var("last_bar_visit", Map.time)
	else:
		Main.add_text(tr("NOTHING_INTERESTING"))
	
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func create_mercenary() -> Characters.Character:
	var actor := Characters.create_npc()
	actor.payment_currency = currency
	actor.payment_cost = int(rand_range(7,9)+actor.level-2*int("young" in actor.personality)-int("old" in actor.personality))
	actor.morale = 50.0+10.0*float("young" in actor.personality)
	actor.hired = true
	actor.hired_until = Map.time+int(rand_range(5.0,7.0)*24*60*60)
	character_ID = actor.ID
	return actor

func encounter_init(actor:Characters.Character):
	var dict:= Characters.create_description(actor)
	character_type = dict.character_type
	Main.add_text(tr("BAR_ENCOUNTER_INIT").format({"adjective":dict.adjective,"person":dict.character_type,"action":dict.action}))
	if known:
		Main.add_text(tr("BAR_ENCOUNTER_KNOWN").format({"name":actor.get_name()}))
	Main.add_action(Game.Action.new(tr("APPROACH_CHARACTER").format({"name":character_type}),self,{8:{"method":"approach_success","grade":1},0:{"method":"approach_failed","grade":0}},"charisma","",4,8))
	



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
	Main.add_text(tr("APPROACH_FAILED"+str(1+(randi()%3))).format({"name":character_type,"he/she":tr(Characters.HE_SHE[gender]),"is/are":tr(Characters.IS_ARE[gender])}))
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
	elif character.appearance.has("tail") && character.appearance.tail!="none":
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
	var date := OS.get_datetime_from_unix_time(character.hired_until)
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
	Journal.add_entry(character_ID, character.get_name(), ["persons","companions"], "", "", Map.time)
	Journal.add_entry("hired_"+character_ID, tr("HIRED")+" "+character.get_name(), ["companions"], tr("HIRED_UNTIL").format({"date":tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})}), "", Map.time,{"character":{"name":character.get_name(),"target":character_ID}})
	character_ID = ""
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))


func leave(_actor,_action,_roll):
	if character_ID!="":
		Characters.characters.erase(character_ID)
	Game.enter_location(Game.location)
	Map.time += 60*2
