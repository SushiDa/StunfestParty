extends Area2D

@export var player: Node2D
@export var respawnzone: Area2D


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(area):
		
	if area.is_in_group("Duck"):
		_on_duck_entered(area)	
		
	if area.is_in_group("Bomb"):
		# TODO 
		#  Est qu'on retire des points au joueur ?
	
		area.spawn()
		area.sprite.play("Off")
		
func _on_duck_entered(duck: Duck) -> void:
	if duck.last_thrower != null:
		duck.last_thrower.score += 1
		duck.last_thrower = null
	duck.queue_free()