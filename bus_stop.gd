class_name BusStop
extends Area2D


@export var is_grapple := false

var has_people := true

@onready var people_sprite: Sprite2D = $Sprite2D/PeopleSprite
@onready var grapple_sprite: Sprite2D = $Sprite2D/GrappleSprite
@onready var animated := people_sprite


func _ready() -> void:
	if is_grapple:
		people_sprite.self_modulate.v = 0.5
		animated = grapple_sprite
	else:
		grapple_sprite.visible = false


var t := 0.0
func _physics_process(delta: float) -> void:
	t += delta
	if t >= 0.4:
		t -= 0.4
		animated.flip_h = not animated.flip_h


func _on_body_entered(body: Node2D) -> void:
	if body is Bus and has_people:
		has_people = false
		people_sprite.visible = false
		grapple_sprite.visible = false
		body.add_deck(self, is_grapple)
