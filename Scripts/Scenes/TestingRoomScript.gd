extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Undermaker.player_can_move = false
	await DialogueHandler.StartDialogue(["* waow"])
	await $Character.move(1,Vector2.UP)
	await get_tree().create_timer(1).timeout
	await $Character.move(1,Vector2.DOWN)
	await DialogueHandler.StartDialogue(["* sorry i went the [color 0 0 255][mode wavy]wrong way"])
	$Character.Speed = 5
	await $Character.move(1,Vector2.RIGHT)
	await $Character.move(2,Vector2.DOWN)
	Undermaker.player_can_move = true
