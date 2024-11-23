@tool
extends RigidBody2D
var drag_offset = Vector2()
var is_mouse_dragging = false
var is_mouse_hover = false
var grid_size: float = 100  # Grid size matches the circle diameter
var physics_impulse_multiplier = 100
var selected = false
signal on_select(node)
signal on_blur(node)

@onready var canvas: Node2D = get_node("Canvas")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@export var camera: Camera2D
@export var speed:= 0.2
var grid_tolerance:= 15

func _ready() -> void:
	collision_shape.shape.radius = canvas.circle_radius
	grid_size = 2 * canvas.circle_radius
	connect("mouse_entered", _on_mouse_enter)
	connect("mouse_exited", _on_mouse_exit)

	# TO REMOVE
	canvas.circle_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))


func _process(delta: float) -> void:
	pass


func focus_section():
	animation_player.play("mouse_in")


func blur_section():
	animation_player.play("mouse_out")


func _on_mouse_enter():
	is_mouse_hover = true
	focus_section()


func _on_mouse_exit():
	is_mouse_hover = false
	var selected_sections = get_tree().get_nodes_in_group("selected_sections")
	if self in selected_sections:
		return
	blur_section()


func _input(event):
	if is_mouse_hover and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.ctrl_pressed:
				var selected_sections = get_tree().get_nodes_in_group("selected_sections")
				for sec in selected_sections:
					sec.remove_from_group("selected_sections")
					if sec != self:
						sec.blur_section()
			add_to_group("selected_sections")
			
			on_select.emit(self)

	# check_left_click(event)
	# check_right_click(event)
	# check_mouse_button_up(event)

	# update_mouse_drag(event)
	# if is_mouse_dragging:
	# 	# global_position = camera.get_global_mouse_position()  + drag_offset

	# 	# Snapping
	# 	var target = camera.get_global_mouse_position() + drag_offset
	# 	var sections = get_tree().get_nodes_in_group("static_sections")
	# 	var found_x = false
	# 	var found_y = false
	# 	var new_x = target.x
	# 	var new_y = target.y

	# 	var target_tolerance = grid_tolerance / camera.get_viewport_transform().x[0]

	# 	for item in sections:
	# 		if item.name != name:
	# 			if not found_x and Vector2(item.position.x, 0).distance_to(Vector2(target.x, 0)) < target_tolerance:
	# 				new_x = item.position.x
	# 				found_x = true

	# 			if not found_y and Vector2(0, item.position.y).distance_to(Vector2(0, target.y)) < target_tolerance:
	# 				new_y = item.position.y
	# 				found_y = true

		
	# 	global_position.x = new_x if found_x else target.x
	# 	global_position.y = new_y if found_y else target.y
			
	# 	# global_position = Vector2(
	# 	# 	round(target.x / grid_size) * grid_size,
	# 	# 	round(target.y / grid_size) * grid_size
	# 	# )

# 	check_collision(event)




# func check_collision(event):
# 	if is_mouse_dragging and event is InputEventMouseMotion:

# 		# Check for collisions with other objects
# 		var space_state = get_world_2d().direct_space_state
# 		var query = PhysicsShapeQueryParameters2D.new()
# 		query.shape = CircleShape2D.new()
# 		query.shape.radius = canvas.circle_radius
# 		query.transform.origin = global_position
# 		query.collision_mask = collision_layer

# 		var results = space_state.intersect_shape(query)
# 		for result in results:
# 			var other_body = result.collider as RigidBody2D
# 			if other_body:
# 				var impulse = (other_body.global_position - global_position).normalized()
# 				other_body.apply_central_impulse(impulse * physics_impulse_multiplier)


# func check_mouse_button_up(event):
# 	if event is InputEventMouseButton and not event.pressed:
# 		add_to_group("static_sections")
# 		is_mouse_dragging = true


# func on_right_click(event):
# 	canvas.circle_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))


# func on_left_click(event):
# 	prioritize_physics()
# 	remove_from_group("static_sections")



# func prioritize_physics():
# 	# deactivate physics
# 	freeze = true
# 	sleeping = true
# 	linear_velocity = Vector2.ZERO
# 	collision_priority = 10000


# func reset_physics():
# 	freeze = false
# 	collision_priority = 1


# func check_left_click(event):
# 	if event is InputEventMouseButton:
# 		if event.pressed && is_mouse_hover and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
# 			on_left_click(event)

# func check_right_click(event):
# 	if event is InputEventMouseButton:
# 		if event.pressed && is_mouse_hover and event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
# 			on_right_click(event)


# func update_mouse_drag(event):
# 	if event is InputEventMouseButton:
# 		if event.pressed && is_mouse_hover and not is_mouse_dragging and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
# 			if not is_mouse_dragging:
# 				drag_offset = global_position - camera.get_global_mouse_position()
# 				is_mouse_dragging = true

# 		elif is_mouse_dragging:
# 			is_mouse_dragging = false
# 			reset_physics()
# 			add_to_group("static_sections")



			