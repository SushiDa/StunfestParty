extends Control
class_name ScorePanel

@export var maximum_points: int
@export var player_score_panel_holder: Node
@export var player_score_panel_prefab: PackedScene

@export var quote_text: Label
@export var random_texts: Array[String]

var _panels: Array[PlayerScorePanel] = []
var _rng = RandomNumberGenerator.new()

signal intro_ended
signal intermission_ended(max_score_reached: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dismiss()
	for player:PlayerInfo in PlayerManager.get_players():
		var player_panel:PlayerScorePanel = player_score_panel_prefab.instantiate()
		player_panel.assign_player_info(player)
		player_score_panel_holder.add_child(player_panel)
		_panels.append(player_panel)

func start_intro() -> void: 
	_change_text()
	_show_scores(false)
	_show_panel(true)
	# animate stuff ici
	await get_tree().create_timer(2).timeout
	intro_ended.emit()
	pass
	
func start_intermission(winners: Array[int]) -> void:
	_change_text()
	_show_scores(true)
	_show_panel(true)
	await get_tree().create_timer(0.5).timeout
	_add_scores(winners)
	_add_score_display(winners)
	await get_tree().create_timer(3).timeout
	intermission_ended.emit(_is_max_score_reached())
	pass
	
func dismiss() -> void:
	_show_panel(false)

func _show_panel(is_show: bool) -> void:
	visible = is_show
	
func _show_scores(is_show: bool) -> void:
	for panel:PlayerScorePanel in _panels:
		panel.score_text.visible = is_show

func _add_score_display(winners: Array[int]) -> void :
	for panel:PlayerScorePanel in _panels:
		if winners.has(panel.get_player_index()):
			panel.set_add_score_text("+1")

func _add_scores(winners: Array[int]) -> void :
	for player:PlayerInfo in PlayerManager.get_players():
		if winners.has(player.player_index):
			player.global_party_score += 1

func _update_score_display() -> void :
	for panel:PlayerScorePanel in _panels:
		panel.update_display()
		
func _is_max_score_reached() -> bool:
	var winners:Array[PlayerInfo] = PlayerManager.get_players().filter(func(p:PlayerInfo): return p.global_party_score >= maximum_points)
	winners.sort_custom(func(a:PlayerInfo,b:PlayerInfo): return a.global_party_score > b.global_party_score)
	return winners.size() == 1 || winners.size() > 1 && winners[0].global_party_score > winners[1].global_party_score

func _change_text() -> void:
	quote_text.text = random_texts[_rng.randi_range(0,random_texts.size() - 1 )]
