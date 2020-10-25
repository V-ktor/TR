extends CanvasLayer

var scroll_down := true
var location_title := ""
var selected_item := -1

var text_label := preload("res://scenes/main/text.tscn")
var action_button := preload("res://scenes/main/button.tscn")
var character_panel := preload("res://scenes/gui/character.tscn")
var quest_panel := preload("res://scenes/gui/quest.tscn")

onready var text_container := $Panel/HBoxContainer/Text/VBoxContainer


func clear():
	for c in text_container.get_children():
		c.queue_free()

func hide_actions():
	for c in text_container.get_children():
		if c.has_method("disable"):
			c.disable()

func add_text(text) -> Label:
	var li = text_label.instance()
	if text.length()>0:
		text[0] = text[0].to_upper()
	li.text = text
	hide_actions()
	text_container.add_child(li)
	$Panel/HBoxContainer/Text.scroll_vertical = text_container.rect_size.y
	scroll_down = true
	return li

func add_action_actor(actor,action):
	var limit = action.limit-action.offset-Game.get_offset(actor,action.primary,action.secondary)
	if action.target!=null && action.target_primary!="":
		limit += Game.get_offset(action.target,action.target_primary,action.target_secondary)
	var bi = action_button.instance()
	bi.get_node("Button").text = tr(action.text).replace("<name>",actor.name.get_name())
	bi.get_node("Button").connect("pressed",self,"_select_action",[actor,action,bi])
	if limit>action.faces*action.num:
		bi.get_node("Button").disabled = true
		bi.get_node("Chance").text = "["+tr("CHANCE")+": "+tr("CHANCE5")+"]"
		bi.get_node("Chance").modulate = Color(0.5,0.0,0.0)
		bi.get_node("Chance").show()
	elif limit>0 && action.result.size()>1:
		bi.get_node("Chance").text = "["+tr("CHANCE")+": "+tr("CHANCE"+str(int(4*limit/Game.MAX_ROLL)))+"]"
		bi.get_node("Chance").modulate = Color(0.0,1.0,0.0).linear_interpolate(Color(1.0,0.0,0.0),float(limit)/float(Game.MAX_ROLL))
		bi.get_node("Chance").show()
	text_container.add_child(bi)
#	bi.grab_focus()
	scroll_down = true
	return bi

func add_action(action,proficiencies=[]):
	var actor = Characters.get_best_character(Characters.party,action.primary,action.secondary,proficiencies)
	return add_action_actor(actor,action)

func get_action_count() -> int:
	var num := 0
	for c in text_container.get_children():
		if c is HBoxContainer && c.has_node("Button") && !c.get_node("Button").disabled:
			num += 1
	return num


func _select_action(actor,action,node):
	hide_actions()
	Game.do_action(actor,action,node)


func _equip(index,button,slot,ID):
	var c = Characters.characters[ID]
	var i = button.get_item_id(index)
	if i>0:
		c.equip(slot,Characters.inventory[i-1])
	elif i==0:
		c.unequip(slot)
	update_characters()

func _use_item(index):
	var dict = Characters.inventory[index]
	if !dict.has("method"):
		selected_item = -1
		return
	
	selected_item = index
	if dict.has("target"):
		if dict.target=="ally":
			$PopupMenu.clear()
			for i in range(Characters.party.size()):
				$PopupMenu.add_item(Characters.characters[Characters.party[i]].get_name(),i)
			$PopupMenu.popup(Rect2($Panel.get_local_mouse_position(),Vector2($PopupMenu.rect_size.x,4+18*Characters.party.size())))
		return
	
	if Items.callv(dict.method,dict.args):
		Items.remove_items(dict.name)
		update_inventory()
	selected_item = -1

func _payout():
	Characters.payout_party()

func _select_character(index):
	if selected_item<0:
		return
	var dict = Characters.inventory[selected_item]
	if Items.callv(dict.method,[Characters.characters[Characters.party[index]]]+dict.args):
		Items.remove_items(dict.name)
		update_inventory()
	selected_item = -1

func _toggle_category_filter(pressed,category):
	Journal.filter[category] = pressed
	update_journal()

func _toggle_sort_name(pressed):
	for c in $Panel/HBoxContainer/List/VBoxContainer/HBoxContainer.get_children():
		c.get_node("Active").hide()
	$Panel/HBoxContainer/List/VBoxContainer/HBoxContainer/ButtonName/Active.show()
	Journal.sort_by = ["name_ascending","name_descending"][int(pressed)]
	update_journal()

func _toggle_sort_time(pressed):
	for c in $Panel/HBoxContainer/List/VBoxContainer/HBoxContainer.get_children():
		c.get_node("Active").hide()
	$Panel/HBoxContainer/List/VBoxContainer/HBoxContainer/ButtonTime/Active.show()
	Journal.sort_by = ["date_ascending","date_descending"][int(pressed)]
	update_journal()

func _show_journal_entry(ID):
	var entry = Journal.entries.values()[ID]
	$Panel/HBoxContainer/Journal/VBoxContainer/Image.texture = load(entry.image)
	$Panel/HBoxContainer/Journal/VBoxContainer/Image/Title.text = entry.title
	$Panel/HBoxContainer/Journal/VBoxContainer/Text.clear()
	$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(0.0,0.0,0.0))
	if entry.category=="city":
		var city = Map.get_location(entry.title)
		$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text(tr("FACTION")+": "+tr(city.faction.to_upper())+"\n")
		if Characters.relations.has(city.faction):
			var relation = Characters.relations[city.faction]
			$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text(tr("RELATION")+": ")
			if relation<=-50:
				$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(1.0,0.1,0.1).darkened(0.5))
			elif relation<=-10:
				$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(0.9,0.9,0.1).darkened(0.5))
			elif relation<10:
				$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(1.0,1.0,1.0).darkened(0.5))
			elif relation<50:
				$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(0.7,1.0,0.5).darkened(0.5))
			else:
				$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(0.2,1.0,0.1).darkened(0.5))
			$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text(str(relation)+"\n")
			$Panel/HBoxContainer/Journal/VBoxContainer/Text.push_color(Color(0.0,0.0,0.0))
		$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text(tr("POPULATION")+": "+str(city.population)+"\n\n")#+tr("FACILITIES")+":\n")
#		for s in city.facilities:
#			$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text("  "+tr(s.to_upper())+"\n")
	for text in entry.text:
		$Panel/HBoxContainer/Journal/VBoxContainer/Text.add_text(text+"\n")


func update_landscape(type):
	if !Map.BACKGROUND_IMAGES.has(type):
		$Panel/HBoxContainer/View/VBoxContainer/Image.hide()
		return
	$Panel/HBoxContainer/View/VBoxContainer/Image.texture = load(Map.BACKGROUND_IMAGES[type].file)
	for p in Map.BACKGROUND_IMAGES[type].keys():
		$Panel/HBoxContainer/View/VBoxContainer/Image.material.set_shader_param(p,Map.BACKGROUND_IMAGES[type][p])
	$Panel/HBoxContainer/View/VBoxContainer/Image.show()

func update_party():
	var text := $Panel/HBoxContainer/View/VBoxContainer/Text
	text.clear()
	for ID in Characters.party:
		var c = Characters.characters[ID]
		text.add_text(c.name.first+": ")
		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.health)/max(float(c.max_health),1.0)))
		text.add_text("["+tr("HEALTH")+": "+tr("HEALTH"+str(ceil(4*c.health/max(c.max_health,1))))+"] ")
		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.stamina)/max(float(c.max_stamina),1.0)))
		text.add_text("["+tr("STAMINA")+": "+tr("STAMINA"+str(ceil(4*c.stamina/max(c.max_stamina,1))))+"] ")
		text.push_color(Color(1.0,0.0,0.0).linear_interpolate(Color(0.0,1.0,0.0),float(c.mana)/max(float(c.max_mana),1.0)))
		text.add_text("["+tr("MANA")+": "+tr("MANA"+str(ceil(4*c.mana/max(c.max_mana,1))))+"] ")
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

func update_characters():
	for c in $Panel/HBoxContainer/Characters/VBoxContainer.get_children():
		c.hide()
	for i in range(Characters.party.size()):
		var ID = Characters.party[i]
		var c = Characters.characters[ID]
		var knowledge = c.get_knowledge()
		var panel
		if has_node("Panel/HBoxContainer/Characters/VBoxContainer/Character"+str(ID)):
			panel = get_node("Panel/HBoxContainer/Characters/VBoxContainer/Character"+str(ID))
			panel.show()
		else:
			panel = character_panel.instance()
			panel.name = "Character"+str(ID)
			get_node("Panel/HBoxContainer/Characters/VBoxContainer").add_child(panel)
		panel.cID = ID
		panel.get_node("Status/HBoxContainerName/Name").text = c.name.get_full()
		panel.get_node("Status/HBoxContainerName/Class").text = tr("LVL")+" "+str(c.level)+" "+tr(c.race.to_upper())
		panel.get_node("Skills/HBoxContainerName/Name").text = panel.get_node("Status/HBoxContainerName/Name").text
		panel.get_node("Skills/HBoxContainerName/Class").text = panel.get_node("Status/HBoxContainerName/Class").text
		panel.get_node("Traits/HBoxContainerName/Name").text = panel.get_node("Status/HBoxContainerName/Name").text
		panel.get_node("Traits/HBoxContainerName/Class").text = panel.get_node("Status/HBoxContainerName/Class").text
		panel.get_node("Status/HBoxContainerStatus/Health/Label").text = tr("HEALTH"+str(ceil(4*c.health/c.max_health)))+" ("+str(c.health)+"/"+str(c.max_health)+")"
		panel.get_node("Status/HBoxContainerStatus/Stamina/Label").text = tr("STAMINA"+str(ceil(4*c.stamina/c.max_stamina)))+" ("+str(c.stamina)+"/"+str(c.max_stamina)+")"
		panel.get_node("Status/HBoxContainerStatus/Mana/Label").text = tr("MANA"+str(ceil(4*c.mana/c.max_mana)))+" ("+str(c.mana)+"/"+str(c.max_mana)+")"
		panel.get_node("Status/HBoxContainerStatus/Exp/Label").text = str(c.expirience)+"/"+str(c.max_expirience)+" ("+str(int(100*c.expirience/c.max_expirience))+"%)"
		for c2 in panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects").get_children():
			c2.hide()
		for j in c.status.size():
			var label
			if panel.has_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Status"+str(j)):
				label = panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Status"+str(j))
			else:
				label = panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Status0").duplicate()
				label.name = "Status"+str(j)
				panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects").add_child(label)
			label.show()
			label.get_node("Label").text = tr(c.status.keys()[j].to_upper())
			if c.status.values()[j].detrimental:
				label.modulate = Color(1.0,0.25,0.25)
			elif c.status.values()[j].beneficial:
				label.modulate = Color(0.25,1.0,0.25)
			else:
				label.modulate = Color(0.5,0.5,0.5)
		if c.hired:
			panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Hired").show()
			panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Hired").hint_tooltip = tr("PAYMENT_TOOLTIP").format({"amount":str(c.payment_cost),"currency":tr(c.payment_currency.to_upper())})
			if c.hired_until!=0:
				var date = OS.get_datetime_from_unix_time(c.hired_until)
				panel.get_node("Status/HBoxContainer/VBoxContainer/HBoxContainerEffects/Hired").hint_tooltip += "\n"+tr("HIRED_UNTIL_TOOLTIP").format({"time":tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})})
		for c2 in panel.get_node("Status/HBoxContainer/VBoxContainer/GridContainer").get_children():
			c2.hide()
		for j in range(c.slots.size()):
			var button
			if panel.has_node("Status/HBoxContainer/VBoxContainer/GridContainer/Button"+str(j)):
				button = panel.get_node("Status/HBoxContainer/VBoxContainer/GridContainer/Button"+str(j))
				button.clear()
			else:
				button = panel.get_node("Status/HBoxContainer/VBoxContainer/GridContainer/Button0").duplicate()
				button.clear()
				button.name = "Button"+str(j)
				panel.get_node("Status/HBoxContainer/VBoxContainer/GridContainer").add_child(button)
			if !button.is_connected("item_selected",self,"_equip"):
				button.connect("item_selected",self,"_equip",[button,j,ID])
			button.show()
			if j>0 && c.equipment.size()+1>j && c.equipment[j-1]!=null && c.equipment[j-1].has("2h") && c.equipment[j-1]["2h"]:
				button.add_item(tr(c.slots[j].to_upper())+": "+tr("USED"),-1)
			else:
				button.add_item(tr(c.slots[j].to_upper())+": "+tr("NONE"),-1)
				if c.equipment.size()>j && c.equipment[j]!=null:
					button.add_item(tr(c.slots[j].to_upper())+": "+tr(c.equipment[j].name),0)
					button.select(1)
				for k in range(Characters.inventory.size()):
					var item = Characters.inventory[k]
					if item.has("slot") && item.slot==c.slots[j]:
						button.add_item(tr(item.name),k+1)
		for stat in Characters.STATS:
			var node = panel.get_node("Skills/HBoxContainerStats/"+stat.capitalize())
			node.get_node("VBoxContainer/Value").value = c.stats[stat]
			node.get_node("VBoxContainer/Value").min_value = c.min_stats[stat]
		panel.get_node("Skills/LabelPoints").text = tr("POINTS_LEFT")+" "+str(c.prof_points)
		for prof in Characters.PROFICIENCIES:
			var node = panel.get_node("Skills/ScrollContainer/VBoxContainer/"+prof.capitalize())
			if c.proficiency.has(prof):
				node.get_node("HBoxContainer/Level").text = tr("PROF_LEVEL"+str(c.proficiency[prof]))
				node.get_node("HBoxContainer/ButtonDec").disabled = c.proficiency[prof]>0
			else:
				node.get_node("HBoxContainer/Level").text = tr("PROF_LEVEL0")
				node.get_node("HBoxContainer/ButtonDec").disabled = true
		for c2 in panel.get_node("Traits/Traits").get_children():
			c2.hide()
		for j in range(c.traits.size()):
			var label
			var stylebox
			if panel.has_node("Traits/Traits/Trait"+str(j)):
				label = panel.get_node("Traits/Traits/Trait"+str(j))
			else:
				label = panel.get_node("Traits/Traits/Trait0").duplicate()
				label.name = "Trait"+str(j)
				panel.get_node("Traits/Traits").add_child(label)
			label.get_node("Label").text = tr(c.traits[j].to_upper())
			stylebox = label.get_stylebox("panel").duplicate()
			if Characters.TRAIT_COLOR.has(c.traits[j]):
				stylebox.border_color = Characters.TRAIT_COLOR[c.traits[j]]
			else:
				stylebox.border_color = Color("#e2b057")
			label.add_stylebox_override("panel",stylebox)
			label.hint_tooltip = tr(c.traits[i].to_upper()+"_TOOLTIP")
			label.show()
		if knowledge.size()==0:
			panel.get_node("Traits/Spells").hide()
			panel.get_node("Traits/HSeparator2").hide()
			panel.get_node("Traits/LabelSpells").hide()
		else:
			for c2 in panel.get_node("Traits/Spells/GridContainer").get_children():
				c2.hide()
			for j in range(knowledge.size()):
				var node
				if panel.has_node("Traits/Spells/GridContainer/Spell"+str(j)):
					node = panel.get_node("Traits/Spells/GridContainer/Spell"+str(j))
				else:
					node = panel.get_node("Traits/Spells/GridContainer/Spell0").duplicate()
					node.name = "Spell"+str(j)
					panel.get_node("Traits/Spells/GridContainer").add_child(node)
				node.get_node("Label").text = tr(knowledge[j].to_upper())
				node.get_node("Label").hint_tooltip = tr(knowledge[j].to_upper()+"_TOOLTIP")
				node.show()
			panel.get_node("Traits/Spells").show()
			panel.get_node("Traits/HSeparator2").show()
			panel.get_node("Traits/LabelSpells").show()
		for c2 in panel.get_node("Traits/ScrollContainer/GridContainer").get_children():
			c2.hide()
		for j in range(c.appearance.size()):
			var node
			if panel.has_node("Traits/ScrollContainer/GridContainer/Trait"+str(j)):
				node = panel.get_node("Traits/ScrollContainer/GridContainer/Trait"+str(j))
			else:
				node = panel.get_node("Traits/ScrollContainer/GridContainer/Trait0").duplicate()
				node.name = "Trait"+str(j)
				panel.get_node("Traits/ScrollContainer/GridContainer").add_child(node)
			node.get_node("HBoxContainer/Label").text = tr(c.appearance.keys()[j].to_upper())
			node.get_node("HBoxContainer/Type").text = tr(c.appearance.values()[j].to_upper())
			node.show()
		panel.get_node("Skills/HBoxContainerStats/Points/Number").text = str(c.stat_points)
		panel.get_node("Status/HBoxContainer/Control").cID = ID
		panel.get_node("Status/HBoxContainer/Control").update()
		

func update_inventory():
	var mass := Characters.get_total_mass()
	var capacity := Characters.get_capacity()
	for c in $Panel/HBoxContainer/Inventory/VBoxContainer/VBoxContainer.get_children():
		c.hide()
	
	for i in range(Characters.inventory.size()):
		var item : Button
		var label : RichTextLabel
		var dict = Characters.inventory[i]
		var tooltip := create_item_tooltip_text(dict)
		if has_node("Panel/HBoxContainer/Inventory/VBoxContainer/VBoxContainer/Item"+str(i)):
			item = get_node("Panel/HBoxContainer/Inventory/VBoxContainer/VBoxContainer/Item"+str(i))
		else:
			item = get_node("Panel/HBoxContainer/Inventory/VBoxContainer/VBoxContainer/Item0").duplicate(0)
			item.name = "Item"+str(i)
			get_node("Panel/HBoxContainer/Inventory/VBoxContainer/VBoxContainer").add_child(item)
			item.connect("pressed",self,"_use_item",[i])
		label = item.get_node("RichTextLabel")
		label.clear()
		if !dict.has("grade"):
			label.push_color(Items.GRADE_COLOR[1].darkened(0.5))
		else:
			label.push_color(Items.GRADE_COLOR[dict.grade].darkened(0.5))
		label.add_text(dict.name)
		label.push_color(Color(0.2,0.2,0.2))
		if dict.has("amount") && dict.amount!=1:
			label.add_text(" [x"+str(dict.amount)+"]")
		item.show()
		item.hint_tooltip = tooltip
		item.disabled = !dict.has("method")
	if mass>capacity:
		$Panel/HBoxContainer/Inventory/VBoxContainer/LabelEncumbrance.modulate = Color(1.0,0.3,0.3)
	else:
		$Panel/HBoxContainer/Inventory/VBoxContainer/LabelEncumbrance.modulate = Color(0.3,1.0,0.3)
	$Panel/HBoxContainer/Inventory/VBoxContainer/LabelEncumbrance.text = tr("ENCUMBRANCE")+": "+str(mass).pad_decimals(1)+"kg / "+str(capacity).pad_decimals(1)+"kg"
	$Panel/HBoxContainer/Inventory/VBoxContainer/LabelPayment.hide()
	$Panel/HBoxContainer/Inventory/VBoxContainer/ButtonPay.hide()
	$Panel/HBoxContainer/Inventory/VBoxContainer/HSeparator.hide()
	if Characters.payment.size()>0:
		$Panel/HBoxContainer/Inventory/VBoxContainer/LabelPayment.show()
		$Panel/HBoxContainer/Inventory/VBoxContainer/ButtonPay.show()
		$Panel/HBoxContainer/Inventory/VBoxContainer/HSeparator.show()
		$Panel/HBoxContainer/Inventory/VBoxContainer/LabelPayment.text = tr("DEBTS")+":\n"
		for currency in Characters.payment.keys():
			if Characters.payment[currency]>=1.0:
				$Panel/HBoxContainer/Inventory/VBoxContainer/LabelPayment.text += "  "+tr(currency.to_upper())+": "+str(Characters.payment[currency]).pad_decimals(1)+"\n"

func update_quests():
	for c in $Panel/HBoxContainer/Quests/VBoxContainer.get_children():
		c.hide()
	
	for i in range(Game.quests.size()):
		var panel
		var quest : Quests.Quest = Game.quests.values()[i]
		var date := OS.get_datetime_from_unix_time(quest.timelimit)
		var location = Map.get_location(quest.location)
		if has_node("Panel/HBoxContainer/Quests/VBoxContainer/Quest"+str(i)):
			panel = get_node("Panel/HBoxContainer/Quests/VBoxContainer/Quest"+str(i))
		else:
			panel = quest_panel.instance()
			panel.name = "Quest"+str(i)
			$Panel/HBoxContainer/Quests/VBoxContainer.add_child(panel)
		panel.get_node("ScrollContainer/VBoxContainer/Name/LabelName").text = tr(quest.name.to_upper())
		panel.get_node("ScrollContainer/VBoxContainer/Name/LabelDifficulty").text = tr(quest.difficulty.to_upper())
		panel.get_node("ScrollContainer/VBoxContainer/LabelDescription").text = quest.description
		for text in quest.updates:
			panel.get_node("ScrollContainer/VBoxContainer/LabelDescription").text += "\n"+text
		panel.get_node("ScrollContainer/VBoxContainer/LabelTimelimit").text = tr("TIMELIMIT")+": "+tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})+" ("+str(int((quest.timelimit-Map.time)/60.0/60.0))+tr("H")+" "+tr("REMAINING")+")"
		panel.get_node("ScrollContainer/VBoxContainer/Location/Label").text = tr("LOCATION")+": "
		panel.get_node("ScrollContainer/VBoxContainer/Location/Button").text = location.name
		if panel.get_node("ScrollContainer/VBoxContainer/Location/Button").is_connected("pressed",self,"_show_location"):
			panel.get_node("ScrollContainer/VBoxContainer/Location/Button").disconnect("pressed",self,"_show_location")
		panel.get_node("ScrollContainer/VBoxContainer/Location/Button").connect("pressed",self,"_show_location",[quest.location])
		panel.show()

func update_journal():
	var keys = Journal.get_entries_sorted()
	for c in $Panel/HBoxContainer/List/VBoxContainer/VBoxContainer.get_children():
		c.hide()
	
	for i in range(Journal.CATEGORIES.size()):
		var c = Journal.CATEGORIES[i]
		var button
		if has_node("Panel/HBoxContainer/List/VBoxContainer/GridContainer/Button"+str(i)):
			button = get_node("Panel/HBoxContainer/List/VBoxContainer/GridContainer/Button"+str(i))
		else:
			button = $Panel/HBoxContainer/List/VBoxContainer/GridContainer/Button0.duplicate(0)
			button.name = "Button"+str(i)
			$Panel/HBoxContainer/List/VBoxContainer/GridContainer.add_child(button)
		button.text = tr(c.to_upper())
		if button.is_connected("toggled",self,"_toggle_category_filter"):
			button.disconnect("toggled",self,"_toggle_category_filter")
		button.pressed = Journal.filter.has(c) && Journal.filter[c]
		button.connect("toggled",self,"_toggle_category_filter",[c])
	
	for i in range(keys.size()):
		var k = keys[i]
		var entry = Journal.entries[k]
		var date = OS.get_datetime_from_unix_time(entry.time)
		var button
		if has_node("Panel/HBoxContainer/List/VBoxContainer/VBoxContainer/Button"+str(i)):
			button = get_node("Panel/HBoxContainer/List/VBoxContainer/VBoxContainer/Button"+str(i))
		else:
			button = $Panel/HBoxContainer/List/VBoxContainer/VBoxContainer/Button0.duplicate(0)
			button.name = "Button"+str(i)
			$Panel/HBoxContainer/List/VBoxContainer/VBoxContainer.add_child(button)
		button.text = entry.title
		button.get_node("Label").text = tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})
		if !button.is_connected("pressed",self,"_show_journal_entry"):
			button.connect("pressed",self,"_show_journal_entry",[i])
		button.visible = Journal.filter.has(entry.category) && Journal.filter[entry.category]
	


func create_item_tooltip_text(item) -> String:
	var text := ""
	if item.has("grade"):
		text += "["+tr(Items.GRADE_NAMES[item.grade])+"] "
	text += item.name+"\n"
	text += tr("TYPE")+": "+tr(item.type.to_upper())+"\n"
	if item.has("slot"):
		text += tr("SLOT")+": "+tr(item.slot.to_upper())+"\n"
	if item.has("proficiency"):
		text += tr("PROFICIENCY")+": "+tr(item.proficiency.to_upper())+"\n"
	if item.has("knowledge"):
		text += tr("SPELLS")+":\n"
		for spell in item.knowledge:
			text += "  "+tr(spell.to_upper())+"\n    "+tr(spell.to_upper()+"_TOOLTIP")+"\n"
	for s in Items.EQUIPMENT_STATS:
		if item.has(s):
			text += tr(s.to_upper())+": "+str(item[s])+"\n"
	text += tr("WEIGHT")+": "+str(item.weight)+"kg\n"+tr("PRICE")+": "+str(item.price)
	return text


func _show_log():
	$Panel/HBoxContainer/View.show()
	$Panel/HBoxContainer/Inventory.hide()
	$Panel/HBoxContainer/Text.show()
	$Panel/HBoxContainer/Characters.hide()
	$Panel/HBoxContainer/Quests.hide()
	$Panel/HBoxContainer/List.hide()
	$Panel/HBoxContainer/Journal.hide()
	$Panel/Map.hide()
	if location_title!="":
		$Title/Label.text = tr(location_title)
	else:
		$Title/Label.text = tr("LOG")

func _show_inventory():
	$Panel/HBoxContainer/View.show()
	$Panel/HBoxContainer/Text.hide()
	$Panel/HBoxContainer/Inventory.show()
	$Panel/HBoxContainer/Characters.hide()
	$Panel/HBoxContainer/Quests.hide()
	$Panel/HBoxContainer/List.hide()
	$Panel/HBoxContainer/Journal.hide()
	$Panel/Map.hide()
	update_inventory()
	$Title/Label.text = tr("INVENTORY")

func _show_characters():
	$Panel/HBoxContainer/View.hide()
	$Panel/HBoxContainer/Text.hide()
	$Panel/HBoxContainer/Inventory.hide()
	$Panel/HBoxContainer/Characters.show()
	$Panel/HBoxContainer/Quests.hide()
	$Panel/HBoxContainer/List.hide()
	$Panel/HBoxContainer/Journal.hide()
	$Panel/Map.hide()
	update_characters()
	$Title/Label.text = tr("CHARACTERS")

func _show_map(location:=Game.location):
	$Panel/HBoxContainer/View.hide()
	$Panel/HBoxContainer/Text.hide()
	$Panel/HBoxContainer/Inventory.hide()
	$Panel/HBoxContainer/Characters.hide()
	$Panel/HBoxContainer/Quests.hide()
	$Panel/HBoxContainer/List.hide()
	$Panel/HBoxContainer/Journal.hide()
	$Panel/Map.show_map(location)
	$Title/Label.text = tr("MAP")

func _show_quests():
	$Panel/HBoxContainer/View.hide()
	$Panel/HBoxContainer/Text.hide()
	$Panel/HBoxContainer/Inventory.hide()
	$Panel/HBoxContainer/Characters.hide()
	$Panel/HBoxContainer/Quests.show()
	$Panel/HBoxContainer/List.hide()
	$Panel/HBoxContainer/Journal.hide()
	$Panel/Map.hide()
	update_quests()
	$Title/Label.text = tr("QUESTS")

func _show_journal():
	$Panel/HBoxContainer/View.hide()
	$Panel/HBoxContainer/Text.hide()
	$Panel/HBoxContainer/Inventory.hide()
	$Panel/HBoxContainer/Characters.hide()
	$Panel/HBoxContainer/Quests.hide()
	$Panel/HBoxContainer/List.show()
	$Panel/HBoxContainer/Journal.show()
	$Panel/Map.hide()
	update_journal()
	$Panel/HBoxContainer/Journal/VBoxContainer/Image.texture = null
	$Panel/HBoxContainer/Journal/VBoxContainer/Image/Title.text = tr("JOURNAL")
	$Title/Label.text = tr("JOURNAL")

func _show_location(location):
	_show_map(location)

func set_title(text):
	location_title = text
	if $Panel/HBoxContainer/Text.visible:
		$Title/Label.text = tr(location_title)


func _process(_delta):
	var date := OS.get_datetime_from_unix_time(Map.time)
	if scroll_down:
		$Panel/HBoxContainer/Text.scroll_vertical = text_container.rect_size.y
	
	$Panel/HBoxContainer/View/VBoxContainer/Time.text = tr("TIME")+": "+tr("TIME_FORMAT").format({"minute":str(date.minute).pad_zeros(2),"hour":str(date.hour).pad_zeros(2),"day":str(date.day).pad_zeros(2),"month":str(date.month).pad_zeros(2),"year":date.year,"weekday":date.weekday})
	

func _input(event):
	if event is InputEventMouseButton && event.pressed:
		scroll_down = false

func _ready():
	$Title.hide()
	$Panel.hide()
	$ButtonMenu.hide()
	$Panel/Panel/VBoxContainer/ButtonLog.connect("pressed",self,"_show_log")
	$Panel/Panel/VBoxContainer/ButtonMap.connect("pressed",self,"_show_map")
	$Panel/Panel/VBoxContainer/ButtonInv.connect("pressed",self,"_show_inventory")
	$Panel/Panel/VBoxContainer/ButtonChr.connect("pressed",self,"_show_characters")
	$Panel/Panel/VBoxContainer/ButtonMis.connect("pressed",self,"_show_quests")
	$Panel/Panel/VBoxContainer/ButtonJou.connect("pressed",self,"_show_journal")
	$Panel/HBoxContainer/Inventory/VBoxContainer/ButtonPay.connect("pressed",self,"_payout")
	$PopupMenu.connect("id_pressed",self,"_select_character")
	$ButtonMenu.connect("pressed",Menu,"show")
	$Panel/HBoxContainer/List/VBoxContainer/HBoxContainer/ButtonName.connect("toggled",self,"_toggle_sort_name")
	$Panel/HBoxContainer/List/VBoxContainer/HBoxContainer/ButtonTime.connect("toggled",self,"_toggle_sort_time")
	
