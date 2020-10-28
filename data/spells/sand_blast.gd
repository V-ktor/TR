extends "res://data/spells/base.gd"

const ACTION = {
	"name":"sand_blast",
	"text":"CAST_SAND_BLAST",
	"target":{},
	"requirements":{"proficiency":{"earth_magic":1},"knowledge":"sand_blast"},
	"result":{19:{"method":"cast_blinding","grade":2},9:{"method":"cast","grade":1},4:{"method":"missed","grade":0},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"earth":1},
	"min_dam":10,
	"max_dam":16,
	"dam_scale":2.0,
	"ticks":3,
	"limit":9
}

func cast_blinding(actor,action,roll):
	cast(actor,action,roll)
	action.target.add_status(Effects.Blind,{"duration":2,"stats_inc":{"agility":-4,"cunning":-4}})

func cast(actor,action,roll):
	var dam_scale := 1.0
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale*rand_range(0.8,1.2))
	prepare_spell(actor,action,roll,"sand_blast")
	if "liquid" in action.target.traits:
		Main.add_text(tr("COMBAT_SAND_BLAST").format({"actor":actor.get_name(),"target":action.target.get_name()}))
		Main.add_text(tr("COMBAT_LITTLE_IMPACT_LIQUID_BODY").format({"target":action.target.get_name()}))
		dam_scale = 0.5
	else:
		Main.add_text(tr("COMBAT_SAND_BLAST").format({"actor":actor.get_name(),"target":action.target.get_name()}))
	action.target.damaged(int(dam_scale*damage))
	if action.target.has_status("bleeding"):
		Main.add_text(tr("COMBAT_SAND_BLAST_BLEEDING").format({"target":action.target.get_name()}))
		action.target.add_status(Effects.Bleeding,{"value":1,"duration":action.target.status.bleeding.duration})
	action.ref.end_turn()

func _init():
	name = ACTION.name
