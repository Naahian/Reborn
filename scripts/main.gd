extends Node2D

@onready var player = $player
@onready var level = $level
@onready var deathzone:Area2D = $deathzone
@export var start_level = 0

func _ready() -> void:
	Config.show_menu = true
	Engine.time_scale = 0
	LevelManager.load_level(start_level) # Load first level
	deathzone.body_entered.connect(_deathzone_entered)

func _deathzone_entered(body):
	if(body.name=="player"):
		body.die()
	if(body.name.contains("enemy")):
		body.die()
