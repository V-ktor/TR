extends "res://data/spells/base.gd"

const ACTION = {
	"name":"combustion",
	"text":"CAST_BLOOD_BOIL",
	"target":{},
	"requirements":{"proficiency":{"blood_magic":1,"fire_magic":1},"knowledge":"blood_boil"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"cunning",
	"secondary":"intelligence",
	"runes":{"blood":1,"fire":1},
	"min_dam":16,
	"max_dam":20,
	"dam_scale":3.0,
	"ticks":3,
	"limit":8
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	var duration := 4
	prepare_spell(actor,action,roll,"blood_boil")
	Main.add_text(tr("COMBAT_BLOOD_BOIL").format({"target":action.target.get_name()}))
	print("damage: "+str(damage))
	
	var dam_scale := SpellInteractions.trigger_spell("fire", action, actor, action.target, damage)
	damage = int(dam_scale*damage)
	action.target.damaged(damage)
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
