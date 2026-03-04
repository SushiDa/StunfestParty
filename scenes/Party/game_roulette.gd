extends Node
class_name Roulette

signal roulette_ended(minigame:MinigameInfo)

@export var roulette_root: Control
@export var roulette_container: Control
@export var game_name: Label
@export var game_subtitle: Label
@export var start_text: Label

@export var panel_btn_hori: Control
@export var panel_btn_vert: Control
@export var panel_btn_move: Control
@export var panel_btn_act1: Control
@export var panel_btn_act2: Control

@export var panel_txt_hori: Label
@export var panel_txt_vert: Label
@export var panel_txt_move: Label
@export var panel_txt_act1: Label
@export var panel_txt_act2: Label

var _all_games: Array[MinigameInfo] = []
var _minigame_indexes: Array[int] = []
var _selected_minigame: MinigameInfo
var _previous_minigame: MinigameInfo
var _ready_to_start: bool

var _rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_show_panel(false)
	_all_games = MinigameRepository.get_minigames()
	_all_games.shuffle()
	_reset_game_indexes()

func dismiss() -> void:
	_show_panel(false)
	
func _show_panel(is_show: bool) -> void:
	roulette_root.scale = Vector2.ZERO
	roulette_root.visible = is_show
	if(is_show):
		roulette_root.scale = Vector2.ONE
		#TODO Animate

func start_roulette() -> void:
	_previous_minigame = _selected_minigame
	_selected_minigame = null
	_update_minigame_display()
	_show_panel(true)
	start_text.visible = false
	var start_index: int = _rng.randi_range(0, _all_games.size() -1)
	#TODO SFX Roulette
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
	#TODO Animate punch scale
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
		panel_btn_hori.visible = false
		panel_btn_vert.visible = false
		panel_btn_move.visible = false
	else :
		game_name.text = _selected_minigame.name
		game_subtitle.text = _selected_minigame.subtitle
		panel_btn_act1.visible = _selected_minigame.action_btn1 != ""
		panel_btn_act2.visible = _selected_minigame.action_btn2 != ""
		panel_btn_hori.visible = _selected_minigame.action_horizontal != ""
		panel_btn_vert.visible = _selected_minigame.action_vertical != ""
		panel_btn_move.visible = _selected_minigame.action_movement != ""
		panel_txt_act1.text = _selected_minigame.action_btn1
		panel_txt_act2.text = _selected_minigame.action_btn2
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
