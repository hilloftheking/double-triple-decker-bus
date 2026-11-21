extends Node2D


signal finished

@onready var bus: Bus = $Bus
@onready var dialogue: CanvasLayer = $Dialogue


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	bus.in_dialogue = true
	dialogue.show_text("Ey take me to Hotdog Jimmy's")
	await dialogue.advanced
	bus.in_dialogue = false
	
	$Controls.visible = true
	$Controls4.visible = true
	
	await bus.victory_achieved
	bus.in_dialogue = true
	dialogue.show_text("You did it")
	await dialogue.advanced
	finished.emit()
