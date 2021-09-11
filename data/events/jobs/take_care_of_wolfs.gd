extends Node

var ID := "take_care_of_wolfs"
var location : Map.Location
var quest : Quests.Quest


func init(_location,_quest):
	location = Map.get_location(_location)
	quest = _quest
	
	Main.update_landscape(location.landscape)
	Main.set_title(tr("WOODS"))
	if Characters.player.proficiency.has("survival") || Game.do_roll(Characters.player,"agility","cunning")>=15:
		Main.add_text(tr("TAKE_CARE_OF_WOLFS_PLAN"))
		Main.add_action(Game.Action.new(tr("TRACK_THEM_DOWN"),self,{16:{"method":"find_wolfs","grade":2},8:{"method":"find_wolfs_spotted","grade":1},0:{"method":"surprised_by_wolfs","grade":0}},"cunning","",4,8))
		Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text(tr("TAKE_CARE_OF_WOLFS_FOUND"))
		start_battle()
	

func surprised_by_wolfs(_actor,_action,_roll):
	Map.time += 5*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_SURPRISED"))
	start_battle(0,true)

func find_wolfs_spotted(_actor,_action,_roll):
	Map.time += 10*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_TRACKED_SPOTTED"))
	start_battle()

func find_wolfs(_actor,_action,_roll):
	Map.time += 10*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_TRACKED"))
	Main.add_action(Game.Action.new(tr("ACTION_ATTACK"),self,{0:{"method":"start_battle","grade":0}},"","",2))
	if Characters.player.proficiency.has("survival"):
		Main.add_action(Game.Action.new(tr("LAY_TRAP"),self,{10:{"method":"trap_success","grade":1},0:{"method":"trap_failed","grade":0}},"cunning","",3,10))
	if Characters.player.proficiency.has("bow") || Characters.player.proficiency.has("crossbow"):
		Main.add_action(Game.Action.new(tr("SNIPE_THEM_DOWN_BOW"),self,{16:{"method":"kill","grade":2},8:{"method":"hit","grade":1},0:{"method":"missed","grade":0}},"dexterity","cunning",3,8))

func trap_success(_actor,_action,_roll):
	Map.time += 6*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_TRAP"))
	start_battle(8)

func trap_failed(_actor,_action,_roll):
	Map.time += 6*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_TRAP_FAILED"))
	start_battle()

func kill(_actor,_action,_roll):
	Map.time += 4*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_SNIPE_KILL"))
	start_battle(0,false,true)

func hit(_actor,_action,_roll):
	Map.time += 4*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_SNIPE_HIT"))
	start_battle(6)

func missed(_actor,_action,_roll):
	Map.time += 4*60
	Main.add_text(tr("TAKE_CARE_OF_WOLFS_SNIPE_MISSED"))
	start_battle()

func start_battle(damage:=0,surprised:=false,kill:=false):
	var script = load("res://data/events/jobs/take_care_of_wolfs_battle.gd").new()
	script.init(location,quest)
	if damage>0:
		damage = damage*script.enemy[0].health/10
		script.enemy[0].damaged(damage)
	if kill:
		script.enemy.pop_back()
	if surprised:
		for actor in script.enemy:
			actor.stats.agility += 2
		for actor in script.player:
			actor.add_status(Effects.Distracted)
	


# leave #

func leave(_actor,_action,_roll):
	Game.fail_quest(quest)
	Game.leave_location()
