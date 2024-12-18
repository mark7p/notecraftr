@tool
extends RigidBody2D
class_name NNode

const Types := preload ("res://global/types.gd")

@onready var body: NNodeBody = get_node("NNodeBody")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@export var io_children: Array[NNodeIO]
@export var color: Color = Color.WHITE
@export var disabled: bool = false
@export var camera_reference: Camera2D
@export var input_connections: Array[NNodeIO] = []
@export var output_connections: Array[NNodeIO] = []

var body_mouse_hovered := false
var io_mouse_hovered := false
var mouse_hovered := false
var touched := false
var focused := false
var io_position_tween: Tween = null
var drag_offset := Vector2.ZERO
var body_dragging := false
var body_can_drag := false
var io_dragging := false
var io_can_drag := false
var physics_impulse_multiplier = 25
var hovered_io: NNodeIO = null


func _ready() -> void:
    collision_shape.shape = body.collision_shape.shape
    # color = Color(randf_range(0.5, 0.8), randf_range(0.5, 0.8), randf_range(0.5, 0.8))
    var target_offset = 2.3
    if body:
        body.mouse_entered.connect(body_mouse_entered)
        body.mouse_exited.connect(body_mouse_exited)
        body.input_event.connect(body_input_event)
        body._set_sphere_color(color)
        target_offset = body.mesh_material_radius - 0.07
        body.area.area_entered.connect(_on_body_entered)
        body.kill_animation_finished.connect(queue_free)

    for io in io_children:
        io.mouse_entered.connect(io_mouse_entered)
        io.mouse_exited.connect(io_mouse_exited)
        io.input_event.connect(io_input_event)
        io._update_io_color(color)
        io._update_io_clip_center(target_offset)
        io._update_io_position(target_offset)


func has_connection() -> bool:
    return has_input_connection() or has_output_connection()


func has_input_connection() -> bool:
    if len(input_connections) > 0:
        return true
    return false


func has_output_connection() -> bool:
    if len(output_connections) > 0:
        return true
    return false


func kill():
    body.animate_kill()
    

func _on_body_entered(node: Node2D):
    if is_in_group("selected_nnodes"):
        return
    if node.is_in_group("nnode_body_area"):
        var target_nnode = node.get_parent().get_parent()
        var impulse = (target_nnode.global_position - global_position).normalized()
        if target_nnode.is_in_group("selected_nnodes"):
            apply_central_impulse(-impulse * physics_impulse_multiplier)


func set_body_focus(value: bool):
    if body.focused == value:
        return
    body.focused = value
    var target_offset = body.mesh_material_radius if value else body.mesh_material_radius - 0.07
    
    if io_position_tween:
        io_position_tween.kill()
        io_position_tween = null
    
    for io in io_children:
        var current_offset = io.get_clip_offset()
        if target_offset == current_offset:
            continue

        if not io_position_tween:
            io_position_tween = create_tween().set_parallel(true)
        
        io_position_tween.tween_method(_update_io_offset.bind(io), current_offset, target_offset, 0.2
        ).set_ease(Tween.EASE_IN if focused else Tween.EASE_OUT
        ).set_trans(Tween.TransitionType.TRANS_SPRING)


func _update_io_offset(offset: float, io: NNodeIO):
    io._update_io_clip_center(offset)
    io._update_io_position(offset)


func _set_mouse_hovered(value: bool):
    mouse_hovered = value
    if Global.hovered_to_selected_nnode != value:
        Global.hovered_to_selected_nnode = value and self.is_in_group("selected_nnodes")


func body_mouse_entered(_nnode):
    body_mouse_hovered = true
    _set_mouse_hovered(true)
    set_body_focus(true)


func io_mouse_entered(nnode):
    if nnode and not body_mouse_hovered:
        hovered_io = nnode

    io_mouse_hovered = true
    _set_mouse_hovered(true)
    set_body_focus(true)


func body_mouse_exited():
    body_mouse_hovered = false
    if not io_mouse_hovered:
        _set_mouse_hovered(false)
    if not focused:
        set_body_focus(mouse_hovered)


func io_mouse_exited():
    io_mouse_hovered = false
    if not body_mouse_hovered:
        _set_mouse_hovered(false)
        if not focused:
            set_body_focus(mouse_hovered)


func body_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int, _nnode):
    if not body_mouse_hovered:
        body_mouse_hovered = true
    if not mouse_hovered:
        _set_mouse_hovered(true)
    if not focused:
        set_body_focus(mouse_hovered)


func io_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int, nnode):
    if nnode and not body_mouse_hovered:
        hovered_io = nnode

    if body_mouse_hovered:
        io_mouse_hovered = false
        # Bypass input event to prioritize body event
        return
    if not io_mouse_hovered:
        io_mouse_hovered = true
    if not mouse_hovered:
        _set_mouse_hovered(true)
        if not focused:
            set_body_focus(mouse_hovered)


func _clear_selected_nnodes(except_self := true):
    var nodes_clear := func(nnode: NNode):
        nnode.remove_from_group("selected_nnodes")
        nnode.focused = false
        nnode.touched = false
        nnode.set_body_focus(false)
        nnode.freeze = false
    _edit_selected_nodes(nodes_clear, except_self)


func _has_touched_other_nnodes() -> bool:
    var selected_nnodes = get_tree().get_nodes_in_group("selected_nnodes")
    for nnode in selected_nnodes:
        if nnode != self and nnode.touched:
            return true
    return false


func _edit_selected_nodes(callback: Callable, except_self := true):
    var selected_nnodes = get_tree().get_nodes_in_group("selected_nnodes")
    for nnode in selected_nnodes:
        if except_self and nnode == self:
            continue
        else:
            callback.call(nnode)


func _some_selected_nnodes(callback: Callable, except_self := true) -> bool:
    var selected_nnodes = get_tree().get_nodes_in_group("selected_nnodes")
    for nnode in selected_nnodes:
        if except_self and nnode == self:
            continue
        elif callback.call(nnode):
            return true
    return false


func _some_all_nnodes(callback: Callable, except_self := true) -> bool:
    var nnodes = get_tree().get_nodes_in_group("nnodes")
    for nnode in nnodes:
        if except_self and nnode == self:
            continue
        elif callback.call(nnode):
            return true
    return false


func _select_nnode():
    focused = true
    add_to_group("selected_nnodes")
    set_body_focus(true)
    freeze = true
    z_index = 1

func _deselect_nnode():
    focused = false
    remove_from_group("selected_nnodes")
    set_body_focus(false)
    freeze = false
    z_index = 0


func _handle_body_mouse_button(
    pressed: bool,
    ctrl_pressed: bool,
    hovered_other_node: bool,
    is_selected: bool,
    dragged: bool,
    is_left: bool,
    is_right: bool,
):
    if is_right and pressed and mouse_hovered:
            kill()

    # Mouse button DOWN body
    if body_mouse_hovered and pressed:
        drag_offset = global_position - camera_reference.get_global_mouse_position()
        touched = true
        body_can_drag = true
        io_can_drag = false

    # Mouse button DOWN inside
    if mouse_hovered and pressed:
        touched = true

        if not ctrl_pressed:
            _select_nnode()

    # Mouse button UP inside
    elif mouse_hovered and not pressed:
        touched = false
        body_can_drag = false
        body_dragging = false
        var selected_on_up = false

        if ctrl_pressed and not is_selected:
            _select_nnode()
            selected_on_up = true
        elif ctrl_pressed and is_selected:
            _deselect_nnode()
        Global.hovered_to_selected_nnode = is_selected or selected_on_up

    # Mouse button DOWN outside
    elif not mouse_hovered and pressed:
        drag_offset = global_position - camera_reference.get_global_mouse_position()
        touched = false
        body_can_drag = false

        if not ctrl_pressed and is_selected and hovered_other_node and not Global.hovered_to_selected_nnode:
            _deselect_nnode()
        elif hovered_other_node and is_selected:
            body_can_drag = true

        # Mouse button UP outside
    elif not mouse_hovered and not pressed:
        touched = false
        body_can_drag = false
        body_dragging = false

        if not ctrl_pressed and is_selected and (not hovered_other_node or not dragged) :
            _deselect_nnode()


func _update_io_connections():
    for io in io_children:
        if io.connected_io:
            continue
        io.reset_rotation()


func _handle_io_mouse_button(
    pressed: bool,
    ctrl_pressed: bool,
    hovered_other_node: bool,
    is_selected: bool,
    dragged: bool,
    is_left: bool,
    is_right: bool,
):
    
    # Mouse button DOWN io
    if hovered_io and pressed and is_left and not body_mouse_hovered:
        io_can_drag = true
        Global.grabbed_io_input = true
        Global.grabbed_io_nnode = hovered_io
        hovered_io.add_to_group("io_connection_candidate")

    # Mouse button UP io NOT DRAGGING (RECEIVING END)
    elif not pressed and is_left and not io_dragging and mouse_hovered:
        # hovered_io.remove_from_group("io_connection_candidate")
        Global.io_connection_candidate = null
        io_can_drag = false

    # Mouse button UP io DRAGGING (CONNECTING END)
    elif not pressed and is_left and io_dragging:
        if Global.io_connection_candidate:
            hovered_io.connected_io = Global.io_connection_candidate
            Global.io_connection_candidate.connected_io = hovered_io
        else:
            hovered_io.connection_canvas.reset_length()
            hovered_io.reset_rotation()

        Global.grabbed_io_input = false
        Global.grabbed_io_nnode = null

    if not pressed:
        io_can_drag = false
        io_dragging = false


func _handle_body_mouse_motion(_event: InputEventMouseMotion):
    if not touched and not focused:
        return
    
    if not body_can_drag or io_can_drag:
        return

    body_dragging = true
    global_position = camera_reference.get_global_mouse_position() + drag_offset


func _get_compatible_io(io_nnode: NNodeIO) -> NNodeIO:
    for io in io_children:
        if io.type != io_nnode.type and not io.connected_io:
            return io
    return null


func _handle_io_mouse_motion(_event: InputEventMouseMotion):

    if not Global.grabbed_io_input and not Global.grabbed_io_nnode:
        return

    var is_receiving := Global.grabbed_io_nnode and Global.grabbed_io_nnode not in io_children and mouse_hovered
    var has_io_candidate := Global.io_connection_candidate and Global.io_connection_candidate in io_children
    var is_connecting := Global.grabbed_io_nnode and Global.grabbed_io_nnode in io_children and io_can_drag

    var target := Vector2.ZERO
    var target_distance := 0.0
    var target_color := color

    # CONNECTING END
    if is_connecting:
        io_dragging = true

        if Global.io_connection_candidate:
            target = Global.io_connection_candidate.get_parent().global_position
            target_distance = (global_position - target).length() - 27 # offset
            target_color = Global.io_connection_candidate.color
        else:
            target = camera_reference.get_global_mouse_position()
            target_distance = (global_position - target).length() - 14 # offset

        hovered_io.pivot_look_at(target)
        hovered_io.connection_canvas.set_length_no_animation(target_distance if not mouse_hovered else 0.0)
        hovered_io.connection_canvas.output_color = target_color

    # RECEIVING END
    # Hovered
    if is_receiving:
        if not has_io_candidate:
            Global.io_connection_candidate = _get_compatible_io(Global.grabbed_io_nnode)
            has_io_candidate = true
        target = Global.grabbed_io_nnode.get_parent().global_position
        Global.io_connection_candidate.pivot_look_with_animation(target)
    # Not Hovered
    elif has_io_candidate:
        if not Global.io_connection_candidate.connected_io:
            Global.io_connection_candidate.reset_rotation()
        Global.io_connection_candidate = null



func _input(event: InputEvent) -> void:
    var is_motion := event is InputEventMouseMotion
    var is_button := event is InputEventMouseButton

    if not is_motion and not is_button:
        return

    if is_button:

        # Mouse button outside without interaction 
        if not mouse_hovered and not focused and not io_dragging:
            return
            
        var pressed = event.pressed
        var ctrl_pressed = event.ctrl_pressed
        var hovered_other_node := _some_all_nnodes(func(nnode):return nnode.mouse_hovered and nnode.body_mouse_hovered)
        var is_selected := self.is_in_group("selected_nnodes")
        var dragged = body_dragging
        var is_left = event.button_index == MOUSE_BUTTON_LEFT
        var is_right = event.button_index == MOUSE_BUTTON_RIGHT

        _handle_body_mouse_button(
            pressed,
            ctrl_pressed,
            hovered_other_node,
            is_selected,
            dragged,
            is_left,
            is_right,
        )

        _handle_io_mouse_button(
            pressed,
            ctrl_pressed,
            hovered_other_node,
            is_selected,
            dragged,
            is_left,
            is_right,
        )

        
    elif is_motion:
        _handle_body_mouse_motion(event)
        _handle_io_mouse_motion(event)

            
        
            
