extends "res://data/scripts/base_battle.gd"

var ID := "take_care_of_wolfs"
var location : Map.Location
var quest : Quests.Quest


func init(_location,_quest):
	var num_enemy := 3
	var type := "wolf"
	location = _location
	quest = _quest
	player.resize(Characters.party.size())
	enemy.resize(num_enemy)
	for i in range(player.size()):
		player[i] = Characters.characters[Characters.party[i]]
	for i in range(num_enemy):
		enemy[i] = Characters.create_enemy(type,int(max(quest.data.level*rand_range(0.8,1.1)+rand_range(-1.5,1.5),1)))
	
	connect("battle_won",self,"won_battle")
	init_battle()
	Main.update_landscape(location.landscape)
	Main.set_title(tr("WOODS"))


# battle ended #

func won_battle(victory):
	if victory:
		var city_name = Map.get_location(quest.data.city).name
		quest.status = "done"
		quest.update(tr("TAKE_CARE_OF_WOLFS_VICTORY").format({"city":city_name}))
		quest.location = quest.data.city
		Events.register_event({"type":"enter_city","location":quest.data.city,"script":"res://data/events/jobs/take_care_of_wolfs_return.gd","quest":quest.ID})
		Main.add_text("\n"+tr("TAKE_CARE_OF_WOLFS_VICTORY").format({"city":city_name}))
		Main.add_action(Game.Action.new(tr("LEAVE_CAREFULLY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
	else:
		Main.add_text("\n"+tr("WOODS_RETREAT"))
		for c in player:
			c.stressed()
		Main.add_action(Game.Action.new(tr("LEAVE_HASTILY"),"location_general",{0:{"method":"leave","grade":1}},"","",3))
		Game.fail_quest(quest)

# leave #

func leave(_actor,_action,_roll):
	Game.leave_location()
