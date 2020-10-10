extends Panel

var cID

func _show_status():
	$Status.show()
	$Skills.hide()
	$Traits.hide()

func _show_skills():
	$Status.hide()
	$Skills.show()
	$Traits.hide()

func _show_traits():
	$Status.hide()
	$Skills.hide()
	$Traits.show()

func _change_stat(value,stat):
	var character = Characters.characters[cID]
	if value<character.stats[stat]:
		character.dec_stat(stat)
		Main.update_characters()
	elif value>character.stats[stat]:
		character.inc_stat(stat)
		Main.update_characters()

func _inc_prof(prof):
	var character = Characters.characters[cID]
	character.inc_prof(prof)
	Main.update_characters()

func _dec_prof(prof):
	var character = Characters.characters[cID]
	character.dec_prof(prof)
	Main.update_characters()

func _ready():
	for stat in Characters.STATS:
		var box = $Skills/HBoxContainerStats/Stat0.duplicate()
		box.name = stat.capitalize()
		box.get_node("VBoxContainer/Label").text = tr(stat.to_upper())
		box.get_node("VBoxContainer/Label").hint_tooltip = tr(stat.to_upper()+"_TOOLTIP")
		box.get_node("VBoxContainer/Value").hint_tooltip = tr(stat.to_upper()+"_TOOLTIP")
		$Skills/HBoxContainerStats.add_child(box)
		box.get_node("VBoxContainer/Value").connect("value_changed",self,"_change_stat",[stat])
		box.show()
	for prof in Characters.PROFICIENCIES:
		var box = $Skills/ScrollContainer/VBoxContainer/Skill0.duplicate()
		box.name = prof.capitalize()
		box.get_node("HBoxContainer/Label").text = tr(prof.to_upper())
		box.get_node("HBoxContainer").hint_tooltip = tr(prof.to_upper()+"_TOOLTIP")
		box.get_node("HBoxContainer/ButtonInc").hint_tooltip = tr(prof.to_upper()+"_TOOLTIP")
		box.get_node("HBoxContainer/ButtonDec").hint_tooltip = tr(prof.to_upper()+"_TOOLTIP")
		$Skills/ScrollContainer/VBoxContainer.add_child(box)
		box.get_node("HBoxContainer/ButtonInc").connect("pressed",self,"_inc_prof",[prof])
		box.get_node("HBoxContainer/ButtonDec").connect("pressed",self,"_dec_prof",[prof])
		box.show()
	
	$Status/HBoxContainerName/ButtonSkills.connect("pressed",self,"_show_skills")
	$Skills/HBoxContainerName/ButtonTraits.connect("pressed",self,"_show_traits")
	$Traits/HBoxContainerName/ButtonStatus.connect("pressed",self,"_show_status")
