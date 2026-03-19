class_name Player
extends Character

func _ready() -> void:
	PlayerData.obj = self
	reload_sprite()
	if Character_Sprite.IdleDown:
		_sprite.sprite_frames.add_frame("idle_down",Character_Sprite.IdleDown,1,-1)
	if Character_Sprite.IdleLeft:
		_sprite.sprite_frames.add_frame("idle_left",Character_Sprite.IdleLeft,1,-1)
	if Character_Sprite.IdleUp:
		_sprite.sprite_frames.add_frame("idle_up",Character_Sprite.IdleUp,1,-1)
	if Character_Sprite.IdleRight:
		_sprite.sprite_frames.add_frame("idle_right",Character_Sprite.IdleRight,1,-1)
	
	if Character_Sprite.WalkDown:
		for i in Character_Sprite.WalkDown:
			_sprite.sprite_frames.add_frame("move_down",i,1,-1)
	if Character_Sprite.WalkLeft:
		for i in Character_Sprite.WalkLeft:
			_sprite.sprite_frames.add_frame("move_left",i,1,-1)
	if Character_Sprite.WalkUp:
		for i in Character_Sprite.WalkUp:
			_sprite.sprite_frames.add_frame("move_up",i,1,-1)
	if Character_Sprite.WalkRight:
		for i in Character_Sprite.WalkRight:
			_sprite.sprite_frames.add_frame("move_right",i,1,-1)
	
	PlayerData.player_teleporting = false
	PlayerData.player_can_move = true
	if PlayerData.player_teleport_position:
		position = PlayerData.player_teleport_position
	fader.fadeIn()

func _process(_delta) -> void:
	var can_move = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting
	if can_move:
		velocity = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))*(30*Speed)
	_handleAnimation(velocity/(30*Speed))
	move_and_slide()
