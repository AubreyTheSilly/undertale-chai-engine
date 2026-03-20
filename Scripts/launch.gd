extends Node2D

func _ready():
	var mods = Undermaker.get_mods_list(OS.get_executable_path().get_base_dir())
	
	var flags = OS.get_cmdline_args()
	await get_tree().process_frame
	if flags.has("--creator"):
		get_tree().change_scene_to_packed(preload("res://Scenes/editor.tscn"))
	elif flags.has("--battle"):
		get_tree().change_scene_to_packed(preload("res://Scenes/BattleLoader.tscn"))
	elif mods.size() >= 1:
		get_tree().change_scene_to_packed(preload("res://Scenes/ModLoader.tscn"))
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/intro.tscn"))
