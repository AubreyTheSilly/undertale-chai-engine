class_name Setting
extends Resource

enum TYPE {INT,BOOL_ONOFF,BOOL_YN}
var typestrings = {"int":TYPE.INT,"onoff":TYPE.BOOL_ONOFF,"yn":TYPE.BOOL_YN}

var name : String
var type : TYPE
var value : Variant

func _init(Name : String,Type : TYPE,StartingValue : Variant = 0.01):
	name = Name
	type = Type
	match Type:
		TYPE.INT:
			if StartingValue == 0.01:
				value = 0
			elif StartingValue is int:
				value = StartingValue
		TYPE.BOOL_ONOFF,TYPE.BOOL_YN:
			if StartingValue == 0.01:
				value = false
			elif StartingValue is bool:
				value = StartingValue
