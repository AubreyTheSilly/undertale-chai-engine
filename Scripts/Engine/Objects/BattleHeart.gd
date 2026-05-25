extends CharacterBody2D

@onready var battle = get_parent()
const SPEED := 2

var soul_colors = [Color(1,0,0),Color(0,0,1)]
var bluevel = Vector2.ZERO
var bluedir = 0

var invincible = false
var jumpstage = 2
var slamming = false
var slamtimer = 0

@onready var box = get_parent().get_node("AttackBox")

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

	return(round(atk + HPmod - (def / 5.0)))

func _ready() -> void:
	var colors = Undermaker.loadJsonAsDictionary("Data/soul_colors.json")
	if colors != {}:
		for i in colors:
			var color : Color = Color.WHITE
			if not colors[i].has("id"):
				return
			if colors[i].has("r"):
				color.r8 =  colors[i]["r"]
			if colors[i].has("g"):
				color.g8 = colors[i]["g"]
			if colors[i].has("b"):
				color.b8 = colors[i]["b"]
			if soul_colors.size()-1 < int(colors[i]["id"]):
				for j in range(int(colors[i]["id"])-soul_colors.size()+1):
					soul_colors.append(Color.WHITE)
			soul_colors[int(colors[i]["id"])] = color

func _process(_delta) -> void:
	global_position.x = clampf(global_position.x,box.get_node("Node2D/AttackRect").global_position.x+3,box.get_node("Node2D/AttackRect").global_position.x+box.get_node("Node2D/AttackRect").size.x-3)
	global_position.y = clampf(global_position.y,box.get_node("Node2D/AttackRect").global_position.y+3,box.get_node("Node2D/AttackRect").global_position.y+box.get_node("Node2D/AttackRect").size.y-3)
	
	$Soul.modulate = soul_colors[battle.soulMode]
	match battle.state:
		battle.ENEMY_DIALOGUE:
			pass
		battle.ENEMY_ATTACK:
			visible = true
			match battle.soulMode:
				Battle.SOULMODES.BLUE:
					var left = "Move Left"
					var right = "Move Right"
					var jump = "Move Up"
					#print(bluedir)
					match abs(bluedir):
						90.0:
							jump = "Move Right"
							left = "Move Up"
							right = "Move Down"
						180.0:
							left = "Move Right"
							right = "Move Left"
							jump = "Move Down"
						270.0:
							left = "Move Down"
							right = "Move Up"
							jump = "Move Left"
					bluevel.x = Input.get_axis(left,right)*SPEED
					
					up_direction = Vector2(0,-1).rotated(deg_to_rad(bluedir))
					
					# old code hopefully i can make it better
					#if is_on_floor():
						#bluevel.y = 0
						#jumpstage = 1
					#elif is_on_ceiling():
						#bluevel.y = 0
						#jumpstage = 2
					#else:
						#jumpstage = 2
					#if jumpstage == 1 and velocity.y == 0 and Input.is_action_just_pressed("Move Up"):
						#jumpstage = 2
						#bluevel.y = -4.5
					#if jumpstage == 2:
						#if Input.is_action_just_released("Move Up") and bluevel.y <= -1:
							#bluevel.y = -1
						#if (bluevel.y > 0.5 and bluevel.y < 8):
							#bluevel.y += 0.4
						#if (bluevel.y > -1 and bluevel.y <= 0.5):
							#bluevel.y += 0.125
						#if (bluevel.y > -4 and bluevel.y <= -1):
							#bluevel.y += 0.325
						#if (bluevel.y <= -4):
							#bluevel.y += 0.125
					
					if is_on_floor():
						if slamming == true and slamtimer == 0:
							$SlamSound.play()
							get_parent().camerashake = 10
							slamming = false
						bluevel.y = 0
						if Input.is_action_just_pressed(jump):
							bluevel.y = -5
					
					if (Input.is_action_just_released(jump) and !is_on_floor()) or is_on_ceiling():
						if bluevel.y < -1:
							bluevel.y = -1
					
					var y_accel : float
					if (bluevel.y <= -4) or (-1 < bluevel.y and bluevel.y <= 0.5):
						y_accel = 0.2
					elif -4 < bluevel.y and bluevel.y <= -1:
						y_accel = 0.5
					elif 0.5 < bluevel.y and bluevel.y < 8:
						y_accel = 0.6
					elif 8 <= bluevel.y:
						y_accel = 0
					
					bluevel.y += y_accel
					
					if slamming:
						bluevel.y = 8
					
					velocity = (bluevel*(30)).rotated(deg_to_rad(bluedir))
				_, Battle.SOULMODES.RED:
					velocity = Vector2.ZERO
					velocity = (Input.get_vector("Move Left","Move Right","Move Up","Move Down")*(30*SPEED))
					bluedir = 0
					bluevel = Vector2.ZERO
			for i in $soul.get_overlapping_areas():
				if i.name == "attack" and !invincible:
					var attack = i.get_parent()
					var dmg = calculateDamage(attack.damage)
					var dir = Input.get_vector("Move Left","Move Right","Move Up","Move Down")
					if attack.modulate == Color(1,1,1):
						damage(dmg)
					elif attack.modulate == Color(0,1,0):
						heal()
						attack.queue_free()
					elif attack.modulate == Color(0.251,1,1) and dir != Vector2.ZERO:	
						damage(dmg)
					elif attack.modulate == Color(1,0.65,0) and dir == Vector2.ZERO:
						damage(dmg)
		_:
			position = Vector2(159.5,159.75)
			velocity = Vector2.ZERO
			visible = false
			jumpstage = 2
			bluevel = Vector2.ZERO
			bluedir = 0
			slamming = false
	move_and_slide()
	if slamtimer > 0:
		slamtimer-=1
	$Soul.rotation_degrees = bluedir
	
	PlayerData.battle_soul_pos = position

func damage(dmg : int):
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_hurt1_c.wav")
	$AudioStreamPlayer.play()
	PlayerData.HP -= dmg
	invincible = true
	for i in range(PlayerData.INV/2.0):
		$Soul.visible = false
		await get_tree().process_frame
		$Soul.visible = true
		await get_tree().process_frame
	invincible = false

func heal():
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_heal_c.wav")
	$AudioStreamPlayer.play()
	PlayerData.HP += 1
