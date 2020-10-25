extends Node

const QUESTS_AVAILABLE = ["take_care_of_wolfs","deliver_small_package"]
const DIFFICULTIES = ["very_easy","easy","moderate","hard","impossible"]

var available_quests := []
var quests := []
var quest_desc := []


func goto(_actor,_action,_roll):
	var c = Map.get_location(Game.location)
	Main.add_text("\n"+tr("YOU_APPROACH_FACILITY").format({"location":c.name,"facility":tr("BOARD")}))
	available_quests.clear()
	for ID in QUESTS_AVAILABLE:
		var data = Quests.quests[ID]
		var valid := true
		if data.has("filter"):
			valid = false
			for tag in data.filter:
				if c.traits.has(tag):
					valid = true
					break
		if !valid:
			continue
		available_quests.push_back(ID)
	if available_quests.size()==0:
		Main.add_text(tr("BOARD_NO_JOBS"))
		Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))
	else:
		quests.resize(3+randi()%4)
		quest_desc.resize(quests.size())
		for i in range(quests.size()):
			var dict := {}
			quests[i] = create_quest()
			dict = Quests.quests[quests[i].name]
			if dict.has("descriptions") && dict.descriptions.size()>0:
				var loc = Map.get_location(quests[i].location)
				var location := ""
				if loc!=null:
					location = loc.name
				quest_desc[i] = tr(dict.descriptions[randi()%dict.descriptions.size()].to_upper()).format({"city":Map.get_location(Game.location).name,"location":location})
			else:
				quest_desc[i] = tr(quests[i].descriptions.to_upper())
		check_jobs(_actor,_action,_roll)
	Map.time += 60*2

func check_jobs(_actor,_action,_roll):
	Main.add_text(tr("BOARD_JOBS"))
	for i in range(quests.size()):
		var action := Game.Action.new(quest_desc[i],self,{0:{"method":"check_job","grade":1}},"","",3)
		action.ID = i
		Main.add_action(action)
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func create_quest() -> Quests.Quest:
	var quest : Quests.Quest
	var type = available_quests[randi()%available_quests.size()]
	var dict = Quests.quests[type]
	var timelimit := int(INF)
	var level_random := 3.0
	var level_scale := 1.0
	var level : int
	var dfc : float
	var difficulty : String
	var location := Game.location
	var events := []
	var reward = dict.reward.duplicate(true)
	if dict.has("level_random"):
		level_random = dict.level_random
	if dict.has("level_scale"):
		level_scale = dict.level_scale
	level = int(max(round(level_scale*Characters.player.level+level_random*rand_range(-1.0,1.0)),1.0))
	if typeof(dict.timelimit)==TYPE_ARRAY:
		timelimit = int(60.0*60.0*rand_range(dict.timelimit[0],dict.timelimit[1]))
	else:
		timelimit = int(60*60*dict.timelimit)
	dfc = max(0.75+dict.difficulty+float(60*60*24-timelimit)/60.0/60.0/24.0+(level-Characters.player.level)/2.0,0.0)
	difficulty = DIFFICULTIES[int(min(round(dfc),DIFFICULTIES.size()))]
	for k in reward.keys():
		reward[k] = int(max(reward[k]*(1.0+dfc)/2.0*rand_range(0.95,1.05),1.0))
	if dict.has("events"):
		events = dict.events
	quest = Quests.Quest.new({"name":type,"description":tr(type.to_upper()+"_DESC").format({"city":Map.get_location(location).name}),"difficulty":difficulty,"timelimit":Map.time+timelimit,"location":location,"events":events,"auto_delete_location":true,"reward":reward,"data":{"city":Game.location,"level":level}})
	if dict.has("location"):
		var location_data := {}
		if typeof(dict.location)==TYPE_DICTIONARY:
			location = dict.location.name
			location_data = dict.location.duplicate(true)
			if location_data.has("position") && typeof(location_data.position)==TYPE_ARRAY:
				location_data.position = Map.get_location(Game.location).position+Vector2(rand_range(location_data.position[0],location_data.position[1]),0.0).rotated(2.0*PI*randf())
			quest.location_data = location_data
			quest.location = ""
		elif typeof(dict.location)==TYPE_STRING:
			match dict.location:
				"random_city":
					var array := Map.get_nearby_locations(Game.location,dict.max_distance)
					if array.size()>0:
						location = array[randi()%array.size()]
						location_data.position = Map.get_location(location).position
						quest.location = location
		if dict.has("time_per_distance"):
			timelimit += dict.time_per_distance*Map.get_location(Game.location).position.distance_to(location_data.position)
	return quest

func check_job(_actor,action,_roll):
	var quest = quests[action.ID]
	var act := Game.Action.new(tr("ACCEPT_JOB"),self,{0:{"method":"accept","grade":1}},"","",2)
	act.ID = action.ID
	Main.add_text(quest_desc[action.ID])
	Main.add_text(quest.description)
	Main.add_text(tr("DIFFICULTY")+": "+tr(quest.difficulty.to_upper()))
	Main.add_action(act)
	Main.add_action(Game.Action.new(tr("CHECKOUT_OTHER_JOBS"),self,{0:{"method":"check_jobs","grade":1}},"","",2))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func accept(_actor,action,_roll):
	Game.accept_quest(quests[action.ID])
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
