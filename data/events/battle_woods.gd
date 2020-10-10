extends "res://data/scripts/base_battle.gd"

var ID := "battle_woods"
var location


func init(pos):
	var num := 1
	var num_enemy := 0
	var type := []
	var mean_level := 0.0
	if randf()<0.5:
		num_enemy = 2
		type.resize(num_enemy)
		for i in range(num_enemy):
			type[i] = ["corrosive_slime","cryo_slime","pyro_slime","toxic_slime"][randi()%4]
	else:
		var t = ["dog","cat","wolf"][randi()%3]
		num_enemy = randi()%2+1
		type.resize(num_enemy)
		for i in range(num_enemy):
			type[i] = t
	location = Map.Location.new(tr("WOODS"),pos)
	location.temporary = true
	location.landscape = "woods"
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
	Main.add_text("\n"+tr("WOODS_INTRO"))
	
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()
	Main.set_title(tr("WOODS"))


# victory #

func won_battle(victory):
	if victory:
		Main.add_text("\n"+tr("WOODS_VICTORY"))
		Main.add_action(Game.Action.new(tr("LEAVE_CAREFULLY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("WOODS_RETREAT"))
		for c in player:
			c.stressed()
		Main.add_action(Game.Action.new(tr("LEAVE_HASTILY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))

# leave #

func leave(_actor,_action,_roll):
	Game.leave_location()
