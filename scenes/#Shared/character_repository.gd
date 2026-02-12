extends Node

var _characters:Dictionary[String, CharacterInfo] = {}

func _load_characters() -> void:
	_characters.clear()
	var dir := DirAccess.open("res://assets/characters")
	dir.list_dir_begin()
	for charname: String in dir.get_directories():
		var character := CharacterInfo.new()
		character.character_name = charname
		var chardir := DirAccess.open("res://assets/characters/" + charname)
		chardir.list_dir_begin()
		var cnt := 0
		for file: String in chardir.get_files():
			if(file.ends_with("png")):
				var texture:Texture2D = ResourceLoader.load("res://assets/characters/" + charname + "/" + file, "Texture2D")
				if(cnt == 0): character.idle_sprite = texture
				else: if (cnt == 1): character.action1_sprite = texture
				else: if(cnt == 2): character.action2_sprite = texture
				cnt = cnt+1
		if(cnt > 2): _characters.set(character.character_name, character)

func get_character(chara_name: String) -> CharacterInfo:
	if _characters.is_empty(): _load_characters()
	if _characters.has(chara_name): return _characters[chara_name]
	return null
	
func get_all_characters() -> Array[CharacterInfo]:
	if _characters.is_empty(): _load_characters()
	return _characters.values()
		
	
