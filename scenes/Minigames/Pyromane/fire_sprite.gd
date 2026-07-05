extends Node2D
class_name PyromaneFireSprite

var rotationSpeed: float
var verticalSpeed: float
var timer: float

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotationSpeed = 0.08
	verticalSpeed = 0.4
	timer = 2

	if rng.randi_range(0,1) == 1:
		rotationSpeed = -rotationSpeed

func initSprite(playerIndex) -> void:
	var sprite = get_child(1) as Sprite2D
	if (playerIndex != -1):
		sprite.modulate = PlayerInfo.get_color(playerIndex)
	else :
		sprite.modulate = Color.BLACK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_child(0).rotate(rotationSpeed)
	position.y -= verticalSpeed
	timer -= delta
	if (timer < 0):
		queue_free()
