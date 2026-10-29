extends RigidBody2D
class_name DodgeBall

@export var initial_speed: float
@export var _sprite_container: Node2D
@export var _area: Area2D
@export var _anim: AnimationPlayer
@export var _slap_speed_increment: float

var current_speed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_sprite_container.scale = Vector2.ZERO
	_area.area_entered.connect(_on_area_entered)
	current_speed = initial_speed
	var _initial_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	apply_central_impulse(_initial_direction * current_speed)
	create_tween().tween_property(_sprite_container, "scale", Vector2.ONE, 1.5)
	_anim.play("blink")
	await get_tree().create_timer(2.5).timeout
	set_meta("is_ball_active", true)
	_anim.play("RESET")

func _physics_process(delta: float) -> void:
	if linear_velocity.length_squared() > 0:
		linear_velocity = linear_velocity.normalized() * current_speed

func _on_area_entered(body: Area2D) -> void:
	if body.has_meta("is_player"):
		current_speed += _slap_speed_increment
		var direction = Vector2.RIGHT.rotated(body.rotation) * current_speed
		linear_velocity = direction

func die() -> void:
	set_meta("is_ball_active", false)
	await create_tween().tween_property(_sprite_container, "scale", Vector2.ZERO, .5).finished
	queue_free()
