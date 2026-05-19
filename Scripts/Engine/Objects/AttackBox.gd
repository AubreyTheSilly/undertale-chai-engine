class_name AttackBox
extends StaticBody2D

@export var rect : Rect2 = Rect2(Vector2(0,0),Vector2(288,70.5))

var vars = {}
var frame := 0

# for scripts
var box_width : float = 0
var box_height : float = 0

# for attack mode 2
var running = false

signal attack_over

func _process(_delta):
	frame += 1
	$AttackRect.size = lerp($AttackRect.size,rect.size,0.4)
	var offset = -$AttackRect.size/2.0
	var targetPos = Vector2(144.0,35.25)
	$AttackRect.position = targetPos+offset
	
	$CollisionShape2D.position.x = 144-float($AttackRect.size.x/2)+1.5
	$CollisionShape2D2.position.x = 144+float($AttackRect.size.x/2)-1.5
	$CollisionShape2D3.position.y = 35.25-float($AttackRect.size.y/2)+1.5
	$CollisionShape2D4.position.y = 35.25+float($AttackRect.size.y/2)-1.5
	
	var box_size = Vector2(float($AttackRect.size.x),float($AttackRect.size.y))-Vector2(6.0,6.0)
	box_width = rect.size.x
	box_height = rect.size.y
	$attacks/bounding.polygon = [Vector2(-box_size.x/2,-box_size.y/2),Vector2(-box_size.x/2,box_size.y/2),Vector2(box_size.x/2,box_size.y/2),Vector2(box_size.x/2,-box_size.y/2)]
#
#func runScript(scr : String,enemy_data : EnemyData):
	##if scr == "":
		##attack_over.emit()
	##await get_tree().process_frame
	#var scriptrunner = preload("res://Scenes/Objects/attackscriptrunner.tscn").instantiate()
	#scriptrunner.node = self
	#scriptrunner.enemydata = enemy_data
	#add_child(scriptrunner)
	#scriptrunner.run_script(scr)
	#await scriptrunner.script_finished
	#attack_over.emit()
#
#func runAttack(attack : AttackData,enemy_data : EnemyData):
	##if scr == "":
		##attack_over.emit()
	##await get_tree().process_frame
	#frame = 0
	#var scriptrunner = preload("res://Scenes/Objects/attackscriptrunner.tscn").instantiate()
	#scriptrunner.node = self
	#scriptrunner.enemydata = enemy_data
	#scriptrunner.running = true
	#add_child(scriptrunner)
	#while scriptrunner.running:
		#scriptrunner.frame += 1
		#scriptrunner.run_script(attack.attack_script)
		#await get_tree().process_frame
	#attack_over.emit()

func runScript(scr : String,enemy_data : EnemyData):
	#if scr == "":
		#attack_over.emit()
	#await get_tree().process_frame
	var scriptrunner := AdvancedScriptRunner.new()
	scriptrunner.custom_constants["enemydata"] = enemy_data
	add_child(scriptrunner)
	scriptrunner.runScript(AdvancedScriptRunner.loadScriptFromFile(scr),self)
	while scriptrunner.is_running:
		await get_tree().process_frame
	attack_over.emit()
	scriptrunner.queue_free()

func runAttack(attack : AttackData,enemy_data : EnemyData):
	#if scr == "":
		#attack_over.emit()
	#await get_tree().process_frame
	frame = 0
	var scriptrunner = preload("res://Scenes/Objects/attackscriptrunner.tscn").instantiate()
	scriptrunner.node = self
	scriptrunner.enemydata = enemy_data
	scriptrunner.running = true
	add_child(scriptrunner)
	while scriptrunner.running:
		scriptrunner.frame += 1
		scriptrunner.run_script(attack.attack_script)
		await get_tree().process_frame
	attack_over.emit()
	scriptrunner.queue_free()
