extends Node2D

func timer(frames : int):
	for i in range(frames):
		await get_tree().process_frame

func _ready():
	$AudioStreamPlayer3
	await timer(20)
	
	
	PlayerData.loadFile()
