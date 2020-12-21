extends "res://data/scripts/base_battle.gd"

var ID := "hunt_down_bandits"
var location : Map.Location
var quest : Quests.Quest


func init(_location,_quest):
	var num_enemy := 3
	var type := ["bandit_blade","bandit_mace","bandit_hunter"]
	location = Map.get_location(_location)
	quest = _quest
	player.resize(Characters.party.size())
	enemy.resize(num_enemy)
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
	for i in range(num_enemy):
		enemy[i] = Characters.create_enemy(type[randi()%type.size()],int(max(quest.data.level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)),char(KEY_A+i))
	
	Main.update_landscape(location.landscape)
	Main.add_text(tr("HUNT_DOWN_BANDITS_INTRO"))
	
	connect("battle_won",self,"won_battle")
	init_battle()
	Main.set_title(tr("PLAINS"))


# victory #

func won_battle(victory):
	if victory:
		var city_name = Map.get_location(quest.data.city).name
		quest.status = "done"
		quest.update(tr("HUNT_DOWN_BANDITS_VICTORY").format({"city":city_name}))
		quest.location = quest.data.city
		Events.register_event({"type":"enter_city","location":quest.data.city,"script":"res://data/events/jobs/hunt_down_bandits_return.gd","quest":quest.ID})
		Main.add_text("\n"+tr("HUNT_DOWN_BANDITS_VICTORY").format({"city":city_name}))
		Main.add_action(Game.Action.new(tr("LEAVE_CAREFULLY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("PLAINS_RETREAT"))
		for c in player:
			c.stressed()
		Main.add_action(Game.Action.new(tr("LEAVE_HASTILY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
		Game.fail_quest(quest)

# leave #

func leave(_actor,_action,_roll):
	Game.leave_location()

