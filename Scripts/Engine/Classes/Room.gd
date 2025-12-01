class_name Room
extends Resource

@export var Layers : Array[RoomLayer] = []
@export var CameraBounds : Rect2

static func loadRoomFromDictionary(dict : Dictionary) -> Room:
	var room = Room.new()
	var json = dict
	
	for i in json:
		if i == "bounds":
			room.CameraBounds = Rect2(0,0,json["bounds"][0]*20,json["bounds"][1]*20)
			continue
		var layerjson : Dictionary = json[i]
		var layer : RoomLayer
		if layerjson["type"] == "tile":
			layer = RoomTileLayer.new()
			layer.tilemap = Loader.load_file("Sprites/Tilemaps/"+layerjson["tilemap"]+".png")
			for j in layerjson["tiles"]:
				var tilejson = j
				var tile : Tile = Tile.new()
				tile.tileindex = Vector2(tilejson["tileindex"][0],tilejson["tileindex"][1])
				tile.position = Vector2(tilejson["position"][0],tilejson["position"][1])
				layer.Tiles.append(tile)
		elif layerjson["type"] == "instance":
			layer = RoomInstanceLayer.new()
			for j in layerjson["obj"]:
				var objarray = layerjson["obj"][j]
				var obj := RoomInstance.new()
				obj.name = objarray["name"]
				obj.type = objarray["type"]
				obj.position = Vector2(objarray["position"][0],objarray["position"][1])
				for k in objarray["data"]:
					var data = objarray["data"][k]
					obj.data[data[0]] = data[1]
				layer.Objects.append(obj)
		room.Layers.append(layer)
	
	return room
