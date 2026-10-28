extends CharacterBody2D
class_name PlayerSmart

@export var _hub: PlayerHub

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var confinement: ConfinementComponent = $ConfinementComponent

# Les variables du joueur
@export var skins: Array[SpriteFrames] = []
@export var player_id: int


var score: int:
	get: return _hub.score
	set(value): _hub.score = value

# Capacités du joueur
@export var throw_force: int = 400
@export var speed: int = 200

# Paramètres du tir chargé
@export var min_charge_force: float = 300.0
@export var max_charge_force: float = 950.0
@export var charge_duration: float = 1.0

# Dash
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.20

# Actions
var player_group: String
var carried_object: Area2D = null
var last_direction: Vector2 = Vector2.RIGHT
var explosion_velocity: Vector2 = Vector2.ZERO
var is_charging: bool = false
var charge_time: float = 0.0
var is_dashing: bool = false
var dash_tween: Tween


func _ready() -> void:
	add_to_group("Joueurs")
	set_collision_mask_value(1, false)
	_hub.btn1_pressed.connect(_do_dash)
	_hub.btn2_pressed.connect(_do_throw)


func set_skin(index: int) -> void:
	if skins.is_empty():
		return
	animated_sprite.sprite_frames = skins[index % skins.size()]
	animated_sprite.play("Idle")


func _do_dash() -> void:
	var direction = _hub.movement.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	is_dashing = true
	if dash_tween:
		dash_tween.kill()
	dash_tween = create_tween()
	dash_tween.tween_property(self, "velocity", direction * dash_speed, 0.05)
	dash_tween.tween_property(self, "velocity", Vector2.ZERO, dash_duration)
	dash_tween.tween_callback(func(): is_dashing = false)


func _do_throw() -> void:
	if not carried_object or is_charging:
		return
	is_charging = true
	charge_time = 0.0


func _physics_process(delta: float) -> void:
	var direction := _hub.movement
	if direction.length() > 0:
		direction = direction.normalized()
		last_direction = direction

	if not is_dashing:
		velocity = direction * speed

	if explosion_velocity.length() > 5.0:
		velocity += explosion_velocity
		explosion_velocity = explosion_velocity.lerp(Vector2.ZERO, delta * 5.0)
	else:
		explosion_velocity = Vector2.ZERO

	var old_position := global_position
	move_and_slide()
	if confinement:
		global_position = confinement.confine_position(global_position, old_position)
		if global_position == old_position:
			velocity = Vector2.ZERO

	if direction != Vector2.ZERO:
		animated_sprite.play("Run")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.play("Idle")

	_update_throw_charge(delta)


func _update_throw_charge(delta: float) -> void:
	if not carried_object:
		return
	carried_object.global_position = global_position + Vector2(0, -40)
	if is_charging:
		if _hub.btn2_hold:
			charge_time += delta
			charge_time = min(charge_time, charge_duration)
			if charge_time >= charge_duration:
				var tween = create_tween()
				tween.tween_property(carried_object.sprite, "modulate", Color.DARK_SLATE_GRAY, 0.05)
				tween.tween_property(carried_object.sprite, "modulate", Color.WHITE, 0.2)
		else:
			_release_throw()


func _release_throw() -> void:
	var obj = carried_object
	carried_object = null
	var charge_ratio = charge_time / charge_duration
	var final_force = lerp(min_charge_force, max_charge_force, charge_ratio)
	obj.throw(last_direction, final_force)
	is_charging = false
	charge_time = 0.0


func pick_object(object: Area2D) -> void:
	if carried_object == null:
		carried_object = object


func release_object() -> void:
	carried_object = null


func apply_explosion_force(force: Vector2) -> void:
	explosion_velocity = force
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)


func get_charge_ratio() -> float:
	return charge_time / charge_duration if is_charging else 0.0
