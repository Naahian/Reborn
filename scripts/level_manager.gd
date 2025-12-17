extends Node

signal level_loaded(level_path: String)
signal returning_to_village()

const LEVELS: Array = [
	preload("res://scenes/levels/intro_level.tscn"),
	preload("res://scenes/levels/level_1.tscn"),
]
const VILLAGE_SCENE = preload("res://scenes/levels/village.tscn")

var current_level: int = -1 # -1 means in village


func _ready():
	print("LevelManager initialized with %d levels" % LEVELS.size())

func load_level_as_node(level_no: int) -> Node:
	if level_no < 0 or level_no >= LEVELS.size():
		push_error("Invalid level number: %d" % level_no)
		return null
	
	var level_scene = LEVELS[level_no]
	current_level = level_no
	return level_scene.instantiate()


func load_village_as_node() -> Node:
	# No need to check if preloaded resource exists
	# If preload failed, the game wouldn't compile
	return VILLAGE_SCENE.instantiate()


func load_level(level_no: int) -> void:
	var level = get_node("/root/main/level")
	print("before loading:", level.get_children())

	# Remove old levels
	for lvl in level.get_children():
		lvl.free()
	
	# Load new level from LevelManager
	var newLevel = null
	if level_no == -1:
		newLevel = load_village_as_node()
	else:
		newLevel = load_level_as_node(level_no)
	
	if newLevel:
		level.add_child(newLevel)
		print("after loading:", level.get_children())
	else:
		push_error("Failed to create level node for level_no: %d" % level_no)

func is_last_level() -> bool:
	return current_level == LEVELS.size() - 1

func get_progress_percentage() -> float:
	if current_level < 0:
		return 0.0
	return (float(current_level + 1) / LEVELS.size()) * 100.0
