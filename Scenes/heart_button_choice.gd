extends Sprite2D

func _process(_delta) -> void:
	if modulate != get_tree().current_scene.get_node("BattleHeart/Soul").modulate:
		modulate = get_tree().current_scene.get_node("BattleHeart/Soul").modulate
