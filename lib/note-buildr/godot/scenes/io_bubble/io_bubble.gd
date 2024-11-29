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
var dragging = false
var is_mouse_hover = false
var _tween: Tween = null
var bubble_offset = 10
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
	mouse_activity.emit(_viewport, _event, _shape_idx)


func _on_mouse_enter():
	is_mouse_hover = true
	mouse_enter_canvas.emit()


func _on_mouse_exit():
	is_mouse_hover = false
	if not dragging:
		mouse_exit_canvas.emit()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if dragging and event is InputEventMouseMotion:
			pivot_node.look_at(get_global_mouse_position())

		elif pivot_node.rotation != 0.0:
			pivot_node.rotation = 0.0

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_mouse_hover:
			dragging = true
		elif not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			dragging = false
			if not is_mouse_hover:
				mouse_exit_canvas.emit()


