extends CharacterBody2D

@onready var battle = get_parent()
const SPEED := 2

var soul_colors = [Color(1,0,0),Color(0,0,1)]
var bluevel = Vector2.ZERO

var invincible = false
var jumpstage = 2

func calculateDamage(atk : int):
	var HPmod = 0
	var HP = PlayerData.MaxHP
	var def = PlayerData.DEF
	
	if HP <= 20: HPmod = 0
	if 20 < HP and HP < 30: HPmod = 1
	if 30 <= HP and HP < 40: HPmod = 2
	if 40 <= HP and HP < 50: HPmod = 3
	if 50 <= HP and HP < 60: HPmod = 4
	if 60 <= HP and HP < 70: HPmod = 5
	if 70 <= HP and HP < 80: HPmod = 6
	if 80 <= HP and HP < 90: HPmod = 7
	if 90 <= HP: HPmod = 8

	return(round(atk + HPmod - (def / 5)))

func _process(_delta) -> void:
	$Soul.modulate = soul_colors[battle.soulMode]
	match battle.state:
		battle.ENEMY_DIALOGUE:
			visible = true
			jumpstage = 2
			bluevel = Vector2.ZERO
			position = Vector2(159.5,159.75)
		battle.ENEMY_ATTACK:
			visible = true
			match battle.soulMode:
				Battle.SOULMODES.RED:
					velocity = Vector2.ZERO
					velocity = Input.get_vector("Move Left","Move Right","Move Up","Move Down")*(30*SPEED)
				Battle.SOULMODES.BLUE:
					bluevel.x = Input.get_axis("Move Left","Move Right")
					if is_on_floor_only():
						bluevel.y = 0
						jumpstage = 1
					if jumpstage == 1 and velocity.y == 0 and Input.is_action_just_pressed("Move Up"):
						jumpstage = 2
						bluevel.y = -3
					if jumpstage == 2:
						if Input.is_action_just_released("Move Up") and bluevel.y <= -1:
							bluevel.y = -0.5
						if (bluevel.y > 0.5 and bluevel.y < 8):
							bluevel.y += 0.3
						if (bluevel.y > -1 and bluevel.y <= 0.5):
							bluevel.y += 0.1
						if (bluevel.y > -4 and bluevel.y <= -1):
							bluevel.y += 0.25
						if (bluevel.y <= -4):
							bluevel.y += 0.1
					velocity = bluevel*(30*(SPEED))
			for i in $soul.get_overlapping_areas():
				if i.name == "attack" and !invincible:
					var attack = i.get_parent()
					var dmg = calculateDamage(attack.damage)
					if attack.modulate == Color(1,1,1):
						damage(dmg)
					elif attack.modulate == Color(0,1,0):
						heal()
						attack.queue_free()
					elif attack.modulate == Color(0.251,1,1) and velocity != Vector2.ZERO:
						damage(dmg)
					elif attack.modulate == Color(1,0.65,0) and velocity == Vector2.ZERO:
						damage(dmg)
		_:
			visible = false
	move_and_slide()

func damage(dmg : int):
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_hurt1_c.wav")
	$AudioStreamPlayer.play()
	PlayerData.HP -= dmg
	invincible = true
	for i in range(PlayerData.INV/2):
		$Soul.visible = false
		await get_tree().process_frame
		$Soul.visible = true
		await get_tree().process_frame
	invincible = false

func heal():
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_heal_c.wav")
	$AudioStreamPlayer.play()
	PlayerData.HP += 1
