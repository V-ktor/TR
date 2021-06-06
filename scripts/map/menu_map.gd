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
const WIDTH = 32
const HEIGHT = 32

var offset := 0.0
var size := Vector2(768.0,768.0)
var scale := 4.0
var tiles := []
var scroll_speed := 0.5


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

func update():
	$TileMap.clear()
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var pos := Vector2(x-offset,y-offset)
			var terrain : String = tiles[y][x].tile
			var rnd : int = tiles[y][x].rnd
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
							var p := get_offset(i)
							t = tiles[clamp(y+p.y,0,HEIGHT-1)][clamp(x+p.x,0,WIDTH-1)].tile
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

func _process(delta):
	var last_offset := int(offset)
	offset += scroll_speed*delta
# warning-ignore:integer_division
	$TileMap.position = scale*Vector2(0,36*offset-HEIGHT*WIDTH/4)+Vector2(OS.window_size.x/2,0)
	$TileMap.scale = Vector2(scale,scale)
	if int(offset)>last_offset:
		update_map()

func update_map():
# warning-ignore:integer_division
	for ofs in range((WIDTH+HEIGHT)/2-1,0,-1):
		for x in range(WIDTH):
			tiles[ofs][x] = tiles[ofs-1][x]
		for y in range(HEIGHT):
			tiles[y][ofs] = tiles[y][ofs-1]
	for x in range(WIDTH):
		var array := []
		for i in range(max(x-1,0),min(x+1,WIDTH)):
			for j in range(0,1):
				array.push_back(tiles[i][j].tile)
		if array.size()>0 && randf()<0.75:
			tiles[0][x] = {"tile":array[randi()%array.size()],"rnd":randi()}
		else:
			tiles[0][x] = {"tile":TILES.keys()[randi()%TILES.size()],"rnd":randi()}
	for y in range(HEIGHT):
		var array := []
		for i in range(0,1):
			for j in range(max(y-1,0),min(y+1,HEIGHT)):
				array.push_back(tiles[i][j].tile)
		if array.size()>0 && randf()<0.75:
			tiles[y][0] = {"tile":array[randi()%array.size()],"rnd":randi()}
		else:
			tiles[y][0] = {"tile":TILES.keys()[randi()%TILES.size()],"rnd":randi()}
	update()

func init_map():
	tiles.resize(HEIGHT)
	for y in range(HEIGHT):
		tiles[y] = []
		tiles[y].resize(WIDTH)
		for x in range(WIDTH):
			tiles[y][x] = {"tile":TILES.keys()[randi()%TILES.size()],"rnd":randi()}
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var array := []
			for i in range(max(x-1,0),min(x+1,WIDTH)):
				for j in range(max(y-1,0),min(y+1,HEIGHT)):
					array.push_back(tiles[i][j].tile)
			if array.size()>0:
				tiles[y][x].type = array[randi()%array.size()]
	update()

func _screen_resized():
	scale = max(OS.window_size.x/768.0, OS.window_size.y/512.0)
	$TileMap.position = scale*Vector2(0,36*offset-HEIGHT*WIDTH/4)+Vector2(OS.window_size.x/2,0)
	$TileMap.scale = Vector2(scale,scale)

func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")
	_screen_resized()
	init_map()
