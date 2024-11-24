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
	connect("body_entered", on_body_entered)

	# TO REMOVE
	canvas.circle_color = Color(randf_range(0.3,1),randf_range(0.3,1),randf_range(0.3,1))

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





			
