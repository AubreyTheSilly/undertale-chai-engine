extends Node2D

func _ready():
	var script = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript")
	$AdvancedScriptRunner.runScript(script,self)
	var script2 = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript2")
	$AdvancedScriptRunner2.runScript(script2,self)
	var script3 = AdvancedScriptRunner.loadScriptFromFile("Examples/TestScript3")
	$AdvancedScriptRunner3.runScript(script3,self)
