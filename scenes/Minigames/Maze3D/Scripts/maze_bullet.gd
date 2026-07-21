extends Node3D

class_name MazeBullet
@export var _rigidbody : RigidBody3D
@export var _light : OmniLight3D
var originPlayer : CharacterBody3D


var dead : bool = false

func _ready() -> void:
	_rigidbody.body_entered.connect(_onBodyEntered)

	
func _onBodyEntered(body: Node) -> void:
	if dead:
		return
	if body == originPlayer:
		return
	if body is CharacterBody3D:
		for child in body.get_children():
			if child is MazePlayer:
				(child as MazePlayer).lose()
	dead = true
	_rigidbody.constant_force = Vector3.ZERO
	_rigidbody.linear_velocity = Vector3.ZERO
	_rigidbody.angular_velocity = Vector3.ZERO
	_rigidbody.freeze = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(_light, "light_energy", 0, .2)
	tween.tween_property(self, "scale", Vector3.ZERO, .3)
	tween.tween_callback(self.queue_free)

func setOriginPlayer(body: CharacterBody3D) -> void:
	originPlayer = body
		
func setVelocity(velocity: Vector3) -> void:
	_rigidbody.linear_velocity = velocity
	_rigidbody.add_constant_force(velocity)
