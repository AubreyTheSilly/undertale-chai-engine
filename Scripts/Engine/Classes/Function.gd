class_name Function
extends Resource

var name : String
var parameters : Array[StringName]
var flags : Array[StringName]

func _init(Name:String,Param:Array[StringName],Flags:Array[StringName]):
	name = Name
	parameters = Param
	flags = Flags
