extends Node2D

func _ready():
	var script = UTScriptAdvanced.loadScriptFromFile("Examples/TestScript2")
	UTScriptAdvanced.runScript(script,self)
