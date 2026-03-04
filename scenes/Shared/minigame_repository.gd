extends Node

var _minigames: Array[MinigameInfo] = []

func _load_minigames() -> void :
	_minigames.clear()
	var dir := DirAccess.open("res://scenes/Minigames")
	dir.list_dir_begin()
	for game_str: String in dir.get_directories():
		var game_dir := DirAccess.open("res://scenes/Minigames/" + game_str)
		game_dir.list_dir_begin()
		for file: String in game_dir.get_files():
			if(file.ends_with(".tres")):
				var info:MinigameInfo = ResourceLoader.load("res://scenes/Minigames/" + game_str + "/" + file, "MinigameInfo")
				if info != null: _minigames.append(info)
		game_dir.list_dir_end()
	dir.list_dir_end()
	
func get_minigames() -> Array[MinigameInfo] :
	if _minigames.is_empty(): _load_minigames()
	return _minigames.duplicate()
