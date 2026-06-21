@tool
class_name RoomSprite
extends Sprite2D

## Path to the sprite. Acts as 'Sprites/[path].png'.
@export var path := ""
@export_enum("center","left","right") var horizontal_alignment : String = "center"
@export_enum("center","top","bottom") var vertical_alignment : String = "center"

static func getOffset(sprite:Texture2D,horiz:String="center",vert:String="center"):
	var Offset := Vector2.ZERO
	match horiz.to_lower():
		"center":
			Offset.x = 0
		"right":
			Offset.x = -float(sprite.get_width())/2
		"left":
			Offset.x = float(sprite.get_width())/2
	match vert.to_lower():
		"center":
			Offset.y = 0
		"top":
			Offset.y = float(sprite.get_height())/2
		"bottom":
			Offset.y = -float(sprite.get_height())/2
	
	return Offset

func _process(_delta) -> void:
	var sprite : Texture2D
	if Engine.is_editor_hint() and FileAccess.file_exists('res://Sprites/'+path+'.png'):
		sprite = load('res://Sprites/'+path+'.png')
	elif !Engine.is_editor_hint():
		sprite = Loader.load_file('Sprites/'+path+'.png')
	if sprite:
		texture = sprite
	else:
		texture = null
	
	offset = getOffset(sprite,horizontal_alignment,vertical_alignment)
