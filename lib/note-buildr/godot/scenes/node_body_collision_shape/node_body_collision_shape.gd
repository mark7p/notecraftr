@tool
extends CollisionShape2D

class_name NodeBodyCollisionShape

@export var canvas: NodeBodyCanvas


func _ready() -> void:
	scale = Vector2.ZERO
	canvas.on_radius_change.connect(_on_canvas_radius_change)


func _on_canvas_radius_change(value: float):
	var new_scale := value / canvas.radius
	scale = Vector2(new_scale, new_scale)

# func _process(delta: float) -> void:
# 	pass
