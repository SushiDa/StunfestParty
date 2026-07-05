extends Node2D
class_name PyromaneSoil

var _grid: PyromaneGrid
var _x: int
var _y: int
var _playerIndex: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


func initSoil(playerIndex: int) -> void:
	_x = int(position.x / _grid.resolution)
	_y = int(position.y / _grid.resolution)
	z_index = int(_y)-100;

	_grid.getCell(_x, _y).setSoil(self)
	_playerIndex = playerIndex 

	var sprite = get_child(1) as Sprite2D
	sprite.modulate = PlayerInfo.get_color(_playerIndex)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
