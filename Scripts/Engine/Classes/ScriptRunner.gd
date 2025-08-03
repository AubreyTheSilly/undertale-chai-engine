class_name ScriptRunner
extends Node

## File path from Scripts/ to the script file.
@export var script_to_run : String
## Must be set for like create and set functions to work.
@export var node : Node

var audio : AudioStreamPlayer = AudioStreamPlayer.new()

var types = {
	Token.TokenType.STRING:Token.TokenType.TYPE_STRING,
	Token.TokenType.BOOLEAN:Token.TokenType.TYPE_BOOL,
	Token.TokenType.NUMBER:Token.TokenType.TYPE_NUM
}

var ifoperators = [5, 7, 8, 9, 10, 11]

var vars : Dictionary[String,UMVar]

func _ready():
	audio.max_polyphony = 1024
	add_child(audio)
	run_script()

func run_script() -> Error:
	if !script_to_run:
		push_error("There is no script to run! Make sure to set script_to_run!!")
		return ERR_DOES_NOT_EXIST
	
	var runscript : UTScript = UTScript.loadScriptFromFile(script_to_run)
	vars.clear()
	
	var line : int = 0
	var skip_depth = 0
	var depth = 0
	
	var while_line = -1
	var while_depth = -1
	
	while line < runscript.data.size()-1:
		line += 1
		
		var ogstringtokens : Dictionary[int,Token] = {}
		
		if skip_depth != 0:
			if runscript.data[line].data[0].type == Token.TokenType.END:
				skip_depth -= 1
				depth -= 1
			continue
		if runscript.data[line].data.size() != 0:
			var token = runscript.data[line].data[0]
			var stringtokenno = -1
			for i in runscript.data[line].data:
				stringtokenno += 1
				if i.type == Token.TokenType.STRING:
					ogstringtokens[stringtokenno] = Token.new(i.lexeme,i.type,i.value)
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
							replace = i.value.substr(start,(end-start)+1)
							replacevar = replace.rstrip("%").lstrip("%")
							
							if vars.has(replacevar):
								if vars[replacevar].type == Token.TokenType.TYPE_NUM and str(vars[replacevar].value).ends_with(".0"):
									i.value = i.value.replace(replace,str(vars[replacevar].value).substr(0,str(vars[replacevar].value).length()-2))
								else:
									i.value = i.value.replace(replace,str(vars[replacevar].value))
							
							index -= replace.length()
							index += str(vars[replacevar].value).length()
							
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
							vars[runscript.data[line].data[2].lexeme] = variable
						else:
							push_error("line "+str(line+1)+": Failed to input an identifier for var")
					else:
						push_error("line "+str(line+1)+": Not a data type")
				Token.TokenType.SET:
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						if vars.has(runscript.data[line].data[1].lexeme):
							if vars[runscript.data[line].data[1].lexeme].type == types[runscript.data[line].data[2].type]:
								vars[runscript.data[line].data[1].lexeme].value = runscript.data[line].data[2].value
							else:
								push_error("line "+str(line+1)+": Variable set type does not match!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for set")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for set")
				Token.TokenType.INCREMENT:
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						if vars.has(runscript.data[line].data[1].lexeme):
							if vars[runscript.data[line].data[1].lexeme].type == Token.TokenType.TYPE_NUM:
								vars[runscript.data[line].data[1].lexeme].value += 1.0
							else:
								push_error("line "+str(line+1)+": Variable must be a num!")
						else:
							push_error("line "+str(line+1)+": You must enter an existing variable for increment")
					else:
						push_error("line "+str(line+1)+": You must enter a valid identifier for increment")
				Token.TokenType.DECREMENT:
					if runscript.data[line].data[1].type == Token.TokenType.IDENTIFIER:
						if vars.has(runscript.data[line].data[1].lexeme):
							if vars[runscript.data[line].data[1].lexeme].type == Token.TokenType.TYPE_NUM:
								vars[runscript.data[line].data[1].lexeme].value -= 1.0
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
						push_error("line "+str(line+1)+": You must add a valid operator for if")
					elif runscript.data[line].data.size() == 3:
						push_error("line "+str(line+1)+": You must have a valid number of arguments for if")
					else:
						if vars.has(runscript.data[line].data[1].lexeme):
							runscript.data[line].data[1].value = vars[runscript.data[line].data[1].lexeme].value
						if vars.has(runscript.data[line].data[3].lexeme):
							runscript.data[line].data[3].value = vars[runscript.data[line].data[3].lexeme].value
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
						if vars.has(runscript.data[line].data[1].lexeme):
							runscript.data[line].data[1].value = vars[runscript.data[line].data[1].lexeme].value
						if vars.has(runscript.data[line].data[3].lexeme):
							runscript.data[line].data[3].value = vars[runscript.data[line].data[3].lexeme].value
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
				Token.TokenType.PLAY_SND:
					if runscript.data[line].data.size() == 1:
						push_error("line "+str(line+1)+": You must have a sound to play for playsnd")
						continue
					elif runscript.data[line].data[1].type != Token.TokenType.STRING:
						push_error("line "+str(line+1)+": You must put a string for playsnd")
						continue
					audio.stream = Loader.load_file("Audio/Sounds/"+runscript.data[line].data[1].value+".wav")
					if audio.stream:
						audio.play()
					else:
						audio.stream = Loader.load_file("Audio/Sounds/"+runscript.data[line].data[1].value+".ogg")
						if audio.stream:
							audio.play()
						else:
							push_error("line "+str(line+1)+": Sound \""+runscript.data[line].data[1].value+"\" does not exist")
				Token.TokenType.WAIT:
					if runscript.data[line].data[1].type != Token.TokenType.NUMBER:
						push_error("line "+str(line+1)+": You must input a valid number")
						continue
					await get_tree().create_timer(runscript.data[line].data[1].value).timeout
				_:
					unhandled_function(runscript.data[line])
		for i in ogstringtokens:
			runscript.data[line].data[i] = ogstringtokens[i]
	print("Script finished executing")
	return OK

func unhandled_function(line : TokenArray):
	print(line.data[0].lexeme)
