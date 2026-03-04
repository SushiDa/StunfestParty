extends Node
class_name PlayerHub

var score: float
#TODO var embedded_score_panel

var movement: Vector2
signal move_left
signal move_right
signal move_up
signal move_down

signal btn1_pressed
var btn1_hold: bool

signal btn2_pressed
var btn2_hold: bool

var controls_enabled: bool = false
var minigame_controls_enabled: bool = true

var _player_info: PlayerInfo

signal player_won(player: PlayerInfo)

func set_player_info(info:PlayerInfo) -> void:
	_player_info = info

func get_character() -> CharacterInfo:
	if _player_info != null: return _player_info.character_info
	else :
		return CharacterRepository.get_all_characters()[0]

func get_player_index() -> int:
	if _player_info != null: return _player_info.player_index
	return 0;
	
func get_player_number() -> int:
	if _player_info != null: return _player_info.player_number
	return 1;

func get_player_color() -> Color:
	if _player_info != null: return _player_info.get_player_color()
	else : return Color.CYAN

func win() -> void:
	player_won.emit(_player_info)

func _process(_delta: float) -> void:
	if controls_enabled && minigame_controls_enabled :
		var device = -1
		if _player_info != null: device = _player_info.device_number
		var input_movement: Vector2 = MultiplayerInput.get_vector(device,"move_left","move_right","move_down","move_up")
		var input_btn1: bool = MultiplayerInput.is_action_pressed(device, "action_one")
		var input_btn2: bool = MultiplayerInput.is_action_pressed(device, "action_two")
		
		if input_movement.x != movement.x:
			if (movement.x + 0.25) * (input_movement.x + 0.25) < 0 && movement.x > input_movement.x :
				move_right.emit()
			if (movement.x - 0.25) * (input_movement.x - 0.25) < 0 && movement.x < input_movement.x :
				move_left.emit()
				
		if input_movement.y != movement.y:
			if (movement.y + 0.25) * (input_movement.y + 0.25) < 0 && movement.y > input_movement.y :
				move_down.emit()
			if (movement.y - 0.25) * (input_movement.y - 0.25) < 0 && movement.y < input_movement.y :
				move_up.emit()
		
		if input_btn1 && !btn1_hold: btn1_pressed.emit()
		if input_btn2 && !btn2_hold: btn2_pressed.emit()
		
		movement = input_movement
		btn1_hold = input_btn1
		btn2_hold = input_btn2
	else :
		movement = Vector2.ZERO
		btn1_hold = false
		btn2_hold = false
