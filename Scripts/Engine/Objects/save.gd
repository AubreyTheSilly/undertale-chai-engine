extends StaticBody2D

var dialogue = []
var saveName := ""

func _on_interact():
	DialogueHandler.StartDialogue(dialogue)
	await DialogueHandler.dialogue_finished
	
	SaveMenu.get_node("DialogueRect/Name").text = saveName
	SaveMenu.visible = true
