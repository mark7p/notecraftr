extends MeshInstance2D

class_name NodeCanvas

var animation_duration := 0.3
var max_radius := 0.4
var max_border := 0.1
var _tween: Tween = null

signal on_radius_change(value: float)

@export var circle_visible := true:
	set(value):
		if circle_visible != value:
			circle_visible = value
			_update_canvas()

@export var focused := false:
	set(value):
		if focused != value:
			focused = value
			_update_canvas()

@export var disabled := false:
	set(value):
		if disabled != value:
			disabled = value
			_update_canvas()

@export var color := Color.WHITE:
	set(value):
		if color != value:
			color = value
			_update_canvas()
		
@export var disabled_color := Color.GRAY:
	set(value):
		if disabled_color != value:
			disabled_color = value
			_update_canvas()

@export var radius := 0.3:
	set(value):
		var new_value = max(0.0, min(max_radius, value))
		# if radius != new_value:
		radius = new_value
		_set_circle_radius(new_value)

@export var border := 0.05:
	set(value):
		var new_value = max(0.0, min(max_border, value))
		# if border != new_value:
		border = new_value
		_set_circle_border(new_value)


func _canvas_init():
    # Make sure shader is unique
	material = material.duplicate()
	_set_circle_border(0.0)
	_set_circle_radius(0.0)
	_set_circle_color(disabled_color if disabled else color)
	_update_canvas()


func _update_canvas():
	var current_color := material.get_shader_parameter("circle_color") as Color
	var current_border := material.get_shader_parameter("circle_border") as float
	var current_radius :=  material.get_shader_parameter("circle_radius") as float

	var target_color :=  disabled_color if disabled else color
	var color_changed := current_color != target_color
	var target_border := border if focused and circle_visible and not disabled else 0.0
	var border_changed := current_border != target_border
	var target_radius := radius if circle_visible else 0.0
	var radius_changed := current_radius != target_radius

	if false or (!color_changed and !border_changed and !radius_changed) or (!visible and !circle_visible):
		return
	

	if _tween:
		_tween.kill()

	_tween = create_tween().set_parallel(true)

	if color_changed:
		_tween.tween_method(_set_circle_color, current_color, target_color, 0.2)

	if border_changed:
		_tween.tween_method(_set_circle_border, current_border, target_border, animation_duration
		).set_ease(Tween.EASE_IN if target_border == 0.0 else Tween.EASE_OUT
		).set_trans(Tween.TransitionType.TRANS_SPRING)
		

	if radius_changed:
		_tween.tween_method(_set_circle_radius, current_radius, target_radius, animation_duration
		).set_ease(Tween.EASE_IN if target_radius == 0.0 else Tween.EASE_OUT
		).set_trans(Tween.TransitionType.TRANS_SPRING)
		if target_radius == 0.0:
			_tween.tween_callback(_on_hide).set_delay(animation_duration)
		elif visible == false:
			visible = true



func _on_hide():
	visible = false


func _on_disable():
	_set_circle_color(disabled_color if disabled else color)


func _enter_animation():
	_tween = create_tween()
	_tween.tween_method(_set_circle_radius, 0.0, radius, 0.3)


func _set_circle_radius(value: float):
	material.set_shader_parameter("circle_radius", value)
	on_radius_change.emit(value)


func _set_circle_color(value: Color):
	material.set_shader_parameter("circle_color", value)


func _set_circle_border(value: float):
	material.set_shader_parameter("circle_border", value)