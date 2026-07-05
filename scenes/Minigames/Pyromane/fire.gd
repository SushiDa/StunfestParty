extends Node2D
class_name PyromaneFire

@export var _fireSprite_prefab: PackedScene

var _grid: PyromaneGrid
var _x: int
var _y: int
var _playerNumber: int

var rng = RandomNumberGenerator.new()

var timer: float
var lifeTimer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = 0


func initFire(playerNumber: int) -> void:
	_x = int(position.x / _grid.resolution)
	_y = int(position.y / _grid.resolution)
	z_index = int(_y);

	_playerNumber = playerNumber
	_grid.getCell(_x, _y).setFire(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rate = 0.2

	lifeTimer += delta
	timer += delta
	if (timer > rate):
		#print("spawn")
		timer -= rate
		var spawn = _fireSprite_prefab.instantiate() as PyromaneFireSprite
		spawn.position.x += rng.randf_range(-1,1) * 7
		spawn.position.y += rng.randf_range(-1,1) * 7
		spawn.initSprite(_playerNumber)
		add_child(spawn)
	
	if (lifeTimer > 2.5):
		_grid.removeFire(_x, _y)
		var hasTree = _grid.removeTree(_x, _y)
		if (hasTree):
			_grid.addSoil(_x, _y, _playerNumber)
	
