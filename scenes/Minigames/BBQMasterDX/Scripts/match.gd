extends CharacterBody2D
class_name bbq_match

var direction

func is_thrown_to(end_pos:Vector2):
	direction = global_position.direction_to(end_pos)
	pass
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	pass
	
