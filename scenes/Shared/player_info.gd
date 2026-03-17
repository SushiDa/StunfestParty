class_name PlayerInfo

var character_info: CharacterInfo
var player_index: int
var player_number: int:
	get: return player_index + 1
var device_number: int
var global_party_score: int

func get_player_color() -> Color:
	return get_color(player_index)

static func get_color(index:int) -> Color :
	match index:
		0: return Color.MAGENTA
		1: return Color.CYAN
		2: return Color.GREEN
		3: return Color.ORANGE
		_: return Color.WHITE

static func get_hue_shift(index:int) -> int :
	match index:
		0: return 330
		1: return 195
		2: return 130
		3: return 40
		_: return 0
