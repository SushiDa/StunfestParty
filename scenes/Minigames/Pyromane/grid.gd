extends Node2D
class_name PyromaneGrid

@export var _tree_prefab: PackedScene
@export var _fire_prefab: PackedScene
@export var _soil_prefab: PackedScene

var cells: Array[PyromaneCell]
var resolution = 20
var width = 1920 / resolution
var height = 1080 / resolution
var _timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cells.resize(width*height)
	for i in range(width):
		for j in range(height):
			cells[i*height+j]= PyromaneCell.new(i, j, self)
	
	for tree in self.get_children() as Array[PyromaneTree]:
		tree.initTree(-1)
	
func getCell(x: int, y: int) -> PyromaneCell:
	return cells[x*height+y]

func getCellFloat(x: float, y: float) -> PyromaneCell:
	var xInt = int(x/resolution);
	var yInt = int(y/resolution);
	return getCell(xInt, yInt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cooldown = 0.2
	_timer += delta
	if _timer > cooldown :
		_timer -= cooldown
		for i in range(width):
			for j in range(height):
				getCell(i,j).update(delta, cooldown)
	#for cell in cells as Array[PyromaneCell]:
	#	cell.update(delta)

func fire(x: float, y: float, playerNumber: int) -> void:
	var cell = getCellFloat(x,y)
	#print("fire cell", cell._x, "/", cell._y)
	var newfire = _fire_prefab.instantiate() as PyromaneFire
	self.add_child(newfire)
	newfire.position.x = cell._x * resolution
	newfire.position.y = cell._y * resolution
	newfire._grid = self
	newfire.initFire(playerNumber)

func addSoil(x: int, y: int, playerNumber: int) -> void:
	var cell = getCell(x, y)
	var newsoil = _soil_prefab.instantiate() as PyromaneSoil
	self.add_child(newsoil)
	newsoil.position.x = cell._x * resolution
	newsoil.position.y = cell._y * resolution
	newsoil._grid = self
	newsoil.initSoil(playerNumber)

func removeTree(x: int, y: int) -> bool:
	var cell = getCell(x, y)
	var hasTree = cell.hasTree()
	if (cell._tree != null):
		cell._tree.queue_free()
		cell._tree = null
	return hasTree
	

func removeFire(x: int, y: int) -> void:
	var cell = getCell(x, y)
	if (cell._fire != null):
		cell._fire.queue_free()
		cell._fire = null
