extends CanvasLayer

@onready var gold = $Container/gold_status/count
@onready var soul = $Container/soul_status/count
@onready var life_bar = $Container/life_bar
@onready var shield_bar = $Container/shield_bar

@onready var menu_ui = $UI/Menu
@onready var shop_ui = $UI/Shop
@onready var inventory_ui = $UI/Inventory

@onready var inventory_btn = $UI/Menu/buttons/inventory/btn
@onready var start_btn = $UI/Menu/buttons/start/btn
@onready var quit_btn = $UI/Menu/buttons/quit/btn
@onready var ui_bg = $UI/bg
@onready var end_ui = $end_ui

@onready var menu_btn = $Container/menu_btn
@onready var quest_btn = $Container/quest_btn
@onready var armor_btn = $Container/armor_btn
@onready var food_btn = $Container/food_btn

@onready var menu_sfx: AudioStreamPlayer = $menu_sfx


var _dialog: Array
var _dialog_index: int
var _dialog_active: bool

func _ready() -> void:
	_dialog = []
	_dialog_index = 0
	_dialog_active = false
	life_bar.max_value = Config.MAX_LIFE
	shield_bar.max_value = Config.MAX_SHIELD
	
	ui_bg.hide()
	menu_btn.pressed.connect(_on_menu_pressed)
	inventory_btn.pressed.connect(_inventory_btn_pressed)
	inventory_ui.get_node("close_btn").pressed.connect(_inventory_close_pressed)
	menu_ui.get_node("buttons/start/btn").pressed.connect(_start_pressed)
	menu_ui.get_node("buttons/quit/btn").pressed.connect(_quit_pressed)
	
	food_btn.pressed.connect(_shop_btn_pressed.bind(Config.ShopType.FOOD))
	armor_btn.pressed.connect(_shop_btn_pressed.bind(Config.ShopType.ARMOR))
	shop_ui.get_node("close_btn").pressed.connect(_shop_close_pressed)
	quest_btn.pressed.connect(func():LevelManager.load_level(LevelManager.current_level+1))
	
	
	
func _process(delta: float) -> void:
	armor_btn.visible = Config.show_armor_shop_btn
	food_btn.visible = Config.show_food_shop_btn
	quest_btn.visible = Config.show_quest_btn
	menu_ui.visible = Config.show_menu
	ui_bg.visible = Config.show_menu
	shop_ui.visible = Config.show_shop
	inventory_ui.visible = Config.show_inventory
	end_ui.visible = Config.show_endui
		
	gold.text = str(Config.coins)
	soul.text = str(Config.souls)
	life_bar.value = Config.life
	shield_bar.value = Config.shield
	
	
func _on_menu_pressed():
	menu_sfx.play()
	Config.show_menu = !Config.show_menu
	if(Config.show_menu):
		Config.show_armor_shop_btn = false
		Config.show_food_shop_btn = false
		Config.show_quest_btn = false
		Config.show_shop = false
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1
		ui_bg.hide()
	
func _shop_btn_pressed(type:Config.ShopType):
	menu_sfx.play()
	Config.show_shop = true
	Config.shop_type = type

func _inventory_btn_pressed():
	menu_sfx.play()
	Config.show_inventory=true

func _shop_close_pressed():
	menu_sfx.play()
	Config.ui_loaded = false
	Config.show_shop = false

func _inventory_close_pressed():
	menu_sfx.play()
	Config.ui_loaded = false
	Config.show_inventory=false

func _start_pressed():
	menu_sfx.play()
	Engine.time_scale = 1
	Config.show_menu = false
	
func _quit_pressed():
	menu_sfx.play()
	get_tree().quit()
