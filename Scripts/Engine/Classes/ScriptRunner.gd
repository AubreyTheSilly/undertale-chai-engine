class_name ScriptRunner
extends Node

## File path from Scripts/ to the script file.
@export var script_to_run : String
## Must be set for like create and set functions to work.
@export var node : Node

var types = {
	Token.TokenType.STRING:Token.TokenType.TYPE_STRING,
	Token.TokenType.BOOLEAN:Token.TokenType.TYPE_BOOL,
	Token.TokenType.NUMBER:Token.TokenType.TYPE_NUM,
	Token.TokenType.TYPE_STRING:Token.TokenType.STRING,
	Token.TokenType.TYPE_BOOL:Token.TokenType.BOOLEAN,
	Token.TokenType.TYPE_NUM:Token.TokenType.NUMBER
}

var operators = [Token.TokenType.PLUS,Token.TokenType.MINUS,Token.TokenType.STAR,Token.TokenType.SLASH]

var ifoperators = [5, 7, 8, 9, 10, 11]

var vars : Dictionary[String,UMVar]
var persistentVars : Dictionary[String,UMVar]

var last_script : UTScript
var last_script_filename : String = ""

signal script_finished

func getVariable(varName : String):
	if persistentVars.has(varName):
		return persistentVars[varName]
	elif vars.has(varName):
		return vars[varName]
	else:
		return null

func _pre_line():
	pass

func _pre_run():
	pass

func run_script(script : String = script_to_run,function_name : String = "",verbose : bool = false) -> Error:
	if script == "":
		push_warning("Tried to run an empty script, it will be assumed this is intentional")
		await get_tree().process_frame
		script_finished.emit()
		return ERR_SCRIPT_FAILED
	if !script:
		push_error("There is no script to run! Make sure to set script_to_run!!")
		return ERR_DOES_NOT_EXIST
	
	var ogrunscript : UTScript = UTScript.loadScriptFromFile(script,verbose)
	var runscript : UTScript = ogrunscript
	vars.clear()
	
	var line : int =-1
	var skip_depth = 0
	var depth = 0
	
	var while_line = -1
	var while_depth = -1
	
	_pre_run()
	
	while line < runscript.data.size()-1:
		line += 1
		var reset = false
		_pre_line()
		
		if skip_depth != 0:
			if runscript.data[line].data.size() != 0:
				if runscript.data[line].data[0].type == Token.TokenType.END:
					skip_depth -= 1
					depth -= 1
				elif runscript.data[line].data[0].type == Token.TokenType.IF or runscript.data[line].data[0].type == Token.TokenType.WHILE:
					skip_depth += 1
					depth += 1
			continue
		if runscript.data[line].data.size() != 0:
			var token = runscript.data[line].data[0]
			var _stringtokenno = -1
			for i in runscript.data[line].data:
				_stringtokenno += 1
				if i.type == Token.TokenType.STRING:
					var start := -1
					var end := -1
					var index := -1
					var replace := ""
					var replacevar := ""
					
					for j in i.value:
						index += 1
						if j == "%":
							if start == -1:
								start = index
							else:
								end = index
						if start!=-1 and end!=-1:
							reset = true
							replace = i.value.substr(start,(end-start)+1)
							replacevar = replace.rstrip("%").lstrip("%")
							var variable = getVariable(replacevar)
							if variable:
								if variable.type == Token.TokenType.TYPE_NUM and str(variable.value).ends_with(".0"):
									i.value = i.value.replace(replace,str(variable.value).substr(0,str(variable.value).length()-2))
								else:
									i.value = i.value.replace(replace,str(variable.value))
								index -= replace.length() 
								index += str(variable.value).length()
							start=-1
							end=-1
			match token.type:
				Token.TokenType.PRINT:
					var msg = ""
					for i in runscript.data[line].data:
						if i.type != Token.TokenType.PRINT:
							msg += str(i.value)+" "
					print(msg)
				Token.TokenType.VAR:
					if runscript.data[line].data[1].type >= 23 and runscript.data[line].data[1].type <= 25:
						var variable : UMVar = UMVar.new()
						variable.type = runscript.data[line].data[1].type
						if runscript.data[line].data[2].type == Token.TokenType.IDENTIFIER:
							if runscript.data[line].data[2].lexeme[0] == "$":
								runscript.data[line].data[2].lexeme[0] = ""
								persistentVars[runscript.data[line].data[2].lexeme] = variable
							else:
								vars[runscript.data[line].data[2].lexeme] = variable
						else:
							push_error("line "+str(line+1)+": Failed to input an identifier for var")
					else:
						push_error("line "+str(line+1)+": Not a data type")
				Token.TokenType.SET:
					if runscript.data[line].data[2].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[2].lexeme)
						if variable:
							runscript.data[line].data[2].type = types[variable.type]
							runscript.data[line].data[2].value = variable.value
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == types[runscript.data[line].data[2].type]:
								variable.value = runscript.data[line].data[2].value
							else:
								push_error("line "+str(line+1)+": Variable set type does not match!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for set")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for set")
				Token.TokenType.INCREMENT:
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == Token.TokenType.TYPE_NUM:
								variable.value += 1.0
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for increment")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for increment")
				Token.TokenType.DECREMENT:
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == Token.TokenType.TYPE_NUM:
								variable.value -= 1.0
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for decrement")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for decrement")
				Token.TokenType.WHILE:
					depth += 1
					while_depth = depth
					while_line = line
					if runscript.data[line].data.size() == 2:
						if !bool(runscript.data[line].data[1].value):
							skip_depth += 1
					elif !(ifoperators.has(runscript.data[line].data[2].type)):
						push_error("line "+str(line+1)+": You must add a valid operator for while")
					elif runscript.data[line].data.size() == 3:
						push_error("line "+str(line+1)+": You must have a valid number of arguments for while")
					else:
						var variable1 = getVariable(runscript.data[line].data[1].lexeme)
						var variable2 = getVariable(runscript.data[line].data[3].lexeme)
						if variable1:
							runscript.data[line].data[1].value = variable1.value
						if variable2:
							runscript.data[line].data[3].value = variable2.value
						match runscript.data[line].data[2].type:
							5:
								if runscript.data[line].data[1].value == runscript.data[line].data[3].value:
									skip_depth += 1
							7:
								if runscript.data[line].data[1].value != runscript.data[line].data[3].value:
									skip_depth += 1
							8:
								if runscript.data[line].data[1].value <= runscript.data[line].data[3].value:
									skip_depth += 1
							9:
								if !(runscript.data[line].data[1].value >= runscript.data[line].data[3].value):
									skip_depth += 1
							10:
								if runscript.data[line].data[1].value >= runscript.data[line].data[3].value:
									skip_depth += 1
							11:
								if (runscript.data[line].data[1].value <= runscript.data[line].data[3].value):
									skip_depth += 1
				Token.TokenType.BREAK:
					if while_line != -1:
						skip_depth += 1
						line = while_line-1
						while_line = -1
				Token.TokenType.END:
					if depth:
						if depth == while_depth and while_line != -1:
							line = while_line-1
						else:
							depth -= 1
				Token.TokenType.IF:
					depth += 1
					if runscript.data[line].data.size() == 2:
						if !bool(runscript.data[line].data[1].value):
							skip_depth += 1
					elif !(ifoperators.has(runscript.data[line].data[2].type)):
						push_error("line "+str(line+1)+": You must add a valid operator for if")
					elif runscript.data[line].data.size() == 3:
						push_error("line "+str(line+1)+": You must have a valid number of arguments for if")
					else:
						var variable1 = getVariable(runscript.data[line].data[1].lexeme)
						var variable2 = getVariable(runscript.data[line].data[3].lexeme)
						if variable1:
							runscript.data[line].data[1].value = variable1.value
						if variable2:
							runscript.data[line].data[3].value = variable2.value
						match runscript.data[line].data[2].type:
							5:
								if runscript.data[line].data[1].value == runscript.data[line].data[3].value:
									skip_depth += 1
							7:
								if runscript.data[line].data[1].value != runscript.data[line].data[3].value:
									skip_depth += 1
							8:
								if runscript.data[line].data[1].value <= runscript.data[line].data[3].value:
									skip_depth += 1
							9:
								if !(runscript.data[line].data[1].value >= runscript.data[line].data[3].value):
									skip_depth += 1
							10:
								if runscript.data[line].data[1].value >= runscript.data[line].data[3].value:
									skip_depth += 1
							11:
								if (runscript.data[line].data[1].value <= runscript.data[line].data[3].value):
									skip_depth += 1
				Token.TokenType.FUNCTION:
					depth += 1
					if runscript.data[line].data.size() == 2:
						if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
							if runscript.data[line].data[1].value != function_name:
								skip_depth += 1
						else:
							push_error("line "+str(line+1)+": Function name must be an identifier")
					else:
						push_error("line "+str(line+1)+": You must have a valid number of arguments for function")
				Token.TokenType.PLAY_SND:
					if runscript.data[line].data.size() == 1:
						push_error("line "+str(line+1)+": You must have a sound to play for playsnd")
						continue
					elif runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": You must put a string for playsnd")
						continue
					var audio = AudioStreamPlayer.new()
					add_child(audio)
					audio.stream = Loader.load_file("Audio/Sounds/"+runscript.data[line].data[1].value+".wav")
					if audio.stream:
						audio.play()
						audio.finished.connect(audio.queue_free)
					else:
						audio.stream = Loader.load_file("Audio/Sounds/"+runscript.data[line].data[1].value+".ogg")
						if audio.stream:
							audio.play()
							audio.finished.connect(audio.queue_free)
						else:
							push_error("line "+str(line+1)+": Sound \""+runscript.data[line].data[1].value+"\" does not exist")
							audio.queue_free()
				Token.TokenType.WAIT:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": You must input a valid number")
						continue
					await get_tree().create_timer(runscript.data[line].data[1].value).timeout
				Token.TokenType.SET_PROPERTY:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variabl = getVariable(i.lexeme)
							i.type = types[variabl.type]
							i.value = variabl.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node property must be a string")
						continue
					var variable = getVariable(runscript.data[line].data[3].lexeme)
					if variable:
						runscript.data[line].data[3].value = variable.value
					if runscript.data[line].data[1].value == "self":
						create_tween().tween_property(node,runscript.data[line].data[2].value,runscript.data[line].data[3].value,0)
					else:
						create_tween().tween_property(node.get_node(runscript.data[line].data[1].value),runscript.data[line].data[2].value,runscript.data[line].data[3].value,0)
				Token.TokenType.TWEEN_PROPERTY:
					if runscript.data[line].data.size() < 5:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node(runscript.data[line].data[1].value):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node property must be a string")
						continue
					if runscript.data[line].data[4].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Tween time must be a valid number")
						continue
					if runscript.data[line].data.size() == 5:
						create_tween().tween_property(node.get_node(runscript.data[line].data[1].value),runscript.data[line].data[2].value,runscript.data[line].data[3].value,runscript.data[line].data[4].value)
					elif runscript.data[line].data.size() > 6:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					else:
						if runscript.data[line].data[5].type >= Token.TokenType.IN and runscript.data[line].data[5].type <= Token.TokenType.OUT_IN:
							var tweentype = Tween.EASE_IN_OUT
							match runscript.data[line].data[5].type:
								Token.TokenType.IN:
									tweentype = Tween.EASE_IN
								Token.TokenType.OUT:
									tweentype = Tween.EASE_OUT
								Token.TokenType.IN_OUT:
									tweentype = Tween.EASE_IN_OUT
								Token.TokenType.OUT_IN:
									tweentype = Tween.EASE_OUT_IN
							create_tween().tween_property(node.get_node(runscript.data[line].data[1].value),runscript.data[line].data[2].value,runscript.data[line].data[3].value,runscript.data[line].data[4].value).set_ease(tweentype).set_trans(Tween.TRANS_CUBIC)
						else:
							push_error("line "+str(line+1)+": You must use a valid ease type")
							continue
				Token.TokenType.CREATE_SPRITE:
					if runscript.data[line].data.size() != 5:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						var variable = getVariable(i.lexeme)
						if i.type == Token.TokenType.IDENTIFIER and variable:
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Sprite name must be a string")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Sprite path must be a string")
						continue
					if !Loader.load_file("Sprites/"+runscript.data[line].data[2].value):
						push_error("line "+str(line+1)+": Sprite path must lead to a valid image file (Path: "+"Sprites/"+runscript.data[line].data[2].value+")")
						continue
					if runscript.data[line].data[3].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Sprite X position must be a number")
						continue
					if runscript.data[line].data[4].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Sprite Y position must be a number")
						continue
					var sprite = Sprite2D.new()
					sprite.name = runscript.data[line].data[1].value
					sprite.texture = Loader.load_file("Sprites/"+runscript.data[line].data[2].value)
					sprite.position = Vector2(runscript.data[line].data[3].value,runscript.data[line].data[4].value)
					node.add_child(sprite)
				Token.TokenType.SIN:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == Token.TokenType.TYPE_NUM:
								if runscript.data[line].data[2].type == Token.TokenType.NUMBER:
									if runscript.data[line].data[3].type == Token.TokenType.NUMBER:
										variable.value = sin(Undermaker.timer*runscript.data[line].data[2].value)*runscript.data[line].data[3].value
									else:
										push_error("line "+str(line+1)+": Multiplier must be a num!")
								else:
									push_error("line "+str(line+1)+": Time scale must be a num!")
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for sin")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for sin")
				Token.TokenType.COS:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == Token.TokenType.TYPE_NUM:
								if runscript.data[line].data[2].type == Token.TokenType.TYPE_NUM:
									if runscript.data[line].data[2].type == Token.TokenType.TYPE_NUM:
										variable.value = cos(Undermaker.timer*runscript.data[line].data[2].value)*runscript.data[line].data[3].value
									else:
										push_error("line "+str(line+1)+": Multiplier must be a num!")
								else:
									push_error("line "+str(line+1)+": Time scale must be a num!")
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for cos")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for cos")
				Token.TokenType.CREATE_ANIMATED_SPRITE:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Sprite name must be a string")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Sprite X position must be a number")
						continue
					if runscript.data[line].data[3].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Sprite Y position must be a number")
						continue
					var sprite = AnimatedSprite2D.new()
					sprite.sprite_frames = SpriteFrames.new()
					sprite.name = runscript.data[line].data[1].value
					sprite.position = Vector2(runscript.data[line].data[2].value,runscript.data[line].data[3].value)
					node.add_child(sprite)
				Token.TokenType.ADD_SPRITE_FRAME:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Sprite path must be a string")
						continue
					if !Loader.load_file("Sprites/"+runscript.data[line].data[2].value):
						push_error("line "+str(line+1)+": Sprite path must lead to a valid image file (Path: "+"Sprites/"+runscript.data[line].data[2].value+")")
						continue
					node.get_node(runscript.data[line].data[1].value).sprite_frames.add_frame("default",Loader.load_file("Sprites/"+runscript.data[line].data[2].value))
				Token.TokenType.PLAY_ANIMATED_SPRITE:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if node.get_node(runscript.data[line].data[1].value) is AnimatedSprite2D:
						node.get_node(runscript.data[line].data[1].value).play()
					else:
						push_error("line "+str(line+1)+": Target node must be an animatedsprite")
						continue
				Token.TokenType.STOP_ANIMATED_SPRITE:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if node.get_node(runscript.data[line].data[1].value) is AnimatedSprite2D:
						node.get_node(runscript.data[line].data[1].value).stop()
					else:
						push_error("line "+str(line+1)+": Target node must be an animatedsprite")
						continue
				Token.TokenType.REPARENT_TO_ROOT:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					node.get_node(runscript.data[line].data[1].value).reparent(get_tree().current_scene)
				Token.TokenType.SEND_PROPERTY:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.IDENTIFIER:
						push_error("line "+str(line+1)+": Variable name must be an identifier")
						continue
					if !getVariable(runscript.data[line].data[1].lexeme):
						push_error("line "+str(line+1)+": Variable must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[2].value) and runscript.data[line].data[2].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if runscript.data[line].data[3].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node property must be a string")
						continue
					var variable = getVariable(runscript.data[line].data[1].lexeme)
					var value
					if runscript.data[line].data[2].value == "self":
						value = node.get(runscript.data[line].data[3].value)
					else:
						value = node.get_node(runscript.data[line].data[2].value).get(runscript.data[line].data[3].value)
					variable.value = value
				Token.TokenType.SEND_X:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.IDENTIFIER:
						push_error("line "+str(line+1)+": Variable name must be an identifier")
						continue
					if !getVariable(runscript.data[line].data[1].lexeme):
						push_error("line "+str(line+1)+": Variable must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[2].value) and runscript.data[line].data[2].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					var variable = getVariable(runscript.data[line].data[1].lexeme)
					variable.value = node.get_node(runscript.data[line].data[2].value).position.x
				Token.TokenType.SEND_Y:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.IDENTIFIER:
						push_error("line "+str(line+1)+": Variable name must be an identifier")
						continue
					if !getVariable(runscript.data[line].data[1].lexeme):
						push_error("line "+str(line+1)+": Variable must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[2].value) and runscript.data[line].data[2].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					var variable = getVariable(runscript.data[line].data[1].lexeme)
					variable.value = node.get_node(runscript.data[line].data[2].value).position.y
				Token.TokenType.MATH:
					var j = -1
					for i in runscript.data[line].data:
						j += 1
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme) and j != 1:
							var variabl = getVariable(i.lexeme)
							i.type = types[variabl.type]
							i.value = variabl.value
							reset = true
					if runscript.data[line].data.size() != 5:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.IDENTIFIER:
						push_error("line "+str(line+1)+": Output variable name must be an identifier")
						continue
					if !getVariable(runscript.data[line].data[1].lexeme):
						push_error("line "+str(line+1)+": Output variable must exist")
						continue
					if !operators.has(runscript.data[line].data[3].type):
						push_error("line "+str(line+1)+": Must use a valid operator")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": First number must be a number")
						continue
					if runscript.data[line].data[4].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Second number must be a number")
						continue
					var variable = getVariable(runscript.data[line].data[1].lexeme)
					match runscript.data[line].data[3].type:
						Token.TokenType.PLUS:
							variable.value = runscript.data[line].data[2].value + runscript.data[line].data[4].value
						Token.TokenType.MINUS:
							variable.value = runscript.data[line].data[2].value - runscript.data[line].data[4].value
						Token.TokenType.STAR:
							variable.value = runscript.data[line].data[2].value * runscript.data[line].data[4].value
						Token.TokenType.SLASH:
							variable.value = runscript.data[line].data[2].value / runscript.data[line].data[4].value
				Token.TokenType.PROCESS_FRAME:
					await get_tree().process_frame
				Token.TokenType.RAND:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						var variable = getVariable(runscript.data[line].data[1].lexeme)
						if variable:
							if variable.type == Token.TokenType.TYPE_NUM:
								if runscript.data[line].data[2].type == Token.TokenType.NUMBER:
									if runscript.data[line].data[3].type == Token.TokenType.NUMBER:
										variable.value = randi_range(runscript.data[line].data[2].value,runscript.data[line].data[3].value)
									else:
										push_error("line "+str(line+1)+": Maximum value must be a num!")
								else:
									push_error("line "+str(line+1)+": Minimum value must be a num!")
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for sin")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for sin")
				Token.TokenType.CREATE_OBJECT:
					if runscript.data[line].data.size() != 5:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Object name must be a string")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Object type must be a string")
						continue
					if !ClassDB.class_exists(runscript.data[line].data[2].value) or !ClassDB.can_instantiate(runscript.data[line].data[2].value):
						push_error("line "+str(line+1)+": Object type must be a valid class, check the Godot documentation")
						continue
					if runscript.data[line].data[3].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Object X position must be a number")
						continue
					if runscript.data[line].data[4].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": Object Y position must be a number")
						continue
					var obj = ClassDB.instantiate(runscript.data[line].data[2].value)
					obj.name = runscript.data[line].data[1].value
					obj.position = Vector2(runscript.data[line].data[3].value,runscript.data[line].data[4].value)
					node.add_child(obj)
				Token.TokenType.SET_SPRITE:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if !node.get_node(runscript.data[line].data[1].value) is Sprite2D:
						push_error("line "+str(line+1)+": Target node must be a sprite")
						continue
					if !Loader.load_file("Sprites/"+runscript.data[line].data[2].value):
						push_error("line "+str(line+1)+": Sprite path must lead to a valid image file (Path: "+"Sprites/"+runscript.data[line].data[2].value+")")
						continue
					var sprite = node.get_node(runscript.data[line].data[1].value)
					sprite.texture = Loader.load_file("Sprites/"+runscript.data[line].data[2].value)
				Token.TokenType.GIVE_ITEM:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Item name must be a string")
						continue
					var item = Item.LoadItemFromFile(runscript.data[line].data[1].value)
					if item:
						PlayerData.inventory.append(item)
					else:
						push_error("line "+str(line+1)+": Item does not exist")
				Token.TokenType.REPARENT:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Target node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value) and runscript.data[line].data[1].value != "self":
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if runscript.data[line].data[2].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Parent node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[2].value) and runscript.data[line].data[2].value != "self":
						push_error("line "+str(line+1)+": Parent node must exist")
						continue
					node.get_node(runscript.data[line].data[1].value).reparent(node.get_node(runscript.data[line].data[2].value))
				Token.TokenType.SET_AUDIO:
					if runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if !node.get_node(runscript.data[line].data[1].value) is AudioStreamPlayer:
						push_error("line "+str(line+1)+": Target node must be a audio player")
						continue
					if !Loader.load_file("Audio/BGM/"+runscript.data[line].data[2].value):
						push_error("line "+str(line+1)+": Audio path must lead to a valid image file (Path: "+"Audio/BGM/"+runscript.data[line].data[2].value+")")
						continue
					var audiuo = node.get_node(runscript.data[line].data[1].value)
					audiuo.stream = Loader.load_file("Audio/BGM/"+runscript.data[line].data[2].value)
				Token.TokenType.STOP_AUDIO:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if !node.get_node(runscript.data[line].data[1].value) is AudioStreamPlayer:
						push_error("line "+str(line+1)+": Target node must be a audio player")
						continue
					var audiuo = node.get_node(runscript.data[line].data[1].value)
					audiuo.stop()
				Token.TokenType.PLAY_AUDIO:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if !node.get_node(runscript.data[line].data[1].value) is AudioStreamPlayer:
						push_error("line "+str(line+1)+": Target node must be a audio player")
						continue
					var audiuo = node.get_node(runscript.data[line].data[1].value)
					audiuo.play()
				Token.TokenType.SET_VARIABLE:
					if runscript.data[line].data.size() != 4:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variabl = getVariable(i.lexeme)
							i.type = types[variabl.type]
							i.value = variabl.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Node name must be a string")
						continue
					if !node.get_node_or_null(runscript.data[line].data[1].value+"/ScriptRunner"):
						push_error("line "+str(line+1)+": Target node must exist")
						continue
					if !node.get_node(runscript.data[line].data[1].value+"/ScriptRunner") is ScriptRunner:
						push_error("line "+str(line+1)+": Target node must have a script runner as a child")
						continue
					print(runscript.data[line].data[2].value)
					var variable = node.get_node(runscript.data[line].data[1].value+"/ScriptRunner").getVariable(runscript.data[line].data[2].value)
					if variable:
						if variable.type == types[runscript.data[line].data[3].type]:
							variable.value = runscript.data[line].data[3].value
						else:
							push_error("line "+str(line+1)+": Variable set type does not match!")
					else:
						print(variable)
						push_error("line "+str(line+1)+": Variable must exist")
				Token.TokenType.WAIT_FRAMES:
					if runscript.data[line].data.size() != 2:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": You must input a valid number")
						continue
					for i in range(runscript.data[line].data[1].value):
						await get_tree().process_frame
				Token.TokenType.START_ENCOUNTER:
					if runscript.data[line].data.size() != 2 and runscript.data[line].data.size() != 3:
						push_error("line "+str(line+1)+": Invalid number of arguments")
						continue
					for i in runscript.data[line].data:
						if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
							var variable = getVariable(i.lexeme)
							i.type = types[variable.type]
							i.value = variable.value
							reset = true
					if runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": Encounter name must be a string")
						continue
					if runscript.data[line].data[2].size == 3:
						if runscript.data[line].data[2].type != Token.TokenType.BOOLEAN:
							push_error("line "+str(line+1)+": Transition or not must be a boolean")
							continue
						Battle.Encounter(runscript.data[line].data[1].value,runscript.data[line].data[2].value)
					else:
						Battle.Encounter(runscript.data[line].data[1].value)
				_:
					await unhandled_function(runscript.data[line])
		if reset:
			runscript = ogrunscript
	await get_tree().process_frame
	script_finished.emit()
	return OK

func unhandled_function(line : TokenArray):
	print(line.data[0].lexeme)
