extends Node
class_name BBQMasterPlayer

@export var _hub: PlayerHub
@export var _root: CharacterBody2D
@export var _sprite: Sprite2D
@export var speed = 500

@export var match_file : PackedScene

@export var _max_slot_space : int
@export var _matches_per_slot: int = 3

@export var _ui_inventory: Label

var match_thrown_count = 0
var last_movement = Vector2.ZERO
var throw_force = Vector2(500,500)

signal flame_spawn(size, position)
signal flame_extincted(position)

var _fires: Array[Fire] = []
var _current_bbq: BBQMaster_BBQ = null
var _collect_point: Node = null

var _sausage_count: int = 0;
var _match_count: int = 0;

enum FieldStatusEnum {BBQ, FIELD, COLLECT}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_display();
	_hub.btn1_pressed.connect(on_sausage_button_pressed)
	_hub.btn2_pressed.connect(on_fire_button_pressed)

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_sprite.texture = _hub.get_character().idle_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _root.movement != Vector2.ZERO:
		last_movement = _root.movement

func on_fire_button_pressed() :
	match get_player_state() :
		FieldStatusEnum.FIELD:
			if _match_count > 0:
				_match_count -= 1
				var match_thrown = throw_match(_root.global_position, _root.global_position+last_movement * throw_force)
				update_ui()
		
		FieldStatusEnum.BBQ:
			if _match_count > 0:
				_match_count -= 1
				if _current_bbq && _current_bbq.get_player_index() == _hub.get_player_index():
					_current_bbq.fire_up()

		FieldStatusEnum.COLLECT:
			if _can_collect_stuff(): _match_count += _matches_per_slot
			else :
				_match_count = ceil(_match_count * 1.0 / _matches_per_slot) * _matches_per_slot
				# event can't collect ?
				pass
			update_ui()

func on_sausage_button_pressed() :
	match get_player_state() :
		FieldStatusEnum.FIELD:
			if _fires.size() > 0:
				_sprite.texture = _root.get_character().get_random_sprite()
				_root.get_node("AnimationPlayer").play("RESET")
				_root.get_node("AnimationPlayer").play("extinguish_fire")
				var dist:float = 999.0;
				var fire_to_extinguish = null
				for f in _fires:
					if !f : continue
					var tmp_dist =_root.global_position.distance_squared_to(f.global_position)
					if tmp_dist < dist :
						dist = tmp_dist
						fire_to_extinguish = f
				if fire_to_extinguish: try_to_extinct_fire(fire_to_extinguish)
		
		FieldStatusEnum.BBQ:
			if _current_bbq && _current_bbq.get_player_index() == _hub.get_player_index() :
				_current_bbq.stop_current_sausage()

		FieldStatusEnum.COLLECT:
			if _can_collect_stuff(): _sausage_count += 1
			else : pass # event can't collect ?
			update_ui()


func _can_collect_stuff()->bool : 
	return _sausage_count + ceil(_match_count * 1.0 / _matches_per_slot) < _max_slot_space;

func get_player_state() -> FieldStatusEnum :
	if _current_bbq && _current_bbq.get_player_index() == _hub.get_player_index(): return FieldStatusEnum.BBQ
	elif _collect_point : return FieldStatusEnum.COLLECT
	else : return FieldStatusEnum.FIELD;

func _physics_process(delta: float) -> void:
	#_root.velocity = _hub.movement
	_root.velocity = _hub.movement * speed
	_root.move_and_slide()
	if _root.velocity != Vector2.ZERO and !_root.get_node("AnimationPlayer").is_playing():
		_root.get_node("AnimationPlayer").play("RESET")
		_root.get_node("AnimationPlayer").play("sautiller")
	elif _root.velocity == Vector2.ZERO and _root.get_node("AnimationPlayer").is_playing() and _root.get_node("AnimationPlayer").current_animation == "sautiller":
		_root.get_node("AnimationPlayer").stop()
	#else:
		#if !_root.get_node("AnimationPlayer").is_playing():
			#_root.get_node("AnimationPlayer").stop()
	pass

# Function that allows the player to throw a match
func throw_match(start_pos:Vector2, end_pos:Vector2):
	var bbq_match_instance = match_file.instantiate()
	bbq_match_instance.global_position = start_pos
	add_child(bbq_match_instance)
	#print("Start pos : ", start_pos)
	#print("end pos : ", end_pos)
	bbq_match_instance.set_destination(end_pos)
	return bbq_match_instance
	
func try_to_extinct_fire(fire_to_extinguish):
	fire_to_extinguish.take_damage(1)
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("fire"):
		if !_fires.find(area.get_parent() as Fire) :
			_fires.append(area.get_parent() as Fire)
	elif area.is_in_group("bbq"):
		_current_bbq = area.get_parent() as BBQMaster_BBQ
		if _current_bbq.get_player_index() == _hub.get_player_index() : 
			_current_bbq.add_sausages(_sausage_count)
			_sausage_count = 0
			update_ui()
	elif area.is_in_group("collect"):
		_collect_point = area.get_parent() as Node

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("fire"):
		var index = _fires.find(area.get_parent())
		if index : _fires.remove_at(index)
	elif area.is_in_group("bbq"):
		_current_bbq = null
	elif area.is_in_group("collect"):
		_collect_point = null

func update_ui() -> void:
	_ui_inventory.text = str(_sausage_count) + "s / " + str(_match_count) + "m"
	pass
