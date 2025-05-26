class_name EnemyData
extends Resource

@export var EnemyName := "Dummy"
@export var EnemySprite : Texture2D = preload("res://Sprites/Battle/Enemies/spr_dummybattle_0.png")
@export var EnemyHurtSprite : Texture2D = preload("res://Sprites/Battle/Enemies/spr_dummybattle_1.png")
@export var EnemySpareSprite : Texture2D = preload("res://Sprites/Battle/Enemies/spr_dummybattle_0.png")
@export var HP := 100
@export var ATK := 0
@export var DEF := 0
@export var acts := ["Check","Talk"]
@export var RandomDialogs = ["Dialog[newline]test."]
@export var Check := ["* DUMMY - ATK 0 DEF 0[wait 2][newline]  A cotton heart and a button eye,[newline]  you are the apple of my eye"]
@export var InstantSpare := false
@export var FlavorText = ["* Example text"]
@export var BubbleType := "Small Right"
