extends Node2D

func _ready():
	var flags = OS.get_cmdline_args()
	await get_tree().process_frame
	if flags.has("--creator"):
		get_tree().change_scene_to_packed(preload("res://Scenes/editor.tscn"))
	elif flags.has("--battle"):
		get_tree().change_scene_to_packed(preload("res://Scenes/BattleLoader.tscn"))
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/intro.tscn"))
