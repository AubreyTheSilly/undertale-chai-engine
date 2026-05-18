extends Node2D

func _ready():
	var script = UTScriptAdvanced.loadScriptFromFile("Examples/TestScript")
	UTScriptAdvanced.runScript(script,self)
