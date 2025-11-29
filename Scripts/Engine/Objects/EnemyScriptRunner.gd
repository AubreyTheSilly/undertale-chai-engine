extends ScriptRunner

var damage : int = -450

func unhandled_function(line : TokenArray):
	match line.data[0].lexeme:
		"set_enemydata":
			if line.data.size() <= 2:
				push_error("Not enough parameters for set_enemydata, must be 3")
				return
			elif line.data.size() >= 4:
				push_error("Too many parameters for set_enemydata, must be 3")
				return
			elif line.data[1].type == Token.TokenType.STRING:
				var property = line.data[1].value
				var value = line.data[2].value
				match property:
					"EnemySprite":
						node.enemy_data.EnemySprite = Loader.load_file("Sprites/Battle/Enemies/"+line.data[2].value+".png")
			else:
				push_error("Enemy data to change must be a string")
		"dialog":
			var dialogarray = []
			var first = true
			if line.data.size() == 0:
				push_error("You must have at least one dialogue string")
				return
			for i in line.data:
				if first:
					first = false
					continue
				if i.type != Token.TokenType.STRING:
					push_error("Dialogue must be a string")
				else:
					dialogarray.append(i.value)
			await get_parent().flavorbox.StartBattleDialogue(dialogarray)
		"damage":
			for i in line.data:
				if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					var variable = getVariable(i.lexeme)
					i.type = types[variable.type]
					i.value = variable.value
			if line.data.size() != 2:
				push_error("Invalid amount of parameters for damage, must be 2")
				return
			elif line.data.size() >= 4:
				push_error("Too many parameters for damage, must be 2")
				return
			elif line.data[1].type != Token.TokenType.NUMBER:
				push_error("Damage amount must be a number")
				return
			var damage = line.data[1].value
			if damage >= 0:
				# enemy hurt :(
				$"../AudioStreamPlayer".stream = preload("res://Audio/Sounds/snd_damage_c.wav")
				$"../AudioStreamPlayer".play()
				node.Shudder()
				$"../DamageText/Label".label_settings.font_color = Color.RED
				$"../DamageText/Label".text = str(int(damage))
				$"../DamageText".bounce()
				$"../HPBar".visible = true
				var ogHP = $"../HPBar".value
				while $"../HPBar".value > (ogHP-damage):
					$"../HPBar".value -= (damage/15)
					await get_tree().process_frame
			else:
				# you missed dumbass
				$"../DamageText/Label".label_settings.font_color = Color.GRAY
				$"../DamageText/Label".text = "MISS"
				$"../DamageText".bounce()
				var shudder = 16
				while shudder != 0:
					if (shudder < 0):
						shudder = (-((shudder + 2)))
					else:
						shudder = (-shudder)
					await get_tree().process_frame
					await get_tree().process_frame
				$"../DamageText".visible = false
				node.damage_done.emit()
		"slice":
			if line.data.size() != 1:
				push_error("slice does not have any parameters")
				return
			node.get_node("AudioStreamPlayer").stream = preload("res://Audio/Sounds/snd_laz_c.wav")
			node.get_node("AudioStreamPlayer").play()
			node.get_node("AnimatedSprite2D").play()
			await get_tree().create_timer(1.0).timeout
		"damage_done":
			if line.data.size() != 1:
				push_error("damage_done does not have any parameters")
				return
			node.damage_done.emit()
		"shudder":
			var shudder = 16
			while shudder != 0:
				if (shudder < 0):
					shudder = (-((shudder + 2)))
				else:
					shudder = (-shudder)
				node.sprite.position.x = shudder
				await get_tree().process_frame
				await get_tree().process_frame

func _pre_run():
	if damage != -450:
		vars["damage"] = UMVar.new()
		vars["damage"].type = Token.TokenType.TYPE_NUM
		vars["damage"].value = damage
		damage = -450
	
	vars["LASTCHOICE"] = UMVar.new()
	vars["LASTCHOICE"].type = Token.TokenType.TYPE_NUM
	vars["LASTCHOICE"].value = get_parent().get_parent().playerbuttonchoice
