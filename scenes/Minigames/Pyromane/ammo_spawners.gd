extends Node2D
class_name PyromaneAmmoSpawners


var currentIndex: int
@export var ammoPrefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentIndex = 0

func spawn() -> void:
	currentIndex += 1
	if (currentIndex >= get_child_count()):
		currentIndex = 0
	
	var spawner = get_child(currentIndex) as Node2D
	var ammo = ammoPrefab.instantiate() as PyromaneAmmo
	spawner.add_child(ammo)
	ammo.global_position = spawner.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
