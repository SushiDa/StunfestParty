extends HBoxContainer

@onready var labels = [$ScoreJ1, $ScoreJ2, $ScoreJ3, $ScoreJ4]

func _process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Joueurs")

	for i in range(4):
		labels[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		labels[i].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		if i < players.size() and players[i] != null:
			labels[i].text = "Joueur%d : %d" % [i + 1, players[i].score]
		else:
			labels[i].text = "Joueur%d : -" % (i + 1)
