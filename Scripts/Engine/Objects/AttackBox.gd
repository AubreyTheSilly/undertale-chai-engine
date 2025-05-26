extends StaticBody2D

@export var rect : Rect2 = Rect2(Vector2(0,0),Vector2(288,70.5))

func _process(_delta):
	$AttackRect.size = lerp($AttackRect.size,rect.size,0.4)
	var targetPos = Vector2(Vector2(144,35.25)-Vector2(float($AttackRect.size.x)/2,float($AttackRect.size.y)/2))
	$AttackRect.position = targetPos
	
	$CollisionShape2D.position.x = 144-float($AttackRect.size.x/2)+1.5
	$CollisionShape2D2.position.x = 144+float($AttackRect.size.x/2)-1.5
	$CollisionShape2D3.position.y = 35.25-float($AttackRect.size.y/2)+1.5
	$CollisionShape2D4.position.y = 35.25+float($AttackRect.size.y/2)-1.5
