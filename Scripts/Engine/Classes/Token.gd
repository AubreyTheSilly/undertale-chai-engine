class_name Token
extends Resource

enum TokenType {
	# note: most of these are shamelessly stolen from Crafting Interpreters
	# single character tokens
	MINUS, PLUS, SLASH, STAR,
	
	# 1-2 character tokens
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL,
	
	# literals
	IDENTIFIER, STRING, NUMBER, BOOLEAN,
	
	# keywords
	IF, ELSE, PRINT, VAR, SET, INCREMENT, DECREMENT, TYPE_STRING, TYPE_BOOL, TYPE_NUM, WHILE, BREAK, END, PLAY_SND,WAIT,SET_PROPERTY,TWEEN_PROPERTY,CREATE_SPRITE,SIN,COS,CREATE_ANIMATED_SPRITE,ADD_SPRITE_FRAME,CLEAR_SPRITE_FRAMES,PLAY_ANIMATED_SPRITE,STOP_ANIMATED_SPRITE,REPARENT_TO_ROOT,SEND_PROPERTY,PROCESS_FRAME,SEND_X,SEND_Y,MATH,RAND,
	# other keywords, used for special functions
	IN,OUT,IN_OUT,OUT_IN}

var lexeme : String
var type : TokenType
var value : Variant

func _init(Lexeme : String,tokentype : TokenType,data : Variant):
	lexeme = Lexeme
	type = tokentype
	value = data
