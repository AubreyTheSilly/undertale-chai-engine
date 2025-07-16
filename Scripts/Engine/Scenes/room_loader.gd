class_name RoomLoader
extends Node2D

@export var room : Room

@onready var camera = $Camera2D

func _ready() -> void:
	LoadRoom()

func LoadRoom() -> void:
	for i in get_children():
		if i.name != "Camera2D":
			i.queue_free()
	var layernum = 0
	for layer in room.Layers:
		var layerobj = Node2D.new()
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
				var object = load("res://Scenes/Objects/"+i.type+".tscn").instantiate()
				for j in i.data:
					object.set(j,i.data[j])
				object.position = i.position*20
				
				layerobj.add_child(object)
		
		layernum += 1

func _physics_process(_delta) -> void:
	for i in get_children():
		for j in i.get_children():
			if j.name == "Player":
				camera.position = j.position-Vector2(160,120)
	camera.position.x = clamp(camera.position.x,room.CameraBounds.position.x,room.CameraBounds.position.x+room.CameraBounds.size.x)
	camera.position.y = clamp(camera.position.y,room.CameraBounds.position.y,room.CameraBounds.position.y+room.CameraBounds.size.y)
