extends Node

@export var minigame: MinigameBase
@export var bbq_prefab: PackedScene
@export var fire_prefab: PackedScene
@export var origin_center: Node2D

@export var smokey_max_value: float
@export var smokey_base_incr: float
@export var smokey_fire_incr: Curve
@export var smokey_fire_incr_max: float
@export var smokey_fire_max_count: float
@export var debug_label: Label

enum SmokeyStatus { SLEEP, AWAKE, ATTACKING }

var _bbqs: Array[BBQMaster_BBQ] = []
var _fires: Array[Fire] = []
var _current_smokey_value: float = 0
var _current_smokey_status: SmokeyStatus = SmokeyStatus.SLEEP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	# await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()


func _on_players_spawned() -> void:
	for player in minigame.players:
		var bbq_player: BBQMasterPlayer = player.get_node("%BBQPlayerMgr") as BBQMasterPlayer
		bbq_player.initialize_display()
		var bbq_spawn = bbq_player.get_parent().get_node("../BBQSpawn") as Node;
		var bbq_instance = bbq_prefab.instantiate() as BBQMaster_BBQ
		bbq_instance.initialize(player, minigame);
		bbq_spawn.add_child(bbq_instance);
		bbq_player.flame_spawn.connect(spawn_fire)
		bbq_player.throw_match.connect(throw_item)
		bbq_instance.throw_coal.connect(throw_item)
		_bbqs.append(bbq_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if minigame._minigame_running && _current_smokey_value < smokey_max_value:
		var incr = (smokey_base_incr + smokey_fire_incr.sample_baked(_fires.size() / smokey_fire_max_count) * smokey_fire_incr_max)
		if debug_label: debug_label.text = "SMOKEY : " + str(_current_smokey_value).pad_decimals(1) + "/50  (+" + str(incr).pad_decimals(1) + ")"
		_current_smokey_value = min(smokey_max_value, _current_smokey_value + incr * delta)
		if _current_smokey_value >= smokey_max_value: 
			print("SMOKEY, WAZKE UP !!!")
			pass

func _on_game_timeout() -> void:
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	minigame.end_game(minigame.get_winners_from_score(true))

func spawn_fire(position:Vector2):
	var fire = fire_prefab.instantiate() as Fire
	fire.position = position
	fire.extinguished.connect(remove_fire)
	_fires.append(fire)

	var fire_index = bbq_index_from_position(fire.global_position)
	for bbq in _bbqs: 
		if bbq_index_from_position(bbq.global_position) == fire_index :
			fire.player_index = bbq.get_player_index()

	add_child(fire)
	
func remove_fire(fire: Fire):
	var index = _fires.find(fire)
	if index >= 0 : _fires.remove_at(index)

	
func bbq_index_from_position(position: Vector2) -> int:
	var relative = position - origin_center.global_position;
	var result: int = 0;
	if relative.x > 0 : result += 1
	if relative.y > 0 : result += 2
	return result

func get_smokey_aggro() -> BBQMaster_BBQ:
	var target_bbq: BBQMaster_BBQ = null;
	var cur_max_fire = -1;
	for bbq in _bbqs:
		var count = _fires.filter(func(f): return f.player_index == bbq.get_player_index()).size()
		if count > cur_max_fire :
			target_bbq = bbq
			cur_max_fire = count
	return target_bbq


# Function that allows the player to throw a match
func throw_item(start_pos:Vector2, end_pos:Vector2, dist:int, item:PackedScene):
	var bbq_match_instance = item.instantiate()
	bbq_match_instance.global_position = start_pos
	add_child(bbq_match_instance)
	
	bbq_match_instance.origin = start_pos
	#bbq_match_instance.destination = end_pos
	bbq_match_instance.dist_max = dist
	bbq_match_instance.direction = bbq_match_instance.global_position.direction_to(end_pos)
	bbq_match_instance.perpendicular = bbq_match_instance.direction.rotated(-PI / 2).normalized()
	if bbq_match_instance.perpendicular.y > 0:
		bbq_match_instance.perpendicular = -bbq_match_instance.perpendicular
	#var dist = bbq_match_instance.global_position.distance_to(end_pos)
	var dist2 = bbq_match_instance.origin.distance_to(bbq_match_instance.global_position)
	bbq_match_instance.reached_destination.connect(spawn_fire)
	
	return bbq_match_instance
