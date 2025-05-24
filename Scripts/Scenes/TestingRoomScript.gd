extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Undermaker.player_can_move = false
	await DialogueHandler.StartDialogue(["* [color 255 255 0][speed 2]Frisk[color 255 255 255]...[wait 4][speed 1][newline]  I remember your [speed 4][mode shaky][color 255 0 0]genocides[color 255 255 255].","* anyways bye"])
	await $Character.move(1,Vector2.UP)
	await get_tree().create_timer(1).timeout
	await $Character.move(1,Vector2.DOWN)
	await DialogueHandler.StartDialogue(["* sorry i went the [color 0 0 255][mode wavy]wrong way"])
	$Character.Speed = 5
	await $Character.move(1,Vector2.RIGHT)
	await $Character.move(2,Vector2.DOWN)
	Undermaker.player_can_move = true
