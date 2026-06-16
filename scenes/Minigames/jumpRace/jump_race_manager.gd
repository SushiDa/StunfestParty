extends Node

@export var minigame: MinigameBase
@export var target_score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerJumpRace = player.get_node("%JumpRacePlayerMgr") as PlayerJumpRace
		p.target_score = target_score
		p.initialize_display()

func _on_game_timeout() -> void:
	minigame.end_game(minigame.get_winners_from_score(true))
