extends "res://data/scripts/base_battle.gd"

var ID := "battle_hills"
var location : Map.Location


func init(pos):
	var num := 1
	var num_enemy := 0
	var type := []
	var mean_level := 0.0
	num_enemy = randi()%2+2
	type.resize(num_enemy)
	if randf()<0.25:
		for i in range(num_enemy):
			type[i] = "vampiric_bat"
		Main.add_text("\n"+tr("HILLS_BAT_SWARM_INTRO"))
	else:
		for i in range(num_enemy):
			var t = ["goblin_knife","goblin_mace","goblin_spear","goblin_slinger","goblin_shaman"][randi()%5]
			type[i] = t
		Main.add_text("\n"+tr("HILLS_GOBLIN_INTRO"))
	location = Map.Location.new(tr("HILLS"),pos)
	location.temporary = true
	location.landscape = "hills"
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
		enemy[i] = Characters.create_enemy(type[i],int(max(mean_level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)),char(KEY_A+i))
	
	Main.update_landscape(location.landscape)
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()
	Main.set_title(tr("HILLS"))


# victory #

func won_battle(victory):
	if victory:
		Main.add_text("\n"+tr("HILLS_VICTORY"))
		Main.add_action(Game.Action.new(tr("LEAVE_CAREFULLY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("HILLS_RETREAT"))
		for c in player:
			c.stressed()
		Main.add_action(Game.Action.new(tr("LEAVE_HASTILY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))

# leave #

func leave(_actor,_action,_roll):
	Game.leave_location()
