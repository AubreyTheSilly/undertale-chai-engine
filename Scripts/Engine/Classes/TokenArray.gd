class_name TokenArray
extends Resource

var data : Array[Token]

static var alnum = "abcdefghijklmnopqrstuvwxyz0123456789_"
static var al = "abcdefghijklmnopqrstuvwxyz"
static var num = "0123456789-."

var tokens : Dictionary[String,Token.TokenType] = {"+":Token.TokenType.PLUS,"-":Token.TokenType.MINUS,"*":Token.TokenType.STAR,"/":Token.TokenType.SLASH,"!":Token.TokenType.BANG,"=":Token.TokenType.EQUAL,"<":Token.TokenType.LESS,">":Token.TokenType.GREATER,"!=":Token.TokenType.BANG_EQUAL,"==":Token.TokenType.EQUAL_EQUAL,"<=":Token.TokenType.LESS_EQUAL,">=":Token.TokenType.GREATER_EQUAL,"if":Token.TokenType.IF,"else":Token.TokenType.ELSE,"print":Token.TokenType.PRINT,"set":Token.TokenType.SET,"var":Token.TokenType.VAR,"increment":Token.TokenType.INCREMENT,"decrement":Token.TokenType.DECREMENT,"string":Token.TokenType.TYPE_STRING,"bool":Token.TokenType.TYPE_BOOL,"num":Token.TokenType.TYPE_NUM,"break":Token.TokenType.BREAK,"end":Token.TokenType.END,"while":Token.TokenType.WHILE,"playsnd":Token.TokenType.PLAY_SND,"wait":Token.TokenType.WAIT,"set_property":Token.TokenType.SET_PROPERTY,"tween_property":Token.TokenType.TWEEN_PROPERTY,"IN":Token.TokenType.IN,"OUT":Token.TokenType.OUT,"IN_OUT":Token.TokenType.IN_OUT,"OUT_IN":Token.TokenType.OUT_IN,"create_sprite":Token.TokenType.CREATE_SPRITE}

func _init():
	data = []

func isNum(str : String) -> bool:
	for i in str:
		if al.contains(i) or !num.contains(i):
			return false
	return true

func tokenize(buffer : String):
	if buffer[0] == "\"" and buffer[-1] == "\"":
		var string = buffer
		string[0] = ""
		string[-1] = ""
		data.append(Token.new(buffer,Token.TokenType.STRING,string))
	elif buffer == "true":
		data.append(Token.new(buffer,Token.TokenType.BOOLEAN,true))
	elif buffer == "false":
		data.append(Token.new(buffer,Token.TokenType.BOOLEAN,false))
	elif tokens.has(buffer):
		data.append(Token.new(buffer,tokens[buffer],buffer))
	elif isNum(buffer):
		data.append(Token.new(buffer,Token.TokenType.NUMBER,buffer.to_float()))
	else:
		data.append(Token.new(buffer,Token.TokenType.IDENTIFIER,buffer))
	#print("Lexeme: \""+data[-1].lexeme+"\" Type: "+str(data[-1].type)+" Value: "+str(data[-1].value))
