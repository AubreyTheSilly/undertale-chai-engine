extends Node2D

var fade = 0

var soul_colors = [Color.RED]

@onready var textobject = $TextObject
@onready var soundplayer = $DialoguePlayer

var dialogue = {
	"texts":[
		"You cannot give[newline]up just yet...",
		"Our fate rests[newline]upon you...",
		"You're going to[newline]be alright...",
		"Don't lose hope!",
		"It cannot end[newline]now!"
	],
	"endingtext":"%![wait:10][newline]Stay determined...",
	"sound":""
}

func StartDialogue(dialog : Array) -> void:
	$DialoguePlayer.stream = Loader.load_file("Audio/Sounds/"+dialogue["sound"]+".wav")
	for i in dialog:
		var cmd = false
		var command = ""
		textobject.text = ""
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
							for k in range(int(cmand[1])):
								await get_tree().process_frame
						"sound":
							$DialoguePlayer.stream = Loader.load_file("Audio/Sounds/"+cmand[1]+".wav")
						_:
							$TextObject.text += "["+command+"]"
				_:
					if cmd == true:
						command += j
					else:
						textobject.text += j
						if j != " ":
							soundplayer.play()
						await get_tree().process_frame
						await get_tree().process_frame
		while !Input.is_action_just_pressed("Select"):
			await get_tree().process_frame

# this only exists to make the code more readable. lol
func makeShard(offset : Vector2) -> void:
	var shard = preload("res://Scenes/Objects/heartshard.tscn").instantiate()
	add_child(shard)
	shard.modulate = $Sprite2D.modulate
	shard.position = PlayerData.battle_soul_pos+offset

func timer(frames : int):
	for i in range(frames):
		await get_tree().process_frame

func _ready() -> void:
	$Sprite2D.position = PlayerData.battle_soul_pos
	var colors = Undermaker.loadJsonAsDictionary("Data/soul_colors.json")
	if colors != {}:
		for i in colors:
			var color : Color = Color.WHITE
			if not colors[i].has("id"):
				return
			if colors[i].has("r"):
				color.r8 =  colors[i]["r"]
			if colors[i].has("g"):
				color.g8 = colors[i]["g"]
			if colors[i].has("b"):
				color.b8 = colors[i]["b"]
			if soul_colors.size()-1 < int(colors[i]["id"]):
				for j in range(int(colors[i]["id"])-soul_colors.size()+1):
					soul_colors.append(Color.WHITE)
			soul_colors[int(colors[i]["id"])] = color
	var dialog = Undermaker.loadJsonAsDictionary("Data/gameover.json")
	if dialog != {}:
		dialogue = dialog
	dialogue["endingtext"] = dialogue["endingtext"].replace("%",PlayerData.Name)
	$Sprite2D.modulate = soul_colors[0]
	await timer(20)
	$AudioStreamPlayer.play()
	$Sprite2D.texture = preload("res://Sprites/Battle/spr_heartbreak_0.png")
	await timer(40)
	$AudioStreamPlayer2.play()
	$Sprite2D.visible = false
	makeShard(Vector2(-2,0))
	makeShard(Vector2(0,3))
	makeShard(Vector2(2,6))
	makeShard(Vector2(8,0))
	makeShard(Vector2(10,3))
	makeShard(Vector2(12,6))
	await timer(50)
	fade = 1
	$AudioStreamPlayer3.play()
	await timer(80)
	await StartDialogue([dialogue["texts"].pick_random(),dialogue["endingtext"]," "])
	fade = 2
	await timer(40)
	PlayerData.loadFile()

func _process(_delta) -> void:
	if fade == 1:
		if $Text.modulate.a < 1:
			$Text.modulate.a += 0.02
	elif fade == 2:
		$Text.modulate.a -= 0.03
		$AudioStreamPlayer3.volume_db -= (80*0.03)
