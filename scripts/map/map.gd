extends Control

const TILES = {
	"farm":[0,78,79,80],
	"hills":{
		 1:[-1,-1,-1,-1,-1,-1],
		90:[ 0, 1, 1, 0, 1, 0],
		91:[ 0, 1, 1, 0, 1, 0],
		92:[ 0, 1, 1, 0,-1, 0],
		93:[ 0,-1, 1, 0, 1, 0],
		94:[ 0,-1,-1, 1, 1, 0],
		95:[ 0,-1,-1, 0, 1, 1],
		96:[ 1, 1, 0,-1,-1, 0],
		97:[ 0, 1, 1, 0,-1, 0]},
	"mountains":{
		 2:[-1,-1,-1,-1,-1,-1],
		 6:[-1, 1, 1, 1,-1,-1],
		 7:[-1,-1, 1, 1, 1,-1],
		 8:[-1,-1,-1, 1, 1, 1],
		 9:[ 1,-1,-1,-1, 1, 1],
		10:[ 1, 1,-1,-1,-1,-1],
		11:[ 1, 1, 1,-1,-1,-1],
		12:[ 1, 1, 1, 1, 1, 1],
		13:[ 1, 1, 1, 1, 1, 1]},
	"desert":[3,98],
	"forest":{
		  4:[-1,-1,-1,-1,-1,-1],
		 99:[ 1, 1, 1, 1, 1, 1],
		100:[ 1, 1, 1, 1, 1, 1],
		101:[-1, 1, 1, 1,-1,-1],
		102:[-1,-1, 1, 1, 1,-1],
		103:[-1,-1,-1, 1, 1, 1],
		104:[ 1,-1,-1,-1, 1, 1],
		105:[ 1, 1,-1,-1,-1, 1],
		106:[ 1, 1, 1,-1,-1,-1]},
	"pines":{
		107:[-1,-1,-1,-1,-1,-1],
		108:[ 1, 1, 1, 1, 1, 1],
		109:[ 1, 1, 1, 1, 1, 1],
		110:[-1, 1, 1, 1,-1,-1],
		111:[-1,-1, 1, 1, 1,-1],
		112:[-1,-1,-1, 1, 1, 1],
		113:[ 1,-1,-1,-1, 1, 1],
		114:[ 1, 1,-1,-1,-1, 1],
		115:[ 1, 1, 1,-1,-1,-1]},
	"swamp":-1,
	"vulcano":{
		87:[-1,-1,-1,-1,-1,-1],
		81:[-1, 1, 1, 1,-1,-1],
		82:[-1,-1, 1, 1, 1,-1],
		83:[-1,-1,-1, 1, 1, 1],
		84:[ 1,-1,-1,-1, 1, 1],
		85:[ 1, 1,-1,-1,-1,-1],
		86:[ 1, 1, 1,-1,-1,-1],
		88:[ 1, 1, 1, 1, 1, 1],
		89:[ 1, 1, 1, 1, 1, 1]},
	"water":{
		 5:[-1,-1,-1,-1,-1,-1],
		14:[-1, 1, 1, 1,-1,-1],
		15:[-1,-1, 1, 1, 1,-1],
		16:[-1,-1,-1, 1, 1, 1],
		17:[ 1,-1,-1,-1, 1, 1],
		18:[ 1, 1,-1,-1,-1, 1],
		19:[ 1, 1, 1,-1,-1,-1],
		20:[ 1, 1, 1, 1, 1, 1],
		21:[ 1, 1, 1, 1, 1, 1],
		22:[-1, 1, 1,-1,-1,-1],
		23:[-1,-1, 1, 1,-1,-1],
		24:[-1,-1,-1, 1, 1,-1],
		25:[-1,-1,-1,-1, 1, 1],
		26:[ 1,-1,-1,-1,-1, 1],
		27:[ 1, 1,-1,-1,-1,-1],
		28:[-1,-1, 1, 1, 1, 1],
		29:[-1, 1, 1, 1, 1,-1],
		30:[ 1, 1, 1, 1,-1,-1],
		31:[ 1, 1, 1,-1,-1, 1],
		32:[ 1, 1,-1,-1, 1, 1],
		33:[ 1,-1,-1, 1, 1, 1],
		34:[-1,-1,-1,-1,-1, 1],
		35:[ 1,-1,-1,-1,-1,-1],
		36:[-1, 1,-1,-1,-1,-1],
		37:[-1,-1, 1,-1,-1,-1],
		38:[-1,-1,-1, 1,-1,-1],
		39:[-1,-1,-1,-1, 1,-1],
		40:[ 1, 1, 1, 1, 1,-1],
		41:[-1, 1, 1, 1, 1, 1],
		42:[ 1,-1, 1, 1, 1, 1],
		43:[ 1, 1,-1, 1, 1, 1],
		44:[ 1, 1, 1,-1, 1, 1],
		45:[ 1, 1, 1, 1,-1, 1],
		46:[-1, 1,-1,-1,-1, 1],
		47:[-1,-1, 1,-1,-1, 1],
		48:[-1,-1,-1, 1,-1, 1],
		49:[ 1,-1, 1,-1,-1,-1],
		50:[ 1,-1,-1, 1,-1,-1],
		51:[ 1,-1,-1,-1, 1,-1],
		52:[-1,-1, 1,-1, 1,-1],
		53:[-1, 1,-1,-1, 1,-1],
		54:[-1, 1,-1, 1,-1,-1],
		55:[ 1,-1, 1,-1, 1,-1],
		56:[-1, 1,-1, 1,-1, 1],
		57:[ 1,-1, 1,-1,-1, 1],
		58:[ 1,-1,-1, 1,-1, 1],
		59:[-1, 1,-1, 1, 1,-1],
		60:[ 1,-1,-1, 1, 1,-1],
		61:[ 1, 1,-1,-1, 1,-1],
		62:[ 1, 1,-1, 1,-1,-1],
		63:[-1,-1, 1, 1,-1, 1],
		64:[ 1,-1, 1, 1,-1,-1],
		65:[ 1, 1,-1, 1,-1, 1],
		66:[ 1, 1, 1,-1, 1,-1],
		67:[-1, 1, 1, 1,-1, 1],
		68:[ 1,-1, 1, 1, 1,-1],
		69:[-1, 1,-1, 1, 1, 1],
		70:[ 1,-1, 1,-1, 1, 1],
		71:[-1, 1, 1,-1, 1, 1],
		72:[ 1,-1, 1, 1,-1, 1],
		73:[ 1, 1,-1, 1, 1,-1],
		74:[-1,-1, 1,-1, 1, 1],
		75:[-1, 1,-1,-1, 1, 1],
		76:[-1, 1, 1,-1, 1,-1],
		77:[-1, 1, 1,-1,-1, 1],
		
		}
}

var offset := 0
var center := Vector2(384.0,384.0)
var size := Vector2(768.0,768.0)
var scale := 4.0
var selected : String
var grab_position : Vector2
var drag := false

var location := preload("res://scenes/gui/button_location.tscn")
var foot := preload("res://scenes/gui/foot.tscn")


func get_offset(dir : int) -> Vector2:
	# Return a vector pointing in the right direction on a hex grid (0 is up, clock-wise).
	var ofs := Vector2()
	match dir:
		0:
			ofs = Vector2(-1,-1)
		1:
			ofs = Vector2( 0,-1)
		2:
			ofs = Vector2( 1, 0)
		3:
			ofs = Vector2( 1, 1)
		4:
			ofs = Vector2( 0, 1)
		5:
			ofs = Vector2(-1, 0)
	return ofs

func update(update_tilemap:=false):
	for c in get_children():
		if c.name=="Tooltip" || c.name=="Terrain" || c.name=="TileMap":
			continue
		c.queue_free()
	rect_size = scale*size
	rect_min_size = scale*size
	selected = Game.location
	for k in Map.locations.keys()+Map.cities.keys():
		var bi = location.instance()
		var l = Map.get_location(k)
		add_child(bi)
		bi.rect_position = scale*(l.position-Vector2(2,2)+center)
		bi.name = k
		bi.connect("mouse_entered",self,"_show_info",[k])
		bi.connect("mouse_exited",self,"_hide_info")
		bi.connect("pressed",self,"_select",[k])
		if Game.location==l.name:
			bi.get_node("Location").show()
	if !update_tilemap:
		return
	$TileMap.clear()
	$TileMap.position = scale*center
	for pos in Map.tiles.keys():
		var terrain = Map.tiles[pos].tile
		var rnd = Map.tiles[pos].rnd
		if TILES.has(terrain):
			if typeof(TILES[terrain])==TYPE_INT:
				$TileMap.set_cellv(pos,TILES[terrain])
			elif typeof(TILES[terrain])==TYPE_ARRAY:
				$TileMap.set_cellv(pos,TILES[terrain][rnd%TILES[terrain].size()])
			elif typeof(TILES[terrain])==TYPE_DICTIONARY:
				var matching := []
				for k in TILES[terrain].keys():
					var valid := true
					for i in range(6):
						var t := ""
						var f = TILES[terrain][k][i]
						if Map.tiles.has(pos+get_offset(i)):
							t = Map.tiles[pos+get_offset(i)].tile
						if (f==1 && t!=terrain) || (f==-1 && t==terrain):
							valid = false
							break
					if !valid:
						continue
					matching.push_back(k)
				if matching.size()==0:
					$TileMap.set_cellv(pos,TILES[terrain].keys()[0])
				else:
					$TileMap.set_cellv(pos,matching[rnd%matching.size()])

func _show_info(ID):
	var c = Map.get_location(ID)
	var dist = Map.get_location(Game.location).position.distance_to(c.position)
	$Tooltip/RichTextLabel.clear()
	if c.type=="city":
		$Tooltip/RichTextLabel.add_text(c.name+"\n"+tr(c.faction.to_upper())+"\n"+tr("DISTANCE")+": "+str(dist).pad_decimals(1)+"km")
	else:
		$Tooltip/RichTextLabel.add_text(c.name+"\n"+tr("DISTANCE")+": "+str(dist).pad_decimals(1)+"km")
	$Tooltip.rect_position = scale*(c.position+center)+Vector2(2,2)
	$Tooltip.show()
	$Tooltip.raise()

func _hide_info():
	$Tooltip.hide()

func _select(ID):
	for c in get_children():
		if c.has_method("set_pressed"):
			c.pressed = c.name==ID
	selected = ID
	$"../../".set_info(Map.get_location(ID))

func draw_footprint(pos,rot):
	var fi = foot.instance()
	fi.position = scale*(pos+center)+Vector2(8.0*(offset-0.5),0.0).rotated(rot)
	fi.rotation = rot+PI/16.0*(offset-0.5)
	add_child(fi)
	offset = (offset+1)%2

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			grab_position = event.position+Vector2(get_parent().scroll_horizontal,get_parent().scroll_vertical)
		drag = event.pressed
	elif event is InputEventMouseMotion && drag:
		get_parent().scroll_horizontal = grab_position.x-event.position.x
		get_parent().scroll_vertical = grab_position.y-event.position.y

func _ready():
	set_process_input(true)
