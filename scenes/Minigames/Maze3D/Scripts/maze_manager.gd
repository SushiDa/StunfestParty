extends Node

@export var minigame: MinigameBase
@export var viewports: Array[SubViewport]

var finished : bool  = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)

	

func _on_players_spawned() -> void:	
	var i = 0;
	for player in minigame.players:
		player.reparent(viewports[i])
		for child in player.get_child(0).get_children():
			if child is MazePlayer:
				(child as MazePlayer)._onDeath.connect(_onPlayerDeath)
		i += 1
			
func _onPlayerDeath() -> void:
	if finished:
		return
	var lastAlive = 0
	var countDead = 0
	var i = 0
	for player in minigame.players:
		for child in player.get_child(0).get_children():
			if child is MazePlayer:
				if child.isDead:
					countDead += 1
				else:
					lastAlive = i
		i += 1
	if countDead == minigame.players.size() - 1:
		minigame.end_game([lastAlive])
		finished = true
