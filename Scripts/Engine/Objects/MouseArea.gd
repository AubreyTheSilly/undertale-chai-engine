extends CanvasLayer

@onready var area = $Area2D

func _process(_delta):
	area.position = area.get_global_mouse_position()
