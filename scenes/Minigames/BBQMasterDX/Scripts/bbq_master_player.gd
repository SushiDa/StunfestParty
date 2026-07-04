extends Node
class_name BBQMasterPlayer

@export var _hub: PlayerHub
@export var _root: CharacterBody2D
@export var _sprite: Sprite2D
@export var speed = 500

signal flame_spawn(size, position)
signal flame_extincted(position)

var colliding_fire_area = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_display();
	_hub.btn1_pressed.connect(on_button_pressed.bind(1))
	_hub.btn2_pressed.connect(on_button_pressed.bind(2))

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#for i in _root.get_slide_collision_count():
		#var collision = _root.get_slide_collision(i)
		#print("Entré en collision avec : ", collision.get_collider().name)
	
	pass
	
	
func on_button_pressed(type):
	match type:
		1:
			flame_spawn.emit(1, _root.global_position)
		2:
			if colliding_fire_area != null:
				extinct_fire(colliding_fire_area)
			#print("button 2 pressed")
			#extinct_fire.emit(_root.global_position)
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

# Function that allows the player to throw a saussage or a match
func throw_item(item, start_pos:Vector2, end_pos:Vector2):
	pass
	
func extinct_fire(fire_to_extinguish):
	fire_to_extinguish.queue_free()
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("fire"):
		colliding_fire_area = area.get_parent()
	pass # Replace with function body.
