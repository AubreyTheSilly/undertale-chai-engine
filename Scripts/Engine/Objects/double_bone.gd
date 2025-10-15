@tool
extends Node2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export_range(0,100,1,"or_greater") var height : float = 0
var velocity : Vector2 = Vector2.ZERO
var rotation_velocity : float = 0

func _draw():
	draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone.png"),Rect2(Vector2(-2.5,-5-height),Vector2(6.5,5)),false)
	draw_rect(Rect2(Vector2(-1.25,-height),Vector2(4,height)),Color.WHITE)
	draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone.png"),Rect2(Vector2(-2.5,height),Vector2(6.5,-5)),false)
	draw_rect(Rect2(Vector2(-1.25,0),Vector2(4,height)),Color.WHITE)

func _process(_delta):
	queue_redraw()
	
	$attack/CollisionShape2D.shape.size.y = (5+height)*2
	$attack/CollisionShape2D.position.y = 0
	
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
