extends Camera2D
class_name CameraShake

@export var intensity := 15.0
@export var decay := 1.0
@export var shake_frequency := 30.0

var trauma := 0.0
var shake_offset := Vector2.ZERO
var time_accum := 0.0

func _process(delta):
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)

		time_accum += delta
		var shake = trauma * trauma * intensity
		shake_offset.x = randf_range(-1.0, 1.0) * shake
		shake_offset.y = randf_range(-1.0, 1.0) * shake

		position = shake_offset
	else:
		position = Vector2.ZERO
		

func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)
