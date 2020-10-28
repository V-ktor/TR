extends "res://data/spells/base.gd"

const ACTION = {
	"name":"flash",
	"text":"CAST_FLASH",
	"target":{},
	"requirements":{"proficiency":{"light_magic":1},"knowledge":"flash"},
	"result":{5:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"wisdom",
	"runes":{"light":1},
	"min_dam":1,
	"max_dam":2,
	"dam_scale":0.5,
	"ticks":3,
	"limit":5
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll,"flash")
	print("damage: "+str(damage))
	action.target.damaged(damage)
	Main.add_text(tr("COMBAT_FLASH").format({"target":action.target.get_name()}))
	action.target.add_status(Effects.Blind,{"duration":5,"stats_inc":{"agility":-5,"cunning":-5}})
	action.target.add_status(Effects.Distracted)
	action.ref.end_turn()

func _init():
	name = ACTION.name
