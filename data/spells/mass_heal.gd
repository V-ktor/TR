extends "res://data/spells/base.gd"

const ACTION = {
	"name":"mass_heal",
	"text":"CAST_MASS_HEAL",
	"requirements":{"proficiency":{"restoration_magic":2,"light_magic":2},"knowledge":"mass_heal"},
	"result":{7:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"intelligence",
	"runes":{"restoration":1,"light":1},
	"min_dam":3,
	"max_dam":6,
	"dam_scale":0.33,
	"ticks":4,
	"limit":7
}

func cast(actor,action,roll):
	var set := get_enemies(actor,action.ref)
	prepare_spell(actor,action,roll,"mass_heal")
	Main.add_text(tr("COMBAT_MASS_HEAL").format({"actor":actor.get_name()}))
	for target in set:
		if target.has_status("bleeding") || target.has_status("poisoned"):
			Main.add_text(tr("COMBAT_CLEANSE").format({"target":target.get_name()}))
			target.remove_status("bleeding")
			target.remove_status("poisoned")
		else:
			var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
			target.heal(damage)
			Main.add_text(tr("COMBAT_HEAL").format({"target":target.get_name()}))
	action.ref.end_turn()

func _init():
	name = ACTION.name
