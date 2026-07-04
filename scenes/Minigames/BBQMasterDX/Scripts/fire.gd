extends CharacterBody2D
class_name Fire

var pv = 1

func _process(delta: float) -> void:
	if pv==3:
		$AnimatedSprite2D.scale=Vector2(2,2)
	if pv==9:
		$AnimatedSprite2D.scale=Vector2(3,3)
	if pv==12:
		$AnimatedSprite2D.scale=Vector2(4,4)
		$Timer.stop()
	pass

func take_damage(value):
	$Timer.start()
	pv=pv-value
	if pv <= 0:
		queue_free()
	print(pv)

func _on_timer_timeout() -> void:
	pv +=1
	print(pv)
	pass # Replace with function body.
