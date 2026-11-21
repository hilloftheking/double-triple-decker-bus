extends Node2D


@onready var line: Polygon2D = $GrappleLine

var rid := RID()
var level_pos := Vector2.ZERO
var bus_pos := Vector2.ZERO
var other_body: Node2D
var bus: RigidBody2D

var length := 0.0:
	set(value):
		PhysicsServer2D.damped_spring_joint_set_param(rid, PhysicsServer2D.DAMPED_SPRING_REST_LENGTH, value)
		length = value


func _physics_process(_delta: float) -> void:
	var level_pos_global := other_body.global_transform * level_pos
	var bus_pos_global := bus.global_transform * bus_pos
	
	line.global_position = (level_pos_global + bus_pos_global) / 2.0
	line.rotation = level_pos_global.angle_to_point(bus_pos_global)
	line.scale.x = (level_pos_global - bus_pos_global).length()


## level_pos is local and bus_pos is local
func setup(p_level_pos: Vector2, p_bus_pos: Vector2, level: Node2D, p_bus: RigidBody2D) -> void:
	level_pos = p_level_pos
	bus_pos = p_bus_pos
	other_body = level
	bus = p_bus
	rid = PhysicsServer2D.joint_create()
	
	var global_level_pos := level.global_transform * level_pos
	var global_bus_pos := bus.global_transform * bus_pos
	
	PhysicsServer2D.joint_make_damped_spring(rid, global_level_pos, global_bus_pos, level.get_rid(), bus.get_rid())
	PhysicsServer2D.damped_spring_joint_set_param(rid, PhysicsServer2D.DAMPED_SPRING_STIFFNESS, 40.0)
	length = (global_level_pos - global_bus_pos).length()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		PhysicsServer2D.free_rid(rid)
