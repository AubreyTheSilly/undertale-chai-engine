extends Character

var dialog := []

signal interacted

func _on_interact():
	interacted.emit()
	PlayerData.player_can_move = false
	DialogueHandler.StartDialogue(dialog)
	await DialogueHandler.dialogue_finished
	await get_tree().process_frame
	PlayerData.player_can_move = true
