class_name BusStop
extends Area2D


@export var is_grapple := false

var has_people := true


func _on_body_entered(body: Node2D) -> void:
	if body is Bus and has_people:
		has_people = false
		$Label.text = "yayyyy!!"
		body.add_deck(self, is_grapple)
