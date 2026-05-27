extends Sprite2D

var timer := 0

var damage := 0
var kr_damage := 0

func _process(_delta):
	timer += 1
	for i in $attack.get_children():
		i.disabled = timer % 2 != 0 or modulate.a < 0.2
