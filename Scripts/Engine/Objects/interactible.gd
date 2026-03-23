extends Node2D

@onready var area = $Area

func _process(_delta) -> void:
	var player_in_area = false
	for i in area.get_overlapping_bodies():
		if i is Player:
			player_in_area = true
	
	if player_in_area and PlayerData.can_move_internal and Input.is_action_just_pressed("Select"):
		pass
