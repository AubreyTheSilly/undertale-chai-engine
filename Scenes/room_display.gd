class_name RoomDisplay
extends Node2D

@export var room : Dictionary = {
	"Layer 1":{
		"type":"tile",
		"tilemap":"ruins",
		"tiles":[]
	},
	"bounds":[16,12]
}

var tilemaps : Dictionary[String,Texture]
var object_textures : Dictionary[String,Texture]

func _draw():
	var index = 0
	var roomjson = Room.loadRoomFromDictionary(room)
	draw_rect(roomjson.CameraBounds,Color.RED,false,1)
	for i in roomjson.Layers:
		if i is RoomTileLayer:
			tilemaps["Layer"+str(index)] = i.tilemap
			for j in i.Tiles:
				var tile : Tile = j
				draw_texture_rect_region(tilemaps["Layer"+str(index)],Rect2((tile.position*20),Vector2(20,20)),Rect2(tile.tileindex*20,Vector2(20,20)))
		if i is RoomInstanceLayer:
			for j in i.Objects:
				var obj : RoomInstance = j
				draw_rect(Rect2((obj.position*10),Vector2(20,20)),Color.BLACK,false,1.0)
				var image = object_textures[obj.name]
				draw_texture(image,((obj.position*10)+Vector2(10,10))-(image.get_size()/2))
		index += 1

func updateObjectTextures() -> void:
	for i in Room.loadRoomFromDictionary(room).Layers:
		if i is RoomInstanceLayer:
			for j in i.Objects:
				var obj : RoomInstance = j
				var image = Undermaker.get_object_image(obj.type)
				object_textures[obj.name] = image
