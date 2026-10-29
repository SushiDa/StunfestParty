extends Node
class_name Roulette

signal roulette_ended(minigame:MinigameInfo)

@export var roulette_root: Control
@export var roulette_container: Control
@export var game_name: Label
@export var game_subtitle: Label
@export var start_text: Label
@export var anim: AnimationPlayer

@export var panel_btn_hori: Control
@export var panel_btn_vert: Control
@export var panel_btn_move: Control
@export var panel_btn_act1: Control
@export var panel_btn_act2: Control
@export var panel_btn_any: Control
@export var panel_btn_act1_mash: Control
@export var panel_btn_act2_mash: Control
@export var panel_btn_any_mash: Control
@export var panel_btn_alt_mash: Control
@export var panel_btn_act1_hold: Control
@export var panel_btn_act2_hold: Control
@export var panel_btn_any_hold: Control

@export var panel_txt_hori: Label
@export var panel_txt_vert: Label
@export var panel_txt_move: Label
@export var panel_txt_act1: Label
@export var panel_txt_act2: Label
@export var panel_txt_any: Label
@export var panel_txt_act1_mash: Label
@export var panel_txt_act2_mash: Label
@export var panel_txt_any_mash: Label
@export var panel_txt_alt_mash: Label
@export var panel_txt_act1_hold: Label
@export var panel_txt_act2_hold: Label
@export var panel_txt_any_hold: Label

@export var _SFX_roulette: AudioStream

var _all_games: Array[MinigameInfo] = []
var _minigame_indexes: Array[int] = []
var _selected_minigame: MinigameInfo
var _previous_minigame: MinigameInfo
var _ready_to_start: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_show_panel(false)
	_all_games = MinigameRepository.get_minigames()
	_all_games.shuffle()
	anim.play("RESET")
	_reset_game_indexes()

func dismiss() -> void:
	_show_panel(false)
	
func _show_panel(is_show: bool) -> void:
	if(is_show):
		anim.play("roulette_open")
	else : anim.play("RESET")

func start_roulette() -> void:
	_previous_minigame = _selected_minigame
	_selected_minigame = null
	_update_minigame_display()
	_show_panel(true)
	start_text.visible = false
	var start_index: int = randi_range(0, _all_games.size() -1)
	SFXPlayer.play(_SFX_roulette)
	for i in 16:
		game_name.text = _all_games[(start_index + i) % _all_games.size()].name
		await get_tree().create_timer(1.25 / 16).timeout
	var index = randi_range(0, _minigame_indexes.size()-1)
	_selected_minigame = _all_games[_minigame_indexes[index]]
	if _selected_minigame == _previous_minigame:
		index = (index + 1) % _minigame_indexes.size()
		_selected_minigame = _all_games[_minigame_indexes[index]]
	_minigame_indexes.remove_at(index)
	
	_update_minigame_display()
	anim.play("roulette_punch")
	if _minigame_indexes.size() == 0: _reset_game_indexes()
	await get_tree().create_timer(1).timeout
	_ready_to_start = true
	start_text.visible = true
	
func _reset_game_indexes() -> void:
	_minigame_indexes = []
	_minigame_indexes.assign(range(_all_games.size()))
	
func _update_minigame_display() -> void:
	if _selected_minigame == null:
		game_name.text = ""
		game_subtitle.text = ""
		panel_btn_act1.visible = false
		panel_btn_act2.visible = false
		panel_btn_any.visible = false
		panel_btn_act1_mash.visible = false
		panel_btn_act2_mash.visible = false
		panel_btn_any_mash.visible = false
		panel_btn_alt_mash.visible = false
		panel_btn_act1_hold.visible = false
		panel_btn_act2_hold.visible = false
		panel_btn_any_hold.visible = false
		panel_btn_hori.visible = false
		panel_btn_vert.visible = false
		panel_btn_move.visible = false
	else :
		game_name.text = _selected_minigame.name
		game_subtitle.text = _selected_minigame.subtitle
		panel_btn_act1.visible = _selected_minigame.action_btn1 != ""
		panel_btn_act2.visible = _selected_minigame.action_btn2 != ""
		panel_btn_any.visible = _selected_minigame.action_btn_any != ""
		panel_btn_act1_mash.visible = _selected_minigame.action_btn1_mash != ""
		panel_btn_act2_mash.visible = _selected_minigame.action_btn2_mash != ""
		panel_btn_any_mash.visible = _selected_minigame.action_btn_any_mash != ""
		panel_btn_alt_mash.visible = _selected_minigame.action_btn_alternate_mash != ""
		panel_btn_act1_hold.visible = _selected_minigame.action_btn1_hold != ""
		panel_btn_act2_hold.visible = _selected_minigame.action_btn2_hold != ""
		panel_btn_any_hold.visible = _selected_minigame.action_btn_any_hold != ""
		panel_btn_hori.visible = _selected_minigame.action_horizontal != ""
		panel_btn_vert.visible = _selected_minigame.action_vertical != ""
		panel_btn_move.visible = _selected_minigame.action_movement != ""

		panel_txt_act1.text = _selected_minigame.action_btn1
		panel_txt_act2.text = _selected_minigame.action_btn2
		panel_txt_any.text = _selected_minigame.action_btn_any
		panel_txt_act1_mash.text = _selected_minigame.action_btn1_mash
		panel_txt_act2_mash.text = _selected_minigame.action_btn2_mash
		panel_txt_any_mash.text = _selected_minigame.action_btn_any_mash
		panel_txt_alt_mash.text = _selected_minigame.action_btn_alternate_mash
		panel_txt_act1_hold.text = _selected_minigame.action_btn1_hold
		panel_txt_act2_hold.text = _selected_minigame.action_btn2_hold
		panel_txt_any_hold.text = _selected_minigame.action_btn_any_hold
		panel_txt_hori.text = _selected_minigame.action_horizontal
		panel_txt_vert.text = _selected_minigame.action_vertical
		panel_txt_move.text = _selected_minigame.action_movement

func _process(_delta: float) -> void:
	if someone_wants_to_start() && _ready_to_start:
		#TODO SFX Lobby Start
		_ready_to_start = false
		roulette_ended.emit(_selected_minigame)
	#TODO F5 pour passer au suivant / debug

func someone_wants_to_start() -> bool:
	for player in PlayerManager.get_players():
		if MultiplayerInput.is_action_just_pressed(player.device_number, "start"):
			return true
	return false
