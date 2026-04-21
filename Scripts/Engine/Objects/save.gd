extends StaticBody2D

var dialogue = []
var saveName := ""

func _on_interact():
	PlayerData.player_can_move = false
	$AudioStreamPlayer.play()
	PlayerData.HP = PlayerData.MaxHP
	DialogueHandler.StartDialogue(dialogue)
	await DialogueHandler.dialogue_finished
	
	PlayerData.save_name = saveName
	SaveMenu.setup_save_screen()
	await get_tree().process_frame
	SaveMenu.visible = true	
	PlayerData.player_can_move = true
