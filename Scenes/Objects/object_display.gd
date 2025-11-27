@tool
extends Node2D

@export var objname := ""
@export var objtype := ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = objname+"\n("+objtype+")"
	if objtype == "Character":
		$Sprite2D.texture = preload("res://Sprites/npc1.png")
	elif objtype == "Player":
		$Sprite2D.texture = preload("res://Sprites/player.png")
	else:
		$Sprite2D.texture = null
