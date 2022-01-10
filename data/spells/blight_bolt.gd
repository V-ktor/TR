extends "res://data/spells/base.gd"

const ACTION = {
	"name":"combustion",
	"text":"CAST_BLIGHT_BOLT",
	"target":{},
	"requirements":{"proficiency":{"blood_magic":1,"arcane_magic":1},"knowledge":"blight_bolt"},
	"result":{9:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"cunning",
	"secondary":"intelligence",
	"runes":{"blood":1,"arcane":1},
	"min_dam":14,
	"max_dam":18,
	"dam_scale":2.5,
	"ticks":3,
	"limit":9
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	var duration := 3
	var stat_inc := 2
	prepare_spell(actor,action,roll,"blight_bolt")
	Main.add_text(tr("COMBAT_BLIGHT_BOLT").format({"target":action.target.get_name()}))
	print("damage: "+str(damage))
	
	var dam_scale := SpellInteractions.trigger_spell("blood", action, actor, action.target, damage)
	damage = int(dam_scale*damage)
	action.target.damaged(damage)
	action.target.add_status(Effects.Diseased,{"duration":duration,"amount":2,"stat_inc":{"strength":-stat_inc, "constitution":-stat_inc,"agility":-stat_inc, "dexterity":-stat_inc, "intelligence":-stat_inc, "wisdom":-stat_inc, "cunning":-stat_inc, "charisma":-stat_inc}})
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
