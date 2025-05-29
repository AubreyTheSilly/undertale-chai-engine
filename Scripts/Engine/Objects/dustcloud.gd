extends AnimatedSprite2D

var direction : float
var rot : int

func _ready() -> void:
	direction = randi_range(-90,90)

func _process(_delta) -> void:
	position += Vector2(1,0).rotated(direction)*2
