extends ScriptRunner

# NOTE: the entire "create" and "update" etc. turns out it got made fucking obsolete by the signal things. so. uh. my bad LMAO

func _ready():
	for signal_info in node.get_signal_list():
		var signal_name = signal_info["name"]
		
		node.connect(signal_name,Callable(self,"_on_signal").bind(signal_name))
	#if script_to_run:
		#run_script(script_to_run,"Create")

#func _process(_delta):
	#if script_to_run:
		#run_script(script_to_run,"Update")
#
#func _physics_process(_delta):
	#if script_to_run:
		#run_script(script_to_run,"PhysicsUpdate")

func _on_signal(signal_name):
	if script_to_run:
		run_script(script_to_run,signal_name)
