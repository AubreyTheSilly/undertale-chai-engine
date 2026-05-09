extends CanvasLayer

var borders_setup = false

@onready var bordersprite = $Border
@onready var fakebordersprite = $FakeBorder

func set_window_size(size : Vector2i) -> void:
	# store size for later
	var old_size = get_window().size
	# change sizes
	get_window().content_scale_size = Vector2i(floor(float(size.x)/2),floor(float(size.y)/2))
	DisplayServer.window_set_size(size)
	
	# fix the window positioning!
	var window_offset = Vector2i((Vector2(size)-Vector2(old_size))/2) # REALLY FUCKY FIX BUT IT REMOVES THE WARN LOL
	
	DisplayServer.window_set_position(get_window().position - window_offset)

func set_border(border) -> void:
	var borderdata = Undermaker.loadJsonAsDictionary("Sprites/Borders/borders.json")
	var sprite : Texture2D
	if borderdata.has(border):
		sprite = Loader.load_file("Sprites/Borders/"+borderdata[border]+".png")
	else:
		sprite = Loader.load_file("Sprites/Borders/"+border+".png")
	
	if !sprite:
		sprite = preload("res://Sprites/Borders/bg_border_line.png")
		if borderdata.has(border):
			push_warning("Border \""+borderdata[border]+"\" does not exist. Defaulting to line border.")
		else:
			push_warning("Border \""+border+"\" does not exist. Defaulting to line border.")
	
	if bordersprite.texture == sprite:
		return
	
	fakebordersprite.texture = bordersprite.texture
	fakebordersprite.modulate.a = 1
	bordersprite.texture = sprite

func _process(_delta) -> void:
	var diff = (bordersprite.texture.get_size()/Vector2(960,540))
	bordersprite.scale = Vector2(0.5/diff.x,0.5/diff.y)
	
	if fakebordersprite.modulate.a >= 0.05:
		fakebordersprite.modulate.a -= 0.05
	elif fakebordersprite.modulate.a != 0:
		fakebordersprite.modulate.a = 0
	
	if visible and !borders_setup:
		borders_setup = true
		set_window_size(Vector2i(960,540))
	elif !visible and borders_setup:
		borders_setup = false
		set_window_size(Vector2i(640,480))
