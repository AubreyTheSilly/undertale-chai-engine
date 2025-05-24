extends Window

func _on_create_click():
	if Undermaker.loadProject($LineEdit.text) == OK:
		visible = false
	else:
		$Label2.visible = true

func _on_back_click():
	visible = false
