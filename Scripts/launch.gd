extends Node2D

func _ready():
	var flags = OS.get_cmdline_args()
	if flags.has("--creator"):
		get_tree().change_scene_to_packed(preload("res://Scenes/editor.tscn"))
