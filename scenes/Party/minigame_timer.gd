extends Label
class_name MinigameTimer

var _current_minigame: MinigameBase;
var _can_update: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _current_minigame != null && _can_update:
		var time = _current_minigame.game_timer.time_left
		if time >= 0:	
			self.text = str(int(ceil(_current_minigame.game_timer.time_left)))

func assign_minigame(minigame: MinigameBase)-> void:
	_current_minigame = minigame;
	_can_update = false;
	if _current_minigame != null && _current_minigame.minigame_duration > 0:
		_on_preshow_timer(_current_minigame.minigame_duration)
		_current_minigame.game_timer_started.connect(_on_timer_started)
		_current_minigame.game_timer_preshow.connect(_on_preshow_timer)
	else:
		self.text = "";
	
func _on_timer_started() -> void:
	_can_update = true;
	pass

func _on_preshow_timer(time: int) -> void: 
	self.text = str(time)
	pass
