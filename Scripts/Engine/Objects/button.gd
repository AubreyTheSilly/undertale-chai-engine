@tool
extends Node2D

@export var size := Vector2(40,40)
@export var text := "Button"

signal click

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$NinePatchRect.size = size
	$Area2D/CollisionShape2D.shape.size = size
	$NinePatchRect.position.x = -(size.x/2)
	$NinePatchRect.position.y = -(size.y/2)
	
	$Label.text = text
	
	if !Engine.is_editor_hint():
		var hovering = false
		for i in $Area2D.get_overlapping_areas():
			if i.name == "MouseArea":
				hovering = true
		if hovering:
			scale = lerp(scale,Vector2(1.1,1.1),0.1)
			if Input.is_action_just_pressed("Click"):
				click.emit()
		else:
			scale = lerp(scale,Vector2(1,1),0.1)
