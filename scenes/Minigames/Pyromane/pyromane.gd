extends Node
class_name PyromaneGame

@export var minigame: MinigameBase
@export var grid: PyromaneGrid
@export var target_score: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()
	#minigame._minigame_running

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PyromanePlayer = player.get_node("%Root") as PyromanePlayer
		p._game = self
		p.initialize_display()

func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))
