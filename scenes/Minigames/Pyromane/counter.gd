extends Node2D
class_name PyromaneCounter

var timer = 0
var lifeTime = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta;
	get_child(0).scale.x += delta * 20
	get_child(0).scale.y += delta * 10
	
	print("counter ", timer)

	if timer > lifeTime:
		queue_free()
