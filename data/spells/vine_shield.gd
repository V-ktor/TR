extends "res://data/spells/base.gd"

const ACTION = {
	"name":"vine_shield",
	"text":"CAST_VINE_SHIELD",
	"target":{"self":true},
	"requirements":{"proficiency":{"shielding_magic":2,"nature_magic":2},"knowledge":"vine_shield"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"intelligence",
	"runes":{"shielding":1,"nature":1},
	"min_dam":6,
	"max_dam":10,
	"dam_scale":0.67,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	prepare_spell(actor,action,roll,"vine_shield")
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	Main.add_text(tr("COMBAT_VINE_SHIELD").format({"target":action.target.get_name()}))
	action.target.add_status(Effects.VineShield,{"duration":5,"amount":damage})
	action.ref.end_turn()

func _init():
	name = ACTION.name
