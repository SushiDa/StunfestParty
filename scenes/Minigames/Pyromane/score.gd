extends Label
class_name PyromaneScoreLabel


var scoreTarget: int
var currentScore: float
var maxScore: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	currentScore = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (currentScore < scoreTarget):
		currentScore += delta * maxScore * 0.5
	else:
		currentScore = int(scoreTarget)
	text = str(int(currentScore))
	pass
