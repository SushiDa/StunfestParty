class_name LobbyCharacterSlot
extends Sprite2D
@export var portrait: Sprite2D
@export var default_color: Color 

var _character: CharacterInfo

func _ready() -> void:
	self_modulate = default_color

func assign_character(character: CharacterInfo) -> void:
	_character = character
	if(character.is_dummy()):
		print("dummy")
		modulate = Color.TRANSPARENT
	else:
		modulate = Color.WHITE
		portrait.texture = character.idle_sprite
		
func lock(player_index:int) -> void:
	self_modulate = PlayerInfo.get_color(player_index)
	portrait.texture = _character.action1_sprite
	
func unlock() -> void:
	self_modulate = default_color
	portrait.texture = _character.idle_sprite
