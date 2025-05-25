extends Node2D

var velocity = 0
const GRAVITY = 0.5
var applyGravity = false

func bounce():
	visible = true
	$Label.position.y = 0
	velocity = -4
	applyGravity = true
	while $Label.position.y <= 0:
		await get_tree().process_frame
	velocity = 0
	applyGravity = false

func _process(_delta):
	$Label.position.y += velocity
	if $Label.position.y > 0:
		$Label.position.y = 0
	if applyGravity:
		velocity += GRAVITY
