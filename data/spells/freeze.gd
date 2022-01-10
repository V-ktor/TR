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
	Main.add_text(tr("COMBAT_FREEZE").format({"target":action.target.get_name()}))
	print("damage: "+str(damage))
	
	var dam_scale := SpellInteractions.trigger_spell("ice", action, actor, action.target, damage)
	damage = int(dam_scale*damage)
	action.target.damaged(damage)
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
