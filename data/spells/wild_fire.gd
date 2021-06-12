extends "res://data/spells/base.gd"

const ACTION = {
	"name":"wild_fire",
	"text":"CAST_WILD_FIRE",
	"requirements":{"proficiency":{"fire_magic":2,"arcane_magic":2},"knowledge":"wild_fire"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"fire":1,"arcane":1},
	"min_dam":4,
	"max_dam":8,
	"dam_scale":0.5,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll,"wild_fire")
	Main.add_text(tr("COMBAT_WILD_FIRE").format({"actor":actor.get_name()}))
	action.ref.add_area_effect(Effects.WildFire, actor, {"damage":damage, "duration":4})
	action.ref.end_turn()

func _init():
	name = ACTION.name
