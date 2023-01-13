extends Sprite
var screen_center
const multiplier = 0.01
func _ready():
	screen_center = get_viewport().get_visible_rect().get_center()

func _process(delta):
	var mouse_position = get_global_mouse_position()
	
	var distance = mouse_position - screen_center

	var speed = Vector2(distance.x*multiplier,distance.y*multiplier)
	if Input.is_mouse_button_pressed(1):
		material.set_shader_param("speed", speed)
	




	
