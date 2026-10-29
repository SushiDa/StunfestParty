extends Node2D
class_name DodgePlayer

@export var _hub:PlayerHub
@export var _body: CharacterBody2D
@export var _sprite: Sprite2D
@export var _anim: AnimationPlayer
@export var _anim_invincible: AnimationPlayer
@export var _anim_flip: AnimationPlayer
@export var _slap_cooldown: float
@export var _invincibility_duration: float
@export var _speed: float
@export var _score_label: Label

@export var _arrow: Node2D
@export var _arrow_sprite: Sprite2D
@export var _SFX_slap: AudioStream
@export var _SFX_hit: AudioStream

var _current_invincibility_time:float = 0
var _slap_timer:float = 0
var _can_move: bool = true
var _previous_movement: Vector2 = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hub.btn1_pressed.connect(slap)
	_hub.btn2_pressed.connect(slap)
	_hub.debug_init.connect(initialize_display)
	_score_label.text = "0"

func initialize_display() -> void:
	_sprite.texture =_hub.get_character().idle_sprite
	_arrow_sprite.modulate =_hub.get_player_color()
	if _body.global_position.x > 1000 : 
		_previous_movement = Vector2.LEFT
		_sprite.flip_h = true
		_arrow.rotation_degrees = 180

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _current_invincibility_time > 0 :
		_current_invincibility_time -= delta
		if _current_invincibility_time <= 0: 
			_anim_invincible.play("RESET")

	if _slap_timer > 0:
		_slap_timer -= delta
		if _slap_timer <= 0:
			_can_move = true
			_sprite.texture = _hub.get_character().idle_sprite

	pass

func _physics_process(_delta: float) -> void:
	
	var real_movement = _hub.movement * _speed if _can_move else Vector2.ZERO
	_body.velocity = real_movement

	_body.move_and_slide()
	for i in _body.get_slide_collision_count():
		var collision = _body.get_slide_collision(i)
		if collision.get_collider().has_meta("is_ball_active") && collision.get_collider().get_meta("is_ball_active") && _current_invincibility_time <= 0:
			SFXPlayer.play(_SFX_hit)
			_current_invincibility_time = _invincibility_duration
			_anim_invincible.play("invincible")
			_hub.score += 1
			_score_label.text = str(int(_hub.score))

	if _can_move :
		if _body.velocity.length_squared() > 0 :
			_anim.play("move")
		else :
			_anim.play("RESET")

	if _hub.movement.length_squared() > 0.05:
		_arrow.rotation = Vector2.RIGHT.angle_to(_hub.movement)

	if _previous_movement.x * real_movement.x < 0 :
		if real_movement.x > 0 : _anim_flip.play("flip_R")
		else : _anim_flip.play("flip_L")

	if real_movement.abs().x > 0: _previous_movement = real_movement.normalized()

func slap() -> void:
	if _slap_timer > 0: return
	SFXPlayer.play(_SFX_slap)
	_anim.play("RESET")
	_anim.play("slap")
	_can_move = false
	_sprite.texture = _hub.get_character().get_random_sprite([_hub.get_character().idle_sprite])
	_slap_timer = _slap_cooldown
