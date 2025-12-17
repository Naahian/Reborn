extends Node2D

@onready var armor_npc:Area2D = $checkpoints/armor_npc
@onready var food_npc:Area2D = $checkpoints/food_npc
@onready var end:Area2D = $checkpoints/end

func _ready() -> void:

	armor_npc.body_entered.connect(_on_armor_entered)
	armor_npc.body_exited.connect(_on_armor_exited)
	food_npc.body_entered.connect(_on_food_entered)
	food_npc.body_exited.connect(_on_food_exited)
	end.body_entered.connect(_on_end_entered)
	end.body_exited.connect(_on_end_exited)

func _on_armor_entered(body):
	if body.name == "player":
		Config.show_armor_shop_btn = true

func _on_armor_exited(body):
	Config.show_armor_shop_btn = false
	
func _on_food_entered(body):
	if body.name == "player":
		Config.show_food_shop_btn = true

func _on_food_exited(body):
		Config.show_food_shop_btn = false
		

func _on_end_entered(body):
	if body.name == "player":
		Config.show_quest_btn = true

func _on_end_exited(body):
	Config.show_quest_btn = false
