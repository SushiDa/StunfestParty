extends Node2D
class_name BBQMaster_BBQ

@export var _temp_decrease_rate: float
@export var _temp_increase_value: float
@export var _temp_states: Array[BBQMaster_TemperatureState]
@export var _sausage_states: Array[BBQMaster_SausageState]


@export var _sprite: Sprite2D

@export var _sausage_sprite: TextureRect

@export var _ui_sausage_count: Label
@export var _ui_sausage_count_zero: Label
@export var _points_label: Label


var _player: PlayerHub;
var _minigame: MinigameBase;

var _temperature:float = 0
var _current_sausage_status: float = 0
var _current_fire_spawn_timer: float = 1
var _sausage_count: int = 10

var _debug_score: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var running = _minigame && _minigame._minigame_running

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
			print("FAYA !!!")
			_current_fire_spawn_timer += 1;

	_ui_sausage_count_zero.visible = _sausage_count <= 0

	_update_graphics()


func initialize(player: PlayerHub, minigame: MinigameBase) -> void:
	_player = player;
	_sprite.modulate = player.get_player_color()
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
	if _player: _player.score += sausage_state.score
	else: _debug_score += sausage_state.score
	print("Score +" + str(sausage_state.score))

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
	_ui_sausage_count.text = "x" + str(_sausage_count)
	_sprite.texture = _get_current_temp_state().sprite
	_sausage_sprite.texture = _get_current_sausage_state().sprite
	if _player: _points_label.text = str(_player.score) + " pts"
	else: _points_label.text = str(_debug_score) + " pts"
