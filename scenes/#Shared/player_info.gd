class_name PlayerInfo

var character_info: CharacterInfo
var player_index: int
var player_number: int:
	get: return player_index + 1
var device_number: int
var global_party_score: int

static func get_color(index:int) -> Color :
	match index:
		0: return Color.CYAN
		1: return Color.MAGENTA
		2: return Color.GREEN
		3: return Color.YELLOW
		_: return Color.WHITE
