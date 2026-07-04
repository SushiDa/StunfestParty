extends CharacterBody2D
class_name bbq_match

var direction: Vector2 = Vector2.ZERO
var origin: Vector2 = Vector2.ZERO
var speed = 700
var dist_max: int = 0
var distance_traveled: float = 0.0
var perpendicular: Vector2
var arc_height: float = 80.0  # léger -> garde une petite valeur

signal reached_destination(arrival_position)

func _physics_process(delta: float) -> void:
	distance_traveled += speed * delta
	var t = clamp(distance_traveled / dist_max, 0.0, 1.0)

	# sin(t*PI) : 0 au départ, monte à 1 au milieu (t=0.5), redescend à 0 à l'arrivée
	var arc_offset = sin(t * PI) * arc_height

	global_position = origin + direction * distance_traveled + perpendicular * arc_offset

	if t >= 1.0:
		reached_destination.emit(global_position)
		queue_free()
