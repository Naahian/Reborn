extends CanvasLayer

@onready var shop_slots = $Shop/items
@onready var inventory_slots = $Inventory/items

@onready var use_item_sfx: AudioStreamPlayer = $use_item_sfx
@onready var buy_sfx: AudioStreamPlayer = $"buy_sfx"

func _process(delta: float) -> void:
	if(Config.show_shop and not Config.ui_loaded):
		_load_shop_items(Config.shop_type)
		Config.ui_loaded = true
	if(Config.show_inventory and not Config.ui_loaded):
		_load_inventory_items()
		Config.ui_loaded = true
		
		
func _clear_shop_slots():
	for slot in shop_slots.get_children():
		slot.get_node("content/icon").texture = null  
		slot.get_node(("content/price_box/Label")).text = "00"
		slot.name = ""
		if slot.get_node("btn").pressed.is_connected(_shop_item_pressed):
			slot.get_node("btn").pressed.disconnect(_shop_item_pressed)

func _load_shop_items(type:Config.ShopType):
	_clear_shop_slots()
	var items = []
	if(type == Config.ShopType.FOOD): items = Config.foodItems
	elif(type == Config.ShopType.ARMOR): items = Config.armorItems
	print(type)
	for i in range(len(items)):
		var slot = shop_slots.get_child(i)
		slot.get_node("content/icon").texture = items[i]["image"]
		slot.get_node("content/price_box/Label").text = str(items[i]["price"])
		slot.name = items[i]["id"]
		slot.get_node("btn").pressed.connect(_shop_item_pressed.bind(items[i]))
		

func _clear_inventory_slots():
	for slot in inventory_slots.get_children():
		slot.name = ""
		slot.get_node("icon").texture = null
		if slot.get_node("btn").pressed.is_connected(_inventory_item_pressed):
			slot.get_node("btn").pressed.disconnect(_inventory_item_pressed)


func _load_inventory_items():
	print("GG")
	_clear_inventory_slots()
	var items = Config.inventory

	for i in range(len(items)):
		var slot = inventory_slots.get_child(i)
		var btn = slot.get_node("btn")
		# Update visuals
		slot.get_node("icon").texture = items[i]["image"]
		slot.name = items[i]["id"]
		# Reconnect
		btn.pressed.connect(_inventory_item_pressed.bind(slot))


func _shop_item_pressed(item):
	buy_sfx.play()
	print(item["price"])
	print(Config.coins)
	if(item["price"] > Config.coins): return
	Config.coins -= item["price"]
	if(len(Config.inventory) < 7):
		Config.inventory.append(item)


func _inventory_item_pressed(slot):
	use_item_sfx.play()
	for i in range(len(Config.inventory)):
		if Config.inventory[i]["id"] == slot.name:
			if Config.inventory[i]["type"] == Config.ShopType.FOOD:
				Config.life += Config.inventory[i]["value"]
			elif Config.inventory[i]["type"] == Config.ShopType.ARMOR:
				Config.shield += Config.inventory[i]["value"]
			Config.inventory.remove_at(i)
			break
	slot.get_node("icon").texture = null
