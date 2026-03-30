extends Control
class_name SharedMinigameUI

signal minigame_end_animation_done
signal start_countdown_timeout

@export var minigame_timer: MinigameTimer

var _current_minigame: MinigameBase

func assign_minigame(minigame: MinigameBase) -> void:
	minigame_timer.assign_minigame(minigame)
	_current_minigame = minigame
	
func disconnect_minigame() -> void:
	minigame_timer.assign_minigame(null)
	# Do stuff / Disconnect signals
	
	_current_minigame = null

func animate_game_end(winners: Array[int]):
	for w in winners: 
		var player = PlayerManager.get_player_from_index(w)
		# Ajouter un panel avec le player / update le sprite
	minigame_end_animation_done.emit()
	pass
	
func show_finish():
	pass
	
func show_start(use_countdown: bool):
	start_countdown_timeout.emit()
	pass
