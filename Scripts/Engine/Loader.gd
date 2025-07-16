extends Node

func load_file(path : String) -> Resource:
	if !FileAccess.file_exists(Undermaker.Path+path):
		return null
	if path.ends_with(".png"):
		var img = Image.load_from_file(Undermaker.Path+path)
		var texture = ImageTexture.create_from_image(img)
		return texture
	elif path.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(Undermaker.Path+path)
	elif path.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(Undermaker.Path+path)
	return null
