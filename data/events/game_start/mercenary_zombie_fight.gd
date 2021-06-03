extends "res://data/scripts/base_battle.gd"

var ID := "battle_mercenary_zombies"
var location : Map.Location
var parent_script


func init(_parent_script : Node, type:="walking_corpse"):
	var mean_level := 0.0
	var num_enemies := int(1 + Characters.party.size())
	parent_script = _parent_script
	Main.add_text(tr("MERCENARY_ZOMBIE_ATTACK"))
	player.resize(Characters.party.size())
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
		mean_level += player[i].level
	mean_level /= player.size()
	enemy.resize(num_enemies)
	for i in range(num_enemies):
		enemy[i] = Characters.create_enemy(type,mean_level)
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()


# victory #

func won_battle(victory : bool):
	if victory:
		Main.add_text("\n"+tr("MERCENARY_ZOMBIES_DEFEATED"))
	else:
		Main.add_text("\n"+tr("MERCENARY_ZOMBIES_STILL_DEFEATED"))
	Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),parent_script,{0:{"method":"zombies_defeated","grade":1}},"","",3))

# leave #

func leave(_actor,_action,_roll):
	parent_script.zombies_defeated(_actor,_action,_roll)
