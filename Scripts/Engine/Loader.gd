extends Node

func load_file(path : String) -> Resource:
	if !FileAccess.file_exists(Undermaker.Path+path):
		return null
	if Undermaker.Path == "res://":
		return load(Undermaker.Path+path)
	if path.ends_with(".png"):
		var img = Image.load_from_file(Undermaker.Path+path)
		var texture = ImageTexture.create_from_image(img)
		return texture
	elif path.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(Undermaker.Path+path)
	elif path.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(Undermaker.Path+path)
	return null

func load_file_absolute(path : String) -> Resource:
	if !FileAccess.file_exists(path):
		return null
	if Undermaker.Path == "res://":
		return load(path)
	if path.ends_with(".png"):
		var img = Image.load_from_file(path)
		var texture = ImageTexture.create_from_image(img)
		return texture
	elif path.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(path)
	elif path.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(path)
	return null
