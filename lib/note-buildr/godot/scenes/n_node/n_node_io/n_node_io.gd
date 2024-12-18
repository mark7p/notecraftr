@tool
extends BaseNNodeSphere
class_name NNodeIO

const Types := preload ("res://global/types.gd")

@export_group("IO Params")
@export var type: Types.IOType = Types.IOType.INPUT

@export_group("IO Required Nodes")
@export var body: NNodeBody
@export var connection_canvas: NNodeIOConnection
@onready var pivot: Node2D = get_node("Pivot")
@onready var container: Node2D = get_node("Pivot/SphereContainer")
var _rotation_tween: Tween = null
var connected_io: NNodeIO = null:
    set(value):
        if connected_io != value:
            connected_io = value
            _update_connection_output_color(value.color if value else color)

var hovering_io: NNodeIO = null:
    set(value):
        if hovering_io != value:
            hovering_io = value
            _update_connection_output_color(value.color if value else color)


func _ready() -> void:
    mesh_material_radius = 0.15
    collision_shape_radius = 5.0
    _initialize_base_sphere()
    body.radius_updated.connect(body_radius_changed)
    body.border_updated.connect(body_border_changed)
    body.color_updated.connect(body_color_changed)
    # body.tree_exiting.connect(queue_free)
    _check_body()


func _input(event: InputEvent) -> void:
    return
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
    if type == Types.IOType.OUTPUT:
        pivot_look_at(Vector2.LEFT + pivot.global_position)


func reset_rotation():
    var target_face = (Vector2.LEFT if type == Types.IOType.OUTPUT else Vector2.RIGHT)
    pivot_look_with_animation(target_face + pivot.global_position)


func pivot_look_at(point: Vector2):
    pivot.look_at(point)


func pivot_look_with_animation(point: Vector2):
    if _rotation_tween:
        _rotation_tween.kill()
        _rotation_tween = null

    _rotation_tween = create_tween()
    _rotation_tween.tween_method(
        pivot_look_at,
        container.global_position,
        point,
        0.3
    ).set_ease(Tween.EASE_OUT)


func _update_io_radius(body_radius: float):
    var ratio = body_radius / body.mesh_material_radius
    var target_radius = mesh_material_radius * ratio
    mesh.material.set_shader_parameter("circle_radius", target_radius if target_radius > 0.0 else 0.0)


func _update_io_border(body_border: float):
    mesh.material.set_shader_parameter("circle_border", body_border)


func _update_io_color(value: Color):
    color = value
    mesh.material.set_shader_parameter("circle_color", value)
    _update_connection_input_color(value)
    if not connected_io and not hovering_io:
        _update_connection_output_color(value)


func _update_connection_input_color(value: Color):
    connection_canvas.input_color = value


func _update_connection_output_color(value: Color):
    connection_canvas.output_color = value


func _update_io_position(clip_center: float):
    container.position = Vector2(mesh.scale.x * clip_center, 0.0)


func _update_io_clip_radius(value: float):
    mesh.material.set_shader_parameter("clip_radius", value)


func _update_io_clip_center(value: float):
    mesh.material.set_shader_parameter("clip_center", value)


func _update_io_clip_border(value: float):
    mesh.material.set_shader_parameter("clip_border", value)


func get_clip_offset() -> float:
    return abs(mesh.material.get_shader_parameter("clip_center"))
