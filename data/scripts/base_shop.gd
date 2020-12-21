extends Node

var type_filter := []
var proficiency_filter := []
var all_items := []
var items := []
var rng := RandomNumberGenerator.new()
var buy_price := 1.0
var sell_price := 0.2
var currency := "silver_coins"
var mode := "buy"
var min_items := 4
var max_items := 6


func set_shop_seed(sd):
	rng.seed = sd

func update_actions(last_action:=""):
	if mode=="buy":
		for i in range(items.size()):
			var item = items[i]
			var amount := 1
			if item.has("amount"):
				amount = item.amount
			var item_price := get_price(item, amount, buy_price)
			var node
			var item_str = item.name
			if amount!=1:
				item_str = str(amount)+"x "+item_str
			var action := Game.Action.new(tr("BUY_ITEM").format({"item":item_str,"price":item_price,"currency":tr(Items.items[currency].name.to_upper())}),self,{0:{"method":"buy_item","grade":1}},"charisma","cunning",2)
			action.ID = i
			node = Main.add_action(action)
			node.get_node("Button").hint_tooltip = Main.create_item_tooltip_text(item)
			if Items.get_item_amount(currency)<item_price:
				node.get_node("Button").disabled = true
		if items.size()==0:
			if last_action=="buy":
				mode = "sell"
				update_actions()
				return
			else:
				Main.add_text(tr("NO_ITEMS_FOR_SALE")+"\n")
		Main.add_action(Game.Action.new(tr("SELL_ITEMS"),self,{0:{"method":"sell_items","grade":1}},"","",1,0))
	elif mode=="sell":
		var num_items := 0
		for i in range(Characters.inventory.size()):
			var item = Characters.inventory[i]
			if !(item.type in type_filter) || (proficiency_filter.size()!=0 && (item.has("proficiency") && !(item.proficiency in proficiency_filter))) || item.base_type==currency:
				continue
			var amount := 1
			if item.has("amount"):
				amount = item.amount
			var item_str = item.name
			if amount!=1:
				item_str = str(amount)+"x "+item_str
			var item_price := get_price(item, amount, sell_price)
			var action := Game.Action.new(tr("SELL_ITEM").format({"item":item_str,"price":item_price,"currency":tr(Items.items[currency].name.to_upper())}),self,{0:{"method":"sell_item","grade":1}},"charisma","cunning",2,0)
			var node
			action.ID = i
			node = Main.add_action(action)
			node.get_node("Button").hint_tooltip = Main.create_item_tooltip_text(item)
			num_items += 1
		if num_items==0:
			if last_action!="sell":
				Main.add_text(tr("NO_INTERESTING_ITEMS")+"\n")
			mode = "buy"
			update_actions()
			return
		else:
			Main.add_action(Game.Action.new(tr("BUY_ITEMS"),self,{0:{"method":"buy_items","grade":1}},"","",1))
	Main.add_action(Game.Action.new(tr("GO_BACK"),self,{0:{"method":"leave","grade":1}},"","",3))

func gather_items():
	for k in Items.items.keys():
		var item = Items.items[k]
		if item.name!=currency && (type_filter.size()==0 || item.type in type_filter) && (proficiency_filter.size()==0 || (item.has("proficiency") && item.proficiency in proficiency_filter)) && k!=currency:
			all_items.push_back(k)

func add_items():
	if all_items.size()==0:
		return
	items.resize(min_items+rng.randi()%int(max(max_items-min_items+1,1)))
	for i in range(items.size()):
		items[i] = Items.create_item(all_items[randi()%all_items.size()])
		if items[i].type=="currency" || items[i].type=="ingredient" || items[i].type=="supplies" || items[i].type=="commodities":
			items[i].amount = 10

func add_commodities():
	for k in Items.commodities:
		if Map.cities.has(Game.location) && Map.cities[Game.location].price_mods.has(k) && Map.cities[Game.location].price_mods[k]>1.2:
			continue
		var amount := 10
		items.push_back(Items.create_item(k,true,amount))

func get_price(item, amount, multiplier) -> int:
	if item.type=="currency":
		return item.price*amount
	elif Map.cities.has(Game.location) && Map.cities[Game.location].price_mods.has(item.base_type):
		return int(ceil(item.price*amount*Map.cities[Game.location].price_mods[item.base_type]))
	else:
		return int(ceil(item.price*multiplier*amount))

func buy_items(_actor,_action,_roll):
	mode = "buy"
	update_actions()

func sell_items(_actor,_action,_roll):
	mode = "sell"
	update_actions()

func buy_item(actor,action,roll):
	var item = items[action.ID]
	var skill = 0
	if actor.proficiency.has("bargaining"):
		skill = actor.proficiency.bargaining
	var multiplier := max(1.0-max(roll-10.0,0.0)/40.0*(1.0+0.5*skill),0.5)
	var amount := 1
	if item.has("amount"):
		amount = item.amount
	var item_price := get_price(item, amount, buy_price*multiplier)
	if multiplier>=1.0:
		Main.add_text("\n"+tr("YOU_BUY_ITEM").format({"item":item.name,"price":item_price,"currency":tr(Items.items[currency].name.to_upper())})+"\n\n")
	else:
		Main.add_text("\n"+tr("YOU_BUY_ITEM_CHEAPER").format({"item":item.name,"price":item_price,"currency":tr(Items.items[currency].name.to_upper())})+"\n\n")
	Items.add_item(item, amount)
	Items.remove_items(currency, item_price)
	if item.type!="commodities" && item.type!="supplies":
		items.remove(action.ID)
	update_actions("buy")

func sell_item(actor,action,roll):
	var item = Characters.inventory[action.ID]
	var skill = 0
	if actor.proficiency.has("bargaining"):
		skill = actor.proficiency.bargaining
	var multiplier := min(1.0+max(roll-10.0,0.0)/40.0*(1.0+0.5*skill),0.5/sell_price)
	var amount := 1
	if item.has("amount"):
		amount = item.amount
	var item_price := get_price(item, amount, sell_price*multiplier)
	Main.add_text("\n"+tr("YOU_SELL_ITEM").format({"item":item.name,"price":item_price,"currency":tr(Items.items[currency].name.to_upper())})+"\n\n")
	Items.remove_item(item)
	Items.add_items(currency, item_price)
	items.push_back(item)
	update_actions("sell")

func leave(_actor,_action,_roll):
	Game.enter_location(Game.location)
	Map.time += 60*2
