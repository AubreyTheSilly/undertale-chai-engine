extends ScriptRunner

var enemydata : EnemyData
var frame = 0
var running = true

func unhandled_function(tokens : TokenArray):
	print(tokens.data[0].lexeme)
	match tokens.data[0].lexeme:
		"create_attack":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data.size() < 7 or tokens.data.size() > 8:
				push_error("Invalid number of arguments for create_attack")
				return
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Attack name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Attack X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Attack Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.STRING:
				push_error("Attack sprite path must be a string")
				return
			if !Loader.load_file("Sprites/Battle/Attacks/"+tokens.data[4].value+".png"):
				push_error(": Sprite path must lead to a valid image file (Path: "+"Sprites/Battle/Attacks/"+tokens.data[4].value+".png)")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Attack X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Attack Y velocity must be a number")
				return
			if tokens.data.size() == 8:
				if tokens.data[7].type != Token.TokenType.STRING:
					push_error("Attack color must be a string")
					return
			var attack = preload("res://Scenes/Objects/Attack.tscn").instantiate()
			attack.name = tokens.data[1].value
			attack.damage = enemydata.ATK
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.texture = Loader.load_file("Sprites/Battle/Attacks/"+str(tokens.data[4].value)+".png")
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			if tokens.data.size() == 8:
				attack.attack_type = tokens.data[7].value
			node.get_node("attacks/bounding").add_child(attack)
		"create_attack_nobounding":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data.size() < 7 or tokens.data.size() > 8:
				push_error("Invalid number of arguments for create_attack_nobounding")
				return
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Attack name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Attack X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Attack Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.STRING:
				push_error("Attack sprite path must be a string")
				return
			if !Loader.load_file("Sprites/Battle/Attacks/"+tokens.data[4].value+".png"):
				push_error(": Sprite path must lead to a valid image file (Path: "+"Sprites/Battle/Attacks/"+tokens.data[4].value+".png)")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Attack X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Attack Y velocity must be a number")
				return
			if tokens.data.size() == 8:
				if tokens.data[7].type != Token.TokenType.STRING:
					push_error("Attack color must be a string")
					return
			var attack = preload("res://Scenes/Objects/Attack.tscn").instantiate()
			attack.name = tokens.data[1].value
			attack.damage = enemydata.ATK
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.texture = Loader.load_file("Sprites/Battle/Attacks/"+str(tokens.data[4].value)+".png")
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			if tokens.data.size() == 8:
				attack.attack_type = tokens.data[7].value
			node.get_node("attacks").add_child(attack)
		"set_box_size":
			if tokens.data.size() != 3:
				push_error("Invalid number of arguments for set_box_size")
				return
			if tokens.data[1].type != Token.TokenType.NUMBER:
				push_error("Box X scale must be a number")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Box Y scale must be a number")
				return
			get_parent().rect.size = Vector2(float(tokens.data[1].value),float(tokens.data[2].value))
			await get_tree().process_frame
		"set_soulmode":
			if tokens.data.size() != 2:
				push_error("Invalid number of arguments for set_soulmode")
				return
			if get_parent().get_parent().soulMode != int(float(tokens.data[1].value)):
				get_parent().get_parent().soulMode = int(float(tokens.data[1].value))
				var audio = AudioStreamPlayer.new()
				add_child(audio)
				audio.stream = preload("res://Audio/Sounds/snd_bell.wav")
				audio.play()
				audio.finished.connect(audio.queue_free)
		"create_bone":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Bone name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Bone X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Bone Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.NUMBER:
				push_error("Bone length must be a number")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Bone X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Bone Y velocity must be a number")
				return
			if tokens.data[7].type != Token.TokenType.NUMBER:
				push_error("Bone direction must be a number")
				return
			if tokens.data.size() >= 9:
				if tokens.data[8].type != Token.TokenType.STRING:
					push_error("Bone color must be a string")
					return
			if tokens.data.size() >= 10:
				if tokens.data[9].type != Token.TokenType.BOOLEAN:
					push_error("Bone type must be a bool")
					return
			var attack = preload("res://Scenes/Objects/Bone.tscn").instantiate()
			attack.name = tokens.data[1].value
			attack.damage = enemydata.ATK
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.height = float(tokens.data[4].value)
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			attack.rotation_degrees = tokens.data[7].value
			if tokens.data.size() >= 9:
				attack.attack_type = tokens.data[8].value
			if tokens.data.size() == 10:
				attack.pap = tokens.data[9].value
			node.get_node("attacks/bounding").add_child(attack)
		"create_doublebone":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Bone name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Bone X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Bone Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.NUMBER:
				push_error("Bone length must be a number")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Bone X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Bone Y velocity must be a number")
				return
			if tokens.data[7].type != Token.TokenType.NUMBER:
				push_error("Bone direction must be a number")
				return
			if tokens.data.size() >= 9:
				if tokens.data[8].type != Token.TokenType.STRING:
					push_error("Bone color must be a string")
					return
			if tokens.data.size() >= 10:
				if tokens.data[9].type != Token.TokenType.BOOLEAN:
					push_error("Bone type must be a bool")
					return
			var attack = preload("res://Scenes/Objects/DoubleBone.tscn").instantiate()
			attack.name = tokens.data[1].value
			attack.damage = enemydata.ATK
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.height = float(tokens.data[4].value)
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			attack.rotation_degrees = tokens.data[7].value
			if tokens.data.size() >= 9:
				attack.attack_type = tokens.data[8].value
			if tokens.data.size() == 10:
				attack.pap = tokens.data[9].value
			node.get_node("attacks/bounding").add_child(attack)
		"create_blaster":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Blaster name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Blaster X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Blaster Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.NUMBER:
				push_error("Blaster direction must be a number")
				return
			if tokens.data.size() >= 6:
				if tokens.data[5].type != Token.TokenType.STRING:
					push_error("Blaster color must be a string")
					return
			var attack = preload("res://Scenes/Objects/blaster.tscn").instantiate()
			attack.name = tokens.data[1].value
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.rotation_degrees = tokens.data[4].value
			if tokens.data.size() == 6:
				attack.attack_type = tokens.data[5].value
			node.get_node("attacks").add_child(attack)
		"create_platform":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Platform name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Platform X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Platform Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.NUMBER:
				push_error("Platform width must be a number")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Platform X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Platform Y velocity must be a number")
				return
			var attack = preload("res://Scenes/Objects/SansPlatform.tscn").instantiate()
			attack.name = tokens.data[1].value
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.width = float(tokens.data[4].value)
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			node.get_node("attacks/bounding").add_child(attack)
		"create_platform_nobounding":
			for i in tokens.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Platform name must be a string")
				return
			if tokens.data[2].type != Token.TokenType.NUMBER:
				push_error("Platform X position must be a number")
				return
			if tokens.data[3].type != Token.TokenType.NUMBER:
				push_error("Platform Y position must be a number")
				return
			if tokens.data[4].type != Token.TokenType.NUMBER:
				push_error("Platform width must be a number")
				return
			if tokens.data[5].type != Token.TokenType.NUMBER:
				push_error("Platform X velocity must be a number")
				return
			if tokens.data[6].type != Token.TokenType.NUMBER:
				push_error("Platform Y velocity must be a number")
				return
			var attack = preload("res://Scenes/Objects/SansPlatform.tscn").instantiate()
			attack.name = tokens.data[1].value
			var attackx = float(tokens.data[2].value)
			var attacky = float(tokens.data[3].value)
			attack.position = Vector2(attackx,attacky)
			attack.width = float(tokens.data[4].value)
			var velx = float(tokens.data[5].value)
			var vely = float(tokens.data[6].value)
			attack.velocity = Vector2(velx,vely)
			node.get_node("attacks").add_child(attack)
		"slam":
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Slam direction must be a string")
				return
			match tokens.data[1].value:
				"left":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 90
					get_parent().get_parent().get_node("BattleHeart").slamming = true
					get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
				"right":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 270
					get_parent().get_parent().get_node("BattleHeart").slamming = true
					get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
				"down":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 0
					get_parent().get_parent().get_node("BattleHeart").slamming = true
					get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
				"up":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 180
					get_parent().get_parent().get_node("BattleHeart").slamming = true
					get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
				_:
					push_error("Slam direction must be \"left\", \"right\", \"up\", or \"down\". (case-sensitive)")
		"set_soul_direction":
			if tokens.data[1].type != Token.TokenType.STRING:
				push_error("Soul direction must be a string")
				return
			match tokens.data[1].value:
				"left":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 90
				"right":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 270
				"down":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 0
				"up":
					get_parent().get_parent().get_node("BattleHeart").bluedir = 180
				_:
					push_error("Soul direction must be \"left\", \"right\", \"up\", or \"down\". (case-sensitive)")
					return
		"end_attack":
			running = false
			#print("hi")
		_:
			print(tokens.data[0].lexeme)

func _pre_run():
	vars["FRAME"] = UMVar.new()
	vars["FRAME"].type = Token.TokenType.TYPE_NUM
	vars["FRAME"].value = frame
	vars["DELTA"] = UMVar.new()
	vars["DELTA"].type = Token.TokenType.TYPE_NUM
	vars["DELTA"].value = get_process_delta_time()
	vars["LEFT"] = UMVar.new()
	vars["LEFT"].type = Token.TokenType.TYPE_NUM
	vars["LEFT"].value = 0
	vars["RIGHT"] = UMVar.new()
	vars["RIGHT"].type = Token.TokenType.TYPE_NUM
	vars["RIGHT"].value = 0
	vars["UP"] = UMVar.new()
	vars["UP"].type = Token.TokenType.TYPE_NUM
	vars["UP"].value = 0
	vars["DOWN"] = UMVar.new()
	vars["DOWN"].type = Token.TokenType.TYPE_NUM
	vars["DOWN"].value = 0

func _pre_line():
	vars["LEFT"].value = (-get_parent().box_width/2)+3
	vars["RIGHT"].value = (get_parent().box_width/2)-3
	vars["UP"].value = (-get_parent().box_height/2)+3
	vars["DOWN"].value = (get_parent().box_height/2)-3
