extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	while !Input.is_action_just_pressed("Select"):
		await get_tree().process_frame
	PlayerData.HP = PlayerData.MaxHP
	get_tree().change_scene_to_file("res://Scenes/Battle.tscn")
