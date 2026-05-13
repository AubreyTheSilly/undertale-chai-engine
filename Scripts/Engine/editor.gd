extends Node2D

var enemypage := 0
var lastpressed := false

func _ready():
	Borders.visible = false
	while !Undermaker.Project.has("projectName"):
		await get_tree().process_frame
	$Settings/LineEdit.text = Undermaker.Project["projectName"]
	$Settings/LineEdit2.text = Undermaker.Project["gameName"]
	$Settings/LineEdit3.text = Undermaker.Project["desc"]

func _on_room_pressed():
	print("room")
	$CanvasLayer/Place.text = "Room Editor"
	$Settings.visible = false
	$CanvasLayer/RoomEditor.visible = true
	$EnemyEditor.visible = false
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _on_enemy_pressed():
	print("enemy")
	$CanvasLayer/Place.text = "Enemy Creator"
	$Settings.visible = false
	$CanvasLayer/RoomEditor.visible = false
	$EnemyEditor.visible = true
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _on_npc_pressed():
	print("npc")
	$CanvasLayer/Place.text = "NPC Editor"
	$Settings.visible = false
	$CanvasLayer/RoomEditor.visible = false
	$EnemyEditor.visible = false
	$NPCEditor.visible = true
	$CharacterEditor.visible = false

func _on_project_pressed():
	print("project settings")
	$CanvasLayer/Place.text = "Project Settings"
	$Settings.visible = true
	$CanvasLayer/RoomEditor.visible = false
	$EnemyEditor.visible = false
	$NPCEditor.visible = false
	$CharacterEditor.visible = false

func _process(_delta):
	$RoomDisplay.visible = $CanvasLayer/RoomEditor.visible
	$FakeTile.visible = $CanvasLayer/RoomEditor.visible and $"/root/editor/RoomDisplay".room[$CanvasLayer/RoomEditor/OptionButton.get_item_text($CanvasLayer/RoomEditor/OptionButton.selected)]["type"] == "tile" and (MouseArea.area in $CanvasLayer/RoomEditor/Area2D.get_overlapping_areas())
	if Undermaker.Project.has("projectName"):
		$CanvasLayer/Label.text = Undermaker.Project["projectName"]
	if $CanvasLayer/RoomEditor.visible:
		var vel = Vector2(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_up","ui_down"))*10
		$Camera2D.position += vel
		var zoom = Input.get_axis("zoomout","zoomin")*-0.02
		$Camera2D.zoom += Vector2(zoom,zoom)
		if zoom != 0.0 or vel != Vector2.ZERO:
			$FakeTile.visible = false
	else:
		$Camera2D.position = Vector2(160,120)
		$Camera2D.zoom = Vector2(1,1)

func _on_save_settings_pressed():
	#$Settings/LineEdit.text = Undermaker.Project["projectName"]
	#$Settings/LineEdit2.text = Undermaker.Project["gameName"]
	Undermaker.Project["projectName"] = $Settings/LineEdit.text
	Undermaker.Project["gameName"] = $Settings/LineEdit2.text
	Undermaker.Project["desc"] = $Settings/LineEdit3.text
	print(Undermaker.Path+"project.json")
	print(Undermaker.createJsonFromDictionary("project.json",Undermaker.Project))

func _on_character_pressed():
	print("character")
	$CanvasLayer/Place.text = "Character Creator"
	$Settings.visible = false
	$CanvasLayer/RoomEditor.visible = false
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
