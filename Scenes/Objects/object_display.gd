extends Node2D

@export var objname := ""
@export var objtype := ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = objname+"\n("+objtype+")"
	$Sprite2D.texture = Undermaker.get_object_image(objtype,RoomInstance.new())
