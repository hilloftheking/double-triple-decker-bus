class_name Bus
extends RigidBody2D


@onready var r_cast: ShapeCast2D = $RWheelCast
@onready var l_cast: ShapeCast2D = $LWheelCast

var stiffness := 50.0
var damping := 5.0
var jump_cd := 1.0
var jump_timer := 0.0
var can_grapple := false
var grapple_joint: Node2D = null
var top_deck: Node2D = null

var prev_travels := {}

var played_audio := false

@onready var start_pos := global_position
var last_bus_stop: Node2D = null


func _ready() -> void:
	for cast: ShapeCast2D in [r_cast, l_cast]:
		var rest := cast.target_position.y
		prev_travels[cast] = cast.get_closest_collision_safe_fraction() * rest


var prev_lin_vel := Vector2.ZERO
func _physics_process(delta: float) -> void:
	var wheels_colliding := 0
	
	for cast: ShapeCast2D in [r_cast, l_cast]:
		if cast.is_colliding():
			wheels_colliding += 1
			var collider := cast.get_collider(0) as PhysicsBody2D
			if collider:
				var platform_vel := PhysicsServer2D.body_get_state(collider.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY) as Vector2
				if platform_vel:
					apply_force(platform_vel * mass, cast.global_position - global_position)
		
		var rest := cast.target_position.y
		var prev_travel := prev_travels[cast] as float
		var travel := cast.get_closest_collision_safe_fraction() * rest
		var spring_vel := (travel - prev_travel) / delta
		var displacement := travel - rest
		
		cast.get_child(0).position.y = travel
		
		var force := -stiffness * displacement - damping * spring_vel
		apply_force(transform.y * -force, cast.global_position - global_position)
		
		prev_travels[cast] = travel
	
	if wheels_colliding > 0:
		if Input.is_action_pressed(&"ui_up"):
			apply_central_force(transform.x * 200)
		if Input.is_action_pressed(&"ui_down"):
			apply_central_force(transform.x * -200)
		
		if Input.is_action_just_pressed(&"ui_accept") and jump_timer <= 0.0:
			jump_timer = jump_cd
			apply_central_impulse(transform.y * -200)
	
	if Input.is_action_pressed(&"ui_right"):
		apply_torque(2000)
	if Input.is_action_pressed(&"ui_left"):
		apply_torque(-2000)
	
	var travel_velocity := linear_velocity.project(transform.x)
	var friction := (wheels_colliding / 2.0) * 0.7
	apply_central_force(friction * (-travel_velocity))
	
	if jump_timer > 0.0:
		jump_timer -= delta
	
	if linear_velocity.y > 300 and not played_audio:
		played_audio = true
		$FallSoundPlayer.play()
	
	if (linear_velocity - prev_lin_vel).length() > 100.0:
		$HitSoundPlayer.pitch_scale = randf_range(0.8, 1.2)
		$HitSoundPlayer.play()
	prev_lin_vel = linear_velocity
	
	if Input.is_action_just_pressed(&"reset"):
		reset_to_last_stop()
	
	if can_grapple:
		if Input.is_action_pressed(&"grapple"):
			var params := PhysicsRayQueryParameters2D.new()
			params.from = top_deck.global_position
			params.to = top_deck.global_transform * Vector2(0, -400)
			var result := get_world_2d().direct_space_state.intersect_ray(params)
			if result and not grapple_joint:
				grapple_joint = preload("res://grapple_joint.tscn").instantiate()
				grapple_joint.position = result["position"]
				grapple_joint.setup(result["position"], top_deck.position, result["collider"], self)
				get_parent().add_child.call_deferred(grapple_joint)
		elif grapple_joint:
			grapple_joint.queue_free()
			grapple_joint = null


var p := 0
func add_deck(bus_stop: Node2D, is_grapple := false) -> void:
	$BusStopSoundPlayer.play()
	var deck := load("res://bus_deck.tscn").instantiate() as Node2D
	if is_grapple:
		deck.get_node(^"GrappleThing").visible = true
	deck.position.y = p - 24
	p -= 24
	add_child.call_deferred(deck)
	
	mass += 0.2
	
	last_bus_stop = bus_stop
	can_grapple = is_grapple
	top_deck = deck


func reset_to_last_stop() -> void:
	reset_to_specific_stop(last_bus_stop)


func reset_to_specific_stop(stop: BusStop) -> void:
	var explosion := preload("res://explosion.tscn").instantiate() as Node2D
	explosion.position = global_position
	get_parent().add_child.call_deferred(explosion)
	
	if stop:
		global_position = stop.global_position
	else:
		global_position = start_pos
	rotation = 0
	linear_velocity = Vector2.ZERO
	prev_lin_vel = Vector2.ZERO
	angular_velocity = 0.0
