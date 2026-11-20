extends Node2D


var stops := []


func _ready() -> void:
	for child in get_children():
		if child is BusStop:
			stops.append(child)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	
	if event is InputEventKey and event.pressed:
		if "1234567890".find(event.as_text_keycode()) != -1:
			var num := (event.as_text_keycode() as String).to_int()
			if num == 0:
				num = 10
			num -= 1
			
			if num < stops.size():
				$Bus.reset_to_specific_stop(stops[num])
