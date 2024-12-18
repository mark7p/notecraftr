extends Node2D
const Types := preload ("res://global/types.gd")

var is_mouse_dragging = false
var is_mouse_hover = false
@onready var camera: Camera2D = get_node("Camera2D")
@onready var background: Background = get_node("Background")



func _ready() -> void:
	pass


func _input(event):
	update_mouse_drag(event)
	update_zoom(event)
	

func update_zoom(event):
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP]:
		var zoom_factor = 1.0 - camera.zoom_speed if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else 1.0 + camera.zoom_speed
		camera.zoom *= Vector2(zoom_factor, zoom_factor)
		camera.zoom = camera.zoom.clamp(camera.min_zoom, camera.max_zoom)
		background.queue_redraw()


func update_mouse_drag(event):
	if event is InputEventMouseMotion:
		is_mouse_dragging = event.button_mask in [MOUSE_BUTTON_MASK_MIDDLE, MOUSE_BUTTON_MASK_LEFT]
		if is_mouse_dragging:
			if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				drag_camera(event)


	else:
		if is_mouse_dragging:
			is_mouse_dragging = false



func drag_camera(event):
	camera.position -= (event.relative / camera.zoom)
	background.queue_redraw()
