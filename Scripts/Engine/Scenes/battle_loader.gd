extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	await $LineEdit.text_submitted
	while $LineEdit.text == "":
		await $LineEdit.text_submitted
	Battle.Encounter($LineEdit.text,false)
