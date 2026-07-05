extends Node2D
class_name PyromaneClope

var _rotationSpeed: float
var _horizontalSpeed: float
var _verticalSpeed: float
var _verticalAccel: float
var _direction: float

var power: float

var _player: PyromanePlayer

var timer
var verticalOffset
var currentVerticalSpeed

var sparkNode: Node2D
@export var spark: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = 0
	verticalOffset = 50
	sparkNode = get_node("%Spawn")

func init(rotationSpeed: float, horizontalSpeed: float, verticalSpeed: float, verticalAccel: float, direction: float) -> void:
	_rotationSpeed = rotationSpeed
	_horizontalSpeed = horizontalSpeed
	_verticalSpeed = verticalSpeed
	_verticalAccel = verticalAccel
	_direction = direction
	currentVerticalSpeed = verticalSpeed

func setPlayer(player: PyromanePlayer) -> void:
	_player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	currentVerticalSpeed += _verticalAccel * delta
	verticalOffset += currentVerticalSpeed * delta

	var vector = Vector2(cos(_direction), -sin(_direction))
	position.x += _horizontalSpeed * vector.x * delta
	position.y -= _horizontalSpeed * vector.y * delta
	position.y -= currentVerticalSpeed * delta

	rotate(_rotationSpeed)

	if (global_position.x >= _player._game.grid.width * _player._game.grid.resolution):
		global_position.x -= _player._game.grid.width * _player._game.grid.resolution
	if (global_position.x < 0):
		global_position.x += _player._game.grid.width * _player._game.grid.resolution
	if (global_position.y >= _player._game.grid.height * _player._game.grid.resolution):
		global_position.y -= _player._game.grid.height * _player._game.grid.resolution
	if (global_position.y < 0):
		global_position.y += _player._game.grid.height * _player._game.grid.resolution

	if verticalOffset < 0:
		_player.fire(global_position.x, global_position.y)
		queue_free()

	spawnSpark()

func spawnSpark() -> void:
	var newspark = spark.instantiate() as PyromaneSpark
	self.get_parent().add_child(newspark)
	newspark.global_position = sparkNode.global_position
