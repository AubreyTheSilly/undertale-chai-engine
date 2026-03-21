extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if PlayerData.flags.has("clover"):
		if PlayerData.flags["clover"] == false:
			Undermaker.player_can_move = true
			PlayerData.flags["clover"] = true
			if PlayerData.EXP == 0:
				await DialogueHandler.StartDialogue(["* oh sorry i didn't realise[newline]  it would attack you","* my bad"])
			else:
				await DialogueHandler.StartDialogue(["* bro did you just fucking kill that doggy","* that's a genocide","* sans get this mf"])
				Battle.Encounter("dustsans")
	else:
		PlayerData.flags["clover"] = false
		Undermaker.player_can_move = false
		await DialogueHandler.StartDialogue(["* Hello Frisk.[wait 2][newline]  It's me, [color 255 255 0]Clover[color 255 255 255].","* Goodbye forever"])
		await $Character.move(4,Vector2.UP)
		await get_tree().create_timer(1).timeout
		await $Character.move(4,Vector2.DOWN)
		await DialogueHandler.StartDialogue(["* sorry i went the [color 0 0 255][mode wavy]wrong way"])
		await $Character.move(2,Vector2.RIGHT)
		await $Character.move(5,Vector2.DOWN)
		$Character.direction = "up"
		await DialogueHandler.StartDialogue(["* oh yeah","* one more thing","* look at this dog i found"])
		Battle.Encounter("dog")
