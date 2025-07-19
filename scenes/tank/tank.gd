class_name Tank
extends Area2D

var fill_amount := 0.0
@export var fill_speed := 20.0
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fill_value: Label = %FillValue

var elapsed_time := 0.0
var colliding := false
var stop_audio_timer := 0.0
@export var stop_audio_delay := 1


func _process(delta):
	elapsed_time += delta
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.material:
		var mat := sprite.material as ShaderMaterial
		mat.set_shader_parameter("fill_level", fill_amount / 100.0)
		mat.set_shader_parameter("time", elapsed_time)

	if colliding:
		if not audio_stream_player_2d.playing:
			audio_stream_player_2d.play()
		stop_audio_timer = 0.0
	else:
		if audio_stream_player_2d.playing:
			stop_audio_timer += delta
			if stop_audio_timer >= stop_audio_delay:
				audio_stream_player_2d.stop()

func fill(delta: float):
	var previous_amount = fill_amount
	fill_amount += fill_speed * delta
	fill_amount = clamp(fill_amount, 0.0, 100.0)
	fill_value.text = str(int(fill_amount))

	if fill_amount > previous_amount:
		animate_fill_text()

	if fill_amount >= 100:
		get_tree().change_scene_to_file("res://scenes/main_menu/game_won.tscn")		
	

func on_stream_hit(hit: bool):
	colliding = hit
	
func animate_fill_text():
	fill_value.pivot_offset = fill_value.size / 2
	fill_value.modulate = Color(1, 1, 1, 1)  # make sure it's full color

	var tween := create_tween()
	tween.tween_property(fill_value, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(fill_value, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(fill_value, "modulate", Color(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(fill_value, "modulate", Color(1, 1, 1), 0.2)
