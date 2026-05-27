@tool
extends Node2D

@export var NormalSprite : Texture2D = preload("res://Sprites/Battle/Buttons/spr_emptybt_0.png")
@export var SelectSprite : Texture2D = preload("res://Sprites/Battle/Buttons/spr_emptybt_1.png")
@export var selected : bool = false
@export var use_modulate_override := false
@export var modulate_override := Color.WHITE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if selected:
		$Sprite2D.texture = SelectSprite
	else:
		$Sprite2D.texture = NormalSprite
	
	if !Engine.is_editor_hint():
		$Sprite2D.modulate = [Undermaker.accents["battlebutton"],Undermaker.accents["battlebuttonselect"]][int(selected)]
	
	if use_modulate_override:
		$Sprite2D.modulate = modulate_override
