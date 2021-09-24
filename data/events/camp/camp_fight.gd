extends "res://data/scripts/base_battle.gd"

var ID := "battle_camp"
var location : Map.Location
var parent_script


func init(_parent_script):
	var mean_level := 0.0
	var type : String = ["wolf","plain_wolf","desert_wolf","hyena","lion","mountain_lion"][randi()%6]
# warning-ignore:integer_division
	var num_enemy := int(2+Characters.party.size()/2)
	parent_script = _parent_script
	enemy.resize(num_enemy)
	player.resize(Characters.party.size())
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
		mean_level += player[i].level
	mean_level /= player.size()
	for i in range(num_enemy):
		enemy[i] = Characters.create_enemy(type,int(max(mean_level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)))
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()


# victory #

func won_battle(victory):
	if victory:
		Main.add_text("\n"+tr("CAMP_ENCOUNTER_WON"))
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),parent_script,{0:{"method":"rest_high","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("CAMP_ENCOUNTER_FLEE"))
		Main.add_action(Game.Action.new(tr("RUN"),parent_script,{0:{"method":"flee","grade":1}},"","",2))

# leave #

func leave(_actor,_action,_roll):
	parent_script.find_ruins(_actor,_action,_roll)

