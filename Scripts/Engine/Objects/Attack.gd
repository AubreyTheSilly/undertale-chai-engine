extends Sprite2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export var hitbox_override_enabled := false
@export var hitbox_override := Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO
var rotation_velocity : float = 0

func _process(_delta):
	if texture:
		$attack/CollisionShape2D.shape.size = texture.get_size()
	
	position += velocity
	rotation_degrees += rotation_velocity
	
	match attack_type.to_lower():
		"blue":
			modulate = Color(0.251,1,1)
		"orange":
			modulate = Color(1,0.65,0)
		"green":
			modulate = Color(0,1,0)
		_:
			modulate = Color(1,1,1)
