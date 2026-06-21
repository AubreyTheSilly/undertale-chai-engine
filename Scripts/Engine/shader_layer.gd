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

func set_shader_property(shaderName : String,value : Variant) -> void:
	if shaderName == "ShaderTemplate":
		push_error("No")
		return
	if get_node_or_null(shaderName):
		var rect : Node2D = get_node(shaderName).get_node("ColorRect")
		rect.material.set_shader_parameter(shaderName,value)
	else:
		push_error(shaderName+" has not been loaded yet.")
		return

func remove_shader(shaderName : String) -> void:
	if shaderName == "ShaderTemplate":
		push_error("YOU CANNOT DELETE THE SHADER TEMPLATE. WHAT THE FUCK ARE YOU DOING.")
		return
	if get_node_or_null(shaderName):
		get_node(shaderName).queue_free()
	else:
		push_error(shaderName+" has not been loaded yet.")
		return
