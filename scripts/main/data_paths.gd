extends Node


func add_file_paths(path : String, name : String, file=null):
	var dir := Directory.new()
	var error := dir.open(path)
	var file_opened : bool = file!=null
	if error!=OK:
		print("Error when accessing "+path+"!")
		return
	
	if file==null:
		file = File.new()
		error = file.open("res://data/"+name+".dat", File.WRITE)
	dir.list_dir_begin(true)
	var file_name := dir.get_next()
	while file_name!="":
		if dir.current_is_dir():
			scan_data_dir(path, file)
		else:
			file.store_line(path+"/"+file_name)
		file_name = dir.get_next()
	if !file_opened:
		file.close()

func scan_data_dir(path : String, file=null):
	var dir := Directory.new()
	var error := dir.open(path)
	if error!=OK:
		print("Error when accessing "+path+"!")
		return
	
	dir.list_dir_begin(true)
	var file_name := dir.get_next()
	while file_name!="":
		if dir.current_is_dir():
			print("Add data paths for "+file_name+".")
			add_file_paths(path+"/"+file_name, file_name, file)
		file_name = dir.get_next()

func _ready():
	scan_data_dir("res://data")
