extends StaticBody2D

@export var rect : Rect2 = Rect2(Vector2(0,0),Vector2(288,70.5))

var vars = {}
var frame := 0

# for scripts
var box_width : float = 0
var box_height : float = 0

signal attack_over

func _process(_delta):
	frame += 1
	$AttackRect.size=lerp($AttackRect.size,rect.size,0.4)
	var offset = -$AttackRect.size/2.0
	var targetPos = Vector2(144.0,35.25)
	$AttackRect.position = targetPos+offset
	
	$CollisionShape2D.position.x = 144-float($AttackRect.size.x/2)+1.5
	$CollisionShape2D2.position.x = 144+float($AttackRect.size.x/2)-1.5
	$CollisionShape2D3.position.y = 35.25-float($AttackRect.size.y/2)+1.5
	$CollisionShape2D4.position.y = 35.25+float($AttackRect.size.y/2)-1.5
	
	var box_size = Vector2(float($AttackRect.size.x),float($AttackRect.size.y))-Vector2(6.0,6.0)
	box_width = box_size.x
	box_height = box_size.y
	$attacks/bounding.polygon = [Vector2(-box_size.x/2,-box_size.y/2),Vector2(-box_size.x/2,box_size.y/2),Vector2(box_size.x/2,box_size.y/2),Vector2(box_size.x/2,-box_size.y/2)]

func runScript(scr : UTScript,enemy_data : EnemyData):
	attack_over.emit()
