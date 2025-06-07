extends Node

var Name = "Chara"
var HP : int = 20
var MaxHP : int = 20
var LV : int = 1
var EXP = 0
var GOLD = 0
var ATK : int = 0
var DEF : int = 0
var weapon : Item = Items.STICK
var armor : Item = Items.BANDAGE
var inventory : Array[Item] = [Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY]
var flags : Dictionary
var fun : int = randi_range(0,100)
var audioplayer = AudioStreamPlayer.new()

func loadFile():
	pass
