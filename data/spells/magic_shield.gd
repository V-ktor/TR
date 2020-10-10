extends "res://data/spells/base.gd"

const ACTION = {
	"name":"magic_shield",
	"text":"CAST_MAGIC_SHIELD",
	"target":{"ally":true},
	"requirements":{"proficiency":{"shielding_magic":1},"knowledge":"magic_shield"},
	"result":{10:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"intelligence",
	"runes":{"shielding":1},
	"min_dam":6,
	"max_dam":10,
	"dam_scale":0.75,
	"ticks":3,
	"limit":10
}

func cast(actor,action,roll):
	prepare_spell(actor,action,roll)
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	print("damage: "+str(damage))
	Main.add_text(tr("COMBAT_MAGIC_SHIELD").format({"target":action.target.get_name()}))
	action.target.add_status(Effects.MagicShield,{"duration":3,"amount":damage})
	action.ref.end_turn()

func _init():
	name = ACTION.name
