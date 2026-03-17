class_name CharacterInfo

var character_name: String = ""
var idle_sprite: Texture2D
var action1_sprite: Texture2D
var action2_sprite: Texture2D:
	get: return action2_sprites[_rng.randi_range(0, action2_sprites.size() - 1 )]
var action2_sprites: Array[Texture2D] = []
var select_offset: Vector2

var _rng = RandomNumberGenerator.new()

func is_dummy() -> bool:
	return character_name == ""

func get_random_sprite(exclusion :Array[Texture2D] = []) -> Texture2D :
	var texs: Array[Texture2D] = []
	texs.append(idle_sprite)
	texs.append(action1_sprite)
	texs.append_array(action2_sprites)
	for t in exclusion:
		var index = texs.find(t)
		if index >= 0: texs.remove_at(index)
	var r_index = _rng.randi_range(0,texs.size() - 1)
	return texs[r_index]
	
