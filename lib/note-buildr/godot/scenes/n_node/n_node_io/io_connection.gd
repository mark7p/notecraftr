@tool
extends MeshInstance2D

class_name NNodeIOConnection
var _color_tween: Tween = null
var _length_tween: Tween =  null

@export var length = 0.0:
    set(value):
        if length != value:
            length = value
            set_length_no_animation(value)

@export var disabled := false:
    set(value):
        if disabled != value:
            disabled = value
            _update_canvas()

@export var input_color := Color.WHITE:
    set(value):
        if input_color != value:
            input_color = value
            _update_canvas()

@export var output_color := Color.WHITE:
    set(value):
        if output_color != value:
            output_color = value
            _update_canvas()

@export var disabled_color := Color.GRAY:
    set(value):
        if disabled_color != value:
            disabled_color = value
            _update_canvas()

# @export var bubble_canvas: BubbleCanvas

func _ready() -> void:
    _canvas_init()
    # bubble_canvas.on_color_change.connect(
    #     func(color: Color):
    #         # _set_input_color(color)
    #         input_color = color
    #         )


func _canvas_init():
    # Make sure shader is unique
    material = material.duplicate()
    _update_canvas()


func set_length_no_animation(value: float):
    if _length_tween:
        _length_tween.kill()
        _length_tween = null
    _set_canvas_length(value)


func set_length_with_animation(value: float):
    if _length_tween:
        _length_tween.kill()
        _length_tween = null
    var current_length = scale.x
    _length_tween = create_tween()
    _length_tween.tween_method(_set_canvas_length, current_length, value, 0.15).set_ease(Tween.EASE_IN)


func reset_length():
    set_length_with_animation(0.0)


func _update_canvas():
    
    var length_changed := scale.x != length || (scale.x != material.get_shader_parameter("scale").x as float)
    if length_changed:
        _set_canvas_length(length)

    var current_input_color := material.get_shader_parameter("line_input_color") as Color
    var current_output_color := material.get_shader_parameter("line_output_color") as Color

    var target_input_color :=  disabled_color if disabled else input_color
    var target_output_color :=  disabled_color if disabled else output_color


    var input_color_changed := current_input_color != target_input_color
    var output_color_changed := current_output_color != target_output_color

    if not input_color_changed and not output_color_changed:
        return

    if _color_tween:
        _color_tween.kill()
        _color_tween = null

    _color_tween = create_tween().set_parallel(true)

    if input_color_changed:
        _color_tween.tween_method(_set_input_color, current_input_color, target_input_color, 0.2)

    if output_color_changed:
        _color_tween.tween_method(_set_output_color, current_output_color, target_output_color, 0.2)


func _set_canvas_length(value: float):
    if visible and value <= 0.0:
        visible = false
    elif not visible and value > 0.0:
        visible = true
    scale.x = value
    material.set_shader_parameter("scale", Vector2(value, 5.0))
    position.x = ((value) / 2.0)  + 4.5 # offset 0.12 radius = 12 - 2 so it wont show gap


func _set_input_color(value: Color):
    material.set_shader_parameter("line_input_color", value)
    if output_color == Color.WHITE:
        _set_output_color(value)


func _set_output_color(value: Color):
    material.set_shader_parameter("line_output_color", value)
