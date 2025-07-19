extends Control

@export var max_psi: float = 100.0
@export var psi_increase_per_second: float = 50.0
@export var psi_decay_per_second: float = 25.0

var current_psi: float = 0.0
var mouse_held := false

@onready var bar: ColorRect = $Bar
var max_width: float = 200.0  # Will be set in _ready()

func _ready():
	max_width = bar.size.x

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_held = event.pressed

func _process(delta):
	if mouse_held:
		current_psi += psi_increase_per_second * delta
	else:
		current_psi -= psi_decay_per_second * delta

	current_psi = clamp(current_psi, 0.0, max_psi)
	set_psi(current_psi)

func set_psi(value: float):
	var ratio = clamp(value / max_psi, 0.0, 1.0)
	bar.size.x = ratio * max_width

	# Color fade from white to red
	var color = Color(
		1.0,                 # R stays full
		1.0 - ratio,         # G fades out
		1.0 - ratio          # B fades out
	)
	bar.color = color
