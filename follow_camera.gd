extends Camera2D


@export var bus: Bus
@export var follow_speed := 600.0


func _physics_process(delta: float) -> void:
	var target_pos := bus.position
	target_pos -= Vector2(0, 40)
	target_pos += bus.linear_velocity * Vector2(0.4, 0.1)
	
	var speed := follow_speed
	var dist := (target_pos - position).length()
	if dist > 200:
		speed = remap(dist, 200, 1000, follow_speed, follow_speed * 10.0)
	
	position = position.move_toward(target_pos, speed * delta)
