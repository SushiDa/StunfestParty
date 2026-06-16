extends Node

@export var minigame: MinigameBase
@export var target_score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()



func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerMasher = player.get_node("%MasherPlayerMgr") as PlayerMasher
		p.target_score = target_score
		p.initialize_display()

func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))
