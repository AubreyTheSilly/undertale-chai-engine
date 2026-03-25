extends CanvasLayer

# 0 = choosing Save or Return, 1 = waiting for user to press Z or X
var state := 0
var choice := 0

func _process(_delta):
	if not visible:
		choice = 0
		state = 0
		for i in $DialogueRect.get_children():
			i.modulate = Color.YELLOW
		return
