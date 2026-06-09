class_name AdvancedScriptRunner
extends Node

enum VariableType {
	STRING,NUMBER,BOOL,UNDEFINED,ARRAY,COLOR,VECTOR,STRUCT,NODE,AUDIO,TEXTURE,SIGNAL
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
	"NODE":VariableType.NODE,
	"AUDIO":VariableType.AUDIO,
	"TEXTURE":VariableType.TEXTURE,
	"SIGNAL":VariableType.SIGNAL
}

enum SCOPE_TYPE {
	SCRIPT,
	BLOCK,
	SINGLE,
	ATTACK,
	ENEMY
}

class Scope:
	var should_continue_block := false
	var should_continue_while := false
	var should_break := false
	var type : SCOPE_TYPE = SCOPE_TYPE.SCRIPT

class Variable:
	var name : String
	var type : VariableType
	var value : Variant
	
	func _init(n:String,t:VariableType,v:Variant=null):
		name=n
		type=t
		value=v

class CustomFunction:
	var code : Lexer.CodeToken
	func _init(Code : Lexer.CodeToken):
		code = Code

static var variables : Dictionary[String,Dictionary] = {}
static var global_variables : Dictionary[String,Variable] = {}
static var custom_functions : Dictionary[String,Dictionary] = {}
static var global_functions : Dictionary[String,CustomFunction] = {}

var l := 0
var t := 0
var total_l := 0
var node : Node

var dt := 0.0
var dt_changed := false

# once scope stuff is implemented hopefully these should like. become unnecessary but yeah
var should_continue_block := false
var should_continue_while := false
var should_break := false

var end_script := false
var is_running := false

var custom_constants := {}
var custom_variables := {}

signal script_ended

func runSingleFunction(function : String,args := []) -> void:
	initConstants()
	var oldt = t
	var functoken := Lexer.FunctionToken.new(Lexer.TokenType.IDENTIFIER,function)
	for i in args:
		var token := Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER,i)
		
		# code stolen from _convert_variables
		match type_string(typeof(i)):
			"String":
				token.type = Lexer.TokenType.STRING
			"float","int":
				token.type = Lexer.TokenType.NUMBER
			"bool":
				token.type = Lexer.TokenType.BOOLEAN
			"Array":
				token.type = Lexer.TokenType.ARRAY
			"Vector2":
				token.type = Lexer.TokenType.VECTOR
			"Color":
				token.type = Lexer.TokenType.COLOR
			"Signal":
				token.type = Lexer.TokenType.SIGNAL
			_:
				if i is SpriteFrames:
					token.type = Lexer.TokenType.SPRITEFRAMES
				elif i is Node:
					token.type = Lexer.TokenType.NODE
				elif i is Font:
					token.type = Lexer.TokenType.FONT
				elif i is AudioStream:
					token.type = Lexer.TokenType.AUDIO
				elif i is Texture2D:
					token.type = Lexer.TokenType.TEXTURE
		
		functoken.params.append(token)
	t = 0
	await executeFunction([functoken],Scope.new(),false,true)
	t = oldt

func initConstants() -> void:
	if !variables.has(str(node.get_instance_id())):
		variables[str(node.get_instance_id())] = {}
	if !custom_functions.has(str(node.get_instance_id())):
		custom_functions[str(node.get_instance_id())] = {}
	
	# timer stuff
	global_variables["TIMER"] = Variable.new("TIMER",VariableType.NUMBER,0.0)
	global_variables["DELTA"] = Variable.new("DELTA",VariableType.NUMBER,dt)
	global_variables["GLOBALTIMER"] = Variable.new("GLOBALTIMER",VariableType.NUMBER,Undermaker.timer)
	
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
	
	# vector constants
	global_variables["DIR_LEFT"] = Variable.new("DIR_LEFT",VariableType.VECTOR,Vector2.LEFT)
	global_variables["DIR_DOWN"] = Variable.new("DIR_DOWN",VariableType.VECTOR,Vector2.DOWN)
	global_variables["DIR_UP"] = Variable.new("DIR_UP",VariableType.VECTOR,Vector2.UP)
	global_variables["DIR_RIGHT"] = Variable.new("DIR_RIGHT",VariableType.VECTOR,Vector2.RIGHT)
	
	# angle constants
	global_variables["ANGLE_LEFT"] = Variable.new("ANGLE_LEFT",VariableType.NUMBER,270.0)
	global_variables["ANGLE_DOWN"] = Variable.new("ANGLE_DOWN",VariableType.NUMBER,180.0)
	global_variables["ANGLE_UP"] = Variable.new("ANGLE_UP",VariableType.NUMBER,0.0)
	global_variables["ANGLE_RIGHT"] = Variable.new("ANGLE_RIGHT",VariableType.NUMBER,90.0)
	
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
	
	# soul modes
	global_variables["MODE_RED"] = Variable.new("MODE_RED",VariableType.NUMBER,0)
	global_variables["MODE_BLUE"] = Variable.new("MODE_BLUE",VariableType.NUMBER,1)
	
	# self
	variables[str(node.get_instance_id())]["self"] = Variable.new("self",VariableType.NODE,node)
	
	# custom variables, these are only supposed to be used by functions. PLEASE DO NOT TRY TO SET THESE THEY WON'T WORK PROPERLY LOL
	for i in custom_constants:
		variables[str(node.get_instance_id())]['_'+i] = Variable.new('_'+i,VariableType.UNDEFINED,custom_constants[i])
	for i in custom_variables:
		variables[str(node.get_instance_id())][i] = Variable.new(i,VariableType.UNDEFINED,custom_variables[i])

func updateConstants() -> void:
	# update timers
	if dt_changed:
		global_variables["TIMER"].value += dt
		global_variables["DELTA"].value = dt
		dt_changed = false
	global_variables["GLOBALTIMER"].value = Undermaker.timer

static func loadScriptFromFile(script : String) -> Array:
	var scr := Undermaker.loadFileAsString("Scripts/"+script+".utscript",false)
	if !scr:
		push_warning("Script 'Scripts/"+script+".utscript' does not exist. Returning empty script.")
		return []
	var lexer = Lexer.new()
	return lexer.parse(lexer.tokenize(scr))

func runScript(script : Array,_node : Node,reinit_vars:=true) -> Error:
	if end_script:
		return ERR_LOCKED
	node = _node
	if reinit_vars:
		is_running = true
		initConstants()
		total_l = 0
		end_script = false
	l = 0
	t = 0
	var scriptscope := Scope.new()
	if !is_instance_valid(node):
		return ERR_DOES_NOT_EXIST
	while l < script.size() and !end_script:
		if !is_inside_tree():
			if reinit_vars:
				end_script = false
				is_running = false
				script_ended.emit()
			return ERR_SCRIPT_FAILED
		#print(l)
		total_l += 1
		updateConstants()
		t = 0
		while t < script[l].size() and !end_script:
			if !is_inside_tree():
				if reinit_vars:
					end_script = false
					is_running = false
					script_ended.emit()
				return ERR_SCRIPT_FAILED
			#print(t)
			if !is_instance_valid(node):
				return ERR_DOES_NOT_EXIST
			var token = script[l][t]
			var next_token = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER)
			if t < script[l].size()-1:
				next_token = script[l][t+1]
			var next_next_token = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER)
			if t < script[l].size()-2:
				next_next_token = script[l][t+2]
			if token is Lexer.FunctionToken:
				#print(token.value)
				await executeFunction(script[l],scriptscope)
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
							var vars = await _convert_variables([script[l][t+2]],scriptscope)
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
							elif variable.type == VariableType.SIGNAL and vars[0].value is Signal:
								_set_variable(token.value,vars[0].value)
							elif type_string(typeof(variable.value)) == type_string(typeof(vars[0].value)):
								_set_variable(token.value,vars[0].value)
							else:
								push_error('Line '+str(total_l+1)+': Type of variable '+str(token.value)+" ("+str(_get_variable(token.value).value)+" : "+type_string(typeof(_get_variable(token.value).value))+') does not match with target value\'s type ('+str(script[l][t+2].value)+' : '+type_string(typeof(vars[0].value))+")")
							t += 2
						Lexer.TokenType.ARITHMETIC_OPERATOR:
							# handle loading the value if it's a function lol
							var vars = await _convert_variables([script[l][t+2]],scriptscope)
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
								await executeFunction([next_token],scriptscope,true)
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
										elif _get_variable(str(next_token.value)):
											var vari : Variable = _get_variable(next_token.value)
											if vari.type == VariableType.SIGNAL:
												#print("variable signal ",vari.value)
												var _signal : Signal = vari.value
												await _signal
											t += 1
						"else":
							if next_token is Lexer.CodeToken and !scriptscope.should_continue_block and !end_script:
								await executeCodeBlock(next_token,node)
							t += 1
						"break":
							if scriptscope.should_continue_while:
								scriptscope.should_continue_while = false
						"function":
							if next_token is not Lexer.FunctionToken:
								push_error('Line '+str(total_l+1)+': Function expected for function definition')
								continue
							if next_next_token is not Lexer.CodeToken:
								push_error('Line '+str(total_l+1)+': Code block expected for function definition')
								continue
							custom_functions[str(node.get_instance_id())][next_token.value] = CustomFunction.new(next_next_token)
							
							t += 2
						"globalfunction":
							if next_token is not Lexer.FunctionToken:
								push_error('Line '+str(total_l+1)+': Function expected for function definition')
								continue
							if next_next_token is not Lexer.CodeToken:
								push_error('Line '+str(total_l+1)+': Code block expected for function definition')
								continue
							global_functions[next_token.value] = CustomFunction.new(next_next_token)
							
							t += 2
			t += 1
		l += 1
	if reinit_vars:
		if is_inside_tree():
			await get_tree().process_frame
		end_script = false
		is_running = false
		script_ended.emit()
		#print("Script finished")
	return OK

func _get_variable(variable:String,verbose:=false,target:=node):
	if variables.has(str(target.get_instance_id())):
		if variables[str(target.get_instance_id())].has(variable):
			return variables[str(target.get_instance_id())][variable]
		elif global_variables.has(variable):
			return global_variables[variable]
	elif global_variables.has(variable):
		return global_variables[variable]
	if verbose:
		push_warning("Variable \""+variable+"\" does not exist, returning null")
	return

func _set_variable(variable:String,value:Variant,target:=node):
	if variables.has(str(target.get_instance_id())):
		if variables[str(target.get_instance_id())].has(variable):
			variables[str(target.get_instance_id())][variable].value = value
	elif global_variables.has(variable):
		global_variables[variable].value = value
	else:
		push_error("Variable \""+variable+"\" does not exist")

func _convert_variables(parameters : Array,scope : Scope,exceptions : Array = [],verbose:=false) -> Array:
	var param = []
	for i in parameters:
		if i is Lexer.AdvancedToken:
			param.append(i.duplicate())
		else:
			param.append(i)
	var index = 0
	
	while index < param.size():
		if param[index] is not Lexer.AdvancedToken:
			#print("default value (index:"+str(index)+")")
			index += 1
			continue
		#print(param[index].value," ",param[index] is Lexer.FunctionToken)
		if _get_variable(str(param[index].value),verbose) and param[index].type == Lexer.TokenType.IDENTIFIER and !exceptions.has(index):
			#print("yeah")=
			param[index].value = _get_variable(str(param[index].value)).value
			match type_string(typeof(param[index].value)):
				"String":
					param[index].type = Lexer.TokenType.STRING
				"float","int":
					param[index].type = Lexer.TokenType.NUMBER
				"bool":
					param[index].type = Lexer.TokenType.BOOLEAN
				"Array":
					param[index].type = Lexer.TokenType.ARRAY
				"Vector2":
					param[index].type = Lexer.TokenType.VECTOR
				"Color":
					param[index].type = Lexer.TokenType.COLOR
				"Signal":
					param[index].type = Lexer.TokenType.SIGNAL
				_:
					if param[index].value is SpriteFrames:
						param[index].type = Lexer.TokenType.SPRITEFRAMES
					elif param[index].value is Node:
						param[index].type = Lexer.TokenType.NODE
					elif param[index].value is Font:
						param[index].type = Lexer.TokenType.FONT
					elif param[index].value is AudioStream:
						param[index].type = Lexer.TokenType.AUDIO
					elif param[index].value is Texture2D:
						param[index].type = Lexer.TokenType.TEXTURE
		elif param[index] is Lexer.FunctionToken and !exceptions.has(index):
			#print("function variable ",param[index].value)
			var val = await executeFunction([param[index]],scope)
			param[index] = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER,val)
			#print(type_string(typeof(param[index].value)))
			match type_string(typeof(param[index].value)):
				"String":
					param[index].type = Lexer.TokenType.STRING
				"float","int":
					param[index].type = Lexer.TokenType.NUMBER
				"bool":
					param[index].type = Lexer.TokenType.BOOLEAN
				"Array":
					param[index].type = Lexer.TokenType.ARRAY
				"Vector2":
					param[index].type = Lexer.TokenType.VECTOR
				"Color":
					param[index].type = Lexer.TokenType.COLOR
				"Signal":
					param[index].type = Lexer.TokenType.SIGNAL
				# for object classes like nodes
				_:
					if param[index].value is SpriteFrames:
						param[index].type = Lexer.TokenType.SPRITEFRAMES
					elif param[index].value is Node:
						param[index].type = Lexer.TokenType.NODE
					elif param[index].value is Font:
						param[index].type = Lexer.TokenType.FONT
					elif param[index].value is AudioStream:
						param[index].type = Lexer.TokenType.AUDIO
					elif param[index].value is Texture2D:
						param[index].type = Lexer.TokenType.TEXTURE
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
					var varible : Variable = _get_variable(variablename)
					if varible:
						targettext += str(varible.value).trim_suffix(".0")
					else:
						targettext += "[null]"
					variable_ing = false
				elif variable_ing:
					variablename += i
				else:
					targettext += i
			param[index].value = targettext
		if param[index].type == Lexer.TokenType.ARRAY:
			#print(param[index].value)
			var has_tokens := false
			for i in param[index].value:
				if i is Lexer.AdvancedToken:
					has_tokens = true
			if has_tokens:
				param[index].value = await _convert_variables(param[index].value,scope)
		index += 1
	return param

func executeFunction(line : Array,scope : Scope,wait := false,ignore_invalid_function_error:=false):
	updateConstants()
	var token : Lexer.FunctionToken = line[t]
	var validFunction = true
	match token.value:
		"print":
			if token.params.size() == 0:
				push_error('Line '+str(total_l+1)+': print() requires at least one parameter')
			else:
				var params = await _convert_variables(token.params,scope)
				var output := ""
				for i : Lexer.AdvancedToken in params:
					var val = i.value
					if i.value is Array:
						val = []
						for j in i.value:
							val.append(j.value)
					output += str(val)
				print(output)
			return
		"initvar":
			if token.params.size() != 2 and token.params.size() != 3:
				#for i in token.params:
					#print(i.value)
				push_error('Line '+str(total_l+1)+': initvar() requires between two and three parameters')
				return
			var params = await _convert_variables(token.params,scope,[0,1])
			
			if params[0].type != Lexer.TokenType.IDENTIFIER:
				push_error('Line '+str(total_l+1)+': Variable name requires at least one parameter')
				return
			
			var variab = Variable.new(params[0].value,variableTypes[params[1].value])
			if params.size() == 3:
				variab.value = params[2].value
				#print(variab.value)
			if variables.has(params[0].value):
				push_warning('Line '+str(total_l+1)+': Variable '+params[0].value+' is already defined and will be overwritten')
			
			variables[str(node.get_instance_id())][params[0].value] = variab
		"initglobal":
			if token.params.size() != 2 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': initglobal() requires between two and three parameters')
				return
			var params = await _convert_variables(token.params,scope,[0,1])
			
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
			var params = await _convert_variables(token.params,scope)
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
		"setvar":
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': set() requires three parameters')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Target node must be a Node')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Target node variable must be a string')
				return
			var target : Node = params[0].value
			if !variables.has(str(target.get_instance_id())):
				push_error('Line '+str(total_l+1)+': Target node does not have any variables')
				return
			if !variables[str(target.get_instance_id())].has(params[1].value):
				push_error('Line '+str(total_l+1)+': Target node does not have variable ',params[1].value)
				return
			# print("setting ",target.name,"'s property ",params[1].value," to ",params[2].value)
			_set_variable(params[1].value,params[2].value,target)
		"tween_property":
			if token.params.size() < 4 and token.params.size() > 6:
				push_error('Line '+str(total_l+1)+': tween_property() requires between four and five parameters')
				return
			var params = await _convert_variables(token.params,scope)
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
			var params = await _convert_variables(token.params,scope)
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
		"getSignal":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': getSignal() requires two parameters')
				return
			var params = await _convert_variables(token.params,scope)
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
			
			if !target.has_signal(params[1].value):
				push_error('Line '+str(total_l+1)+': Node does not have signal',params[1].value)
				return
			
			var signal_ref : Signal = Signal(target,params[1].value)
			
			return signal_ref
		"waitForSignal":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': waitForSignal() requires two parameters')
				return
			var params = await _convert_variables(token.params,scope)
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
			
			if !target.has_signal(params[1].value):
				push_error('Line '+str(total_l+1)+': Node does not have signal',params[1].value)
				return
			
			var signal_ref : Signal = Signal(target,params[1].value)
			
			await signal_ref
		"sin":
			if token.params.size() <= 0 and token.params.size() >= 3:
				push_error('Line '+str(total_l+1)+': sin() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Angle must be a number')
				return
			var output = sin(deg_to_rad(params[0].value))
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
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Angle must be a number')
				return
			var output = cos(deg_to_rad(params[0].value))
			if token.params.size() == 2:
				if params[1].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Output multiplier must be a number')
					return
				output *= params[1].value
			
			return output
		"while":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': while requires exactly one or three parameters')
				return
			
			var ogparams = []
			for i in token.params:
				ogparams.append(i.duplicate())
			var params = []
			
			var ogline = total_l
			
			scope.should_continue_while = true
			
			while scope.should_continue_while and !end_script and is_inside_tree():
				total_l = ogline
				params = []
				for i in ogparams:
					params.append(i.duplicate())
				
				params = await _convert_variables(params,scope,[1])
			
				if params.size() == 1:
					# one parameter version
					scope.should_continue_while = bool(params[0].value)
				else:
					# comparison version
					if params[1].type != Lexer.TokenType.OPERATOR:
						push_error('Line '+str(total_l+1)+': Invalid comparison operator')
						return
					match params[1].value:
						"<=":
							scope.should_continue_while = params[0].value <= params[2].value
						">=":
							scope.should_continue_while = params[0].value >= params[2].value
						"!=":
							scope.should_continue_while = params[0].value != params[2].value
						"==":
							scope.should_continue_while = params[0].value == params[2].value
						"<":
							scope.should_continue_while = params[0].value < params[2].value
						">":
							scope.should_continue_while = params[0].value > params[2].value
				
				if t >= line.size()-1:
					push_error('Line '+str(total_l+1)+': Code block expected for while')
					scope.should_continue_while = false
					#return
				if line[t+1] is not Lexer.CodeToken:
					#print(Lexer.TokenType.keys()[line[t+1].type])
					#print(t+1)
					push_error('Line '+str(total_l+1)+': Code block expected for while')
					scope.should_continue_while = false
					#return
				if scope.should_continue_while:
					await executeCodeBlock(line[t+1],node)
				else:
					total_l += line[t+1].value.size()+1
			#print("while loop ended")
			t += 1
		"repeat":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': repeat requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Repeat times must be a number')
				return
			if t >= line.size()-1:
				push_error('Line '+str(total_l+1)+': Code block expected for repeat')
				return
			if line[t+1] is not Lexer.CodeToken:
				push_error('Line '+str(total_l+1)+': Code block expected for repeat')
				return
			for i in range(params[0].value):
				#print(l)
				await executeCodeBlock(line[t+1],node)
			total_l += line[t+1].value.size()+1
			
			t += 1
		"if":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': if requires exactly one or three parameters')
				return
			
			var params = await _convert_variables(token.params,scope,[1])
			#for i in params:
				#print(i.value)
			
			scope.should_continue_block = true
			
			if params.size() == 1:
				# one parameter version
				if params[0].value is String:
					scope.should_continue_block = params[0].value != ""
				elif params[0].value is float or params[0].value is bool:
					scope.should_continue_block = bool(params[0].value)
				else:
					scope.should_continue_block = params[0].value != null
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
				if params[0].type == Lexer.TokenType.IDENTIFIER and token.params[0] is not Lexer.FunctionToken:
					push_error('Line '+str(total_l+1)+': Variable ',token.params[0].value,' does not exist or has not been initialized properly')
					return
				if params[2].type == Lexer.TokenType.IDENTIFIER and token.params[2] is not Lexer.FunctionToken:
					push_error('Line '+str(total_l+1)+': Variable ',token.params[2].value,' does not exist or has not been initialized properly')
					return
				match params[1].value:
					"<=":
						scope.should_continue_block = params[0].value <= params[2].value
					">=":
						scope.should_continue_block = params[0].value >= params[2].value
					"!=":
						scope.should_continue_block = params[0].value != params[2].value
					"==":
						scope.should_continue_block = params[0].value == params[2].value
					"<":
						scope.should_continue_block = params[0].value < params[2].value
					">":
						scope.should_continue_block = params[0].value > params[2].value
			
			if t >= line.size()-1:
				push_error('Line '+str(total_l+1)+': Code block expected for if')
				return
			if line[t+1] is not Lexer.CodeToken:
				push_error('Line '+str(total_l+1)+': Code block expected for if')
				return
			var curshouldcontinue = scope.should_continue_block
			if curshouldcontinue:
				await executeCodeBlock(line[t+1],node)
			#else:
				##print("else")
				#total_l += line[t+1].value.size()+1
				
			#if line.size() >= 4:
				#print(line[t+2].type)
				#if line[t+2].value == "else":
					#var next_token = line[t+3]
					#if next_token is Lexer.CodeToken and !end_script and !curshouldcontinue:
						#await executeCodeBlock(next_token,node)
					#t += 2
			
			t += 1
		"elif":
			if token.params.size() != 1 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': elif requires exactly one or three parameters')
				return
			
			if scope.should_continue_block:
				return
			
			var params = await _convert_variables(token.params,scope,[1])
			
			if token.params.size() == 1:
				# one parameter version
				scope.should_continue_block = bool(params[0].value)
			else:
				# comparison
				if params[1].type != Lexer.TokenType.OPERATOR:
					push_error('Line '+str(total_l+1)+': Invalid comparison operator')
					return
				match params[1].value:
					"<=":
						scope.should_continue_block = params[0].value <= params[2].value
					">=":
						scope.should_continue_block = params[0].value >= params[2].value
					"!=":
						scope.should_continue_block = params[0].value != params[2].value
					"==":
						scope.should_continue_block = params[0].value == params[2].value
					"<":
						scope.should_continue_block = params[0].value < params[2].value
					">":
						scope.should_continue_block = params[0].value > params[2].value
			
			if t >= line.size()-1:
				push_error('Line '+str(total_l+1)+': Code block expected for elif')
				return
			if line[t+1] is not Lexer.CodeToken:
				push_error('Line '+str(total_l+1)+': Code block expected for elif')
				return
			
			if scope.should_continue_block:
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
			var params = await _convert_variables(token.params,scope)
			
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
			var params = await _convert_variables(token.params,scope)
			
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
			var params = await _convert_variables(token.params,scope)
			
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
			var params = await _convert_variables(token.params,scope)
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
			var params = await _convert_variables(token.params,scope,[2])
			
			if params[2].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Weight must be a number')
				return
			
			return lerp(params[0].value,params[1].value,params[2].value)
		"vec2":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': vec2() requires exactly two parameters (',token.params.size(),' were given)')
				return
			var params = await _convert_variables(token.params,scope)
			
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
			var params = await _convert_variables(token.params,scope)
			
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
			
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.ARRAY and params[0].type != Lexer.TokenType.VECTOR and params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Array must be a valid array, Vector2 or string')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Index must be a number')
				return
			if params[1].value >= params[0].value.size():
				push_error('Line '+str(total_l+1)+': Index out of range')
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
			
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.ARRAY and params[0].type != Lexer.TokenType.VECTOR and params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Array must be a valid array, Vector2 or string')
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
				push_error('Line '+str(total_l+1)+': createSprite() requires exactly three parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Sprite object name must be a string')
				return
			if params[1].type != Lexer.TokenType.TEXTURE:
				push_error('Line '+str(total_l+1)+': Sprite must be a texture')
				return
			
			var sprite := Sprite2D.new()
			sprite.name = params[0].value
			sprite.texture = params[1].value
			sprite.position = params[2].value
			node.add_child(sprite,true)
			
			return sprite
		"createAnimatedSprite":
			if token.params.size() != 2 and token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': createAnimatedSprite() requires between two an three parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
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
			node.add_child(sprite,true)
			
			return sprite
		"font":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': font() requires exactly one parameter')
				return
			var font = FontFile.new()
			font.load_dynamic_font(Undermaker.Path+"Fonts/"+str(token.params[0].value))
			
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
			var params = await _convert_variables(token.params,scope)
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
			var params = await _convert_variables(token.params,scope)
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
			var params = await _convert_variables(token.params,scope)
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
			var params = await _convert_variables(token.params,scope)
			
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
			node.add_child(obj,true)
			
			return obj
		"reparent":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': reparent() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Child node must be a Node')
				return
			if params[1].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Parent node must be a Node')
				return
			
			params[0].value.reparent(params[1].value)
		"createText":
			if token.params.size() != 3 and token.params.size() != 4:
				push_error('Line '+str(total_l+1)+': createText() requires between three and four parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Text object name must be a string')
				return
			if params[1].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Starting text must be a string')
				return
			if params[2].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+': Object position must be a Vector2')
				return
			var font = preload("res://Fonts/DTM-Mono.otf")
			if params.size() == 4:
				if params[3].type != Lexer.TokenType.FONT and params[3].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Text font must be a Font or String')
					return
				font = params[3].value
			
			var text = TextObject.new()
			if font is String:
				text.load_font_data(font)
			else:
				text.font = font
			text.name = params[0].value
			text.text = params[1].value
			text.position = params[2].value
			node.add_child(text,true)
			
			return text
		"playSound":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': playSound() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Sound name must be a string)')
				return
			
			var audio = AudioStreamPlayer.new()
			add_child(audio,true)
			audio.stream = Loader.load_file("Audio/Sounds/"+params[0].value+".wav")
			if audio.stream:
				audio.play()
				audio.finished.connect(audio.queue_free)
			else:
				audio.stream = Loader.load_file("Audio/Sounds/"+params[0].value+".ogg")
				if audio.stream:
					audio.play()
					audio.finished.connect(audio.queue_free)
				else:
					push_error("Line "+str(total_l+1)+": Sound \"Audio/Sounds/"+params[0].value+"\" does not exist")
					audio.queue_free()
		"playBGM":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': playBGM() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': BGM name must be a string')
				return
			if !Loader.load_file("Audio/BGM/"+params[0].value+".ogg"):
				push_error("Line "+str(total_l+1)+": Audio path must lead to a valid audio file (Path: "+"Audio/BGM/"+params[0]+".ogg)")
				return
			
			BGM.playBGM(params[0].value)
		"fadeInBGM":
			if token.params.size() != 0:
				push_error('Line '+str(total_l+1)+': fadeInBGM() takes no parameters')
				return
			BGM.fadeIn()
		"fadeOutBGM":
			if token.params.size() != 0:
				push_error('Line '+str(total_l+1)+': fadeOutBGM() takes no parameters')
				return
			BGM.fadeOut()
		"loadRoom":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': loadRoom() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Room name must be a room')
				return
			
			Undermaker.load_scene(params[0].value)
			end_script = true
		"loadAudio":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': loadAudio() requires between exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Audio filename must be a string')
				return
			var sound = Loader.load_file("Audio/Sounds/"+params[0].value+".wav")
			if sound:
				return sound
			else:
				sound = Loader.load_file("Audio/Sounds/"+params[0].value+".ogg")
				if sound:
					sound.looped = true
					return sound
				else:
					push_error("Line "+str(total_l+1)+": Sound \"Audio/"+params[0].value+"\" does not exist")
		"moveCharacter":
			if token.params.size() != 3:
				push_error('Line '+str(total_l+1)+': moveCharacter() requires exactly three parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.NODE:
				push_error('Line '+str(total_l+1)+': Character object must be a Node')
				return
			if params[0].value is not Character:
				push_error('Line '+str(total_l+1)+': Character object is not a Character')
				return
			
			if params[1].type != Lexer.TokenType.VECTOR:
				push_error('Line '+str(total_l+1)+': Movement direction must be a Vector2')
				return
			
			if params[2].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Steps must be a number')
				return
			
			var chara : Character = params[0].value
			if wait:
				await chara.move(int(floorf(params[2].value)),clamp(params[1].value,Vector2(-1,-1),Vector2(1,1)))
			else:
				chara.move(int(floorf(params[2].value)),clamp(params[1].value,Vector2(-1,-1),Vector2(1,1)))
		"getFlag":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': "getFlag":() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Flag name must be a string')
				return
			
			if PlayerData.flags.has(params[0].value):
				return PlayerData.flags[params[0].value]
			else:
				push_warning('Line '+str(total_l+1)+': Flag ',params[0].value,' does not exist, defaulting to false')
				return false
		"setFlag":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': "setFlag":() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Flag name must be a string')
				return
			
			PlayerData.flags[params[0].value] = params[1].value
		"encounter":
			if token.params.size() != 1 and token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': encounter() requires between one and two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Encounter name must be a string')
				return
			
			var transition := true
			
			if params.size() == 2:
				if params[1].type != Lexer.TokenType.BOOLEAN:
					push_error('Line '+str(total_l+1)+': Encounter transition must be a bool')
					return
				transition = params[1].value
			
			Battle.Encounter(params[0].value,transition)
		"getRoomNode":
			if token.params.size() != 0:
				push_error('Line '+str(total_l+1)+': getRoomNode() takes no parameters')
				return
			
			return get_tree().current_scene
		"loadTexture":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': loadTexture() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Texture path must be a string')
				return
			
			var tex = Loader.load_file("Sprites/"+params[0].value+".png")
			if !tex:
				push_error('Line '+str(total_l+1)+': Texture must exist')
				return
			
			return tex
		"mod":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': mod() requires exactly two parameters')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Input must be a number')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Divider must be a number')
				return
			
			return fmod(params[0].value,params[1].value)
		"createMetronome":
			if token.params.size() < 2 or token.params.size() > 6:
				push_error('Line '+str(total_l+1)+': createMetronome() requires between two and six parameters.')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Metronome object name must be a String')
				return
			if params[1].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': BPM must be a number')
				return
			var bpm : float = params[1].value
			var beats : int = 4
			var steps : int = 4
			var start := true
			var sound := false
			
			if params.size() >= 3:
				if params[2].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Beat count must be a number')
					return
				beats = int(params[2].value)
			if params.size() >= 4:
				if params[3].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Step count must be a number')
					return
				steps = int(params[3].value)
			if params.size() >= 5:
				if params[4].type != Lexer.TokenType.BOOLEAN:
					push_error('Line '+str(total_l+1)+': Auto starting must be a boolean')
					return
				start = params[4].value
			if params.size() >= 6:
				if params[5].type != Lexer.TokenType.BOOLEAN:
					push_error('Line '+str(total_l+1)+': Metronome sound enabling must be a boolean')
					return
				sound = params[5].value
			
			var metronome := Metronome.new(bpm,beats,steps,start,sound)
			metronome.name = params[0].value
			node.add_child(metronome,true)
			
			return metronome
		"setPlayerData":
			if token.params.size() != 2:
				push_error('Line '+str(total_l+1)+': setPlayerData() requires exactly two parameters.')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Player value name must be a String')
				return
			
			PlayerData.set_indexed(params[0].value,params[1].value)
		"giveItem":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': giveItem() requires exactly one parameter.')
				return
			var params = await _convert_variables(token.params,scope)
			if params[0].type != Lexer.TokenType.STRING:
				push_error('Line '+str(total_l+1)+': Item name must be a String')
				return
			
			var items = Item.GetItemList()
			if items.has(params[0].value):
				PlayerData.inventory.append(items[params[0].value])
			else:
				push_error('Line '+str(total_l+1)+": Item does not exist. Valid item list is: "+str(items))
		"angle_as_vector":
			if token.params.size() != 1:
				push_error('Line '+str(total_l+1)+': angle_as_vector() requires exactly one parameter')
				return
			var params = await _convert_variables(token.params,scope)
			
			if params[0].type != Lexer.TokenType.NUMBER:
				push_error('Line '+str(total_l+1)+': Angle must be a number')
				return
			
			return Vector2(cos(deg_to_rad(params[0].value-90)),sin(deg_to_rad(params[0].value-90)))
		_:
			validFunction = false

		#"template":
			#if token.params.size() != 1 and token.params.size() != 2:
				#push_error('Line '+str(total_l+1)+': template() requires between one and two parameters')
				#return
			#var params = await _convert_variables(token.params,scope)
			#
			#if params[0].type != Lexer.TokenType.STRING:
				#push_error('Line '+str(total_l+1)+': template()')
				#return
	if validFunction:
		return
	validFunction = false
	
	if node is Enemy:
		# enemy scope!
		validFunction = true
		# so that it's easier to get the values.
		#@warning_ignore("unused_variable") # todo: remove when enemy functions are added
		# ERM ACTUALLY... i dont even NEED this because of the "if node is Enemy" autotyping it. 1000 iq move ma'am
		# var enemy : Enemy = node
		match token.value:
			"playSlashAnimation":
				if token.params.size() != 0:
					push_error('Line '+str(total_l+1)+': playSlashAnimation() takes no parameters')
					return
				node.playSlashAnimation()
			"miss":
				if token.params.size() < 0 and token.params.size() > 1:
					push_error('Line '+str(total_l+1)+': miss() requires between zero and one parameters')
					return
				var params = await _convert_variables(token.params,scope)
				var text = "miss"
				if params.size() == 1:
					if params[0].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': damage() requires exactly one parameter')
						return
					text = params[0].value
				node.miss(text)
			"damage":
				#for i in line.data:
					#if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
						#print("set damage variable")
						#var variable = getVariable(i.lexeme)
						#i.type = types[variable.type]
						#i.value = variable.value
				#if line.data.size() != 2:
					#push_error("Invalid amount of parameters for damage, must be 2")
					#return
				#elif line.data.size() >= 4:
					#push_error("Too many parameters for damage, must be 2")
					#return
				#elif line.data[1].type == Token.TokenType.TYPE_NUM:
					#push_error("Damage amount must be a number")
					#return	
				#var damag = line.data[1].value
				if token.params.size() != 1:
					push_error('Line '+str(total_l+1)+': damage() requires exactly one parameter')
					return
				var params = await _convert_variables(token.params,scope)
				
				if token.params[0].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Damage amount must be a number')
					return
				
				var damag = params[0].value
				if wait:
					await node._damage(damag,true)
				else:
					node._damage(damag,true)
			_:
				validFunction = false
		
	if node is AttackBox:
		# attack scope!
		validFunction = true
		# i DID have this.... then i realized there aren't really any variables i need to easily access like there are in the enemy object LMAO
		# var attacker : AttackBox = node
		match token.value:
			"createAttack":
				if token.params.size() < 3 or token.params.size() > 6:
					push_error('Line '+str(total_l+1)+': makeAttack() requires between three and six parameters')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Attack object name must be a string')
					return
				if params[1].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Attack object position must be a Vector2')
					return
				if params[2].type != Lexer.TokenType.TEXTURE:
					push_error('Line '+str(total_l+1)+': Attack sprite must be a Texture')
					return
				var vel : Vector2 = Vector2.ZERO
				var color : String = "white"
				var bounding := true
				if params.size() >= 4:
					if params[3].type != Lexer.TokenType.VECTOR:
						push_error('Line '+str(total_l+1)+': Attack velocity must be a Vector2')
						return
					vel = params[3].value
				if params.size() >= 5:
					if params[4].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Attack color must be a string')
						return
					color = params[4].value
				if params.size() >= 6:
					if params[5].type != Lexer.TokenType.BOOLEAN:
						push_error('Line '+str(total_l+1)+': Bounding should be a bool')
						return
					bounding = params[5].value
				
				var attack = preload("res://Scenes/Objects/Attack.tscn").instantiate()
				attack.name = params[0].value
				attack.damage = variables[str(node.get_instance_id())]["_enemydata"].value.ATK
				attack.position = params[1].value
				attack.texture = params[2].value
				attack.velocity = vel
				attack.attack_type = color
				if bounding:
					node.get_node("attacks/bounding").add_child(attack,true)
				else:
					node.get_node("attacks").add_child(attack,true)
				return attack
			"setBoxSize":
				#if tokens.data.size() != 3:
					#push_error("Invalid number of arguments for set_box_size")
					#return
				#if tokens.data[1].type != Token.TokenType.NUMBER:
					#push_error("Box X scale must be a number")
					#return
				#if tokens.data[2].type != Token.TokenType.NUMBER:
					#push_error("Box Y scale must be a number")
					#return
				#get_parent().rect.size = Vector2(float(tokens.data[1].value),float(tokens.data[2].value))
				#await get_tree().process_frame
				if token.params.size() != 1 and token.params.size() != 2:
					push_error('Line '+str(total_l+1)+': setBoxSize() requires between one and two parameters')
					return
				var params = await _convert_variables(token.params,scope)
				if params[0].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Box size must be a Vector2')
					return
				var position : Vector2 = node.rect.position
				if params.size() == 2:
					if params[1].type != Lexer.TokenType.VECTOR:
						push_error('Line '+str(total_l+1)+': Box offset must be a Vector2')
						return
					position = params[1].value
				node.rect.size = params[0].value
				node.rect.position = position
			"setSoulMode":
				if token.params.size() != 1:
					push_error('Line '+str(total_l+1)+': setSoulMode() requires exactly one parameter')
					return
				var params = await _convert_variables(token.params,scope)
				if params[0].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Soul mode must be a number')
					return
				if get_parent().get_parent().soulMode != int(params[0].value):
					get_parent().get_parent().soulMode = int(params[0].value)
					var audio = AudioStreamPlayer.new()
					add_child(audio,true)
					audio.stream = preload("res://Audio/Sounds/snd_bell.wav")
					audio.play()
					audio.finished.connect(audio.queue_free)
			"getBoxPos":
				if token.params.size() != 1 and token.params.size() != 2:
					push_error('Line '+str(total_l+1)+': setSoulMode() requires between one and two parameters')
					return
				var params = await _convert_variables(token.params,scope)
				if params[0].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Direction must be a vector')
					return
				# IGNORE THE FACT IT'S CALLED VECTOR. WHEN I UPDATED THIS FUNCTION I FORGOT ITS A NUMBER AND NOT A VECTOR IM JUST TOO LAZY TO CHANGE IT PLEASE KILL ME
				var vector : float
				match params[0].value:
					Vector2.LEFT:
						vector = ((-node.box_width/2)+3)+node.get_node("Node2D").position.x
					Vector2.DOWN:
						vector = ((node.box_height/2)-3)+node.get_node("Node2D").position.y
					Vector2.UP:
						vector = ((-node.box_height/2)+3)+node.get_node("Node2D").position.y
					Vector2.RIGHT:
						vector = ((node.box_width/2)-3)+node.get_node("Node2D").position.x
					_:
						push_error('Line '+str(total_l+1)+': Direction must be exactly up, down, left, or right')
						return
				if params.size() == 2:
					if params[1].type != Lexer.TokenType.NUMBER:
						push_error('Line '+str(total_l+1)+': Position offset must be a number')
						return
					vector += params[1].value
				return vector
			#"create_bone":
				#for i in tokens.data:
					#if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
						#var variable = getVariable(i.lexeme)
						#i.type = types[variable.type]
						#i.value = variable.value
				#if tokens.data[1].type != Token.TokenType.STRING:
					#push_error("Bone name must be a string")
					#return
				#if tokens.data[2].type != Token.TokenType.NUMBER:
					#push_error("Bone X position must be a number")
					#return
				#if tokens.data[3].type != Token.TokenType.NUMBER:
					#push_error("Bone Y position must be a number")
					#return
				#if tokens.data[4].type != Token.TokenType.NUMBER:
					#push_error("Bone length must be a number")
					#return
				#if tokens.data[5].type != Token.TokenType.NUMBER:
					#push_error("Bone X velocity must be a number")
					#return
				#if tokens.data[6].type != Token.TokenType.NUMBER:
					#push_error("Bone Y velocity must be a number")
					#return
				#if tokens.data[7].type != Token.TokenType.NUMBER:
					#push_error("Bone direction must be a number")
					#return
				#if tokens.data.size() >= 9:
					#if tokens.data[8].type != Token.TokenType.STRING:
						#push_error("Bone color must be a string")
						#return
				#if tokens.data.size() >= 10:
					#if tokens.data[9].type != Token.TokenType.BOOLEAN:
						#push_error("Bone type must be a bool")
						#return
				#var attack = preload("res://Scenes/Objects/Bone.tscn").instantiate()
				#attack.name = tokens.data[1].value
				#attack.damage = enemydata.ATK
				#var attackx = float(tokens.data[2].value)
				#var attacky = float(tokens.data[3].value)
				#attack.position = Vector2(attackx,attacky)
				#attack.height = float(tokens.data[4].value)
				#var velx = float(tokens.data[5].value)
				#var vely = float(tokens.data[6].value)
				#attack.velocity = Vector2(velx,vely)
				#attack.rotation_degrees = tokens.data[7].value
				#if tokens.data.size() >= 9:
					#attack.attack_type = tokens.data[8].value
				#if tokens.data.size() == 10:
					#attack.pap = tokens.data[9].value
				#node.get_node("attacks/bounding").add_child(attack)
			"createBone":
				if token.params.size() < 4 or token.params.size() > 8:
					push_error('Line '+str(total_l+1)+': createBone() requires between four and eight parameters')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Bone name must be a string')
					return
				if params[1].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Bone position must be a Vector2')
					return
				if params[2].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Bone length must be a number')
					return
				if params[2].value < 10:
					params[2].value = 10
				var vel = Vector2.ZERO
				var col = "white"
				var rot = 0
				var pap = false
				if params.size() >= 4:
					if params[3].type != Lexer.TokenType.VECTOR:
						push_error('Line '+str(total_l+1)+': Bone velocity must be a Vector2')
						return
					vel = params[3].value
				if params.size() >= 5:
					if params[4].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Bone color must be a string')
						return
					col = params[4].value
				if params.size() >= 6:
					if params[5].type != Lexer.TokenType.NUMBER:
						push_error('Line '+str(total_l+1)+': Bone rotation must be a number')
						return
					rot = params[5].value
				if params.size() >= 7:
					if params[6].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Bone color must be a string')
						return
					rot = params[6].value
				if params.size() >= 8:
					if params[7].type != Lexer.TokenType.BOOLEAN:
						push_error('Line '+str(total_l+1)+': Bone display type must be a boolean')
						return
					pap = params[7].value
				
				var attack = preload("res://Scenes/Objects/Bone.tscn").instantiate()
				attack.name = params[0].value
				attack.damage = variables[str(node.get_instance_id())]["_enemydata"].value.ATK
				#var attackx = float(tokens.data[2].value)
				#var attacky = float(tokens.data[3].value)
				attack.position = params[1].value
				attack.height = params[2].value
				#var velx = float(tokens.data[5].value)
				#var vely = float(tokens.data[6].value)
				attack.velocity = vel
				attack.rotation_degrees = rot
				attack.attack_type = col
				attack.pap = pap
				
				node.get_node("attacks/bounding").add_child(attack,true)
				return attack
			"createCenteredBone":
				if token.params.size() < 4 or token.params.size() > 8:
					push_error('Line '+str(total_l+1)+': createCenteredBone() requires between four and eight parameters')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Bone name must be a string')
					return
				if params[1].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Bone position must be a Vector2')
					return
				if params[2].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Bone length must be a number')
					return
				if params[2].value < 10:
					params[2].value = 10
				var vel = Vector2.ZERO
				var col = "white"
				var rot = 0
				var pap = false
				if params.size() >= 4:
					if params[3].type != Lexer.TokenType.VECTOR:
						push_error('Line '+str(total_l+1)+': Bone velocity must be a Vector2')
						return
					vel = params[3].value
				if params.size() >= 5:
					if params[4].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Bone color must be a string')
						return
					col = params[4].value
				if params.size() >= 6:
					if params[5].type != Lexer.TokenType.NUMBER:
						push_error('Line '+str(total_l+1)+': Bone rotation must be a number')
						return
					rot = params[5].value
				if params.size() >= 7:
					if params[6].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Bone color must be a string')
						return
					rot = params[6].value
				if params.size() >= 8:
					if params[7].type != Lexer.TokenType.BOOLEAN:
						push_error('Line '+str(total_l+1)+': Bone display type must be a boolean')
						return
					pap = params[7].value
				
				var attack = preload("res://Scenes/Objects/Bone.tscn").instantiate()
				attack.name = params[0].value
				attack.damage = variables[str(node.get_instance_id())]["_enemydata"].value.ATK
				#var attackx = float(tokens.data[2].value)
				#var attacky = float(tokens.data[3].value)
				attack.position = params[1].value
				attack.height = params[2].value
				#var velx = float(tokens.data[5].value)
				#var vely = float(tokens.data[6].value)
				attack.velocity = vel
				attack.rotation_degrees = rot
				attack.attack_type = col
				attack.pap = pap
				
				node.get_node("attacks/bounding").add_child(attack,true)
				return attack
			#"create_blaster":
				#for i in tokens.data:
					#if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
						#var variable = getVariable(i.lexeme)
						#i.type = types[variable.type]
						#i.value = variable.value
				#if tokens.data[1].type != Token.TokenType.STRING:
					#push_error("Blaster name must be a string")
					#return
				#if tokens.data[2].type != Token.TokenType.NUMBER:
					#push_error("Blaster X position must be a number")
					#return
				#if tokens.data[3].type != Token.TokenType.NUMBER:
					#push_error("Blaster Y position must be a number")
					#return
				#if tokens.data[4].type != Token.TokenType.NUMBER:
					#push_error("Blaster direction must be a number")
					#return
				#if tokens.data.size() >= 6:
					#if tokens.data[5].type != Token.TokenType.STRING:
						#push_error("Blaster color must be a string")
						#return
				#var attack = preload("res://Scenes/Objects/blaster.tscn").instantiate()
				#attack.name = tokens.data[1].value
				#var attackx = float(tokens.data[2].value)
				#var attacky = float(tokens.data[3].value)
				#attack.position = Vector2(attackx,attacky)
				#attack.rotation_degrees = tokens.data[4].value
				#if tokens.data.size() == 6:
					#attack.attack_type = tokens.data[5].value
				#node.get_node("attacks").add_child(attack)
			"createBlaster":
				if token.params.size() != 3 and token.params.size() != 4:
					push_error('Line '+str(total_l+1)+': createBlaster() requires between three and four parameters')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Blaster name must be a string')
					return
				if params[1].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Blaster position must be a Vector2')
					return
				if params[2].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Blaster direction must be a number')
					return
				var col = "white"
				if params.size() >= 4:
					if params[3].type != Lexer.TokenType.STRING:
						push_error('Line '+str(total_l+1)+': Blaster color must be a string')
						return
					col = params[3].value
				
				var attack = preload("res://Scenes/Objects/newBlaster.tscn").instantiate()
				attack.name = params[0].value
				attack.initial_position = Vector2.ZERO
				attack.target_position = params[1].value
				attack.target_rotation = params[2].value
				attack.attack_type = col
				
				node.get_node("attacks").add_child(attack,true)
				return attack
			#"slam":
				#if tokens.data[1].type != Token.TokenType.STRING:
					#push_error("Slam direction must be a string")
					#return
				#match tokens.data[1].value:
					#"left":
						#get_parent().get_parent().get_node("BattleHeart").bluedir = 90
						#get_parent().get_parent().get_node("BattleHeart").slamming = true
						#get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
					#"right":
						#get_parent().get_parent().get_node("BattleHeart").bluedir = 270
						#get_parent().get_parent().get_node("BattleHeart").slamming = true
						#get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
					#"down":
						#get_parent().get_parent().get_node("BattleHeart").bluedir = 0
						#get_parent().get_parent().get_node("BattleHeart").slamming = true
						#get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
					#"up":
						#get_parent().get_parent().get_node("BattleHeart").bluedir = 180
						#get_parent().get_parent().get_node("BattleHeart").slamming = true
						#get_parent().get_parent().get_node("BattleHeart").slamtimer = 1
					#_:
						#push_error("Slam direction must be \"left\", \"right\", \"up\", or \"down\". (case-sensitive)")
			"slam":
				if token.params.size() != 1:
					push_error('Line '+str(total_l+1)+': slam() requires exactly one parameter')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Soul angle must be a number')
					return
				if ![0.0,90.0,180.0,270.0].has(params[0].value):
					push_error('Line '+str(total_l+1)+': Soul angle must be a cardinal direction. It is recommended to use ANGLE_LEFT, ANGLE_RIGHT, ANGLE_UP, or ANGLE_DOWN for this function.')
					return
				var heart = get_tree().current_scene.get_node("BattleHeart")
				
				heart.bluedir = params[0].value-180
				heart.slamming = true
				heart.slamtimer = 1
				
				if wait:
					while heart.slamming:
						if !is_inside_tree():
							return
						await get_tree().process_frame
			#"create_platform":
				#for i in tokens.data:
					#if i.type == Token.TokenType.IDENTIFIER and getVariable(i.lexeme):
						#var variable = getVariable(i.lexeme)
						#i.type = types[variable.type]
						#i.value = variable.value
				#if tokens.data[1].type != Token.TokenType.STRING:
					#push_error("Platform name must be a string")
					#return
				#if tokens.data[2].type != Token.TokenType.NUMBER:
					#push_error("Platform X position must be a number")
					#return
				#if tokens.data[3].type != Token.TokenType.NUMBER:
					#push_error("Platform Y position must be a number")
					#return
				#if tokens.data[4].type != Token.TokenType.NUMBER:
					#push_error("Platform width must be a number")
					#return
				#if tokens.data[5].type != Token.TokenType.NUMBER:
					#push_error("Platform X velocity must be a number")
					#return
				#if tokens.data[6].type != Token.TokenType.NUMBER:
					#push_error("Platform Y velocity must be a number")
					#return
				#var attack = preload("res://Scenes/Objects/SansPlatform.tscn").instantiate()
				#attack.name = tokens.data[1].value
				#var attackx = float(tokens.data[2].value)
				#var attacky = float(tokens.data[3].value)
				#attack.position = Vector2(attackx,attacky)
				#attack.width = float(tokens.data[4].value)
				#var velx = float(tokens.data[5].value)
				#var vely = float(tokens.data[6].value)
				#attack.velocity = Vector2(velx,vely)
				#node.get_node("attacks/bounding").add_child(attack)
			"createPlatform":
				if token.params.size() != 4:
					push_error('Line '+str(total_l+1)+': createPlatform() requires exactly four parameters')
					return
				var params = await _convert_variables(token.params,scope)
				
				if params[0].type != Lexer.TokenType.STRING:
					push_error('Line '+str(total_l+1)+': Platform object name must be a string')
					return
				if params[1].type != Lexer.TokenType.NUMBER:
					push_error('Line '+str(total_l+1)+': Platform width must be a number')
					return
				if params[2].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Platform position must be a vector')
					return
				if params[3].type != Lexer.TokenType.VECTOR:
					push_error('Line '+str(total_l+1)+': Platform velocity must be a vector')
					return
				
				var platform = preload("res://Scenes/Objects/SansPlatform.tscn").instantiate()
				platform.name = params[0].value
				platform.width = params[1].value
				platform.position = params[2].value
				platform.velocity = params[3].value
				
				node.get_node("attacks/bounding").add_child(platform,true)
			_:
				validFunction = false
	
	if custom_functions[str(node.get_instance_id())].has(token.value):
		#print("running custom function ",token.value,"()")
		validFunction = true
		var index = 0
		var params = await _convert_variables(token.params,scope)
		for i in params:
			index += 1
			variables[str(node.get_instance_id())]["PARAM"+str(index)] = Variable.new("PARAM"+str(index),VariableType.UNDEFINED,i.value)
			
		await executeCodeBlock(custom_functions[str(node.get_instance_id())][token.value].code,node)
		index = 0
		for i in token.params:
			index += 1
			variables[str(node.get_instance_id())].erase("PARAM"+str(index))
	elif global_functions.has(token.value):
		#print("running custom global function ",token.value,"()")
		validFunction = true
		var index = 0
		var params = await _convert_variables(token.params,scope)
		for i in params:
			index += 1
			variables[str(node.get_instance_id())]["PARAM"+str(index)] = Variable.new("PARAM"+str(index),VariableType.UNDEFINED,i.value)
			
		await executeCodeBlock(global_functions[token.value].code,node)
		
		index = 0
		for i in token.params:
			index += 1
			variables[str(node.get_instance_id())].erase("PARAM"+str(index))
	
	if !validFunction and !ignore_invalid_function_error:
		push_error('Line ',str(total_l+1),': Function ',token.value,' does not exist in the current scope')

func executeCodeBlock(codeblock : Lexer.CodeToken,_node:Node) -> void:
	#print("Started to execute code block")
	#print(l)
	var oldl = l
	var oldt = t
	#print(total_l," ",t)
	await runScript(codeblock.value,_node,false)
	l = oldl
	t = oldt
	#print("Finished executing code block")

func _process(_delta) -> void:
	dt = _delta
	dt_changed = true
