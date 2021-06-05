extends Node

var spells := {}


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

func load_file_paths(path : String) -> Array:
	var array := []
	var file := File.new()
	var error := file.open(path, File.READ)
	if error!=OK:
		return array
	
	var currentline := file.get_line()
	while !file.eof_reached():
		array.push_back(currentline)
		currentline = file.get_line()
	file.close()
	return array

func load_spell_data(paths : Array):
	for file_name in paths:
		var script = load(file_name).new()
		if script.name!="":
			spells[script.name] = script
		print("Loaded spell "+str(script.name))

func _ready():
#	load_spell_data(get_file_paths("res://data/spells"))
	load_spell_data(load_file_paths("res://data/spells.dat"))
	load_spell_data(get_file_paths("user://data/spells"))
