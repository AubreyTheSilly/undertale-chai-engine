extends Node2D

var mode = 0
var editormode = 0

var prevtilemap : String

var newlayer = false

var objdata : Array[Array] = [["",""]]
var curobjdata : int = 0

func redraw_room(_text : String = "") -> void:
	await $"/root/editor/RoomDisplay".updateObjectTextures()
	$"/root/editor/RoomDisplay".queue_redraw()

func checkfortile(tilelist : Array, tilepos : Vector2) -> int:
	var index = -1
	for i in tilelist:
		index += 1
		if i["position"] == [tilepos.x,tilepos.y]:
			return index
	return -1

func checkforobj(tilelist : Dictionary, tilepos : Vector2) -> String:
	for i in tilelist:
		if tilelist[i]["position"] == [tilepos.x,tilepos.y]:
			return i
	return ""

func makeObj():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = (($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(10,10))/10.0)-($"/root/editor/RoomDisplay".position/10.0)
	
	var obj = {}
	obj["position"] = [objpos.x,objpos.y]
	obj["data"] = {}
	for i in objdata:
		if i[0] != "":
			obj["data"][i[0]] = i[1]
	obj["name"] = $PanelContainer/ObjMode/ObjName.text
	var naming = 0
	if $"/root/editor/RoomDisplay".room[targetlayer]["obj"].has(obj["name"]):
		naming = 1
	if naming == 1:
		while $"/root/editor/RoomDisplay".room[targetlayer]["obj"].has(obj["name"]+str(naming)):
			naming += 1
		obj["name"] = $PanelContainer/ObjMode/ObjName.text+str(naming)
	obj["type"] = $PanelContainer/ObjMode/Filename.text
	
	if obj["name"] == "" or obj["type"] == "":
		return
	
	if checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos) != "":
		print("theres an object there already")
	else:
		$"/root/editor/RoomDisplay".room[targetlayer]["obj"][obj["name"]] = obj
	
	# i don't think clearing the properties is neccessary but one of my testers basically begged me to.......
	# UPDATE: this has been moved to the clearObjectProperties function and now happens when you press the delete key.
	#$PanelContainer/ObjMode/ObjName.text = ""
	#$PanelContainer/ObjMode/Filename.text = ""
	#objdata = [["",""]]
	#curobjdata = 0
	#
	#$PanelContainer/ObjMode/Property.text = ""
	#$PanelContainer/ObjMode/PropertyValue.text = ""
	
	redraw_room()

func clearObjectProperties() -> void:
	$PanelContainer/ObjMode/ObjName.text = ""
	$PanelContainer/ObjMode/Filename.text = ""
	objdata = [["",""]]
	curobjdata = 0
	
	$PanelContainer/ObjMode/Property.text = ""
	$PanelContainer/ObjMode/PropertyValue.text = ""

func _fix_layers():
	print("Layers changed")

func loadObjectIntoObjectEditor(obj : Dictionary) -> void:
	$PanelContainer/ObjMode/ObjName.text = obj["name"]
	$PanelContainer/ObjMode/Filename.text = obj["type"]
	objdata = []
	curobjdata = 0
	
	for i in obj["data"]:
		objdata.append([i,obj["data"][i]])
	
	if objdata == []:
		objdata = [["",""]]
	
	$PanelContainer/ObjMode/Property.text = objdata[curobjdata][0]
	$PanelContainer/ObjMode/PropertyValue.text = objdata[curobjdata][1]

func getObjAtCursor() -> Dictionary:
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = (($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(10,10))/10.0)-($"/root/editor/RoomDisplay".position/10.0)
	
	if checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos) != "":
		return $"/root/editor/RoomDisplay".room[targetlayer]["obj"][checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos)]
	
	return {}

func removeObj():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var objpos = (($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(10,10))/10.0)-($"/root/editor/RoomDisplay".position/10.0)
	print(checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos))
	
	if checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos) != "":
		print("Removing object")
		$"/root/editor/RoomDisplay".room[targetlayer]["obj"].erase(checkforobj($"/root/editor/RoomDisplay".room[targetlayer]["obj"],objpos))
	
	redraw_room()

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
	redraw_room()

func removeTile():
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	var tilepos = (($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)
	if checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos) != -1:
		$"/root/editor/RoomDisplay".room[targetlayer]["tiles"].remove_at(checkfortile($"/root/editor/RoomDisplay".room[targetlayer]["tiles"],tilepos))
	redraw_room()

func get_optionbutton_items(optionbutton : OptionButton) -> Array[String]:
	var output : Array[String]
	for i in range(optionbutton.item_count):
		output.append(optionbutton.get_item_text(i))
	return output

func _process(_delta):
	$"/root/editor/RoomDisplay".room["bgm"] = $PanelContainer/Settings/BGM.text
	$PanelContainer/ObjMode/Label5.text = str(curobjdata+1)+"/"+str(objdata.size())
	objdata[curobjdata][0] = $PanelContainer/ObjMode/Property.text
	objdata[curobjdata][1] = $PanelContainer/ObjMode/PropertyValue.text
	if !visible:
		return
	var room_bg = Loader.load_file("Sprites/Backgrounds/"+$LineEdit.text+".png")
	if room_bg:
		$"/root/editor/RoomDisplay/Sprite2D2".visible = true
		$"/root/editor/RoomDisplay/Sprite2D2".texture = room_bg
	else:
		$"/root/editor/RoomDisplay/Sprite2D2".visible = false
	var roomitems = []
	for i in $"/root/editor/RoomDisplay".room:
		if i != "bounds" and i != "bgm":
			roomitems.append(i)
	if get_optionbutton_items($OptionButton) != roomitems:
		print(get_optionbutton_items($OptionButton))
		print(roomitems)
		var j = get_optionbutton_items($OptionButton).size()
		for i in get_optionbutton_items($OptionButton):
			j -= 1
			$OptionButton.remove_item(j)
		for i in $"/root/editor/RoomDisplay".room:
			if i != "bounds" and i != "bgm":
				$OptionButton.add_item(i)
		if newlayer:
			$OptionButton.selected = get_optionbutton_items($OptionButton).size()-1
			newlayer = false
		else:
			$OptionButton.selected = 0
	# $CursorPos.text = "X: "+str((($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0).x)+" Y: "+str((($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0).y)
	var targetlayer = $OptionButton.get_item_text($OptionButton.selected)
	if $"/root/editor/RoomDisplay".room.has(targetlayer):
		if $PanelContainer/TileMode.visible and ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "instance"):
			$PanelContainer/TileMode.visible = false
		if $PanelContainer/ObjMode.visible and ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "tile"):
			$PanelContainer/ObjMode.visible = false
		
		if ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "tile"):
			$CursorPos.text = "X: "+str(int(((($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)).x))+" Y: "+str(int(((($"/root/editor/FakeTile".position-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($"/root/editor/RoomDisplay".position/20.0)).x))
		elif ($"/root/editor/RoomDisplay".room[targetlayer]["type"] == "instance"):
			$CursorPos.text = "X: "+str(int(((($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(10,10))/10.0)-($"/root/editor/RoomDisplay".position/10.0)).x)+1)+" Y: "+str(int(((($"/root/editor/ObjectDisplay".position-Vector2(10,10)).snapped(Vector2(10,10))/10.0)-($"/root/editor/RoomDisplay".position/10.0)).y)+1)
	if $PanelContainer/Settings.visible and editormode == 0:
		$PanelContainer/Settings.visible = false
	if !$PanelContainer/Settings.visible and editormode == 1:
		$PanelContainer/TileMode.visible = false
		$PanelContainer/ObjMode.visible = false
		$PanelContainer/Settings.visible = true
		$"/root/editor/FakeTile".visible = false
	
	if $"/root/editor/RoomDisplay".room.has(targetlayer) and editormode == 0:
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
				redraw_room()
		else:
			if $PanelContainer/TileMode.visible:
				$PanelContainer/TileMode.visible = false
			if !$PanelContainer/ObjMode.visible:
				$PanelContainer/ObjMode.visible = true
			$"/root/editor/ObjectDisplay".visible = true
			$"/root/editor/FakeTile".visible = false
			
			$"/root/editor/ObjectDisplay/Label2".text = ""
			var obj_at_cursor = getObjAtCursor()
			if obj_at_cursor != {}:
				$"/root/editor/ObjectDisplay/Label2".text = obj_at_cursor["name"]+"\nType: "+obj_at_cursor["type"]
				for i in obj_at_cursor["data"]:
					$"/root/editor/ObjectDisplay/Label2".text += "\n"+i+": "+obj_at_cursor["data"][i]
				if Input.is_action_just_pressed("MiddleClick"):
					loadObjectIntoObjectEditor(obj_at_cursor)
			if Input.is_action_just_pressed("delete"):
				clearObjectProperties()
			
			var Scale = Vector2(1,1)
			var rot = 0
			
			for i in objdata:
				if i[0] == "scale" and str_to_var(i[1]) is Vector2:
					Scale = str_to_var(i[1])
				elif i[0] == "scale:x" and (str_to_var(i[1]) is float or str_to_var(i[1]) is int):
					Scale.x = str_to_var(i[1])
				elif i[0] == "scale:y" and (str_to_var(i[1]) is float or str_to_var(i[1]) is int):
					Scale.y = str_to_var(i[1])
				elif i[0] == "rotation_degrees" and (str_to_var(i[1]) is float or str_to_var(i[1]) is int):
					rot = str_to_var(i[1])
			
			$"/root/editor/ObjectDisplay/Sprite2D".scale = Scale
			$"/root/editor/ObjectDisplay/Sprite2D".rotation_degrees = rot
		
			$"/root/editor/ObjectDisplay".position = (get_tree().current_scene.get_global_mouse_position()).snapped(Vector2(10,10))
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
		# $"/root/editor/RoomDisplay".room["bounds"]
		if $"/root/editor/RoomDisplay".room.has("bounds"):
			$PanelContainer/Settings/SizeX.text = str(int($"/root/editor/RoomDisplay".room["bounds"][0]))
			$PanelContainer/Settings/SizeY.text = str(int($"/root/editor/RoomDisplay".room["bounds"][1]))
		else:
			$PanelContainer/Settings/SizeX.text = "16"
			$PanelContainer/Settings/SizeY.text = "12"
		if $"/root/editor/RoomDisplay".room.has("bgm"):
			$PanelContainer/Settings/BGM.text = $"/root/editor/RoomDisplay".room["bgm"]
		else:
			$PanelContainer/Settings/BGM.text = ""
		print("loaded room "+$LineEdit.text)
		redraw_room()
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
		if $"/root/editor/RoomDisplay".room[i] is Dictionary:
			if ($"/root/editor/RoomDisplay".room[i]).has("type"):
				roomitems.append(i)
	if roomitems.size() != 1:
		print("removed "+roomitems[$OptionButton.selected])
		$"/root/editor/RoomDisplay".room.erase(roomitems[$OptionButton.selected])
		redraw_room()
	else:
		print("you idiot there's only one layer")

func _on_size_y_text_submitted(_new_text):
	$"/root/editor/RoomDisplay".room["bounds"] = [float($PanelContainer/Settings/SizeX.text),float($PanelContainer/Settings/SizeY.text)]
	redraw_room()

func _on_size_x_text_submitted(_new_text):
	$"/root/editor/RoomDisplay".room["bounds"] = [float($PanelContainer/Settings/SizeX.text),float($PanelContainer/Settings/SizeY.text)]
	redraw_room()

func _on_prev_objdata_pressed():
	if curobjdata == 0:
		curobjdata = objdata.size()-1
	else:
		curobjdata -= 1
	$PanelContainer/ObjMode/Property.text = objdata[curobjdata][0]
	$PanelContainer/ObjMode/PropertyValue.text = objdata[curobjdata][1]

func _on_next_objdata_pressed():
	if curobjdata == objdata.size()-1:
		curobjdata = 0
	else:
		curobjdata += 1
	$PanelContainer/ObjMode/Property.text = objdata[curobjdata][0]
	$PanelContainer/ObjMode/PropertyValue.text = objdata[curobjdata][1]

func _on_add_objdata_pressed():
	objdata.append(["",""])
	curobjdata = objdata.size()-1
	$PanelContainer/ObjMode/Property.text = objdata[curobjdata][0]
	$PanelContainer/ObjMode/PropertyValue.text = objdata[curobjdata][1]

func _on_remove_objdata_pressed():
	if objdata.size() == 1:
		return
	var oldobjdata = curobjdata
	curobjdata -= 1
	objdata.remove_at(oldobjdata)
	$PanelContainer/ObjMode/Property.text = objdata[curobjdata][0]
	$PanelContainer/ObjMode/PropertyValue.text = objdata[curobjdata][1]
