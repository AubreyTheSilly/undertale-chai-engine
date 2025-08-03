extends Node2D

var mode = 0

var prevtilemap : String

func checkfortile(tilelist : Array, tilepos : Vector2) -> int:
	var index = -1
	for i in tilelist:
		index += 1
		if i["position"] == [tilepos.x,tilepos.y]:
			return index
	return -1

func makeTile():
	var tile = {}
	tile["tileindex"] = [int($PanelContainer/TileMode/TileX.text),int($PanelContainer/TileMode/TileY.text)]
	var tilepos = ((get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($RoomDisplay.position/20.0)
	tile["position"] = [tilepos.x,tilepos.y]
	if checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos) != -1:
		$RoomDisplay.room["layer1"]["tiles"][checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos)] = tile
	else:
		$RoomDisplay.room["layer1"]["tiles"].append(tile)
	$RoomDisplay.queue_redraw()
func removeTile():
	var tilepos = ((get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($RoomDisplay.position/20.0)
	if checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos) != -1:
		$RoomDisplay.room["layer1"]["tiles"].remove_at(checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos))
	$RoomDisplay.queue_redraw()

func _process(_delta):
	if mode == 0:
		$PanelContainer/TileMode.visible = true
		$PanelContainer/ObjMode.visible = false
		$ObjectDisplay.visible = false
		$FakeTile.visible = true
		
		
		$FakeTile.position = (get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))
		if prevtilemap != "Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png":
			$FakeTile.texture = Loader.load_file("Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png")
			prevtilemap = "Sprites/Tilemaps/"+$PanelContainer/TileMode/Tilemap.text+".png"
		$FakeTile.region_rect.position.x = int($PanelContainer/TileMode/TileX.text)*20
		$FakeTile.region_rect.position.y = int($PanelContainer/TileMode/TileY.text)*20
		
		if Input.is_action_pressed("Click") and MouseArea in $Area2D.get_overlapping_areas():
			makeTile()
		if Input.is_action_pressed("RightClick") and MouseArea in $Area2D.get_overlapping_areas():
			removeTile()
		
		if $FakeTile.texture and $RoomDisplay.room["layer1"]["tilemap"] != $PanelContainer/TileMode/Tilemap.text:
			$RoomDisplay.room["layer1"]["tilemap"] = $PanelContainer/TileMode/Tilemap.text
			queue_redraw()
	else:
		$PanelContainer/TileMode.visible = false
		$PanelContainer/ObjMode.visible = true
		$ObjectDisplay.visible = true
		$FakeTile.visible = false
		
		$ObjectDisplay.position = (get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))
		#$ObjectDisplay/Label.text = $PanelContainer/ObjMode/ObjName.text+"\n("+$PanelContainer/ObjMode/Filename.text+")"
		$ObjectDisplay.objname = $PanelContainer/ObjMode/ObjName.text
		$ObjectDisplay.objtype = $PanelContainer/ObjMode/Filename.text
		
		if Input.is_action_pressed("Click") and MouseArea in $Area2D.get_overlapping_areas():
			var tile = {}
			tile["tileindex"] = [int($PanelContainer/TileMode/TileX.text),int($PanelContainer/TileMode/TileY.text)]
			var tilepos = ((get_global_mouse_position()-Vector2(10,10)).snapped(Vector2(20,20))/20.0)-($RoomDisplay.position/20.0)
			tile["position"] = [tilepos.x,tilepos.y]
			if checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos) != -1:
				$RoomDisplay.room["layer1"]["tiles"][checkfortile($RoomDisplay.room["layer1"]["tiles"],tilepos)] = tile
			else:
				$RoomDisplay.room["layer1"]["tiles"].append(tile)
			$RoomDisplay.queue_redraw()

func _on_tile_mode_pressed():
	mode = 0

func _on_obj_mode_pressed():
	mode = 1
