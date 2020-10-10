extends Control

func _draw():
	var scale = get_parent().scale
	var center = get_parent().center
	for terrain in Map.terrains:
		draw_circle(scale*(terrain.position+center),scale*terrain.radius,Color(terrain.color.r,terrain.color.g,terrain.color.b,0.1))
