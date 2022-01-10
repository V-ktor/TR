extends "res://data/spells/base.gd"

const ACTION = {
	"name":"combustion",
	"text":"CAST_COMBUSTION",
	"target":{},
	"requirements":{"proficiency":{"fire_magic":1},"knowledge":"combustion"},
	"result":{8:{"method":"cast","grade":1},4:{"method":"missed","grade":0},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"fire":1},
	"min_dam":12,
	"max_dam":16,
	"dam_scale":2.0,
	"ticks":3,
	"limit":8
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll,"combustion")
	Main.add_text(tr("COMBAT_COMBUSTION").format({"target":action.target.get_name()}))
	print("damage: "+str(damage))
	
	var damage_scale := SpellInteractions.trigger_spell("fire", action, actor, action.target, damage)
	damage = int(damage*damage_scale)
	action.target.damaged(damage)
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
