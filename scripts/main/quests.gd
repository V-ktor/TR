extends Node

var quests := {}


class Quest:
	var ID : String
	var name : String
	var description : String
	var updates : Array
	var difficulty : String
	var timelimit : int
	var location : String
	var location_data : Dictionary
	var auto_delete_location := true
	var faction : String
	var reward : Dictionary
	var items : Array
	var data : Dictionary
	var events : Array
	var start_script : String
	var status : String
	
	func _init(dict : Dictionary):
		if dict.has("ID"):
			ID = dict.ID
		name = dict.name
		description = dict.description
		difficulty = dict.difficulty
		if dict.has("timelimit"):
			timelimit = dict.timelimit
		if dict.has("location"):
			location = dict.location
		if dict.has("auto_delete_location"):
			auto_delete_location = dict.auto_delete_location
		if dict.has("reward"):
			reward = dict.reward
		if dict.has("data"):
			data = dict.data
		if dict.has("events"):
			events = dict.events.duplicate(true)
			for i in range(events.size()):
				events[i].location = location
		if dict.has("script"):
			start_script = dict.script
		if dict.has("updates"):
			updates = dict.updates
		status = "initialized"
	
	func update(text : String):
		updates.push_back(text)
	
	func to_dict() -> Dictionary:
		var dict := {"ID":ID,"name":name,"description":description,"difficulty":difficulty,
			"timelimit":timelimit,"location":location,"auto_delete_location":auto_delete_location,
			"reward":reward,"events":events,"script":start_script,"status":status,"data":data,"updates":updates}
		return dict


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
		else:
			array += get_file_paths(path+"/"+file_name)
		file_name = dir.get_next()
	
	return array

func load_quests(paths : Array):
	for file_name in paths:
		var file := File.new()
		var err := file.open(file_name,File.READ)
		if err!=OK:
			print("Can't open file "+file_name+"!")
			continue
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
			currentline = JSON.parse(currentline)
			if currentline.error!=OK:
				printt("Error parsing "+file_name+".")
				continue
			currentline = currentline.get_result()
#			var currentline = JSON.parse(file.get_as_text()).result
			if currentline!=null:
				quests[currentline.name] = currentline
			print("Add quest "+currentline.name+".")
		file.close()

func _ready():
	load_quests(get_file_paths("res://data/quests"))
	load_quests(get_file_paths("user://data/quests"))
