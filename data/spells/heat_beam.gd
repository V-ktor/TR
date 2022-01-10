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
	Main.add_text(tr("COMBAT_HEAT_BEAM").format({"target":action.target.get_name()}))
	print("damage: "+str(damage))
	
	var dam_scale := SpellInteractions.trigger_spell("fire", action, actor, action.target, damage)
	damage = int(dam_scale*damage)
	action.target.damaged(damage)
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
