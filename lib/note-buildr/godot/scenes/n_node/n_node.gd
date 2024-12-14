extends RigidBody2D
class_name NNode

@onready var body: NNodeBody = get_node("NNodeBody")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@export var io_children: Array[NNodeIO]
@export var color: Color = Color.WHITE
@export var disabled: bool = false
@export var camera_reference: Camera2D

var body_mouse_hovered := false
var io_mouse_hovered := false
var mouse_hovered := false
var touched := false
var focused := false
var io_position_tween: Tween = null
var drag_offset := Vector2.ZERO
var dragging := false
var can_drag := false
var physics_impulse_multiplier = 25


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

    for io in io_children:
        io.mouse_entered.connect(io_mouse_entered)
        io.mouse_exited.connect(io_mouse_exited)
        io.input_event.connect(io_input_event)
        io._update_io_color(color)
        io._update_io_clip_center(target_offset)
        io._update_io_position(target_offset)
    
    


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


func _input(event: InputEvent) -> void:
    var is_motion := event is InputEventMouseMotion
    var is_button := event is InputEventMouseButton
    if not is_motion and not is_button:
        return
    if is_button:
        
        # Mouse button outside without interaction 
        if not mouse_hovered and not focused:
            return
            
        var pressed = event.pressed
        var is_left_button = event.button_index == MOUSE_BUTTON_LEFT
        var ctrl_pressed = event.ctrl_pressed
        var touched_other_node := _some_selected_nnodes(func(nnode):return nnode.touched)
        var is_selected := self.is_in_group("selected_nnodes")
        var dragged_other_node := _some_selected_nnodes(func(nnode):return nnode.dragging)
        var num_selected_nnodes := len(get_tree().get_nodes_in_group("selected_nnodes"))

        # Mouse button down inside
        if mouse_hovered and pressed:
            # if num_selected_nnodes <= 1 and not ctrl_pressed:
            #     print(1)
            #     _clear_selected_nnodes()
            # touched = true
            # focused = true
            # set_body_focus(focused)
            # add_to_group("selected_nnodes")
            # freeze = true
            if not ctrl_pressed and num_selected_nnodes <= 1:
                touched = true
                focused = true
                add_to_group("selected_nnodes")
                set_body_focus(true)
                freeze = true

            pass

    
        # Mouse button up inside
        if mouse_hovered and not pressed:
            # if not ctrl_pressed and not dragging:
            #     print(2)
            #     _clear_selected_nnodes()
            #     add_to_group("selected_nnodes")
            # touched = false
            # dragging = false
            # can_drag = false
            # _edit_selected_nodes(func(nnode): nnode.dragging=false)
            if ctrl_pressed and not is_selected:
                touched = true
                focused = true
                add_to_group("selected_nnodes")
                set_body_focus(true)
                freeze = true
            elif ctrl_pressed and is_selected:
                touched = false
                focused = false
                remove_from_group("selected_nnodes")
                set_body_focus(false)
                freeze = false

            dragging = false
            can_drag = false

            pass

        # Mouse button down body
        if body_mouse_hovered and pressed:
            touched = true
            drag_offset = global_position - camera_reference.get_global_mouse_position()
            can_drag = true
        

        # Mouse button down outside
        if not mouse_hovered and pressed:
            drag_offset = global_position - camera_reference.get_global_mouse_position()
            # drag_offset = global_position - camera_reference.get_global_mouse_position()
            # if not ctrl_pressed:
            #     touched = false
            # if num_selected_nnodes <= 1 and not ctrl_pressed:
            #     print(3)
            #     _clear_selected_nnodes()
            if not ctrl_pressed and num_selected_nnodes < 1 and is_selected:
                focused = false
                remove_from_group("selected_nnodes")
                set_body_focus(false)
                freeze = false
            touched = false
            dragging = false
            can_drag = false
            pass

         # Mouse button up outside
        if not mouse_hovered and not pressed:
            # if not ctrl_pressed and not dragging:
            #     touched = false
            #     remove_from_group("selected_nnodes")
            #     focused = false
            #     set_body_focus(focused)
            #     freeze = false
            # dragging = false
            # can_drag = false
            # _edit_selected_nodes(func(nnode): nnode.dragging=false)
            if not ctrl_pressed and not dragging:
                focused = false
                remove_from_group("selected_nnodes")
                set_body_focus(false)
                freeze = false
            touched = false
            dragging = false
            can_drag = false
            pass

        # set_body_focus(focused)

    elif is_motion:
        if not touched and not focused:
            return
        
        if not can_drag:
            return

        var drag_nodes := func(nnode: NNode):
            nnode.global_position = camera_reference.get_global_mouse_position() + nnode.drag_offset
            nnode.dragging = true

        _edit_selected_nodes(drag_nodes, false)

            
        
            
