class_name Enemy
extends Node2D

@export var enemy_data : EnemyData
@onready var sprite = $Sprite2D
@onready var flavorbox = get_parent().get_node("FlavorBox")

signal damage_done

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = enemy_data.EnemySprite
	$GPUParticles2D.process_material.set_shader_parameter("sprite",enemy_data.EnemyHurtSprite)
	$HPBar.max_value = enemy_data.HP
	$HPBar.value = enemy_data.HP
	_damage(15)

func _dust():
	$Sprite2D.visible = false
	$GPUParticles2D.start()

func shudder():
	var shudder = 16
	sprite.texture = enemy_data.EnemyHurtSprite
	while shudder != 0:
		if (shudder < 0):
			shudder = (-((shudder + 2)))
		else:
			shudder = (-shudder)
		sprite.position.x = shudder
		await get_tree().process_frame
		await get_tree().process_frame
	for i in range(15):
		await get_tree().process_frame
	$DamageText.visible = false
	$HPBar.visible = false
	if $HPBar.value == 0:
		_dust()
	else:
		sprite.texture = enemy_data.EnemySprite

func _damage(damage : float):
	if damage > 0:
		shudder()
		$DamageText/Label.label_settings.font_color = Color.RED
		$DamageText/Label.text = str(damage)
		$DamageText.bounce()
		$HPBar.visible = true
		var ogHP = $HPBar.value
		while $HPBar.value > (ogHP-damage):
			$HPBar.value -= (damage/15)
			await get_tree().process_frame
		await get_tree().create_timer(1).timeout

func act(Act : String) -> void:
	if Act == "Check":
		await flavorbox.StartBattleDialogue(enemy_data.Check)
	if Act == "Talk" and enemy_data.EnemyName == "Dummy":
		await flavorbox.StartBattleDialogue(["* You talk to the DUMMY.[wait 2][speed 3] ...","* It doesn't seem much for[newline]  conversation.","* TORIEL seems happy with you."])
