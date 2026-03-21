extends CanvasLayer

@onready var dialogbox : NinePatchRect = $Box/DialogueRect
@onready var soundplayer : AudioStreamPlayer = $DialoguePlayer
@onready var textobject : TextObject = $Box/TextObject
@onready var facesprite : Sprite2D = $Box/Face

var skiptext = false

enum {UP=0,DOWN=1}

signal dialogue_finished

func StartDialogue(dialogue : Array,position : int = DOWN) -> void:
	visible = true
	textobject.font = preload("res://Fonts/DTM-Mono.otf")
	textobject.size = 13
	textobject.character_spacing = 8
	textobject.line_spacing = 18
	var face = "none"
	facesprite.texture = null
	textobject.position.x = 8
	$DialoguePlayer.stream = preload("res://Audio/Sounds/SND_TXT1.wav")
	if position == 0:
		$Box.position.y = 5
	else:
		$Box.position.y = 160
	for i in dialogue:
		var cmd = false
		var command = ""
		var speed = 1
		skiptext = false
		$Box/TextObject.text = ""
		for j in i:
			match j:
				"[":
					cmd = true
					command = ""
				"]":
					cmd = false
					var cmand = command.split(":",false)
					match cmand[0]:
						"wait":
							if skiptext:
								continue
							for k in range(int(cmand[1])):
								await get_tree().process_frame
						"face":
							face = cmand[1]
							if face == "empty":
								facesprite.texture = null
								textobject.position.x = 8
							else:
								facesprite.texture = Loader.load_file("Sprites/Dialogue Faces/"+face+".png")
								textobject.position.x = 72
						"speed":
							speed = int(cmand[1])
						"font":
							#if Loader.load_file("Fonts/"+".otf"):
								#textobject.font = Loader.load_file("Fonts/"+".otf")
							#elif Loader.load_file("Fonts/"+".ttf"):
								#textobject.font = Loader.load_file("Fonts/"+".ttf")
							var font = FontFile.new()
							font.load_dynamic_font(Undermaker.Path+"Fonts/"+cmand[1])
							if font:
								textobject.font = font
						"font_size":
							textobject.size = int(cmand[1])
							textobject.character_spacing = float(cmand[2])
							textobject.line_spacing = float(cmand[3])
						"sound":
							$DialoguePlayer.stream = Loader.load_file("Audio/Sounds/"+cmand[1]+".wav")
						_:
							$Box/TextObject.text += "["+command+"]"
				_:
					if cmd == true:
						command += j
					else:
						textobject.text += j
						if j != " " and !skiptext:
							soundplayer.play()
						if !skiptext:
							for k in range(speed):
								await get_tree().process_frame
								await get_tree().process_frame
		while !Input.is_action_just_pressed("Select"):
			await get_tree().process_frame
	visible = false
	dialogue_finished.emit()

func _process(_delta) -> void:
	if visible and Input.is_action_just_pressed("Back"):
		skiptext = true
	
	# What the fuck was this line doing. Like I don't remember why it exists (commented it out 1/12/2025??)
	#var audio = AudioStream.new()
