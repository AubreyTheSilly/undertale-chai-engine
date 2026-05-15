class_name RoomLoader
extends Node2D

@export var roomName : String = "room_start"

@onready var camera = $Camera2D
@onready var room : Room

var room_valid = false

func _ready() -> void:
	if PlayerData.room:
		roomName = PlayerData.room
	LoadRoom()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("backslash") and !Engine.is_editor_hint():
		get_tree().reload_current_scene()
	for i in get_children():
		for j in i.get_children():
			if j is Player:
				camera.position = j.position-Vector2(160,120)
	if room:
		camera.position.x = clamp(camera.position.x,room.CameraBounds.position.x,room.CameraBounds.position.x+(room.CameraBounds.size.x-320))
		camera.position.y = clamp(camera.position.y,room.CameraBounds.position.y,room.CameraBounds.position.y+(room.CameraBounds.size.y-240))
	else:
		camera.position = Vector2.ZERO

func clear_room() -> void:
	for i in get_children():
		if i.name != "Camera2D" and i.name != "DoesntExist" and i.name != "BG" and i.name != "ScriptRunner":
			i.queue_free()

func LoadRoom() -> void:
	visible = false
	room_valid = false
	$BG.texture = null
	$DoesntExist.visible = false
	clear_room()
	if Undermaker.loadJsonAsDictionary("Data/rooms/"+roomName+".json") == {}:
		print("room load failed")
		$DoesntExist/Label.text = "Error!\nRoom \""+roomName+"\" does not exist.\nPlease enter a room to load instead."
		$DoesntExist.visible = true
		return
	if Loader.load_file("Sprites/Backgrounds/"+roomName+".png"):
		$BG.texture = Loader.load_file("Sprites/Backgrounds/"+roomName+".png")
	room = Room.loadRoomFromDictionary(Undermaker.loadJsonAsDictionary("Data/rooms/"+roomName+".json"))
	room_valid = true
	BGM.playBGM(room.Music)
	if BGM.stream_paused:
		print("fade in")
		BGM.fadeIn()
	else:
		BGM.fadeval = 0
		BGM.targetfade = 0
	var layernum = 1
	for layer in room.Layers:
		var layerobj = Node2D.new()
		layerobj.y_sort_enabled = true
		add_child(layerobj)
		
		layerobj.name = "Layer"+str(layernum)
		layerobj.z_index = layer.depth
		
		if layer is RoomTileLayer:
			var tex = layer.tilemap
			for j in layer.Tiles:
				var tile = preload("res://Scenes/Objects/tile.tscn").instantiate()
				tile.texture = tex
				tile.region_rect.size = Vector2(20,20)
				tile.region_rect.position = j.tileindex*20
				tile.position = j.position*20
				layerobj.add_child(tile)
		elif layer is RoomInstanceLayer:
			for i in layer.Objects:
				# OLD and BAD object code
				#var object = load("res://Scenes/Objects/"+i.type+".tscn").instantiate()
				#for j in i.data:
					#object.set(j,i.data[j])
				#object.position = i.position*20
				if FileAccess.file_exists(Undermaker.Path+"Data/Objects/"+i.type+".txt"):
					var objectdata = Undermaker.loadTextAsObjectData(i.type)
					if objectdata != {}:
						var object = Undermaker.loadCustomObject(i.type)
						if !object:
							continue
						for j in i.data:
							if j in object:
								if str_to_var(i.data[j]):
									object.set_indexed(j,i.str_to_var(i.data[j]))
								else:
									object.set_indexed(j,i.data[j])
								print(i.type+"'s property "+j+" has been set to "+i.data[j])
							else:
								push_warning(i.type+" does not have property "+j)
						object.name = i.name
						object.position = (i.position+Vector2(1,1))*10
						layerobj.add_child(object)
					else:
						push_error("Tried to load an invalid object in "+roomName)
				else:
					var object = Undermaker.getObjectByClassName(i.type)
					if object:
						object.name = i.name
						for j in i.data:
							if j in object:
								if str_to_var(i.data[j]) != null:
									object.set_indexed(j,i.str_to_var(i.data[j]))
									print(object.name+"'s property "+j+" has been set to "+i.data[j])
								elif object.get(j) is String:
									object.set_indexed(j,i.data[j])
									print(object.name+"'s property "+j+" has been set to "+i.data[j])
								else:
									push_warning(object.name+"'s property "+j+" is not a string")
							else:
								print(object.name+" does not have property "+j)
						object.position = (i.position+Vector2(1,1))*10
						layerobj.add_child(object)
		
		layernum += 1
	if FileAccess.file_exists(Undermaker.Path+"Scripts/Rooms/"+roomName+".utscript"):
		$ScriptRunner.run_script("Rooms/"+roomName+".utscript")
	visible = true

func _on_line_edit_text_submitted(new_text):
	roomName = new_text
	$DoesntExist/LineEdit.text = ""
	LoadRoom()
