extends Node

const ATK_RESULT = {
	20:{"method":"critical_hit", "grade":3}, 
	9:{"method":"hit", "grade":1}, 
	0:{"method":"miss", "grade":0}
}
var ACTIONS = [
	{
		"name":"escape", 
		"text":"COMBAT_ESCAPE", 
		"requirements":{"stats":{"agility":12}}, 
		"target":{"no_status":"pinned", "optional":true}, 
		"result":{12:{"method":"escape", "grade":1}, 0:{"method":"fail_escape", "grade":0}}, 
		"primary":"agility", 
		"secondary":"", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"actor_override":{"worst_stat":"agility"}, 
		"ticks":6, 
		"limit":12
	}, 
	{
		"name":"stunning_blow", 
		"text":"STUNNING_BLOW_TARGET", 
		"requirements":{"weapon":"two-hander", "proficiency":{"two-hander":2}}, 
		"target":{"no_status":"stunned"}, 
		"result":{14:{"method":"stunning_blow", "grade":1}, 10:{"method":"hit", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"strength", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":10
	}, 
	{
		"name":"stunning_blow", 
		"text":"STUNNING_BLOW_TARGET", 
		"requirements":{"weapon":"mace", "proficiency":{"mace":2}}, 
		"target":{"no_status":"stunned"}, 
		"result":{14:{"method":"stunning_blow", "grade":1}, 10:{"method":"hit", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"strength", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":10
	}, 
	{
		"name":"cleave", 
		"text":"CLEAVE_TARGETS", 
		"requirements":{"weapon":"axe", "proficiency":{"axe":2}}, 
		"result":{14:{"method":"cleave", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"dexterity", 
		"secondary":"agility", 
		"stamina":1, 
		"ticks":4, 
		"limit":14
	}, 
	{
		"name":"riposte", 
		"text":"USE_RIPOSTE", 
		"requirements":{"weapon":"blade", "proficiency":{"blade":2}}, 
		"result":{8:{"method":"riposte", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"stamina":1, 
		"ticks":2, 
		"limit":8
	}, 
	{
		"name":"backstab", 
		"text":"BACKSTAB_TARGET", 
		"requirements":{"weapon":"knife", "proficiency":{"knife":2}}, 
		"target":{"status":"distracted"}, 
		"result":{9:{"method":"backstab", "grade":1}, 0:{"method":"fail_backstab", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":9
	}, 
	{
		"name":"backstab", 
		"text":"BACKSTAB_TARGET", 
		"requirements":{"weapon":"knife", "proficiency":{"knife":2}, "status":"hidden"}, 
		"target":{}, 
		"result":{9:{"method":"backstab", "grade":1}, 0:{"method":"fail_backstab", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":9
	}, 
	{
		"name":"backstab", 
		"text":"BACKSTAB_TARGET", 
		"requirements":{"weapon":"crossbow", "proficiency":{"crossbow":2}}, 
		"target":{"status":"distracted"}, 
		"result":{9:{"method":"backstab", "grade":1}, 0:{"method":"fail_backstab", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":9
	}, 
	{
		"name":"backstab", 
		"text":"BACKSTAB_TARGET", 
		"requirements":{"weapon":"crossbow", "proficiency":{"crossbow":2}, "status":"hidden"}, 
		"target":{}, 
		"result":{9:{"method":"backstab", "grade":1}, 0:{"method":"fail_backstab", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":9
	}, 
	{
		"name":"pin_down", 
		"text":"PIN_DOWN_TARGET", 
		"requirements":{"weapon":"bow", "proficiency":{"bow":2}}, 
		"target":{"no_status":"pinned"}, 
		"result":{12:{"method":"pin_down", "grade":1}, 8:{"method":"hit", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"agility", 
		"secondary":"dexterity", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"stamina":1, 
		"ticks":3, 
		"limit":8
	}, 
	{
		"name":"body_slam", 
		"text":"BODY_SLAM_TARGET", 
		"requirements":{"proficiency":{"unarmed":2}}, 
		"target":{}, 
		"result":{12:{"method":"body_slam", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"dexterity", 
		"secondary":"constitution", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"tool_override":{"name":"body", "use_stat":"constitution", "proficiency":"unarmed", "range":"unarmed"}, 
		"stamina":1, 
		"ticks":3, 
		"limit":12
	}, 
	{
		"name":"claws", 
		"text":"CLAWS_TARGET", 
		"requirements":{"traits":["claws"], "proficiency":{"unarmed":1}}, 
		"target":{}, 
		"result":{19:{"method":"claws_bleed", "grade":2}, 7:{"method":"claws", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"dexterity", 
		"secondary":"agility", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"tool_override":{"name":"claws", "use_stat":"strength", "proficiency":"unarmed", "range":"unarmed"}, 
		"ticks":3, 
		"limit":7
	}, 
	{
		"name":"headbutt", 
		"text":"HEADBUTT_TARGET", 
		"requirements":{"traits":["horns"], "proficiency":{"unarmed":1}}, 
		"target":{}, 
		"result":{19:{"method":"headbutt_confuse", "grade":2}, 7:{"method":"headbutt", "grade":1}, 0:{"method":"miss", "grade":0}}, 
		"primary":"dexterity", 
		"secondary":"agility", 
		"target_primary":"agility", 
		"target_secondary":"", 
		"tool_override":{"name":"horns", "use_stat":"strength", "proficiency":"unarmed", "range":"unarmed"}, 
		"ticks":3, 
		"limit":7
	}, 
	{
		"name":"hide", 
		"text":"USE_HIDE", 
		"requirements":{"proficiency":{"stealth":2}}, 
		"result":{10:{"method":"hide", "grade":1}, 0:{"method":"fail_hide", "grade":0}}, 
		"primary":"cunning", 
		"secondary":"agility", 
		"stamina":1, 
		"ticks":3, 
		"limit":10
	}, 
	{
		"name":"extinguish", 
		"text":"EXTINGUISH_FLAMES", 
		"requirements":{"status":"burning"}, 
		"result":{0:{"method":"extinguish_flames", "grade":1}}, 
		"primary":"dexterity", 
		"secondary":"cunning", 
		"ticks":4, 
		"limit":0
	}, 
	# magic
	{
		"name":"draw_arcane_rune", 
		"text":"DRAW_ARCANE_RUNE", 
		"requirements":{"proficiency":{"arcane_magic":1}, "can_cast_spell":"arcane"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"arcane", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_fire_rune", 
		"text":"DRAW_FIRE_RUNE", 
		"requirements":{"proficiency":{"fire_magic":1}, "can_cast_spell":"fire"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"fire", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_ice_rune", 
		"text":"DRAW_ICE_RUNE", 
		"requirements":{"proficiency":{"ice_magic":1}, "can_cast_spell":"ice"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"ice", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_wind_rune", 
		"text":"DRAW_WIND_RUNE", 
		"requirements":{"proficiency":{"wind_magic":1}, "can_cast_spell":"wind"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"wind", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_earth_rune", 
		"text":"DRAW_EARTH_RUNE", 
		"requirements":{"proficiency":{"earth_magic":1}, "can_cast_spell":"earth"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"earth", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_light_rune", 
		"text":"DRAW_LIGHT_RUNE", 
		"requirements":{"proficiency":{"light_magic":1}, "can_cast_spell":"light"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"light", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_nature_rune", 
		"text":"DRAW_NATURE_RUNE", 
		"requirements":{"proficiency":{"nature_magic":1}, "can_cast_spell":"nature"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"cunning", 
		"type":"nature", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_restoration_rune", 
		"text":"DRAW_RESTORATION_RUNE", 
		"requirements":{"proficiency":{"restoration_magic":1}, "can_cast_spell":"restoration"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"cunning", 
		"type":"restoration", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}, 
	{
		"name":"draw_shielding_rune", 
		"text":"DRAW_SHIELDING_RUNE", 
		"requirements":{"proficiency":{"shielding_magic":1}, "can_cast_spell":"shielding"}, 
		"result":{4:{"method":"draw_rune", "grade":1}, 0:{"method":"fail_rune", "grade":0}}, 
		"primary":"wisdom", 
		"secondary":"intelligence", 
		"type":"shielding", 
		"mana":1, 
		"ticks":2, 
		"limit":4
	}
]
const UNARMED_ATTACK = {
	"name":"unarmed_attack", 
	"text":"UNARMED_ATTACK_TARGET", 
	"requirements":{"proficiency":{"unarmed":1}}, 
	"result":{8:{"method":"unarmed_attack", "grade":1}, 0:{"method":"miss", "grade":0}}, 
	"primary":"dexterity", 
	"secondary":"agility", 
	"tool_override":{"name":"fists", "use_stat":"strength", "proficiency":"unarmed", "range":"unarmed"}, 
	"ticks":3, 
	"limit":8
}


var player : Array
var enemy : Array
var queue := []
var turn_timer := Timer.new()
var expirience := 0
var loot := []
var runes := [{}, {}]
var area_effects := {}

signal battle_won(victory)
signal battle_lost(dead)


class Sorter:
	static func sort(a, b):
		if a[0]<b[0]:
			return true
		return false




func get_enemy_counts(enemies) -> Dictionary:
	var dict := {}
	for e in enemies:
		if dict.has(e.base_type):
			dict[e.base_type] += 1
		else:
			dict[e.base_type] = 1
	return dict



func init_battle():
	var group : String
	
	if enemy.size()==1:
		group = tr(enemy[0].get_name())
	else:
		var list := ""
		var dict := get_enemy_counts(enemy)
		var count := {}
		for i in range(dict.size()):
			if dict.values()[i]==1:
				list += tr(dict.keys()[i].to_upper())
			else:
				list += str(dict.values()[i])+" "+tr(dict.keys()[i].to_upper())+"s"
			if i<dict.size()-1:
				list += ", "
			if i==dict.size()-2:
				list += tr("AND")+" "
		for c in enemy:
			if dict.has(c.base_type) && dict[c.base_type]>1:
				if !count.has(c.base_type):
					count[c.base_type] = 0
				if typeof(c.name)==TYPE_STRING:
					c.name += " "+char(KEY_A+count[c.base_type])
				else:
					if c.name.last.length()>0:
						c.name.last += " "+char(KEY_A+count[c.base_type])
					else:
						c.name.first += " "+char(KEY_A+count[c.base_type])
				count[c.base_type] += 1
		group = tr("GROUP_OF").format({"list":list})
	Main.add_text(tr("COMBAT_INIT").format({"enemy":group}))
	
	turn_timer.wait_time = 0.5
	turn_timer.one_shot = true
	Main.add_child(turn_timer)
	
	Main.add_action(Game.Action.new(tr("FIGHT"), self, {0:{"method":"start_battle", "grade":1}}, "", "", 2))

func start_battle(_actor, _action, _roll):
	sort_attack_order()
	next_turn()

func update_enemies():
	var text := Main.get_node("Panel/HBoxContainer/View/VBoxContainer/Text2")
	text.clear()
	for c in enemy:
		text.push_color(Color(1.0,0.3,0.2))
		if typeof(c.name)==TYPE_STRING:
			text.add_text(c.name+": ")
		else:
			text.add_text(c.name.first+": ")
		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.health)/max(float(c.max_health),1.0)))
		text.add_text("["+tr("HEALTH")+": "+tr("HEALTH"+str(ceil(4*c.health/max(c.max_health,1))))+"] ")
		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.stamina)/max(float(c.max_stamina),1.0)))
#		text.add_text("["+tr("STAMINA")+": "+tr("STAMINA"+str(ceil(4*c.stamina/max(c.max_stamina,1))))+"] ")
#		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.mana)/max(float(c.max_mana),1.0)))
#		text.add_text("["+tr("MANA")+": "+tr("MANA"+str(ceil(4*c.mana/max(c.max_mana,1))))+"] ")
		text.push_color(Color(1.0,1.0,1.0))
		for k in c.status.keys():
			if c.status[k].detrimental:
				text.push_color(Color(1.0,0.25,0.25))
			elif c.status[k].beneficial:
				text.push_color(Color(0.25,1.0,0.25))
			else:
				text.push_color(Color(1.0,1.0,1.0))
			text.add_text("["+tr(k.to_upper())+"] ")
		text.push_color(Color(1.0,1.0,1.0))
		text.newline()



func is_action_valid(actor, dict) -> bool:
	if dict.has("stamina") && actor.stamina<dict.stamina:
		return false
	if dict.has("mana") && actor.mana<dict.mana:
		return false
	if dict.has("requirements"):
		if dict.requirements.has("stats"):
			for k in dict.requirements.stats.keys():
				if actor.stats[k]<dict.requirements.stats[k]:
					return false
		if dict.requirements.has("status"):
			if !actor.has_status(dict.requirements.status):
				return false
		if dict.requirements.has("traits"):
			for k in dict.requirements.traits:
				if !(k in actor.traits):
					return false
		if dict.requirements.has("proficiency"):
			for k in dict.requirements.proficiency.keys():
				if !actor.proficiency.has(k) || actor.proficiency[k]<dict.requirements.proficiency[k]:
					return false
		if dict.requirements.has("knowledge"):
			if !actor.get_knowledge().has(dict.requirements.knowledge):
				return false
		if dict.requirements.has("can_cast_spell"):
			var has_spell := false
			for spell in Spells.spells.keys():
				var spell_dict = Spells.spells[spell].ACTION
				var knowledge := []
				if actor in player:
					for a in player:
						knowledge += a.get_knowledge()
				elif actor in enemy:
					for a in enemy:
						knowledge += a.get_knowledge()
				else:
					knowledge = actor.get_knowledge()
				if spell_dict.requirements.has("knowledge") && !knowledge.has(spell_dict.requirements.knowledge):
					continue
				if dict.requirements.can_cast_spell in spell_dict.runes.keys():
					has_spell = true
					break
			if !has_spell:
				return false
	return true

func get_actions(actor) -> Array:
	var actions := []
	var group := [actor]
	var num_weapons := 0
	if actor in player:
		group = player
	elif actor in enemy:
		group = enemy
	
	for eq in actor.equipment:
		if eq==null:
			continue
		if eq.type=="weapon":
			var primary : String
			var secondary = null
			var text : String
			var target = acquire_target(actor)
			var action
			if target==null:
				continue
			primary = "dexterity"
			secondary = ""
			text = tr("ATTACK_TARGET_WITH").format({"weapon":eq.name, "target":target.get_name()})
			action = Game.Action.new(text, self, ATK_RESULT, primary, secondary, 4, 9)
			action.tool_used = eq
			action.target = target
			action.target_primary = "dexterity"
			actions.push_back(action)
			num_weapons += 1
	if num_weapons==0:
		var target = acquire_target(actor)
		var action := Game.Action.new(UNARMED_ATTACK.text, self, UNARMED_ATTACK.result, UNARMED_ATTACK.primary, UNARMED_ATTACK.secondary, UNARMED_ATTACK.ticks, UNARMED_ATTACK.limit)
		action.tool_used = UNARMED_ATTACK.tool_override
		action.target = target
		action.target_primary = "dexterity"
		actions.push_back(action)
	
	for dict in ACTIONS:
		if !is_action_valid(actor, dict):
			continue
		var valid := true
		var action := Game.Action.new(tr(dict.text), self, dict.result, dict.primary, dict.secondary, dict.ticks, dict.limit)
		if dict.requirements.has("weapon"):
			var weapons := []
			var weapon
			for eq in actor.equipment:
				if eq==null:
					continue
				if eq.type=="weapon" && eq.proficiency==dict.requirements.weapon:
					weapons.push_back(eq)
			if weapons.size()==0:
				valid = false
				continue
			weapon = weapons[randi()%weapons.size()]
			action.tool_used = weapon
			action.text = action.text.format("weapon", weapon.name)
		if dict.has("tool_override"):
			action.tool_used = dict.tool_override
		if dict.has("actor_override"):
			if dict.actor_override.has("worst_stat"):
				action.actor_override = Characters.get_worst_character(group, dict.primary, dict.secondary)
			elif dict.actor_override.has("best_stat"):
				action.actor_override = Characters.get_best_character(group, dict.primary, dict.secondary)
		if dict.has("target"):
			var target = acquire_target(actor, dict.target)
			if target==null && !(dict.target.has("optional") && dict.target.optional):
				valid = false
				continue
			action.target = target
			if target!=null:
				action.text = action.text.format({"target":target.get_name()})
			if dict.has("target_primary"):
				action.target_primary = dict.target_primary
			if dict.has("target_secondary"):
				action.target_secondary = dict.target_secondary
		if dict.has("type"):
			action.type = dict.type
		if dict.has("health"):
			action.health = dict.health
		if dict.has("stamina"):
			action.stamina = dict.stamina
		if dict.has("mana"):
			action.mana = dict.mana
		if valid:
			actions.push_back(action)
	
	for spell in Spells.spells.keys():
		var action
		var valid := true
		var dict = Spells.spells[spell].ACTION
		if !is_action_valid(actor, dict):
			continue
		action = Game.Action.new(tr(dict.text), Spells.spells[spell], dict.result, dict.primary, dict.secondary, dict.ticks, dict.limit)
		action.ref = self
		if dict.has("weapon"):
			var weapons := []
			var weapon
			for eq in actor.equipment:
				if eq.type=="weapon" && eq.proficiency==dict.weapon:
					weapons.push_back(eq)
			if weapons.size()==0:
				continue
			weapon = weapons[randi()%weapons.size()]
			action.tool_used = weapon
			action.text = action.text.format("weapon", weapon.name)
		if dict.has("tool_override"):
			action.tool_used = dict.tool_override
		if dict.has("actor_override"):
			if dict.actor_override.has("worst_stat"):
				action.actor_override = Characters.get_worst_character(group, dict.primary, dict.secondary)
			elif dict.actor_override.has("best_stat"):
				action.actor_override = Characters.get_best_character(group, dict.primary, dict.secondary)
		if dict.has("target"):
			var target = acquire_target(actor, dict.target)
			if target==null:
				valid = false
				continue
			action.target = target
			action.text = action.text.format({"target":target.get_name()})
		if dict.has("runes"):
			var index = int(actor in player)
			for k in dict.runes.keys():
				if !runes[index].has(k) || runes[index][k]<dict.runes[k]:
					valid = false
					continue
			action.runes = dict.runes
		
		if valid:
			actions.push_back(action)
	
	return actions


func acquire_target(actor, filter={}):
	var q := []
	var set := []
	if filter.has("self") && filter.self:
		set.push_back(actor)
	if actor.has_status("confused"):
		set += player+enemy
	elif actor in enemy:
		if filter.has("ally") && filter.ally:
			set += enemy
		else:
			set += player
	elif actor in player:
		if filter.has("ally") && filter.ally:
			set += player
		else:
			set += enemy
	if set.size()==0:
		set += player+enemy
	for target in set:
		if target==actor:
			continue
		if target.health>0:
			if filter.has("status"):
				if !target.has_status(filter.status):
					continue
			if filter.has("no_status"):
				if target.has_status(filter.no_status):
					continue
			if target.has_status("hidden"):
				var roll = Game.do_roll(actor, "cunning", "", -target.stats.cunning)
				if roll<10:
					continue
			q.push_back([Game.roll(target.stats.agility-target.taunt), target])
	q.sort_custom(Sorter, "sort")
	if q.size()>0:
		return q[0][1]
	else:
		return


func sort_attack_order():
	var q := []
	for actor in enemy+player:
		if actor.health>0:
			q.push_back([Game.roll(actor.stats.agility), actor])
	q.sort_custom(Sorter, "sort")
	queue.resize(q.size())
	for i in range(q.size()):
		queue[i] = q[i][1]

func next_turn():
	var stun := false
	var actor = queue[0]
	queue.pop_front()
	for k in actor.status.keys():
		var st = actor.status[k]
		if st.has_method("on_turn"):
			st.on_turn()
		if k=="stunned":
			stun = true
	if stun || actor.health<=0:
		end_turn()
		return
	
	var actions := get_actions(actor)
	Main.add_text("")
	if "regeneration" in actor.traits:
		actor.heal(int(ceil(actor.max_health/10)))
	for effect in area_effects.values():
		if effect.has_method("on_turn"):
			effect.on_turn()
	Main.update_party()
	update_enemies()
	
	if actor in enemy || actor.has_status("confused"):
		if actions.size()>0:
			Game.do_action(actor, actions[randi()%actions.size()])
		else:
			Main.add_text(tr("COMBAT_UNABLE_TO_ACT").format({"actor":actor.get_name()}))
			end_turn()
	elif actor in player:
		Main.add_text(tr("ACTORS_TURN").format({"actor":actor.get_name()}))
		for action in actions:
			Main.add_action_actor(actor, action)
		if actions.size()==0 && Main.get_action_count()==0:
			Main.add_text(tr("COMBAT_UNABLE_TO_ACT").format({"actor":actor.get_name()}))
			end_turn()
	else:
		end_turn()

func end_turn():
	if turn_timer.time_left>0.0:
		printt("Timer still running...")
		return
	turn_timer.start()
	yield(turn_timer, "timeout")
	
	if queue.size()==0:
		sort_attack_order()
	if get_actor_count(player)==0:
		defeat()
	elif get_actor_count(enemy)==0:
		victory()
	else:
		if queue.size()==0:
			return
		next_turn()

func get_actor_count(set) -> int:
	var num := 0
	for c in set:
		if c.health>0:
			num += 1
	return num

func defeat():
	print("Player lost battle!")
	Main.add_text(tr("PLAYER_DEAD"))
	clear_status()
	Main.get_node("Panel/HBoxContainer/View/VBoxContainer/Text2").clear()
	emit_signal("battle_lost", true)
	turn_timer.queue_free()
	queue_free()

func victory():
	print("Player won battle!")
	clear_status()
	Main.get_node("Panel/HBoxContainer/View/VBoxContainer/Text2").clear()
	if expirience>0:
		expirience /= Characters.party.size()
		Main.add_text(tr("EXP_GAINED"))
		for ID in Characters.party:
			var c = Characters.characters[ID]
			c.add_exp(expirience)
	for ID in Characters.party:
		var c = Characters.characters[ID]
		c.increase_morale(5.0)
		for spell in c.spells_used.keys():
			if spell in c.knowledge:
				continue
			if c.spells_used[spell]>40-Game.do_roll(c, "intelligence", "cunning"):
				c.learn_spell(spell)
				Main.add_text(tr("ACTOR_LEARNED_SPELL").format({"name":c.get_name(), "spell":tr(spell.to_upper())}))
	if loot.size()>0:
		var list := ""
		for i in range(loot.size()):
			var type = loot[i]
			var item = Items.create_item(type)
			Items.add_item(item)
			list += item.name
			if i<loot.size()-1:
				list += ", "
				if i==loot.size()-2:
					list += tr("AND")+" "
		Main.add_text(tr("LOOT_FOUND").format({"list":list}))
	emit_signal("battle_won", true)
	turn_timer.queue_free()

func escaped():
	print("Player escaped from battle!")
	for ID in Characters.party:
		var c = Characters.characters[ID]
		c.increase_morale(5.0)
	clear_status()
	Main.get_node("Panel/HBoxContainer/View/VBoxContainer/Text2").clear()
	emit_signal("battle_won", false)
	turn_timer.queue_free()

func clear_status():
	for c in Characters.characters.values():
		for k in c.status.keys():
			if !c.status[k].permament:
				c.remove_status(k)

func clear_area_effects():
	area_effects.clear()

func add_area_effect(area_effect : Effects.AreaEffect, caster, args:={}):
	var effect = area_effect.new(self, caster, args)
	if area_effects.has(effect.name):
		remove_area_effect(area_effects[effect.name])
	area_effects[effect.name] = effect
	if effect.has_method("on_apply"):
		effect.on_apply()

func remove_area_effect(area_effect : Effects.AreaEffect):
	if area_effect.has_method("on_remove"):
		area_effect.on_remove()
	area_effects.erase(area_effect.name)

func check_block(actor, action, _roll):
	for eq in action.target.equipment:
		if eq==null:
			return
		if eq.type=="shield":
			var block := Game.do_roll(action.target, "strength", "constitution", eq.block-int(actor.stats.agility/2))
			if block>9:
				if block==Game.MAX_ROLL:
					var value := int(eq.block/2)
					Main.add_text(tr("COMBAT_BLOCKED_COUNTER").format({"actor":actor.get_name(), "target":action.target.get_name()}))
# warning-ignore:integer_division
					actor.add_status(Effects.CounterAttack, {"stat_inc":{"agility":-value, "dexterity":-int(value/2)}, "armor_inc":-value})
				else:
					Main.add_text(tr("COMBAT_BLOCKED").format({"actor":actor.get_name(), "target":action.target.get_name()}))
				return true
	return false

func miss(actor, action, _roll):
	var target : String
	if action.target==null:
		target = tr("THE_TARGETS")
	else:
		target = action.target.get_name()
	Main.add_text(tr("COMBAT_MISS").format({"actor":actor.get_name(), "target":target}))
	end_turn()

func hit(actor, action, roll):
	if check_block(actor, action, roll):
		end_turn()
		return
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)), num, max_roll)
	attack(actor, action, dam_roll)

func critical_hit(actor, action, _roll):
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
# warning-ignore:integer_division
	var dam_roll := 12+Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor/2, 0)), num, max_roll)/2
	Main.add_text(tr("CRITICAL_HIT"))
	attack(actor, action, dam_roll)

func attack(actor, action, roll, no_end:=false):
	var damage := int(round(action.tool_used.min_dam+(action.tool_used.max_dam-action.tool_used.min_dam)*roll/float(Game.MAX_ROLL)))
	var weapon_name = action.tool_used.name
	if weapon_name=="fists":
		weapon_name = tr("FISTS").format({"his/her":tr(Characters.HIS_HER[actor.gender])})
	Main.add_text(tr("COMBAT_HIT").format({"actor":actor.get_name(), "target":action.target.get_name(), "weapon":action.tool_used.name}))
	if action.target.has_status("riposte") && action.tool_used.range=="melee":
# warning-ignore:integer_division
		damage = int(damage/2)
		action.target.remove_status("riposte")
		Main.add_text(tr("RIPOSTE_ACTION").format({"actor":actor.get_name(), "target":action.target.get_name()}))
		actor.damaged(damage)
		print(actor.get_name()+"->"+action.target.get_name()+" damage: "+str(damage))
	for st in action.target.status.values():
		if st.has_method("on_attacked"):
			st.on_attacked(actor, action)
	action.target.damaged(damage)
	if damage>0 && action.target.health>0:
		Main.add_text(tr("COMBAT_DAMAGED").format({"actor":action.target.get_name()}))
		if action.tool_used.has("afflict") && (!action.tool_used.afflict[1].has("chance") || randf()<action.tool_used.afflict[1].chance):
				action.target.add_status(Effects.get(action.tool_used.afflict[0]), action.tool_used.afflict[1])
	
	if action.health>0:
		actor.damaged(action.health)
	if action.stamina>0:
		actor.stressed(action.stamina)
	if action.mana>0:
		actor.drained(action.mana)
	
	for st in actor.status.values():
		if st.has_method("on_attack"):
			st.on_attack(action.target)
	
	# effects from traits and status effects
	if "corrosive" in action.target.traits && (action.tool_used.range=="melee" || action.tool_used.range=="unarmed"):
		actor.add_status(Effects.Corrosion, {"duration":2, "armor_inc":-1})
	if "cryo" in action.target.traits && (action.tool_used.range=="melee" || action.tool_used.range=="unarmed"):
		actor.add_status(Effects.Frozen, {"duration":2, "stats_inc":{"agility":-4, "dexterity":-4}})
	if "pyro" in action.target.traits && (action.tool_used.range=="melee" || action.tool_used.range=="unarmed"):
		actor.add_status(Effects.Burning, {"duration":2, "amount":1})
	if "toxic" in action.target.traits && (action.tool_used.range=="melee" || action.tool_used.range=="unarmed"):
		actor.add_status(Effects.Poisoned, {"duration":3, "amount":1})
	
	if action.tool_used.has("lifesteal"):
# warning-ignore:integer_division
		actor.heal(int(damage/2))
		Main.add_text(tr("COMBAT_LIFESTEAL").format({"actor":actor.get_name(), "target":action.target.get_name()}))
	
	# add exp and loot from attacking
	if action.target.health<=0 && actor in player:
		var rnd := randf()
		expirience += action.target.expirience
		while rnd<action.target.drop_rate:
			loot.push_back(action.target.drops[randi()%action.target.drops.size()])
			rnd += 1.0
	
	if !no_end:
		end_turn()


func escape(actor, _action, _roll):
	if actor in player:
		Main.add_text(tr("COMBAT_ESCAPE_SUCCESS"))
		escaped()
	elif actor in enemy:
		Main.add_text(tr("COMBAT_ACTOR_ESCAPED").format({"actor":actor.get_name()}))
		enemy.erase(actor)
		end_turn()
	else:
		end_turn()

func fail_escape(actor, _action, _roll):
	if actor in player:
		Main.add_text(tr("COMBAT_FAIL_ESCAPE"))
	else:
		Main.add_text(tr("COMBAT_ACTOR_FAIL_ESCAPE").format({"actor":actor.get_name()}))
	end_turn()


func stunning_blow(actor, action, roll):
	if check_block(actor, action, roll):
		end_turn()
		return
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)), num, max_roll)
	attack(actor, action, dam_roll)
	action.target.add_status(Effects.Stunned)
	end_turn()

func cleave(actor, action, roll):
	var targets
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
	if actor in player:
		targets = enemy
	elif actor in enemy:
		targets = player
	else:
		targets = player+enemy
	action.health = 0
	action.stamina = 0
	action.mana = 0
	for target in targets:
		action.target = target
		if check_block(actor, action, roll):
			continue
		var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(target.armor, 0)), num, max_roll)
		attack(actor, action, dam_roll, true)
	end_turn()

func riposte(actor, action, _roll):
	if action.health>0:
		actor.damaged(action.health)
	if action.stamina>0:
		actor.stressed(action.stamina)
	if action.mana>0:
		actor.drained(action.mana)
	actor.add_status(Effects.Riposte)
	end_turn()

func backstab(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, "cunning", "dexterity", 0)
	var damage := round(action.tool_used.min_dam+(action.tool_used.max_dam-action.tool_used.min_dam)*dam_roll/float(Game.MAX_ROLL))
	action.tool_used.max_dam *= 2
	action.target.damaged(damage)
	Main.add_text(tr("COMBAT_BACKSTAB").format({"actor":actor.get_name(), "target":action.target.get_name()}))
	action.target.remove_status("distracted")
	if damage>0 && action.target.health>0:
		Main.add_text(tr("COMBAT_DAMAGED").format({"actor":action.target.get_name()}))
	end_turn()

func fail_backstab(actor, action, _roll):
	Main.add_text(tr("COMBAT_MISS").format({"actor":actor.get_name(), "target":action.target.get_name()}))
	action.target.remove_status("distracted")
	end_turn()

func body_slam(actor, action, roll):
	if check_block(actor, action, roll):
		end_turn()
		return
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)), num, max_roll)
	unarmed_attack(actor, action, dam_roll)
	action.target.add_status(Effects.CounterAttack, {"stat_inc":{"agility":-4, "dexterity":-2}})
	action.target.add_status(Effects.Distracted)
	end_turn()

func pin_down(actor, action, _roll):
	var num := 1
	var max_roll := Game.MAX_ROLL
	if action.tool_used.has("rolls"):
		num = action.tool_used.rolls
	if action.tool_used.has("faces"):
		max_roll = action.tool_used.faces
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)), num, max_roll)
	attack(actor, action, dam_roll)
	action.target.add_status(Effects.Pinned, {"duration":3, "stats_inc":{"agility":-6}})
	end_turn()

func hide(actor, action, _roll):
	if action.health>0:
		actor.damaged(action.health)
	if action.stamina>0:
		actor.stressed(action.stamina)
	if action.mana>0:
		actor.drained(action.mana)
	actor.add_status(Effects.Hidden)
	end_turn()


func unarmed_attack(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)))
	action.tool_used = {"name":"unarmed", "min_dam":2, "max_dam":4, "proficiency":"unarmed", "use_stat":"strength", "range":"unarmed"}
	attack(actor, action, dam_roll)

func claws(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)))
	action.tool_used = {"name":"claws", "min_dam":2, "max_dam":5, "proficiency":"unarmed", "use_stat":"strength", "range":"unarmed"}
	attack(actor, action, dam_roll)

func claws_bleed(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)))
	action.tool_used = {"name":"claws", "min_dam":2, "max_dam":5, "proficiency":"unarmed", "use_stat":"strength", "range":"unarmed"}
	attack(actor, action, dam_roll)
	action.target.add_status(Effects.Bleeding, {"value":1, "duration":5})

func headbutt(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)))
	action.tool_used = {"name":"headbutt", "min_dam":2, "max_dam":4, "proficiency":"unarmed", "use_stat":"strength", "range":"unarmed"}
	attack(actor, action, dam_roll)

func headbutt_bleed(actor, action, _roll):
	var dam_roll := Game.do_roll(actor, action.tool_used.use_stat, "", -int(max(action.target.armor, 0)))
	action.tool_used = {"name":"headbutt", "min_dam":2, "max_dam":4, "proficiency":"unarmed", "use_stat":"strength", "range":"unarmed"}
	attack(actor, action, dam_roll)
	action.target.add_status(Effects.Confused, {"duration":3})

func extinguish_flames(actor, _action, _roll):
	actor.remove_status("burning")
	end_turn()


# magic

func fail_rune(actor, action, _roll):
	Main.add_text(tr("COMBAT_FAIL_DRAW_RUNE").format({"actor":actor.get_name(), "type":tr(action.type.to_upper())}))
	if action.mana>0:
		actor.drained(action.mana)
	end_turn()

func draw_rune(actor, action, _roll):
	var index := int(actor in player)
	Main.add_text(tr("COMBAT_DRAW_RUNE").format({"actor":actor.get_name(), "type":tr(action.type.to_upper())}))
	if runes[index].has(action.type):
		runes[index][action.type] += 1
	else:
		runes[index][action.type] = 1
	if action.mana>0:
		actor.drained(action.mana)
	end_turn()
