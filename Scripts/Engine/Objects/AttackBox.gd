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
	frame = 0
	var runNext = true
	for i in scr.data:
		if runNext == false:
			if i.name == "end":
				runNext = true
			continue
		match i.name:
			"wait":
				await get_tree().create_timer(float(i.parameters[0])).timeout
			"print":
				var text = ""
				for j in i.parameters:
					if get(j):
						text += str(get(j))+" "
					else:
						var txt = str(j)
						if txt[0] == '"':
							txt[0] = ""
						if txt[-1] == '"':
							txt[-1] = ""
						text += txt+" "
				print(text)
			"set":
				if get(i.parameters[0]) != null:
					if get(i.parameters[1]) != null:
						set(i.parameters[0],get(i.parameters[1]))
					else:
						set(i.parameters[0],str_to_var(i.parameters[1]))
				else:
					if get(i.parameters[1]) != null:
						vars[i.parameters[0]] = get(i.parameters[1])
					else:
						vars[i.parameters[0]] = str_to_var(i.parameters[1])
			"create_sprite":
				print(i.parameters)
				var sprite = Sprite2D.new()
				sprite.name = str(i.parameters[0])
				sprite.position = Vector2(int(i.parameters[1]),int(i.parameters[2]))
				sprite.texture = Loader.load_file("Sprites/"+str(i.parameters[3])+".png")
				print(i.parameters.size())
				if i.parameters.size() >= 5:
					print("layer "+str(i.parameters[4]))
					sprite.z_index = int(i.parameters[4])
				if i.parameters.size() == 7:
					print("offset "+str(i.parameters[5])+" "+str(i.parameters[6]))
					sprite.offset = Vector2(int(i.parameters[5]),int(i.parameters[6]))
				if i.flags.has("_scene"):
					get_tree().current_scene.add_child(sprite)
				else:
					add_child(sprite)
			"sin":
				vars[str(i.parameters[0])] = sin(frame*float(i.parameters[1]))*float(i.parameters[2])
			"cos":
				vars[str(i.parameters[0])] = cos(frame*float(i.parameters[1]))*float(i.parameters[2])
			"rand":
				vars[str(i.parameters[0])] = randf_range(float(i.parameters[1]),float(i.parameters[2]))
			"set_property":
				var setvar = str_to_var(i.parameters[2])
				if vars.has(str(i.parameters[2])):
					setvar = vars[str(i.parameters[2])]
				elif get(i.parameters[2]):
					setvar = get(i.parameters[2])
				if i.parameters[0] == "self":
					set(i.parameters[1],setvar)
				else:
					if i.flags.has("_scene"):
						get_tree().current_scene.get_node(str(i.parameters[0])).set(i.parameters[1],setvar)
					else:
						get_node(str(i.parameters[0])).set(i.parameters[1],setvar)
			"set_position":
				var x = int(i.parameters[1])
				var y = int(i.parameters[2])
				
				if vars.has(str(i.parameters[1])):
					x = vars[str(i.parameters[1])]
				if vars.has(str(i.parameters[2])):
					y = vars[str(i.parameters[2])]
				
				var pos = Vector2(x,y)
				if i.parameters[0] == "self":
					set("position",pos)
				else:
					if i.flags.has("_scene"):
						get_tree().current_scene.get_node(str(i.parameters[0])).set("position",pos)
					else:
						get_node(str(i.parameters[0])).set("position",pos)
			"change":
				if vars.has(str(i.parameters[1])):
					if vars[str(i.parameters[1])] is int:
						match str(i.parameters[0]):
							"+":
								vars[str(i.parameters[1])] += int(i.parameters[2])
							"-":
								vars[str(i.parameters[1])] -= int(i.parameters[2])
							"*":
								vars[str(i.parameters[1])] *= int(i.parameters[2])
							"/":
								vars[str(i.parameters[1])] /= int(i.parameters[2])
			"if":
				var compare = i.parameters[0]
				if i.flags.has("_not"):
					if get(compare):
						if i.parameters.size() == 1:
							runNext = false
						elif get(compare) == str_to_var(i.parameters[1]):
							runNext = false
						continue
					if !vars.has(compare):
						continue
					if vars[compare] == str_to_var(i.parameters[1]):
						runNext = false
				else:
					if get(compare) != null:
						if i.parameters.size() == 1:
							runNext = true
						elif get(compare) == str_to_var(i.parameters[1]):
							runNext = true
						else:
							runNext = false
						continue
					if !vars.has(compare):
						runNext = false
						continue
					if vars[compare] != str_to_var(i.parameters[1]):
						runNext = false
			"create_attack":
				var attack = preload("res://Scenes/Objects/Attack.tscn").instantiate()
				attack.name = i.parameters[0]
				attack.damage = enemy_data.ATK
				var attackx = float(i.parameters[1])
				var attacky = float(i.parameters[2])
				if vars.has(str(i.parameters[1])):
					attackx = vars[str(i.parameters[1])]
				if vars.has(str(i.parameters[2])):
					attacky = vars[str(i.parameters[2])]
				attack.position = Vector2(attackx,attacky)
				attack.texture = Loader.load_file("Sprites/Battle/Attacks/"+str(i.parameters[3])+".png")
				var velx = float(i.parameters[4])
				var vely = float(i.parameters[5])
				if vars.has(str(i.parameters[4])):
					velx = vars[str(i.parameters[4])]
				if vars.has(str(i.parameters[5])):
					vely = vars[str(i.parameters[5])]
				attack.velocity = Vector2(velx,vely)
				if i.parameters.size() == 7:
					attack.attack_type = i.parameters[6]
				if i.flags.has("_ignoreclipping"):
					$attacks.add_child(attack)
				else:
					$attacks/bounding.add_child(attack)
			"play_sound":
				var audio = AudioStreamPlayer.new()
				add_child(audio)
				audio.stream = Loader.load_file("Audio/Sounds/"+str(i.parameters[0])+".wav")
				audio.finished.connect(audio.queue_free)
				audio.play()
			"set_box_size":
				rect.size = Vector2(float(i.parameters[0]),float(i.parameters[1]))
			"set_soulmode":
				get_parent().soulMode =  int(i.parameters[0])
			"stop":
				break
	attack_over.emit()
