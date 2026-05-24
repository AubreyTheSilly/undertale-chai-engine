extends Node2D

func _ready():
	var script = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript")
	$AdvancedScriptRunner.runScript(script,self)
