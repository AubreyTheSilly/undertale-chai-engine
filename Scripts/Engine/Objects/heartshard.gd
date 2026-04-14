extends AnimatedSprite2D

var velocity := Vector2.ZERO
const GRAVITY = 0.2
const SPEED = 7

func _ready():
	var dir = deg_to_rad(randi_range(0,359))
	
	velocity = Vector2(cos(dir),sin(dir))*SPEED

func _process(_delta):
	velocity.y += GRAVITY
	
	position += velocity
