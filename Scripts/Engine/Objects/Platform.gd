@tool
extends StaticBody2D

@export var width : int = 60
var velocity : Vector2 = Vector2.ZERO

func _draw():
	draw_texture_rect(preload("res://Sprites/Battle/Attacks/spr_platform_side.png"),Rect2(Vector2(-width/2,0),Vector2(1,11)),false)
	draw_texture_rect(preload("res://Sprites/Battle/Attacks/spr_platform_side.png"),Rect2(Vector2((width/2),0),Vector2(1,11)),false)
	draw_texture_rect(preload("res://Sprites/Battle/Attacks/spr_platform_mid.png"),Rect2(Vector2(-width/2,0),Vector2(width,11)),false)

func _process(_delta):
	$CollisionShape2D.shape.size.x = width
	$Area2D/CollisionShape2D.shape.size.x = width
	position += velocity
	
	for i in $Area2D.get_overlapping_bodies():
		if i.name == "BattleHeart":
			var soul = i
			if soul.is_on_floor_only():
				soul.position += velocity
	
	queue_redraw()
