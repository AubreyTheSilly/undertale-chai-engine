class_name UTScript
extends Resource

var data : Array[Function]

func _init(scr:Array[Function]=[]):
	data = scr

func loadScript(path:StringName) -> Error:
	if FileAccess.file_exists(Undermaker.Path+"Scripts/"+path):
		var script : Array[Function]
		var scriptFile = FileAccess.open(Undermaker.Path+"Scripts/"+path,FileAccess.READ)
		while scriptFile.get_position() < scriptFile.get_length():
			var line := scriptFile.get_line()
			var funct := ""
			var params : Array[StringName] = []
			var flags : Array[StringName] = []
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
						sub += '"'
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
		return OK
	print("Script does not exist")
	return FAILED
