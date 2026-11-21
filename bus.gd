class_name Bus
extends RigidBody2D


signal victory_achieved

@onready var r_cast: ShapeCast2D = $RWheelCast
@onready var l_cast: ShapeCast2D = $LWheelCast

var stiffness := 50.0
var damping := 5.0
var jump_cd := 0.5
var jump_timer := 0.0
var can_grapple := false
var grapple_joint: Node2D = null
var top_deck: Node2D = null

var is_winning := false
var in_dialogue := false
var remove_deck_timer := 0.8
var num_decks := 0
var fade_timer := 1.0

var prev_travels := {}

@onready var start_pos := global_position
var last_bus_stop: Node2D = null


func _ready() -> void:
	for cast: ShapeCast2D in [r_cast, l_cast]:
		var rest := cast.target_position.y
		prev_travels[cast] = cast.get_closest_collision_safe_fraction() * rest


var prev_lin_vel := Vector2.ZERO
func _physics_process(delta: float) -> void:
	if in_dialogue:
		freeze = true
		return
	else:
		freeze = false
	
	var wheels_colliding := 0
	
	for cast: ShapeCast2D in [r_cast, l_cast]:
		if cast.is_colliding():
			wheels_colliding += 1
			var collider := cast.get_collider(0) as PhysicsBody2D
			if collider:
				var platform_vel := PhysicsServer2D.body_get_state(collider.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY) as Vector2
				if platform_vel:
					apply_force(platform_vel * mass * 0.25, cast.global_position - global_position)
		
		var rest := cast.target_position.y
		var prev_travel := prev_travels[cast] as float
		var travel := cast.get_closest_collision_safe_fraction() * rest
		var spring_vel := (travel - prev_travel) / delta
		var displacement := travel - rest
		
		cast.get_child(0).position.y = travel
		
		var force := -stiffness * displacement - damping * spring_vel
		apply_force(transform.y * -force, cast.global_position - global_position)
		
		prev_travels[cast] = travel
	
	if not is_winning:
		if wheels_colliding > 0:
			if Input.is_action_pressed(&"ui_up"):
				apply_central_force(transform.x * 200)
			if Input.is_action_pressed(&"ui_down"):
				apply_central_force(transform.x * -200)
			
			if Input.is_action_just_pressed(&"ui_accept") and jump_timer <= 0.0:
				jump_timer = jump_cd
				apply_central_impulse(transform.y * -200)
		
		# When grappling, up and down keys also change grapple length
		if grapple_joint:
			if Input.is_action_pressed(&"ui_up"):
				grapple_joint.length -= 90 * delta
				grapple_joint.length = maxf(0.0, grapple_joint.length)
			if Input.is_action_pressed(&"ui_down"):
				grapple_joint.length += 90 * delta
		
		if Input.is_action_pressed(&"ui_right"):
			apply_torque(4000)
		if Input.is_action_pressed(&"ui_left"):
			apply_torque(-4000)
	
	var travel_velocity := linear_velocity.project(transform.x)
	var friction := (wheels_colliding / 2.0) * 0.7
	apply_central_force(friction * (-travel_velocity))
	
	if jump_timer > 0.0:
		jump_timer -= delta
	
	if (linear_velocity - prev_lin_vel).length() > 100.0:
		$HitSoundPlayer.pitch_scale = randf_range(0.8, 1.2)
		$HitSoundPlayer.play()
	prev_lin_vel = linear_velocity
	
	if Input.is_action_just_pressed(&"reset") and not is_winning:
		reset_to_last_stop()
	
	if can_grapple and not is_winning:
		if Input.is_action_pressed(&"grapple"):
			var params := PhysicsRayQueryParameters2D.new()
			params.from = top_deck.global_transform * Vector2(0, -6)
			params.to = top_deck.global_transform * Vector2(0, -400)
			var result := get_world_2d().direct_space_state.intersect_ray(params)
			if result and not grapple_joint:
				grapple_joint = preload("res://grapple_joint.tscn").instantiate()
				grapple_joint.position = result["position"]
				var level_local = result["collider"].global_transform.inverse() * result["position"]
				grapple_joint.setup(level_local, top_deck.position + Vector2(0, -6), result["collider"], self)
				get_parent().add_child.call_deferred(grapple_joint)
		elif grapple_joint:
			clear_grapple()
	
	if is_winning:
		if num_decks > 0:
			remove_deck_timer -= delta
			if remove_deck_timer <= 0.0:
				remove_deck_timer += 0.2
				num_decks -= 1
				
				var curr_top: Node = null
				for child in get_children():
					if child.is_in_group(&"deck"):
						curr_top = child
				curr_top.queue_free()
				$RemoveDeckSoundPlayer.play()
		else:
			fade_timer -= delta
			if fade_timer <= 0.0:
				fade_timer = 10000
				victory_achieved.emit()


func clear_grapple():
	if grapple_joint:
		grapple_joint.queue_free()
		grapple_joint = null


var p := 0
func add_deck(bus_stop: Node2D, is_grapple := false) -> void:
	clear_grapple()
	
	if can_grapple:
		top_deck.get_node(^"GrappleThing").visible = false
	
	$BusStopSoundPlayer.play()
	var deck := load("res://bus_deck.tscn").instantiate() as Node2D
	deck.get_node(^"Base").visible = false
	deck.get_node(^"Deck").visible = true
	if is_grapple:
		deck.get_node(^"GrappleThing").visible = true
	deck.position.y = p - 24
	p -= 24
	add_child.call_deferred(deck)
	
	mass += 0.2
	
	last_bus_stop = bus_stop
	can_grapple = is_grapple
	top_deck = deck
	num_decks += 1


func reset_to_last_stop() -> void:
	reset_to_specific_stop(last_bus_stop)


func reset_to_specific_stop(stop: BusStop) -> void:
	clear_grapple()
	
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


func victory() -> void:
	$VictorySoundPlayer.play()
	is_winning = true
	linear_damp = 0.8
	clear_grapple()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	
	if event is InputEventKey and event.pressed:
		if "1234567890".find(event.as_text_keycode()) != -1:
			var num := (event.as_text_keycode() as String).to_int()
			if num == 0:
				num = 10
			num -= 1
			
			var stops := []
			for child in get_parent().get_children():
				if child is BusStop:
					stops.append(child)
			
			if num < stops.size():
				await get_tree().physics_frame
				reset_to_specific_stop(stops[num])
