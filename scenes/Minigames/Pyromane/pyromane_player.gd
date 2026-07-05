extends Node
class_name PyromanePlayer

@export var _hub: PlayerHub
@export var _root: Node2D
@export var _sprite: Sprite2D
@export var _power_prefab: PackedScene
@export var _clope_prefab: PackedScene
@export var _counter_prefab: PackedScene

@export var _throwSFX: AudioStream
@export var _counterSFX: AudioStream
@export var _counterSuccessSFX: AudioStream

var _game: PyromaneGame

var throwing: bool
var countering: bool
var moving : bool

var power: float
var direction: float
var powerNode: PyromanePower

var basemovespeed = 200.0
var slowFactor = 0.2
var runFactor = 1.8

var basePower = 0.1
var maxPower = 1.3
var powerFactor = 1.8
var counterCooldown = 0.25
var counterTimer = 0

var clopeArray: Array[PyromaneClope] = []
var playerAmmo: int

var spriteNode: Sprite2D
var animNode: AnimationPlayer
var colliderNode: Area2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	throwing = false
	moving = false
	playerAmmo = 4
	_hub.btn1_pressed.connect(_on_btn1_pressed)
	_hub.btn2_pressed.connect(_on_btn2_pressed)
	initialize_display()
	spriteNode = get_node("%Sprite")
	animNode = get_node("%AnimationPlayer")
	colliderNode = get_node("%Collider")


func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

func _process(delta: float) -> void:
	(colliderNode.get_child(0) as CollisionShape2D).disabled = false
	var movespeed = basemovespeed

	if (countering):
		counterTimer += delta
		if counterTimer > counterCooldown:
			countering = false
			clopeArray.clear()
		if clopeArray.size() > 0:
			for clope in clopeArray:
				if is_instance_valid(clope):
					counterThrow(clope)
		movespeed = basemovespeed * slowFactor
		colliderNode.position.x = 0 + cos(direction) * 20
		colliderNode.position.y = 0 + sin(direction) * 20
	else :
		colliderNode.position.x = 0
		colliderNode.position.y = 0


	if (throwing && _hub.btn1_hold):
		power += delta
		if power > maxPower-basePower:
			power = maxPower-basePower
		powerNode.get_child(0).scale.x = power * 5 / maxPower
		powerNode.rotation = direction
		movespeed = basemovespeed * slowFactor

	if (throwing && !_hub.btn1_hold):
		throwing = false
		powerNode.queue_free()
		throw()

	if (playerAmmo == 0):
		movespeed = movespeed * runFactor

	if (_hub.movement.x != 0 || _hub.movement.y != 0):
		_root.position.x += _hub.movement.x * movespeed * delta
		_root.position.y -= _hub.movement.y * movespeed * delta
		if (_root.global_position.x >= _game.grid.width * _game.grid.resolution):
			_root.global_position.x = _game.grid.width * _game.grid.resolution - 1
		if (_root.global_position.x < 0):
			_root.global_position.x = 0
		if (_root.global_position.y >= _game.grid.height * _game.grid.resolution):
			_root.global_position.y = _game.grid.height * _game.grid.resolution - 1
		if (_root.global_position.y < 100):
			_root.global_position.y = 100
		direction = atan2(-_hub.movement.y, _hub.movement.x)

		spriteNode.flip_h = _hub.movement.x <= 0
		moving = true
	else :
		moving = false


	var y = int(_root.global_position.y / _game.grid.resolution)
	_root.z_index = int(y);
	
	updateAnim()

		

func _on_btn1_pressed() -> void:
	if (!throwing && !countering && playerAmmo > 0):
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
	power = power + basePower
	var newclope = _clope_prefab.instantiate() as PyromaneClope
	_game.add_child(newclope)
	newclope.global_position.x = _root.global_position.x + cos(direction) * 20
	newclope.global_position.y = -50 + _root.global_position.y - sin(direction) * 20
	newclope.init(0.05 + 0.10*power*powerFactor, 220*power*powerFactor, 400+100*power*powerFactor, -750, direction)
	newclope.setPlayer(self)
	newclope.power = power

	setPlayerAmmo(playerAmmo - 1)
	SFXPlayer.play(_throwSFX, 5)

func counter() -> void:
	var newcounter = _counter_prefab.instantiate() as PyromaneCounter
	newcounter.position.x = 0 + cos(direction) * 20
	newcounter.position.y = -50 + sin(direction) * 20
	newcounter.rotation = direction

	self.add_child(newcounter)
	SFXPlayer.play(_counterSFX, 5)

func counterThrow(clope: PyromaneClope) -> void:
	if clope._player._hub.get_player_index() != _hub.get_player_index() && clope.verticalOffset < 120:
		var prev_power = clope.power
		clopeArray.erase(clope)
		clope.queue_free()

		power = prev_power*1.2
		var newclope = _clope_prefab.instantiate() as PyromaneClope
		_game.add_child(newclope)
		newclope.global_position.x = _root.global_position.x + cos(direction) * 20
		newclope.global_position.y = -50 + _root.global_position.y - sin(direction) * 20
		newclope.init(0.05 + 0.10*power*powerFactor, 220*power*powerFactor, 400+100*power*powerFactor, -750, direction)
		newclope.setPlayer(self)
		SFXPlayer.play(_counterSuccessSFX, 5)
	
		

func fire(x: float, y: float) -> void:
	var inBound = true;
	if (_root.global_position.x >= _game.grid.width * _game.grid.resolution):
		inBound = false
	if (_root.global_position.x < 0):
		inBound = false
	if (_root.global_position.y >= _game.grid.height * _game.grid.resolution):
		inBound = false
	if (_root.global_position.y < 0):
		inBound = false
	
	if (inBound):
		_game.grid.fire(x, y, _hub.get_player_index())

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_of(area.get_parent(), PyromaneClope):
		clopeArray.append(area.get_parent() as PyromaneClope)

	if is_instance_of(area.get_parent(), PyromaneAmmo):
		if playerAmmo == 0:
			var ammo = area.get_parent() as PyromaneAmmo
			ammo.queue_free()
			setPlayerAmmo(4)
			_game.spawnAmmo()

func setPlayerAmmo(ammo: int) -> void:
	playerAmmo = ammo
	updateAmmoDisplay()
	if (ammo == 0):
		(colliderNode.get_child(0) as CollisionShape2D).disabled = true


func updateAmmoDisplay() -> void:
	var ammoNode = get_node("%Ammo") as Node2D
	for i in range (0,4):
		var ammo = ammoNode.get_child(i) as Sprite2D
		ammo.visible = playerAmmo > i

func updateAnim() -> void:
	if (throwing || countering):
		animNode.play("action")
	elif (moving):
		animNode.play("move")
	else:
		animNode.play("idle")

	if (throwing):
		_sprite.texture = _hub.get_character().action1_sprite
	elif (countering):
		_sprite.texture = _hub.get_character().action2_sprite
	else :
		_sprite.texture = _hub.get_character().idle_sprite


		
