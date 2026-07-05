extends Node2D
class_name PyromaneSpark

var speed: float
var lifeTime: float
var timer: float
var direction: float

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 50
	lifeTime = 0.2
	timer = 0
	direction = rng.randf_range(0, PI)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	global_position.x += cos(direction) * delta * speed
	global_position.y += sin(direction) * delta * speed

	timer += delta
	if (timer > lifeTime):
		queue_free()
