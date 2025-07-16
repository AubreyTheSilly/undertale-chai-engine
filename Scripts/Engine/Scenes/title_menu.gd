extends Node2D

var d = 0

func _process(_delta):
	$SprTitleimage0.texture = Loader.load_file("Sprites/spr_titleimage_0.png")
	d+=1
	if d >= 100:
		$Label.visible = true
