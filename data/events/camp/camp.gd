extends Node

var location : Map.Location
var delay : int
var traps := false


func init(pos):
	var event
	var encounter_chance : float
	var encounter : bool
	var date := OS.get_datetime_from_unix_time(Map.time)
	var hour : float = date.hour+date.minute/60.0
	var dt := min(hour/2.0, 3.0)
	location = Map.Location.new(tr("CAMP"), pos)
	if hour>16.0:
		dt = -min((21.0-hour)/2.0, 3.0)
	delay = int(8.0-dt+rand_range(-0.05,0.05))*60*60
	
	Main.set_title(tr("CAMP"))
	Main.add_text(tr("CAMP_INTRO"))
	
	if Characters.party.size()==1:
		Main.add_text(tr("CAMP_ALONE"))
	else:
		Main.add_text(tr("CAMP_SHIFTS"))
	if Characters.player.proficiency.has("survival"):
		Main.add_text(tr("CAMP_TRAPS"))
		traps = true
	else:
		var character = Characters.has_proficiency("survival")
		if character!=null:
			Main.add_text(tr("CAMP_CHARACTER_TRAPS").format({"name":character.name.first}))
			traps = true
	
	encounter_chance = max(0.5-0.2*clamp(Characters.get_proficiency_level("survival")-1.0,0.0,2.0),0.0)
	encounter = randf()<encounter_chance
	if !encounter:
		event = Events.check_event("set_camp", [location,self])
	
	if event!=null:
		pass
	
	if encounter:
		Main.add_action(Game.Action.new(tr("REST"),self,{0:{"method":"encounter","grade":0}},"","",4))
	else:
		Main.add_action(Game.Action.new(tr("REST"),self,{0:{"method":"rest_high","grade":1}},"","",5))


func encounter(_actor,_action,_roll):
	var surprise_chance := 0.25+0.25*float(Characters.party.size()==1)-0.25*float(traps)
	var script = load("res://data/events/camp/camp_fight.gd").new()
	var surprised := randf()<surprise_chance
# warning-ignore:integer_division
	Map.time += delay/2
	Main.add_text("\n"+tr("CAMP_ENCOUNTER"))
	if surprised:
		Main.add_text(tr("CAMP_ENCOUNTER_SURPRISED"))
	script.init(self)
	if surprised:
		for actor in script.enemy:
			actor.stats.agility += 2
		for actor in script.player:
			actor.add_status(Effects.Distracted)

func flee(_actor,_action,_roll):
	var array := []
	for item in Characters.inventory:
		if item.type=="supplies":
			array.push_back(item)
	if array.size()>0:
		var item = array[randi()%array.size()]
		var amount := int(min(rand_range(6,10)+rand_range(0.09,1.1)*item.amount,max(item.amount-1,0)))
		item.amount -= amount
		Main.add_text(tr("CAMP_ENCOUNTER_LOST_RATIONS").format({"type":tr(item.name.to_upper()),"amount":amount}))
	rest_low(_actor,_action,_roll)

func rest_low(_actor,_action,_roll):
	feed_pets()
# warning-ignore:integer_division
	Map.time += delay/2
	Main.add_text(tr("CAMP_NO_SLEEP")+"\n"+tr("CAMP_CONTINUE"))
	Characters.rest(0.1)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",2))

func rest_high(_actor,_action,_roll):
	feed_pets()
	Map.time += delay
	Main.add_text(tr("CAMP_NO_OCCURRENCE")+"\n"+tr("CAMP_CONTINUE"))
	Characters.rest(0.25)
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",2))

func feed_pets():
	for item in Characters.inventory:
		if item.has("type") && item.type=="pet":
			Main.add_text(tr("CAMP_FEED").format({"type":tr(item.name.to_upper())}))
			Items.remove_items("supplies")

# leave #

func leave(_actor,_action,_roll):
	Game.set_var("last_rest_time",Map.time)
	Game.leave_location()
