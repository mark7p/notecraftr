@tool
extends RigidBody2D

class_name Section

const Types := preload ("res://global/types.gd")
@export var body_canvas: NodeBodyCanvas
@export var collision_shape: NodeBodyCollisionShape
@export var io_bubbles: Array[IOBubble]
@export var camera: Camera2D
@export var state: Types.SectionState = Types.SectionState.NORMAL
@export var connected_to: Array[Section]:
	set(value):
		connected_to = value
@export var connected_from: Array[Section]:
	set(value):
			connected_from = value

var drag_offset = Vector2.ZERO
var body_mouse_hover = false
var touched = false
var dragged = false
var physics_impulse_multiplier = 50
var bubbles_mouse_hover = false
var _canvas_update_tween: Tween


func _ready() -> void:
	# CANVAS
	# Set canvas color, bypass animation
	var random_color = Color(randf_range(0.3,1),randf_range(0.3,1),randf_range(0.3,1))
	_update_all_canvas(func(c): c._set_circle_color(random_color), false)
	_update_all_canvas(func(c): c.color = random_color, false)
	_update_canvas()

	body_entered.connect(_on_body_entered)

	# BUBBLES
	for bubble in io_bubbles:
		bubble.mouse_enter_canvas.connect(_bubbles_canvas_mouse_enter)
		bubble.mouse_exit_canvas.connect(_bubbles_canvas_mouse_exit)
		bubble.mouse_activity.connect(_bubbles_mouse_activity)


func _connected_to_update():
	pass


func _connected_from_update():
	pass


func _update_all_canvas(callback: Callable, delay = true):
	# Create a tween delay to make sure all properties are set before update
	var _updates = func():
		callback.call(body_canvas)
		for bubble in io_bubbles:
			callback.call(bubble.bubble_canvas)
	
	if delay:
		if _canvas_update_tween:
			_canvas_update_tween.kill()
			_canvas_update_tween = null
		_canvas_update_tween = create_tween()
		_canvas_update_tween.tween_callback(_updates).set_delay(0.05)
	else:
		_updates.call()

	


func _check_canvas_focus():
	var _check_hover := func():
		if bubbles_mouse_hover or body_mouse_hover or state:
			_update_all_canvas(func(c): c.focused = true)
		else:
			_update_all_canvas(func(c): c.focused = false)
	
	var _tween = create_tween()
	_tween.tween_callback(_check_hover).set_delay(0.1)


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


func _set_as_connection_candidate():
	if Global.section_seaking_connection and Global.section_connection_candidate != self:
		Global.section_connection_candidate = self
		if Global.section_seaking_connection == self:
			return

		for bubble in io_bubbles:
			if bubble.type == Types.BubbleType.OUTPUT and not bubble.connected:
				bubble.bubble_look_at(Global.section_seaking_connection.global_position)
	

func _remove_as_connection_candidate():
	if Global.section_seaking_connection and Global.section_connection_candidate == self:
		Global.section_connection_candidate = null
		if Global.section_seaking_connection == self:
			return

		for bubble in io_bubbles:
			if bubble.type == Types.BubbleType.OUTPUT and not bubble.connected:
				bubble.request_reset_position()

func _bubbles_canvas_mouse_enter():
	bubbles_mouse_hover = true
	if not body_mouse_hover:
		_set_as_connection_candidate()
		_update_all_canvas(func(c): c.focused = true)


func _bubbles_canvas_mouse_exit():
	bubbles_mouse_hover = false
	if state != Types.SectionState.SELECTED:
		if not body_mouse_hover:
			_remove_as_connection_candidate()
			_update_all_canvas(func(c): c.focused = false)


func _on_mouse_enter():
	body_mouse_hover = true
	if not bubbles_mouse_hover:
		_set_as_connection_candidate()
		_update_all_canvas(func(c): c.focused = true)


func _on_mouse_exit():
	if state != Types.SectionState.SELECTED:
		if not bubbles_mouse_hover:
			_remove_as_connection_candidate()
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
			if Global.section_connection_candidate == self:
				_remove_as_connection_candidate()
			if Global.section_seaking_connection == self:
				Global.section_seaking_connection = null
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




			
