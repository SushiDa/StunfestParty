extends Node
class_name PyromanePlayer

@export var _hub: PlayerHub
@export var _root: Node2D
@export var _sprite: Sprite2D
@export var _power_prefab: PackedScene
@export var _clope_prefab: PackedScene
@export var _counter_prefab: PackedScene

var _game: PyromaneGame

var throwing: bool
var countering: bool
var power: float
var direction: float
var powerNode: PyromanePower

var basemovespeed = 180.0

var basePower = 0.3
var maxPower = 2.5
var counterCooldown = 0.25
var counterTimer = 0

var clopeArray: Array[PyromaneClope] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	throwing = false
	_hub.btn1_pressed.connect(_on_btn1_pressed)
	_hub.btn2_pressed.connect(_on_btn2_pressed)
	initialize_display()

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

func _process(delta: float) -> void:
	var movespeed = basemovespeed

	if (countering):
		counterTimer += delta
		if counterTimer > counterCooldown:
			countering = false
			clopeArray.clear()
		if clopeArray.size() > 0:
			for clope in clopeArray:
				counterThrow(clope)


	if (throwing && _hub.btn1_hold):
		power += delta
		if power > maxPower-basePower:
			power = maxPower-basePower
		powerNode.get_child(0).scale.x = power * 2
		powerNode.rotation = direction
		movespeed = basemovespeed / 2

	if (throwing && !_hub.btn1_hold):
		throwing = false
		powerNode.queue_free()
		throw()

	if (_hub.movement.x != 0 || _hub.movement.y != 0):
		_root.position.x += _hub.movement.x * movespeed * delta
		_root.position.y -= _hub.movement.y * movespeed * delta
		direction = atan2(-_hub.movement.y, _hub.movement.x)

func _on_btn1_pressed() -> void:
	if (!throwing && !countering):
		power = 0
		throwing = true
		var newpower = _power_prefab.instantiate() as PyromanePower
		newpower.position.x = 0
		newpower.position.y = -50
		newpower.rotation = direction
		newpower.get_child(0).scale.x = 0
		self.add_child(newpower)
		powerNode = newpower

func _on_btn2_pressed() -> void:
	if (!throwing && !countering):
		clopeArray.clear()
		countering = true
		counterTimer = 0
		counter()

func throw() -> void:
	var power = power + basePower
	var newclope = _clope_prefab.instantiate() as PyromaneClope
	_game.add_child(newclope)
	newclope.global_position.x = _root.global_position.x + cos(direction) * 20
	newclope.global_position.y = -50 + _root.global_position.y - sin(direction) * 20
	newclope.init(0.15*power, 150*power, 200+150*power, -750, direction)
	newclope.setPlayer(self)

func counter() -> void:
	var newcounter = _counter_prefab.instantiate() as PyromaneCounter
	newcounter.position.x = 0 + cos(direction) * 20
	newcounter.position.y = -50 + sin(direction) * 20
	newcounter.rotation = direction
	self.add_child(newcounter)

func counterThrow(clope: PyromaneClope) -> void:
	if clope._player._hub.get_player_index() != _hub.get_player_index(): 
		clopeArray.erase(clope)
		clope.queue_free()

		power = maxPower
		var newclope = _clope_prefab.instantiate() as PyromaneClope
		_game.add_child(newclope)
		newclope.global_position.x = _root.global_position.x + cos(direction) * 20
		newclope.global_position.y = -50 + _root.global_position.y - sin(direction) * 20
		newclope.init(0.15*power, 150*power, 200+150*power, -750, direction)
		newclope.setPlayer(self)
	
		

func fire(x: float, y: float) -> void:
	_game.grid.fire(x, y, _hub.get_player_index())

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_of(area.get_parent(), PyromaneClope):
		clopeArray.append(area.get_parent() as PyromaneClope)
