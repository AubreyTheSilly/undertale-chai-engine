class_name Player
extends Character

func _ready() -> void:
	if CharacterJson:
		Character_Sprite = CharacterSprite.fromJson(CharacterJson+".json")
	else:
		Character_Sprite = CharacterSprite.fromJson("player.json")
	
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
	
	PlayerData.player_teleporting = false
	PlayerData.player_can_move = true
	if PlayerData.player_teleport_position:
		position = PlayerData.player_teleport_position
	fader.fadeIn()

func _process(_delta) -> void:
	PlayerData.obj = self
	var can_move = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting
	if can_move:
		velocity = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))*(30*Speed)
	handleAnimation(velocity/(30*Speed))
	move_and_slide()
