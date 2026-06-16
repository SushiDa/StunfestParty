extends Node
class_name PlayerJumpRace

@export var _hub: PlayerHub
@export var _sprite: Sprite2D
@export var _score_label: Label
@export var _steps: AudioStream
@onready var _playerBody: CharacterBody2D = $"../PlayerBody"

var target_score: int
const JUMP_VELOCITY = -300.0
const SPEED = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hub.btn1_pressed.connect(_on_btn_pressed)
	_hub.btn2_pressed.connect(_on_btn_pressed)
	
	initialize_display()

func initialize_display() -> void :
	_score_label.text = "0"
	_sprite.texture = _hub.get_character().idle_sprite

func _on_btn_pressed() -> void :
	SFXPlayer.play(_steps)
	_sprite.texture = _hub.get_character().get_random_sprite([_sprite.texture])
	
	if _playerBody.is_on_floor():
		_playerBody.velocity.y = JUMP_VELOCITY
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if _hub.movement.x:
		_playerBody.velocity.x = _hub.movement.x * SPEED
	else:
		_playerBody.velocity.x = move_toward(_playerBody.velocity.x, 0, SPEED)
		
	_playerBody.move_and_slide()
