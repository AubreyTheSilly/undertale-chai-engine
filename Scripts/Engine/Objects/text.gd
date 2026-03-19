@tool
class_name TextObject
extends Node2D

@export var text : String
@export var character_spacing : float = 8
@export var extra_font_spacing : Dictionary[String,float]
@export var line_spacing : float = 16
@export var size : int = 13
@export var font : Font

func _draw():
	if !font:
		return
	var mode = "normal"
	var drawposition = Vector2(0,0)
	var color = Color.WHITE
	var cmd = false
	var command = ""
	var index = -1
	for i in text:
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
						draw_char(font,drawposition+Vector2(0,size),i,size,color)
					drawposition.x += character_spacing
					if extra_font_spacing.has(i):
						drawposition.x += extra_font_spacing[i]

func _process(_delta):
	queue_redraw()
