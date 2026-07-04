extends Node

@export var minigame: MinigameBase
@export var bbq_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	# await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()


func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:BBQMasterPlayer = player.get_node("%BBQPlayerMgr") as BBQMasterPlayer
		var bbq_spawn = p.get_parent().get_node("../BBQSpawn") as Node;
		var bbq_instance = bbq_prefab.instantiate() as BBQMaster_BBQ
		bbq_instance.initialize(player, minigame);
		bbq_spawn.add_child(bbq_instance);
		p.initialize_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))
