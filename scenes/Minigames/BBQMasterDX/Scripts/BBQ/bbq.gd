extends Node2D
class_name BBQMaster_BBQ

@export var _temp_decrease_rate: float
@export var _temp_increase_value: float
@export var _temp_states: Array[BBQMaster_TemperatureState]
@export var _sausage_states: Array[BBQMaster_SausageState]


@export var _sprite: AnimatedSprite2D

@export var _sausage_sprite: TextureRect

@export var _ui_sausage_count: Label
@export var _ui_sausage_count_zero: Label
@export var _points_label: Label
@export var ui_item_feedback : PackedScene


var _player: PlayerHub; 
var _minigame: MinigameBase;

var _temperature:float = 0
var _current_sausage_status: float = 0
var _current_fire_spawn_timer: float = 1
var _sausage_count: int = 0
var destroyed := false

var _debug_score: int = 0;
signal throw_coal(start_pos:Vector2, end_pos:Vector2, throw_force:int, item_to_throw:PackedScene)
@export var coal_file : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var running = _minigame && _minigame._minigame_running && !destroyed

	if running :
		_temperature = max(0, _temperature - _temp_decrease_rate * delta)

		var temp_state = _get_current_temp_state()

		# Cuisson des saucisses
		if _sausage_count > 0: 
			_current_sausage_status = min(1, _current_sausage_status + temp_state.cook_speed * delta)
			if _current_sausage_status >= 1:
				stop_current_sausage()

		# Spawn du feu
		_current_fire_spawn_timer -= temp_state.fire_spawn_rate * delta
		if _current_fire_spawn_timer <= 0:
			# Spawn fire here
			
			throw_coal.emit(global_position, compute_arrival_pos(200, 500), compute_throw_force(), coal_file)
			_current_fire_spawn_timer += 1;

	_ui_sausage_count_zero.visible = _sausage_count <= 0

	_update_graphics()

func compute_arrival_pos(min_throw_radius, max_throw_radius) -> Vector2:
	var angle = randf_range(0.0, TAU) # TAU = 2*PI, donc direction sur 360°
	var direction = Vector2.RIGHT.rotated(angle)
	var distance = randf_range(min_throw_radius, max_throw_radius)
	return global_position + direction * distance
	
func compute_throw_force():
	var rand_force = randf_range(100, 500)
	return rand_force

func initialize(player: PlayerHub, minigame: MinigameBase) -> void:
	_player = player;
	#_sprite.modulate = player.get_player_color()
	_minigame = minigame
	pass

func fire_up() -> void:
	_temperature = min(1, _temperature + _temp_increase_value)
	pass

func add_sausages(amount: int) -> void:
	_sausage_count += amount;
	pass

func stop_current_sausage() -> void:
	var sausage_state = _get_current_sausage_state()
	if sausage_state.status == BBQMaster_SausageState.SausageStateEnum.RAW :
		return
	
	_sausage_count -= 1
	_current_sausage_status = 0;
	if _player: 
		_player.score += sausage_state.score
		add_ui_feedback_anim("add_text", sausage_state.score)
	else: 
		_debug_score += sausage_state.score
		print("Score +" + str(sausage_state.score))
	
func add_ui_feedback_anim(anim:String, score):
	var ui_feedback = ui_item_feedback.instantiate()
	ui_feedback.rotation_degrees = randf_range(-45.0, 45.0)
	ui_feedback.position += Vector2(randf_range(-50, 50), randf_range(-25, 25))
	add_child(ui_feedback)
	ui_feedback.get_node("HBoxContainer/Label").text = str("Score +") + str(score)
	ui_feedback.get_node("AnimationPlayer").play(anim)
	pass

func _get_current_temp_state() -> BBQMaster_TemperatureState:
	var result = _temp_states[0];
	
	for state in _temp_states :
		if _temperature <state.threshold : break
		result = state

	return result;

func _get_current_sausage_state() -> BBQMaster_SausageState:
	var result = _sausage_states[0];
	
	for state in _sausage_states :
		if _current_sausage_status < state.threshold : break
		result = state

	return result;

func _update_graphics() -> void:
	if destroyed :
		_ui_sausage_count.text = "RIP"
		_sprite.animation = _get_current_temp_state().animation_string
		_sausage_sprite.texture = null
	else :
		_ui_sausage_count.text = "x" + str(_sausage_count)
		_sprite.animation = _get_current_temp_state().animation_string
		_sausage_sprite.texture = _get_current_sausage_state().sprite

	if _player: _points_label.text = str(_player.score) + ""
	else: _points_label.text = str(_debug_score) + ""

func get_player_index() -> int:
	return _player.get_player_index()

func destroy_bbq():
	_sausage_count = 0
	_temperature = 0
	destroyed = true