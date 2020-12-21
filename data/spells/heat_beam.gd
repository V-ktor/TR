extends "res://data/spells/base.gd"

const ACTION = {
	"name":"heat_beam",
	"text":"CAST_HEAT_BEAM",
	"target":{},
	"requirements":{"proficiency":{"fire_magic":2,"light_magic":2},"knowledge":"heat_beam"},
	"result":{8:{"method":"cast","grade":1},4:{"method":"missed","grade":0},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"wisdom",
	"runes":{"fire":1,"light":1},
	"min_dam":15,
	"max_dam":20,
	"dam_scale":3.0,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	var duration := 3
	prepare_spell(actor,action,roll,"heat_beam")
	print("damage: "+str(damage))
	if action.target.has_status("frozen"):
		Main.add_text(tr("COMBAT_COMBUSTION_FROZEN").format({"target":action.target.get_name(),"actor":actor.get_name()}))
# warning-ignore:integer_division
		action.target.damaged(int(damage/4))
		action.target.remove_status("frozen")
		action.target.add_status(Effects.Wet,{"duration":5,"amount":1})
	elif action.target.has_status("wet"):
		Main.add_text(tr("COMBAT_COMBUSTION_WET").format({"target":action.target.get_name()}))
		action.target.damaged(int(min(action.target.status.wet.amount/4.0, 1.0)*damage))
		action.target.remove_status("wet")
		action.target.add_status(Effects.Stunned)
	else:
		var dam_scale := 1.0
		if "liquid" in action.target.traits && action.target.has_status("burning"):
			Main.add_text(tr("COMBAT_BOILING").format({"target":action.target.get_name()}))
			dam_scale = 2.0
		Main.add_text(tr("COMBAT_HEAT_BEAM").format({"target":action.target.get_name()}))
# warning-ignore:integer_division
		action.target.damaged(int(dam_scale*damage/(duration+1)))
		action.target.add_status(Effects.Burning,{"duration":duration,"amount":ceil(damage/float(duration+1))})
	action.ref.end_turn()

func _init():
	name = ACTION.name
