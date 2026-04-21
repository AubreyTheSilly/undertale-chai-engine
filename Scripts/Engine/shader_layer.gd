extends CanvasLayer

@onready var template = $ShaderTemplate

# it has been confirmed to work, so.... no need for this anymore lol
#func _ready() -> void:
	#load_shader("TestShader")
	#await get_tree().create_timer(5).timeout
	#remove_shader("TestShader")

func load_shader(shaderName : String,parameters : Dictionary = {}) -> void:
	var shader = Shader.new()
	var file = FileAccess.open(Undermaker.Path+"Shaders/"+shaderName+".gdshader", FileAccess.READ)
	if file:
		var shader_code = file.get_as_text()
		shader.code = shader_code
	else:
		push_error(Undermaker.Path+"Shaders/"+shaderName+".gdshader doesn't exist.")
		return
	
	var shaderObj = template.duplicate()
	add_child(shaderObj)
	
	shaderObj.visible = true
	shaderObj.name = shaderName
	var material := ShaderMaterial.new()
	material.shader = shader
	for i in parameters:
		material.set_shader_parameter(i,parameters[i])
	
	shaderObj.get_node("ColorRect").material = material

func remove_shader(shaderName : String) -> void:
	if shaderName == "ShaderTemplate":
		push_error("YOU CANNOT DELETE THE SHADER TEMPLATE. WHAT THE FUCK ARE YOU DOING.")
		return
	if get_node_or_null(shaderName):
		get_node(shaderName).queue_free()
	else:
		push_error(shaderName+" has not been loaded yet.")
		return
