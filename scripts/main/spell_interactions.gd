extends Node


func trigger_spell(type: String, action, actor, target, damage) -> float:
	if has_method("trigger_"+type):
		return call("trigger_"+type, action, actor, target, damage)
	return 1.0


func trigger_fire(_action, actor, target, damage) -> float:
	if target.has_status("frozen"):
		Main.add_text(tr("FIRE_INTERACTION_FROZEN").format({"target":target.get_name(),"actor":actor.get_name()}))
		target.remove_status("frozen")
		target.add_status(Effects.Wet,{"duration":5,"amount":1})
		return 0.5
	elif target.has_status("wet"):
		Main.add_text(tr("FIRE_INTERACTION_WET").format({"target":target.get_name()}))
		target.remove_status("wet")
		target.add_status(Effects.Stunned)
		return 1.5
	else:
		var dam_scale:= 0.5
		var duration:= 3
		if "liquid" in target.traits && target.has_status("burning"):
			target.add_status(Effects.Boiling,{"duration":duration,"amount":1})
			dam_scale *= 2.0
		target.add_status(Effects.Burning,{"duration":duration,"amount":ceil(dam_scale*damage/float(duration+1))})
		return dam_scale

func trigger_ice(_action, _actor, target, _damage) -> float:
	if target.has_status("burning"):
		Main.add_text(tr("ICE_INTERACTION_BURNING").format({"target":target.get_name()}))
		target.remove_status("burning")
		target.add_status("wet",{"duration":5,"amount":1})
		return 0.5
	elif target.has_status("wet"):
		Main.add_text(tr("ICE_INTERACTION_WET").format({"target":target.get_name()}))
		target.remove_status("wet")
		target.add_status(Effects.Frozen,{"duration":4,"stats_inc":{"agility":-4,"dexterity":-4}})
		target.add_status(Effects.Pinned,{"duration":2,"stats_inc":{"agility":-4}})
		return 1.5
	else:
		if "liquid" in target.traits && target.has_status("frozen"):
			Main.add_text(tr("COMBAT_FROZEN_SOLID").format({"target":target.get_name()}))
			target.add_status(Effects.Stunned)
		target.add_status(Effects.Frozen,{"duration":3,"stats_inc":{"agility":-4,"dexterity":-4}})
	return 1.0

func trigger_wind(_action, _actor, target, _damage) -> float:
	if "flying" in target.traits:
		target.add_status(Effects.Pinned,{"duration":2,"stats_inc":{"agility":-6}})
		return 1.5
	
	return 0.25

func trigger_earth(_action, _actor, target, _damage) -> float:
	var multiplier := 1.0
	if "liquid" in target.traits:
		Main.add_text(tr("COMBAT_LITTLE_IMPACT_LIQUID_BODY").format({"target":target.get_name()}))
		multiplier = 0.5
	if target.has_status("bleeding"):
		Main.add_text(tr("COMBAT_WOUNDS_DEEPEN").format({"target":target.get_name()}))
		target.add_status(Effects.Bleeding,{"value":1,"duration":target.status.bleeding.duration})
	
	return multiplier

func trigger_nature(_action, _actor, _target, _damage) -> float:
	
	return 1.0

func trigger_light(_action, _actor, _target, _damage) -> float:
	
	return 1.0

func trigger_arcane(_action, _actor, _target, _damage) -> float:
	
	return 1.0

func trigger_blood(_action, _actor, target, _damage) -> float:
	if "liquid" in target.traits:
		Main.add_text(tr("COMBAT_LITTLE_IMPACT_LIQUID_BODY").format({"target":target.get_name()}))
		return 0.5
	
	return 1.0


func trigger_restoration(_action, _actor, _target, _damage) -> float:
	
	return 1.0

func trigger_shielding(_action, _actor, _target, _damage) -> float:
	
	return 1.0

