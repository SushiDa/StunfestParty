extends Node
## Classe de base pour un minijeu.
##
## Doit être à la racine de la scène d'un minijeu.
class_name MinigameBase

signal game_initialized()
signal players_spawned()					
signal game_start_request()					
signal game_started()

signal game_timer_started()
signal game_timer_preshow(time: int)
signal game_timer_timeout()

signal game_finish_requested()
signal game_ended(winners: Array[int])


## Scene du joueur.
@export var player_prefab: PackedScene

## Points de spawns des joueurs. Facultatif.
@export var player_spawns: Array[Node]

## Définit si les spawns peuvent être mélangés (faire apparaitre le P1 au spawn 3, le P2 au spawn 1, etc)
@export var fixed_spawns: bool

## Musique à lancer au démarrage. Facultatif.
@export var music: AudioStream

## Si true, le minijeu démarrera automatiquement après son initialisation (le démarrage est fait par le manager en amont)
## Si false, il faudra manuellement démarrer le minijeu dans la logique du minijeu avec la fonction request_game_start
@export var auto_start: bool = true

## Si true, le démarrage commencera avec un "3 2 1"
@export var start_countdown: bool = true

## Si > 0, un timer sera lancé. Le timer est automatiquement lié à l'ui globale de timer
@export var minigame_duration: int = -1


var game_timer: Timer = Timer.new()		## Timer du minijeu
var minigame_run_time: float = 0		## Temps depuis le démarrage du minijeu
var players: Array[PlayerHub] = []		## Liste des joueurs du minijeu

var _minigame_running: bool = false		
var _spawn_indexes: Array = []


func _ready() -> void:
	add_child(game_timer)
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_time_over)

func _process(delta: float) -> void:
	if !_minigame_running: return
	minigame_run_time += delta

## Démarre le jeu courant. Le PartyManager écoute le signal pour démarrer après countdown.
func request_game_start() -> void :
	game_start_request.emit()

## Démarre un timer (lié automatiquement à l'UI de timer). A utiliser si on veut relancer le timer après son démarrage initial
func start_game_timer(time: float) -> void:
	if time > 0:
		game_timer.start(time)
		game_timer_started.emit()

## Affiche le timer même s'il n'a pas encore démarré. A utiliser en cas de timer manuel
func preshow_game_timer(time: int)-> void:
	game_timer_preshow.emit(time);

## Termine le minijeu courant. Affiche le "FINISH" si il n'a pas encore été fait
## winners: liste des index des gagnants 
func end_game(winners: Array[int]) -> void:
	if _minigame_running: show_finish_and_lock()
	if winners.size() == players.size() && winners.size() != 1 : winners.clear()
	game_ended.emit(winners)

## Affiche "FINISH" et bloque les controles des joueurs
## A appeler si on veut finir la phase de jeu sans annoncer les gagnants tout de suite, si on veut faire une animation
func show_finish_and_lock() -> void:
	MusicPlayer.stop()
	for player in players:
		player.controls_enabled = false
	_minigame_running = false
	game_timer.stop()
	game_finish_requested.emit()

## Permet de récupérer automatiquement la liste des gagnants selon le score attribué aux joueurs (pratique à utiliser avec la fonction end_game)
func get_winners_from_score(most_points_wins:bool) -> Array[int] :
	var winners:Array[int] = []
	if players.size() > 0:
		players.sort_custom(func(a,b): 
			if most_points_wins : return a.score > b.score
			else : return a.score < b.score)
		var top_value:float = players[0].score;
		if players.size() > 1 && players[players.size() - 1].score != top_value:
			for i in players.size():
				if players[i].score == top_value: winners.append(players[i].get_player_index())
	return winners


#region champs privés et appelés par le PartyManager

######											  ######
### !!! NE PAS APPELER DIRECTEMENT DANS LES MINIJEUX ###
######											  ######

###### Les fonctions suivantes sont privées ou appelées par le PartyManager

## Si vous avez besoin de démarrer manuellement un mini jeu, utilisez request_game_start
func start_game() -> void: 
	_minigame_running = true
	start_game_timer(minigame_duration)
	game_started.emit()
	for player in players:
		player.controls_enabled = true

func init_game() -> void:
	# Spawn Players
	_spawn_players()
	game_initialized.emit()
	if music != null:
		MusicPlayer.play(music)

func _on_time_over() -> void:
	game_timer_timeout.emit()
	pass
	
func _on_player_won(player_info:PlayerInfo) -> void:
	end_game([player_info.player_index])

func _spawn_players() ->void:
	players = []
	_reset_indexes()
	if !fixed_spawns: player_spawns.shuffle()
	for p in PlayerManager.get_players() :
		var spawn_parent = self
		if player_spawns.size() > 0:
			spawn_parent = player_spawns[p.player_index % player_spawns.size()]
		var player_instance = player_prefab.instantiate() as PlayerHub
		player_instance.set_player_info(p)
		player_instance.player_won.connect(_on_player_won)
		#TODO scoreboard register player
		players.append(player_instance)
		spawn_parent.add_child(player_instance)
	players_spawned.emit()

func _reset_indexes() -> void:
	_spawn_indexes = range(player_spawns.size()) as Array[int]

#endregion
