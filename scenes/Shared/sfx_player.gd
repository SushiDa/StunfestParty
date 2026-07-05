extends Node

func play(sound: AudioStream, volume: float = 0) -> void :
	for child in get_children() :
		var player = child as AudioStreamPlayer
		if !player.playing :
			player.stream = sound
			player.volume_db = volume
			player.play()
			break