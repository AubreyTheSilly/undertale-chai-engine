class_name Lexer

enum TokenType {
	# basic thingies
	IDENTIFIER,
	STRING,
	NUMBER,
	BOOLEAN,
	ARRAY,
	LPAREN,
	RPAREN,
	LPARENSQUARE,
	RPARENSQUARE,
	COMMA,
	SEMICOLON,
	EOF,
	EQUALS,
	OPERATOR
}

class AdvancedToken:
	var type : TokenType
	var value : Variant
	
	func _init(t:TokenType,v:Variant=null):
		type = t
		value = v

class FunctionToken:
	extends AdvancedToken
	var params : Array[AdvancedToken]

# tokenizer variables
var source := ""
var pos := 0

# parser variables
var parsersource := []
var parserline := 0
var parsertoken := 0

func tokenize(code:String) -> Array:
	source = code
	pos = 0
	var script = []
	var tokens = []
	
	while pos < source.length():
		var c = source[pos]
		
		match c:
			" ", "\t", "\n", "\r":
				pos += 1
			"(":
				tokens.append(AdvancedToken.new(TokenType.LPAREN))
				pos += 1
			")":
				tokens.append(AdvancedToken.new(TokenType.RPAREN))
				pos += 1
			"[":
				tokens.append(AdvancedToken.new(TokenType.LPARENSQUARE))
				pos += 1
			"]":
				tokens.append(AdvancedToken.new(TokenType.RPARENSQUARE))
				pos += 1
			",":
				tokens.append(AdvancedToken.new(TokenType.COMMA))
				pos += 1
			";":
				tokens.append(AdvancedToken.new(TokenType.SEMICOLON))
				pos += 1
				
				script.append(tokens.duplicate(true))
				tokens = []
			"=":
				if source[pos+1] == "=":
					tokens.append(AdvancedToken.new(TokenType.OPERATOR,c+"="))
					pos += 1
				else:
					tokens.append(AdvancedToken.new(TokenType.EQUALS))
				pos += 1
			">","<":
				if source[pos+1] == "=":
					tokens.append(AdvancedToken.new(TokenType.OPERATOR,c+"="))
					pos += 1
				else:
					tokens.append(AdvancedToken.new(TokenType.OPERATOR,c))
				pos += 1
			"!":
				if source[pos+1] == "=":
					tokens.append(AdvancedToken.new(TokenType.OPERATOR,c+"="))
					pos += 1
				else:
					push_error("Unexpected character ("+c+")")
				pos += 1
			'"':
				tokens.append(read_string())
			
			_:
				if is_alpha(c):
					tokens.append(read_identifier())
				elif is_digit(c):
					tokens.append(read_number())
				else:
					push_error("Unexpected character ("+c+")")
					pos += 1
	
	tokens.append(AdvancedToken.new(TokenType.EOF))
	script.append(tokens)
	
	# debugging
	#for i in script:
		#for j in i:
			#print(TokenType.keys()[j.type]," ",j.value)
		#print()
	
	return script

func read_string() -> AdvancedToken:
	pos += 1
	var start = pos
	
	while pos < source.length() and source[pos] != '"':
		pos += 1
	
	var value = source.substr(start,pos-start)
	pos += 1
	
	return AdvancedToken.new(TokenType.STRING,value)

func read_number() -> AdvancedToken:
	var start = pos
	
	while pos < source.length() and is_digit(source[pos]):
		pos += 1
	
	var value = source.substr(start,pos-start).to_float()
	
	return AdvancedToken.new(TokenType.STRING,value)

func read_identifier() -> AdvancedToken:
	var start = pos
	
	while pos < source.length() and (is_alpha(source[pos]) or is_digit(source[pos])):
		pos += 1
	
	var value = source.substr(start,pos-start)
	
	match value:
		"true":
			return AdvancedToken.new(TokenType.BOOLEAN,true)
		"false":
			return AdvancedToken.new(TokenType.BOOLEAN,false)
		_:
			return AdvancedToken.new(TokenType.IDENTIFIER,value)

func is_alpha(c:String) -> bool:
	return c.is_subsequence_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_")


func is_digit(c:String) -> bool:
	return c.is_subsequence_of("0123456789.")

func parse(code:Array) -> Array:
	var script = []
	var line = []
	
	parsersource = code
	parserline = 0
	
	while parserline < parsersource.size():
		#print("PARSING LINE")
		parsertoken = 0
		while parsertoken < parsersource[parserline].size():
			var token = parsersource[parserline][parsertoken]
			var nexttoken = AdvancedToken.new(TokenType.IDENTIFIER)
			if parsertoken != parsersource[parserline].size()-1:
				nexttoken = parsersource[parserline][parsertoken+1]
			match token.type:
				TokenType.IDENTIFIER:
					if nexttoken.type == TokenType.LPAREN:
						line.append(read_function())
					else:
						line.append(token)
						parsertoken += 1
				TokenType.LPARENSQUARE:
					line.append(read_array())
				_:
					line.append(token)
					parsertoken += 1
			#parsertoken += 1
		script.append(line.duplicate(true))
		line = []
		parserline += 1
		#print("FINISHED PARSING LINE")
	
	return script

func read_function() -> FunctionToken:
	var token : AdvancedToken = parsersource[parserline][parsertoken]
	var function : FunctionToken = FunctionToken.new(token.type,token.value)
	parsertoken += 2
	
	while parsertoken < parsersource[parserline].size() and parsersource[parserline][parsertoken].type != TokenType.RPAREN:
		token = parsersource[parserline][parsertoken]
		if token.type == TokenType.LPARENSQUARE:
			function.params.append(read_array())
		elif token.type != TokenType.COMMA:
			function.params.append(token)
		parsertoken += 1
	
	parsertoken += 1
	
	if parsertoken == parsersource[parserline].size():
		push_error("Line "+str(parserline+1)+" - Unfinished function")
	
	return function

func read_array() -> AdvancedToken:
	var token : AdvancedToken = parsersource[parserline][parsertoken]
	var array : AdvancedToken = AdvancedToken.new(TokenType.ARRAY,[])
	parsertoken += 1
	
	while parsertoken < parsersource[parserline].size() and parsersource[parserline][parsertoken].type != TokenType.RPARENSQUARE:
		token = parsersource[parserline][parsertoken]
		if token.type != TokenType.COMMA:
			array.value.append(token.value)
		parsertoken += 1
	
	parsertoken += 1
	
	#print(array.value)
	
	if parsertoken == parsersource[parserline].size():
		push_error("Line "+str(parserline+1)+" - Unfinished array")
	
	parsertoken += 1
	
	return array
