extends Node

var _players: Dictionary[int, PlayerInfo]

func clear_players() -> void:
	_players.clear()

func register_players(player_array: Array[PlayerInfo]):
	_players = {}
	for player:PlayerInfo in player_array:
		_players.set(player.player_index, player)
	
func reset_scores()-> void:
	for player:PlayerInfo in _players.values():
		player.global_party_score = 0

func get_player_from_index(index: int) -> PlayerInfo:
	if _players.has(index): return _players[index]
	return null
	
func get_players() -> Array[PlayerInfo] :
	return _players.values()
