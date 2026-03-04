extends Control
class_name PlayerScorePanel

@export var index_text:Label
@export var score_text:Label
@export var add_score_text:Label
# @export var container:Control
@export var portrait:TextureRect

var _player_info:PlayerInfo
var _initial_add_score_position:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_add_score_position = add_score_text.position

func assign_player_info(info: PlayerInfo)-> void:
	_player_info = info
	update_display()
	
func update_display() -> void:
	index_text.text = "P" + str(_player_info.player_number)
	score_text.text = str(_player_info.global_party_score)
	index_text.self_modulate = _player_info.get_player_color()
	score_text.self_modulate = _player_info.get_player_color()
	portrait.texture = _player_info.character_info.idle_sprite
	add_score_text.text = ""
	add_score_text.scale = Vector2.ONE
	
func set_add_score_text(text: String) -> void :
	add_score_text.set_position(_initial_add_score_position)
	add_score_text.scale = Vector2.ONE
	add_score_text.text = text
	# Play SFX PointPreGet
	await get_tree().create_timer(1).timeout
	update_display()
	portrait.texture = _player_info.character_info.action1_sprite
	# Play SFX PointGet
	await get_tree().create_timer(1).timeout
	portrait.texture = _player_info.character_info.idle_sprite
	
func get_player_index() -> int:
	return _player_info.player_index
