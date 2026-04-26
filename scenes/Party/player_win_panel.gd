extends Control
class_name PlayerWinPanel

@export var index_text:Label
@export var name_text:Label
# @export var container:Control
@export var portrait:TextureRect

var _player_info:PlayerInfo

func assign_player_info(info: PlayerInfo)-> void:
	_player_info = info
	update_display()

func update_display() -> void:
	index_text.text = "P" + str(_player_info.player_number)
	name_text.text = _player_info.character_info.character_name
	index_text.self_modulate = _player_info.get_player_color()
	name_text.self_modulate = _player_info.get_player_color()
	portrait.texture = _player_info.character_info.idle_sprite

