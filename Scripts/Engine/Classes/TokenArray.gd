class_name TokenArray
extends Resource

var data : Array[Token]

static var alnum = "abcdefghijklmnopqrstuvwxyz0123456789_"
static var al = "abcdefghijklmnopqrstuvwxyz"
static var num = "0123456789-."

var tokens : Dictionary[String,Token.TokenType] = {"+":Token.TokenType.PLUS,"-":Token.TokenType.MINUS,"*":Token.TokenType.STAR,"/":Token.TokenType.SLASH,"!":Token.TokenType.BANG,"=":Token.TokenType.EQUAL,"<":Token.TokenType.LESS,">":Token.TokenType.GREATER,"!=":Token.TokenType.BANG_EQUAL,"==":Token.TokenType.EQUAL_EQUAL,"<=":Token.TokenType.LESS_EQUAL,">=":Token.TokenType.GREATER_EQUAL,"if":Token.TokenType.IF,"else":Token.TokenType.ELSE,"print":Token.TokenType.PRINT,"set":Token.TokenType.SET,"var":Token.TokenType.VAR,"increment":Token.TokenType.INCREMENT,"decrement":Token.TokenType.DECREMENT,"string":Token.TokenType.TYPE_STRING,"bool":Token.TokenType.TYPE_BOOL,"num":Token.TokenType.TYPE_NUM,"break":Token.TokenType.BREAK,"end":Token.TokenType.END,"while":Token.TokenType.WHILE,"playsnd":Token.TokenType.PLAY_SND,"wait":Token.TokenType.WAIT,"set_property":Token.TokenType.SET_PROPERTY,"tween_property":Token.TokenType.TWEEN_PROPERTY,"IN":Token.TokenType.IN,"OUT":Token.TokenType.OUT,"IN_OUT":Token.TokenType.IN_OUT,"OUT_IN":Token.TokenType.OUT_IN,"create_sprite":Token.TokenType.CREATE_SPRITE,"send_sin":Token.TokenType.SIN,"send_cos":Token.TokenType.COS,"create_animated_sprite":Token.TokenType.CREATE_ANIMATED_SPRITE,"add_sprite_frame":Token.TokenType.ADD_SPRITE_FRAME,"clear_sprite_frames":Token.TokenType.CLEAR_SPRITE_FRAMES,"play_animated_sprite":Token.TokenType.PLAY_ANIMATED_SPRITE,"stop_animated_sprite":Token.TokenType.STOP_ANIMATED_SPRITE,"reparent_to_root":Token.TokenType.REPARENT_TO_ROOT,"send_property":Token.TokenType.SEND_PROPERTY,"process_frame":Token.TokenType.PROCESS_FRAME,"send_x":Token.TokenType.SEND_X,"send_y":Token.TokenType.SEND_Y,"math":Token.TokenType.MATH,"rand":Token.TokenType.RAND,"create_obj":Token.TokenType.CREATE_OBJECT,"set_sprite":Token.TokenType.SET_SPRITE,"give_item":Token.TokenType.GIVE_ITEM,"reparent":Token.TokenType.REPARENT,"play_audio":Token.TokenType.PLAY_AUDIO,"stop_audio":Token.TokenType.STOP_AUDIO,"set_audio":Token.TokenType.SET_AUDIO,"pause_audio":Token.TokenType.PAUSE_AUDIO,"set_variable":Token.TokenType.SET_VARIABLE,"wait_frames":Token.TokenType.WAIT_FRAMES,"start_encounter":Token.TokenType.START_ENCOUNTER,"function":Token.TokenType.FUNCTION,"create_custom_obj":Token.TokenType.CREATE_CUSTOM_OBJECT,"create_text":Token.TokenType.CREATE_TEXT,"create_text_typer":Token.TokenType.CREATE_TEXT,"wait_for_signal":Token.TokenType.WAIT_FOR_SIGNAL,"get_flag":Token.TokenType.GET_FLAG,"set_flag":Token.TokenType.SET_FLAG,"start_dialogue":Token.TokenType.START_DIALOGUE}
var verbose = false

func _init():
	data = []

func isNum(string : String) -> bool:
	for i in string:
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
	if verbose:
		print("Lexeme: \""+data[-1].lexeme+"\" Type: "+str(data[-1].type)+" Value: "+str(data[-1].value))
