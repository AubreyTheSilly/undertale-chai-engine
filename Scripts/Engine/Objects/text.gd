@tool
class_name TextObject
extends Node2D

@export var text : String
@export var character_spacing : float = 8
@export var extra_font_spacing : Dictionary
@export var line_spacing : float = 16
@export var size : int = 13
@export var font : Font

@export var centered := false

func load_font_data(fontname:String) -> void:
	var data = {
		"font":"DTM-Mono.otf",
		"line_spacing":16.0,
		"character_spacing":8.0,
		"size":13,
		"extra_character_spacing":{}
	}
	var fontdict = Undermaker.loadJsonAsDictionary("/Data/fontdata/"+fontname+".json")
	if fontdict:
		for i in fontdict:
			data[i] = fontdict[i]
	
	var newfont := FontFile.new()
	newfont.load_dynamic_font(Undermaker.Path+"/Fonts/"+str(data["font"]))
	font.antialiasing = 0
	font.subpixel_positioning = 1
	
	font = newfont
	line_spacing = float(data["line_spacing"])
	character_spacing = float(data["character_spacing"])
	size = int(data["size"])
	extra_font_spacing = data["extra_character_spacing"]

func get_processed_text() -> String:
	var Text = ""
	
	var _xoffset = 0
	var _cmd = false
	
	var newlining = false
	
	for i in text:
		if _cmd and i == "]":
			Text += i
			_cmd = false
			continue
		elif _cmd:
			Text += i
			continue
		elif !_cmd and i == "[":
			Text += i
			_cmd = true
			continue
		if newlining and i == " ":
			continue
		else:
			newlining = false
		Text += i
		_xoffset += character_spacing
		if extra_font_spacing.has(i):
			_xoffset += extra_font_spacing[i]
	
	return Text

func get_font_end_offset() -> Vector2:
	var drawposition = Vector2.ZERO
	var _cmd = false
	var cmd = ""
	
	if !font:
		return Vector2.ZERO
	
	for i in get_processed_text():
		if _cmd and i != "]":
			cmd += i
			continue
		match i:
			"[":
				_cmd = true
				cmd = ""
			"]":
				_cmd = false
				if cmd == "newline":
					drawposition.x = 0
					drawposition.y += line_spacing
			_:
				drawposition.x += character_spacing
				if extra_font_spacing.has(i):
					drawposition.x += extra_font_spacing[i]
	return drawposition

func _draw():
	if !font:
		return
	var mode = "normal"
	var drawposition = Vector2.ZERO
	var color = Color.WHITE
	if !Engine.is_editor_hint():
		color = Undermaker.accents["primary"]
	var cmd = false
	var command = ""
	var index = -1
	for i in get_processed_text():
		index += 1
		match i:
			"[":
				cmd = true
				command = ""
			"]":
				cmd = false
				var commandlist = command.split(":")
				if commandlist.size() != 0:
					match commandlist[0]:
						"newline":
							drawposition.x = 0
							drawposition.y += line_spacing
						"color":
							if commandlist.size() == 4:
								color.r = float(commandlist[1])/255
								color.g = float(commandlist[2])/255
								color.b = float(commandlist[3])/255
							elif commandlist.size() == 2:
								if Undermaker.accents.has(commandlist[1]):
									color = Undermaker.accents[commandlist[1]]
						"mode":
							mode = commandlist[1]
			_:
				if cmd:
					command += i
				else:
					if mode == "shaky":
						draw_char(font,drawposition+Vector2(0,size)+Vector2(randf_range(-0.5,0.5),randf_range(-0.5,0.5)),i,size,color)
					elif mode == "wavy" and !Engine.is_editor_hint():
						draw_char(font,drawposition+Vector2(0,size)+(Vector2(cos((Undermaker.timer+(index*5))/10),sin((Undermaker.timer+(index*5))/10))*1),i,size,color)
					else:
						draw_set_transform(drawposition/2,0,Vector2(0.5,0.5))
						
						# NOTE: deprecated because it DIDN'T FUCKING WORK ANYWAYS
						# draw_char(font,drawposition+Vector2(0,size),i,size,color)
						# draw_string(font,drawposition+Vector2(0,size),i,0,-1,size,color)
						# PLEASE fucking work
						#if Undermaker.font_glyphs.has(font.get_font_name()):
							#if Undermaker.font_glyphs[font.get_font_name()].has(i):
								#var tex = Undermaker.font_glyphs[font.get_font_name()][i]
								#draw_texture(tex,drawposition+(Vector2(0,size)),color)
							#else:
								#draw_char(font,drawposition+Vector2(0,size),i,size*2,color)
						#else:
							#draw_char(font,drawposition+Vector2(0,size),i,size*2,color)
						draw_char(font,drawposition+Vector2(0,size*2),i,size*2,color)
						
					drawposition.x += character_spacing
					if extra_font_spacing.has(i):
						drawposition.x += extra_font_spacing[i]

func get_line_count() -> int:
	var lines = 1
	
	lines += get_processed_text().count("[newline]")
	
	return lines

func _process(_delta):
	queue_redraw()
