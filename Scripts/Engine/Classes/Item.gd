class_name Item
extends Resource

enum {HEALING,WEAPON,ARMOR,SPECIAL}

@export var itemName : String
@export var type : int
@export var value : int
@export var use : Array
@export var check : Array
@export var short : String
@export var serious : String

func _init(itemname = "Item",itemtype = SPECIAL,itemvalue = 0,Check = ["* Item[newline]  It's an item."],Use = ["You used the Item."],Short="",Serious=""):
	itemName = itemname
	type = itemtype
	value = itemvalue
	use = Use
	check = Check
	if Short.length() == 0:
		short = itemname
	else:
		short = Short
	if Serious.length() == 0:
		serious = itemname
	else:
		serious = Serious
