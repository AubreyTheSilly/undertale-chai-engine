extends Node2D

var mode = 0
var editormode = 0

var prevtilemap : String

func checkfortile(tilelist : Array, tilepos : Vector2) -> int:
	var index = -1
	for i in tilelist:
		index += 1
		if i["position"] == [tilepos.x,tilepos.y]:
			return index
	return -1

func makeObj():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = (($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	
	var obj = {}
	obj["position"] = [objpos.x,objpos.y]
	
	
	$"/root/editor/RoomDisplay".queue_redraw()
	
func removeObj():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = ((get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	$"/root/editor/RoomDisplay".queue_redraw()

func makeTile():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var tile = {}
	tile["tileindex"] = [int($PanelContainer/TileMode/TileX.text),int($PanelContainer/TileMode/TileY.text)]
	var tilepos = (($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	tile["position"] = [tilepos.x,tilepos.y]
	if checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos) != -1:
		$"/root/editor/RoomDisplay".room[targetlayer]["tiles"][checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos)] = tile
	else:
		$"/root/editor/RoomDisplay".room[targetlayer]["tiles"].append(tile)
	$"/root/editor/RoomDisplay".queue_redraw()

func removeTile():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var tilepos = (($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	if checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos) != -1:
		$"/root/editor/RoomDisplay".room[targetlayer]["tiles"].remove_at(checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos))
	$"/root/editor/RoomDisplay".queue_redraw()

func _process(_delta):
	if !visible:
		return
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	if $"/root/editor/RoomDisplay".room[targetlayer]["type"] == "instance":
		$"obj properties".visible = true
		if editormode == 2:
			editormode = 0
	else:
		$"obj properties".visible = false
	if $PanelContainer/TileMode.visible and $"/root/editor/RoomDisplay".room[targetlayer]["type"] == "instance":
		$PanelContainer/TileMode.visible = false
	if $PanelContainer/ObjMode.visible and $"/root/editor/RoomDisplay".room[targetlayer]["type"] == "tile":
		print("set objmode invisible1")
		$PanelContainer/ObjMode.visible = false
	$PanelContainer/Settings.visible = false
	$PanelContainer/Properties.visible = false
	
	match editormode:
		1:
			$PanelContainer/Settings.visible = true
		2:
			$PanelContainer/Properties.visible = true
	
	if $"/root/editor/RoomDisplay".room[$OptionButton.get_item_text($OptionButton.selected)]["type"] == "tile":
		if !$PanelContainer/TileMode.visible:
			$PanelContainer/TileMode.visible = true
		if $PanelContainer/ObjMode.visible:
			print("set objmode invisible")
			$PanelContainer/ObjMode.visible = false
		$ObjectDisplay.visible = false
		$"/root/editor/FakeTile".visible = true
		
		$"/root/editor/FakeTile".position = (get_tree().current_scene.get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))
		if prevtilemap != "Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png":
			$"/root/editor/FakeTile".texture = Loader.load_file("Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png")
			prevtilemap = "Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png"
		$"/root/editor/FakeTile".region_rect.position.x = int($PanelContainer/TileMode/TileX.text)*20
		$"/root/editor/FakeTile".region_rect.position.y = int($PanelContainer/TileMode/TileY.text)*20
		
		if Input.is_action_pressed("Click") and MouseArea.area in $Area2D.get_overlapping_areas():
			makeTile()
		if Input.is_action_pressed("RightClick") and MouseArea.area in $Area2D.get_overlapping_areas():
			removeTile()
		
		if $"/root/editor/FakeTile".texture and $"/root/editor/RoomDisplay".room[targetlayer]["tilemap"] != $PanelContainer/TileMode/Tilemap.text:
			$"/root/editor/RoomDisplay".room[targetlayer]["tilemap"] = $PanelContainer/TileMode/Tilemap.text
			$"/root/editor/RoomDisplay".queue_redraw()
	else:
		if $PanelContainer/TileMode.visible:
			$PanelContainer/TileMode.visible = false
		if !$PanelContainer/ObjMode.visible:
			$PanelContainer/ObjMode.visible = true
		$ObjectDisplay.visible = true
		$"/root/editor/FakeTile".visible = false
		
		$ObjectDisplay.position = (get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))
		#$ObjectDisplay/Label.text = $PanelContainer/ObjMode/ObjName.text+"\n("+$PanelContainer/ObjMode/Filename.text+")"
		$ObjectDisplay.objname = $PanelContainer/ObjMode/ObjName.text
		$ObjectDisplay.objtype = $PanelContainer/ObjMode/Filename.text
		
		if Input.is_action_pressed("Click") and MouseArea.area in $Area2D.get_overlapping_areas():
			makeObj()
		if Input.is_action_pressed("Click") and MouseArea.area in $Area2D.get_overlapping_areas():
			removeObj()
		
	if not (MouseArea.area in $Area2D.get_overlapping_areas()):
		$"/root/editor/FakeTile".visible = false
		$ObjectDisplay.visible = false

func _on_tile_mode_pressed():
	mode = 0

func _on_obj_mode_pressed():
	mode = 1

func _on_save_pressed():
	print("saved room "+$LineEdit.text)
	Undermaker.createJsonFromDictionary("Data/rooms/"+$LineEdit.text+".json",$"/root/editor/RoomDisplay".room)

func _on_load_pressed():
	if Undermaker.loadJsonAsDictionary("Data/rooms/"+$LineEdit.text+".json"):
		$"/root/editor/RoomDisplay".room = Undermaker.loadJsonAsDictionary("Data/rooms/"+$LineEdit.text+".json")
		print("loaded room "+$LineEdit.text)
		$"/root/editor/RoomDisplay".queue_redraw()
	else:
		print("That room doesn't exist, dumbass ("+"Data/rooms/"+$LineEdit.text+".json"+")")

func _on_draw_pressed():
	editormode = 0

func _on_settings_pressed():
	editormode = 1

func _on_obj_properties_pressed():
	editormode = 2
