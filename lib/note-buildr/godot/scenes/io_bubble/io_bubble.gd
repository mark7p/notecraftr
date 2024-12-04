@tool
extends Node2D
class_name IOBubble

const Types := preload ("res://global/types.gd")

@export var pivot_node: Node2D
@export var bubble_container: Node2D
@export var canvas: BubbleCanvas
@export var bubble_area: Area2D
@export var section_body_canvas: NodeBodyCanvas
@export var section_body_collision_shape: NodeBodyCollisionShape
@export var init_position: Types.BubblePosition = Types.BubblePosition.RIGHT
var bubble_container_original_position := Vector2.ZERO
var touched = false
var dragging = false
var is_mouse_hover = false
var started_dragging = false
var _tween: Tween = null
var bubble_offset = 10
var bubble_pos_animating = false
signal mouse_enter_canvas()
signal mouse_exit_canvas()
signal mouse_activity(viewport: Node, event: InputEvent, shape_idx: int)


func _ready() -> void:
	bubble_container.position = bubble_container_original_position
	section_body_canvas.on_radius_change.connect(_on_section_body_canvas_radius_change)
	bubble_area.mouse_entered.connect(_on_mouse_enter)
	bubble_area.mouse_exited.connect(_on_mouse_exit)
	bubble_area.input_event.connect(_on_mouse_activity)
	

func _on_section_body_canvas_radius_change(value: float):
	var new_scale := value / section_body_canvas.radius
	var target = (section_body_collision_shape.shape.radius + bubble_offset) * new_scale
	bubble_container_original_position = Vector2(target, 0.0)
	bubble_container.position = bubble_container_original_position
	if init_position == Types.BubblePosition.LEFT:
		rotation_degrees = 180

	

func _rotate_pivote_node(target_position: Vector2):
	if _tween:
		_tween.kill()


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

func _reset_bubble_position():
	bubble_pos_animating = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(false)
	_tween.tween_property(bubble_container, "position", bubble_container_original_position, 0.3
	).set_trans(Tween.TRANS_SPRING)
	_tween.tween_property(pivot_node, "rotation", 0.0, 0.2
	).set_trans(Tween.TRANS_SPRING)
	_tween.tween_callback(_set_animating.bind(false))


func _set_animating(is_animating: bool):
	bubble_pos_animating = is_animating


func _input(event: InputEvent) -> void:
	# Only check motion if touched
	if touched and event is InputEventMouseMotion:
		if event.button_mask in [MOUSE_BUTTON_MASK_LEFT]:
			if dragging:
				var mouse_pos = get_global_mouse_position()
				pivot_node.look_at(mouse_pos)
				var target_length := (pivot_node.global_position - mouse_pos).length()
				bubble_container.position.x = target_length


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
			bubble_container_original_position = bubble_container.position

		if not touched and dragging:
			dragging = false
			_reset_bubble_position()

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


