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
				draw_set_transform(Vector2.ZERO)
				draw_texture_rect_region(tilemaps["Layer"+str(index)],Rect2((tile.position*20),Vector2(20,20)),Rect2(tile.tileindex*20,Vector2(20,20)))
		if i is RoomInstanceLayer:
			for j in i.Objects:
				var obj : RoomInstance = j
				
				var Offset := Vector2.ZERO
				var Scale := Vector2(1.0,1.0)
				var rotatio := 0.0
				
				var image = object_textures[obj.name]
				
				for k in obj.data:
					var data = [k,obj.data[k]]
					if data[0] == "scale" and str_to_var(data[1]) is Vector2:
						Scale = str_to_var(data[1])
					elif data[0] == "scale:x" and (str_to_var(data[1]) is float or str_to_var(data[1]) is int):
						Scale.x = str_to_var(data[1])
					elif data[0] == "scale:y" and (str_to_var(data[1]) is float or str_to_var(data[1]) is int):
						Scale.y = str_to_var(data[1])
					elif data[0] == "rotation_degrees" and (str_to_var(data[1]) is float or str_to_var(data[1]) is int):
						rotatio = str_to_var(data[1])
					if obj.type == "RoomSprite":
						if data[0] == "horizontal_alignment":
							Offset.x = RoomSprite.getOffset(image,data[1]).x
						elif data[0] == "vertical_alignment":
							Offset.y = RoomSprite.getOffset(image,"center",data[1]).y
				# OLD and FUCKING STUPID CODE ITS 2 AM AND I WANNA DIE
				#draw_rect(Rect2((obj.position*10),Vector2(20,20)),Color.BLACK,false,1.0)
				#if image:
					#draw_texture(image,((obj.position*10)+Vector2(10,10))-(image.get_size()/2))
				# NEW and STILL PROBABLY BAD CODE THAT MAKES ME WANT TO HANG MYSELF
				draw_set_transform(Vector2.ZERO)
				draw_rect(Rect2((obj.position*10),Vector2(20,20)),Color.BLACK,false,1.0)
				draw_set_transform(Vector2.ZERO.rotated(rotatio)+Vector2(10,10)+(obj.position*10)+Offset,deg_to_rad(rotatio),Scale)
				if image:
					draw_texture(image,(Vector2.ZERO)-(image.get_size()/2))
		index += 1

func updateObjectTextures() -> void:
	for i in Room.loadRoomFromDictionary(room).Layers:
		if i is RoomInstanceLayer:
			for j in i.Objects:
				var obj : RoomInstance = j
				var image = Undermaker.get_object_image(obj.type,obj)
				object_textures[obj.name] = image
