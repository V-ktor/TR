extends Node

var events := []
var character_events := {}


func check_event(type,args):
	if has_method("check_"+type):
		return callv("check_"+type,args)

func check_travel(pos):
	var encounters := []
	var length : int
	for terrain in Map.terrains:
		if pos.distance_squared_to(terrain.position)<terrain.radius*terrain.radius:
			encounters += terrain.encounters
	length = encounters.size()
	for dict in encounters:
		if randf()<dict.base_chance/length:
			if dict.has("character"):
				if character_events.has(dict.character):
					character_events[dict.character].push_back(dict.script)
				else:
					character_events[dict.character] = [dict.script]
			return dict

func check_enter_city(_location):
	var  array := []
	var length : int
	printt("check enter city")
	if Characters.party.size()>1:
		for ID in Characters.party:
			var c = Characters.characters[ID]
			if c.hired && c.hired_until!=0 && Map.time>=c.hired_until:
				array.push_back({"script":"mercenary_expired","args":[ID],"base_chance":1.0,"character":ID})
	length = array.size()
	for dict in array:
		if randf()<dict.base_chance/length:
			if dict.has("character"):
				if character_events.has(dict.character):
					character_events[dict.character].push_back(dict.script)
				else:
					character_events[dict.character] = [dict.script]
			return dict


func _save(file : File) -> int:
	# Add informations to save file.
	file.store_line(JSON.print({"events":events}))
	file.store_line(JSON.print(character_events))
	return OK

func _load(file : File) -> int:
	# Load from given save file.
	var currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	events = currentline.events
	currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	character_events = currentline
	return OK
