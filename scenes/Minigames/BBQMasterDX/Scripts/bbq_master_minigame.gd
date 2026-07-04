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
		var bbq_player:BBQMasterPlayer = player.get_node("%BBQPlayerMgr") as BBQMasterPlayer
		bbq_player.initialize_display()
		var bbq_spawn = bbq_player.get_parent().get_node("../BBQSpawn") as Node;
		var bbq_instance = bbq_prefab.instantiate() as BBQMaster_BBQ
		bbq_instance.initialize(player, minigame);
		bbq_spawn.add_child(bbq_instance);

		
		bbq_player.flame_spawn.connect(spawn_fire)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))

func spawn_fire(size, position:Vector2):
	#print("spawn_fire function called. Position of fire : ", position)
	var uid : String = ""
	match size:
		1:uid = "uid://53rkua7kpscu" #small_fire.tscn
		2:uid = "" #small_fire.tscn
		3:uid = "" #small_fire.tscn
		_:uid = "uid://53rkua7kpscu" #small_fire.tscn
	var fire = load(uid).instantiate()
	fire.position = position
	#get_tree().get_root().get_node("game").add_child(fire)
	add_child(fire)
	pass
	

	
