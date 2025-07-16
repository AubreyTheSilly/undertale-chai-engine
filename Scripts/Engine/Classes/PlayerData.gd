extends Node

var Name = "Chara"
var HP : int = 20
var MaxHP : int = 20
var LV : int = 1
var EXP = 0
var GOLD = 0
var ATK : int = 0
var DEF : int = 0
var INV : int = 30
var weapon : Item = Items.STICK
var armor : Item = Items.BANDAGE
var inventory : Array[Item] = [Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY,Items.MONSTER_CANDY]
var flags : Dictionary
var fun : int = randi_range(0,100)
var room = "TestRoom"

var obj : Player
var player_can_move = true
var player_teleporting = false

func loadFile(newgame : bool = false):
	pass

func _process(_delta):
	HP = clampi(HP,0,MaxHP)
