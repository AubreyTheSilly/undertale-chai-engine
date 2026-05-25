extends Node2D

func _ready():
	$TextObject.load_font_data("default")
	var script = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript")
	$AdvancedScriptRunner.runScript(script,self)
