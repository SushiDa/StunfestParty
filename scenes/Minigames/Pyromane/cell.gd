extends Node
class_name PyromaneCell

var _x: int
var _y: int
var _grid: PyromaneGrid
var _tree: PyromaneTree
var _fire: PyromaneFire
var _soil: PyromaneSoil

var rng = RandomNumberGenerator.new()
var updateTimer: float

var baseGrowth = 0.003
var baseSpread = 0.5
var baseReGrowth = 0.018
var cellTickRate = 0.5

func _init(x: int, y: int, grid: PyromaneGrid) -> void:
	self._x = x
	self._y = y
	self._grid = grid
	self._tree = null
	updateTimer = rng.randf_range(0, 1) * cellTickRate

func setTree(tree :PyromaneTree) -> void:
	#print("set tree ",_x,"/",_y)
	_tree = tree

func setFire(fire: PyromaneFire) -> void:
	#print("set fire ",_x,"/",_y)
	_fire = fire

func setSoil(soil: PyromaneSoil) -> void:
	_soil = soil

func hasTree() -> bool:
	return _tree != null

func hasFire() -> bool:
	return _fire != null 

func hasSoil() -> bool:
	return _soil != null   

func update(delta: float) -> void:
	updateTimer += delta

	if (updateTimer > cellTickRate):
		updateTimer -= cellTickRate
		_updateGrowth(cellTickRate)
		_updateFire(cellTickRate)
		_updateSoil(cellTickRate)
	

		
func _updateGrowth(cooldown: float) -> void:
	
	if (!hasTree()):
		var count = 0
		var looprange = 3
		for i in range(max(0,_x - looprange), min(_x + looprange, _grid.width -1), 1):
			for j in range(max(0,_y - looprange), min(_y + looprange, _grid.height -1), 1):
				var cell = _grid.getCell(i,j)
				if (cell.hasTree() && !cell.hasFire()):
					count += 1
		
		#if count > 0:
			#print("count : ", count)
		var growth = 0.0
		if count == 1:
			growth = baseGrowth*1*cooldown
		if count == 2:
			growth = baseGrowth*3*cooldown
		if count >= 3:
			growth = baseGrowth*4*cooldown
		
		var growth_rng = rng.randf_range(0.0, 1.0)
		if growth_rng < growth:
			#print("newtree", _x, "/", _y)
			var newtree = _grid._tree_prefab.instantiate() as PyromaneTree
			_grid.add_child(newtree)
			newtree.position.x = _x * _grid.resolution
			newtree.position.y = _y * _grid.resolution
			newtree._grid = _grid
			if (hasSoil()):
				newtree.initTree(_soil._playerIndex)
			else :
				newtree.initTree(-1)

func _updateFire(cooldown: float) -> void:
	
	if (!hasFire() && hasTree()):
		#print("updatefire ", _x, "/", _y)
		var playerNumber: int
		var count = 0
		var looprange = 3
		for i in range(max(0,_x - looprange), min(_x + looprange, _grid.width -1), 1):
			for j in range(max(0,_y - looprange), min(_y + looprange, _grid.height -1), 1):
				if (!(i == 0 && j == 0)):
					var cell = _grid.getCell(i,j)
					if (cell.hasFire()):
						count += 1
						playerNumber = cell._fire._playerNumber

		var spread = 0.0
		if count == 1:
			spread = baseSpread*1*cooldown
		if count == 2:
			spread = baseSpread*3*cooldown
		if count == 3:
			spread = baseSpread*6*cooldown
		if count >= 4:
			spread = baseSpread*8*cooldown

		var fire_rng = rng.randf_range(0.0, 1.0)
		if fire_rng < spread:
			#print("newfire", _x, "/", _y)
			var newfire = _grid._fire_prefab.instantiate() as PyromaneFire
			_grid.add_child(newfire)
			newfire.position.x = _x * _grid.resolution
			newfire.position.y = _y * _grid.resolution
			newfire._grid = _grid
			newfire.initFire(playerNumber)

func _updateSoil(cooldown: float) -> void:
	if(hasSoil() && !hasTree() && !hasFire()):
		var count = 0
		var looprange = 5
		var stop = false;
		for i in range(max(0,_x - looprange), min(_x + looprange, _grid.width -1), 1):
			if (stop):
				break
			for j in range(max(0,_y - looprange), min(_y + looprange, _grid.height -1), 1):
				var cell = _grid.getCell(i,j)
				if (cell.hasFire()):
					count += 1
					stop = false
					break
					
		if count == 0:
			var growth_rng = rng.randf_range(0.0, 1.0)
			var growth = baseReGrowth * cooldown
			if growth_rng < growth:
				#print("newtree", _x, "/", _y)
				var newtree = _grid._tree_prefab.instantiate() as PyromaneTree
				_grid.add_child(newtree)
				newtree.position.x = _x * _grid.resolution
				newtree.position.y = _y * _grid.resolution
				newtree._grid = _grid
				newtree.initTree(_soil._playerIndex)
		



					







	
