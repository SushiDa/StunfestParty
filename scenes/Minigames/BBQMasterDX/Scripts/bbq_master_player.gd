extends Node
class_name BBQMasterPlayer

@export var _hub: PlayerHub
@export var _root: Node2D
@export var _sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_display();

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
