extends Node2D

@onready var dialogbox := $DialogueRect
@onready var soundplayer := get_parent().get_node("DialoguePlayer")

var skiptext = false
var skiptext2 = false

func StartFlavorDialogue(dialogue : String) -> void:
	var sound = "SND_TXT2"
	var cmd = false
	var command = ""
	var speed = 1
	skiptext = false
	$TextObject.text = ""
	for j in dialogue:
		match j:
			"[":
				cmd = true
				command = ""
			"]":
				cmd = false
				var cmand = command.split(":",false)
				print(cmand)
				match cmand[0]:
					"wait":
						if skiptext2 or skiptext:
							continue
						for k in range(int(cmand[1])):
							await get_tree().process_frame
					"speed":
						speed = int(cmand[1])
					_:
							$TextObject.text += "["+command+"]"
			_:
				if cmd == true:
					command += j
				else:
					$TextObject.text += j
					soundplayer.stream = Loader.load_file("Audio/Sounds/"+sound+".wav")
					if j != " " and !skiptext:
						soundplayer.play()
					if !skiptext:
						for k in range(speed):
							await get_tree().process_frame
							#await get_tree().process_frame

func StartBattleDialogue(dialogue : Array) -> void:
	for i in dialogue:
		var sound = "SND_TXT2"
		var cmd = false
		var command = ""
		skiptext2 = false
		$TextObject.text = ""
		for j in i:
			match j:
				"[":
					cmd = true
					command = ""
				"]":
					cmd = false
					var cmand = command.split(":",false)
					print(cmand)
					match cmand[0]:
						"wait":
							if skiptext2 or skiptext:
								continue
							for k in range(int(cmand[1])):
								await get_tree().process_frame
						_:
							$TextObject.text += "["+command+"]"
				_:
					if cmd == true:
						command += j
					else:
						$TextObject.text += j
						soundplayer.stream = load("res://Audio/Sounds/"+sound+".wav")
						if j != " " and !skiptext2:
							soundplayer.play()
						if !skiptext2:
							await get_tree().process_frame
							#await get_tree().process_frame
		while !Input.is_action_just_pressed("Select"):
			await get_tree().process_frame

func _process(_delta) -> void:
	if Input.is_action_just_pressed("Select"):
		skiptext = true
	if Input.is_action_just_pressed("Back"):
		skiptext2 = true
