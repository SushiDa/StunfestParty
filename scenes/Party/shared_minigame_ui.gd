extends Control
class_name SharedMinigameUI

signal minigame_end_animation_done
signal start_animation_callback
signal finish_animation_callback
signal end_banner_animation_callback

@export var minigame_timer: MinigameTimer
@export var minigame_start_finish: Label
@export var animation_player: AnimationPlayer

@export_group("End banner")
@export var end_label: Label
@export var end_winner_container: Control
@export var end_winner_scene: PackedScene

@export_group("Audio")
@export var sfx_countdown: AudioStream
@export var sfx_start: AudioStream
@export var sfx_finish: AudioStream
@export var sfx_fanfares: AudioStream
@export var sfx_draws: AudioStream

var _current_minigame: MinigameBase
var is_draw: bool = false

func assign_minigame(minigame: MinigameBase) -> void:
	minigame_timer.assign_minigame(minigame)
	_current_minigame = minigame
	
func disconnect_minigame() -> void:
	minigame_timer.assign_minigame(null)
	# TODO Do stuff / Disconnect signals
	
	_current_minigame = null

func assign_winners(winners: Array[int]):

	is_draw = winners.size() == 0

	if is_draw:
		end_label.text = "Égalité"
	else :
		end_label.text = "Gagnants"
	
	for child in end_winner_container.get_children():
		end_winner_container.remove_child(child)

	if !is_draw :
		for winner in winners: 
			var player = PlayerManager.get_player_from_index(winner)
			var player_panel = end_winner_scene.instantiate() as PlayerWinPanel
			player_panel.assign_player_info(player)
			end_winner_container.add_child(player_panel)
	# TODO Rajouter un truc particulier si c'est une égalité

func show_game_end():
	animation_player.play("game_end")
	
func show_start(use_countdown: bool):
	if use_countdown:
		animation_player.play("start_cd");
	else :
		animation_player.play("start_no_cd");

func show_finish():
	animation_player.play("finish");
	pass

	######################
	### ANIM CALLBACKS ###
	######################

func emit_start_callback():
	start_animation_callback.emit()

func emit_finish_callback():
	finish_animation_callback.emit()

func emit_end_banner_callback():
	end_banner_animation_callback.emit()

	#############
	### AUDIO ###
	#############

func play_countdown_sound():
	SFXPlayer.play(sfx_countdown)

func play_fanfare_sound():
	if is_draw:
		SFXPlayer.play(sfx_draws)
	else :
		SFXPlayer.play(sfx_fanfares)

func play_finish_audio():
		SFXPlayer.play(sfx_finish)

func play_start_audio():
	SFXPlayer.play(sfx_start)
