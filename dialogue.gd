extends CanvasLayer


signal advanced

@onready var label: Label = $CanvasGroup/Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

const FADE_TIME := 0.5
const CHAR_TIME := 0.02
var timer := CHAR_TIME

var target_alpha := 0.0
var can_advance := false


func show_text(text: String) -> void:
	target_alpha = 1.0
	can_advance = false
	label.text = ""
	await get_tree().create_timer(0.5).timeout
	
	label.text = text
	label.visible_characters = 0
	can_advance = true


func _physics_process(delta: float) -> void:
	var curr_alpha := $CanvasGroup.material.get_shader_parameter(&"alpha") as float
	$CanvasGroup.material.set_shader_parameter(&"alpha", move_toward(curr_alpha, target_alpha, delta / FADE_TIME))
	
	if label.visible_characters < label.text.length():
		timer -= delta
		while timer <= 0.0:
			timer += CHAR_TIME
			label.visible_characters += 1
			audio_player.play()
	elif can_advance:
		if Input.is_action_just_pressed(&"advance_dialogue"):
			target_alpha = 0.0
			advanced.emit()
