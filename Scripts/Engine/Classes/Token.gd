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
	IF, ELSE, PRINT, VAR, SET, INCREMENT, DECREMENT, TYPE_STRING, TYPE_BOOL, TYPE_NUM, WHILE, BREAK, END, PLAY_SND,WAIT
}

var lexeme : String
var type : TokenType
var value : Variant

func _init(Lexeme : String,tokentype : TokenType,data : Variant):
	lexeme = Lexeme
	type = tokentype
	value = data
