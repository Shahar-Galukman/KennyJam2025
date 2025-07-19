extends Control

@export var max_psi: float = 100.0
@export var psi_increase_per_second: float = 70.0
@export var psi_decay_per_second: float = 5.0

var overpressure_time: float = 0.0
var current_psi: float = 0.0
var mouse_held := false

@onready var bar: ColorRect = $Bar
var max_width: float = 200.0
var shake_camera: CameraShake
@onready var bladder_blow: Label = %BladderBlow
@onready var death_counter: Label = %DeathCounter

@onready var groans := [
	$Groan1,
	$Groan2,
	$Groan3,
	$Groan4,
	$Groan5
]
var current_level := 0


func _ready():
	max_width = bar.size.x
	shake_camera = get_node("/root/World/WorldCamera")
	current_level = 0
	groans[0].play()

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

	if current_psi >= 95.0:
		overpressure_time += delta
		bladder_blow.show()
		death_counter.show()
		death_counter.text = String("%.2f" % (5.0 - overpressure_time))
		if overpressure_time >= 5.0:
			get_tree().change_scene_to_file("res://scenes/main_menu/game_over.tscn")
	else:
		overpressure_time = 0.0
		bladder_blow.hide()
		death_counter.hide()
		

	var psi_ratio := current_psi / max_psi

	if psi_ratio > 0.8 and shake_camera:
		var trauma := (psi_ratio - 0.8) / 0.2
		shake_camera.add_trauma(trauma * delta * 2.0)
	
	var new_level := 0
	if current_psi > 25: new_level = 1
	if current_psi > 50: new_level = 2
	if current_psi > 75: new_level = 3
	if current_psi > 95: new_level = 4

	if new_level != current_level:
		if new_level > current_level:
			for g in groans:
				g.stop()
			groans[new_level].play()
			current_level = new_level
		else:
			if not groans[current_level].playing:
				current_level = new_level
				for g in groans:
					g.stop()
				groans[new_level].play()

func set_psi(value: float):
	var ratio = clamp(value / max_psi, 0.0, 1.0)
	bar.size.x = ratio * max_width

	var color = Color(
		1.0,
		1.0 - ratio,
		1.0 - ratio
	)
	bar.color = color
