extends Area2D


var has_people := true


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and has_people:
		has_people = false
		$Label.text = "yayyyy!!"
		body.add_deck()
