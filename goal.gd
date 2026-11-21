extends Area2D


var goal_reached := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if goal_reached:
		return
	
	if body is Bus:
		goal_reached = true
		body.victory()
