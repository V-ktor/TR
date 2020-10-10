extends HBoxContainer

const DELAY = 0.25

export var num_dots := 3
export var status := ""
var delay := DELAY


func disable():
	$Button.disabled = true

func start(_num_dots,_status,color):
	num_dots = _num_dots
	status = _status
	$Dots.add_color_override("font_color",color)
	$Dots.show()

func _process(delta):
	delay -= delta
	if delay<=0.0:
		$Dots.text += "."
		if $Dots.text.length()>=num_dots:
			$Status.text = tr(status)
			$Status.show()
			set_process(false)

func _ready():
	set_process(false)
