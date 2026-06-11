class_name AdvancedObjectScriptRunner
extends AdvancedScriptRunner

var objname := "object"
var timer := 0.0
var frametimer := 0.0

func _enter_tree():
	await runScript(loadScriptFromFile("Objects/"+objname),get_parent())
	
	for signal_info in get_parent().get_signal_list():
		var signal_name = signal_info["name"]
		
		get_parent().connect(signal_name,func(...args:Array):
			_on_signal(signal_name,args))
	
	runSingleFunction("_ready")
	
	#if script_to_run:
		#run_script(script_to_run,"Create")

func _process(_delta):
	timer += _delta
	frametimer += 2
	custom_variables["TIMER"] = timer
	custom_variables["FRAME_TIMER"] = frametimer
	runSingleFunction("_update")

func _physics_process(_delta):
	runSingleFunction("_physics_update")

func _on_signal(signal_name:String,args:Array):
	runSingleFunction("_"+signal_name,args)
