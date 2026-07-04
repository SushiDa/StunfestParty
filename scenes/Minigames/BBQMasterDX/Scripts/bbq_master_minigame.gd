extends Node

@export var minigame: MinigameBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	# await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()


func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:BBQMasterPlayer = player.get_node("%BBQPlayerMgr") as BBQMasterPlayer
		p.initialize_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))
