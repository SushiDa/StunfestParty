class_name CharacterInfo

var character_name: String = ""
var idle_sprite: Texture2D
var action1_sprite: Texture2D
var action2_sprite: Texture2D
var select_offset: Vector2

func is_dummy() -> bool:
	return character_name == ""
