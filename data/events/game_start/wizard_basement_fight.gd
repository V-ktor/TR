extends "res://data/scripts/base_battle.gd"

var ID := "battle_wizard_basement"
var location : Map.Location
var parent_script


func init(_parent_script):
	var mean_level := 0.0
	var type := "small_imp"
	parent_script = _parent_script
	Main.add_text("\n"+tr("WIZARD_BASEMENT_LAB_IMP_ATTACK"))
	player.resize(Characters.party.size())
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
		mean_level += player[i].level
	mean_level /= player.size()
	enemy = [Characters.create_enemy(type,int(max(mean_level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)))]
	
	# Add additional actions for the combat here.
	ACTIONS += []
	
	connect("battle_won",self,"won_battle")
	init_battle()


# victory #

func won_battle(victory):
	if victory:
		Main.add_text("\n"+tr("WIZARD_IMP_DEFEATED"))
		Main.add_action(Game.Action.new(tr("ACTION_CONTINUE"),parent_script,{0:{"method":"lab_imp_defeated","grade":1}},"","",3))
	else:
		Main.add_action(Game.Action.new(tr("SAY_SORRY"),parent_script,{0:{"method":"imp_access_forbidden","grade":1}},"","",2))

# leave #

func leave(_actor,_action,_roll):
	parent_script.goto_crossroads(_actor,_action,_roll)

