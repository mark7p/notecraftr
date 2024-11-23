@tool
extends Node2D 

# Circle properties
@export var circle_radius: float = 100.0:
    set(value):
        circle_radius = value
        queue_redraw()

@export var border_radius: float = 0.0:
    set(value):
        border_radius = value
        queue_redraw()
        # if border_radius > 0.0:

@export var circle_color: Color = Color(1, 0, 0):
    set(value):
        circle_color = value
        queue_redraw()


func _ready():
    pass


func _draw():

    # Draw border
    draw_circle(Vector2(0, 0), circle_radius + (circle_radius * border_radius), circle_color - Color(0,0,0,0.5), true, -1.0, true)

    # Draw main circle
    draw_circle(Vector2(0, 0), circle_radius, circle_color, true, -1.0, true)


    

