class_name RoomDisplay
extends Node2D

@export var room : Dictionary = {
	"Layer 1":{
		"type":"tile",
		"tilemap":"ruins",
		"tiles":[]
	},
	"Layer 2":{
		"type":"tile",
		"tilemap":"ruins",
		"tiles":[]
	}
}

var tilemaps : Dictionary[String,Texture]

func _draw():
	var index = 0
	var roomjson = Room.loadRoomFromDictionary(room)
	for i in roomjson.Layers:
		if i is RoomTileLayer:
			tilemaps["Layer"+str(index)] = i.tilemap
			for j in i.Tiles:
				var tile : Tile = j
				draw_texture_rect_region(tilemaps["Layer"+str(index)],Rect2((tile.position*20),Vector2(20,20)),Rect2(tile.tileindex*20,Vector2(20,20)))
		if i is RoomInstanceLayer:
			for j in i.Objects:
				var obj : RoomInstance = j
				if obj.type == "Character" or obj.type == "NPC":
					draw_texture(Loader.load_file("Sprites/npc1.png"),obj.position*20)
				if obj.type == "Player":
					draw_texture(Loader.load_file("Sprites/player.png"),obj.position*20)
		index += 1
