extends Node

var location : String


func init(_location,mission):
	var reward_str := ""
	var city = Map.get_location(_location)
	location = _location
	Main.set_title(tr("DELIVER_PACKAGE"))
	Main.update_landscape(city.landscape)
	for i in range(mission.reward.size()-1):
		var k = mission.reward.keys()[i]
		reward_str += str(mission.reward[k])+"x "+tr(k.to_upper())+", "
		Items.add_items(k,mission.reward[k])
	var k = mission.reward.keys()[mission.reward.size()-1]
	reward_str += tr("AND")+" "+str(mission.reward[k])+"x "+tr(k.to_upper())
	if reward_str=="":
		Main.add_text(tr("COMPLETE_JOB"))
	else:
		Main.add_text(tr("COMPLETE_JOB_REWARD").format({"reward":reward_str}))
	Main.add_action(Game.Action.new(tr("LEAVE"),self,{0:{"method":"leave","grade":1}},"","",3))
	Game.finish_mission(mission)

func leave(_actor,_action,_roll):
	Game.enter_location(location)
