extends Node2D

const BOUNCE_VELOCITY = -500.0
@onready var anim = $Area2D/Animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.velocity.y = BOUNCE_VELOCITY
	anim.play("default")
