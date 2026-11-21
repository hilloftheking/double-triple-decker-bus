extends ColorRect


var alpha := 0.0:
	set(value):
		material.set_shader_parameter(&"alpha", value)
		alpha = value
