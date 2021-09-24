extends "res://data/spells/base.gd"

const ACTION = {
	"name":"blood_spray",
	"text":"CAST_BLOOD_SPRAY",
	"target":{},
	"requirements":{"proficiency":{"blood_magic":1},"knowledge":"blood_spray"},
	"result":{18:{"method":"cast_disease","grade":2},8:{"method":"cast","grade":1},4:{"method":"missed","grade":0},0:{"method":"fail","grade":0}},
	"primary":"cunning",
	"secondary":"intelligence",
	"runes":{"blood":1},
	"min_dam":12,
	"max_dam":18,
	"dam_scale":2.0,
	"ticks":3,
	"limit":8
}

func cast_disease(actor,action,roll):
	cast(actor,action,roll)
	action.target.add_status(Effects.Diseased,{"value":1, "duration":4})

func cast(actor,action,roll):
	var dam_scale := 1.0
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale*rand_range(0.8,1.2))
	prepare_spell(actor,action,roll,"blood_spray")
	if "liquid" in action.target.traits:
		Main.add_text(tr("COMBAT_BLOOD_SPRAY").format({"actor":actor.get_name(),"target":action.target.get_name()}))
		Main.add_text(tr("COMBAT_LITTLE_IMPACT_LIQUID_BODY").format({"target":action.target.get_name()}))
		dam_scale = 0.25
	else:
		Main.add_text(tr("COMBAT_BLOOD_SPRAY").format({"actor":actor.get_name(),"target":action.target.get_name()}))
	action.target.damaged(int(dam_scale*damage))
	action.ref.end_turn()

func _init():
	name = ACTION.name
