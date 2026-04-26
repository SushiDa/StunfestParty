extends Node

@export var minigame_holder: Node
@export var current_game_info: MinigameInfo
@export var btn_players: Button

@export var minigame_ui: SharedMinigameUI;

var _current_game_instance: MinigameBase

var player_count: int = 1
var _current_winners: Array[int] = []
var _finish_animation_pending: bool = false
var _end_after_finish: bool = false

func _ready() -> void:
	_generate_players()
	minigame_ui.start_animation_callback.connect(_on_start_animation_end)
	minigame_ui.finish_animation_callback.connect(_on_finish_animation_end)

func _on_load_game_pressed() -> void:
	_on_destroy_game_pressed()
	var minigame:MinigameBase = current_game_info.prefab.instantiate() as MinigameBase
	minigame_holder.add_child(minigame)
	_current_game_instance = minigame
	if _current_game_instance != null:
		_current_game_instance.game_finish_requested.connect(_on_game_finished)
		_current_game_instance.game_ended.connect(_on_minigame_end)
		minigame_ui.assign_minigame(_current_game_instance)
		_current_game_instance.init_game()
		if minigame.auto_start :
			await get_tree().create_timer(0.5).timeout
			_initiate_game_start()
		else :
			minigame.game_start_request.connect(_initiate_game_start)


func _initiate_game_start()-> void :
	if _current_game_instance != null :
		if !_current_game_instance.auto_start : _current_game_instance.game_start_request.disconnect(_initiate_game_start)
		minigame_ui.show_start(_current_game_instance.start_countdown)
		pass


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

func _on_start_animation_end() -> void:
	if _current_game_instance != null :
		_current_game_instance.start_game()

func _on_finish_animation_end() -> void:
	_finish_animation_pending = false
	if _end_after_finish:
		_show_minigame_end()

func _on_game_finished() -> void :
	_finish_animation_pending = true
	minigame_ui.show_finish()

func _on_minigame_end(winners: Array[int]) -> void:
	_current_winners = winners
	minigame_ui.assign_winners(winners);
	# assign winners to minigame ui here 
	if _finish_animation_pending : _end_after_finish = true
	else : _show_minigame_end()


func _show_minigame_end() -> void:
	minigame_ui.show_game_end()