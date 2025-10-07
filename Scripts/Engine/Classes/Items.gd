extends Node

var STICK = Item.new("Stick",Item.WEAPON,0,["* Stick - +0 ATK[wait 2][newline]  Its bark is worse than its[newline] bite."],["* You brandished the Stick."])
var BANDAGE = Item.new("Bandage",Item.ARMOR,0,["* Bandage - +0 DEF[wait 2][newline]  It has already been used[newline]  many times."],["* You re-applied the bandage.[wait 2][newline]  Still kind of gooey."])
var MONSTER_CANDY = Item.new("Monster Candy",Item.HEALING,10,["* Monster Candy - Heals 10 HP[wait 2][newline]  Has a distinct, non-licorice[newline]  flavor."],["* You ate the Monster Candy.[wait 2][newline]  Very un-licorice-like.","* You ate the Monster Candy.[wait 2][newline]  ...tastes like licorice."],"MnstrCandy")
var REALKNIFE = Item.new("Real Knife",Item.WEAPON,99,["* add later"],["[color 255 0 0]* Here we are!"])
var LOCKET = Item.new("The Locket",Item.ARMOR,99,["* add later"],["* Right where it belongs."])
