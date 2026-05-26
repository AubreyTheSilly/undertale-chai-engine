# THIS CODE IS LARGLY PORTED FROM ILOVECOOKIES'S TML ENGINE GASTER BLASTER SYSTEM!!!! THEY'RE AWESOMESAUCE (and their code is easier to read than toby's :sob:)

class_name Blaster
extends Node2D

@export var initial_position := Vector2.ZERO
@export var target_position := Vector2(100,100)
@export var target_rotation := 90

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export var kr_damage := 10

var blast_cooldown := 5
var blast_duration := 50
var blast := false

var beam : Node

var counter := 0

var stage := "coming"
var playanimation := false

var follow:=false
var alpha_is_ready:= false
var can_continue:=false

var BlasterDuration := 30

@onready var charge = $ChargeSound
@onready var fire = $FireSound
@onready var sprite = $AnimatedSprite2D

func _process(_delta) -> void:
	counter += 1
	BlasterDuration -= 1
	
	if counter == 1 and stage == "coming":
		charge.play()
		create_tween().tween_property(self,"position",target_position,float(BlasterDuration)/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		create_tween().tween_property(self,"rotation_degrees",target_rotation,float(BlasterDuration)/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	if BlasterDuration == -1:
		stage = "blast cooldown"
	
	if playanimation:
		var targetframe = sprite.frame
		if sprite.frame < 4:
			if fmod(counter,2) == 0:
				targetframe += 1
		if sprite.frame > 3:
			if fmod(counter,3) == 0:
				targetframe += 1
		if targetframe > 5:
			targetframe = 4
		sprite.frame = targetframe
	
	if stage == "blast cooldown":
		blast_cooldown -= 1
		if blast_cooldown < 0:
			stage = "preparing for the blast"
	
	if stage == "preparing for the blast":
		playanimation = true
		if sprite.frame == 4:
			stage = "shoot!"
			fire.play()
