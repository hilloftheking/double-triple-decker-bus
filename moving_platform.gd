extends AnimatableBody2D


@export var target_node: Node2D
@export var move_time := 2.0

var t := 0.0

@onready var start_pos := global_position


func _physics_process(delta: float) -> void:
	t += delta * TAU / move_time
	
	global_position = start_pos.lerp(target_node.global_position, -cos(t) * 0.5 + 0.5)
