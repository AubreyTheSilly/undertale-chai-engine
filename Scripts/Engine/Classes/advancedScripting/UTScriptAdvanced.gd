extends Node

enum VariableType {
	STRING,NUMBER,BOOL,UNDEFINED,ARRAY,COLOR,VECTOR,STRUCT,NODE
}

var variableTypes := {
	"STRING":VariableType.STRING,
	"NUMBER":VariableType.NUMBER,
	"BOOL":VariableType.BOOL,
	"UNDEFINED":VariableType.UNDEFINED,
	"ARRAY":VariableType.ARRAY,
	"COLOR":VariableType.COLOR,
	"VECTOR2":VariableType.VECTOR,
	"STRUCT":VariableType.STRUCT,
	"NODE":VariableType.NODE
}

class Variable:
	var name : String
	var type : VariableType
	var value : Variant
	
	func _init(n:String,t:VariableType,v:Variant=null):
		name=n
		type=t
		value=v

var variables : Dictionary[String,Dictionary] = {}
var global_variables : Dictionary[String,Variable] = {}

var l := 0
var t := 0
var total_l := 0
var node : Node

var dt := 0.0
var dt_changed := false

var should_continue_block := false
var should_continue_while := false
var should_break := false

var end_script := false

func initConstants() -> void:
	if !variables.has(str(node.get_instance_id())):
		variables[str(node.get_instance_id())] = {}
	
	# timer stuff
	global_variables["TIMER"] = Variable.new("TIMER",VariableType.NUMBER,0.0)
	global_variables["DELTA"] = Variable.new("DELTA",VariableType.NUMBER,dt)
	
	# tween eases
	global_variables["EASE_IN"] = Variable.new("EASE_IN",VariableType.NUMBER,0.0)
	global_variables["EASE_OUT"] = Variable.new("EASE_OUT",VariableType.NUMBER,1.0)
	global_variables["EASE_IN_OUT"] = Variable.new("EASE_IN_OUT",VariableType.NUMBER,2.0)
	global_variables["EASE_OUT_IN"] = Variable.new("EASE_OUT_IN",VariableType.NUMBER,3.0)
	# tween transitions
	global_variables["TRANS_LINEAR"] = Variable.new("TRANS_LINEAR",VariableType.NUMBER,0.0)
	global_variables["TRANS_SINE"] = Variable.new("TRANS_SINE",VariableType.NUMBER,1.0)
	global_variables["TRANS_QUINT"] = Variable.new("TRANS_QUINT",VariableType.NUMBER,2.0)
	global_variables["TRANS_QUART"] = Variable.new("TRANS_QUART",VariableType.NUMBER,3.0)
	global_variables["TRANS_QUAD"] = Variable.new("TRANS_QUAD",VariableType.NUMBER,4.0)
	global_variables["TRANS_EXPO"] = Variable.new("TRANS_EXPO",VariableType.NUMBER,5.0)
	global_variables["TRANS_ELASTIC"] = Variable.new("TRANS_ELASTIC",VariableType.NUMBER,6.0)
	global_variables["TRANS_CUBIC"] = Variable.new("TRANS_CUBIC",VariableType.NUMBER,7.0)
	global_variables["TRANS_CIRC"] = Variable.new("TRANS_CIRC",VariableType.NUMBER,8.0)
	global_variables["TRANS_BOUNCE"] = Variable.new("TRANS_BOUNCE",VariableType.NUMBER,9.0)
	global_variables["TRANS_BACK"] = Variable.new("TRANS_BACK",VariableType.NUMBER,10.0)
	global_variables["TRANS_SPRING"] = Variable.new("TRANS_SPRING",VariableType.NUMBER,11.0)
	
	# direction constants
	global_variables["DIR_LEFT"] = Variable.new("DIR_LEFT",VariableType.VECTOR,Vector2.LEFT)
	global_variables["DIR_DOWN"] = Variable.new("DIR_DOWN",VariableType.VECTOR,Vector2.DOWN)
	global_variables["DIR_UP"] = Variable.new("DIR_UP",VariableType.VECTOR,Vector2.UP)
	global_variables["DIR_RIGHT"] = Variable.new("DIR_RIGHT",VariableType.VECTOR,Vector2.RIGHT)
	
	# color constants (THESE ARE ALL FROM GAMEMAKER!!!!
	global_variables["C_AQUA"] = Variable.new("C_AQUA",VariableType.COLOR,Color.from_rgba8(0,255,255))
	global_variables["C_BLACK"] = Variable.new("C_BLACK",VariableType.COLOR,Color.from_rgba8(0,0,0))
	global_variables["C_BLUE"] = Variable.new("C_BLUE",VariableType.COLOR,Color.from_rgba8(0,0,255))
	global_variables["C_DARKGRAY"] = Variable.new("C_DARKGRAY",VariableType.COLOR,Color.from_rgba8(64,64,64))
	global_variables["C_FUCHSIA"] = Variable.new("C_FUCHSIA",VariableType.COLOR,Color.from_rgba8(255,0,255))
	global_variables["C_GRAY"] = Variable.new("C_GRAY",VariableType.COLOR,Color.from_rgba8(128,128,128))
	global_variables["C_GREEN"] = Variable.new("C_GREEN",VariableType.COLOR,Color.from_rgba8(0,128,0))
	global_variables["C_LIME"] = Variable.new("C_LIME",VariableType.COLOR,Color.from_rgba8(0,255,0))
	global_variables["C_LIGHTGRAY"] = Variable.new("C_LIGHTGRAY",VariableType.COLOR,Color.from_rgba8(192,192,192))
	global_variables["C_MAROON"] = Variable.new("C_MAROON",VariableType.COLOR,Color.from_rgba8(128,0,0))
	global_variables["C_NAVY"] = Variable.new("C_NAVY",VariableType.COLOR,Color.from_rgba8(0,0,128))
	global_variables["C_OLIVE"] = Variable.new("C_OLIVE",VariableType.COLOR,Color.from_rgba8(128,128,0))
	global_variables["C_ORANGE"] = Variable.new("C_ORANGE",VariableType.COLOR,Color.from_rgba8(255,160,64))
	global_variables["C_PURPLE"] = Variable.new("C_PURPLE",VariableType.COLOR,Color.from_rgba8(128,0,128))
	global_variables["C_RED"] = Variable.new("C_RED",VariableType.COLOR,Color.from_rgba8(255,0,0))
	global_variables["C_SILVER"] = Variable.new("C_SILVER",VariableType.COLOR,Color.from_rgba8(192,192,192))
	global_variables["C_TEAL"] = Variable.new("C_TEAL",VariableType.COLOR,Color.from_rgba8(0,128,128))
	global_variables["C_WHITE"] = Variable.new("C_WHITE",VariableType.COLOR,Color.from_rgba8(255,255,255))
	global_variables["C_YELLOW"] = Variable.new("C_YELLOW",VariableType.COLOR,Color.from_rgba8(255,255,0))
	
	# self
	variables[str(node.get_instance_id())]["self"] = Variable.new("self",VariableType.NODE,node)

func updateConstants() -> void:
	# update timers
	if dt_changed:
		global_variables["TIMER"].value += dt
		global_variables["DELTA"].value = dt
		dt_changed = false

func loadScriptFromFile(script : String) -> Array:
	var scr := Undermaker.loadFileAsString("Scripts/"+script+".utscript")
	var lexer = Lexer.new()
	return lexer.parse(lexer.tokenize(scr))

func runScript(script : Array,_node : Node,reinit_vars:=true) -> Error:
	node = _node
	if reinit_vars:
		initConstants()
		total_l = 0
	l = 0
	t = 0
	while l < script.size() and !end_script:
		if !is_instance_valid(node):
			return ERR_DOES_NOT_EXIST
		total_l += 1
		updateConstants()
		t = 0
		while t < script[l].size() and !end_script:
			if !is_instance_valid(node):
				return ERR_DOES_NOT_EXIST
			var token = script[l][t]
			var next_token = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER)
			if t != script[l].size()-1:
				next_token = script[l][t+1]
			if token is Lexer.FunctionToken:
				#print(token.value)
				await executeFunction(script[l])
			elif token is Lexer.CodeToken:
				#var oldl = l
				#var oldt = t
				#await runScript(token.value,_node,false)
				#l = oldl
				#t = oldt
				await executeCodeBlock(token,_node)
			#elif token.type == Lexer.TokenType.COMMENT:
				#total_l += 1
			elif token.value:
				if _get_variable(str(token.value)) and t < script[l].size()-2:
					var variable = _get_variable(token.value)
					match next_token.type:
						Lexer.TokenType.EQUALS:
							# handle loading the value if it's a function lol
							var vars = await _convert_variables([script[l][t+2]])
							#script[l][t+2] = vars[0]
							
							# handle setting the variable
							if variable.type == VariableType.STRING and vars[0].value is String:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.NUMBER and vars[0].value is float:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.BOOL and vars[0].value is bool:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.ARRAY and vars[0].value is Array:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.VECTOR and vars[0].value is Vector2:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.COLOR and vars[0].value is Color:
								_set_variable(token.value,vars[0].value)
							elif variable.type == VariableType.NODE and vars[0].value is Node:
								_set_variable(token.value,vars[0].value)
							elif type_string(typeof(variable.value)) == type_string(typeof(vars[0].value)):
								_set_variable(token.value,vars[0].value)
							else:
								push_error('Line '+str(total_l+1)+': Type of variable '+str(token.value)+" ("+str(_get_variable(token.value).value)+" : "+type_string(typeof(_get_variable(token.value).value))+') does not match with target value\'s type ('+str(script[l][t+2].value)+' : '+type_string(typeof(vars[0].value))+")")
							t += 2
						Lexer.TokenType.ARITHMETIC_OPERATOR:
							# handle loading the value if it's a function lol
							var vars = await _convert_variables([script[l][t+2]])
							#print(script[l][t+2].value)
							#print(vars[0].value)
							
							#print(vars[0].value)
							
							var change = 0.0
							change = vars[0].value
							var result = _get_variable(token.value).value
							if (result is float and change is float) or (result is Vector2 and change is Vector2) or (result is Vector2 and change is float):
								match next_token.value:
									"-=":
										result -= change
									"*=":
										result *= change
									"/=":
										result /= change
									"+=":
										result += change
							elif next_token.value == "+=" and change is String and result is String:
								result += change
							
							# handle setting the variable
							if variable.type == VariableType.STRING and vars[0].value is String:
								if next_token.value == "-=":
									push_error('Line '+str(total_l+1)+': Subtraction operation cannot be performed on a string')
								else:
									_set_variable(token.value,result)
							elif variable.type == VariableType.NUMBER and change is float:
								#print("setting ",token.value," to ",result)
								_set_variable(token.value,result)
							elif variable.type == VariableType.VECTOR and change is Vector2:
								_set_variable(token.value,result)
							elif variable.type == VariableType.VECTOR and change is float:
								_set_variable(token.value,result)
							elif variable.type == VariableType.BOOL and vars[0] is bool:
								push_error('Line '+str(total_l+1)+': Booleans cannot have arithmetic performed on them')
							elif variable.type == VariableType.ARRAY and vars[0] is Array:
								push_error('Line '+str(total_l+1)+': Arrays cannot have arithmetic performed on them')
							else:
								push_error('Line '+str(total_l+1)+': Type of variable '+str(token.value)+" ("+str(_get_variable(token.value).value)+" : "+type_string(typeof(_get_variable(token.value).value))+') does not match with target value\'s type ('+str(change)+' : '+type_string(typeof(change))+")")
							t += 2
				else:
					match token.value:
						"await":
							#print("performing await")
							if next_token is Lexer.FunctionToken:
								await executeFunction([next_token],true)
								t += 1
							elif next_token.type == Lexer.TokenType.IDENTIFIER:
								match next_token.value:
									"process_frame":
										await get_tree().process_frame
										t += 1
									_:
										if node.get_indexed(next_token.value) is Signal:
											await node.get_indexed(next_token.value)
											t += 1
						"else":
							if next_token is Lexer.CodeToken and !should_continue_block:
								await executeCodeBlock(next_token,node)
							t += 1
						"break":
							if should_continue_while:
								should_continue_while = false
					
			t += 1
		l += 1
	end_script = false
	
	return OK

func _get_variable(variable:String,verbose:=false):
	if variables.has(str(node.get_instance_id())):
		if variables[str(node.get_instance_id())].has(variable):
			return variables[str(node.get_instance_id())][variable]
		elif global_variables.has(variable):
			return global_variables[variable]
	elif global_variables.has(variable):
		return global_variables[variable]
	if verbose:
		push_warning("Variable \""+variable+"\" does not exist, returning null")
	return

func _set_variable(variable:String,value:Variant):
	if variables.has(str(node.get_instance_id())):
		if variables[str(node.get_instance_id())].has(variable):
			variables[str(node.get_instance_id())][variable].value = value
	elif global_variables.has(variable):
		global_variables[variable].value = value
	else:
		push_error("Variable \""+variable+"\" does not exist")

func _convert_variables(parameters : Array,exceptions : Array = [],verbose:=false) -> Array:
	var param = []
	for i in parameters:
		if i is Lexer.AdvancedToken:
			param.append(i.duplicate())
		else:
			param.append(i)
	var index = 0
	
	while index < param.size():
		if param[index] is not Lexer.AdvancedToken:
			print("default value (index:"+str(index)+")")
			index += 1
			continue
		#print(param[index].value," ",param[index] is Lexer.FunctionToken)
		if _get_variable(str(param[index].value),verbose) and param[index].type == Lexer.TokenType.IDENTIFIER and !exceptions.has(index):
			#print("yeah")
			param[index].value = _get_variable(str(param[index].value)).value
			#print(type_string(typeof(param[index].value)))
			match type_string(typeof(param[index].value)):
				"String":
					param[index].type = Lexer.TokenType.STRING
				"float":
					param[index].type = Lexer.TokenType.NUMBER
				"bool":
					param[index].type = Lexer.TokenType.BOOLEAN
				"Array":
					param[index].type = Lexer.TokenType.ARRAY
				"Vector2":
					param[index].type = Lexer.TokenType.VECTOR
				"Color":
					param[index].type = Lexer.TokenType.COLOR
				_:
					if param[index].value is SpriteFrames:
						param[index].type = Lexer.TokenType.SPRITEFRAMES
					elif param[index].value is Node:
						param[index].type = Lexer.TokenType.NODE
		elif param[index] is Lexer.FunctionToken and !exceptions.has(index):
			#print("function variable ",param[index].value)
			var val = await executeFunction([param[index]])
			param[index] = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER,val)
			#print(type_string(typeof(param[index].value)))
			match type_string(typeof(param[index].value)):
				"String":
					param[index].type = Lexer.TokenType.STRING
				"float":
					param[index].type = Lexer.TokenType.NUMBER
				"bool":
					param[index].type = Lexer.TokenType.BOOLEAN
				"Array":
					param[index].type = Lexer.TokenType.ARRAY
				"Vector2":
					param[index].type = Lexer.TokenType.VECTOR
				"Color":
					param[index].type = Lexer.TokenType.COLOR
				# for object classes like nodes
				_:
					if param[index].value is SpriteFrames:
						param[index].type = Lexer.TokenType.SPRITEFRAMES
					elif param[index].value is Node:
						param[index].type = Lexer.TokenType.NODE
		elif param[index].type == Lexer.TokenType.STRING:
			var targettext := ""
			var ignore := false
			var variable_ing := false
			var variablename := ""
			for i : String in param[index].value:
				if ignore:
					targettext += i
					ignore = false
					continue
				
				if i == "\\":
					ignore = true
				elif i == "{":
					variable_ing = true
					variablename = ""
				elif i == "}" and variable_ing:
					var varible = _get_variable(variablename)
					if varible:
						targettext += str(varible.value)
					else:
						targettext += "[null]"
					variable_ing = false
				elif variable_ing:
					variablename += i
				else:
					targettext += i
			param[index].value = targettext
		if param[index].type == Lexer.TokenType.ARRAY:
			# print(param[index].value)
			var has_tokens := false
			for i in param[index].value:
				if i is Lexer.AdvancedToken:
					has_tokens = true
			if has_tokens:
				param[index].value = await _convert_variables(param[index].value)
		index += 1
	return param

func executeFunction(line : Array,wait := false):
	updateConstants()
	var token = line[t]
	match token.value:
		"print":
			if token.params.size() == 0:
				push_error('Line '+str(total_l+1)+': print() requires at least one parameter')
			else:
				var params = await _convert_variables(token.params)
				var output := ""
				for i : Lexer.AdvancedToken in params:
					output += str(i.value)
				print(output)
		"initvar":
			if token.params.size() != 2 and token.params.size() != 3:
				#for i in token.params:
					#print(i.value)
				push_error('Line '+str(total_l+1)+': initvar() requires between two and three parameters')
				return
			var params = await _convert_variables(token.params,[0,1])
			
			if params[0].type != Lexer.TokenType.IDENTIFIER:
				push_error('Line '+str(total_l+1)+': Variable name requires at least one parameter')
				return
			
			var variab = Variable.new(params[0].value,variableTypes[params[1].value])
			if params.size() == 3:
				variab.value = params[2].value
			if variables.has(params[0].value):
				push_warning('Line '+str(total_l+1)+': Variable '+params[0].value+' is already defined and will be overwritten')
			
			variables[str(node.get_instance_id())][params[0].value] = variab
		"initglobal":
			if token.params.size() != 2 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': initglobal() requires between two and three parameters')
				return
			var params = await _convert_variables(token.params,[0,1])
			
			if params[0].type != Lexer.TokenType.IDENTIFIER:
				push_error('Line '+str(total_l+1)+': Variable name requires at least one parameter')
				return
			
			var variab = Variable.new(params[0].value,variableTypes[params[1].value])
			if params.size() == 3:
				variab.value = params[2].value
			if global_variables.has(params[0].value):
				push_warning('Line '+str(total_l+1)+': Variable '+params[0].value+' is already defined and will be overwritten')
			
			variables[str(node.get_instance_id())][params[0].value] = variab
		"startDialogue":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': startDialogue() requires between one and two parameters')
				return
			
			if token.params[0].type != Lexer.TokenType.ARRAY:
				push_error('Line '+str(total_l+1)+': Dialogue must be an array')
				return
			var down = 1
			if token.params.size() == 2:
				if token.params[1].type != Lexer.TokenType.BOOLEAN:
					push_error('Line '+str(total_l+1)+': Dialogue positioning must be a bool')
					return
				down = int(token.params[1].value)
			
			DialogueHandler.StartDialogue(token.params[0].value,down)
			if wait:
				await DialogueHandler.dialogue_finished
		"set":
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': set() requires three parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Target node must be a Node')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Target node property must be a string')
				return
			var target : Node = params[0].value
			var propertylist := []
			for i in target.get_property_list():
				propertylist.append(i["name"])
			if !propertylist.has(params[1].value):
				push_error('Line '+str(total_l+1)+': Target node does not have property "'+str(params[1].value)+'"')
				return
			# print("setting ",target.name,"'s property ",params[1].value," to ",params[2].value)
			target.set_indexed(params[1].value,params[2].value)
		"tween_property":
			if token.params.size() < 4 and token.params.size() > 6:
				push_error('Line '+str(total_l+1)+': tween_property() requires between four and five parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Target node name must be a string')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Target node property must be a string')
				return
			var target : Node = params[0].value
			if target.get_indexed(params[1].value) == null:
				push_error('Line '+str(total_l+1)+': Target node property must exist')
				return
			if params[3].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Tween time must be a number')
				return
			
			var easing := Tween.EASE_IN_OUT
			if params.size() >= 6:
				if params[5].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Tween ease must be a valid number or ease constant')
					return
				easing = [Tween.EASE_IN,Tween.EASE_OUT,Tween.EASE_IN_OUT,Tween.EASE_OUT_IN][params[5].value]
			#print(easing)
			var trans := Tween.TRANS_LINEAR
			if params.size() >= 5:
				if params[4].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Tween transition must be a valid number or transition constant')
					return
				trans = [Tween.TRANS_LINEAR,Tween.TRANS_SINE,Tween.TRANS_QUINT,Tween.TRANS_QUART,Tween.TRANS_QUAD,Tween.TRANS_EXPO,Tween.TRANS_ELASTIC,Tween.TRANS_CUBIC,Tween.TRANS_CIRC,Tween.TRANS_BOUNCE,Tween.TRANS_BACK,Tween.TRANS_SPRING][params[4].value]
			if wait:
				await create_tween().tween_property(target,params[1].value,params[2].value,params[3].value).set_ease(easing).set_trans(trans).finished
			else:
				create_tween().tween_property(target,params[1].value,params[2].value,params[3].value).set_ease(easing).set_trans(trans)
		"get":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': get() requires two parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Target node must be a Node')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Target node property must be a string')
				return
			var target : Node = params[0].value
			if target.get_indexed(params[1].value) == null:
				push_error('Line '+str(total_l+1)+': Target node property must exist')
				return
			
			return target.get_indexed(params[1].value)
		"sin":
			if token.params.size() <= 0 and token.params.size() >= 3:
				push_error('Line '+str(total_l+1)+': sin() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Angle must be a number')
				return
			var output = sin(params[0].value)
			if token.params.size() == 2:
				if params[1].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Output multiplier must be a number')
					return
				output *= params[1].value
			
			return output
		"cos":
			if token.params.size() <= 0 and token.params.size() >= 3:
				push_error('Line '+str(total_l+1)+': cos() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Angle must be a number')
				return
			var output = cos(params[0].value)
			if token.params.size() == 2:
				if params[1].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Output multiplier must be a number')
					return
				output *= params[1].value
			
			return output
		"while":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': if requires exactly one or two parameters')
				return
			
			var ogparams = []
			for i in token.params:
				ogparams.append(i.duplicate())
			var params = []
			
			var ogline = total_l
			
			should_continue_while = true
			
			while should_continue_while:
				total_l = ogline
				params = []
				for i in ogparams:
					params.append(i.duplicate())
				
				params = await _convert_variables(params,[1])
			
				if params.size() == 1:
					# one parameter version
					should_continue_while = bool(params[0].value)
				else:
					# comparison version
					if params[1].type != Lexer.TokenType.OPERATOR:
						push_error('Line '+str(total_l+1)+': Invalid comparison operator')
						return
					match params[1].value:
						"<=":
							should_continue_while = params[0].value <= params[2].value
						">=":
							should_continue_while = params[0].value >= params[2].value
						"!=":
							should_continue_while = params[0].value != params[2].value
						"==":
							should_continue_while = params[0].value == params[2].value
						"<":
							should_continue_block = params[0].value < params[2].value
						">":
							should_continue_block = params[0].value > params[2].value
				
				if t >= line.size()-1:
					push_error('Line '+str(total_l+1)+': Code block expected for while')
					should_continue_while = false
					#return
				if line[t+1] is not Lexer.CodeToken:
					#print(Lexer.TokenType.keys()[line[t+1].type])
					#print(t+1)
					push_error('Line '+str(total_l+1)+': Code block expected for while')
					should_continue_while = false
					#return
				if should_continue_while:
					await executeCodeBlock(line[t+1],node)
				else:
					total_l += line[t+1].value.size()+1
			print("while loop ended")
			t += 1
		"if":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': if requires exactly one or two parameters')
				return
			
			var params = await _convert_variables(token.params,[1])
			#for i in params:
				#print(i.value)
			
			should_continue_block = true
			
			if params.size() == 1:
				# one parameter version
				if params[0].value is String:
					should_continue_block = params[0].value != ""
				elif params[0].value is float or params[0].value is bool:
					should_continue_block = bool(params[0].value)
				else:
					should_continue_block = params[0].value != null
			else:
				# comparison version
				if params[1].type != Lexer.TokenType.OPERATOR:
					push_error('Line '+str(total_l+1)+': Invalid comparison operator')
					return
				if params[0].value == null:
					push_error('Line '+str(total_l+1)+': Cannot compare nil (',str(params[0].value),' and ',(params[2].value),')')
					return
				if params[2].value == null:
					push_error('Line '+str(total_l+1)+': Cannot compare nil (',str(params[0].value),' and ',(params[2].value),')')
					return
				match params[1].value:
					"<=":
						should_continue_block = params[0].value <= params[2].value
					">=":
						should_continue_block = params[0].value >= params[2].value
					"!=":
						should_continue_block = params[0].value != params[2].value
					"==":
						should_continue_block = params[0].value == params[2].value
					"<":
						should_continue_block = params[0].value < params[2].value
					">":
						should_continue_block = params[0].value > params[2].value
			
			if t >= line.size()-1:
				push_error('Line '+str(total_l+1)+': Code block expected for if')
				return
			if line[t+1] is not Lexer.CodeToken:
				push_error('Line '+str(total_l+1)+': Code block expected for if')
				return
			
			if should_continue_block:
				await executeCodeBlock(line[t+1],node)
			else:
				total_l += line[t+1].value.size()+1
			
			t += 1
		"elif":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': if requires exactly one or two parameters')
				return
			
			if should_continue_block:
				return
			
			var params = await _convert_variables(token.params,[1])
			
			if token.params.size() == 1:
				# one parameter version
				should_continue_block = bool(params[0].value)
			else:
				# comparison
				if params[1].type != Lexer.TokenType.OPERATOR:
					push_error('Line '+str(total_l+1)+': Invalid comparison operator')
					return
				match params[1].value:
					"<=":
						should_continue_block = params[0].value <= params[2].value
					">=":
						should_continue_block = params[0].value >= params[2].value
					"!=":
						should_continue_block = params[0].value != params[2].value
					"==":
						should_continue_block = params[0].value == params[2].value
					"<":
						should_continue_block = params[0].value < params[2].value
					">":
						should_continue_block = params[0].value > params[2].value
			
			if t >= line.size()-1:
				push_error('Line '+str(total_l+1)+': Code block expected for elif')
				return
			if line[t+1] is not Lexer.CodeToken:
				push_error('Line '+str(total_l+1)+': Code block expected for elif')
				return
			
			if should_continue_block:
				await executeCodeBlock(line[t+1],node)
			else:
				total_l += line[t+1].value.size()+1
			
			t += 1
		"wait":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': wait() requires exactly one or two parameters')
				return
			if token.params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Amount of seconds for wait() must be a number')
				return
			
			await get_tree().create_timer(token.params[0].value).timeout
		"wait_frames":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': wait_frames() requires exactly one parameter')
				return
			if token.params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Amount of seconds for wait_frames() must be a number')
				return
			
			for i in range(token.params[0].value):
				await get_tree().process_frame
		"randi":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': randi() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Minimum value for randi() must be a number')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Maximum value for randi() must be a number')
				return
			
			return float(randi_range(roundi(params[0].value),roundi(params[1].value)))
		"randf":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': randf() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Minimum value for randf() must be a number')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Maximum value for randf() must be a number')
				return
			
			return randf_range(params[0].value,params[1].value)
		"round":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': round() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Input for round() must be a number')
				return
			var step := 1.0
			if params.size() == 2:
				if params[1].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Step must be a number')
					return
				step = params[1].value
			
			return snapped(params[0].value,step)
		"is_key_pressed":
			#print("keypress check")
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': is_key_pressed() requires exactly one parameter')
				return
			if token.params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Key must be a string')
				return
			if OS.find_keycode_from_string(token.params[0].value) == KEY_NONE:
				push_error("line "+str(total_l+1)+": Invalid keycode")
				return
			return Input.is_key_pressed(OS.find_keycode_from_string(token.params[0].value))
			#return bool(randi_range(0,1))
		"increment":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': increment() requires exactly one parameter')
				return
			if token.params[0].type != Lexer.TokenType.IDENTIFIER:
				push_error('Line '+str(total_l+1)+': Target variable must be an identifier')
				return
			if !_get_variable(token.params[0].value):
				push_error('Line '+str(total_l+1)+': Target variable does not exist')
				return
			if _get_variable(token.params[0].value).type != VariableType.NUMBER:
				push_error('Line '+str(total_l+1)+': Target variable must be a number')
				return
			
			_set_variable(token.params[0].value,_get_variable(token.params[0].value).value+1)
		"decrement":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': decrement() requires exactly one parameter')
				return
			if token.params[0].type != Lexer.TokenType.IDENTIFIER:
				push_error('Line '+str(total_l+1)+': Target variable must be an identifier')
				return
			if !_get_variable(token.params[0].value):
				push_error('Line '+str(total_l+1)+': Target variable does not exist')
				return
			if _get_variable(token.params[0].value).type != VariableType.NUMBER:
				push_error('Line '+str(total_l+1)+': Target variable must be a number')
				return
			
			_set_variable(token.params[0].value,_get_variable(token.params[0].value).value-1)
		"expr":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': expr() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Expression must be a string')
				return
			var expr = Expression.new()
			var err = expr.parse(params[0].value)
			#print("Executing "+params[0].value)
			if err == OK:
				var result = expr.execute([],node)
				if not expr.has_execute_failed():
					#print(result)
					return result
				else:
					push_error('Line '+str(total_l+1)+': Execution of expr() failed')
			else:
				push_error('Line '+str(total_l+1)+': Invalid expression for expr()')
		"to_num":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': to_num() requires exactly one parameter')
				return
			if token.params[0].value is String:
				return token.params[0].to_float()
			elif token.params[0].value is bool:
				return 1.0*(int(token.params[0].value))
			elif token.params[0].value is float:
				return token.params[0].value
			else:
				push_error('Line '+str(total_l+1)+': to_num() requires a string, bool, or int')
		"to_str":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': to_str() requires exactly one parameter')
				return
			return str(token.params[0].value)
		"to_bool":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': to_str() requires exactly one parameter')
				return
			if token.params[0].value:
				return true
			else:
				return false
		"lerp":
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': lerp() requires exactly three parameters')
				return
			var params = await _convert_variables(token.params,[2])
			
			if params[2].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Weight must be a number')
				return
			
			return lerp(params[0].value,params[1].value,params[2].value)
		"vec2":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': vec2() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				#print(params[0].type)
				push_error('Line '+str(total_l+1)+': X must be a number')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Y must be a number')
				return
			
			return Vector2(params[0].value,params[1].value)
		"color":
			if token.params.size() != 3 and token.params.size() != 4:
				push_error('Line '+str(total_l+1)+': vec2() requires between three and four parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': R must be a number')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': G must be a number')
				return
			if params[2].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': B must be a number')
				return
			var a := 255
			if params.size() == 4:
				if params[3].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': A must be a number')
					return
				a = params[3].value
			
			return Color.from_rgba8(params[0].value,params[1].value,a)
		# temporarily removed functions. these were originally for like. vectors? but vectors don't have get and set_indexed. sooo
		#"getVariableProperty":
			#if token.params.size() != 2:
				#push_error('Line '+str(total_l+1)+': getVariableProperty() requires exactly two parameters')
				#return
			#
			#if token.params[0].type != Lexer.TokenType.IDENTIFIER:
				#push_error('Line '+str(total_l+1)+': Variable must be a valid identifier')
				#return
			#var variab = _get_variable(token.params[0].value)
			#if !variab:
				#push_error('Line '+str(total_l+1)+': Variable must exist')
				#return
			#
			#if token.params[1].type != Lexer.TokenType.STRING:
				#push_error('Line '+str(total_l+1)+': Variable property must be a string')
				#return
			#
			#return variab.value.get_indexed(token.params[1].value)
		#"setVariableProperty":
			#if token.params.size() != 3:
				#push_error('Line '+str(total_l+1)+': getVariableProperty() requires exactly two parameters')
				#return
			#
			#var params = await _convert_variables([token.params[2]])
			#
			#if token.params[0].type != Lexer.TokenType.IDENTIFIER:
				#push_error('Line '+str(total_l+1)+': Variable must be a valid identifier')
				#return
			#var variab = _get_variable(token.params[0].value)
			#if !variab:
				#push_error('Line '+str(total_l+1)+': Variable must exist')
				#return
			#
			#if token.params[1].type != Lexer.TokenType.STRING:
				#push_error('Line '+str(total_l+1)+': Variable property must be a string')
				#return
			#
			#return variab.value.set_indexed(token.params[1].value,params[0])
		"get_at_index":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': get_at_index() requires exactly two parameters')
				return
			
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.ARRAY and params[0].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+': Object to get value from must be a valid array or vector')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Index must be a number')
				return
			var val = params[0].value[params[1].value]
			if val is Lexer.AdvancedToken:
				return val.value
			else:
				return val
		"set_at_index":
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': set_at_index() requires exactly two parameters')
				return
			
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.ARRAY:
				push_error('Line '+str(total_l+1)+': Array must be a valid array')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Array position must be a number')
				return
			
			params[0].value[params[1].value].value = params[2].value
			var variab = _get_variable(token.params[0].value)
			if variab:
				_set_variable(token.params[0].value,params[0].value)
			return params[0].value
		"createSprite":
			# using this code from the og scriptrunner as reference
			
			#var sprite = Sprite2D.new()
			#sprite.name = runscript.data[line].data[1].value
			#sprite.texture = Loader.load_file("Sprites/"+runscript.data[line].data[2].value)
			#sprite.position = Vector2(runscript.data[line].data[3].value,runscript.data[line].data[4].value)
			#node.add_child(sprite)
			
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': create_sprite() requires exactly three parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Sprite object name must be a string')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Sprite path must be a valid string')
				return
			if params[2].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+': Sprite position must be a vector')
				return
			
			var sprite := Sprite2D.new()
			sprite.name = params[0].value
			sprite.texture = Loader.load_file("Sprites/"+params[1].value+".png")
			sprite.position = params[2].value
			node.add_child(sprite)
		"createAnimatedSprite":
			if token.params.size() != 2 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': create_sprite() requires between two an three parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Sprite object name must be a string')
				return
			if params[1].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+': Sprite position must be a vector')
				return
			
			var sprite := AnimatedSprite2D.new()
			sprite.name = params[0].value
			sprite.position = params[1].value
			if params.size() == 3:
				if params[2].type != Lexer.TokenType.SPRITEFRAMES:
					push_error('Line '+str(total_l+1)+': Sprite animation must be a SpriteFrames')
					return
				sprite.sprite_frames = params[2].value
			node.add_child(sprite)
		"font":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': font() requires exactly one parameter')
				return
			var font = FontFile.new()
			font.load_dynamic_font(Undermaker.Path+"Fonts/"+token.params[0].value)
			
			if font:
				return font
			else:
				push_error('Line '+str(total_l+1)+': Font '+token.params[0].value+' does not exist')
				return
		"getAnimation":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': getAnimation() requires exactly one parameter')
				return
			
			if token.params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Animation json name must be a string')
				return
			
			return Undermaker.loadSpriteFramesFromFile(token.params[0].value)
		"stopAnimation":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': stopAnimation() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Node must be a Node type')
				return
			
			var sprite = params[0].value
			if sprite is not AnimatedSprite:
				push_error('Line '+str(total_l+1)+': Node is not an AnimationFrame')
				return
			
			sprite.stop()
		"playAnimation":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': playAnimation() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Sprite must be a node')
				return
			
			var sprite = params[0].value
			if sprite is not AnimatedSprite2D:
				push_error('Line '+str(total_l+1)+': Node is not an AnimatedSprite2D')
				return
			
			if params.size() == 2:
				if params[1].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Animation name must be a string')
					return
				if !sprite.sprite_frames.get_animation_names().has(params[1].value):
					push_error('Line '+str(total_l+1)+': Animation ',params[1].value,' does not exist')
					return
				sprite.play(params[1].value)
			else:
				sprite.play()
		"getNode":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': getNode() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params)
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Node name must be a string')
				return
			var obj = node.get_node_or_null(params[0].value)
			if !is_instance_valid(obj):
				push_error('Line '+str(total_l+1)+': Object ',params[0].value,' does not exist')
				return
			return obj
		"setBorder":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': setBorder() requires exactly one parameter')
				return
			if token.params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Border name must be a string')
				return
			Borders.set_border(token.params[0].value)
		"createNode":
			# original scriptrunner function reference
			#if runscript.data[line].data.size() != 5:
				#push_error("line "+str(line+1)+": Invalid number of arguments")
				#continue
			#for i in runscript.data[line].data:
				#if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
					#var variable = getVariable(i.lexeme)
					#i.type = types[variable.type]
					#i.value = variable.value
					#reset = true # (this caused lag so i moved it to only be in end) (WE MIGHT BE BRINGING THIS BACK IDFK
			#if runscript.data[line].data[1].type != Token.TokenType.STRING:
				#push_error("line "+str(line+1)+": Object name must be a string")
				#continue
			#if runscript.data[line].data[2].type != Token.TokenType.STRING:
				#push_error("line "+str(line+1)+": Object type must be a string")
				#continue
			#if !ClassDB.class_exists(runscript.data[line].data[2].value) or !ClassDB.can_instantiate(runscript.data[line].data[2].value):
				#push_error("line "+str(line+1)+": Object type must be a valid class, check the Godot documentation")
				#continue
			#if runscript.data[line].data[3].type != Token.TokenType.NUMBER:
				#push_error("line "+str(line+1)+": Object X position must be a number")
				#continue
			#if runscript.data[line].data[4].type != Token.TokenType.NUMBER:
				#push_error("line "+str(line+1)+": Object Y position must be a number")
				#continue
			#var obj = ClassDB.instantiate(runscript.data[line].data[2].value)
			#obj.name = runscript.data[line].data[1].value
			#obj.position = Vector2(runscript.data[line].data[3].value,runscript.data[line].data[4].value)
			#node.add_child(obj)
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': createNode() requires exactly three parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Node name must be a String')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Node type must be a String')
				return
			if !ClassDB.class_exists(params[1].value) or !ClassDB.can_instantiate(params[1].value):
				push_error('Line '+str(total_l+1)+": NOde type must be a valid Object subclass, check the Godot documentation")
				return
			if params[2].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+": Node position must be a Vector2")
				return
			var obj = ClassDB.instantiate(params[1].value)
			obj.name = params[0].value
			obj.position = params[2].value
			node.add_child(obj)
		"reparent":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': reparent() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params)
			
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Child node must be a Node')
				return
			if params[1].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Parent node must be a Node')
				return
			
			params[0].value.reparent(params[1].value)

func executeCodeBlock(codeblock : Lexer.CodeToken,_node:Node) -> void:
	# print("Started to execute code block")
	# print(l)
	var oldl = l
	var oldt = t
	await runScript(codeblock.value.duplicate(true),_node,false)
	l = oldl
	t = oldt
	# print("Finished executing code block")

func _process(_delta) -> void:
	dt = _delta
	dt_changed = true
