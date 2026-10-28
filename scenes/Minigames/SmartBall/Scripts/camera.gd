extends Node

func shake(duration: float = 0.3, strength: float = 10.0) -> void:
	var tween = create_tween()
	var steps = int(duration / 0.05)  # une secousse toutes les 50ms
	
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		# Force décroissante au fil du temps
		var t = float(i) / steps
		offset *= (1.0 - t)
		tween.tween_property(self, "offset", offset, 0.05)
	
	# Recentre la caméra à la fin
	tween.tween_property(self, "offset", Vector2.ZERO, 0.05)


func _ready() -> void:
	add_to_group("camera")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
