extends Node2D
var drag_offset = Vector2()
var is_mouse_dragging = false
var is_mouse_hover = false
var sections = null
var selected_sections = null
var drag_start: Vector2
@onready var camera: Camera2D = get_node("Camera2D")


func _ready() -> void:
	connect("child_order_changed", _check_sections)
	_check_sections()


func _process(delta: float) -> void:
	pass


func _input(event):
	update_mouse_drag(event)
	update_zoom(event)


func _check_sections():
	var scene_tree = get_tree()
	if scene_tree:
		sections = scene_tree.get_nodes_in_group("sections")
		selected_sections = scene_tree.get_nodes_in_group("selected_sections")


func update_mouse_down(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			drag_start = camera.get_global_mouse_position()

func update_zoom(event):
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP]:
		var zoom_factor = 1.0 - camera.zoom_speed if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else 1.0 + camera.zoom_speed
		camera.zoom *= Vector2(zoom_factor, zoom_factor)
		camera.zoom = camera.zoom.clamp(camera.min_zoom, camera.max_zoom)


func update_mouse_drag(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if selected_sections and len(selected_sections) > 0:
				drag_selected_sections(event)
				print(1)
			else:
				drag_camera(event)

		elif event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			# drag_start = camera.get_global_mouse_position()
			drag_camera(event)
			print(2)

		elif is_mouse_dragging:
			is_mouse_dragging = false
			# reset_physics()
			add_to_group("static_sections")

func drag_selected_sections(event):
	drag_offset = global_position - camera.get_global_mouse_position()

func drag_camera(event):
	camera.position -= (event.relative / camera.zoom)