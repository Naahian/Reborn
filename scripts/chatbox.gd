extends NinePatchRect

@onready var label = $Label
@onready var sfx = $Tap

var intro_level_dialog = [
	"[Wizard]: You are awake at last, my King.",
	"[Player]: What… happened? Where am I?",
	"[Wizard]: I pulled your soul back from death.",
	"[Player]: My soul… pulled back? How is that possible?",
	"[Wizard]: Your kingdom has fallen into chaos.",
	"[Player]: Chaos? Who dares threaten my kingdom?",
	"[Wizard]: The corrupt minister you trusted betrayed you on the battlefield.",
	"[Player]: That traitor… I will make him pay.",
	"[Wizard]: I bound that soul to this fragile form. To regain your full human body, you must collect 15 souls.",
	"[Player]: Fifteen souls… I will find them all.",
	"[Wizard]: For now, proceed to the nearby village.",
	"[Player]: Okay",
]

var dialog_lines: Array = []
var current_index: int = 0
var is_active: bool = false

func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	if (Config.show_chatbox == true) and (self.visible != true):
		
		start_dialog(intro_level_dialog)
	self.visible = Config.show_chatbox

func _input(event: InputEvent) -> void:
	if is_active and event.is_pressed() and not event.is_echo():
		_show_next_line()

func start_dialog(lines: Array) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.set_physics_process(false)
	player.get_node("AnimatedSprite2D").play("idle")	#TODO:fix hardcoded later
	
	dialog_lines = lines
	current_index = 0
	is_active = true
	self.visible = true
	_show_next_line()

func _show_next_line() -> void:
	sfx.play()
	if current_index >= len(dialog_lines):
		_end_dialog()
		return
	label.text = dialog_lines[current_index]
	current_index += 1

func _end_dialog() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.set_physics_process(true)
	is_active = false
	self.visible = false
	label.text = ""
	dialog_lines = []
	current_index = 0
	Config.show_chatbox = false
