extends "res://data/spells/base.gd"

const ACTION = {
	"name":"freeze",
	"text":"CAST_FREEZE",
	"target":{},
	"requirements":{"proficiency":{"ice_magic":1},"knowledge":"freeze"},
	"result":{6:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"ice":1},
	"min_dam":4,
	"max_dam":8,
	"dam_scale":2.0,
	"ticks":3,
	"limit":6
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll,"freeze")
	print("damage: "+str(damage))
	if action.target.has_status("burning"):
		Main.add_text(tr("COMBAT_FREEZE_BURNING").format({"target":action.target.get_name()}))
		action.target.remove_status("burning")
		action.target.add_status("wet",{"duration":5,"amount":1})
# warning-ignore:integer_division
		action.target.damaged(int(damage/2))
	elif action.target.has_status("wet"):
		Main.add_text(tr("COMBAT_FREEZE_WET").format({"target":action.target.get_name()}))
		action.target.damaged(int(min(1.0+action.target.status.wet.amount/2.0, 3.0)*damage))
		action.target.remove_status("wet")
		action.target.add_status(Effects.Frozen,{"duration":4,"stats_inc":{"agility":-4,"dexterity":-4}})
		action.target.add_status(Effects.Pinned,{"duration":2,"stats_inc":{"agility":-4}})
	else:
		Main.add_text(tr("COMBAT_FREEZE").format({"target":action.target.get_name()}))
		action.target.damaged(damage)
		if "liquid" in action.target.traits && action.target.has_status("frozen"):
			Main.add_text(tr("COMBAT_FROZEN_SOLID").format({"target":action.target.get_name()}))
			action.target.add_status(Effects.Stunned)
		action.target.add_status(Effects.Frozen,{"duration":3,"stats_inc":{"agility":-4,"dexterity":-4}})
	action.ref.end_turn()

func _init():
	name = ACTION.name
