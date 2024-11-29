@tool
extends Node2D
class_name Background

# Customizable properties
@export var horizontal_line_color = Color(0.3, 0.3, 0.3) # Light gray
@export var vertical_line_color = Color(0.2, 0.2, 0.2)   # Even lighter gray
@export var background_color = Color(1.0, 1.0, 1.0)   # Even lighter gray
@export var line_width = 2.0                              # Line width
@export var horizontal_spacing = 75                        # Spacing between horizontal lines
@export var vertical_spacing = 75                           # Spacing between vertical lines
@export var camera: Camera2D

func _ready():
	
	pass

func _draw():
	var camera_pos = camera.get_global_position()
	var viewport_size := (camera.get_viewport_rect().size / camera.zoom) + Vector2(100, 100)

	# Draw the background
	draw_rect(Rect2(camera_pos - viewport_size / 2, viewport_size), background_color, true)

	# Determine the range of lines to draw based on the camera position and viewport size
	var viewport_x = viewport_size.x / 2
	var viewport_y = viewport_size.y / 2
	var start_x = floor((camera_pos.x - viewport_x) / vertical_spacing) * vertical_spacing
	var end_x = ceil((camera_pos.x + viewport_x) / vertical_spacing) * vertical_spacing
	var start_y = floor((camera_pos.y - viewport_y) / horizontal_spacing) * horizontal_spacing
	var end_y = ceil((camera_pos.y + viewport_y) / horizontal_spacing) * horizontal_spacing

	# Draw horizontal lines
	for y in range(start_y, end_y + 1, horizontal_spacing):
		draw_line(Vector2(start_x, y), Vector2(end_x, y), horizontal_line_color, line_width, true)

	# Draw vertical lines
	for x in range(start_x, end_x + 1, vertical_spacing):
		draw_line(Vector2(x, start_y), Vector2(x, end_y), vertical_line_color, line_width, true)


