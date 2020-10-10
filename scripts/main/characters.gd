extends Node

const STATS = [
	"strength",
	"constitution",
	"dexterity",
	"agility",
	"intelligence",
	"wisdom",
	"cunning",
	"charisma"
]

const MAX_PROFICIENCY = 4
const PROFICIENCIES = [
	"unarmed",
	"two-hander",
	"blade",
	"knife",
	"axe",
	"mace",
	"spear",
	"staff",
	"shield",
	"light_armor",
	"heavy_armor",
	"bow",
	"crossbow",
	"sling",
	"stealth",
	"lock_picking",
	"bargaining",
	"arcane_magic",
	"fire_magic",
	"ice_magic",
	"wind_magic",
	"earth_magic",
	"light_magic",
	"nature_magic",
	"restoration_magic",
	"shielding_magic"
]

const SKIN_TYPES = {
	"default":["pale","fair","olive","tanned"],
	"bright":["pale","fair","olive"],
	"dark":["olive","tanned","green","purple"],
	"beast":["fur","scales"],
	"undead":["none","rotting"]
}
const HEAD_TYPES = {
	"default":["average"],
	"elven":["elven_ears"],
	"beast":["cat_ears","wolf_ears","horns"],
	"bearded":["bearded"],
	"undead":["skull","rotting"]
}
const HAIR_TYPES = {
	"default":["bald","short","long"]
}
const HAIR_COLOR_TYPES = {
	"default":["black","brown","blond","grey","white","red"],
	"bright":["brown","blond","grey","white"],
}
const EYES_TYPES = {
	"default":["blue","green","brown"],
	"beast":["green","yellow","purple","cyan"],
	"red":["red","orange","pink"],
}
const BODY_TYPES = {
	"default":["average","small","tall"],
	"small":["average","small"],
	"undead":["bones","rotting"]
}
const ARMS_TYPES = {
	"default":["average"],
	"beast":["claws"],
	"undead":["bones","rotting"]
}
const LEGS_TYPES = {
	"default":["average"],
	"beast":["claws","hooves"],
	"undead":["bones","rotting"]
}
const TAIL_TYPES = {
	"beast":["cat_tail","wolf_tail","lizzard_tail"],
	"none":["none"],
	"undead":["bones","rotting"]
}
const APPEARANCE_TRAITS = {
	"claws":"claws",
	"horns":"horns",
	"wings":"flying"
}

const PERSONALITIES = [
	"shy","bold","reckless","cynical","curious","cheerful"
]
const ALIGNMENTS = [
	"lawful","chaotic","evil"
]

const COLOR_BENEFICIAL = Color(0.2,0.7,0.1)
const COLOR_DETRIMENTAL = Color(0.7,0.2,0.1)
const TRAIT_COLOR = {
	"versatile":COLOR_BENEFICIAL,
	"resiliant":COLOR_BENEFICIAL,
	"startling":COLOR_DETRIMENTAL,
	"intimidating":COLOR_BENEFICIAL,
	"poison_resistance":COLOR_BENEFICIAL,
	"claws":COLOR_BENEFICIAL,
	"horns":COLOR_BENEFICIAL
}

const HE_SHE = ["HE","SHE","THEY"]
const HIS_HER = ["HIS","HER","THEIR"]
const HIM_HER = ["HIM","HER","THEM"]
const IS_ARE = ["IS","IS","ARE"]


var inventory := []
var characters := {}
var party := []
var mounts := []
var player : Character
var enemies := {}
var relations := {}
var payment := {}
var payment_delay := 0.0
var rations_consumed := 0.0


class Character:
	var name
	var gender : int
	var race : String
	var ID : String
	var stats : Dictionary
	var base_type : String
	var base_stats : Dictionary
	var min_stats : Dictionary
	var stat_points : int
	var prof_points : int
	var proficiency : Dictionary
	var min_prof : Dictionary
	var equipment : Array
	var slots := ["body","hand","hand","head","hands","feet","trinket"]
	var level := 1
	var expirience := 0
	var max_expirience : int
	var health : int
	var max_health : int
	var stamina : int
	var max_stamina : int
	var mana : int
	var max_mana : int
	var mass : float
	var shielding := 0
	var armor : int
	var taunt : int
	var appearance : Dictionary
	var traits : Array
	var personality := []
	var status : Dictionary
	var knowledge : Array
	var drop_rate := 0.0
	var drops := []
	var hired := false
	var hired_until := 0
	var payment_cost := 0.0
	var payment_currency : String
	var morale := 0.0
	var max_morale := 100.0
	var home : String
	var cls_name : String
	
	
	func _init(dict : Dictionary):
		for key in dict.keys():
			set(key, dict[key])
		base_stats = stats.duplicate()
		min_stats = stats.duplicate()
		min_prof = proficiency.duplicate()
		if typeof(name)==TYPE_DICTIONARY:
			name = Names.Name.new(name.first, name.last, name.title)
		
		calc_stats()
		calc_max_exp()
		if health==0:
			health = max_health
		if stamina==0:
			stamina = max_stamina
		if mana==0:
			mana = max_mana
	
	func calc_stats():
		mass = 0.0
		armor = 0
		stats = base_stats.duplicate(true)
		for eq in equipment:
			if eq==null:
				continue
			for s in base_stats.keys():
				if eq.has(s):
					stats[s] += eq[s]
			if eq.has("armor"):
				armor += eq.armor
			if eq.has("weight"):
				mass += eq.weight
		if "resiliant" in traits:
			armor += 1
		if proficiency.has("stealth") && proficiency["stealth"]>0:
			taunt -= 2
		calc_max_health()
	
	func calc_max_health():
		var fatigue := int(max(mass-stats.constitution,0))
		max_health = int((stats.constitution+10)*(9+level)/10.0)
		max_stamina = int(max(stats.constitution*(9+level)/10.0-fatigue,1))
		max_mana = int(max(stats.wisdom*(9+level)/10.0-fatigue,1))
		if health>max_health:
			health = max_health
		if stamina>max_stamina:
			stamina = max_stamina
		if mana>max_mana:
			mana = max_mana
	
	func calc_max_exp():
		max_expirience = int(round(33.4+33.3*level+33.3*level*level))
	
	func get_knowledge() -> Array:
		var list := knowledge.duplicate()
		for eq in equipment:
			if eq==null:
				continue
			if eq.has("knowledge"):
				list += eq.knowledge
		return list
	
	func add_exp(value):
		expirience += value
		if expirience>=max_expirience:
			level_up()
	
	func level_up():
		var gained_prof_points := 1
		if "versatile" in traits && level%5==0:
			gained_prof_points += 1
		expirience -= max_expirience
		level += 1
		prof_points += gained_prof_points
#		if level%5==0:
#			stat_points += 1
		for stat in stats.keys():
			min_stats[stat] = max(stats[stat]-1,1)
		for prof in proficiency.keys():
			min_prof[prof] = max(proficiency[prof]-1,0)
		calc_max_health()
		calc_max_exp()
		Main.add_text(tr("ACTOR_LEVEL_UP").format({"actor":get_name(),"level":str(level)}))
		if prof_points>0:
			Main.add_text(tr("ACTOR_GAINED_PROF").format({"actor":get_name(),"amount":str(gained_prof_points)}))
		increase_morale(5.0+10.0*float("curious" in personality))
	
	
	func heal(value:=1):
		health += value
		increase_morale(1)
		if health>=max_health:
			health = max_health
	
	func damaged(dam:=1):
		if shielding>0:
			if dam>shielding:
				dam -= shielding
				shielding = 0
				remove_status("magic_shield")
			else:
				dam = 0
				shielding -= dam
				return
		health -= dam
		decrease_morale(1)
		if health<=0:
			health = 0
			Main.add_text(tr("COMBAT_ACTOR_DIED").format({"actor":get_name()}))
		for st in status.values():
			if st.has_method("on_damaged"):
				st.on_damaged(dam)
	
	func stressed(dam:=1):
		stamina -= dam
		decrease_morale(1)
		if stamina<=0:
			stamina = 0
			Main.add_text(tr("COMBAT_ACTOR_EXHAUSTED").format({"actor":get_name()}))
	
	func drained(dam:=1):
		mana -= dam
		decrease_morale(1)
		if mana<=0:
			mana = 0
			Main.add_text(tr("COMBAT_ACTOR_EXHAUSTED").format({"actor":get_name()}))
	
	func decrease_morale(amount):
		if hired:
			morale -= amount
	
	func increase_morale(amount):
		if hired:
			morale += amount
			if morale>max_morale:
				morale = max_morale
	
	
	func add_status(cl,dict:={}):
		var st = cl.new(self,dict)
		st.owner = self
		if st.failed:
			return
		if status.has(st.name):
			if status[st.name].has_method("merge") && status[st.name].merge(dict):
				return
			remove_status(st.name)
		if st.has_method("on_apply"):
			st.on_apply()
		status[st.name] = st
	
	func remove_status(type):
		if !status.has(type):
			return
		var st = status[type]
		if st.has_method("on_remove"):
			st.on_remove()
		status.erase(type)
	
	func has_status(type):
		return status.has(type)
	
	func reset_status():
		for type in status.keys():
			remove_status(type)
	
	func unequip(index) -> bool:
		if equipment.size()<=index || equipment[index]==null:
			return false
		Items.add_item(equipment[index])
		equipment[index] = null
		calc_stats()
		return true
	
	func equip(index,item) -> bool:
		if equipment.size()<=index:
			equipment.resize(index+1)
		elif equipment[index]!=null:
			unequip(index)
		equipment[index] = item
		Items.remove_item(item)
		calc_stats()
		return true
	
	func inc_stat(stat) -> bool:
		if stat_points<1:
			return false
		stats[stat] += 1
		if min_stats[stat]<stats[stat]-1:
			min_stats[stat] += 1
		stat_points -= 1
		return true
	
	func dec_stat(stat) -> bool:
		if stats[stat]<=min_stats[stat]:
			return false
		stat_points += 1
		stats[stat] -= 1
		return true
	
	func inc_prof(prof) -> bool:
		var cost := 1
		if proficiency.has(prof):
			if proficiency[prof]>=MAX_PROFICIENCY:
				return false
			cost += proficiency[prof]
		if prof_points<cost:
			return false
		proficiency[prof] += 1
		if min_prof[prof]<proficiency[prof]-1:
			min_prof[prof] += 1
		prof_points -= cost
		return true
	
	func dec_prof(prof) -> bool:
		if !proficiency.has(prof) || proficiency[prof]<=min_prof[prof] || proficiency[prof]<=0:
			return false
		prof_points += proficiency[prof]
		proficiency[prof] -= 1
		if proficiency[prof]<=0:
			proficiency.erase(prof)
		return true
	
	func get_name():
		if typeof(name)==TYPE_STRING:
			return name
		else:
			return name.get_name()
	
	func to_dict() -> Dictionary:
		var dict := {
			"name":name.to_dict(),"gender":gender,"race":race,"ID":ID,
			"stats":base_stats,"min_stats":min_stats,"appearance":appearance,
			"stat_points":stat_points,"prof_points":prof_points,
			"proficiency":proficiency,"min_prof":min_prof,"equipment":equipment,
			"slots":slots,"level":level,"expirience":expirience,"health":health,
			"stamina":stamina,"traits":traits,"personality":personality,
			"armor":armor,"taunt":taunt,
			"hired":hired,"hired_until":hired_until,"morale":morale,"home":home,
			"payment_cost":payment_cost,"payment_currency":payment_currency,
			"status":status,"knowledge":knowledge,"cls_name":cls_name}
		return dict


func payout_party() -> bool:
	for currency in payment.keys():
		if Items.get_item_amount(currency)<payment[currency]:
			return false
	for currency in payment.keys():
		Items.remove_items(currency, int(payment[currency]))
		payment[currency] -= int(payment[currency])
	for ID in party:
		if characters[ID].hired:
			characters[ID].increase_morale(10.0*payment_delay/24.0)
	payment_delay = 0.0
	return true


func get_stat_points_left(stats,stat_offset,extra_points:=0) -> int:
	var left := extra_points
	for stat in STATS:
		left += Menu.STAT_DEFAULT-stats[stat]
		if stat_offset.has(stat):
			left += stat_offset[stat]
	return left

func distribute_stat_points(stat_offset : Dictionary, main_stats : Array, extra_points:=-5) -> Dictionary:
	var stats := {}
	for stat in STATS:
		var offset := 0
		if stat_offset.has(stat):
			offset += stat_offset[stat]
		if stat in main_stats:
			# Main stats should be higher than average.
			stats[stat] = Menu.STAT_DEFAULT+2+offset+randi()%int(max(Menu.STAT_MAX-Menu.STAT_DEFAULT-2, 1))
		else:
			stats[stat] = Menu.STAT_MIN+offset+randi()%int(max(Menu.STAT_MAX-Menu.STAT_MIN, 1))
	while get_stat_points_left(stats,stat_offset,extra_points)!=0:
		var points_left := get_stat_points_left(stats,stat_offset,extra_points)
		for _i in range(max(-points_left,0)):
			var s = stats.keys()[randi()%stats.size()]
			var offset := 0
			if stat_offset.has(s):
				offset += stat_offset[s]
			if !(s in main_stats):
				stats[s] = max(stats[s]-1, Menu.STAT_MIN+offset)
		for _i in range(max(points_left,0)):
			var s = stats.keys()[randi()%stats.size()]
			var offset := 0
			if stat_offset.has(s):
				offset += stat_offset[s]
			stats[s] = min(stats[s]+1, Menu.STAT_MAX+offset)
	return stats

func distribute_prof_points(character : Character):
	for _i in range(100):
		var valid := []
		for k in character.proficiency.keys():
			if character.proficiency[k]<MAX_PROFICIENCY:
				valid.push_back(k)
		if valid.size()==0:
			valid += PROFICIENCIES
		character.inc_prof(valid[randi()%valid.size()])
		if character.prof_points<=0:
			break

func add_character(name,level,expirience,gender,race,_stats,_equip,prof,apr,_traits,knowledge,stat_points,prof_points):
	var character
	var ID = name
	var num := 1
	var appearance = apr.duplicate(true)
	var proficiency = prof.duplicate()
	var stats = _stats.duplicate()
	var traits = _traits.duplicate()
	var equipment := []
	var equip := []
	equip.resize(_equip.size())
	for i in range(_equip.size()):
		equip[i] = Items.create_item(_equip[i],true)
	for s in stats.keys():
		if typeof(stats[s])==TYPE_ARRAY:
			stats[s] = int(round(rand_range(stats[s][0],stats[s][1])))
	for s in proficiency.keys():
		if typeof(proficiency[s])==TYPE_ARRAY:
			proficiency[s] = int(round(rand_range(proficiency[s][0],proficiency[s][1])))
	for s in appearance.keys():
		if typeof(appearance[s])==TYPE_ARRAY:
			appearance[s] = appearance[s][randi()%appearance[s].size()]
		if get(s.to_upper()+"_TYPES").has(appearance[s]):
			var array = get(s.to_upper()+"_TYPES")[appearance[s]]
			appearance[s] = array[randi()%array.size()]
		for k in APPEARANCE_TRAITS.keys():
			if appearance[s]==k && !(APPEARANCE_TRAITS[k] in traits):
				traits.push_back(APPEARANCE_TRAITS[k])
	character = Character.new({"name":name,"level":level,"expirience":expirience,"gender":gender,"race":race,"stats":stats,"equipment":equipment,"proficiency":proficiency,"appearance":appearance,"traits":traits,"knowledge":knowledge.duplicate(),"stat_points":stat_points,"prof_points":prof_points})
	equipment.resize(character.slots.size())
	for i in range(character.slots.size()):
		for j in range(equip.size()-1,-1,-1):
			if equip[j].slot==character.slots[i]:
				character.equip(i,equip[j])
				equip.remove(j)
				break
	name = name.get_full().to_lower().replace(" ","_")
	while characters.has(name+str(num)):
		num += 1
	ID = name+str(num)
	characters[ID] = character
	character.ID = ID
	return character

func get_best_character(group, primary, secondary="", proficiencies=[]) -> Character:
	if primary=="" && secondary=="":
		return player
	
	var best := player
	var value := 0
	for c in group:
		var valid := true
		if typeof(c)==TYPE_STRING:
			c = characters[c]
		for p in proficiencies:
			if !c.proficiency.has(p):
				valid = false
				break
		if !valid:
			continue
		
		var v := 0
		if secondary=="":
			v = c.stats[primary]
		else:
			v = (2.0*c.stats[primary]+c.stats[secondary])/3.0
		if v>value:
			best = c
			value = v
	return best

func get_worst_character(group, primary, secondary="", proficiencies=[]) -> Character:
	if primary=="" && secondary=="":
		return player
	
	var best := player
	var value := 999
	for c in group:
		var valid := true
		if typeof(c)==TYPE_STRING:
			c = characters[c]
		for p in proficiencies:
			if !c.proficiency.has(p):
				valid = false
				break
		if !valid:
			continue
		
		var v := 0
		if secondary=="":
			v = c.stats[primary]
		else:
			v = (2.0*c.stats[primary]+c.stats[secondary])/3.0
		if v<value:
			best = c
			value = v
	return best

func get_total_mass() -> float:
	var mass := 0.0
	for item in inventory:
		if item.has("weight"):
			mass += item.weight*item.amount
	for k in party:
		var c = characters[k]
		for item in c.equipment:
			if item==null:
				continue
			if item.has("weight"):
				mass += item.weight
	return mass

func get_capacity() -> float:
	var capacity := 0.0
	var total_strength := 0
	for mount in mounts:
		if Items.get_item_amount(mount.fuel)>=mount.fuel_consumption:
			capacity += mount.cargo_space
	for k in party:
		var c = characters[k]
		total_strength += c.stats.strength
	capacity += 2*total_strength
	return capacity

func get_travel_speed() -> float:
	var speed := 0.0
	var multiplier := 1.0
	var total_mass := get_total_mass()
	var mass_capacity := get_capacity()
	if mounts.size()>0:
		for mount in mounts:
			if Items.get_item_amount(mount.fuel)>=mount.fuel_consumption:
				speed += mount.speed
				mass_capacity += mount.cargo_space
				mount.active = true
			else:
				mount.active = false
		speed /= mounts.size()
	else:
		speed = 10.0
	multiplier *= min(mass_capacity/total_mass, 1.0)
	speed = max(speed*multiplier, 2.0)
	return speed


func create_enemy(type, level:=1, ID:="") -> Character:
	var enemy : Character
	var gender = int(2.1*randf())
	var dict = enemies[type]
	var appearance = dict.appearance.duplicate(true)
	var traits = dict.traits.duplicate(true)
	var stats := {}
	var prof := {}
	var equip := []
	var knowledge := []
	var name := tr(dict.name.to_upper())
	var expirience := 0
	if gender==1 && dict.has("no_female") && dict.no_female:
		if randf()<0.1:
			gender = 2
		else:
			gender = 0
	elif gender==0 && dict.has("no_male") && dict.no_male:
		if randf()<0.1:
			gender = 2
		else:
			gender = 1
	if ID!="":
		name += " "+ID
	for s in dict.stats.keys():
		if typeof(dict.stats[s])==TYPE_ARRAY:
			stats[s] = int(round(rand_range(dict.stats[s][0], dict.stats[s][1])))
		else:
			stats[s] = dict.stats[s]
	for s in dict.proficiency.keys():
		if typeof(dict.proficiency[s])==TYPE_ARRAY:
			prof[s] = int(round(rand_range(dict.proficiency[s][0], dict.proficiency[s][1])))
		else:
			prof[s] = dict.proficiency[s]
	equip.resize(dict.equipment.size())
	for i in range(equip.size()):
		if typeof(dict.equipment[i])==TYPE_DICTIONARY:
			equip[i] = dict.equipment[i]
		else:
			equip[i] = Items.create_item(dict.equipment[i])
	for s in appearance.keys():
		if typeof(appearance[s])==TYPE_ARRAY:
			appearance[s] = appearance[s][randi()%appearance[s].size()]
		for k in APPEARANCE_TRAITS.keys():
			if appearance[s]==k && !(APPEARANCE_TRAITS[k] in traits):
				traits.push_back(APPEARANCE_TRAITS[k])
	if dict.has("knowledge"):
		knowledge = dict.knowledge.duplicate(true)
	if dict.has("expirience"):
		expirience = int(dict.expirience*sqrt(level))
	else:
		expirience = int(2*sqrt(level))
	enemy = Character.new({"name":name,"level":level,"expirience":expirience,"gender":gender,"race":dict.race,"stats":stats,"equipment":equip,"proficiency":prof,"appearance":appearance,"traits":traits,"knowledge":knowledge})
	enemy.base_type = type
	if dict.has("drop_rate"):
		enemy.drop_rate = dict.drop_rate
	if dict.has("drops"):
		enemy.drops = dict.drops
	return enemy


func _save(file : File) -> int:
	# Add informations to save file.
	var player_ID : String
	var list_characters := {}
	var list_inventory := {}
	for k in characters.keys():
		list_characters[k] = characters[k].to_dict()
		if characters[k]==player:
			player_ID = k
	for i in range(inventory.size()):
		list_inventory[i] = inventory[i]
	
	file.store_line(JSON.print({"party":party,"mounts":mounts,"player":player_ID,"relations":relations,"payment":payment,"payment_delay":payment_delay}))
	file.store_line(JSON.print(list_characters))
	file.store_line(JSON.print(list_inventory))
	return OK

func _load(file : File) -> int:
	# Load from given save file.
	var player_ID
	var currentline = JSON.parse(file.get_line()).result
	characters.clear()
	inventory.clear()
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	party = currentline.party
	mounts = currentline.mounts
	player_ID = currentline.player
	relations = currentline.relations
	payment = currentline.payment
	payment_delay = currentline.payment_delay
	
	currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	for k in currentline.keys():
		characters[k] = Character.new(currentline[k])
	if !characters.has(player_ID):
		return FAILED
	player = characters[player_ID]
	
	currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	inventory.resize(currentline.size())
	for i in range(currentline.size()):
		inventory[i] = currentline.values()[i]
	
	return OK

func load_enemy_data(path):
	var dir := Directory.new()
	var file := File.new()
	var filename : String
	var error := dir.change_dir(path)
	if error!=OK:
		return
	error = dir.list_dir_begin(true)
	if error!=OK:
		return
	
	# Load all data files in the items directory.
	filename = dir.get_next()
	while filename!="":
		# open file
		error = file.open(path+"/"+filename, File.READ)
		if error!=OK:
			print("Can't open file "+filename+"!")
			filename = dir.get_next()
			continue
		else:
			print("Loading items "+filename+".")
		
		while !file.eof_reached():
			# Gather all lines that are belonging to the same item.
			var currentline = file.get_line()
			var num_brackets = 0
			for s in currentline:
				num_brackets += int(s=="{")-int(s=="}")
			while num_brackets>0:
				var new = file.get_line()
				for s in new:
					num_brackets += int(s=="{")-int(s=="}")
				currentline += "\n"+new
				if file.eof_reached():
					break
			if currentline.length()<1:
				continue
			
			# parse data
			var raw = currentline
			currentline = JSON.parse(currentline)
			if currentline.error!=OK:
				printt("Error parsing "+filename+".", raw)
				continue
			currentline = currentline.get_result()
			if !currentline.has("name"):
				printt("Error parsing "+filename+" (missing name).")
				continue
			
			enemies[currentline.name] = currentline
			
		filename = dir.get_next()

func _ready():
	load_enemy_data("res://data/enemies")
	load_enemy_data("user://data/enemies")
