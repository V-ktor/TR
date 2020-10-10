extends Panel

var focused_map := 0

func show_map():
	var pos = $ScrollContainer/Map.scale*(Map.get_location(Game.location).position+$ScrollContainer/Map.center)
	$ScrollContainer/Map.update()
	$ScrollContainer/Map._select(Game.location)
	$ScrollContainer.scroll_horizontal = pos.x-$ScrollContainer.rect_size.x/2
	$ScrollContainer.scroll_vertical = pos.y-$ScrollContainer.rect_size.y/2
	focused_map = 2
	show()

func set_info(selected):
	var dist = Map.get_location(Game.location).position.distance_to(Map.get_location($ScrollContainer/Map.selected).position)
	var time := round(60*dist/Characters.get_travel_speed())
	var str_fuel_c := ""
	var fuel_consumption := {}
	var rations = Characters.party.size()*dist/8.0
	var time_str := str(time).pad_zeros(2)+tr("MIN")
	if time>60.0:
		time_str = str(floor(time/60.0)).pad_zeros(2)+":"+str(round(time-60*floor(time/60.0))).pad_zeros(2)+tr("H")
	for mount in Characters.mounts:
		if mount.active && mount.has("fuel") && mount.has("fuel_consumption"):
			if fuel_consumption.has(mount.fuel):
				fuel_consumption[mount.fuel] += mount.fuel_consumption
			else:
				fuel_consumption[mount.fuel] = mount.fuel_consumption
	for i in range(fuel_consumption.size()):
		var fuel = fuel_consumption.keys()[i]
		str_fuel_c += str(ceil(fuel_consumption[fuel]*dist/8.0))+" "+tr(fuel.to_upper())
		if i+1<fuel_consumption.size():
			str_fuel_c += ", "
	if str_fuel_c.length()==0:
		str_fuel_c = tr("NONE")
	$Info/ScrollContainer/VBoxContainer/Info.clear()
	if selected.type=="city":
		$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(1.0,1.0,1.0))
		$Info/ScrollContainer/VBoxContainer/Info.add_text(selected.name+"\n"+tr(selected.faction.to_upper())+"\n")
		if Characters.relations.has(selected.faction):
			var relation = Characters.relations[selected.faction]
			$Info/ScrollContainer/VBoxContainer/Info.add_text(tr("RELATION")+": ")
			if relation<=-50:
				$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(1.0,0.1,0.1))
			elif relation<=-10:
				$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(0.9,0.9,0.1))
			elif relation<10:
				$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(1.0,1.0,1.0))
			elif relation<50:
				$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(0.7,1.0,0.5))
			else:
				$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(0.2,1.0,0.1))
			$Info/ScrollContainer/VBoxContainer/Info.add_text(str(relation)+"\n")
		$Info/ScrollContainer/VBoxContainer/Info.push_color(Color(1.0,1.0,1.0))
		$Info/ScrollContainer/VBoxContainer/Info.add_text(tr("POPULATION")+": "+str(selected.population)+"\n"+tr("DISTANCE")+": "+str(dist).pad_decimals(1)+"km\n"+tr("TRAVEL_TIME")+": "+time_str+"\n"+tr("SUPPLIES_REQUIRED")+": "+str(rations).pad_decimals(1)+"\n"+tr("FUEL_CONSUMPTION")+": "+str_fuel_c+"\n"+tr("FACILITIES")+":\n")
		for s in selected.facilities:
			$Info/ScrollContainer/VBoxContainer/Info.add_text("  "+tr(s.to_upper())+"\n")
		$Info/ScrollContainer/VBoxContainer/Info.newline()
		$Info/ScrollContainer/VBoxContainer/Info.add_text(tr("COMMODITY_PRICES")+":\n")
		for k in selected.price_mods.keys():
			if Items.items[k].type=="commodities":
				$Info/ScrollContainer/VBoxContainer/Info.add_text("  "+tr(k.to_upper())+": "+str(selected.price_mods[k]*Items.items[k].price).pad_decimals(1)+"\n")
	else:
		$Info/ScrollContainer/VBoxContainer/Info.add_text(selected.name+"\n"+tr("DISTANCE")+": "+str(dist).pad_decimals(1)+"km\n"+tr("TRAVEL_TIME")+": "+time_str+"\n"+tr("SUPPLIES_REQUIRED")+": "+str(rations).pad_decimals(1)+"\n"+tr("FUEL_CONSUMPTION")+": "+str_fuel_c)

func _goto():
	if Map.get_location($ScrollContainer/Map.selected).temporary:
		return
	Game.goto($ScrollContainer/Map.selected)

func draw_footprint(pos,rot):
	$ScrollContainer/Map.draw_footprint(pos,rot)

func disable():
	$Info/ScrollContainer/VBoxContainer/Button.disabled = true
	printt("DISABLE TRAVEL")

func enable():
	$Info/ScrollContainer/VBoxContainer/Button.disabled = false
	printt("ENABLE TRAVEL")


func _process(_delta):
	focused_map -= 1
	if focused_map>0:
		var pos = $ScrollContainer/Map.scale*(Map.get_location(Game.location).position+$ScrollContainer/Map.center)
		$ScrollContainer.scroll_horizontal = pos.x-$ScrollContainer.rect_size.x/2
		$ScrollContainer.scroll_vertical = pos.y-$ScrollContainer.rect_size.y/2
		focused_map = true

func _ready():
	$Info/ScrollContainer/VBoxContainer/Button.connect("pressed",self,"_goto")
