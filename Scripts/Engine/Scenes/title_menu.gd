extends Node2D

var d = 0

func _ready():
	$SprTitleimage0.texture = Loader.load_file("Sprites/spr_titleimage_0.png")

func _process(_delta):
	d+=1
	if d >= 100:
		$Label.visible = true
	
	if Input.is_action_just_pressed("Select"):
		get_tree().change_scene_to_packed(preload("res://Scenes/StartMenu.tscn"))
