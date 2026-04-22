extends Node2D

func _ready():
	var mods = Undermaker.get_mods_list(OS.get_executable_path().get_base_dir())
	
	var flags = OS.get_cmdline_args()
	await get_tree().process_frame
	if mods.size() >= 1:
		get_tree().change_scene_to_packed(preload("res://Scenes/ModLoader.tscn"))
	elif flags.has("--creator"):
		get_tree().change_scene_to_packed(preload("res://Scenes/editor.tscn"))
	elif flags.has("--battle"):
		get_tree().change_scene_to_packed(preload("res://Scenes/NewBattleLoader.tscn"))
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/intro.tscn"))
