extends Node
class_name PartySceneManager

@export var score_panel_mgr: ScorePanel
@export var roulette: Roulette
@export var minigame_holder: Node

@export var party_ui: Control
@export var minigame_ui: SharedMinigameUI;

var _current_minigame: MinigameBase
var _current_winners: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.reset_scores()
	score_panel_mgr.intro_ended.connect(_on_intro_end)
	score_panel_mgr.intermission_ended.connect(_on_intermission_end)
	roulette.roulette_ended.connect(_on_roulette_end)
	score_panel_mgr.start_intro()

func _on_intro_end() -> void:
	_start_roulette()

func _start_roulette() -> void:
	roulette.start_roulette()

func _on_roulette_end(selected_game_info:MinigameInfo) -> void:
	_clean_game_holder()
	SceneManager.scene_added.connect(_on_minigame_loaded)
	SceneManager.swap_scenes(selected_game_info.prefab.resource_path, minigame_holder)

func _on_minigame_loaded(scene: Node, _loading)-> void:
	SceneManager.scene_added.disconnect(_on_minigame_loaded)
	var minigame: MinigameBase = scene as MinigameBase
	if minigame != null:
		party_ui.visible = false
		minigame_ui.visible = true
		_current_minigame = minigame
		_current_minigame.game_ended.connect(_on_minigame_end)
		minigame_ui.assign_minigame(_current_minigame)
		_current_minigame.init_game()
		await get_tree().create_timer(1.5).timeout
		_current_minigame.start_game()

func _on_minigame_end(winners: Array[int]) -> void:
	_current_winners = winners
	SceneManager.scene_added.connect(_on_minigame_unloaded)
	SceneManager.swap_scenes("res://scenes/SceneManager/empty.tscn",minigame_holder, _current_minigame)

func _on_minigame_unloaded(_scene, _loading) -> void:
	SceneManager.scene_added.disconnect(_on_minigame_unloaded)
	party_ui.visible = true
	minigame_ui.visible = false
	minigame_ui.disconnect_minigame()
	_current_minigame = null
	await get_tree().create_timer(0.5).timeout
	_start_intermission(_current_winners)

func _start_intermission(winners:Array[int]) -> void:
	score_panel_mgr.start_intermission(winners)

func _on_intermission_end(max_score_reached:bool) -> void:
	if max_score_reached:
		_start_party_end()
	else:
		_start_roulette()

func _start_party_end() -> void:
	print("PARTY END WOW !")
	# TODO

func _clean_game_holder() -> void:
	for node in minigame_holder.get_children():
		node.queue_free()



	
