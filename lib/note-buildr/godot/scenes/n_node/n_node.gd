extends Node2D


@onready var body: NNodeBody = get_node("NNodeBody")
@export var io_children: Array[NNodeIO]
@export var color: Color = Color.WHITE
@export var disabled: bool = false

var body_mouse_hovered := false
var io_mouse_hovered := false
var mouse_hovered := false
var touched := false
var focused := false
var io_position_tween: Tween = null

func _ready() -> void:
    color = Color(randf_range(0.5, 0.8), randf_range(0.5, 0.8), randf_range(0.5, 0.8))
    var target_offset = 2.3
    if body:
        body.mouse_entered.connect(body_mouse_entered)
        body.mouse_exited.connect(body_mouse_exited)
        body.input_event.connect(body_input_event)
        body._set_sphere_color(color)
        target_offset = body.mesh_material_radius - 0.07

    for io in io_children:
        io.mouse_entered.connect(io_mouse_entered)
        io.mouse_exited.connect(io_mouse_exited)
        io.input_event.connect(io_input_event)
        io._update_io_color(color)
        io._update_io_clip_center(target_offset)
        io._update_io_position(target_offset)


func set_body_focus(value: bool):
    if body.focused == value:
        return
    body.focused = value
    var target_offset = body.mesh_material_radius if value else body.mesh_material_radius - 0.07
    if io_position_tween:
        io_position_tween.kill()
    io_position_tween = create_tween().set_parallel(true)
    for io in io_children:
        var current_offset = io.get_clip_offset()
        if target_offset == current_offset:
            continue
        
        io_position_tween.tween_method(_update_io_offset.bind(io), current_offset, target_offset, 0.2
        ).set_ease(Tween.EASE_IN if focused else Tween.EASE_OUT
        ).set_trans(Tween.TransitionType.TRANS_SPRING)


func _update_io_offset(offset: float, io: NNodeIO):
    io._update_io_clip_center(offset)
    io._update_io_position(offset)


func body_mouse_entered():
    body_mouse_hovered = true
    mouse_hovered = true
    set_body_focus(true)


func io_mouse_entered():
    io_mouse_hovered = true
    mouse_hovered = true
    set_body_focus(true)


func body_mouse_exited():
    body_mouse_hovered = false
    if not io_mouse_hovered:
        mouse_hovered = false
    if not focused:
        set_body_focus(mouse_hovered)


func io_mouse_exited():
    io_mouse_hovered = false
    if not body_mouse_hovered:
        mouse_hovered = false
        if not focused:
            set_body_focus(mouse_hovered)


func body_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int):
    if not body_mouse_hovered:
        body_mouse_hovered = true
    if not mouse_hovered:
        mouse_hovered = true
    if not focused:
        set_body_focus(mouse_hovered)


func io_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int):
    if body_mouse_hovered:
        io_mouse_hovered = false
        # Bypass input event to prioritize body event
        return
    if not io_mouse_hovered:
        io_mouse_hovered = true
    if not mouse_hovered:
        mouse_hovered = true
        if not focused:
            set_body_focus(mouse_hovered)


func _input(event: InputEvent) -> void:
    var is_motion := event is InputEventMouseMotion
    var is_button := event is InputEventMouseButton
    if not is_motion and not is_button:
        return
    if is_button:
        
        # Mouse button outside without interaction 
        if not mouse_hovered and not focused:
            return
            
        var pressed = event.is_pressed()
        
        # Mouse button up outside after focus
        if not mouse_hovered and not pressed and focused:
            touched = false

        # Mouse button down outside after focus
        if not mouse_hovered and pressed and focused:
            focused = false
            touched = false

        # Mouse button up inside
        if mouse_hovered and not pressed:
            touched = false

        # Mouse button down inside
        if mouse_hovered and pressed:
            touched = true
            focused = true
        
        set_body_focus(focused)

    elif is_motion:
        if not touched:
            return
        
            



