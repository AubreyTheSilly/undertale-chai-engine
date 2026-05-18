extends AudioStreamPlayer

var currentbgm : String = ""

var fadeval := 0.0
var targetfade := 0.0

func fadeOut():
	fadeval = -3
	targetfade = -60

func fadeIn():
	fadeval = 3
	targetfade = 0

func _process(_delta) -> void:
	if fadeval >= 0:
		if volume_db <= targetfade:
			volume_db += fadeval
		else:
			volume_db = targetfade
	else:
		if volume_db >= targetfade:
			volume_db += fadeval
		else:
			volume_db = targetfade

func playBGM(bgm : String) -> void:
	var audio = Loader.load_file("Audio/BGM/"+bgm+".ogg")
	volume_db = 0
	currentbgm = bgm
	if audio:
		if !(audio == stream and playing):
			stream = audio
			stream.loop = true
			play()
		elif stream_paused:
			stream_paused = false
	else:
		stop()
