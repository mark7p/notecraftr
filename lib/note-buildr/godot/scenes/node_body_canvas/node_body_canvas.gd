@tool
extends NodeCanvas

class_name NodeBodyCanvas



func _ready() -> void:
	animation_duration = 0.3
	max_radius = 0.4
	max_border = 0.1
	_canvas_init()


