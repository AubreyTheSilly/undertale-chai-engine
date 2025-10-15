extends ScriptRunner

func unhandled_function(line : TokenArray):
	match line.data[0].lexeme:
		"set_enemydata":
			if line.data.size() <= 2:
				push_error("Not enough parameters for set_enemydata, must be 3")
			elif line.data.size() >= 4:
				push_error("Too many parameters for set_enemydata, must be 3")
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

func _pre_run():
	vars["LASTCHOICE"] = UMVar.new()
	vars["LASTCHOICE"].type = Token.TokenType.TYPE_NUM
	vars["LASTCHOICE"].value = get_parent().get_parent().playerbuttonchoice
