class_name UTScript
extends Resource

var data : Array[TokenArray]

static var alnum = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-"
static var al = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
static var num = "0123456789"

static var tokens = ["+","-","*","/","!","=","<",">","if","else","true","false","print","set","var","increment","decrement","string","bool","num","break","end"]

func has_chars(checkstr:String,charstr:String) -> bool:
	for i in checkstr:
		if !charstr.contains(i):
			return false
	return true

func _init(scr:Array[TokenArray]=[]):
	data = scr
	
static func loadScriptFromFile(path:StringName) -> UTScript:
	if FileAccess.file_exists(Undermaker.Path+"Scripts/"+path):
		var script : UTScript = UTScript.new()
		var scriptFile = FileAccess.open(Undermaker.Path+"Scripts/"+path,FileAccess.READ)
		var scriptStr = scriptFile.get_as_text()
		scriptFile.close()
		var pointer := 0
		var buffer := ""
		var tokenbuffer : TokenArray = TokenArray.new()
		
		var string := false
		var comment := false
		
		while pointer <= scriptStr.length()-1:
			if scriptStr[pointer] == "\n":
				comment = false
			elif comment:
				pointer += 1
				continue
			match scriptStr[pointer]:
				" ","\t":
					if string:
						buffer += scriptStr[pointer]
					elif buffer:
						tokenbuffer.tokenize(buffer)
						buffer = ""
					pointer += 1
				"\n":
					if buffer:
						tokenbuffer.tokenize(buffer)
						buffer = ""
					script.data.append(tokenbuffer)
					tokenbuffer = TokenArray.new()
					pointer += 1
				"\"":
					if buffer:
						if buffer[0] != "\"":
							tokenbuffer.tokenize(buffer)
							buffer = ""
					buffer += "\""
					if !string:
						string = true
					else:
						string = false
						tokenbuffer.tokenize(buffer)
						buffer = ""
					pointer += 1
				"/":
					comment = true
					if scriptStr[pointer+1] == "/":
						pointer += 1
					pointer += 1
				"+","-","*","/":
					if string:
						buffer += scriptStr[pointer]
						pointer += 1
						continue
					tokenbuffer.tokenize(scriptStr[pointer])
					buffer = ""
					pointer += 1
				"=","<",">","!":
					if string:
						buffer += scriptStr[pointer]
						pointer += 1
						continue
					if scriptStr[pointer+1] == "=":
						tokenbuffer.tokenize(scriptStr[pointer]+scriptStr[pointer+1])
						pointer += 1
					else:
						tokenbuffer.tokenize(scriptStr[pointer])
					buffer = ""
					pointer += 1
				
				_:
					if alnum.contains(scriptStr[pointer]) or string:
						buffer += scriptStr[pointer]
					
					#if tokens.has(buffer):
						#tokenbuffer.tokenize(buffer)
						#buffer = ""
					
					pointer += 1
		if buffer:
			tokenbuffer.tokenize(buffer)
		if tokenbuffer.data:
			script.data.append(tokenbuffer)
		return script
	push_error("Script does not exist")
	return null

#func loadScript(path:StringName) -> Error:
	#if FileAccess.file_exists(Undermaker.Path+"Scripts/"+path):
		#var script : Array[Function]
		#var scriptFile = FileAccess.open(Undermaker.Path+"Scripts/"+path,FileAccess.READ)
		#while scriptFile.get_position() < scriptFile.get_length():
			#var line := scriptFile.get_line()
			#var funct := ""
			#var params : Array[StringName] = []
			#var flags : Array[StringName] = []
			#var string = false
			#var sub = ""
			#for i in line:
				#if funct == "":
					#if i == " ":
						#funct = sub
						#sub = ""
					#else:
						#sub += i
				#else:
					#if i == " " and !string:
						#if sub.length() == 0:
							#continue
						#if sub[0] == "_":
							#flags.append(sub)
						#else:
							#params.append(sub)
						#sub = ""
					#elif i == '"':
						#string = !string
						#sub += '"'
					#else:
						#sub += i
			#if sub != "":
				#if funct == "":
					#funct = sub
				#else:
					#if sub[0] == "_":
						#flags.append(sub)
					#else:
						#params.append(sub)
			#script.append(Function.new(funct,params,flags))
		#data = script
		#return OK
	#push_error("Script does not exist")
	#return FAILED
