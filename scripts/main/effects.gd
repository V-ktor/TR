extends Node


class Effect:
	var name := ""
	var duration := 0
	var detrimental := false
	var beneficial := false
	var permament := false				# automatically remove after battles if false
	var failed := false					# applying this effect failed
	var owner : Characters.Character

class AreaEffect:
	var name := ""
	var duration := 0
	var failed := false					# applying this effect failed
	var caster : Characters.Character
	var game_state


# beneficial status effects #

class HealthPotion:
	extends Effect
	var amount := 0
	
	func _init(_actor,args={}):
		name = "healing"
		beneficial = true
		if !args.has("amount"):
			args.amount = 5
		if !args.has("duration"):
			args.duration = 3
		duration = args.duration
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		var total_dam = amount*duration
		duration = args.duration
		amount = int(args.amount+total_dam/duration)
		return true
	
	func on_turn():
		owner.health += amount
		if owner.health>owner.max_health:
			owner.health = owner.max_health
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class MagicShield:
	extends Effect
	var amount := 0
	
	func _init(_actor,args={}):
		name = "magic_shield"
		beneficial = true
		if !args.has("amount"):
			args.amount = 6
		if !args.has("duration"):
			args.duration = 3
		duration = args.duration
	
	func on_apply():
		owner.shielding += amount
		Main.add_text(tr("STATUS_MAGIC_SHIELD").format({"actor":owner.get_name()}))
	
	func on_remove():
		owner.shielding = int(max(owner.shielding-amount, 0))
		Main.add_text(tr("STATUS_MAGIC_SHIELD_STOP").format({"actor":owner.get_name()}))
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		owner.shielding -= amount
		duration = int((args.duration+duration)/2)
		amount = int(args.amount+amount)
		owner.shielding = int(max(owner.shielding+amount, 0))
		return true
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class FireShield:
	extends Effect
	var amount := 0
	
	func _init(_actor,args={}):
		name = "fire_shield"
		beneficial = true
		if !args.has("amount"):
			args.amount = 4
		if !args.has("duration"):
			args.duration = 4
		duration = args.duration
	
	func on_apply():
		Main.add_text(tr("STATUS_FIRE_SHIELD").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_FIRE_SHIELD_STOP").format({"actor":owner.get_name()}))
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		duration = int((args.duration+duration)/2)
		amount = int((args.amount+amount)/2)
		return true
	
	func on_attacked(attacker,action):
		if action.tool_used.range!="melee":
			return
		Main.add_text(tr("FIRE_SHIELD_BURN").format({"actor":owner.get_name(),"target":attacker.get_name()}))
		attacker.damaged(amount)
		print(owner.get_name()+"->"+attacker.get_name()+" damage: "+str(amount))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Riposte:
	extends Effect
	
	func _init(_actor,_args={}):
		name = "riposte"
		beneficial = true
	
	func on_turn():
		owner.remove_status(name)

class Hidden:
	extends Effect
	
	func _init(_actor,_args={}):
		name = "hidden"
		beneficial = true
	
	func on_apply():
		Main.add_text(tr("STATUS_HIDDEN").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_HIDDEN_STOP").format({"actor":owner.get_name()}))
	
	func on_damaged(_damage):
		owner.remove_status(name)
	
	func on_attack(_target):
		owner.remove_status(name)


# detrimental status effects #

class CounterAttack:
	extends Effect
	var stats_inc := {}
	var armor_inc := 0
	
	func _init(_actor,args={}):
		name = "counter_attack"
		detrimental = true
		if args.has("stats_inc"):
			stats_inc = args.stats_inc
		if args.has("armor_inc"):
			armor_inc = args.armor_inc
	
	func on_apply():
		for s in stats_inc.keys():
			owner.stats[s] += stats_inc[s]
		owner.armor += armor_inc
	
	func on_remove():
		for s in stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
		owner.armor -= armor_inc
	
	func on_damaged(_damage):
		owner.remove_status(name)
	
	func on_turn():
		owner.remove_status(name)

class Distracted:
	extends Effect
	
	func _init(_actor,_args={}):
		name = "distracted"
		detrimental = true
	
	func on_apply():
		Main.add_text(tr("STATUS_DISTRACTED").format({"actor":owner.get_name()}))
	
	func on_damaged(_damage):
		owner.remove_status(name)
	
	func on_turn():
		owner.remove_status(name)

class Stunned:
	extends Effect
	
	func _init(_actor,_args={}):
		name = "stunned"
		detrimental = true
	
	func on_apply():
		Main.add_text(tr("STATUS_STUNNED").format({"actor":owner.get_name()}))
	
	func on_damaged(_damage):
		owner.remove_status(name)
	
	func on_turn():
		owner.remove_status(name)

class Bleeding:
	extends Effect
	var amount := 0
	
	func _init(_actor,args={}):
		name = "bleeding"
		detrimental = true
		if !args.has("amount"):
			args.amount = 1
		if !args.has("duration"):
			args.duration = 5
		duration = args.duration
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		var total_dam = amount*duration
		duration = int(max(duration, args.duration))
		amount = int(args.amount*args.duration/duration+total_dam/duration)
		return true
	
	func on_apply():
		Main.add_text(tr("STATUS_BLEEDING").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_BLEEDING_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		owner.damaged(amount)
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Poisoned:
	extends Effect
	var amount := 0
	var stats_inc := {}
	
	func _init(actor,args={}):
		name = "poisoned"
		detrimental = true
		if !args.has("amount"):
			args.amount = 1
		if !args.has("duration"):
			args.duration = 5
		if args.has("stats_inc"):
			stats_inc = args.stats_inc
		duration = args.duration
		if "poison_resistance" in actor.traits:
			Main.add_text(tr("STATUS_POISON_RESISTED").format({"actor":actor}))
			failed = true
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		var total_dam = amount*duration
		duration = int(max(duration, args.duration))
		amount = int(args.amount*args.duration/duration+total_dam/duration)
		if args.has("stats_inc"):
			for s in args.stats_inc.keys():
				stats_inc[s] += args.stats_inc[s]
				owner.stats[s] += args.stats_inc[s]
		return true
	
	func on_apply():
		for s in stats_inc.keys():
			owner.stats[s] += stats_inc[s]
		Main.add_text(tr("STATUS_POISONED").format({"actor":owner.get_name()}))
	
	func on_remove():
		for s in stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
		Main.add_text(tr("STATUS_POISONED_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		owner.damaged(amount)
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Burning:
	extends Effect
	var amount := 0
	
	func _init(_actor,args={}):
		name = "burning"
		detrimental = true
		if !args.has("amount"):
			args.amount = 1
		if !args.has("duration"):
			args.duration = 2
		duration = args.duration
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		var total_dam = amount*duration
		duration = int(max(duration, args.duration))
		amount = int(args.amount*args.duration/duration+total_dam/duration)
		return true
	
	func on_apply():
		Main.add_text(tr("STATUS_BURNING").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_BURNING_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		owner.damaged(amount)
		duration -= 1
		if duration<=0:
			owner.remove_status(name)


class Confused:
	extends Effect
	
	func _init(_actor,_args={}):
		name = "confused"
	
	func on_apply():
		Main.add_text(tr("STATUS_CONFUSED").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_CONFUSED_STOP").format({"actor":owner.get_name()}))
	
	func on_damaged(damage):
		if damage>=1 && randf()<0.5:
			owner.remove_status(name)


class Corrosion:
	extends Effect
	var armor_inc := 0
	
	func _init(_actor,args={}):
		name = "corrosion"
		detrimental = true
		if args.has("armor_inc"):
			armor_inc = args.armor_inc
		duration = args.duration
	
	func merge(args={}):
		if !args.has("armor_inc") || !args.has("duration"):
			return false
		duration = int((duration+args.duration)/2)
		armor_inc += args.armor_inc
		owner.armor += args.armor_inc
		return true
	
	func on_apply():
		owner.armor += armor_inc
		Main.add_text(tr("STATUS_CORROSION").format({"actor":owner.get_name()}))
	
	func on_remove():
		owner.armor -= armor_inc
		Main.add_text(tr("STATUS_CORROSION_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Frozen:
	extends Effect
	var stats_inc := {}
	
	func _init(_actor,args={}):
		name = "frozen"
		detrimental = true
		if args.has("stats_inc"):
			stats_inc = args.stats_inc
		duration = args.duration
	
	func merge(args={}):
		if !args.has("stats_inc") || !args.has("duration"):
			return false
		duration = int((duration+args.duration)/2)
		for s in args.stats_inc.keys():
			stats_inc[s] += args.stats_inc[s]
			owner.stats[s] += args.stats_inc[s]
		return true
	
	func on_apply():
		for s in stats_inc.keys():
			owner.stats[s] += stats_inc[s]
		Main.add_text(tr("STATUS_FROZEN").format({"actor":owner.get_name()}))
	
	func on_remove():
		for s in stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
		Main.add_text(tr("STATUS_FROZEN_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Blind:
	extends Effect
	var stats_inc := {}
	
	func _init(_actor,args={}):
		name = "blind"
		detrimental = true
		if args.has("stats_inc"):
			stats_inc = args.stats_inc
		duration = args.duration
	
	func merge(args={}):
		if !args.has("stats_inc") || !args.has("duration"):
			return false
		duration = int(max(duration, args.duration))
		for s in args.stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
			stats_inc[s] = int((stats_inc[s]+args.stats_inc[s])/2)
			owner.stats[s] += stats_inc[s]
		return true
	
	func on_apply():
		for s in stats_inc.keys():
			owner.stats[s] += stats_inc[s]
		Main.add_text(tr("STATUS_BLIND").format({"actor":owner.get_name()}))
	
	func on_remove():
		for s in stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
		Main.add_text(tr("STATUS_BLIND_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Pinned:
	extends Effect
	var stats_inc := {}
	
	func _init(_actor,args={}):
		name = "pinned"
		detrimental = true
		if args.has("stats_inc"):
			stats_inc = args.stats_inc
		duration = args.duration
	
	func on_apply():
		for s in stats_inc.keys():
			owner.stats[s] += stats_inc[s]
		Main.add_text(tr("STATUS_PINNED").format({"actor":owner.get_name()}))
	
	func on_remove():
		for s in stats_inc.keys():
			owner.stats[s] -= stats_inc[s]
		Main.add_text(tr("STATUS_PINNED_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)

class Wet:
	extends Effect
	var amount := 1
	
	func _init(_actor,args={}):
		name = "wet"
		detrimental = true
		if args.has("amount"):
			amount = args.amount
		duration = args.duration
	
	func merge(args={}):
		if !args.has("amount") || !args.has("duration"):
			return false
		duration = int(max(duration, args.duration))
		amount += args.amount
		return true
	
	func on_apply():
		Main.add_text(tr("STATUS_WET").format({"actor":owner.get_name()}))
	
	func on_remove():
		Main.add_text(tr("STATUS_WET_STOP").format({"actor":owner.get_name()}))
	
	func on_turn():
		duration -= 1
		if duration<=0:
			owner.remove_status(name)



# area effects #

class PoisonousClouds:
	extends AreaEffect
	var damage := 0
	
	func _init(_game_state,actor,args={}):
		name = "poisonous_clouds"
		game_state = _game_state
		caster = actor
		if args.has("damage"):
			damage = args.damage
		if args.has("duration"):
			duration = args.duration
	
	func on_apply():
		Main.add_text(tr("AREA_POISONOUS_CLOUDS"))
	
	func on_remove():
		Main.add_text(tr("AREA_POISONOUS_CLOUDS_STOP"))
	
	func on_turn():
		for actor in game_state.player+game_state.enemy:
			actor.damaged(damage)
		duration -= 1
		if duration<=0:
			game_state.remove_area_effect(self)

class WildFire:
	extends AreaEffect
	var damage := 0
	
	func _init(_game_state,actor,args={}):
		name = "wild_fire"
		game_state = _game_state
		caster = actor
		if args.has("damage"):
			damage = args.damage
		else:
			damage = 6
		if args.has("duration"):
			duration = args.duration
		else:
			duration = 3
	
	func on_apply():
		Main.add_text(tr("AREA_WILD_FIRE"))
	
	func on_remove():
		Main.add_text(tr("AREA_WILD_FIRE_STOP"))
	
	func on_turn():
		var set := []
		if caster in game_state.player:
			set += game_state.enemy
		if caster in game_state.enemy:
			set += game_state.ally
		for actor in set:
			actor.add_status(Burning,{"duration":3,"amount":ceil(damage/float(duration+1))})
		duration -= 1
		if duration<=0:
			game_state.remove_area_effect(self)
