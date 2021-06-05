extends CanvasLayer

const VERSION = "0.0"
const MAX_MENUS = 5
const MENUS = ["race", "class", "background", "appearance", "name"]
const STAT_DEFAULT = 10
const STAT_MIN = 5
const STAT_MAX = 15
const EXTRA_POINTS = 10

var races := {}
var available_races := []
var classes := {}
var available_classes := []
var stats := {}
var player_name := Names.Name.new("", "")
var gender := -1
var player_race := -1
var player_class := -1
var player_background := -1
var player_appearance := {}
var current := 0
var files_mode := "load"
var save_files := []
var started := false


func new_game():
	var location := ""
	var largest_city := 0
	var race = available_races[player_race]
	var cl = available_classes[player_class]
	var proficiency = classes[cl].proficiency
	var traits := []
	for k in races[race].proficiency:
		if proficiency.has(k):
			proficiency[k] += 1
		else:
			proficiency[k] = 1
	if races[race].has("traits"):
		traits = races[race].traits
	Characters.characters.clear()
	Characters.inventory.clear()
	Characters.player = Characters.add_character(player_name, 1, 0, gender, race, stats, classes[cl].equipment, proficiency, Characters.BACKGROUNDS[player_background], player_appearance, traits, [], get_stat_points_left(), 0)
	Characters.player.cls_name = cl
	Characters.player.story = [tr(Characters.BACKGROUNDS[player_background].to_upper()+"_DESC"), tr(Characters.BACKGROUNDS[player_background].to_upper()+"_"+cl.to_upper())]
	Characters.party = [Characters.player.ID]
	if classes[cl].has("mounts"):
		Characters.mounts = []+classes[cl].mounts.duplicate(true)
	else:
		Characters.mounts = []
	for array in classes[cl].inventory:
		Items.add_items(array[0], array[1])
	for mount in Characters.mounts:
		Items.add_items(mount.fuel, mount.fuel_capacity)
	Game.quests.clear()
	Game.scripts.clear()
	Game.vars.clear()
	Journal.entries.clear()
	Map.create_world()
	for k in Map.cities.keys():
		if Map.cities[k].population>largest_city && Map.cities[k].faction==available_races[player_race] && !Map.cities[k].traits.has("capital"):
			largest_city = Map.cities[k].population
			location = k
	if location=="":
		printt("No suitable starting location found!\nSelecting a random city instead...")
		location = Map.cities.keys()[randi()%Map.cities.size()]
	Game.location = location
	Characters.player.home = location
	for r in races.keys():
		Characters.relations[r] = 0.0
	if races[race].has("relations"):
		for r in races[race].relations.keys():
			Characters.relations[r] += races[race].relations[r]
	Characters.relations[available_races[player_race]] += 10.0
	Journal.add_entry(Characters.player.ID, player_name.get_name(), ["persons", "companions"], "", "", Map.time)
	start()
	var script
	if Characters.BACKGROUNDS[player_background]=="mercenary":
		script = load("res://data/events/game_start/mercenary.gd").new()
	elif Characters.BACKGROUNDS[player_background]=="explorer":
		script = load("res://data/events/game_start/explorer.gd").new()
	elif Characters.BACKGROUNDS[player_background]=="drifter" && (cl=="archer" || cl=="druid" || cl=="rogue"):
		script = load("res://data/events/game_start/explorer.gd").new()
	elif cl=="wizard":
		script = load("res://data/events/game_start/wizard.gd").new()
	else:
		script = load("res://data/events/game_start/mercenary.gd").new()
	Game.in_city = false
	script.init(Map.cities[location], location, cl)
	Main.update_party()
	Main._show_log()


func start():
	started = true
	hide()
	Main.clear()
	Main.get_node("Panel").show()
	Main.get_node("Title").show()
	Main.get_node("Panel/Map/ScrollContainer/Map").update(true)
	Main.get_node("Panel/Map/ScrollContainer").scroll_horizontal = Main.get_node("Panel/Map/ScrollContainer/Map").rect_min_size.x/2-Main.get_node("Panel/Map/ScrollContainer").rect_size.x/2
	Main.get_node("Panel/Map/ScrollContainer").scroll_vertical = Main.get_node("Panel/Map/ScrollContainer/Map").rect_min_size.y/2-Main.get_node("Panel/Map/ScrollContainer").rect_size.y/2
	$Panel/VBoxContainer/Button6.show()
	$Panel/VBoxContainer/Button7.show()
	Main.get_node("ButtonMenu").show()

func hide():
	for c in get_children():
		if c.has_method("hide"):
			c.hide()

func show():
	$BG.show()
	$Panel.show()
	$Panel/VBoxContainer/Button7.disabled = !Game.can_save()


func _save_new(_filename:=""):
	Game._save($Files/ScrollContainer/VBoxContainer/New/LineEdit.get_text())
	$Files.hide()

func _select_file(filename):
	match files_mode:
		"load":
			Game._load(filename)
			hide()
		"save":
			Game._save(filename)
			$Files.hide()

func _quit():
	Game._save()
	get_tree().quit()


# character generation #

func get_stat_points_left() -> int:
	var left := EXTRA_POINTS
	var race = available_races[player_race]
	for stat in Characters.STATS:
		left += STAT_DEFAULT-stats[stat]
		if races[race].has("stats") && races[race].stats.has(stat):
			left += races[race].stats[stat]
	return left

func _set_stat(value, stat, node):
	if value-stats[stat]<=get_stat_points_left():
		stats[stat] = value
	else:
		node.get_node("HBoxContainer/SpinBox").value = stats[stat]
	$NewChar/HBoxContainer/Summary/VBoxContainer/LabelStatPoints.text = tr("POINTS_LEFT")+" "+str(get_stat_points_left())

func combine_dicts(dict1 : Dictionary, dict2 : Dictionary) -> Dictionary:
	var dict := {}
	for k in ["traits", "stats", "proficiency", "equipment", "inventory", "knowledge"]:
		if dict1.has(k):
			dict[k] = dict1[k].duplicate(true)
		if dict2.has(k):
			if dict.has(k):
				if typeof(dict[k])==TYPE_ARRAY:
					dict[k] += dict2[k]
				else:
					for key in dict2[k].keys():
						if dict[k].has(key):
							dict[k][key] += dict2[k][key]
						else:
							dict[k][key] = dict2[k][key]
			else:
				dict[k] = dict2[k]
	return dict

func add_appearance_traits(dict : Dictionary) -> Dictionary:
	for type in player_appearance.keys():
		for k in Characters.APPEARANCE_TRAITS.keys():
			if k==player_appearance[type]:
				if !dict.has("traits"):
					dict.traits = [Characters.APPEARANCE_TRAITS[k]]
				elif !(Characters.APPEARANCE_TRAITS[k] in dict.traits):
					dict.traits.push_back(Characters.APPEARANCE_TRAITS[k])
	return dict

func get_all_traits(type : String) -> Array:
	var all_traits := []
	var race = available_races[player_race]
	if typeof(races[race].appearance[type])==TYPE_ARRAY:
		for s in races[race].appearance[type]:
			all_traits += Characters.get(type.to_upper()+"_TYPES")[s]
	else:
		all_traits = Characters.get(type.to_upper()+"_TYPES")[races[race].appearance[type]]
	return all_traits

func set_random_trait(type : String):
	var all_traits := get_all_traits(type)
	_set_trait(type, all_traits[randi()%all_traits.size()])

func _update_name(_text):
	player_name.first = $NewChar/HBoxContainer/Name/FirstName.text
	player_name.last = $NewChar/HBoxContainer/Name/LastName.text

func _set_gender(_pressed : bool, ID : int):
	var race = races[available_races[player_race]]
	if ID==0 && race.has("no_male") && race.no_male:
		ID = 1
	if ID==1 && race.has("no_female") && race.no_female:
		ID = 0
	gender = ID

func _set_race(ID : int):
	var race = available_races[ID]
	player_race = ID
	_set_gender(true, gender)
	$NewChar/HBoxContainer/Description.clear()
	$NewChar/HBoxContainer/Description.add_text(tr(race.to_upper())+"\n\n")
	$NewChar/HBoxContainer/Description.add_text(tr(race.to_upper()+"_TOOLTIP")+"\n\n")
	$NewChar/HBoxContainer/Description.add_text(tr(race.to_upper()+"_DESCRIPTION"))
	for s in Characters.STATS:
		var spin_box = get_node("NewChar/HBoxContainer/Summary/VBoxContainer/Stats/"+s.capitalize()+"/HBoxContainer/SpinBox")
		spin_box.min_value = STAT_MIN
		spin_box.max_value = STAT_MAX
		if races[race].has("stats") && races[race].stats.has(s):
			spin_box.min_value += races[race].stats[s]
			spin_box.max_value += races[race].stats[s]
	for s in player_appearance.keys():
		if !races[race].appearance.has(s):
			player_appearance.erase(s)
	for s in races[race].appearance.keys():
		if !player_appearance.has(s):
			set_random_trait(s)
	get_node("NewChar/HBoxContainer/Races/VBoxContainer/Button"+str(ID)).pressed = true
	update_preview(races[race])

func _set_class(ID : int):
	var cl = available_classes[ID]
	var num_main_stats = classes[cl].main_stats.size()
	player_class = ID
	$NewChar/HBoxContainer/Description.clear()
	$NewChar/HBoxContainer/Description.add_text(tr(cl.to_upper())+"\n\n")
	$NewChar/HBoxContainer/Description.add_text(tr(cl.to_upper()+"_TOOLTIP")+"\n\n")
	$NewChar/HBoxContainer/Description.add_text(tr("IMPORTANT_STATS")+" ")
	for i in range(num_main_stats):
		$NewChar/HBoxContainer/Description.add_text(tr(classes[cl].main_stats[i].to_upper()))
		if i==num_main_stats-2:
			$NewChar/HBoxContainer/Description.add_text(" "+tr("AND")+" ")
		elif i<num_main_stats-1:
			$NewChar/HBoxContainer/Description.add_text(", ")
	get_node("NewChar/HBoxContainer/Classes/VBoxContainer/Button"+str(ID)).pressed = true
	update_preview(classes.values()[player_class])

func _set_background(ID : int):
	player_background = ID
	$NewChar/HBoxContainer/Description.clear()
	$NewChar/HBoxContainer/Description.add_text(tr(Characters.BACKGROUNDS[ID].to_upper())+"\n\n")
	$NewChar/HBoxContainer/Description.add_text(tr(Characters.BACKGROUNDS[ID].to_upper()+"_DESC")+"\n"+tr(Characters.BACKGROUNDS[ID].to_upper()+"_"+available_classes[player_class].to_upper())+"\n")
	get_node("NewChar/HBoxContainer/Background/VBoxContainer/Button"+str(ID)).pressed = true
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.text = tr(Characters.BACKGROUNDS[player_background].to_upper()+"_DESC")
	if player_class>=0:
		$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.text += "\n\n"+tr(Characters.BACKGROUNDS[player_background].to_upper()+"_"+available_classes[player_class].to_upper())
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.show()

func _set_trait(type : String, ID : String):
	player_appearance[type] = ID
	$NewChar/HBoxContainer/Description.clear()
	update_appearance()

func _randomize():
	match current:
		0:
			_set_race(randi()%available_races.size())
		1:
			_set_class(randi()%available_classes.size())
		2:
			_set_background(randi()%Characters.BACKGROUNDS.size())
		3:
			for s in races[available_races[player_race]].appearance.keys():
				set_random_trait(s)
			update_appearance()
		4:
			var race = races[available_races[player_race]]
			var cl = classes[available_classes[player_class]]
			# Set gender.
			gender = int(2.1*randf())
			if gender==0 && races[available_races[player_race]].has("no_male") && races[available_races[player_race]].no_male:
				gender = 1
			if gender==1 && races[available_races[player_race]].has("no_female") && races[available_races[player_race]].no_female:
				gender = 0
			get_node("NewChar/HBoxContainer/Name/HBoxContainer/CheckBox"+str(gender+1)).pressed = true
			# Randomize name.
			player_name = Names.get_random_name(gender, available_races[player_race])
			get_node("NewChar/HBoxContainer/Name/FirstName").text = player_name.first
			get_node("NewChar/HBoxContainer/Name/LastName").text = player_name.last
			# Distribute stat points.
			for stat in Characters.STATS:
				var offset := 0
				if race.has("stats") && race.stats.has(stat):
					offset += race.stats[stat]
				if stat in cl.main_stats:
					# Main stats should be higher than average.
					stats[stat] = STAT_DEFAULT+2+offset+randi()%int(max(STAT_MAX-STAT_DEFAULT-2, 1))
				else:
					stats[stat] = STAT_MIN+offset+randi()%int(max(STAT_MAX-STAT_MIN, 1))
			while get_stat_points_left()!=0:
				var points_left := get_stat_points_left()
				for _i in range(max(-points_left, 0)):
					var s = stats.keys()[randi()%stats.size()]
					var offset := 0
					if race.has("stats") && race.stats.has(s):
						offset += race.stats[s]
					if !(s in cl.main_stats):
						stats[s] = max(stats[s]-1, STAT_MIN+offset)
				for _i in range(max(points_left, 0)):
					var s = stats.keys()[randi()%stats.size()]
					var offset := 0
					if race.has("stats") && race.stats.has(s):
						offset += race.stats[s]
					stats[s] = min(stats[s]+1, STAT_MAX+offset)
			update_summary()


func _next():
	if current>=MAX_MENUS-1:
		current = MAX_MENUS-1
		$NewChar/Bottom/ButtonContinue.text = tr("CONFIRM")
		new_game()
		return
	
	current += 1
	call("_select_"+MENUS[current])
	if current>=MAX_MENUS-1:
		$NewChar/Bottom/ButtonContinue.text = tr("CONFIRM")
	$NewChar/Bottom/ButtonBack.text = tr("BACK")

func _back():
	if current<=0:
		current = 0
		$NewChar/Bottom/ButtonBack.text = tr("CANCEL")
		$NewChar.hide()
		return
	
	current -= 1
	call("_select_"+MENUS[current])
	if current<=0:
		$NewChar/Bottom/ButtonBack.text = tr("CANCEL")
	$NewChar/Bottom/ButtonContinue.text = tr("NEXT")

func _select_race():
	current = 0
	$NewChar/HBoxContainer/Races.show()
	$NewChar/HBoxContainer/Classes.hide()
	$NewChar/HBoxContainer/Background.hide()
	$NewChar/HBoxContainer/Appearance.hide()
	$NewChar/HBoxContainer/Name.hide()
	$NewChar/HBoxContainer/Description.show()
	$NewChar/HBoxContainer/Preview.show()
	$NewChar/HBoxContainer/Summary.hide()
	$NewChar/Top/ButtonRace.pressed = true
	$NewChar/Bottom/ButtonBack.text = tr("CANCEL")
	$NewChar/Bottom/ButtonContinue.text = tr("NEXT")
	for c in $NewChar/HBoxContainer/Preview/VBoxContainer.get_children():
		c.hide()
	if player_race<0:
		_randomize()
	else:
		_set_race(player_race)

func _select_class():
	current = 1
	$NewChar/HBoxContainer/Races.hide()
	$NewChar/HBoxContainer/Classes.show()
	$NewChar/HBoxContainer/Background.hide()
	$NewChar/HBoxContainer/Appearance.hide()
	$NewChar/HBoxContainer/Name.hide()
	$NewChar/HBoxContainer/Description.show()
	$NewChar/HBoxContainer/Preview.show()
	$NewChar/HBoxContainer/Summary.hide()
	$NewChar/Top/ButtonClass.pressed = true
	$NewChar/Bottom/ButtonBack.text = tr("BACK")
	$NewChar/Bottom/ButtonContinue.text = tr("NEXT")
	for c in $NewChar/HBoxContainer/Preview/VBoxContainer.get_children():
		c.hide()
	if player_class<0:
		_randomize()
	else:
		_set_class(player_class)

func _select_background():
	current = 2
	$NewChar/HBoxContainer/Races.hide()
	$NewChar/HBoxContainer/Classes.hide()
	$NewChar/HBoxContainer/Background.show()
	$NewChar/HBoxContainer/Appearance.hide()
	$NewChar/HBoxContainer/Name.hide()
	$NewChar/HBoxContainer/Description.show()
	$NewChar/HBoxContainer/Preview.show()
	$NewChar/HBoxContainer/Summary.hide()
	$NewChar/Top/ButtonBackground.pressed = true
	$NewChar/Bottom/ButtonBack.text = tr("BACK")
	$NewChar/Bottom/ButtonContinue.text = tr("NEXT")
	for c in $NewChar/HBoxContainer/Preview/VBoxContainer.get_children():
		c.hide()
	if player_background<0:
		_set_background(0)
	else:
		_set_background(player_background)

func _select_appearance():
	current = 3
	$NewChar/HBoxContainer/Races.hide()
	$NewChar/HBoxContainer/Classes.hide()
	$NewChar/HBoxContainer/Background.hide()
	$NewChar/HBoxContainer/Appearance.show()
	$NewChar/HBoxContainer/Name.hide()
	$NewChar/HBoxContainer/Description.show()
	$NewChar/HBoxContainer/Preview.show()
	$NewChar/HBoxContainer/Summary.hide()
	$NewChar/Top/ButtonAppearance.pressed = true
	$NewChar/HBoxContainer/Description.text = ""
	$NewChar/Bottom/ButtonBack.text = tr("BACK")
	$NewChar/Bottom/ButtonContinue.text = tr("NEXT")
	for c in $NewChar/HBoxContainer/Preview/VBoxContainer.get_children():
		c.hide()
	update_appearance()

func _select_name():
	var race = races[available_races[player_race]]
	current = 4
	$NewChar/HBoxContainer/Races.hide()
	$NewChar/HBoxContainer/Classes.hide()
	$NewChar/HBoxContainer/Background.hide()
	$NewChar/HBoxContainer/Appearance.hide()
	$NewChar/HBoxContainer/Name.show()
	$NewChar/HBoxContainer/Description.hide()
	$NewChar/HBoxContainer/Summary.show()
	$NewChar/HBoxContainer/Preview.show()
	update_preview(add_appearance_traits(combine_dicts(races[available_races[player_race]], classes[available_classes[player_class]])))
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelStats.hide()
	$NewChar/HBoxContainer/Preview/VBoxContainer/Stats.hide()
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator2.hide()
	$NewChar/HBoxContainer/Name/HBoxContainer/CheckBox1.disabled = race.has("no_male") && race.no_male
	$NewChar/HBoxContainer/Name/HBoxContainer/CheckBox2.disabled = race.has("no_female") && race.no_female
	$NewChar/Top/ButtonName.pressed = true
	$NewChar/Bottom/ButtonBack.text = tr("BACK")
	$NewChar/Bottom/ButtonContinue.text = tr("CONFIRM")
	if player_name.get_name()==" ":
		_randomize()
	else:
		update_summary()

func update_preview(dict : Dictionary):
	var knowledge := []
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelTraits.visible = dict.has("traits") && dict.traits.size()>0
	$NewChar/HBoxContainer/Preview/VBoxContainer/Traits.visible = dict.has("traits") && dict.traits.size()>0
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator1.visible = dict.has("traits") && dict.traits.size()>0
	if dict.has("traits") && dict.traits.size()>0:
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Traits.get_children():
			c.hide()
		for i in range(dict.traits.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Traits/Trait"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Traits/Trait"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Traits/Trait0.duplicate()
				panel.name = "Trait"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Traits.add_child(panel)
			var stylebox = panel.get_stylebox("panel").duplicate()
			panel.show()
			panel.get_node("Label").text = tr(dict.traits[i].to_upper())
			panel.hint_tooltip = tr(dict.traits[i].to_upper()+"_TOOLTIP")
			if Characters.TRAIT_COLOR.has(dict.traits[i]):
				stylebox.border_color = Characters.TRAIT_COLOR[dict.traits[i]]
			else:
				stylebox.border_color = Color("#e2b057")
			panel.add_stylebox_override("panel", stylebox)
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelStats.visible = dict.has("stats")
	$NewChar/HBoxContainer/Preview/VBoxContainer/Stats.visible = dict.has("stats")
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator2.visible = dict.has("stats")
	if dict.has("stats"):
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Stats.get_children():
			c.hide()
		for i in range(dict.stats.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Stats/Stat"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Stats/Stat"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Stats/Stat0.duplicate()
				panel.name = "Stat"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Stats.add_child(panel)
			panel.show()
			panel.hint_tooltip = tr(dict.stats.keys()[i].to_upper()+"_TOOLTIP")
			if dict.stats.values()[i]>0:
				panel.get_node("Label").text = tr(dict.stats.keys()[i].to_upper())+": +"+str(dict.stats.values()[i])
			else:
				panel.get_node("Label").text = tr(dict.stats.keys()[i].to_upper())+": "+str(dict.stats.values()[i])
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelProf.visible = dict.has("proficiency")
	$NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies.visible = dict.has("proficiency")
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator3.visible = dict.has("proficiency")
	if dict.has("proficiency"):
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies.get_children():
			c.hide()
		for i in range(dict.proficiency.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies/Skill"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies/Skill"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies/Skill0.duplicate()
				panel.name = "Skill"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Proficiencies.add_child(panel)
			panel.show()
			if dict.proficiency.values()[i]>0:
				panel.get_node("Label").text = tr(dict.proficiency.keys()[i].to_upper())+": +"+str(dict.proficiency.values()[i])
			else:
				panel.get_node("Label").text = tr(dict.proficiency.keys()[i].to_upper())+": "+str(dict.proficiency.values()[i])
			panel.hint_tooltip = tr(tr(dict.proficiency.keys()[i].to_upper()+"_TOOLTIP"))
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelEquipment.visible = dict.has("equipment")
	$NewChar/HBoxContainer/Preview/VBoxContainer/Equipment.visible = dict.has("equipment")
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator5.visible = dict.has("equipment")
	if dict.has("equipment"):
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Equipment.get_children():
			c.hide()
		for i in range(dict.equipment.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Equipment/Equipment"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Equipment/Equipment"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Equipment/Equipment0.duplicate()
				panel.name = "Equipment"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Equipment.add_child(panel)
			panel.show()
			panel.get_node("Label").text = tr(dict.equipment[i].to_upper())
			if Items.items[dict.equipment[i]].has("knowledge"):
				knowledge += Items.items[dict.equipment[i]].knowledge
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelInventory.visible = dict.has("inventory")
	$NewChar/HBoxContainer/Preview/VBoxContainer/Inventory.visible = dict.has("inventory")
	if dict.has("inventory"):
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Inventory.get_children():
			c.hide()
		for i in range(dict.inventory.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Inventory/Item"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Inventory/Item"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Inventory/Item0.duplicate()
				panel.name = "Item"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Inventory.add_child(panel)
			panel.show()
			panel.get_node("Label").text = tr(dict.inventory[i][0].to_upper())+" ["+str(dict.inventory[i][1])+"x]"
	
	if dict.has("knowledge"):
		knowledge += dict.knowledge
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelSpells.visible = knowledge.size()>0
	$NewChar/HBoxContainer/Preview/VBoxContainer/Spells.visible = knowledge.size()>0
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator4.visible = knowledge.size()>0
	if knowledge.size()>0:
		for c in $NewChar/HBoxContainer/Preview/VBoxContainer/Spells.get_children():
			c.hide()
		for i in range(knowledge.size()):
			var panel
			if has_node("NewChar/HBoxContainer/Preview/VBoxContainer/Spells/Spell"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Preview/VBoxContainer/Spells/Spell"+str(i))
			else:
				panel = $NewChar/HBoxContainer/Preview/VBoxContainer/Spells/Spell0.duplicate()
				panel.name = "Spell"+str(i)
				$NewChar/HBoxContainer/Preview/VBoxContainer/Spells.add_child(panel)
			panel.show()
			panel.get_node("Label").text = tr(knowledge[i].to_upper())
			panel.hint_tooltip = tr(knowledge[i].to_upper()+"_TOOLTIP")
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.hide()
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator6.hide()

func update_summary():
	var dict := combine_dicts(races[available_races[player_race]], classes[available_classes[player_class]])
	for s in stats.keys():
		var panel = get_node("NewChar/HBoxContainer/Summary/VBoxContainer/Stats/"+s.capitalize())
		if dict.has("stats") && dict.stats.has(s):
			panel.get_node("HBoxContainer/SpinBox").min_value = STAT_MIN+dict.stats[s]
			panel.get_node("HBoxContainer/SpinBox").max_value = STAT_MAX+dict.stats[s]
			if stats[s]<STAT_MIN+dict.stats[s]:
				stats[s] = STAT_MIN+dict.stats[s]
			if stats[s]>STAT_MAX+dict.stats[s]:
				stats[s] = STAT_MAX+dict.stats[s]
		else:
			panel.get_node("HBoxContainer/SpinBox").min_value = STAT_MIN
			panel.get_node("HBoxContainer/SpinBox").max_value = STAT_MAX
			if stats[s]<STAT_MIN:
				stats[s] = STAT_MIN
			if stats[s]>STAT_MAX:
				stats[s] = STAT_MAX
		panel.get_node("HBoxContainer/SpinBox").value = stats[s]
	
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.text = tr(available_races[player_race].to_upper())+" "+tr(available_classes[player_class].to_upper())
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.show()
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator6.show()

func update_appearance():
	var dict := {}
	var race = races[available_races[player_race]]
	dict["traits"] = []
	for c in $NewChar/HBoxContainer/Appearance/VBoxContainer.get_children():
		c.hide()
	if race.has("appearance"):
		for i in range(race.appearance.size()):
			var type = race.appearance.keys()[i]
			var traits := get_all_traits(type)
			var panel
			if has_node("NewChar/HBoxContainer/Appearance/VBoxContainer/Cat"+str(i)):
				panel = get_node("NewChar/HBoxContainer/Appearance/VBoxContainer/Cat"+str(i))
			else:
				var button_group := ButtonGroup.new()
				panel = $NewChar/HBoxContainer/Appearance/VBoxContainer/Cat0.duplicate(0)
				panel.name = "Cat"+str(i)
				for c in panel.get_node("VBoxContainer").get_children():
					if c.name=="Label":
						continue
					c.group = button_group
				$NewChar/HBoxContainer/Appearance/VBoxContainer.add_child(panel)
			for c in panel.get_node("VBoxContainer").get_children():
				c.hide()
			panel.get_node("VBoxContainer/Label").show()
			panel.show()
			panel.get_node("VBoxContainer/Label").text = tr(type.to_upper())
			if !player_appearance.has(type):
				player_appearance[type] = traits[randi()%traits.size()]
			elif !(player_appearance[type] in traits):
				player_appearance[type] = traits[randi()%traits.size()]
			for j in range(traits.size()):
				var button
				if panel.has_node("VBoxContainer/Button"+str(j)):
					button = panel.get_node("VBoxContainer/Button"+str(j))
				else:
					button = panel.get_node("VBoxContainer/Button0").duplicate(0)
					button.name = "Button"+str(j)
					panel.get_node("VBoxContainer").add_child(button)
				button.show()
				button.text = tr(traits[j].to_upper())
				if button.is_connected("pressed", self, "_set_trait"):
					button.disconnect("pressed", self, "_set_trait")
				button.pressed = player_appearance[type]==traits[j]
				button.connect("pressed", self, "_set_trait", [type, traits[j]])
			panel.rect_min_size.y = 36*(1+traits.size())
			for k in Characters.APPEARANCE_TRAITS.keys():
				if k==player_appearance[type] && !(Characters.APPEARANCE_TRAITS[k] in dict.traits):
					dict.traits.push_back(Characters.APPEARANCE_TRAITS[k])
	update_preview(dict)
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.text = tr(available_races[player_race].to_upper())+" "+tr(available_classes[player_class].to_upper())
	$NewChar/HBoxContainer/Preview/VBoxContainer/LabelDescription.show()
	$NewChar/HBoxContainer/Preview/VBoxContainer/HSeparator6.show()


func _show_new():
	$NewChar.show()
	_select_race()

func _show_load():
	files_mode = "load"
	update_save_files()
	$Files/Panel/Label.text = tr("LOAD")
	$Files.show()

func _show_save():
	files_mode = "save"
	update_save_files()
	$Files/ScrollContainer/VBoxContainer/New.show()
	$Files/Panel/Label.text = tr("SAVE")
	$Files.show()

func _show_options():
	Settings.load_settings()
	$Options.show()
	_select_setting(true, Settings.settings.keys()[0])


func update_save_files():
	# Add paths of all save files to save_files.
	var filename : String
	var dir := Directory.new()
	var error := dir.open("user://saves")
	if error!=OK:
		print("Failed to open save directory.")
		return
	
	dir.list_dir_begin(true)
	filename = dir.get_next()
	save_files.clear()
	while filename!="":
		if ".sav" in filename:
			save_files.push_back(filename.replace(".sav", ""))
		filename = dir.get_next()
	save_files.sort()
	dir.list_dir_end()
	
	for c in $Files/ScrollContainer/VBoxContainer.get_children():
		c.hide()
	for i in range(save_files.size()):
		var button : Button
		var file := File.new()
		if has_node("Files/ScrollContainer/VBoxContainer/Button"+str(i)):
			button = get_node("Files/ScrollContainer/VBoxContainer/Button"+str(i))
			if button.is_connected("pressed", self, "_select_file"):
				button.disconnect("pressed", self, "_select_file")
		else:
			button = $Files/ScrollContainer/VBoxContainer/Button0.duplicate(0)
			button.name = "Button"+str(i)
			$Files/ScrollContainer/VBoxContainer.add_child(button)
		button.connect("pressed", self, "_select_file", [save_files[i]])
		error = file.open("user://saves/"+save_files[i]+".sav", File.READ)
		if error==OK:
			var currentline = JSON.parse(file.get_line()).result
			if currentline!=null && typeof(currentline)==TYPE_DICTIONARY:
				button.get_node("GridContainer/LabelName").text = currentline.name
				button.get_node("GridContainer/LabelClass").text = currentline.class
				button.get_node("GridContainer/LabelDate").text = currentline.date
				button.get_node("GridContainer/LabelFilename").text = save_files[i]
				button.get_node("GridContainer/LabelVersion").text = currentline.version
				if currentline.version!=VERSION:
					button.get_node("GridContainer/LabelVersion").modulate = Color(1.0, 0.0, 0.0)
				else:
					button.get_node("GridContainer/LabelVersion").modulate = Color(1.0, 1.0, 1.0)
				button.show()

func _apply_settings():
	# ...
	Settings.apply()
	Settings.save_settings()

func _confirm_settings():
	_apply_settings()
	$Options.hide()

func _set_setting(value, type, ID):
	Settings.settings[type][ID] = value

func _select_setting(pressed, type):
	if !pressed:
		return
	for c in $Options/ScrollContainer/VBoxContainer.get_children():
		c.queue_free()
	for k in Settings.settings[type]:
		var container := HBoxContainer.new()
		var label := Label.new()
		label.text = tr(k.to_upper())
		label.add_color_override("font_color", Color(1.0, 1.0, 1.0))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(label)
		match typeof(Settings.settings[type][k]):
			TYPE_BOOL:
				var button := CheckBox.new()
				button.name = k.capitalize()
				button.pressed = Settings.settings[type][k]
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				button.connect("toggled", self, "_set_setting", [type, k])
				container.add_child(button)
			TYPE_INT:
				var button := SpinBox.new()
				button.name = k.capitalize()
				if Settings.MIN_VALUES.has(k):
					button.min_value = Settings.MIN_VALUES[k]
				else:
					button.min_value = 0
				if Settings.MAX_VALUES.has(k):
					button.max_value = Settings.MAX_VALUES[k]
				else:
					button.max_value = 100
				button.value = Settings.settings[type][k]
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				button.connect("value_changed", self, "_set_setting", [type, k])
				container.add_child(button)
			TYPE_REAL:
				var button = HSlider.new()
				button.name = k.capitalize()
				if Settings.MIN_VALUES.has(k):
					button.min_value = Settings.MIN_VALUES[k]
				else:
					button.min_value = 0.0
				if Settings.MAX_VALUES.has(k):
					button.max_value = Settings.MAX_VALUES[k]
				else:
					button.max_value = 1.0
				button.step = 0.0
				button.value = Settings.settings[type][k]
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				button.connect("value_changed", self, "_set_setting", [type, k])
				container.add_child(button)
		
		$Options/ScrollContainer/VBoxContainer.add_child(container)


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

func load_races(paths : Array):
	for file_name in paths:
		var file := File.new()
		var err := file.open(file_name, File.READ)
		if err==OK:
			var currentline = JSON.parse(file.get_as_text()).result
			if currentline!=null:
				print("Add race "+file_name+".")
				races[currentline.name] = currentline
				if currentline.has("playable") && currentline.playable:
					available_races.push_back(currentline.name)
		file.close()

func load_classes(paths : Array):
	for file_name in paths:
		var file := File.new()
		var err := file.open(file_name, File.READ)
		if err==OK:
			var currentline = JSON.parse(file.get_as_text()).result
			if currentline!=null:
				print("Add class "+file_name+".")
				classes[currentline.name] = currentline
				if currentline.has("playable") && currentline.playable:
					available_classes.push_back(currentline.name)
		file.close()


func _input(event):
	if event.is_action_pressed("ui_cancel") && started:
		if $Panel.visible:
			hide()
		else:
			show()

func _ready():
	randomize()
	
	# Load race and class data.
	load_races(get_file_paths("res://data/races"))
	load_races(get_file_paths("user://data/races"))
	load_classes(get_file_paths("res://data/classes"))
	load_classes(get_file_paths("user://data/classes"))
	
	# Set up GUI stuff.
	for stat in Characters.STATS:
		var box = $NewChar/HBoxContainer/Summary/VBoxContainer/Stats/Stat0.duplicate()
		box.name = stat.capitalize()
		box.get_node("HBoxContainer/Label").text = tr(stat.to_upper())
		box.hint_tooltip = tr(stat.to_upper()+"_TOOLTIP")
		box.get_node("HBoxContainer/SpinBox").min_value = STAT_MIN
		box.get_node("HBoxContainer/SpinBox").max_value = STAT_MAX
		box.get_node("HBoxContainer/SpinBox").value = STAT_DEFAULT
		box.get_node("HBoxContainer/SpinBox").hint_tooltip = tr(stat.to_upper()+"_TOOLTIP")
		$NewChar/HBoxContainer/Summary/VBoxContainer/Stats.add_child(box)
		box.get_node("HBoxContainer/SpinBox").connect("value_changed", self, "_set_stat", [stat, box])
		box.show()
		stats[stat] = STAT_DEFAULT
	$NewChar/HBoxContainer/Name/FirstName.connect("text_changed", self, "_update_name")
	$NewChar/HBoxContainer/Name/LastName.connect("text_changed", self, "_update_name")
	for i in range(3):
		get_node("NewChar/HBoxContainer/Name/HBoxContainer/CheckBox"+str(i+1)).connect("toggled", self, "_set_gender", [i])
	for i in range(available_races.size()):
		var button = $NewChar/HBoxContainer/Races/VBoxContainer/Button.duplicate()
		button.name = "Button"+str(i)
		button.text = tr(available_races[i].to_upper())
		button.hint_tooltip = tr(available_races[i].to_upper()+"_TOOLTIP")
		$NewChar/HBoxContainer/Races/VBoxContainer.add_child(button)
		button.connect("pressed", self, "_set_race", [i])
		button.show()
	for i in range(available_classes.size()):
		var button = $NewChar/HBoxContainer/Classes/VBoxContainer/Button.duplicate()
		button.name = "Button"+str(i)
		button.text = tr(available_classes[i].to_upper())
		button.hint_tooltip = tr(available_classes[i].to_upper()+"_TOOLTIP")
		$NewChar/HBoxContainer/Classes/VBoxContainer.add_child(button)
		button.connect("pressed", self, "_set_class", [i])
		button.show()
	for i in range(Characters.BACKGROUNDS.size()):
		var button = $NewChar/HBoxContainer/Background/VBoxContainer/Button.duplicate()
		button.name = "Button"+str(i)
		button.text = tr(Characters.BACKGROUNDS[i].to_upper())
#		button.hint_tooltip = tr(Characters.BACKGROUNDS[i].to_upper()+"_TOOLTIP")
		$NewChar/HBoxContainer/Background/VBoxContainer.add_child(button)
		button.connect("pressed", self, "_set_background", [i])
		button.show()
	for k in Settings.settings.keys():
		var button := $Options/Top/Button0.duplicate()
		button.name = "Button"+k.capitalize()
		button.text = tr(k.to_upper())
		button.connect("toggled", self, "_select_setting", [k])
		$Options/Top.add_child(button)
		button.show()
	
	# Connect buttons.
	$NewChar/Top/ButtonRace.connect("pressed", self, "_select_race")
	$NewChar/Top/ButtonClass.connect("pressed", self, "_select_class")
	$NewChar/Top/ButtonBackground.connect("pressed", self, "_select_background")
	$NewChar/Top/ButtonAppearance.connect("pressed", self, "_select_appearance")
	$NewChar/Top/ButtonName.connect("pressed", self, "_select_name")
	$NewChar/Bottom/ButtonBack.connect("pressed", self, "_back")
	$NewChar/Bottom/ButtonContinue.connect("pressed", self, "_next")
	$NewChar/Bottom/ButtonRandomize.connect("pressed", self, "_randomize")
	$Panel/VBoxContainer/Button1.connect("pressed", self, "_show_new")
	$Panel/VBoxContainer/Button2.connect("pressed", self, "_show_load")
	$Panel/VBoxContainer/Button7.connect("pressed", self, "_show_save")
	$Panel/VBoxContainer/Button3.connect("pressed", self, "_show_options")
	$Panel/VBoxContainer/Button4.connect("pressed", self, "_quit")
	$Panel/VBoxContainer/Button5.connect("pressed", $Credits, "show")
	$Panel/VBoxContainer/Button6.connect("pressed", self, "hide")
	$Files/Panel/Button.connect("pressed", $Files, "hide")
	$Files/ScrollContainer/VBoxContainer/New/LineEdit.connect("text_entered", self, "_save_new")
	$Files/ScrollContainer/VBoxContainer/New/ButtonConfirm.connect("pressed", self, "_save_new")
	$Options/Panel/Button.connect("pressed", $Options, "hide")
	$Options/Bottom/ButtonConfirm.connect("pressed", self, "_confirm_settings")
	$Options/Bottom/ButtonApply.connect("pressed", self, "_apply_settings")
	$Options/Bottom/ButtonCancel.connect("pressed", $Options, "hide")
	$Credits/Panel/Button.connect("pressed", $Credits, "hide")
	$Credits/RichTextLabel.connect("meta_clicked", OS, "shell_open")
	
	# Hide these buttons. Only visible once the game has been started.
	$Panel/VBoxContainer/Button6.hide()
	$Panel/VBoxContainer/Button7.hide()
	
	# Set up credits text.
	$Credits/RichTextLabel.add_text(tr("ENGINE")+":\n Godot 3.2 (")
	$Credits/RichTextLabel.append_bbcode("[url=https://godotengine.org]godotengine.org[/url]")
	$Credits/RichTextLabel.add_text(")\n\n"+tr("PROGRAMMING")+":\n - Viktor Hahn\n\n")
	$Credits/RichTextLabel.add_text(tr("GRAPHICS")+":\n - Justin Nichol(")
	$Credits/RichTextLabel.append_bbcode("[url=https://opengameart.org/content/flare-environment-concept-art-pack-1]opengameart.org[/url]")
	$Credits/RichTextLabel.add_text(")\n - Sergei Churbanov\n - Tamara Ramsay (")
	$Credits/RichTextLabel.append_bbcode("[url=http://vectorgurl.com/]vectorgurl.com[/url]")
	$Credits/RichTextLabel.add_text(")\n - Nidhoggn\n - JAP\n\n")
	$Credits/RichTextLabel.add_text(tr("FONT")+":\n - Jonas Hecksher\n - Kenney Vleugels (")
	$Credits/RichTextLabel.append_bbcode("[url=www.kenney.nl]www.kenney.nl[/url]")
	$Credits/RichTextLabel.add_text(")\n\n")
	
