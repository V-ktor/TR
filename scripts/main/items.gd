extends Node

const EQUIPMENT_STATS = ["min_dam","max_dam","armor","block"]
const GRADE_COLOR = [
	Color(0.6,0.6,0.6),
	Color(1.0,1.0,1.0),
	Color(0.5,1.0,0.5),
	Color(0.5,0.5,1.0),
	Color(1.0,0.5,1.0),
	Color(1.0,1.0,0.5),
	Color(0.5,0.5,0.2)]
const GRADE_NAMES = [
	"GARBAGE","NORMAL","RARE","","",
	"EPIC","LEGENDARY"
]

var items := {}
var commodities := []
var enhancements_minor := {}
var enhancements_major := {}


func add_item(item : Dictionary, amount:=1):
	var ID := Characters.inventory.find(item)
	if ID>=0:
		Characters.inventory[ID].amount += amount
	else:
		item.amount = amount
		Characters.inventory.push_back(item)

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
	else:
		add_item(create_item(name), amount)

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



func create_item(type : String, no_enhancements:=false, amount:=1):
	if !items.has(type):
		var item := {
			"name":type,"type":"quest","base_type":type,
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


func load_items(path : String):
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
		error = file.open(path+"/"+filename,File.READ)
		if error!=OK:
			print("Can't open file "+filename+"!")
			filename = dir.get_next()
			continue
		else:
			print("Loading items "+filename+".")
		
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
				printt("Error parsing "+filename+".",raw)
				continue
			var data : Dictionary = currentline.get_result()
			if !data.has("name"):
				printt("Error parsing "+filename+" (missing name).")
				continue
			
			items[data.name] = data
			if data.type=="commodities" || data.type=="fuel":
				commodities.push_back(data.name)
			
		filename = dir.get_next()

func load_enhancements(path : String):
	var dir := Directory.new()
	var file := File.new()
	var filename : String
	var error := dir.change_dir(path)
	if error!=OK:
		return
	error = dir.list_dir_begin(true)
	if error!=OK:
		return
	
	# Load all data files in the enhancement directory.
	filename = dir.get_next()
	while filename!="":
		# open file
		error = file.open(path+"/"+filename,File.READ)
		if error!=OK:
			print("Can't open file "+filename+"!")
			filename = dir.get_next()
			continue
		else:
			print("Loading enhancements "+filename+".")
		
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
				printt("Error parsing "+filename+".",raw)
				continue
			var data : Dictionary = currentline.get_result()
			if !data.has("name"):
				printt("Error parsing "+filename+" (missing name).")
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
			
		filename = dir.get_next()

func load_data():
	load_items("res://data/items")
	load_items("user://data/items")
	load_enhancements("res://data/enhancements")
	load_enhancements("user://data/enhancements")
	


func _ready():
	load_data()

