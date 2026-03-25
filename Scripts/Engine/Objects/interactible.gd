extends Area2D

signal interact

func _ready() -> void:
	interact.connect(_interact)

func _process(_delta) -> void:
	var player_in_area = false
	for i in get_overlapping_bodies():
		if i is Player:
			player_in_area = true
	
	if player_in_area and PlayerData.can_move_internal and Input.is_action_just_pressed("Select"):
		interact.emit()

func _interact() -> void:
	pass
