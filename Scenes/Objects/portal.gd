class_name Portal
extends Area2D

### Sends you to 'Data/rooms/[destination].json'.
@export var destination : String
### Position for the player to appear at in the new room. In tiles.
@export var exitpos : Vector2 = Vector2.ZERO

func _ready():
	pass

func _process(_delta):
	for i in get_overlapping_bodies():
		if i.name.to_lower().contains("player") and !PlayerData.player_teleporting:
			PlayerData.player_teleporting = true
			PlayerData.player_teleport_position = exitpos
			await fader.fadeIn()
			if get_tree().current_scene is RoomLoader:
				get_tree().current_scene.roomName = destination
				get_tree().current_scene.LoadRoom()
