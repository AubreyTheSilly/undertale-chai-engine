extends Node2D

func _ready():
	var script = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript4")
	$AdvancedScriptRunner.runScript(script,self)
