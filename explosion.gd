extends Sprite2D


var destroy := 0.0
var flicker := 0.0

var should_flip_h := true


func _physics_process(delta: float) -> void:
	destroy += delta
	flicker += delta
	
	if flicker >= 0.1:
		if should_flip_h:
			flip_h = not flip_h
		else:
			flip_v = not flip_v
		should_flip_h = not should_flip_h
		flicker -= 0.1
	
	if destroy >= 0.5:
		queue_free()
