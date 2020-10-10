extends CanvasLayer

func _ready():
	for c in get_children():
		if c.has_method("hide"):
			c.hide()
