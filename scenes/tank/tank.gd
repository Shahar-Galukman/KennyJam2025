class_name Tank
extends Area2D

var fill_amount := 0.0
@export var fill_speed := 20.0  # how fast it fills per second

var elapsed_time := 0.0

func _process(delta):
	elapsed_time += delta
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.material:
		var mat := sprite.material as ShaderMaterial
		mat.set_shader_parameter("fill_level", fill_amount / 100.0)
		mat.set_shader_parameter("time",elapsed_time)


func fill(delta: float):
	fill_amount += fill_speed * delta
	fill_amount = clamp(fill_amount, 0.0, 100.0)  # example max = 100
	print("Tank filled:", fill_amount)
