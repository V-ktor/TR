extends Node

var events := []
var character_events := {}


class Event:
	var type : String
	var location : String
	var quest : String
	var base_chance : float
	var args : Array
	var _script
	
	func _init(_type,_script_path,_location,_quest="",_base_chance=1.0,_args:=[]):
		type = _type
		_script = _script_path
		location = _location
		quest = _quest
		base_chance = _base_chance
		args = _args
	
	func to_dict() -> Dictionary:
		var dict := {"type":type,"script":_script,"location":location,"base_chance":base_chance,"quest":quest,"args":args}
		return dict


func check_event(type : String,args:=[]):
	if has_method("check_"+type):
		return callv("check_"+type,args)

func check_travel(pos : Vector2):
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

func check_enter_city(location : String):
	var  array := []
	var length : int
	for event in events:
		if event.type=="enter_city":
			if event.location=="" || event.location==location:
				array.push_back(event)
	length = array.size()
	if length>0:
		for dict in array:
			if randf()<dict.base_chance/length:
				return dict
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

func check_enter_location(location : String):
	var array := []
	var length : int
	for event in events:
		if event.type=="enter_location":
			if event.location=="" || event.location==location:
				array.push_back(event)
	length = array.size()
	for dict in array:
		if randf()<dict.base_chance/length:
			return dict


func register_event(data : Dictionary):
	var quest := ""
	var base_chance := 1.0
	var args := []
	if data.has("quest"):
		quest = data.quest
	if data.has("base_chance"):
		base_chance = data.base_chance
	if data.has("args"):
		args = data.args
	events.push_back(Event.new(data.type,data.script,data.location,quest,base_chance,args))

func clear_event(event : Event):
	events.erase(event)

func clear_quest_events(ID):
	for event in events:
		if event.quest==ID:
			clear_event(event)


func _save(file : File) -> int:
	# Add informations to save file.
	var array := []
	array.resize(events.size())
	for i in range(events.size()):
		array[i] = events[i].to_dict()
	file.store_line(JSON.print({"events":array}))
	file.store_line(JSON.print(character_events))
	return OK

func _load(file : File) -> int:
	# Load from given save file.
	var currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	events.resize(currentline.events.size())
	for i in range(events.size()):
		events[i] = Event.new(currentline.events[i].type,currentline.events[i].script,currentline.events[i].location,currentline.events[i].quest,currentline.events[i].base_chance,currentline.events[i].args)
	currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	character_events = currentline
	return OK
