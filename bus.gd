extends RigidBody2D


@onready var r_cast: ShapeCast2D = $RWheelCast
@onready var l_cast: ShapeCast2D = $LWheelCast

var stiffness := 50.0
var damping := 5.0

var prev_travels := {}

func _ready() -> void:
	for cast: ShapeCast2D in [r_cast, l_cast]:
		var rest := cast.target_position.y
		prev_travels[cast] = cast.get_closest_collision_safe_fraction() * rest


func _physics_process(delta: float) -> void:
	var wheels_colliding := 0
	
	for cast: ShapeCast2D in [r_cast, l_cast]:
		if cast.is_colliding():
			wheels_colliding += 1
		
		var rest := cast.target_position.y
		var prev_travel := prev_travels[cast] as float
		var travel := cast.get_closest_collision_safe_fraction() * rest
		var spring_vel := (travel - prev_travel) / delta
		var displacement := travel - rest
		
		cast.get_child(0).position.y = travel
		
		var force := -stiffness * displacement - damping * spring_vel
		apply_force(transform.y * -force, cast.global_position - global_position)
		#apply_force(Vector2(0, -force), cast.global_position - global_position)
		
		prev_travels[cast] = travel
	
	if Input.is_action_pressed(&"ui_right"):
		apply_central_force(transform.x * 500)
	if Input.is_action_pressed(&"ui_left"):
		apply_central_force(transform.x * -500)
	
	var travel_velocity := linear_velocity.project(transform.x)
	var friction := (wheels_colliding / 2.0) * 0.7
	apply_central_force(friction * (-travel_velocity))


var p := 0
func add_deck() -> void:
	var deck := load("res://bus_deck.tscn").instantiate() as Node2D
	deck.position.y = p - 80
	p -= 80
	add_child.call_deferred(deck)
	
	mass += 0.2
