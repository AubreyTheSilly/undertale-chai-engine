class_name UTScript
extends Resource

var data : Array[Function]

func _init(scr:Array[Function]=[]):
	data = scr

func loadScript(path:StringName) -> Error:
	print("Loading script at "+Undermaker.Path+"Scripts/"+path)
	if FileAccess.file_exists(Undermaker.Path+"Scripts/"+path):
		var script : Array[Function]
		var scriptFile = FileAccess.open(Undermaker.Path+"Scripts/"+path,FileAccess.READ)
		while scriptFile.get_position() < scriptFile.get_length():
			var line := scriptFile.get_line()
			var funct := ""
			var params : Array[String] = []
			var flags : Array[String] = []
			var string = false
			var sub = ""
			for i in line:
				if funct == "":
					if i == " ":
						funct = sub
						sub = ""
					else:
						sub += i
				else:
					if i == " " and !string:
						if sub[0] == "-":
							flags.append(sub)
						else:
							params.append(sub)
						sub = ""
					elif i == '"':
						string = !string
					else:
						sub += i
			if sub != "":
				if funct == "":
					funct = sub
				else:
					if sub[0] == "-":
						flags.append(sub)
					else:
						params.append(sub)
			script.append(Function.new(funct,params,flags))
		data = script
		print("Successfully loaded script!")
		return OK
	print("Script does not exist")
	return FAILED
