extends Node

func get_damage(actor,action,roll,min_dam,max_dam,dam_scale) -> int:
	printt(min_dam,max_dam,action.num,action.faces,roll/float(Game.MAX_ROLL),dam_scale,actor.stats.intelligence,actor.stats.intelligence/2.0-5)
	return int(round(min_dam+(max_dam-min_dam)*roll/float(action.faces)+dam_scale*(actor.stats.intelligence/2.0-5)))

func prepare_spell(actor,action,_roll,spell:=""):
	var index = int(actor in action.ref.player)
	for k in action.runes.keys():
		if action.ref.runes[index].has(k):
			if action.ref.runes[index][k]<=action.runes[k]:
				action.ref.runes[index].erase(k)
			else:
				action.ref.runes[index][k] -= action.runes[k]
	if action.health>0:
		actor.damaged(action.health)
	if action.stamina>0:
		actor.stressed(action.stamina)
	if action.mana>0:
		actor.drained(action.mana)
	if spell!="":
		if actor.spells_used.has(spell):
			actor.spells_used[spell] += 1
		else:
			actor.spells_used[spell] = 1

func fail(actor,action,roll):
	prepare_spell(actor,action,roll)
	Main.add_text(tr("COMBAT_SPELL_FAILED").format({"actor":actor.get_name()}))
	action.ref.end_turn()

func missed(actor,action,roll):
	prepare_spell(actor,action,roll)
	Main.add_text(tr("COMBAT_SPELL_MISSED").format({"actor":actor.get_name(),"target":action.target.get_name()}))
	action.ref.end_turn()
