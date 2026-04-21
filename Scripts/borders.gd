extends CanvasLayer

func _process(_delta) -> void:
	if visible:
		DisplayServer.window_set_size(Vector2i(960, 540))
