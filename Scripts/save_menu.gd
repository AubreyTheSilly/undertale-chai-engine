extends CanvasLayer

# 0 = choosing Save or Return, 1 = waiting for user to press Z or X
var state := 0
var choice := 0

var just_opened = false

func setup_save_screen(save : Dictionary = {}) -> void:
	var curSave
	if save == {}:
		curSave = PlayerData.get_save_file()
	else:
		curSave = save
	
	$DialogueRect/Name.text = curSave["name"]
	$DialogueRect/LV.text = "LV "+str(int(curSave["lv"]))
	$DialogueRect/Place.text = curSave["save_name"]
	if str(int(fmod(curSave["time"],60))).length() == 1:
		$DialogueRect/Time.text = str(int(floor(curSave["time"]/60)))+" 0"+str(int(fmod(curSave["time"],60)))
	else:
		$DialogueRect/Time.text = str(int(floor(curSave["time"]/60)))+" "+str(int(fmod(curSave["time"],60)))

func _process(_delta) -> void:
	if not visible:
		choice = 0
		$DialogueRect/Save.text = "Save"
		$DialogueRect/Return.visible = true
		$DialogueRect/heart.visible = true
		$DialogueRect/heart.position.x = 21.5
		state = 0
		for i in $DialogueRect.get_children():
			if i.name != "heart":
				i.modulate = Color.WHITE
		return
	else:
		if state == 0:
			for i in $DialogueRect.get_children():
				if i.name != "heart":
					i.modulate = Color.WHITE
			if Input.is_action_just_pressed("Move Left") and choice == 1:
				$DialogueRect/heart.position.x = 21.5
				choice = 0
				$AudioStreamPlayer.play()
			if Input.is_action_just_pressed("Move Right") and choice == 0:
				$DialogueRect/heart.position.x = 111.5
				choice = 1
				$AudioStreamPlayer.play()
			if Input.is_action_just_pressed("Back"):
				visible = false
			if Input.is_action_just_pressed("Select") and !just_opened:
				if choice == 1:
					visible = false
				else:
					state = 1
					setup_save_screen(PlayerData.savefile_to_dictionary())
					PlayerData.save_game()
					$AudioStreamPlayer.play()
					$AudioStreamPlayer2.play()
		else:
			for i in $DialogueRect.get_children():
				if i.name != "heart":
					i.modulate = Color.YELLOW
			$DialogueRect/heart.visible = false
			$DialogueRect/Return.visible = false
			$DialogueRect/Save.text = "Game saved."
			if Input.is_action_just_pressed("Select"):
				visible = false
