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
	LPARENCURLY,
	RPARENCURLY,
	COMMA,
	SEMICOLON,
	EOF,
	EQUALS,
	OPERATOR,
	ARITHMETIC_OPERATOR,
	CODE_BLOCK,
	COLON,
	# next types are not used in the lexer, but instead used for values in interpreting e.g. colors and vectors
	VECTOR,
	COLOR,
	SPRITEFRAMES,
	NODE,
	FONT,
	AUDIO,
	TEXTURE,
	# end of unused lexer types
	COMMENT
}

class AdvancedToken:
	var type : TokenType
	var value : Variant
	
	func _init(t:TokenType,v:Variant=null):
		type = t
		value = v
	
	func duplicate():
		if self is FunctionToken:
			var token = FunctionToken.new(type,value)
			token.params = self.params
			return token
		if self is CodeToken:
			return CodeToken.new(type,value)
		elif self is AdvancedToken:
			return AdvancedToken.new(type,value)

class FunctionToken:
	extends AdvancedToken
	var params : Array[AdvancedToken]

class CodeToken:
	extends AdvancedToken

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
	
	var comment = false
	
	while pos < source.length():
		var c = source[pos]
		
		if comment:
			if c == "\n":
				script.append(tokens.duplicate(true))
				tokens = []
				comment = false
			pos += 1
			continue
		
		match c:
			# white space
			" ", "\t", "\n", "\r":
				pos += 1
			# colons (for dictionaries when i add them) (if i have added them by time of reading js ignore this)
			":":
				tokens.append(AdvancedToken.new(TokenType.COLON))
				pos += 1
			# comments
			"/":
				if source[pos+1] == "/":
					tokens.append(AdvancedToken.new(TokenType.COMMENT))
					comment = true
				elif source[pos+1] == "=":
					tokens.append(AdvancedToken.new(TokenType.ARITHMETIC_OPERATOR,c+"="))
				pos += 1
			# brackets
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
			"{":
				tokens.append(AdvancedToken.new(TokenType.LPARENCURLY))
				pos += 1
			"}":
				tokens.append(AdvancedToken.new(TokenType.RPARENCURLY))
				pos += 1
			# comma
			",":
				tokens.append(AdvancedToken.new(TokenType.COMMA))
				pos += 1
			# semicolon (ends line)
			";":
				tokens.append(AdvancedToken.new(TokenType.SEMICOLON))
				pos += 1
				
				script.append(tokens.duplicate(true))
				tokens = []
			# operators/equals
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
			# arithmetic
			"+","-","*":
				if source[pos+1] == "=":
					tokens.append(AdvancedToken.new(TokenType.ARITHMETIC_OPERATOR,c+"="))
					pos += 2
				elif is_digit(source[pos+1]):
					tokens.append(read_number())
				else:
					tokens.append(AdvancedToken.new(TokenType.ARITHMETIC_OPERATOR,c))
					pos += 1
			# strings
			'"':
				tokens.append(read_string())
			# identifiers and numbers
			_:
				if is_alpha(c):
					tokens.append(read_identifier())
				elif is_digit_beginning(c):
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
	pos += 1
	
	while pos < source.length() and (is_digit(source[pos])):
		pos += 1
	
	var value = source.substr(start,pos-start).to_float()
	
	return AdvancedToken.new(TokenType.NUMBER,value)

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

# so that it can detect like. negative numbers
func is_digit_beginning(c:String) -> bool:
	return c.is_subsequence_of("0123456789.-")

# we don't want -4-5 to be a valid number do we
func is_digit(c:String) -> bool:
	return c.is_subsequence_of("0123456789.")

func parse(code:Array) -> Array:
	var script = []
	var line = []
	
	parsersource = code
	parserline = 0
	
	while parserline < parsersource.size():
		# print("PARSING LINE")
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
						line.append(token.duplicate())
						parsertoken += 1
				TokenType.LPARENSQUARE:
					line.append(read_array())
				TokenType.LPARENCURLY:
					line.append(read_codeblock())
					#print("hi")
					#parsertoken += 1
				_:
					line.append(token.duplicate())
					parsertoken += 1
			#parsertoken += 1
		script.append(line.duplicate(true))
		line = []
		parserline += 1
		#print("FINISHED PARSING LINE")
	
	# debugging
	#for i in script:
		#for j in i:
			#print(TokenType.keys()[j.type]," ",j.value)
		#print()
	
	return script

func read_codeblock() -> CodeToken:
	#print("reading codeblock")
	
	var code : CodeToken = CodeToken.new(TokenType.CODE_BLOCK,[])
	
	var interpreted = []
	var line = []
	
	#print(parsertoken)
	if parsersource[parserline].size()-1 == parsertoken:
		parsertoken = 0
		parserline += 1
	else:
		parsertoken += 1
	var token : AdvancedToken = parsersource[parserline][parsertoken]
	
	var blockdepth := 0
	var done := false
	
	# old code that FORGOT I COULD DO NESTED LOOPS IM SO STUPID AHAHAHAHAHHHHAHAHA
	#while parserline < parsersource.size() and !(token.type == TokenType.RPARENCURLY and ignorecurly == 0):
		#while parsertoken < parsersource[parserline].size() and !(token.type == TokenType.RPARENCURLY and ignorecurly == 0):
			#if token.type == TokenType.LPARENCURLY:
				#print("nested codeblock began")
				#ignorecurly += 1
				#print("ignorecurly ",ignorecurly)
			#elif token.type == TokenType.RPARENCURLY:
				#print("nested codeblock ended")
				#ignorecurly -= 1
				#print("ignorecurly ",ignorecurly)
			#elif token.type == TokenType.IDENTIFIER:
				#print(token.value)
			#token = parsersource[parserline][parsertoken]
			#line.append(token.duplicate())
			#parsertoken += 1
		#var dupe = []
		#for i in line:
			#dupe.append(i.duplicate())
		#interpreted.append(dupe)
		#print(parsersource[parserline])
		#line = []
		#if parserline+1 >= parsersource.size():
			#push_warning("Code block reached end of script")
			#break
		#elif parsertoken > parsersource[parserline].size():
			#parserline += 1
			#parsertoken = 0
			#token = parsersource[parserline][parsertoken]
		#else:
			#parsertoken += 1
	
	while parserline < parsersource.size() and !done:
		while parsertoken < parsersource[parserline].size() and !done:
			match token.type:
				Lexer.TokenType.LPARENCURLY:
					#print("Nested block start")
					blockdepth += 1
					line.append(token.duplicate())
				Lexer.TokenType.RPARENCURLY:
					if blockdepth == 0:
						done = true
						break
					else:
						#print("Nested block end")
						blockdepth -= 1
						line.append(token.duplicate())
				_:
					line.append(token.duplicate())
			parsertoken += 1
			if parsertoken < parsersource[parserline].size():
				token = parsersource[parserline][parsertoken]
		interpreted.append(line.duplicate(true))
		line = []
		if parserline+1 >= parsersource.size():
			push_warning("Code block reached end of script")
			break
		elif !done:
			parserline += 1
			parsertoken = 0
			token = parsersource[parserline][parsertoken]
	
	#print("finished reading codeblock, parsing")
	if line.size() != 0:
		interpreted.append(line.duplicate(true))
	#for i in interpreted:
		#for j in i:
			#print(j.value)
	var oldtoken = parsertoken
	var oldline = parserline
	var oldsource = parsersource
	code.value = parse(interpreted)
	parsertoken = oldtoken
	parserline = oldline
	parsersource = oldsource
	
	#print("finished parsing codeblock!")
	
	# print("yeah")
	# print(interpreted)
	
	#parsertoken += 1
	
	if parserline == parsersource.size() and code.value.size() != 0:
		parserline -= 1
	
	return code

func read_function() -> FunctionToken:
	#print("reading function")
	
	var token : AdvancedToken = parsersource[parserline][parsertoken]
	var function : FunctionToken = FunctionToken.new(token.type,token.value)
	#print(token.value)
	parsertoken += 2
	
	while parsertoken < parsersource[parserline].size() and parsersource[parserline][parsertoken].type != TokenType.RPAREN:
		token = parsersource[parserline][parsertoken]
		if token.type == TokenType.LPARENSQUARE:
			function.params.append(read_array())
			#print("addded array token")
		elif token.type == TokenType.IDENTIFIER and parsersource[parserline][parsertoken+1].type == TokenType.LPAREN:
			function.params.append(read_function())
			#print("added function token")
		elif token.type != TokenType.COMMA:
			function.params.append(token.duplicate())
			#print("added general token")
			parsertoken += 1
		else:
			parsertoken += 1
		#print(TokenType.keys()[token.type]," ",token.value)
	#print()
	
	parsertoken += 1
	
	if parsertoken == parsersource[parserline].size():
		push_error("Line "+str(parserline+1)+" - Unfinished function")
	
	#for i in function.params:
		#print(i.value)
	
	#print("finished reading function")	
	
	return function

func read_array() -> AdvancedToken:
	var token : AdvancedToken = parsersource[parserline][parsertoken]
	var nexttoken : AdvancedToken
	var array : AdvancedToken = AdvancedToken.new(TokenType.ARRAY,[])
	parsertoken += 1
	
	var cont = true
	
	while parsertoken < parsersource[parserline].size() and cont:
		#print(parsertoken)
		token = parsersource[parserline][parsertoken]
		nexttoken = AdvancedToken.new(TokenType.IDENTIFIER)
		if parsertoken+1 < parsersource[parserline].size():
			nexttoken = parsersource[parserline][parsertoken+1]
		if token.type == TokenType.IDENTIFIER and nexttoken.type == TokenType.LPAREN:
			array.value.append(read_function())
			parsertoken -= 1
		elif token.type == TokenType.RPARENSQUARE:
			#print("DISABLE CONT")
			cont = false
			parsertoken += 1
			continue
		elif token.type != TokenType.COMMA:
			array.value.append(token)
		#print(TokenType.keys()[token.type]," ",token.value)
		parsertoken += 1
	
	#print(array.value)
	
	if parsertoken >= parsersource[parserline].size():
		push_error("Line "+str(parserline+1)+" - Unfinished array")
	
	#parsertoken += 1
	
	#parsertoken += 1
	
	return array
