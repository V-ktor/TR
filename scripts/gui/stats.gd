extends Control

var cID


func get_max_stat(stats) -> int:
	var m := 0
	for v in stats.values():
		if v>m:
			m = v
	return m

func _draw():
	if !Characters.characters.has(cID):
		return
	
	var character = Characters.characters[cID]
	var stats = character.stats
	var num_stats = stats.size()
	var center = rect_size/2.0
	var max_stat := get_max_stat(stats)
	var length = min(rect_size.x,rect_size.y)/2.0
# warning-ignore:integer_division
	var num_lines := int(max_stat/3)
	var points := []
	points.resize(num_stats)
	for i in num_stats:
		var angle := 2.0*PI*float(i)/float(num_stats)
		var to := Vector2(rect_size.x/2.0*cos(angle)*cos(angle)+rect_size.y/2.0*sin(angle)*sin(angle),0).rotated(angle)
		var j = int(i+1)%num_stats
		var angle2 := 2.0*PI*float(j)/float(num_stats)
		draw_line(center,center+to,Color(1.0,1.0,1.0),2.0,true)
		
		for l in range(num_lines):
			var v1 = center+Vector2(length*float(l)/float(num_lines),0).rotated(angle)
			var v2 = center+Vector2(length*float(l)/float(num_lines),0).rotated(angle2)
			draw_line(v1,v2,Color(0.75,0.75,0.75,0.5),1.0,true)
		
		var v1 = center+Vector2(length*float(stats.values()[i])/float(max_stat),0).rotated(angle)
		var v2 = center+Vector2(length*float(stats.values()[j])/float(max_stat),0).rotated(angle2)
		var v3 = center+Vector2(length,0).rotated(angle)
		v3.x = min(max(v3.x, 16), rect_size.x-16)
		v3.y = min(max(v3.y, 16), rect_size.y-16)
		draw_line(v1,v2,Color(0.5,0.75,1.0,1.0),2.0,true)
		draw_string(get_node("../../../").theme.get_default_font(),v3+Vector2(-16,0),tr(stats.keys()[i]).substr(0,3).to_upper(),Color(0.75,0.75,0.75,0.75))
		points[i] = v1
	draw_colored_polygon(points,Color(0.5,0.75,1.0,0.25))
