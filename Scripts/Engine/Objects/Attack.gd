extends Sprite2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage = 1
var velocity : Vector2 = Vector2.ZERO

func _process(_delta):
	if texture:
		$attack/CollisionShape2D.shape.size = texture.get_size()
	
	position += velocity.normalized()
	
	match attack_type.to_lower():
		"blue":
			modulate = Color(0.251,1,1)
		"orange":
			modulate = Color(1,0.65,0)
		"green":
			modulate = Color(0,1,0)
		_:
			modulate = Color(1,1,1)
