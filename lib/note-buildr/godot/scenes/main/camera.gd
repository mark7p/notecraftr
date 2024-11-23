extends Camera2D

# Adjustable settings
@export var zoom_speed: float = 0.1
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)
@export var max_zoom: Vector2 = Vector2(3, 3)

# Internal variables
var drag_start: Vector2
var dragging: bool = false

func d_input(event: InputEvent) -> void:
    # Middle mouse drag handling
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			if event.pressed:
				drag_start = get_global_mouse_position()
				dragging = true
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		# print(event.position)
		# print(event.global_position)
		position -= (event.relative / zoom)

	# Zoom handling
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP]:
		var zoom_factor = 1.0 - zoom_speed if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else 1.0 + zoom_speed
		zoom *= Vector2(zoom_factor, zoom_factor)
		zoom = zoom.clamp(min_zoom, max_zoom)
