extends Node

const MAP_SIZE = 300.0
const MIN_CITY_DIST = 24.0
const FACILITIES = [
	"bar","inn","blacksmith","armory","tailor",
	"board","herbalist","archery_range"
]
const IMPORTANT_FACILITIES = [
	"inn","board","bar"
]
const CITY_TRAITS = [
	"poor","prosperous",
	"trading","manufactories",
#	These are assigned via terrain.
#	"farming","mining","wood",
#	"dry","scarce","vulcano",
	"xenophobic",
]
const CITY_DESC = [
	# special
	"+human +capital",
	# trading
	"+trading +prosperous -poor","+trading +poor +small",
	"+trading +bar +inn +board -prosperous",
	# farming
	"+farming +wood +small","+farming +prosperous -manufactories",
	"+wood +small -farming -manufactories",
	# mining
	"+mining +small -poor -manufactories","+mining +small +poor",
	"+mining +manufactories -small -dwarf",
	# manufactories
	"+manufactories +poor -farming",
	"+manufactories +prosperous -poor",
	# farming under extreme conditions
	"+farming +vulcano","+farming +dry",
	# others
	"+xenophobic +small -prosperous",
	"+blacksmith +armory +tailor +archery_range",
	# race specific details
	"+elf +archery_range -poor -small",
	"+dwarf +manufactories +blacksmith +armory -small",
	"+dwarf +small -manufactories -wood -farming",
	"+orc +blacksmith +armory",
	"+human +prosperous +large",
]
const IMAGE_HUMAN_CITY = {
	"file":"res://images/backgrounds/sk5.jpg",
	"scale_i":2.0,
	"scale_f":1.5,
	"pos_i":Vector2(-0.25,0.2),
	"pos_f":Vector2(0.15,0.1),
	"speed":0.1
}
const IMAGE_DWARVEN_CITY = {
	"file":"res://images/backgrounds/Badlands.png",
	"scale_i":1.3,
	"scale_f":1.2,
	"pos_i":Vector2(0.12,-0.1),
	"pos_f":Vector2(-0.05,0.0),
	"speed":0.1
}
const IMAGE_GENERIC_CITY = {
	"file":"res://images/backgrounds/FireTemple.png",
	"scale_i":1.0,
	"scale_f":1.2,
	"pos_i":Vector2(-0.15,0.0),
	"pos_f":Vector2(0.1,-0.1),
	"speed":0.1
}
const IMAGE_GENERIC_PLAINS = {
	"file":"res://images/backgrounds/battleback10.png",
	"scale_i":1.0,
	"scale_f":1.0,
	"pos_i":Vector2(-0.1,0.0),
	"pos_f":Vector2(0.1,0.0),
	"speed":0.2
}
const IMAGE_GENERIC_HILLS = {
	"file":"res://images/backgrounds/wizardtower.png",
	"scale_i":1.1,
	"scale_f":1.2,
	"pos_i":Vector2(-0.1,0.05),
	"pos_f":Vector2(0.1,0.0),
	"speed":0.1
}
const IMAGE_GENERIC_FOREST = {
	"file":"res://images/backgrounds/battleback1.png",
	"scale_i":1.0,
	"scale_f":1.0,
	"pos_i":Vector2(-0.1,0.0),
	"pos_f":Vector2(0.1,0.0),
	"speed":0.2
}
const IMAGE_DEEP_FOREST = {
	"file":"res://images/backgrounds/environment_forest_evening.png",
	"scale_i":1.0,
	"scale_f":1.0,
	"pos_i":Vector2(-0.1,0.0),
	"pos_f":Vector2(0.1,0.0),
	"speed":0.2
}
const IMAGE_GENERIC_SANDS = {
	"file":"res://images/backgrounds/cloudsinthedesert.png",
	"scale_i":1.0,
	"scale_f":1.1,
	"pos_i":Vector2(-0.1,0.0),
	"pos_f":Vector2(0.1,0.05),
	"speed":0.15
}
const IMAGE_GENERIC_DESERT = {
	"file":"res://images/backgrounds/battleback3.png",
	"scale_i":1.0,
	"scale_f":1.0,
	"pos_i":Vector2(-0.1,0.0),
	"pos_f":Vector2(0.1,0.0),
	"speed":0.2
}
const IMAGE_COLD_MOUNTAINS = {
	"file":"res://images/backgrounds/coldmountain.png",
	"scale_i":1.25,
	"scale_f":1.1,
	"pos_i":Vector2(-0.1,0.05),
	"pos_f":Vector2(0.1,-0.05),
	"speed":0.1
}
const BACKGROUND_IMAGES = {
	"human_city":IMAGE_HUMAN_CITY,
	"dwarf_city":IMAGE_DWARVEN_CITY,
	"generic_city":IMAGE_GENERIC_CITY,
	"woods":IMAGE_GENERIC_FOREST,
	"deep_forest":IMAGE_DEEP_FOREST,
	"plains":IMAGE_GENERIC_PLAINS,
	"hills":IMAGE_GENERIC_HILLS,
	"sands":IMAGE_GENERIC_SANDS,
	"desert":IMAGE_GENERIC_DESERT,
	"cold_mountains":IMAGE_COLD_MOUNTAINS
}
const PRICE_MODS = {
	"farming":{"food":-0.25},
	"mining":{"food":0.1,"wood":0.1,"metals":-0.25},
	"wood":{"wood":-0.25,"food":-0.1,"luxury_goods":-0.1},
	"dry":{"food":0.2,"wood":0.2,"luxury_goods":-0.2},
	"scarce":{"food":0.1,"wood":0.1,"metals":0.1,"medical_supplies":0.1,"luxury_goods":-0.1},
	"trading":{"food":0.1,"luxury_goods":0.2},
	"manufactories":{"food":0.1,"metals":0.2,"wood":0.2,"medical_supplies":-0.1},
	"poor":{"food":-0.1,"luxury_goods":-0.2,"medical_supplies":0.2},
	"prosperous":{"food":0.1,"luxury_goods":0.1,"medical_supplies":-0.2}
}

var city_data := []
var terrain_data := []
var cities := {}
var locations := {}
var terrains := []
var tiles := {}
var time := 0


class Location:
	var name : String
	var description : String
	var position : Vector2
	var type : String
	var traits : Array
	var can_leave : bool
	var landscape : String
	var temporary : bool		# automatically delete this if not needed anymore?
	
	func _init(_name:="",_position:=Vector2(),_type:="",_traits:=[],_can_leave:=true,_landscape:="",_temporary:=false):
		name = _name
		position = _position
		type = _type
		traits = _traits
		can_leave = _can_leave
		landscape = _landscape
		temporary = _temporary
	
	func to_dict() -> Dictionary:
		var dict := {"name":name,"position":[position.x,position.y],
			"type":type,"landscape":landscape,"temporary":temporary,
			"traits":traits,"can_leave":can_leave}
		return dict

class City extends Location:
	var faction : String
	var population : int
	var facilities : Array
	var desc : Array
	var shop_seed : int
	var price_mods : Dictionary
	
	func _init(_name,_position,_faction,_population,_facilities,_traits,_price_mods,_shop_seed:=randi()):
		type = "city"
		name = _name
		position = _position
		faction = _faction
		population = _population
		facilities = _facilities
		traits = _traits
		can_leave = true
		if BACKGROUND_IMAGES.has(faction+"_city"):
			landscape = faction+"_city"
		else:
			landscape = "generic_city"
		shop_seed = _shop_seed
		price_mods = _price_mods
		set_desc()
	
	func set_desc():
		# Create describtions, determined by combinations of traits.
		desc = []
		for d in CITY_DESC:
			var has := []
			var has_not := []
			var qualified = true
			for t in d.split(" ",false):
				if "+" in t:
					has.push_back(t.replace("+",""))
				elif "-" in t:
					has_not.push_back(t.replace("-",""))
			for tag in has:
				if !(tag in traits) && !(tag in facilities) && !(tag==faction):
					qualified = false
					break
			for tag in has_not:
				if tag in traits || tag in facilities || tag==faction:
					qualified = false
					break
			if qualified:
				desc.push_back(tr(d).to_upper())
		description = ""
		for d in desc:
			description += tr(d.to_upper().replace(" ","")).format({"city":name,"faction":tr(faction.to_upper()),"population":str(population)})+"\n"
		
	
	func to_dict() -> Dictionary:
		var dict := {"name":name,"type":"city","position":[position.x,position.y],
			"landscape":landscape,"temporary":temporary,
			"faction":faction,"population":population,"traits":traits,
			"facilities":facilities,
			"shop_seed":shop_seed,"price_mods":price_mods}
		return dict

class Terrain:
	var type : String
	var position : Vector2
	var radius : float
	var travel_time : float
	var encounters : Array
	var traits : Array
	var tile : String
	
	func _init(_type,_position,_radius,_travel_time,_encounters,_traits,_tile):
		type = _type
		position = _position
		radius = _radius
		travel_time = _travel_time
		encounters = _encounters
		traits = _traits
		tile = _tile
	
	func to_dict() -> Dictionary:
		var dict := {"name":type,"type":type,
			"position":[position.x,position.y],"radius":radius,
			"travel_time":travel_time,
			"encounters":encounters,"traits":traits,
			"tile":tile}
		return dict


func get_location(ID):
	if locations.has(ID):
		return locations[ID]
	elif cities.has(ID):
		return cities[ID]

func get_faction_cities(faction : String) -> Array:
	var array := []
	for c in cities.keys():
		if cities[c].faction==faction:
			array.push_back(c)
	return array

func get_nearby_locations(ID : String, max_dist : float) -> Array:
	var array := []
	var pos = get_location(ID).position
	for c in cities.keys():
		if pos.distance_squared_to(cities[c].position)<=max_dist*max_dist:
			array.push_back(c)
	return array


func get_random_position(data) -> Vector2:
	var position := Vector2()
	var min_dist := 0.0
	var traits := []
	for _i in range(100):
		min_dist = MIN_CITY_DIST
		position = data.pos+Vector2(randf()*data.spread,0.0).rotated(2.0*PI*randf())
		traits = get_terrain_traits(position)
		if "no_cities" in traits:
			continue
		if data.has("traits"):
			var has := true
			for trait in data.traits:
				if !(trait in traits):
					has = false
					continue
			if !has:
				continue
		if data.has("terrain"):
			var has := true
			var array := get_terrains(position)
			for terrain in data.terrain:
				if !(terrain in array):
					has = false
					continue
			if !has:
				continue
		for c in cities.values():
			var dist = position.distance_to(c.position)
			if dist<min_dist:
				min_dist = dist
				break
		if min_dist>=MIN_CITY_DIST:
			break
	return position

func get_terrain_traits(pos) -> Array:
	var traits := []
	for terrain in terrains:
		if pos.distance_squared_to(terrain.position)<terrain.radius*terrain.radius:
			traits += terrain.traits
	return traits

func get_terrains(pos) -> Array:
	var array := []
	for terrain in terrains:
		if pos.distance_squared_to(terrain.position)<terrain.radius*terrain.radius:
			if !(terrain.type in array):
				array.push_back(terrain.type)
	return array



func create_city(data, size:=1, traits:=[]):
	# Set up the variables for a new city.
	var name := Names.get_random_city_name(data.race)
	var position := get_random_position(data)
	var population : int
	var facilities := ["market"]
	var extra_facilities := []
	var price_mods := {}
	while cities.has(name):
		name = Names.get_random_city_name(data.race)
	population = int(rand_range(80.0,125.0)*(size+2)*(size+1)*size*size/2.0)
	if data.has("population"):
		population = int(population*data.population)
	if data.has("city_size"):
		size += data.city_size
	
# warning-ignore:unused_variable
	for i in range(2+randi()%2):
		var t = CITY_TRAITS[randi()%CITY_TRAITS.size()]
		if !(t in traits):
			traits.push_back(t)
		else:
			i -= 1
	for trait in get_terrain_traits(position):
		if !(trait in traits):
			traits.push_back(trait)
	if population<1000:
		traits.push_back("small")
	elif population>=10000:
		traits.push_back("large")
	for k in Items.commodities:
		price_mods[k] = 1.0
	for k in PRICE_MODS.keys():
		if k in traits:
			for c in PRICE_MODS[k].keys():
				price_mods[c] += PRICE_MODS[k][c]
	
# warning-ignore:unused_variable
	for i in range(int(4.0*sqrt(size/2.0)+2.5)):
		var f = FACILITIES[randi()%FACILITIES.size()]
		if !(f in facilities):
			facilities.push_back(f)
		else:
			i -= 1
	if !("inn" in facilities) && population>=5000:
		facilities.push_back("inn")
	for k in IMPORTANT_FACILITIES:
		if !(k in facilities):
			extra_facilities.push_back(k)
	if extra_facilities.size()>0:
		facilities.push_back(extra_facilities[randi()%extra_facilities.size()])
	
	add_city(name,position,data.race,population,facilities,traits,price_mods)

func add_city(name,position,faction,population,facilities,traits,price_mods):
	# Create the new city.
	var city = City.new(name,position,faction,population,facilities,traits,price_mods)
	city.set_desc()
	cities[city.name] = city
	# Add an entry to the journal.
	Journal.add_entry(city.name, city.name, ["cities",faction], city.description, BACKGROUND_IMAGES[city.landscape].file, int(time-60.0*60.0*24.0*365.0*(10.0+population/8000.0)*rand_range(0.9,1.1)))

func create_terrain(data,size,dist,angle):
	var tile := ""
	var pos = data.pos+Vector2(dist*rand_range(0.9,1.1),0.0).rotated(angle*rand_range(0.9,1.1))
	if data.has("tile"):
		tile = data.tile
	var terrain := Terrain.new(data.name,pos,size,data.travel_time,data.encounters,data.traits,tile)
	terrains.push_back(terrain)


func create_world():
	var capital
	var max_pop := 0
	var scale := 4.0
	var center := Vector2(MAP_SIZE,MAP_SIZE)
	randomize()
	# Set starting date.
	time = int(OS.get_unix_time()-60*60*24*365*rand_range(1822.0,1922.0))
	# Add terrain.
	terrains.clear()
	for data in terrain_data:
		if !data.has("pos"):
			continue
		var dist_offset := randf()
		var angle_offset := randf()
		for j in range(data.amount):
			var p := float(j)/float(data.amount-1)
			create_terrain(data,data.size[0]+(data.size[1]-data.size[0])*p,fmod(data.spread*(1.0-p+dist_offset),data.spread),2.0*PI*fmod(p+angle_offset,1.0))
	for x in range(-1.5*scale*Map.MAP_SIZE/30, 1.5*scale*Map.MAP_SIZE/30):
		for y in range(-1.5*scale*Map.MAP_SIZE/18, 1.5*scale*Map.MAP_SIZE/18):
			var pos = (x+0.5)*Vector2(60.0/2.0,36.0/2.0)+(y+0.5)*Vector2(-60.0/2.0,36.0/2.0)+scale*center
			var array := []
			for terrain in terrains:
				if pos.distance_squared_to(scale*(terrain.position+center))<scale*scale*terrain.radius*terrain.radius+10000.0*randf():
					array.push_back(terrain.tile)
			if array.size()>0:
				tiles[Vector2(x,y)] = {"tile":array[randi()%array.size()],"rnd":randi()}
	for data in terrain_data:
		if !data.has("start_pos"):
			continue
		var angle_offset := randf()
		for j in range(data.amount):
			var p := float(j)/max(data.amount-1, 1)
			var pos
			var init_dist2
			var start = (data.start_pos+Vector2(p*data.spread,0).rotated(2.0*PI*p+angle_offset))*scale
			var end = (data.end_pos+Vector2((1.0-p)*data.spread,0).rotated(2.0*PI*(1.0-p)-angle_offset))*scale
			var rnd := rand_range(-1.0,1.0)
			var last_dir := Vector2()
			start = start.x*Vector2(1.0/36.0,1.0/36.0)+start.y*Vector2(1.0/36.0,-1.0/36.0)
			start = Vector2(int(start.x),int(start.y))
			end = end.x*Vector2(1.0/36.0,1.0/36.0)+end.y*Vector2(1.0/36.0,-1.0/36.0)
			end = Vector2(int(end.x),int(end.y))
			pos = start
			init_dist2 = start.distance_squared_to(end)
			for _i in range(1000):
				var dist2 = pos.distance_squared_to(end)
				var dir = (end-pos).normalized()
				for i in range(-floor(0.5*data.width),ceil(0.5*data.width)):
					tiles[pos+Vector2(-int(i*last_dir.y),int(i*last_dir.x))] = {"tile":data.tile,"rnd":randi()}
				if dist2<=4:
					break
				if dir==Vector2():
					continue
				dir = (dir+rnd*data.variation*(1.0-min(abs(2.0*dist2-init_dist2)/init_dist2, 1.0))*Vector2(-dir.y,dir.x)).normalized()
				dir.x = int(clamp(round(rand_range(0.75,1.25)*dir.x), -1, 1))
				dir.y = int(clamp(round(rand_range(0.75,1.25)*dir.y), -1, 1))
				rnd = 0.7*rnd+0.3*rand_range(-1.0,1.0)
				if dir.x==-dir.y:
					if randf()<0.5:
						dir.x *= -1
					else:
						dir.y *= -1
				pos += dir
				last_dir = dir
	
	# Add cities.
	cities.clear()
	locations.clear()
	for data in city_data:
		for j in range(data.num_cities):
# warning-ignore:integer_division
			create_city(data,1+int(5*j/(4+data.num_cities/2.0)))
			if cities.values()[cities.size()-1].faction=="human" && cities.values()[cities.size()-1].population>max_pop && cities.values()[cities.size()-1].position.length_squared()<64*64:
				capital = cities.keys()[cities.size()-1]
				max_pop = cities.values()[cities.size()-1].population
	cities[capital].traits.push_back("capital")
	cities[capital].traits.erase("poor")
	cities[capital].facilities.push_back("imperial_palace")
	cities[capital].set_desc()
	# Adjust price mods (lower difference for nearby cities).
	for city1 in cities.values():
		for city2 in cities.values():
			if city1==city2:
				continue
			var weight = clamp(2.0*MIN_CITY_DIST/city1.position.distance_squared_to(city2.position), 0.0, 1.0)
			for k in Items.commodities:
				var mean = (city1.price_mods[k]+city2.price_mods[k])/2.0
				city1.price_mods[k] = (1.0-weight)*city1.price_mods[k] + weight*mean
				city2.price_mods[k] = (1.0-weight)*city2.price_mods[k] + weight*mean
	


func _save(file : File) -> int:
	# Add informations to save file.
	var list_terrains := {}
	var list_cities := {}
	var list_locations := {}
	for i in range(terrains.size()):
		list_terrains[i] = terrains[i].to_dict()
	for k in cities.keys():
		list_cities[k] = cities[k].to_dict()
	for k in locations.keys():
		list_locations[k] = locations[k].to_dict()
	
	file.store_line(JSON.print({"time":time}))
	file.store_line(JSON.print(list_terrains))
	file.store_line(JSON.print(tiles))
	file.store_line(JSON.print(list_cities))
	file.store_line(JSON.print(list_locations))
	return OK

func _load(file : File) -> int:
	# Load from given save file.
	var currentline = JSON.parse(file.get_line()).result
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	time = currentline.time
	
	currentline = JSON.parse(file.get_line()).result
	terrains.clear()
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	for i in currentline.keys():
		terrains.push_back(Terrain.new(currentline[i].type,Vector2(currentline[i].position[0],currentline[i].position[1]),currentline[i].radius,currentline[i].travel_time,currentline[i].encounters,currentline[i].traits,currentline[i].tile))
	
	currentline = JSON.parse(file.get_line()).result
	tiles.clear()
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	for string in currentline.keys():
		# Fix broken Vector2 data.
		var array = string.substr(1,string.length()-2).split(",")
		tiles[Vector2(int(array[0]),int(array[1]))] = currentline[string]
		tiles[Vector2(int(array[0]),int(array[1]))].rnd = int(tiles[Vector2(int(array[0]),int(array[1]))].rnd)
	
	currentline = JSON.parse(file.get_line()).result
	cities.clear()
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	for k in currentline.keys():
		cities[k] = City.new(currentline[k].name,Vector2(currentline[k].position[0],currentline[k].position[1]),currentline[k].faction,currentline[k].population,currentline[k].facilities,currentline[k].traits,currentline[k].price_mods,currentline[k].shop_seed)
		cities[k].temporary = currentline[k].temporary
		cities[k].landscape = currentline[k].landscape
	
	currentline = JSON.parse(file.get_line()).result
	locations.clear()
	if currentline==null || typeof(currentline)!=TYPE_DICTIONARY:
		return FAILED
	for k in currentline.keys():
		locations[k] = Location.new(currentline[k].name,Vector2(currentline[k].position[0],currentline[k].position[1]),currentline[k].type,currentline[k].traits,currentline[k].can_leave,currentline[k].landscape,currentline[k].temporary)
	
	return OK

func load_world(path : String):
	var dir := Directory.new()
	var error := dir.open(path)
	if error!=OK:
		print("Error when accessing "+path+"!")
		return
	
	dir.list_dir_begin(true)
	var file_name := dir.get_next()
	while file_name!="":
		if !dir.current_is_dir():
			var file := File.new()
			var err := file.open(path+"/"+file_name,File.READ)
			if err==OK:
				var currentline = JSON.parse(file.get_as_text()).result
				if currentline!=null && currentline.has("type"):
					if currentline.type=="city":
						print("Add cities "+file_name+".")
						currentline.pos = Vector2(currentline.pos[0],currentline.pos[1])
						city_data.push_back(currentline)
					elif currentline.type=="terrain":
						print("Add terrain "+file_name+".")
						if currentline.has("pos"):
							currentline.pos = Vector2(currentline.pos[0],currentline.pos[1])
						if currentline.has("start_pos"):
							currentline.start_pos = Vector2(currentline.start_pos[0],currentline.start_pos[1])
						if currentline.has("end_pos"):
							currentline.end_pos = Vector2(currentline.end_pos[0],currentline.end_pos[1])
						if currentline.has("color"):
							if typeof(currentline.color)==TYPE_ARRAY:
								currentline.color = Color(currentline.color[0],currentline.color[1],currentline.color[2])
							elif typeof(currentline.color)==TYPE_STRING:
								currentline.color = Color(currentline.color)
						if !currentline.has("travel_time"):
							currentline.travel_time = 0.0
						if !currentline.has("encounters"):
							currentline.encounters = []
						if !currentline.has("traits"):
							currentline.traits = []
						terrain_data.push_back(currentline)
			file.close()
		file_name = dir.get_next()

func _ready():
	load_world("res://data/world")
	load_world("user://data/world")
