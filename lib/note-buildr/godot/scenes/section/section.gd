@tool
extends RigidBody2D

class_name Section

const Types := preload ("res://global/types.gd")
@export var body_canvas: NodeBodyCanvas
@export var collision_shape: NodeBodyCollisionShape
@export var io_bubbles: Array[IOBubble]
@export var camera: Camera2D
@export var state: Types.SectionState = Types.SectionState.NORMAL
var drag_offset = Vector2.ZERO
var body_mouse_hover = false
var touched = false
var dragged = false
var physics_impulse_multiplier = 50
var bubbles_mouse_hover = false


func _ready() -> void:
	# CANVAS
	# Set canvas color, bypass animation
	var random_color = Color(randf_range(0.3,1),randf_range(0.3,1),randf_range(0.3,1))
	_update_all_canvas(func(c): c._set_circle_color(random_color))
	_update_all_canvas(func(c): c.color = random_color)
	_update_canvas()

	body_entered.connect(_on_body_entered)

	# BUBBLES
	for bubble in io_bubbles:
		bubble.mouse_enter_canvas.connect(_bubbles_canvas_mouse_enter)
		bubble.mouse_exit_canvas.connect(_bubbles_canvas_mouse_exit)
		bubble.mouse_activity.connect(_bubbles_mouse_activity)


func _update_all_canvas(callback: Callable):
	callback.call(body_canvas)
	for bubble in io_bubbles:
		callback.call(bubble.canvas)


func _update_canvas():
	match state:
		Types.SectionState.DISABLED:
			_update_all_canvas(func(c): c.disabled = true)
		Types.SectionState.SELECTED:
			_update_all_canvas(func(c): c.focused = true)
		_:
			pass


func _bubbles_mouse_activity(_viewport: Node, _event: InputEvent, _shape_idx: int):
	pass
	# print(_event)
	# _update_all_canvas(func(c): c.focused = true)



func _bubbles_canvas_mouse_enter():
	# bubbles_mouse_hover = true
	# print("bubble enter")
	bubbles_mouse_hover = true
	if not body_mouse_hover:
		_update_all_canvas(func(c): c.focused = true)


func _bubbles_canvas_mouse_exit():
	# if not body_mouse_hover:
	# print("bubble exit")
	bubbles_mouse_hover = false
	if state != Types.SectionState.SELECTED:
		if not body_mouse_hover:
			_update_all_canvas(func(c): c.focused = false)


func _on_mouse_enter():
	# print("body enter")
	body_mouse_hover = true
	if not bubbles_mouse_hover:
		_update_all_canvas(func(c): c.focused = true)


func _on_mouse_exit():
	# print("body exit")
	if state != Types.SectionState.SELECTED:
		if not bubbles_mouse_hover:
			_update_all_canvas(func(c): c.focused = false)

	body_mouse_hover = false


func delete():
	body_canvas.hidden.connect(queue_free)
	_update_all_canvas(func(c): c.circle_visible = false)


func select():
	remove_from_group("selected_sections")
	if state == Types.SectionState.DISABLED:
		return

	add_to_group("selected_sections")
	freeze = true
	state = Types.SectionState.SELECTED
	_update_all_canvas(func(c): c.focused = true)



func deselect():
	if state == Types.SectionState.DISABLED:
		return

	remove_from_group("selected_sections")
	freeze = false
	state = Types.SectionState.NORMAL
	_update_all_canvas(func(c): c.focused = false)


func _on_body_entered(node):
	if node.is_in_group("sections"):
		var impulse = (node.global_position - global_position).normalized()
		if node.is_in_group("selected_sections"):
			apply_central_impulse(-impulse * physics_impulse_multiplier)
		else:
			node.apply_central_impulse(impulse * physics_impulse_multiplier)



func _input(event):
	if event is InputEventMouseButton:
		if body_mouse_hover:
			if event.pressed:
				touched = true
		else:
			if not dragged:
				touched = false

		if body_mouse_hover:
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
			if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				delete()
		else:
			if state == Types.SectionState.SELECTED and event.button_index == MOUSE_BUTTON_LEFT:
				var selected_sections = get_tree().get_nodes_in_group("sections")
				var found_hovered = false
				for section in selected_sections:
					if found_hovered:
						continue
					found_hovered = section.body_mouse_hover

				if not found_hovered:
					deselect()


			

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag_offset = position - (camera.get_global_mouse_position() if camera else get_global_mouse_position())
		
		if not event.pressed:
			dragged = false
			touched = false
			

	if event is InputEventMouseMotion:
		if (global_position - (camera.get_global_mouse_position() if camera else get_global_mouse_position())).length() <= collision_shape.shape.radius * collision_shape.scale.x:
			if not body_mouse_hover:
				_on_mouse_enter()
		else:
			if body_mouse_hover:
				_on_mouse_exit()


	if event is InputEventMouseMotion and event.button_mask in [MOUSE_BUTTON_MASK_LEFT, MOUSE_BUTTON_MASK_MIDDLE, MOUSE_BUTTON_MASK_RIGHT]:
		dragged = true
	else:
		dragged = false

	if event is InputEventMouseMotion and event.button_mask in [MOUSE_BUTTON_MASK_LEFT]:
		if state == Types.SectionState.SELECTED:
			global_position = (camera.get_global_mouse_position() if camera else get_global_mouse_position()) + drag_offset




			
