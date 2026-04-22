@tool
extends Node2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export_range(10,100,1,"or_greater") var height : float = 10
var velocity : Vector2 = Vector2.ZERO
var rotation_velocity : float = 0
@export var pap : bool = false

func _draw():
	var drawheight = height/2
	
	if pap:
		draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone_pap.png"),Rect2(Vector2(-3.25,-drawheight+0.5),Vector2(6.5,5)),false)
		draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone_pap.png"),Rect2(Vector2(-3.25,drawheight-5.5),Vector2(6.5,-5)),false)
		draw_rect(Rect2(Vector2(-1.25,(-height/2)+5),Vector2(2.5,height-10)),Color.WHITE)
	else:
		draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone.png"),Rect2(Vector2(-2.5,-drawheight+0.5),Vector2(5,5)),false)
		draw_texture_rect(preload("res://Sprites/Battle/Attacks/bone.png"),Rect2(Vector2(-2.5,drawheight-5.5),Vector2(5,-5)),false)
		draw_rect(Rect2(Vector2(-1.5,(-height/2)+5),Vector2(3,height-10)),Color.WHITE)

func _process(_delta):
	queue_redraw()
	
	$attack/CollisionShape2D.shape.size.x = 3-(1*int(pap))
	$attack/CollisionShape2D.shape.size.y = (height)
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
