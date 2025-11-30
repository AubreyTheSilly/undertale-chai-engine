extends Node2D

func _ready():
	$ScriptRunner.run_script($ScriptRunner.script_to_run,"update")
