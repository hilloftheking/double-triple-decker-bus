extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Bus:
		body.reset_to_last_stop()
