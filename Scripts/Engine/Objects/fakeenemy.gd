extends Sprite2D

@export var enemydata : EnemyData = EnemyData.new()
@onready var enemyname = get_parent().get_node("Page1/EnemyName")
@onready var filename = get_parent().get_node("Page1/FileName")
@onready var normalsprite = get_parent().get_node("Page1/NormalSprite")
@onready var hurtsprite = get_parent().get_node("Page1/HurtSprite")
@onready var sparesprite = get_parent().get_node("Page1/SpareSprite")
@onready var hp = get_parent().get_node("Page1/HP")
@onready var atk = get_parent().get_node("Page1/ATK")
@onready var def = get_parent().get_node("Page1/DEF")

var damaging = false

func _process(_delta):
	enemydata.EnemyName = enemyname.text
	enemydata.EnemySprite = Loader.load_file("Sprites/Battle/Enemies/"+normalsprite.text+".png")
	enemydata.EnemyHurtSprite = Loader.load_file("Sprites/Battle/Enemies/"+hurtsprite.text+".png")
	enemydata.EnemySpareSprite = Loader.load_file("Sprites/Battle/Enemies/"+sparesprite.text+".png")
	enemydata.HP = int(hp.text)
	enemydata.ATK = int(atk.text)
	enemydata.DEF = int(def.text)
	
	if damaging:
		texture = enemydata.EnemyHurtSprite
	else:
		texture = enemydata.EnemySprite

func Shudder():
	# enemy shake
	var shudder = 16
	damaging = true
	while shudder != 0:
		if (shudder < 0):
			shudder = (-((shudder + 2)))
		else:
			shudder = (-shudder)
		position.x = 60+shudder
		await get_tree().process_frame
		await get_tree().process_frame
	damaging = false


func _on_save_pressed():
	pass # Replace with function body.
