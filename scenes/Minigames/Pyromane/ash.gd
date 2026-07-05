extends Node2D
class_name PyromaneAsh

var speed: float
var lifeTime: float
var timer: float
var yOffset: float
var xOffset: float
var startPosition: Vector2

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 180
	lifeTime = 1
	timer = 0
	yOffset = 60 * rng.randf_range(0,1)
	xOffset = 8 * rng.randf_range(-1,1)
	global_position.y += 5 * rng.randf_range(-1,1)
	startPosition = global_position
	global_position.y = startPosition.y - yOffset
	global_position.x = startPosition.x + xOffset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	yOffset -= speed * delta
	if (yOffset < 0):
		yOffset = 0
	
	global_position.y = startPosition.y - yOffset

	

	timer += delta
	if (timer > lifeTime):
		queue_free()

