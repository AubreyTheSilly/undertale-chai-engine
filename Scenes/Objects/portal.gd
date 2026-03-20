class_name Portal
extends Trigger

### Sends you to 'Data/rooms/[destination].json'.
@export var destination : String
### Position for the player to appear at in the new room. In tiles.
@export var exitpos : Vector2 = Vector2.ZERO

func _triggered() -> void:
	print("portal triggered")
	if !PlayerData.player_teleporting:
		PlayerData.player_teleporting = true
		PlayerData.player_teleport_position = exitpos*10
		await fader.fadeOut()
		if get_tree().current_scene is RoomLoader:
			Undermaker.load_scene(destination)
