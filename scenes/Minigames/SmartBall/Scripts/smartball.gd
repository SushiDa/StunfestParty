
extends Node

@export var minigame: MinigameBase
@export var target_score: int

const DuckScene = preload("res://scenes/Minigames/SmartBall/duck.tscn")
const BombScene = preload("res://scenes/Minigames/SmartBall/bomb.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	await get_tree().create_timer(2.5).timeout
	minigame.request_game_start()
	for i in range(1,5):
		_spawn_objects(10,DuckScene ,get_node("../Maps/Forest/Spawn/ZoneSpawnP%d" % i ))
		_spawn_objects(2,BombScene ,get_node("../Maps/Forest/Spawn/ZoneSpawnP%d" % i ))
		
func _spawn_objects(count: int, scene_param: PackedScene, respawn_zone: CollisionShape2D) -> void:
	var player_zone := get_node_or_null("../Maps/Forest/PlayerZone") as Area2D
	for i in count:
		var object = scene_param.instantiate()
		object.respawnzone = respawn_zone
		add_child(object)
		object.confinement.confinement_zone = player_zone
		object.spawn()

func _on_players_spawned() -> void:
	var player_zone := get_node_or_null("../Maps/Forest/PlayerZone") as Area2D
	var but_zone := get_node_or_null("../Maps/Forest/But") as Area2D

	if player_zone == null:
		push_error("SmartBall: PlayerZone introuvable (../Maps/Forest/PlayerZone)")
	if but_zone == null:
		push_error("SmartBall: But introuvable (../Maps/Forest/But)")

	var exclusions: Array[Area2D] = []
	if but_zone:
		exclusions.append(but_zone)

	var index := 0
	for player in minigame.players:
		var p: PlayerSmart = player.get_node("%SmartJoueurMgr") as PlayerSmart
		p.confinement.confinement_zone = player_zone
		p.confinement.exclusion_zones = exclusions
		p.set_skin(index)
		index += 1


func _on_game_timeout() -> void:
	minigame.end_game(minigame.get_winners_from_score(true))
