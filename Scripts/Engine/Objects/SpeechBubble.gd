@tool
extends Sprite2D

@export_enum("Above","Small Left","Short Left","Small Right","Short Right","Wide Right","Wide Left") var bubbleType = "Small Right"

@export var pos := Vector2(0,0)

var sprites := {
	"Above":preload("res://Sprites/Battle/SpeechBubbles/spr_blconabove_0.png"),
	"Small Left":preload("res://Sprites/Battle/SpeechBubbles/spr_blconsm2_0.png"),
	"Short Left":preload("res://Sprites/Battle/SpeechBubbles/spr_blconsm2_shrt_0.png"),
	"Small Right":preload("res://Sprites/Battle/SpeechBubbles/spr_blconsm_0.png"),
	"Short Right":preload("res://Sprites/Battle/SpeechBubbles/spr_blconsm_shrt_0.png"),
	"Wide Right":preload("res://Sprites/Battle/SpeechBubbles/spr_blconwdshrt_0.png"),
	"Wide Left":preload("res://Sprites/Battle/SpeechBubbles/spr_blconwdshrt_l_0.png")
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	texture = sprites[bubbleType]
	match bubbleType:
		"Small Right":
			position = Vector2(52.25,0.5)
			$TextObject.position = Vector2(-26.5,-39.0)
		"Small Left":
			position = Vector2(-55,0.5)
			$TextObject.position = Vector2(-40,-39.0)
		"Wide Right":
			position = Vector2(79,-2)
			$TextObject.position = Vector2(-80,-39.0)
		"Wide Left":
			position = Vector2(-84,-2)
			$TextObject.position = Vector2(-100,-39.0)
		"Above":
			position = Vector2(0,-60)
			$TextObject.position = Vector2(-78,-39.0)
		"Short Left":
			position = Vector2(-52,-0.5)
			$TextObject.position = Vector2(-40,-19)
		"Short Right":
			position = Vector2(52,-0.5)
			$TextObject.position = Vector2(-30,-19)
	position += pos
