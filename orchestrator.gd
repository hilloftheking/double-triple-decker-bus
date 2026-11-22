extends Node2D


var curr_level: Node = null


func _ready() -> void:
	$LevelSelect/HotdogJimmy.pressed.connect(start_level.bind("res://levels/jimmy_quest.tscn"))
	$LevelSelect/Volcano.pressed.connect(start_level.bind("res://levels/volcano.tscn"))
	unlock_level(false)


## 1.0 is fully black, 0.0 has everything visible
func fade_dither(alpha: float) -> void:
	var t := create_tween()
	t.tween_property($CanvasLayer/Dither, "alpha", alpha, 1.0)
	await t.finished


func finish_level() -> void:
	unlock_level(true)
	await fade_dither(1.0)
	curr_level.queue_free()
	curr_level = null
	$LevelSelect.visible = true
	fade_dither(0.0)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


var can_start_level := true
func start_level(level_path: String) -> void:
	if not can_start_level:
		return
	can_start_level = false
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	await fade_dither(1.0)
	curr_level = load(level_path).instantiate()
	add_child.call_deferred(curr_level)
	curr_level.finished.connect(finish_level)
	await fade_dither(0.0)
	
	can_start_level = true


func unlock_level(unlock := true) -> void:
	$LevelSelect/Volcano.disabled = not unlock
	$LevelSelect/Volcano.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if unlock else Control.CURSOR_ARROW
	$LevelSelect/TextureRect3.visible = unlock


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"mute"):
		var music_idx := AudioServer.get_bus_index(&"Music")
		AudioServer.set_bus_mute(music_idx, not AudioServer.is_bus_mute(music_idx))
	if Input.is_action_just_pressed(&"unlock_level"):
		unlock_level(true)
	if Input.is_action_just_pressed(&"fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN
