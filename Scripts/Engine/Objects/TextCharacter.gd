class_name TextCharacter
extends Label

var font : Font = preload("res://Fonts/DTM-Mono.otf")
var chara : String
var mode = "normal"
var color : Color = Color.WHITE
var timer : float = 0
var originalPos = Vector2.ZERO

func _ready() -> void:
	originalPos = position

func _process(_delta) -> void:
	timer += 0.15
	if label_settings.font != font:
		label_settings.font = font
	if text != chara:
		text = chara
	if label_settings.font_color != color:
		label_settings.font_color = color
	if !Engine.is_editor_hint():
		position = originalPos
		match mode:
			"wavy":
				position.x += sin(timer)*2
				position.y += cos(timer)*2
			"shaky":
				position.x += randf_range(-1,1)
				position.y += randf_range(-1,1)
