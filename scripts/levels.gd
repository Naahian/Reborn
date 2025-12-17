extends Node

@onready var checkpoints = $checkpoints

var level_name: String

func _ready():
	level_name = name
	checkpoints.get_node("end").body_entered.connect(_on_checkpoint_end_entered)
	checkpoints.get_node("start").body_entered.connect(_on_start_entered)
	checkpoints.get_node("start").body_exited.connect(func():Config.show_chatbox = false)
	
func _on_checkpoint_end_entered(body):
	if body.is_in_group("Player"):
		Config.show_endui = true
		get_node("/root/main/Tap").play()
		body.set_physics_process(false)
		await get_tree().create_timer(3.0).timeout
		LevelManager.load_level(-1)
		Config.show_endui = false

func _on_start_entered(body):
	if(body.name == "player" and LevelManager.current_level == 0):
		Config.show_chatbox = true
		

	
