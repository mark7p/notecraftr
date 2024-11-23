@tool
extends RigidBody2D
# class_name Section

const Types := preload ("res://global/types.gd")

var drag_offset = Vector2()
var is_mouse_dragging = false
var is_mouse_hover = false
var grid_size: float = 100  # Grid size matches the circle diameter
var physics_impulse_multiplier = 100
signal on_select(node)
signal on_blur(node)
var sections_dragged = false
var touched = false
var dragged = false
var initial_press_position
@export var state: Types.SectionState = Types.SectionState.NORMAL
@export var camera: Camera2D

@onready var canvas: SectionCanvas = get_node("Canvas")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func _ready() -> void:
	collision_shape.shape.radius = canvas.circle_radius
	grid_size = 2 * canvas.circle_radius
	# connect("mouse_entered", _on_mouse_enter)
	# connect("mouse_exited", _on_mouse_exit)
	connect("body_entered", on_body_entered)

	# TO REMOVE
	canvas.circle_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))

# func _on_input(i_viewport, i_event, i_index):
# 	printt(i_viewport, i_event, i_index)

func _process(delta: float) -> void:
	pass


func select():
	if state == Types.SectionState.DISABLED:
		return

	add_to_group("selected_sections")
	freeze = true
	state = Types.SectionState.SELECTED
	on_select.emit(self)
	if canvas.border_radius <= 0.1:
		animation_player.play("mouse_in")


func deselect():
	if state == Types.SectionState.DISABLED:
		return

	remove_from_group("selected_sections")
	freeze = false
	state = Types.SectionState.NORMAL
	on_blur.emit(self)
	if canvas.border_radius  > 0.1:
		animation_player.play("mouse_out")


func focus_section():
	animation_player.play("mouse_in")


func blur_section():
	animation_player.play("mouse_out")


func _on_mouse_enter():
	if state == Types.SectionState.DISABLED:
		return
		
	if dragged:
		return

	# if not get_parent().is_mouse_dragging:
	is_mouse_hover = true
	focus_section()


func _on_mouse_exit():
	if state == Types.SectionState.DISABLED:
		return

	is_mouse_hover = false

	if state == Types.SectionState.SELECTED:
		return

	if state == Types.SectionState.NORMAL:
		if touched:
			return

	blur_section()


func on_body_entered(node):
	if node.is_in_group("sections"):
		var impulse = (node.global_position - global_position).normalized()
		if node.is_in_group("selected_sections"):
			apply_central_impulse(-impulse * physics_impulse_multiplier)
		else:
			node.apply_central_impulse(impulse * physics_impulse_multiplier)
		


func _input(event):
	if event is InputEventMouseButton:
		if is_mouse_hover:
			if event.pressed:
				touched = true
		else:
			if not dragged:
				touched = false

		if is_mouse_hover:
			if state == Types.SectionState.NORMAL:
				if event.pressed and not event.ctrl_pressed:
					if touched and event.button_index == MOUSE_BUTTON_LEFT:
						var selected_sections = get_tree().get_nodes_in_group("selected_sections")
						for section in selected_sections:
							section.deselect()
						select()
				elif not event.pressed and event.ctrl_pressed:
					if not dragged:
						select()
			
			elif state == Types.SectionState.SELECTED:
				if event.pressed and not event.ctrl_pressed:
					if touched and event.button_index == MOUSE_BUTTON_LEFT:
						if event.ctrl_pressed:
							deselect()
					elif not event.ctrl_pressed:
						deselect()
				elif not event.pressed and event.ctrl_pressed:
					if not dragged:
						deselect()
		else:
			if state == Types.SectionState.SELECTED and event.button_index == MOUSE_BUTTON_LEFT:
				var selected_sections = get_tree().get_nodes_in_group("sections")
				var found_hovered = false
				for section in selected_sections:
					if found_hovered:
						continue
					found_hovered = section.is_mouse_hover

				if not found_hovered:
					deselect()


			

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag_offset = position - camera.get_global_mouse_position()
		
		if not event.pressed:
			dragged = false
			touched = false
			

	if event is InputEventMouseMotion:
		if (global_position - camera.get_global_mouse_position()).length() <= canvas.circle_radius:
			if not is_mouse_hover:
				_on_mouse_enter()
		else:
			if is_mouse_hover:
				_on_mouse_exit()


	if event is InputEventMouseMotion and event.button_mask in [MOUSE_BUTTON_MASK_LEFT, MOUSE_BUTTON_MASK_MIDDLE, MOUSE_BUTTON_MASK_RIGHT]:
		dragged = true
	else:
		dragged = false

	if event is InputEventMouseMotion and event.button_mask in [MOUSE_BUTTON_MASK_LEFT]:
		if state == Types.SectionState.SELECTED:
			global_position = camera.get_global_mouse_position() + drag_offset
			# check_collision(event)



		

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




func check_collision(event):
	if is_mouse_dragging and event is InputEventMouseMotion:

		# Check for collisions with other objects
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = CircleShape2D.new()
		query.shape.radius = canvas.circle_radius
		query.transform.origin = global_position
		query.collision_mask = collision_layer

		var results = space_state.intersect_shape(query)
		for result in results:
			var other_body = result.collider as RigidBody2D
			if other_body:
				var impulse = (other_body.global_position - global_position).normalized()
				other_body.apply_central_impulse(impulse * physics_impulse_multiplier)


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



			
