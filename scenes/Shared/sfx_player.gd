extends Node

func play(sound: AudioStream) -> void :
	for child in get_children() :
		var player = child as AudioStreamPlayer
		if !player.playing :
			player.stream = sound
			player.play()
			break