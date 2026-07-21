extends Node3D

class_name MazePlayer

@export var _hub: PlayerHub
@export var _sprite: Sprite3D
@export var _charaBody: CharacterBody3D
@export var _camera: Camera3D
@export var _speed: float = 10
@export var _bulletSpeed: float = 12
@export var _turningSpeed: float = 10
@export var _shootCooldown: float = 0.2
@export var _bulletPrefab: PackedScene
@export var _deadLabel : Label

signal _onDeath

var target_score: int
var velocity: Vector3
var turningAngle: int
var isDead: bool = false
var shootCD: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hub.btn1_pressed.connect(_on_shoot_pressed)
	initialize_display()

func initialize_display() -> void :
	_sprite.texture = _hub.get_character().idle_sprite

func _process(delta):
	if isDead:
		return;
	if !_hub.btn2_hold:
		_camera.rotate_y(-_hub.movement.x * _turningSpeed * delta)
	if shootCD > 0:
		shootCD -= delta
		
func _physics_process(delta):
	if isDead:
		return;
	if _hub.btn2_hold:
		velocity.x = _hub.movement.x;
	else:
		velocity.x = 0;
	velocity.z = -_hub.movement.y
	var movementSpeed = velocity.rotated(Vector3.UP, _camera.basis.get_euler().y)
	movementSpeed.y = 0
	movementSpeed = movementSpeed.normalized() * _speed
	movementSpeed += Vector3.DOWN * 9.81
	_charaBody.set_velocity(movementSpeed)
	_charaBody.move_and_slide()

func lose() -> void :
	isDead = true
	_deadLabel.visible = true
	_onDeath.emit()
	var tween = get_tree().create_tween()
	tween.tween_property(_sprite, "modulate", Color.TRANSPARENT, 1.0)
	(get_parent() as CharacterBody3D).collision_layer = 4
	
func _on_shoot_pressed() -> void :
	if shootCD > 0:
		return
	shootCD = _shootCooldown
	var bulletInstance = _bulletPrefab.instantiate() as MazeBullet
	get_node("/root").add_child(bulletInstance) #je deteste referencer un node avec un string, à changer plus tard
	var forward = Vector3.FORWARD.rotated(Vector3.UP, _camera.basis.get_euler().y)
	bulletInstance.position = _camera.global_position + forward * 1.5
	bulletInstance.position.y = 1
	forward.y = 0
	bulletInstance.setVelocity(forward * _bulletSpeed)
	bulletInstance.setOriginPlayer(get_parent() as CharacterBody3D)
	
