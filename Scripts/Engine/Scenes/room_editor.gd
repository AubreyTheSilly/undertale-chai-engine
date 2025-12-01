extends Node2D

var mode = 0
var editormode = 0

var prevtilemap : String

var newlayer = false

func checkfortile(tilelist : Array, tilepos : Vector2) -> int:
	var index = -1
	for i in tilelist:
		index += 1
		if i["position"] == [tilepos.x,tilepos.y]:
			return index
	return -1

func checkforobj(tilelist : Dictionary, tilepos : Vector2) -> int:
	var index = -1
	for i in tilelist:
		index += 1
		if tilelist[i]["position"] == [tilepos.x,tilepos.y]:
			return index
	return -1

func makeObj():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = (($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	
	var obj = {}
	obj["position"] = [objpos.x,objpos.y]
	obj["data"] = {}
	obj["name"] = $PanelContainer/ObjMode/ObjName.text
	obj["type"] = $PanelContainer/ObjMode/Filename.text
	
	if obj["name"] == "" or obj["type"] == "":
		return
	
	if checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos) != -1:
		print("theres an object there already")
	else:
		$"/root/editor/RoomDisplay".room[targetlayer]["obj"][obj["name"]] = obj
	
	$"/root/editor/RoomDisplay".queue_redraw()

func _fix_layers():
	print("Layers changed")

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
	if !$"/root/editor/FakeTile".texture:
		return
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

func get_optionbutton_items(optionbutton : OptionButton) -> Array[String]:
	var output : Array[String]
	for i in range(optionbutton.item_count):
		output.append(optionbutton.get_item_text(i))
	return output

func _process(_delta):
	$"/root/editor/RoomDisplay".room["bounds"]
	
	if !visible:
		return
	var roomitems = []
	for i in $"/root/editor/RoomDisplay".room:
		roomitems.append(i)
	if get_optionbutton_items($OptionButton) != roomitems:
		print(get_optionbutton_items($OptionButton))
		print(roomitems)
		var j = get_optionbutton_items($OptionButton).size()
		for i in get_optionbutton_items($OptionButton):
			j -= 1
			$OptionButton.remove_item(j)
		for i in $"/root/editor/RoomDisplay".room:
			$OptionButton.add_item(i)
		if newlayer:
			$OptionButton.selected = get_optionbutton_items($OptionButton).size()-1
			newlayer = false
		else:
			$OptionButton.selected = 0
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	if $"/root/editor/RoomDisplay".room.has(targetlayer):
		if $PanelContainer/TileMode.visible and ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "instance"):
			$PanelContainer/TileMode.visible = false
		if $PanelContainer/ObjMode.visible and ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "tile"):
			$PanelContainer/ObjMode.visible = false
	if $PanelContainer/Settings.visible and editormode == 0:
		$PanelContainer/Settings.visible = false
	if !$PanelContainer/Settings.visible and editormode == 1:
		$PanelContainer/Settings.visible = true
	
	if $"/root/editor/RoomDisplay".room.has(targetlayer):
		if $"/root/editor/RoomDisplay".room[$OptionButton.get_item_text($OptionButton.selected)]["type"] == "tile":
			if !$PanelContainer/TileMode.visible:
				$PanelContainer/TileMode.visible = true
			if $PanelContainer/ObjMode.visible:
				print("set objmode invisible")
				$PanelContainer/ObjMode.visible = false
			$"/root/editor/ObjectDisplay".visible = false
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
			$"/root/editor/ObjectDisplay".visible = true
			$"/root/editor/FakeTile".visible = false
		
			$"/root/editor/ObjectDisplay".position = (get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))
			#$"/root/editor/ObjectDisplay"/Label.text = $PanelContainer/ObjMode/ObjName.text+"\n("+$PanelContainer/ObjMode/Filename.text+")"
			$"/root/editor/ObjectDisplay".objname = $PanelContainer/ObjMode/ObjName.text
			$"/root/editor/ObjectDisplay".objtype = $PanelContainer/ObjMode/Filename.text
			
			if Input.is_action_just_pressed("Click") and MouseArea.area in $Area2D.get_overlapping_areas():
				makeObj()
			if Input.is_action_just_pressed("RightClick") and MouseArea.area in $Area2D.get_overlapping_areas():
				removeObj()
		
	if not (MouseArea.area in $Area2D.get_overlapping_areas()):
		$"/root/editor/FakeTile".visible = false
		$"/root/editor/ObjectDisplay".visible = false

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

func _add_tile_layer():
	var roomitems = []
	for i in $"/root/editor/RoomDisplay".room:
		roomitems.append(i)
	var layernumber = 1
	while $"/root/editor/RoomDisplay".room.has("Layer "+str(layernumber)):
		layernumber += 1
	var layerdata = {
		"tilemap":"ruins",
		"tiles":[],
		"type":"tile"
	}
	$"/root/editor/RoomDisplay".room["Layer "+str(layernumber)] = layerdata
	newlayer = true

func _add_object_layer():
	var roomitems = []
	for i in $"/root/editor/RoomDisplay".room:
		roomitems.append(i)
	var layernumber = 1
	while $"/root/editor/RoomDisplay".room.has("Layer "+str(layernumber)):
		layernumber += 1
	var layerdata = {
		"obj":{},
		"type":"instance"
	}
	$"/root/editor/RoomDisplay".room["Layer "+str(layernumber)] = layerdata
	newlayer = true

func _on_remove_layer_pressed():
	var roomitems = []
	for i in $"/root/editor/RoomDisplay".room:
		roomitems.append(i)
	if roomitems.size() != 1:
		print("removed "+roomitems[$OptionButton.selected])
		$"/root/editor/RoomDisplay".room.erase(roomitems[$OptionButton.selected])
		$"/root/editor/RoomDisplay".queue_redraw()
	else:
		print("you idiot there's only one layer")
