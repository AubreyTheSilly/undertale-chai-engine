extends Node2D

func _on_open_click():
	if $NewProject.visible:
		return
	$OpenProject.visible = true

func _on_quit_click():
	get_tree().quit()

func _on_new_click():
	if $OpenProject.visible:
		return
	$NewProject.visible = true
