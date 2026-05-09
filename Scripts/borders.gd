extends CanvasLayer

var borders_setup = false

func set_window_size(size : Vector2i) -> void:
	# store size for later
	var old_size = get_window().size
	# change sizes
	get_window().content_scale_size = Vector2i(floor(float(size.x)/2),floor(float(size.y)/2))
	DisplayServer.window_set_size(size)
	
	# fix the window positioning!
	var window_offset = (size-old_size)/2
	
	DisplayServer.window_set_position(get_window().position - window_offset)

func _process(_delta) -> void:
	if visible and !borders_setup:
		borders_setup = true
		set_window_size(Vector2i(960,540))
	elif !visible and borders_setup:
		borders_setup = false
		set_window_size(Vector2i(640,480))
