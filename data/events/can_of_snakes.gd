extends "res://data/scripts/base_battle.gd"

var ID := "battle_can_of_snakes"
var parent_script


func init(_parent_script):
	var num := 1
	var num_enemy := int(1.5+Characters.party.size()/2)
	var type := []
	var mean_level := 0.0
	parent_script = _parent_script
	type.resize(num_enemy)
	for i in range(num_enemy):
		type[i] = ["copperhead_snake","rattlesnake","cobra","anaconda"][randi()%4]
	player.resize(Characters.party.size())
	enemy.resize(num_enemy)
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
		mean_level += player[i].level
	mean_level /= player.size()
	for i in range(num_enemy):
		enemy[i] = Characters.create_enemy(type[i],int(max(mean_level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)))
	
	Main.add_text("\n"+tr("ATTACKED_BY_SNAKES"))
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()

# victory #

func won_battle(victory):
	if victory:
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),parent_script,{0:{"method":"defeat_snakes","grade":1}},"","",3))
	else:
		Main.add_text(tr("SNAKES_ESCAPE"))
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),parent_script,{0:{"method":"escape_snakes","grade":1}},"","",3))
