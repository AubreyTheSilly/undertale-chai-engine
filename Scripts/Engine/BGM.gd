extends AudioStreamPlayer

func fadeOut():
	volume_db = 0
	while (volume_db > -60):
		volume_db -= 0.7
		await get_tree().process_frame
	volume_db = -60

func playBGM(bgm : String) -> void:
	var audio = Loader.load_file("Audio/BGM/"+bgm+".ogg")
	if audio:
		if audio != stream:
			stream = audio
			volume_db = 0
			play()
	else:
		stream_paused = true
