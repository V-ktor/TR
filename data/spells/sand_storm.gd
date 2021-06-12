extends "res://data/spells/base.gd"

const ACTION = {
	"name":"sand_storm",
	"text":"CAST_SAND_STORM",
	"requirements":{"proficiency":{"earth_magic":2,"wind_magic":2},"knowledge":"sand_storm"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"earth":1,"wind":1},
	"min_dam":6,
	"max_dam":12,
	"dam_scale":1.0,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	var set := get_enemies(actor,action.ref)
	prepare_spell(actor,action,roll,"sand_blast")
	Main.add_text(tr("COMBAT_SAND_STORM").format({"actor":actor.get_name()}))
	for target in set:
		var dam_scale := 1.0
		var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale*rand_range(0.8,1.2))
		if "liquid" in target.traits:
			Main.add_text(tr("COMBAT_LITTLE_IMPACT_LIQUID_BODY").format({"target":target.get_name()}))
			dam_scale = 0.5
		target.damaged(int(dam_scale*damage))
		target.add_status(Effects.Blind,{"duration":2,"stats_inc":{"agility":-5,"cunning":-5}})
	action.ref.end_turn()

func _init():
	name = ACTION.name
