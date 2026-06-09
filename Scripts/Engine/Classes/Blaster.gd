 	# THIS CODE IS LARGLY PORTED FROM ILOVECOOKIES'S TML ENGINE GASTER BLASTER SYSTEM!!!! THEY'RE AWESOMESAUCE (and their code is easier to read than toby's :sob:)

class_name Blaster
extends Node2D

@export var initial_position := Vector2.ZERO
@export var target_position := Vector2(100,100)
@export var target_rotation := 90

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export var kr_damage := 10

var blast_cooldown := 10
var blast_duration := 25
var blast := false

var velocity := 0

var animate_beam := 5

var beam : Node2D

var counter := 0

var stage := "coming"
var playanimation := false

var alpha_is_ready:= false
var can_continue:=false

var BlasterDuration := 25

@onready var charge = $ChargeSound
@onready var fire = $FireSound
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	global_position = initial_position

func _process(_delta) -> void:
	position += Vector2.from_angle(deg_to_rad(rotation_degrees+90))*velocity
	
	counter += 1
	BlasterDuration -= 1
	
	if counter == 1 and stage == "coming":
		charge.play()
		create_tween().tween_property(self,"position",target_position,float(BlasterDuration)/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		create_tween().tween_property(self,"rotation_degrees",target_rotation+180,float(BlasterDuration)/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
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
			beam = preload("res://Scenes/Objects/blasterBeam.tscn").instantiate()
			beam.position = Vector2(0,40)
			beam.scale.y = 0
			beam.modulate.a = 0
			beam.damage = damage
			beam.kr_damage = kr_damage
			create_tween().tween_property(beam,"scale:y",1,5.0/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			create_tween().tween_property(beam,"modulate:a",1,5.0/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			add_child(beam)
	
	if stage == "shoot!":
		animate_beam -= 1
		if beam:
			velocity = -15
			if animate_beam <= 0:
				blast_duration -= 1
				if blast_duration > 5:
					beam.scale.y = lerp(beam.scale.y,beam.scale.y+sin(counter)*1,0.1)
				else:
					stage = "beam_end"
					create_tween().tween_property(beam,"scale:y",0,25.0/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
					create_tween().tween_property(beam,"modulate:a",0,25.0/30.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	if stage == "beam end":
		if beam:
			if beam.modulate.a < 0.1:
				beam.queue_free()
	
	# end of stolen i mean BORROWED code
	
	match attack_type.to_lower():
		"blue":
			modulate = Undermaker.accents["blueattack"]
		"orange":
			modulate = Undermaker.accents["orangeattack"]
		"green":
			modulate = Undermaker.accents["greenattack"]
		_:
			modulate = Undermaker.accents["primary"]
	if beam:
		var olda = beam.modulate.a
		match attack_type.to_lower():
			"blue":
				beam.modulate = Undermaker.accents["blueattack"]
			"orange":
				beam.modulate = Undermaker.accents["orangeattack"]
			"green":
				beam.modulate = Undermaker.accents["greenattack"]
			_:
				beam.modulate = Undermaker.accents["primary"]
		beam.modulate.a = olda
