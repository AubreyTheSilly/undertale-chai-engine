extends ScriptRunner

func _ready():
	if script_to_run:
		run_script(script_to_run,"Create")

func _process(_delta):
	if script_to_run:
		run_script(script_to_run,"Update")
