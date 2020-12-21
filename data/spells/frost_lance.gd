extends "res://data/spells/base.gd"

const ACTION = {
	"name":"frost_lance",
	"text":"CAST_FROST_LANCE",
	"target":{},
	"requirements":{"proficiency":{"arcane_magic":2,"ice_magic":2},"knowledge":"frost_lance"},
	"result":{9:{"method":"cast","grade":1},4:{"method":"missed","grade":0},0:{"method":"fail","grade":0}},
	"primary":"intelligence",
	"secondary":"cunning",
	"runes":{"arcane":1,"ice":1},
	"min_dam":10,
	"max_dam":25,
	"dam_scale":3.0,
	"ticks":4,
	"limit":9
}

func cast(actor,action,roll):
	var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
	prepare_spell(actor,action,roll)
	Main.add_text(tr("COMBAT_FROST_LANCE").format({"actor":actor.get_name(),"target":action.target.get_name()}))
	Main.add_text(tr("COMBAT_DAMAGED").format({"actor":action.target.get_name()}))
	action.target.damaged(damage)
	if action.target.has_status("burning"):
	    action.target.remove_status("burning")
		action.target.add_status("wet",{"duration":5,"amount":1})
    elif action.target.has_status("wet"):
        action.target.remove_status("wet")
        action.target.add_status(Effects.Frozen,{"duration":4,"stats_inc":{"agility":-4,"dexterity":-4}})
	else:
    	action.target.add_status(Effects.Frozen,{"duration":2,"stats_inc":{"agility":-3,"dexterity":-3}})
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
