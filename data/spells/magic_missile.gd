extends "res://data/spells/base.gd"

const ACTION = {
	"name":"magic_missile",
	"text":"CAST_MAGIC_MISISLE",
	"target":{},
	"requirements":{"proficiency":{"arcane_magic":1},"knowledge":"magic_missile"},
	"result":{20:{"method":"double_cast","grade":1},5:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"arcane":1},
	"min_dam":8,
	"max_dam":14,
	"dam_scale":2.0,
	"ticks":3,
	"limit":5
}

func double_cast(actor,action,roll):
	var target
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll,"magic_missile")
	if actor in action.ref.player:
		target = action.ref.enemy[randi()%action.ref.enemy.size()]
	else:
		target = action.ref.player[randi()%action.ref.player.size()]
	Main.add_text(tr("COMBAT_MAGIC_MISSILE_DOUBLE").format({"actor":actor.get_name(),"target":action.target.get_name(),"secondary_target":target.get_name()}))
	Main.add_text(tr("COMBAT_DAMAGED_PLURAL").format({"actors":action.target.get_name()+" "+tr("AND")+" "+target.get_name()}))
	action.target.damaged(damage)
	target.damaged(damage)
	action.ref.end_turn()

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll)
	Main.add_text(tr("COMBAT_MAGIC_MISSILE").format({"actor":actor.get_name(),"target":action.target.get_name()}))
	Main.add_text(tr("COMBAT_DAMAGED").format({"actor":action.target.get_name()}))
	action.target.damaged(damage)
	action.ref.end_turn()

func _init():
	name = ACTION.name
