extends StaticBody2D

@export var rect : Rect2 = Rect2(Vector2(0,0),Vector2(288,70.5))

func _process(_delta):
	var targetPos = Vector2(Vector2(144,35.25)-Vector2(float($AttackRect.size.x)/2,float($AttackRect.size.y)/2))
	$AttackRect.size = lerp($AttackRect.size,rect.size,0.05)
	
	$AttackRect.position = targetPos
