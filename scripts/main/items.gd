extends Node

const EQUIPMENT_STATS = ["min_dam","max_dam","armor","block"]
const GRADE_COLOR = [
	Color(0.6,0.6,0.6),
	Color(1.0,1.0,1.0),
	Color(0.5,1.0,0.5),
	Color(0.5,0.5,1.0),
	Color(1.0,0.5,1.0),
	Color(1.0,1.0,0.5)]
const GRADE_NAMES = ["GARBAGE","NORMAL","RARE","EXCEPTIONAL","EPIC","LEGENDARY"]

var items := {}
var commodities := []
var enhancements_minor := {}
var enhancements_major := {}


func add_item(item : Dictionary, amount:=1) -> Dictionary:
	var ID = Characters.inventory.find(item)
	if ID>=0:
		Characters.inventory[ID].amount += amount
		return Characters.inventory[ID]
	else:
		item.amount = amount
		Characters.inventory.push_back(item)
	return item

func remove_item(item : Dictionary):
	Characters.inventory.erase(item)

func find_items(base_type : String) -> Array:
	var array := []
	for i in range(Characters.inventory.size()):
		if Characters.inventory[i].base_type==base_type:
			array.push_back(i)
	return array

func has_item(name : String) -> bool:
	return find_items(name).size()>0

func get_item_amount(name : String) -> int:
	var amount := 0
	for i in find_items(name):
		amount += Characters.inventory[i].amount
	return amount

func add_items(name : String, amount:=1):
	var array := find_items(name)
	if array.size()>0:
		var item : Dictionary = Characters.inventory[array[0]]
		if item.has("amount"):
			item.amount += amount
		else:
			item.amount = 1 + amount
		return item
	else:
		return add_item(create_item(name), amount)

func remove_items(name : String, amount:=1) -> int:
	var removed := 0
	for i in find_items(name):
		if Characters.inventory[i].amount<amount:
			amount -= Characters.inventory[i].amount
			removed += Characters.inventory[i].amount
			Characters.inventory[i].amount = 0
		else:
			Characters.inventory[i].amount -= amount
			removed += amount
			break
	for i in range(Characters.inventory.size()-1,-1,-1):
		if Characters.inventory[i].amount<=0:
			Characters.inventory.remove(i)
	return amount-removed

func get_pet_morale() -> float:
	var ret := 0.0
	for item in items.values():
		if item.has("type") && item.type=="pet" && item.has("morale"):
			ret += item.morale
	return ret


func health_potion(target : Characters.Character, amount : int) -> bool:
	if target.health>=target.max_health:
		return false
	target.heal(amount)
	return true

func mana_potion(target : Characters.Character, amount : int) -> bool:
	if target.mana>=target.max_mana:
		return false
	target.mana += amount
	if target.mana>target.max_mana:
		target.mana = target.max_mana
	return true

func stamina_potion(target : Characters.Character, amount : int) -> bool:
	if target.stamina>=target.max_stamina:
		return false
	target.stamina += amount
	if target.stamina>target.max_stamina:
		target.stamina = target.max_stamina
	return true

func cleansing_potion(target : Characters.Character, amount : int, filter : Array) -> bool:
	var valid_effects := []
	for k in target.status:
		if k in filter:
			valid_effects.push_back(k)
	if valid_effects.size()==0:
		return false
	for _i in range(amount):
		var k = valid_effects[randi()%valid_effects.size()]
		target.remove_status(k)
		valid_effects.erase(k)
	return true

func random_potion(target : Characters.Character, amount : int) -> bool:
	var type := randi()%4
	var multiplier := 0.5+0.5*(randi()%2)
	if randf()<0.33:
		multiplier *= -1.0
	match type:
		0:
			return health_potion(target, int(multiplier*amount))
		1:
			return mana_potion(target, int(multiplier*amount))
		2:
			return stamina_potion(target, int(multiplier*amount))
		3:
			return cleansing_potion(target, int(ceil(multiplier*amount/2)), [])
	return true



func create_item(type : String, no_enhancements:=false, amount:=1):
	if !items.has(type):
		var item := {
			"name":tr(type.to_upper()),"type":"quest","base_type":type,
			"weight":0.0,"price":0,"grade":1
		}
		return item
	
	var item : Dictionary = items[type].duplicate()
	for s in EQUIPMENT_STATS:
		if item.has(s) && typeof(item[s])==TYPE_ARRAY:
			item[s] = int(round(rand_range(item[s][0],item[s][1])))
	item.base_type = item.name
	item.name = tr(item.name.to_upper())
	if !no_enhancements:
		if randf()<0.2:
			add_enhancement(item,false)
		if randf()<0.4:
			add_enhancement(item,true)
	item.amount = amount
	return item

func add_enhancement(item : Dictionary, minor:=false):
	var enhancements := []
	if !item.has("enhancements"):
		return
	
	if minor:
		for type in item.enhancements:
			if enhancements_minor.has(type):
				enhancements += enhancements_minor[type]
	else:
		for type in item.enhancements:
			if enhancements_major.has(type):
				enhancements += enhancements_major[type]
	if enhancements.size()==0:
		return
	
	var sum := 0
	var cur := 0
	var rnd := randf()
	var ID := 0
	for i in range(enhancements.size()):
		sum += enhancements[i].frequency
	for i in range(enhancements.size()):
		if rnd<(enhancements[i].frequency+cur)/sum:
			ID = i
			break
		cur += enhancements[i].frequency
	
	var enhancement : Dictionary = enhancements[ID]
	if minor:
		item.name = tr(enhancement.name.to_upper())+" "+item.name
	else:
		item.name = item.name+" "+tr(enhancement.name.to_upper())
	for s in EQUIPMENT_STATS+["weight","price","grade"]:
		if enhancement.has(s):
			if item.has(s):
				item[s] = max(item[s]+enhancement[s],0)
			else:
				item[s] = enhancement[s]
	if enhancement.has("knowledge"):
		if item.has("knowledge"):
			item.knowledge += enhancement.knowledge
		else:
			item.knowledge = enhancement.knowledge


func get_file_paths(path : String) -> Array:
	var array := []
	var dir := Directory.new()
	var error := dir.open(path)
	if error!=OK:
		print("Error when accessing "+path+"!")
		return array
	
	dir.list_dir_begin(true)
	var file_name := dir.get_next()
	while file_name!="":
		if !dir.current_is_dir():
			array.push_back(path+"/"+file_name)
		file_name = dir.get_next()
	
	return array

func load_items(paths : Array):
	for file_name in paths:
		# open file
		var file := File.new()
		var error := file.open(file_name, File.READ)
		if error!=OK:
			print("Can't open file "+file_name+"!")
			continue
		else:
			print("Loading items "+file_name+".")
		
		while !file.eof_reached():
			# Gather all lines that are belonging to the same item.
			var raw := file.get_line()
			var num_brackets := 0
			for s in raw:
				num_brackets += int(s=="{")-int(s=="}")
			while num_brackets>0:
				var new := file.get_line()
				for s in new:
					num_brackets += int(s=="{")-int(s=="}")
				raw += "\n"+new
				if file.eof_reached():
					break
			if raw.length()<1:
				continue
			
			# parse data
			var currentline := JSON.parse(raw)
			if currentline.error!=OK:
				printt("Error parsing "+file_name+".",raw)
				continue
			var data : Dictionary = currentline.get_result()
			if !data.has("name"):
				printt("Error parsing "+file_name+" (missing name).")
				continue
			
			items[data.name] = data
			if data.type=="commodities" || data.type=="fuel":
				commodities.push_back(data.name)

func load_enhancements(paths : Array):
	for file_name in paths:
		# open file
		var file := File.new()
		var error := file.open(file_name, File.READ)
		if error!=OK:
			print("Can't open file "+file_name+"!")
			continue
		else:
			print("Loading enhancements "+file_name+".")
		
		while !file.eof_reached():
			# Gather all lines that are belonging to the same item.
			var raw := file.get_line()
			var num_brackets := 0
			for s in raw:
				num_brackets += int(s=="{")-int(s=="}")
			while num_brackets>0:
				var new := file.get_line()
				for s in new:
					num_brackets += int(s=="{")-int(s=="}")
				raw += "\n"+new
				if file.eof_reached():
					break
			if raw.length()<1:
				continue
			
			# parse data
			var currentline := JSON.parse(raw)
			if currentline.error!=OK:
				printt("Error parsing "+file_name+".",raw)
				continue
			var data : Dictionary = currentline.get_result()
			if !data.has("name"):
				printt("Error parsing "+file_name+" (missing name).")
				continue
			
			if data.has("minor") && data.minor:
				if !enhancements_minor.has(data.type):
					enhancements_minor[data.type] = [data]
				else:
					enhancements_minor[data.type].push_back(data)
			else:
				if !enhancements_major.has(data.type):
					enhancements_major[data.type] = [data]
				else:
					enhancements_major[data.type].push_back(data)

func load_data():
	load_items(get_file_paths("res://data/items"))
	load_items(get_file_paths("user://data/items"))
	load_enhancements(get_file_paths("res://data/enhancements"))
	load_enhancements(get_file_paths("user://data/enhancements"))
	


func _ready():
	load_data()

