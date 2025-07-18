class_name Tank
extends Area2D

var fill_amount := 0.0
@export var fill_speed := 10.0  # how fast it fills per second


func fill(delta: float):
	fill_amount += fill_speed * delta
	fill_amount = clamp(fill_amount, 0.0, 100.0)  # example max = 100
	print("Tank filled:", fill_amount)
