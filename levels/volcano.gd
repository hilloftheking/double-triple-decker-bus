extends Node2D


signal finished

@onready var bus: Bus = $Bus
@onready var dialogue: CanvasLayer = $Dialogue


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	bus.in_dialogue = true
	dialogue.show_text("Listen, I need you to take me to the volcano.")
	await dialogue.advanced
	dialogue.show_text("I've got something I need to get rid of.")
	await dialogue.advanced
	bus.in_dialogue = false
	
	await bus.victory_achieved
	bus.in_dialogue = true
	dialogue.show_text("Thank you.")
	await dialogue.advanced
	dialogue.show_text("Now I can get rid of this evidence.")
	await dialogue.advanced
	dialogue.show_text("I'm actually evil. Muahaha")
	await dialogue.advanced
	dialogue.show_text("This is the end of the game btw.")
	await dialogue.advanced
	dialogue.show_text("Just pretend that there was a satisfying boss fight with me.")
	await dialogue.advanced
	finished.emit()
