extends Node
class_name PyromaneGame

@export var minigame: MinigameBase
@export var grid: PyromaneGrid
@export var target_score: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	minigame.game_timer_started.connect(_on_game_start)
	await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()
	#minigame._minigame_running

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PyromanePlayer = player.get_node("%Root") as PyromanePlayer
		p._game = self
		p.initialize_display()

func _on_game_start() -> void: 
	grid.start()
	spawnAmmo()

func _on_game_timeout() -> void:
	grid.stop()

	var scores = grid.computeScores()
	var maxScore = max(scores[0], scores[1], scores[2], scores[3])
	print("max", maxScore)
	for player in minigame.players:
		player.score = scores[player.get_player_index()]

	var scoreNode = get_node("%Score") as Control
	scoreNode.visible = true
	for player in minigame.players:
		var label = scoreNode.get_child(0).get_child(player.get_player_index()) as PyromaneScoreLabel
		label.scoreTarget = player.score
		label.maxScore = maxScore
		label.modulate = PlayerInfo.get_color(player.get_player_index())

	minigame.show_finish_and_lock()
	await get_tree().create_timer(4).timeout
	minigame.end_game(minigame.get_winners_from_score(true))

func spawnAmmo() -> void:
	var ammoSpawner = get_node("%AmmoSpawners") as PyromaneAmmoSpawners
	ammoSpawner.spawn()
