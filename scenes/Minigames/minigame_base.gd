extends Node
class_name MinigameBase

signal game_initialized()
signal game_start_request()
signal game_started()
signal game_timer_started()
signal game_timer_preshow(time: int)
signal game_timer_timeout()
signal game_finish_requested()
signal game_ended(winners: Array[int])
signal players_spawned()

@export var player_prefab: PackedScene
@export var player_spawns: Array[Node]
@export var fixed_spawns: bool
@export var music: AudioStream
@export var auto_start: bool = true
@export var start_countdown: bool = true
@export var minigame_duration: int = -1

#TODO @export var minigame_scoreboard: MinigameScoreboard

var game_timer: Timer = Timer.new()
var minigame_run_time: float = 0
var _minigame_running: bool = false
var players: Array[PlayerHub] = []
var _spawn_indexes: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(game_timer)
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_time_over)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_minigame_running: return
	minigame_run_time += delta
	
func init_game() -> void:
	# Spawn Players
	_spawn_players()
	game_initialized.emit()
	if music != null:
		MusicPlayer.play(music)


func request_game_start() -> void :
	game_start_request.emit()

func start_game() -> void: 
	_minigame_running = true
	start_game_timer(minigame_duration)
	game_started.emit()
	for player in players:
		player.controls_enabled = true

func _on_time_over() -> void:
	game_timer_timeout.emit()
	pass

func end_game(winners: Array[int]) -> void:
	if _minigame_running: show_finish_and_lock()
	if winners.size() == players.size() && winners.size() != 1 : winners.clear()
	game_ended.emit(winners)

func show_finish_and_lock() -> void:
	MusicPlayer.stop()
	for player in players:
		player.controls_enabled = false
	_minigame_running = false
	game_timer.stop()
	game_finish_requested.emit()

func _spawn_players() ->void:
	players = []
	_reset_indexes()
	if !fixed_spawns: player_spawns.shuffle()
	for p in PlayerManager.get_players() :
		var spawn_parent = self
		if player_spawns.size() > 0:
			spawn_parent = player_spawns[p.player_index % player_spawns.size()]
		var player_instance = player_prefab.instantiate() as PlayerHub
		player_instance.set_player_info(p)
		player_instance.player_won.connect(_on_player_won)
		#TODO scoreboard register player
		players.append(player_instance)
		spawn_parent.add_child(player_instance)
	players_spawned.emit()

func _reset_indexes() -> void:
	_spawn_indexes = range(player_spawns.size()) as Array[int]

func preshow_game_timer(time: int)-> void:
	game_timer_preshow.emit(time);

func start_game_timer(time: float) -> void:
	if time > 0:
		game_timer.start(time)
		game_timer_started.emit()

func _on_player_won(player_info:PlayerInfo) -> void:
	end_game([player_info.player_index])
	
func get_winners_from_score(most_points_wins:bool) -> Array[int] :
	var winners:Array[int] = []
	if players.size() > 0:
		players.sort_custom(func(a,b): 
			if most_points_wins : return a.score > b.score
			else : return a.score < b.score)
		var top_value:float = players[0].score;
		if players.size() > 1 && players[players.size() - 1].score != top_value:
			for i in players.size():
				if players[i].score == top_value: winners.append(players[i].get_player_index())
	return winners
