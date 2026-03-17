class_name LobbyCharacterSlot
extends Node2D
@export var background: Sprite2D
@export var portrait: Sprite2D
@export var default_color: Color 
@export var selected_color: Color 
var target_scale:float

var _character: CharacterInfo

func _ready() -> void:
	background.self_modulate = default_color
	background.modulate = Color.WHITE
	scale = Vector2.ONE * target_scale

func assign_character(character: CharacterInfo) -> void:
	_character = character
	if(character.is_dummy()):
		modulate = Color.TRANSPARENT
	else:
		modulate = Color.WHITE
		portrait.texture = character.idle_sprite
		
func lock(player_index:int) -> void:
	background.self_modulate = selected_color
	background.modulate = PlayerInfo.get_color(player_index)
	portrait.texture = _character.action1_sprite
	
func unlock() -> void:
	background.modulate = Color.WHITE
	background.self_modulate = default_color
	portrait.texture = _character.idle_sprite
	
	
