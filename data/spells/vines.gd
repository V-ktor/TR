extends "res://data/spells/base.gd"

const ACTION = {
	"name":"vines",
	"text":"CAST_VINES",
	"target":{"no_status":"pinned"},
	"requirements":{"proficiency":{"nature_magic":1},"knowledge":"vines"},
	"result":{6:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"wisdom",
	"secondary":"cunning",
	"target_primary":"agility",
	"target_secondary":"constitution",
	"runes":{"nature":1},
	"min_dam":10,
	"max_dam":14,
	"dam_scale":2.0,
	"ticks":4,
	"limit":6
}

func cast(actor,action,roll):
	var duration := 5
	prepare_spell(actor,action,roll,"vines")
	Main.add_text(tr("COMBAT_VINES").format({"target":action.target.get_name()}))
	
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	var dam_scale := SpellInteractions.trigger_spell("nature", action, actor, action.target, damage)
	damage = int(dam_scale*damage)
	
	action.target.damaged(damage)
	if "liquid" in action.target.traits:
		Main.add_text(tr("COMBAT_VINES_LIQUID_BODY").format({"target":action.target.get_name()}))
		# warning-ignore:integer_division
		action.target.damaged(int(damage/(duration+1)))
	else:
		# warning-ignore:integer_division
		action.target.damaged(int(damage/(duration+1)))
		# warning-ignore:integer_division
		action.target.add_status(Effects.Pinned,{"duration":int(duration/2),"stats_inc":{"agility":-6}})
	action.target.add_status(Effects.Poisoned,{"duration":duration,"amount":ceil(damage/float(duration+1))})
	action.ref.end_turn()

func _init():
	name = ACTION.name
