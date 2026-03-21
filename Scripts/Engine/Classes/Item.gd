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

static func LoadItemFromFile(itemname : String) -> Item:
	var itemFile = FileAccess.open(Undermaker.Path+"Data/items/"+itemname+".txt",FileAccess.READ)
	if !itemFile:
		return
	var itemArray = itemFile.get_line().split(":")
	itemFile.close()
	var item = Item.new(itemArray[0],int(itemArray[1]),int(itemArray[2]),itemArray[3].split("|"),itemArray[4].split("|"),itemArray[5],itemArray[6])
	return item

static func GetItemList() -> Dictionary:
	var itemArray := {}
	var itemFile = Undermaker.loadJsonAsDictionary("Data/items.json")
	if !itemFile:
		return {}
	for i in itemFile:
		var item = itemFile[i]
		print(i,item)
		if item is not Dictionary:
			push_error("Item "+i+" is invalid.")
			continue
		elif !item.has("itemName"):
			push_error("Item "+i+" is missing an item name.")
			continue
		elif !item.has("type"):
			push_error("Item "+i+" is missing a type.")
			continue
		elif !item.has("value"):
			continue
		elif !item.has("use"):
			continue
		elif !item.has("check"):
			continue
		var newitem = Item.new(item["itemName"],item["type"],item["value"],item["check"],item["use"])
		if item.has("short"):
			newitem.short = item["short"]
		if item.has("serious"):
			newitem.serious = item["serious"]
		itemArray[i] = newitem
	return itemArray
