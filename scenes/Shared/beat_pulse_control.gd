class_name BeatPulseControl
extends Control

@export var pulse_scale: Vector2 = Vector2.ONE
@export var scale_duration_pct: float = 1.0
@export var enabled: bool = true

var tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicPlayer.beat.connect(animate)
	pivot_offset_ratio = Vector2(.5,.5)

func animate(_beat: int) -> void:
	if !enabled: return
	var duration = MusicPlayer.beat_length * scale_duration_pct
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, duration).from(pulse_scale)
