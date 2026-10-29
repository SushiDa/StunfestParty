extends Node

@export var minigame: MinigameBase
@export var spawn_interval: float
@export var ball_max_count: int
@export var ball_base_speed: float
@export var ball_speed_increment: float
@export var ball_prefab: PackedScene
@export var ball_spawn_point: Node2D

var _current_ball_speed: float
var _current_ball_count: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_ball_speed = ball_base_speed;
	_current_ball_count = 0;
	minigame.game_started.connect(_spawn_balls)
	minigame.game_timer.timeout.connect(_on_game_timeout)
	minigame.players_spawned.connect(_on_players_spawned)

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:DodgePlayer = player.get_node("%PlayerMgr") as DodgePlayer
		p.initialize_display()


func _spawn_balls() -> void:
	while _current_ball_count < ball_max_count :
		_current_ball_count += 1
		var ball: DodgeBall = ball_prefab.instantiate()
		ball.initial_speed = _current_ball_speed
		_current_ball_speed += ball_speed_increment
		ball_spawn_point.add_child(ball)
		minigame.game_timer.timeout.connect(ball.die)
		await get_tree().create_timer(spawn_interval).timeout

func _on_game_timeout() -> void:
	minigame.end_game(minigame.get_winners_from_score(false))
