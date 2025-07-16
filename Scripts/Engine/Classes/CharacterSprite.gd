class_name CharacterSprite
extends Resource

@export var WalkDown : Array[Texture2D]
@export var WalkLeft : Array[Texture2D]
@export var WalkRight : Array[Texture2D]
@export var WalkUp : Array[Texture2D]
@export var IdleDown : Texture2D
@export var IdleLeft : Texture2D
@export var IdleRight : Texture2D
@export var IdleUp : Texture2D

static func fromJson(path : String) -> CharacterSprite:
	print(Undermaker.Path+"Data/characters/"+path)
	var json = Undermaker.loadJsonAsDictionary("Data/characters/"+path)
	print(json)
	var sprite = CharacterSprite.new()
	if json.has("walk_down"):
		for i in json["walk_down"]:
			sprite.WalkDown.append(Loader.load_file("Sprites/Character/"+i+".png"))
	if json.has("walk_left"):
		for i in json["walk_left"]:
			sprite.WalkLeft.append(Loader.load_file("Sprites/Character/"+i+".png"))
	if json.has("walk_right"):
		for i in json["walk_right"]:
			sprite.WalkRight.append(Loader.load_file("Sprites/Character/"+i+".png"))
	if json.has("walk_up"):
		for i in json["walk_up"]:
			sprite.WalkUp.append(Loader.load_file("Sprites/Character/"+i+".png"))
	
	if json.has("idle_down"):
		sprite.IdleDown = Loader.load_file("Sprites/Character/"+json["idle_down"]+".png")
	if json.has("idle_left"):
		sprite.IdleLeft = Loader.load_file("Sprites/Character/"+json["idle_left"]+".png")
	if json.has("idle_right"):
		sprite.IdleRight = Loader.load_file("Sprites/Character/"+json["idle_right"]+".png")
	if json.has("idle_up"):
		sprite.IdleUp = Loader.load_file("Sprites/Character/"+json["idle_up"]+".png")
	
	return sprite
