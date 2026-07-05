extends Node2D
class_name Fire

signal extinguished(fire: Fire)

@export var main_sprite : AnimatedSprite2D
@export var frames_list: Array[SpriteFrames]
@export var sprites_thresholds: Array[float]
@export var pv_max: float
@export var pv_per_second: float
@export var start_pv: float
@export var debug_label: Label

var pv:float = 0
var player_index: int = -1

func _ready() -> void:
	pv = start_pv

func _process(delta: float) -> void:
	pv = min(pv_max, pv + delta * pv_per_second)
	
	var frames = frames_list[0]
	for i in sprites_thresholds.size() :
		if pv > sprites_thresholds[i] : frames = frames_list[i]
	if frames != main_sprite.sprite_frames: 
		main_sprite.sprite_frames = frames
		main_sprite.play("default")
	if debug_label : debug_label.text = str(player_index)

func take_damage(value):
	pv -= value
	if pv <= 0:
		extinguished.emit(self)
		queue_free()
