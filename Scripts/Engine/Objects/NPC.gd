extends Character

var dialog := []
var extra_dialogs := []

var interactions := -1

signal interacted

func _on_interact():
	interacted.emit()
	interactions += 1
	if dialog.size() == 0 and interactions == 1:
		return
	PlayerData.player_can_move = false
	if interactions == 0 or extra_dialogs.size() == 0:
		DialogueHandler.StartDialogue(dialog)
	else:
		print(extra_dialogs[clamp(interactions,1,extra_dialogs.size())-1])
		DialogueHandler.StartDialogue(extra_dialogs[clamp(interactions,1,extra_dialogs.size())-1])
	await DialogueHandler.dialogue_finished
	await get_tree().process_frame
	PlayerData.player_can_move = true
