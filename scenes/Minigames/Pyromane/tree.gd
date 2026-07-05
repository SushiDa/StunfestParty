extends Node2D
class_name PyromaneTree

@export var _grid: PyromaneGrid

var _playerIndex: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func initTree(playerIndex: int) -> void:
	var x = int(position.x / _grid.resolution)
	var y = int(position.y / _grid.resolution)
	z_index = int(y);

	_playerIndex = playerIndex
	var sprite = get_child(1) as Sprite2D
	if (_playerIndex != -1):
		sprite.modulate = PlayerInfo.get_color(_playerIndex)
	else :
		sprite.modulate = Color.BLACK

	_grid.getCell(x, y).setTree(self)

	scale.x = 0
	scale.y = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (scale.x < 1):
		scale.x += delta
		scale.y += delta
