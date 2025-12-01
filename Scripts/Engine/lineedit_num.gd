extends LineEdit

var valid_chars : Array[String] = ["0","1","2","3","4","5","6","7","8","9"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var ogpos = caret_column
	while true:
		var valid = true
		var j = 0
		for i in text:
			if !valid:
				continue
			if !valid_chars.has(i):
				valid = false
				text[j] = ""
			j += 1
		if valid:
			break
		if ogpos != text.length():
			ogpos-=1
	caret_column = ogpos
