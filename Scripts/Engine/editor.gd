extends Node2D

var enemypage := 0
var lastpressed := false

func _ready():
	while !Undermaker.Project.has("projectName"):
		await get_tree().process_frame
	$Settings/LineEdit.text = Undermaker.Project["projectName"]
	$Settings/LineEdit2.text = Undermaker.Project["gameName"]

func _on_room_pressed():
	print("room")
	$Camera2D/Place.text = "Room Editor"
	$Settings.visible = false
	$RoomEditor.visible = true
	$EnemyEditor.visible = false
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _on_enemy_pressed():
	print("enemy")
	$Camera2D/Place.text = "Enemy Creator"
	$Settings.visible = false
	$RoomEditor.visible = false
	$EnemyEditor.visible = true
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _on_npc_pressed():
	print("npc")
	$Camera2D/Place.text = "NPC Editor"
	$Settings.visible = false
	$RoomEditor.visible = false
	$EnemyEditor.visible = false
	$NPCEditor.visible = true
	$CharacterEditor.visible = false

func _on_project_pressed():
	print("project settings")
	$Camera2D/Place.text = "Project Settings"
	$Settings.visible = true
	$RoomEditor.visible = false
	$EnemyEditor.visible = false
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _process(_delta):
	if Undermaker.Project.has("projectName"):
		$Camera2D/Label.text = Undermaker.Project["projectName"]
	if $RoomEditor.visible:
		var vel = Vector2(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_up","ui_down"))*-20
		$RoomEditor/RoomDisplay.position += vel

func _on_save_settings_pressed():
	#$Settings/LineEdit.text = Undermaker.Project["projectName"]
	#$Settings/LineEdit2.text = Undermaker.Project["gameName"]
	Undermaker.Project["projectName"] = $Settings/LineEdit.text
	Undermaker.Project["gameName"] = $Settings/LineEdit2.text
	print(Undermaker.Path+"project.json")
	print(Undermaker.createJsonFromDictionary("project.json",Undermaker.Project))

func _on_character_pressed():
	print("character")
	$Camera2D/Place.text = "Character Creator"
	$Settings.visible = false
	$RoomEditor.visible = false
	$EnemyEditor.visible = false
	$NPCEditor.visible = false
	$CharacterEditor.visible = true

func _on_next_enenymenu_pressed():
	if enemypage == 0:
		enemypage = 1
		$EnemyEditor/Page1.visible = false
		$EnemyEditor/Page2.visible = true
	else:
		enemypage = 0
		$EnemyEditor/Page1.visible = true
		$EnemyEditor/Page2.visible = false
