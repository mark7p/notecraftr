@tool
extends BaseNNodeSphere
class_name NNodeIO

const Types := preload ("res://global/types.gd")

@export_group("IO Params")
@export var type: Types.IOType = Types.IOType.INPUT

@export_group("IO Required Nodes")
@export var body: NNodeBody

@onready var pivot: Node2D = get_node("Pivot")
@onready var container: Node2D = get_node("Pivot/SphereContainer")


func _ready() -> void:
    mesh_material_radius = 0.15
    collision_shape_radius = 5.0
    _initialize_base_sphere()
    body.radius_updated.connect(body_radius_changed)
    body.border_updated.connect(body_border_changed)
    body.color_updated.connect(body_color_changed)
    _check_body()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        pivot_look_at(get_global_mouse_position())

# Override base update methods
func _update_focus():
    pass
func _update_color():
    pass
func _update_radius():
    pass


func body_color_changed(value: Color):
    _update_io_color(value)


func body_radius_changed(value: float):
    _update_io_clip_radius(value)
    _update_io_clip_center(value)
    _update_io_position(value)
    _update_io_radius(value)


func body_border_changed(value: float):
    _update_io_clip_border(value)
    _update_io_border(value)


func _check_body():
    if not body:
        return
    
    var clip_radius = body.mesh.material.get_shader_parameter("circle_radius")
    var clip_border = body.mesh.material.get_shader_parameter("circle_border")
    var circle_color = body.mesh.material.get_shader_parameter("circle_color")
    
    _update_io_clip_radius(clip_radius)
    _update_io_clip_center(clip_radius)
    _update_io_clip_border(clip_border)
    _update_io_color(circle_color)
    _update_io_position(clip_radius)


func pivot_look_at(point: Vector2):
    pivot.look_at(point)


func _update_io_radius(body_radius: float):
    var ratio = body_radius / body.mesh_material_radius
    var target_radius = mesh_material_radius * ratio
    mesh.material.set_shader_parameter("circle_radius", target_radius if target_radius > 0.0 else 0.0)


func _update_io_border(body_border: float):
    mesh.material.set_shader_parameter("circle_border", body_border)


func _update_io_color(value: Color):
    mesh.material.set_shader_parameter("circle_color", value)


func _update_io_position(clip_center: float):
    if type == Types.IOType.OUTPUT:
        clip_center *= -1
    container.position = Vector2(mesh.scale.x * clip_center, 0.0)


func _update_io_clip_radius(value: float):
    mesh.material.set_shader_parameter("clip_radius", value)


func _update_io_clip_center(value: float):
    if type == Types.IOType.OUTPUT:
        value *= -1
    mesh.material.set_shader_parameter("clip_center", value)


func _update_io_clip_border(value: float):
    mesh.material.set_shader_parameter("clip_border", value)
