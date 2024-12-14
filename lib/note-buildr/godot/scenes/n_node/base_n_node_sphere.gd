extends Node2D
class_name BaseNNodeSphere


@export_group("Sphere Properties")
@export var focused := false:
    set(value):
        if focused != value:
            focused = value
            _update_focus()

@export var color := Color.WHITE:
    set(value):
        if color != value: 
            color = value
            _update_color()

@export var sphere_visible := true:
    set(value):
        if sphere_visible != value:
            sphere_visible = value
            _update_radius()

@export_group("Required Nodes")
@export var mesh: MeshInstance2D
@export var area: Area2D
@export var collision_shape: CollisionShape2D

signal radius_updated(value: float)
signal focus_updated(value: bool)
signal color_updated(value: Color)
signal border_updated(value: float)


var animation_duration := 0.3
var mesh_material_radius := 0.3
var mesh_material_border := 0.05
var collision_shape_radius := 10.0

var radius_tween: Tween = null
var border_tween: Tween = null
var color_tween: Tween = null


signal mouse_entered
signal mouse_exited
signal input_event(viewport: Node, event: InputEvent, shape_idx: int)


func _initialize_base_sphere():
    mesh.material = mesh.material.duplicate()
    area.mouse_entered.connect(func():mouse_entered.emit())
    area.mouse_exited.connect(func():mouse_exited.emit())
    area.input_event.connect(
        func(viewport: Node, event: InputEvent, shape_idx: int
        ):input_event.emit(viewport, event, shape_idx))


func _update_focus():
    if not mesh:
        return

    if border_tween:
        border_tween.kill()

    var actual_border = mesh.material.get_shader_parameter("circle_border") as float
    var target_border = mesh_material_border if focused else 0.0

    border_tween = create_tween()
    border_tween.tween_method(_set_sphere_border, actual_border, target_border, animation_duration
        ).set_ease(Tween.EASE_IN if not focused else Tween.EASE_OUT
        ).set_trans(Tween.TransitionType.TRANS_SPRING)
    
    focus_updated.emit(focused)


func _update_color():
    if not mesh:
        return

    if color_tween:
        color_tween.kill()

    var actual_color = mesh.material.get_shader_parameter("circle_color") as Color
    var target_color = color

    color_tween = create_tween()
    color_tween.tween_method(_set_sphere_color, actual_color, target_color, animation_duration)


func _update_radius():
    if not mesh:
        return
    if radius_tween:
        radius_tween.kill()

    var target_mesh_radius = mesh_material_radius if sphere_visible else 0.0
    var actual_mesh_radius = mesh.material.get_shader_parameter("circle_radius") as float

    radius_tween = create_tween().set_parallel(true)
    radius_tween.tween_method(_set_mesh_radius, actual_mesh_radius, target_mesh_radius, animation_duration
        ).set_ease(Tween.EASE_IN if not sphere_visible else Tween.EASE_OUT
        ).set_trans(Tween.TransitionType.TRANS_SPRING)

    if not collision_shape:
        return

    var target_collision_shape_radius = collision_shape_radius if sphere_visible else 0.0
    var actual_collision_shape_radius = collision_shape.shape.radius

    radius_tween.tween_method(_set_collision_shape_radius, actual_collision_shape_radius, target_collision_shape_radius, animation_duration
        ).set_ease(Tween.EASE_IN if not sphere_visible else Tween.EASE_OUT
        ).set_trans(Tween.TransitionType.TRANS_SPRING)
    
    

func _set_mesh_radius(value: float):
    mesh.material.set_shader_parameter("circle_radius", value)
    radius_updated.emit(value)


func _set_collision_shape_radius(value: float):
    var target_value = value if value >= 0.0 else 0.0
    collision_shape.shape.radius = target_value


func _set_sphere_color(value: Color):
    mesh.material.set_shader_parameter("circle_color", value)
    color_updated.emit(value)


func _set_sphere_border(value: float):
    mesh.material.set_shader_parameter("circle_border", value)
    border_updated.emit(value)

