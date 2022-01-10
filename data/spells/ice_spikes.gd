extends "res://data/spells/base.gd"

const ACTION = {
	"name":"ice_spikes",
	"text":"CAST_ICE_SPIKES",
	"target":{},
	"requirements":{"proficiency":{"ice_magic":2,"earth_magic":2},"knowledge":"ice_spikes"},
	"result":{8:{"method":"cast","grade":1},0:{"method":"fail","grade":0}},
	"primary":"cunning",
	"secondary":"intelligence",
	"runes":{"ice":1,"earth":1},
	"min_dam":10,
	"max_dam":20,
	"dam_scale":2.0,
	"ticks":4,
	"limit":8
}

func cast(actor,action,roll):
	var set := get_enemies(actor,action.ref)
	prepare_spell(actor,action,roll)
	Main.add_text(tr("COMBAT_ICE_SPIKES").format({"actor":actor.get_name()}))
	for target in set:
		var hit_roll := Game.do_roll(actor,"cunning","dexterity",-Game.get_offset(target,"agility","cunning"))
		if hit_roll<8:
			Main.add_text(tr("COMBAT_SPELL_MISSED").format({"actor":actor.get_name(),"target":target.get_name()}))
			continue
		var damage := get_damage(actor,action,roll,ACTION.min_dam,ACTION.max_dam,ACTION.dam_scale)
		Main.add_text(tr("COMBAT_DAMAGED").format({"actor":target.get_name()}))
		var dam_scale := SpellInteractions.trigger_spell("ice", action, actor, action.target, damage)
		damage = int(dam_scale*damage)
		target.damaged(damage)
		if hit_roll>14:
			target.add_status(Effects.Bleeding,{"value":1,"duration":3})
	
	action.ref.end_turn()

func _init():
	name = ACTION.name
