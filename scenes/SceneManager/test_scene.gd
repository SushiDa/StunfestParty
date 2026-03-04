extends Node2D

@export var minigame_holder: Node
@export var current_game_info: MinigameInfo
@export var btn_players: Button
@export var timer_label: Label

var _current_game_instance: MinigameBase

var player_count: int = 1

func _ready() -> void:
	_generate_players()
	pass

func _on_load_game_pressed() -> void:
	_on_destroy_game_pressed()
	var minigame:MinigameBase = current_game_info.prefab.instantiate() as MinigameBase
	minigame_holder.add_child(minigame)
	_current_game_instance = minigame
	if _current_game_instance != null:
		_current_game_instance.init_game()

func _on_start_game_pressed() -> void:
	if _current_game_instance != null:
		_current_game_instance.start_game()

func _on_destroy_game_pressed() -> void:
	if _current_game_instance != null :
		_current_game_instance.queue_free()
		_current_game_instance = null
	for node in minigame_holder.get_children():
		node.queue_free()

func _on_players_pressed() -> void:
	player_count += 1
	if player_count == 5: player_count = 1
	btn_players.text = "Players : " + str(player_count)
	_generate_players()
	
func _generate_players()-> void:
	var players: Array[PlayerInfo] = []
	var characters = CharacterRepository.get_all_characters()
	characters.shuffle()
	for i in player_count :
		var info: PlayerInfo = PlayerInfo.new()
		info.device_number = i - 1
		info.player_index = i
		info.character_info = characters[i]
		players.append(info)
	PlayerManager.register_players(players)

func _process(_delta: float) -> void:
	if _current_game_instance != null:
		timer_label.text = str(int(ceil(_current_game_instance.game_timer.time_left)))
