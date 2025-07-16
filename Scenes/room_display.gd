class_name RoomDisplay
extends Node2D

@export var room : Dictionary = {
	"layer1":{
		"type":"tile",
		"tilemap":"ruins",
		"tiles":[
			{
				"tileindex":[0,11],
				"position":[0,0]
			},
			{
				"tileindex":[1,11],
				"position":[1,0]
			},
			{
				"tileindex":[2,11],
				"position":[2,0]
			},
			{
				"tileindex":[0,12],
				"position":[0,1]
			},
			{
				"tileindex":[1,12],
				"position":[1,1]
			},
			{
				"tileindex":[2,12],
				"position":[2,1]
			},
			{
				"tileindex":[0,11],
				"position":[0,0]
			},
			{
				"tileindex":[1,11],
				"position":[1,0]
			},
			{
				"tileindex":[2,11],
				"position":[2,0]
			}
		]
	}
}
var offset : Vector2 = Vector2.ZERO
var tilemap : Texture2D

func _draw():
	var roomjson = Room.loadRoomFromDictionary(room)
	for i in roomjson.Layers:
		if i is RoomTileLayer:
			for j in i.Tiles:
				var tile : Tile = j
				tilemap = i.tilemap
				draw_texture_rect_region(tilemap,Rect2(tile.position*20,Vector2(20,20)),Rect2(tile.tileindex*20,Vector2(20,20)))
