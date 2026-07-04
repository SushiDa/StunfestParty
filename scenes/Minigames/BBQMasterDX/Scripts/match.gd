extends CharacterBody2D
class_name bbq_match

var direction:Vector2 = Vector2.ZERO
var destination = Vector2.ZERO
var speed = 700

func _process(delta):
	print(global_position)

func set_destination(end_pos:Vector2):
	direction = global_position.direction_to(end_pos)
	destination = end_pos
	print("match destination : ", destination)
	pass
	
func _physics_process(delta: float) -> void:
	velocity = direction * speed
	if round(global_position.x) == round(destination.x) and round(global_position.y) == round(destination.y):
		queue_free()
	move_and_slide()
	pass
	
