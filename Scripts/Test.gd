extends Node2D

func _draw():
	if Undermaker.font_glyphs["Determination Mono"]["atlas"]:
		draw_texture(Undermaker.font_glyphs["Determination Mono"]["atlas"],Vector2(0,0))

func _process(_delta):
	queue_redraw()
