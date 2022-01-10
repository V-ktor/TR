extends "res://data/spells/base.gd"

const ACTION = {
	"name":"cleansing_wind",
	"text":"CAST_CLEANSING_WIND",
	"requirements":{"proficiency":{"wind_magic":1},"knowledge":"cleansing_wind"},
	"result":{9:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"cunning",
	"runes":{"wind":1},
	"min_dam":2,
	"max_dam":8,
	"dam_scale":1.0,
	"ticks":3,
	"limit":9
}

func cast(actor,action,roll):
	var set := []
	prepare_spell(actor,action,roll,"cleansing_wind")
	Main.add_text(tr("COMBAT_CLEANSING_WIND"))
	if actor in action.ref.player:
		set = action.ref.enemy
	elif actor in action.ref.enemy:
		set = action.ref.player
	for target in set:
		var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
		var dam_scale := SpellInteractions.trigger_spell("wind", action, actor, action.target, damage)
		damage = int(dam_scale*damage)
		target.damaged(damage)
	action.ref.clear_area_effects()
	action.ref.end_turn()

func _init():
	name = ACTION.name
