extends CanvasLayer

onready var log_container = $Frame/Panel/ScrollContainer/VBoxContainer


func add_log_text(text):
	var label = Label.new()
	label.autowrap = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = text
	log_container.add_child(label)
