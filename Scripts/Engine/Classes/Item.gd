class_name Item
extends Resource

enum {HEALING,WEAPON,ARMOR,SPECIAL}

@export var itemName : String
@export var type : int
@export var value : int
@export var use : String
@export var check : Array

func _init(itemname = "Item",itemtype = SPECIAL,itemvalue = 0,Check = ["* Item[newline]  It's an item."],Use = "You used the Item."):
	itemName = itemname
	type = itemtype
	value = itemvalue
	use = Use
	check = Check
