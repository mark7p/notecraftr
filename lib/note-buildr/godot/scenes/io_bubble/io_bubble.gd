@tool
extends Node2D
class_name IOBubble

const Types := preload ("res://global/types.gd")

@export var pivot_node: Node2D
@export var bubble_container: Node2D
@export var bubble_canvas: BubbleCanvas
@export var connection_canvas: BubbleConnectionCanvas
@export var bubble_area: Area2D
@export var section_body_canvas: NodeBodyCanvas
@export var section_body_collision_shape: NodeBodyCollisionShape
@export var type: Types.BubbleType = Types.BubbleType.INPUT

var bubble_container_original_position := Vector2.ZERO
var touched = false
var dragging = false
var is_mouse_hover = false
var started_dragging = false
var _tween: Tween = null
var bubble_offset = 10
var bubble_pos_animating = false
var connected:= false
signal mouse_enter_canvas()
signal mouse_exit_canvas()
signal mouse_activity(viewport: Node, event: InputEvent, shape_idx: int)


func _ready() -> void:
	bubble_container.position = bubble_container_original_position
	section_body_canvas.on_radius_change.connect(_on_section_body_canvas_radius_change)
	bubble_area.mouse_entered.connect(_on_mouse_enter)
	bubble_area.mouse_exited.connect(_on_mouse_exit)
	bubble_area.input_event.connect(_on_mouse_activity)
	# bubble_area.area_entered.connect(_on_area_body_entered)
	# if type == Types.BubbleType.OUTPUT:
	# 	rotation_degrees = 180


# func _on_area_body_entered(body):
# 	if touched:
# 		printt(body)
	

func _on_section_body_canvas_radius_change(value: float):
	var new_scale := value / section_body_canvas.radius
	var target = (section_body_collision_shape.shape.radius + bubble_offset) * new_scale
	bubble_container_original_position = Vector2(target, 0.0)
	bubble_container.position = bubble_container_original_position
	if type == Types.BubbleType.OUTPUT:
		rotation_degrees = 180
	else:
		rotation_degrees = 0

	

func bubble_look_at(target_position: Vector2):
	if _tween:
		_tween.kill()
		bubble_pos_animating = false
	pivot_node.look_at(Global.section_seaking_connection.global_position)


func _on_mouse_activity(_viewport: Node, _event: InputEvent, _shape_idx: int):
	is_mouse_hover = true
	if not is_mouse_hover:
		_on_mouse_enter()
	mouse_activity.emit(_viewport, _event, _shape_idx)


func _on_mouse_enter():
	is_mouse_hover = true
	mouse_enter_canvas.emit()


func _on_mouse_exit():
	is_mouse_hover = false
	if not dragging:
		mouse_exit_canvas.emit()

func request_reset_position():
	_reset_bubble_position()

func _reset_bubble_position():
	bubble_pos_animating = true

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(false)
	# _tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(connection_canvas, "length", 0.0, 0.2
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_property(pivot_node, "rotation", 0.0, 0.5
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(func():bubble_pos_animating = false)



func _input(event: InputEvent) -> void:
	# Only check motion if touched
	if touched and event is InputEventMouseMotion:
		if event.button_mask in [MOUSE_BUTTON_MASK_LEFT]:
			if dragging:
				if Global.section_connection_candidate:
					pivot_node.look_at(Global.section_connection_candidate.global_position)
					var target_length := (bubble_container.global_position - Global.section_connection_candidate.global_position).length()
					connection_canvas.length = target_length - 60
					connection_canvas.output_color = Global.section_connection_candidate.body_canvas.color
				else:
					var mouse_pos = get_global_mouse_position()
					pivot_node.look_at(mouse_pos)
					var target_length := (bubble_container.global_position - mouse_pos).length()
					connection_canvas.length = target_length - 10 # offset 0.12 radius = 12 - 2 so it wont show gap
					connection_canvas.output_color = connection_canvas.input_color


	elif event is InputEventMouseButton:
		var is_pressed = event.pressed
		var is_left = event.button_index == MOUSE_BUTTON_LEFT

		if is_pressed and is_mouse_hover and not dragging:
			touched = true
		if not is_pressed and touched:
			touched = false

		# Started pressing bubble
		if touched and is_left and not dragging and not bubble_pos_animating:
			dragging = true
			Global.section_seaking_connection = get_parent()
			bubble_container_original_position = bubble_container.position

		if not touched and dragging:
			dragging = false
			_reset_bubble_position()
			Global.section_seaking_connection = null

		if not is_pressed and not is_mouse_hover:
			mouse_exit_canvas.emit()

		# elif not is_pressed or not is_left:
		# 	if touched:
		# 		_reset_bubble_position()
		# 	dragging = false
		# 	touched = false
		# 	if not is_mouse_hover:
		# 		mouse_exit_canvas.emit()
			

		# if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 	_reset_bubble_position()
