extends Window

func _on_create_click():
	var result = Undermaker.newProject($LineEdit.text)
	if result == OK:
		visible = false
	elif result == ERR_ALREADY_EXISTS:
		$Label2.text = "There's a project in that folder already! Use open project\ninstead."
		$Label2.visible = true
	else:
		$Label2.text = "Malformed string error... Make sure the directory entered\nis correct!"
		$Label2.visible = true

func _on_back_click():
	visible = false
