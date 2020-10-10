extends Node

var spells := {}

func load_spell_data(path):
	var dir = Directory.new()
	var filename
	var error = dir.change_dir(path)
	if error!=OK:
		return
	error = dir.list_dir_begin(true)
	if error!=OK:
		return
	
	# Load all data files in the items directory.
	printt("Loading spells")
	filename = dir.get_next()
	while filename!="":
		var script = load(path+"/"+filename).new()
		if script.name!="":
			spells[script.name] = script
#		print("Loaded spell "+str(script.name))
		filename = dir.get_next()

func _ready():
	load_spell_data("res://data/spells")
	load_spell_data("user://data/spells")
