extends Node2D

@export var max_distance: float = 1000.0
@export var power_speed_per_sec: float = 1200.0
@export var arc_height: float = 150.0
@export var texture: Texture2D
@export var origin_position: Vector2 = Vector2(0, 0)
@export var stream_scroll_speed: float = 1.5
@export var power_increase_per_click: float = 0.1
@export var power_decay_per_sec: float = 200.0
@export var power_rise_speed: float = 800.0
@export var power_fall_speed: float = 300.0
@export var drop_amount: float = 300.0
@export var tank: Area2D

var current_distance: float = 0.0
var target_distance: float = 0.0
var holding_mouse: bool = false
var stream_offset: float = 0.0  # 🔄 for animated motion

const SEGMENT_COUNT := 20
var segments := []

var hit_radius := 32.0
var hit_circle := CircleShape2D.new()
var query_params := PhysicsShapeQueryParameters2D.new()


func _ready():
	var tanks = get_tree().get_nodes_in_group("tank")
	if tanks.size() > 0:
		tank = tanks[0]
	hit_circle.radius = hit_radius
	query_params.shape = hit_circle
	query_params.collision_mask = 1
	
	for i in range(SEGMENT_COUNT):
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true
		add_child(sprite)
		segments.append(sprite)

	set_process_input(true)
	set_process(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_distance += max_distance * power_increase_per_click
			target_distance = min(target_distance, max_distance)

func _process(delta):
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_distance -= power_decay_per_sec * delta
		target_distance = max(target_distance, 0)

	if current_distance < target_distance:
		current_distance += power_rise_speed * delta
		if current_distance > target_distance:
			current_distance = target_distance
	elif current_distance > target_distance:
		current_distance -= power_fall_speed * delta
		if current_distance < target_distance:
			current_distance = target_distance

	# Animate only if power > 0
	if current_distance > 0:
		stream_offset += delta * stream_scroll_speed
		stream_offset = fmod(stream_offset, 1.0)
		_update_segments()
	else:
		for s in segments:
			s.visible = false

func _update_segments():
	if current_distance <= 5.0:
		for s in segments:
			s.visible = false
		return

	for i in range(SEGMENT_COUNT):
		var t = fmod(float(i) / float(SEGMENT_COUNT - 1) + stream_offset, 1.0)

		var x = t * current_distance
		var y = -arc_height * sin(t * PI) + t * drop_amount

		var local_pos = Vector2(x, y)
		var world_pos = origin_position + local_pos

		var dt = 0.001
		var p0 = Vector2(x, y)
		var p1 = Vector2((t + dt) * current_distance, -arc_height * sin((t + dt) * PI))
		var direction = (p1 - p0).normalized()
		var angle = direction.angle()

		var sprite = segments[i]
		sprite.visible = true
		sprite.position = world_pos
		sprite.rotation = angle

	var last_pos = segments[SEGMENT_COUNT - 1].global_position
	var circle_transform = Transform2D(0, last_pos)
	var is_hitting := false

	if tank:
		var shape_node = tank.get_node_or_null("CollisionShape2D")
		if shape_node:
			var tank_shape: Shape2D = shape_node.shape
			if hit_circle.collide(circle_transform, tank_shape, tank.global_transform):
				is_hitting = true

	if is_hitting:
		tank.fill(get_process_delta_time())
	
	tank.call("on_stream_hit", is_hitting)
