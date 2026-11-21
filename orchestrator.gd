extends Node2D


var curr_level: Node = null


func _ready() -> void:
	#curr_level = load("res://levels/jimmy_quest.tscn").instantiate() as Node
	#add_child.call_deferred(curr_level)
	
	$LevelSelect/HotdogJimmy.pressed.connect(start_level.bind("res://levels/jimmy_quest.tscn"))


## 1.0 is fully black, 0.0 has everything visible
func fade_dither(alpha: float) -> void:
	var t := create_tween()
	t.tween_property($CanvasLayer/Dither, "alpha", alpha, 1.0)
	await t.finished


func finish_level() -> void:
	await fade_dither(1.0)
	curr_level.queue_free()
	curr_level = null
	$LevelSelect.visible = true
	fade_dither(0.0)


var can_start_level := true
func start_level(level_path: String) -> void:
	if not can_start_level:
		return
	can_start_level = false
	
	await fade_dither(1.0)
	curr_level = load(level_path).instantiate()
	add_child.call_deferred(curr_level)
	curr_level.finished.connect(finish_level)
	await fade_dither(0.0)
	
	can_start_level = true
