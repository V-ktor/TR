extends "res://data/spells/base.gd"

const ACTION = {
	"name":"fire_shield",
	"text":"CAST_FIRE_SHIELD",
	"target":{"self":true},
	"requirements":{"proficiency":{"shielding_magic":2,"fire_magic":2},"knowledge":"fire_shield"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"intelligence",
	"runes":{"shielding":1,"fire":1},
	"min_dam":6,
	"max_dam":9,
	"dam_scale":0.5,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	prepare_spell(actor,action,roll,"fire_shield")
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	print("damage: "+str(damage))
	Main.add_text(tr("COMBAT_FIRE_SHIELD").format({"target":action.target.get_name()}))
	action.target.add_status(Effects.FireShield,{"duration":4,"amount":damage})
	action.ref.end_turn()

func _init():
	name = ACTION.name
