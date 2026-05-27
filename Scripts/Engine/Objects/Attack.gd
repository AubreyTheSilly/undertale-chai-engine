class_name Attack
extends Sprite2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export var kr_damage := 1
@export var hitbox_override_enabled := false
@export var hitbox_override := Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO
var rotation_velocity : float = 0

@onready var last_texture : Texture2D

func _process(_delta):
	if texture and texture != last_texture:
		$attack.position = Vector2(-(texture.get_width()/2.0),-(texture.get_height()/2.0))
		for i in $attack.get_children():
			i.queue_free()
		var img : Image = texture.get_image()
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(img)
		
		var image_rect = Rect2(Vector2(0,0),bitmap.get_size())
		var polygons = bitmap.opaque_to_polygons(image_rect,0.0001)
		
		for polygon in polygons:
			var collider = CollisionPolygon2D.new()
			collider.polygon = polygon
			$attack.add_child(collider)
		last_texture = texture
	
	position += velocity
	rotation_degrees += rotation_velocity
	
	if !Engine.is_editor_hint():
		match attack_type.to_lower():
			"blue":
				modulate = Undermaker.accents["blueattack"]
			"orange":
				modulate = Undermaker.accents["orangeattack"]
			"green":
				modulate = Undermaker.accents["greenattack"]
			_:
				modulate = Undermaker.accents["primary"]
