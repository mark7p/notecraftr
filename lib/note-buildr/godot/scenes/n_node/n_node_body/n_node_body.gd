@tool
extends BaseNNodeSphere
class_name NNodeBody


func _ready() -> void:
    mesh_material_radius = 0.3
    collision_shape_radius = 10.0
    _initialize_base_sphere() 
