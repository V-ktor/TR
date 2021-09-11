extends "res://data/scripts/base_battle.gd"

var ID := "battle_northern_mountains"
var location : Map.Location


func init(pos):
	var num := 1
	var num_enemy := 0
	var mean_level := 0.0
	var type := "mountain_lion"
	num_enemy = randi()%2+1
	Main.add_text("\n"+tr("NORTHERN_MOUNTAINS_INTRO"))
	location = Map.Location.new(tr("MOUNTAINS"),pos)
	location.temporary = true
	location.landscape = "cold_mountains"
	while Map.locations.has(ID+str(num)):
		num += 1
	ID += str(num)
	Map.locations[ID] = location
	Game.location = ID
	player.resize(Characters.party.size())
	enemy.resize(num_enemy)
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
		mean_level += player[i].level
	mean_level /= player.size()
	for i in range(num_enemy):
		enemy[i] = Characters.create_enemy(type,int(max(mean_level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)))
	
	Main.update_landscape(location.landscape)
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()
	Main.set_title(tr("MOUNTAINS"))


# victory #

func won_battle(victory):
	if victory:
		Main.add_text("\n"+tr("MOUNTAINS_VICTORY"))
		Main.add_action(Game.Action.new(tr("LEAVE_CAREFULLY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("MOUNTAINS_RETREAT"))
		for c in player:
			c.stressed()
		Main.add_action(Game.Action.new(tr("LEAVE_HASTILY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))

# leave #

func leave(_actor,_action,_roll):
	Game.leave_location()
