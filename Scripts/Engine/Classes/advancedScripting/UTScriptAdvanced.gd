class_name UTScriptAdvanced

enum VariableType {
	STRING,NUMBER,BOOL,UNDEFINED,ARRAY
}

static var variableTypes := {
	"STRING":VariableType.STRING,
	"NUMBER":VariableType.NUMBER,
	"BOOL":VariableType.BOOL,
	"UNDEFINED":VariableType.UNDEFINED,
	"ARRAY":VariableType.ARRAY
}

class Variable:
	var name : String
	var type : VariableType
	var value : Variant
	
	func _init(n:String,t:VariableType,v:Variant=null):
		name=n
		type=t
		value=v

static var variables : Dictionary[String,Variable] = {}

static func loadScriptFromFile(script : String) -> Array:
	var scr := Undermaker.loadFileAsString("Scripts/"+script+".utscript")
	var lexer = Lexer.new()
	return lexer.parse(lexer.tokenize(scr))

static func runScript(script : Array,_node : Node) -> Error:
	var l := 0
	var t := 0
	while l < script.size():
		t = 0
		#print("hi")
		while t < script[l].size():
			var token = script[l][t]
			var next_token = Lexer.AdvancedToken.new(Lexer.TokenType.IDENTIFIER)
			if t != script[l].size()-1:
				next_token = script[l][t+1]
			if token is Lexer.FunctionToken:
				#print(token.value)
				match token.value:
					"print":
						if token.params.size() == 0:
							push_error('Line '+str(l)+': print() requires at least one parameter')
						else:
							token.params = _convert_variables(token.params)
							var output := ""
							for i : Lexer.AdvancedToken in token.params:
								output += str(i.value)
							print(output)
					"initvar":
						if token.params.size() != 2 and token.params.size() != 3:
							push_error('Line '+str(l)+': initvar() requires between two and three parameters')
							continue
						token.params = _convert_variables(token.params,[0,1])
						
						if token.params[0].type != Lexer.TokenType.IDENTIFIER:
							push_error('Line '+str(l)+': Variable name requires at least one parameter')
							continue
						
						var variab = Variable.new(token.params[0].value,variableTypes[token.params[1].value])
						if token.params.size() == 3:
							variab.value = token.params[2].value
						if variables.has(token.params[0].value):
							push_warning('Line '+str(l)+': Variable '+token.params[0].value+' is already defined and will be overwritten')
						
						variables[token.params[0].value] = variab
					"startDialogue":
						if token.params.size() != 1 and token.params.size() != 2:
							push_error('Line '+str(l)+': startDialogue() requires between one and two parameters')
							continue
						
						if token.params[0].type != Lexer.TokenType.ARRAY:
							push_error('Line '+str(l)+': Dialogue must be an array')
							continue
						var down = 1
						if token.params.size() == 2:
							if token.params[2].type != Lexer.TokenType.BOOLEAN:
								push_error('Line '+str(l)+': Dialogue positioning must be a bool')
								continue
							down = int(token.params[2].value)
						
						DialogueHandler.StartDialogue(token.params[0].value,down)
						await DialogueHandler.dialogue_finished
			elif token.value:
				if _get_variable(str(token.value)):
					var variable = _get_variable(token.value)
					if next_token.type == Lexer.TokenType.EQUALS and t < script[l].size()-2:
						# handle setting the variable
						if variable.type == VariableType.STRING and script[l][t+2].value is String:
							_set_variable(token.value,script[l][t+2].value)
						elif variable.type == VariableType.NUMBER and script[l][t+2].value is float:
							_set_variable(token.value,script[l][t+2].value)
						elif variable.type == VariableType.BOOL and script[l][t+2].value is bool:
							_set_variable(token.value,script[l][t+2].value)
						elif variable.type == VariableType.ARRAY and script[l][t+2].value is Array:
							_set_variable(token.value,script[l][t+2].value)
						else:
							push_error('Line '+str(l)+': Type of variable '+str(token.params[0].value)+' does not match with target value')
						t += 2
			t += 1
		l += 1
	
	return OK

static func _get_variable(variable:String):
	if variables.has(variable):
		return variables[variable]
	push_warning("Variable \""+variable+"\" does not exist, returning null")
	return

static func _set_variable(variable:String,value:Variant):
	if variables.has(variable):
		variables[variable].value = value
	else:
		push_error("Variable \""+variable+"\" does not exist")

static func _convert_variables(parameters : Array,exceptions : Array = []) -> Array:
	var param = parameters
	var index = 0
	
	while index < param.size():
		#print(str(param[index].value))
		if variables.has(str(param[index].value)) and !exceptions.has(index):
			param[index].value = variables[param[index].value].value
		index += 1
	
	return param
