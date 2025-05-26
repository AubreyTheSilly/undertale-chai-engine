class_name Character
extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $Sprite
## Set of animations for the character.
@export var Character_Sprite : CharacterSprite
## Walk speed in pixels per frame. 1 = 30 pixels per second.
@export var Speed : int = 2
@export_enum("left","down","up","right") var direction = "down"

func _ready():
	if Character_Sprite.IdleDown:
		sprite.sprite_frames.add_frame("idle_down",Character_Sprite.IdleDown,1,-1)
	if Character_Sprite.IdleLeft:
		sprite.sprite_frames.add_frame("idle_left",Character_Sprite.IdleLeft,1,-1)
	if Character_Sprite.IdleUp:
		sprite.sprite_frames.add_frame("idle_up",Character_Sprite.IdleUp,1,-1)
	if Character_Sprite.IdleRight:
		sprite.sprite_frames.add_frame("idle_right",Character_Sprite.IdleRight,1,-1)
	
	if Character_Sprite.WalkDown:
		for i in Character_Sprite.WalkDown:
			sprite.sprite_frames.add_frame("move_down",i,1,-1)
	if Character_Sprite.WalkLeft:
		for i in Character_Sprite.WalkLeft:
			sprite.sprite_frames.add_frame("move_left",i,1,-1)
	if Character_Sprite.WalkUp:
		for i in Character_Sprite.WalkUp:
			sprite.sprite_frames.add_frame("move_up",i,1,-1)
	if Character_Sprite.WalkRight:
		for i in Character_Sprite.WalkRight:
			sprite.sprite_frames.add_frame("move_right",i,1,-1)

func handleAnimation(dir : Vector2) -> String:
	var target_animation = "idle_down"
	match dir:
		Vector2(-1,0):
			direction = "left"
		Vector2(0,1):
			direction = "down"
		Vector2(0,-1):
			direction = "up"
		Vector2(1,0):
			direction = "right"
	if dir == Vector2.ZERO:
		target_animation = "idle_"+direction
	else:
		target_animation = "move_"+direction
	if sprite.animation != target_animation:
		sprite.animation = target_animation
		sprite.play()
	return target_animation

func move(steps : int,dir : Vector2) -> void:
	for i in range(steps):
		for j in range(20):
			velocity = dir*(30*Speed)
			await get_tree().process_frame
	velocity = Vector2.ZERO

func _process(delta) -> void:
	sprite.speed_scale = Speed/2
	handleAnimation(velocity/(30*Speed))
	move_and_slide()
