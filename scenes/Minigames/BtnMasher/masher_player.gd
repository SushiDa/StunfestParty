extends Node
class_name PlayerMasher

@export var _hub: PlayerHub
@export var _root: Node2D
@export var _sprite: Sprite2D
@export var _score_label: Label
@export var _step_distance: float
@export var _angles: Array[float]

var target_score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hub.btn1_pressed.connect(_on_btn_pressed)
	_hub.btn2_pressed.connect(_on_btn_pressed)
	initialize_display()

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_score_label.text = "0"
	_sprite.texture = _hub.get_character().idle_sprite

func _on_btn_pressed() -> void :
	_hub.score += 1
	# _score_label.text = str(int(target_score - _hub.score))
	_score_label.text = str(int(_hub.score))
	# if _hub.score >= target_score: _hub.win();
	_root.position.x = _hub.score * _step_distance
	_sprite.texture = _hub.get_character().get_random_sprite([_sprite.texture])
	_sprite.rotation_degrees = _angles[int(_hub.score) % _angles.size()]
