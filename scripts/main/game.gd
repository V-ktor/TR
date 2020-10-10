extends Node

const MAX_ROLL = 20
const ROLL_GRADE = {
	-1:{"msg":"DISASTER","color":Color(0.5,0.05,0.03)},
	 0:{"msg":"FAILED",  "color":Color(0.9,0.15, 0.1)},
	 1:{"msg":"SUCCESS", "color":Color(0.2, 0.9, 0.2)},
	 2:{"msg":"GREAT",   "color":Color(0.2, 1.0, 0.5)},
	 3:{"msg":"PERFECT", "color":Color(0.2, 0.6, 1.0)}
}

var vars := {}
var scripts := []
var location : String
var in_city := false
var entry_forbidden := false
var supplies := "supplies"


class Action:
	var text : String
	var primary : String
	var secondary : String
	var result : Dictionary
	var limit : int
	var offset : int
	var num := 1
	var faces := MAX_ROLL
	var _script
	var tool_used : Dictionary
	var ID : int
	var target : Characters.Character
	var actor_override
	var target_primary : String
	var target_secondary : String
	var ticks : int
	var ref
	var type
	var health := 0
	var mana := 0
	var stamina := 0
	var runes := {}
	
	func _init(_text,_script_file,_result,_primary:="",_secondary:="",_ticks:=0,_limit:=0,_offset:=0):
		text = _text
		primary = _primary
		secondary = _secondary
		ticks = _ticks
		limit = _limit
		offset = _offset
		result = _result.duplicate()
		if typeof(_script_file)==TYPE_STRING:
			_script = load("res://data/scripts/"+_script_file+".gd").new()
		else:
			_script = _script_file
		
	


func roll(offset,num:=1,max_roll:=MAX_ROLL) -> int:
	var value := 0
	for _i in range(num):
		value += int(max(min((randi()%max_roll)+1+offset, max_roll), 1))
	return value

func do_roll(actor,primary:String,secondary:="",offset:=0,num:=1,max_roll:=MAX_ROLL) -> int:
	offset += get_offset(actor, primary, secondary)
	return roll(offset, num, max_roll)

func get_offset(actor:Characters.Character,primary:String,secondary:String) -> int:
	if primary!="":
		if secondary!="":
			return int((2*actor.stats[primary]+actor.stats[secondary])/3)-10
		else:
			return actor.stats[primary]-10
	return 0



func do_action(actor:Characters.Character,action:Action,node=null):
	var roll := 0
	var ID := -1
	if action.actor_override!=null:
		actor = action.actor_override
	if action.target!=null && action.target_primary!="":
		var offset = get_offset(action.target, action.target_primary, action.target_secondary)
		roll = do_roll(actor, action.primary, action.secondary, -offset+action.offset, action.num, action.faces)
	else:
		roll = do_roll(actor, action.primary, action.secondary, action.offset, action.num, action.faces)
	if action.ticks>0 && node!=null:
		var timer = Timer.new()
		timer.wait_time = 0.2
		add_child(timer)
		timer.start()
		node.get_node("Dots").show()
		for _i in range(action.ticks):
			if node!=null:
				node.get_node("Dots").text += "."
			yield(timer,"timeout")
		timer.queue_free()
	for k in action.result.keys():
		if roll>=k && k>ID:
			ID = k
	if ID>=0:
		var grade = action.result[ID].grade
		if node!=null:
			node.get_node("Status").show()
			node.get_node("Status").text = "["+tr(ROLL_GRADE[grade].msg)+"]"
			node.get_node("Status").modulate = ROLL_GRADE[grade].color
		if grade>0:
			var can_fail := false
			for dict in action.result.values():
				if dict.grade<=0:
					can_fail = true
					break
			if can_fail:
				actor.add_exp(grade*grade)
		action._script.call(action.result[ID].method, actor, action, roll)
	


func pay_party(delay):
	for ID in Characters.party:
		var c = Characters.characters[ID]
		if c.payment_cost==0:
			continue
		pay(delay,c.payment_currency,c.payment_cost)
		c.decrease_morale(10.0*delay/24.0)
	Characters.payment_delay += delay

func pay(delay,currency,amount):
	if Characters.payment.has(currency):
		Characters.payment[currency] += amount*float(delay)/60.0/60.0/24.0
	else:
		Characters.payment[currency] = amount*float(delay)/60.0/60.0/24.0


func set_var(ID,value=true):
	vars[ID] = value

func inc_var(ID,inc:=1):
	if vars.has(ID):
		vars[ID] += inc
	else:
		vars[ID] = inc

func get_var(ID):
	if vars.has(ID):
		return vars[ID]
	return false


func goto(_location:String):
	var c0 = Map.get_location(location)
	var c1 = Map.get_location(_location)
	var dist = c0.position.distance_to(c1.position)
	var num_steps = int(dist/8.0)
	var rot = c0.position.angle_to_point(c1.position)-PI/2.0
	var timer = Timer.new()
	timer.wait_time = 0.5
	add_child(timer)
	Main.get_node("Panel/Map").disable()
	
	for i in range(num_steps):
		var travel_time_terrain = 0.0
		var num_terrains := 0
		var pos = c0.position.linear_interpolate(c1.position, (i+0.5)/num_steps)
		var event = Events.check_event("travel", [pos])
		var delay := 0
		Main.get_node("Panel/Map").draw_footprint(pos, rot)
		for terrain in Map.terrains:
			if pos.distance_squared_to(terrain.position)<terrain.radius*terrain.radius:
				travel_time_terrain += terrain.travel_time
				num_terrains += 1
		if num_terrains>0:
			travel_time_terrain /= num_terrains
		delay = int((rand_range(0.95, 1.05)+travel_time_terrain)*8.0*60.0*60.0/Characters.get_travel_speed())
		Map.time += delay
		Characters.rations_consumed += Characters.party.size()
		if Characters.rations_consumed>=1.0:
			var diff = Items.remove_items(supplies, int(Characters.rations_consumed))
			Characters.rations_consumed -= int(Characters.rations_consumed)
			if diff>0:
				for ID in Characters.party:
					var c = Characters.characters[ID]
					c.damaged()
		for mount in Characters.mounts:
			if !mount.active:
				continue
			Items.remove_items(mount.fuel, mount.fuel_consumption)
		pay_party(delay)
		timer.start()
		yield(timer,"timeout")
		if event!=null:
			var script = load("res://data/events/"+event.script+".gd").new()
			if event.has("args"):
				script.init(c0.position+(c1.position-c0.position)*(i+1.0)/(num_steps+2.0),event.args)
			else:
				script.init(c0.position+(c1.position-c0.position)*(i+1.0)/(num_steps+2.0))
			Main.update_party()
			Main._show_log()
			for ID in Characters.party:
				var c = Characters.characters[ID]
				if "curious" in c.personality:
					c.add_morale(2.0)
			return
	
	var delay = int(rand_range(0.95, 1.05)*max(dist-8.0*num_steps, 0.0)*60.0*60.0/Characters.get_travel_speed())
	Characters.rations_consumed += Characters.party.size()*max(dist-8.0*num_steps, 0.0)/8.0
	Map.time += delay
	pay_party(delay)
	enter_location(_location,c1)

func enter_location(_location : String,c=null):
	if entry_forbidden && location==_location:
		leave_location()
		return
	
	if c==null:
		c = Map.get_location(_location)
	else:
		c.shop_seed = randi()
	Main.add_text("\n"+tr("ENTER_LOCATION_"+c.type.to_upper()).format({"name":c.name}))
	Main.add_text(c.description+"\n")
	Main.update_party()
	if location!=_location && (Characters.relations[c.faction]<-10 || (Characters.player.traits.has("startling") && Characters.relations[c.faction]<10)):
		var script = load("res://data/events/city_gates.gd").new()
		in_city = false
		script.init(c,_location)
		location = _location
		Main.update_party()
		Main._show_log()
		return
	
	location = _location
	entry_forbidden = false
	Main.set_title("")
	in_city = true
	print("Entering "+location)
	
	for ID in Map.locations.keys():
		if Map.get_location(ID).temporary:
			Map.locations.erase(ID)
			Map.cities.erase(ID)
	
	Main._show_log()
	Main.get_node("Panel/Map").enable()
	Main.update_landscape(c.landscape)
	Main.set_title(c.name)
	
	var event = Events.check_event("enter_city", [location])
	if event!=null:
		var script = load("res://data/events/"+event.script+".gd").new()
		if event.has("args"):
			script.init(location,event.args)
		else:
			script.init(location)
		Main.update_party()
		Main._show_log()
		return
	
	for f in c.facilities:
		var action = Action.new(tr("VISIT_LOCATION").format({"name":tr(f.to_upper())}), "facilities/visit_"+f, {0:{"method":"goto","grade":1}}, "", "", 2)
		Main.add_action(action)
	if c.can_leave || Main.get_action_count()==0:
		# Enable to leave a location if there is no available action.
		Main.add_action(Action.new(tr("LEAVE"), "location_general", {0:{"method":"leave","grade":1}}, "", "", 3))
	

func leave_location():
	in_city = false
	Main.set_title("")
	Main.get_node("Panel/Map").enable()
	Main._show_map()


func can_save() -> bool:
	var valid := false
	if !in_city:
		return false
	for node in Main.text_container.get_children():
		if node.has_node("Button") && !node.get_node("Button").disabled:
			valid = true
			break
	if !valid:
		return false
	return true

func _save(filename:="autosave") -> bool:
	# Save the game.
	# First check if saving the game is allowed.
	if !can_save():
		printt("Can't save the game right now.")
		return false
	
	# Open the file.
	var file := File.new()
	var error := file.open("user://saves/"+filename+".sav",File.WRITE)
	if error!=OK:
		var dir := Directory.new()
		dir.make_dir_recursive("user://saves")
		error = file.open("user://saves/"+filename+".sav",File.WRITE)
		if error!=OK:
			printt("Error while reading/making save directory.")
			return false
	
	# Write data.
	var date := OS.get_datetime()
	file.store_line(JSON.print({"version":Menu.VERSION,"name":Characters.player.get_name(),"class":tr("LVL")+" "+str(Characters.player.level)+" "+tr(Characters.player.cls_name.to_upper()),"date":tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})}))
	file.store_line(JSON.print({"location":location,"vars":vars}))
	error = Map._save(file)
	if error!=OK:
		print("Error while saving map data of save file user://saves/"+filename+".sav !")
	error = Characters._save(file)
	if error!=OK:
		print("Error while saving character data of save file user://saves/"+filename+".sav !")
	error = Events._save(file)
	if error!=OK:
		print("Error while saving event data of save file user://saves/"+filename+".sav !")
	
	file.close()
	return true

func _load(filename:="autosave") -> int:
	var file := File.new()
	var error := file.open("user://saves/"+filename+".sav",File.READ)
	if error!=OK:
		print("Error while loading user://saves/"+filename+".sav !")
		return FAILED
	
	var currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	if currentline.version!=Menu.VERSION:
		printt("Incompatible game version!")
		return FAILED
	currentline = JSON.parse(file.get_line()).result
	location = currentline.location
	vars = currentline.vars
	error = Map._load(file)
	if error!=OK:
		print("Error while loading map data of save file user://saves/"+filename+".sav !")
	error = Characters._load(file)
	if error!=OK:
		print("Error while loading character data of save file user://saves/"+filename+".sav !")
	error = Events._load(file)
	if error!=OK:
		print("Error while loading event data of save file user://saves/"+filename+".sav !")
	
	file.close()
	Menu.start()
	enter_location(location,Map.cities[location])
	return OK

