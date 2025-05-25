extends Node

@export var Name = "Chara"
@export var HP = 20
@export var MaxHP = 20
@export var LV = 1
@export var ATK = 0
@export var DEF = 0
@export var weapon : Item = Items.STICK
@export var armor : Item = Items.BANDAGE
@export var inventory : Array[Item] = []
@export var flags : Dictionary
@export var fun : int = randi_range(0,100)
