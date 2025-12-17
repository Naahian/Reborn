extends Node

const MAX_LIFE: int = 5
const MAX_SHIELD: int = 5


#player
var life: int = 5
var shield: int = 1
var coins: int = 0
var souls: int = 0

#UI
enum ShopType {FOOD, ARMOR}
var shop_type:ShopType = ShopType.FOOD
var show_inventory: bool = false
var show_shop:bool = false
var show_menu:bool = false
var show_chatbox: bool = false
var show_endui: bool = false
var ui_loaded:bool = false

var show_quest_btn: bool = false
var show_armor_shop_btn:bool = false
var show_food_shop_btn:bool = false


var foodItems = [
	{"id":"1", "type":ShopType.FOOD, "image":preload("res://assets/items/food/item009.png"),"price":10, "value":2},
	{"id":"2", "type":ShopType.FOOD, "image":preload("res://assets/items/food/item010.png"),"price":15, "value":3},
	{"id":"3", "type":ShopType.FOOD, "image":preload("res://assets/items/food/item011.png"),"price":20, "value":4},
	{"id":"4", "type":ShopType.FOOD, "image":preload("res://assets/items/food/item016.png"),"price":30, "value":5},
]

var armorItems = [
	{"id":"5", "type":ShopType.ARMOR, "image":preload("res://assets/items/armor/item006.png"),"price":10, "value":2},
	{"id":"6", "type":ShopType.ARMOR, "image":preload("res://assets/items/armor/item007.png"),"price":15, "value":3},
	{"id":"7", "type":ShopType.ARMOR, "image":preload("res://assets/items/armor/item039.png"),"price":30, "value":5},
]

var inventory = [
]


#methods
func reset_player_stats() -> void:
	life = MAX_LIFE
	shield = MAX_SHIELD / 2
	coins = 0
	inventory.clear()
