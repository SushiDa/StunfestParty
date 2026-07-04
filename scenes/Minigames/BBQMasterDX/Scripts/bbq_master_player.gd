extends Node
class_name BBQMasterPlayer

@export var _hub: PlayerHub
@export var _root: CharacterBody2D
@export var _sprite: Sprite2D
@export var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_display();

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#_hub.btn1.connect()
	#_hub.bnt2.connect()
	#_root.velocity = _hub.movement
	_root.velocity = _hub.movement * speed
	_root.move_and_slide()
	if _root.velocity != Vector2.ZERO:
		_root.get_node("AnimationPlayer").play("sautiller")
	else:
		_root.get_node("AnimationPlayer").stop()
	pass
