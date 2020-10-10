extends "res://data/spells/base.gd"

const ACTION = {
	"name":"minor_heal",
	"text":"CAST_HEAL",
	"target":{"ally":true},
	"requirements":{"proficiency":{"restoration_magic":1},"knowledge":"minor_heal"},
	"result":{6:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"intelligence",
	"runes":{"restoration":1},
	"min_dam":4,
	"max_dam":8,
	"dam_scale":0.5,
	"ticks":3,
	"limit":6
}

func cast(actor,action,roll):
	prepare_spell(actor,action,roll)
	if action.target.has_status("bleeding") || action.target.has_status("poisoned"):
		Main.add_text(tr("COMBAT_CLEANSE").format({"target":action.target.get_name()}))
		action.target.remove_status("bleeding")
		action.target.remove_status("poisoned")
	else:
		var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
		print("damage: "+str(damage))
		action.target.heal(damage)
		Main.add_text(tr("COMBAT_HEAL").format({"target":action.target.get_name()}))
	action.ref.end_turn()

func _init():
	name = ACTION.name
