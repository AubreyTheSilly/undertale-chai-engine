@tool
extends Node2D

@export var NormalSprite : Texture2D = preload("res://Sprites/Battle/Buttons/spr_emptybt_0.png")
@export var SelectSprite : Texture2D = preload("res://Sprites/Battle/Buttons/spr_emptybt_1.png")
@export var selected : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if selected:
		$Sprite2D.texture = SelectSprite
	else:
		$Sprite2D.texture = NormalSprite
