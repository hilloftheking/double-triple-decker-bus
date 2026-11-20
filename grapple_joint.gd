extends Node2D


@onready var line: Polygon2D = $GrappleLine

var rid := RID()
var level_pos := Vector2.ZERO
var bus_pos := Vector2.ZERO
var bus: RigidBody2D


func _physics_process(_delta: float) -> void:
	var bus_pos_global := bus.global_transform * bus_pos
	
	line.global_position = (level_pos + bus_pos_global) / 2.0
	line.rotation = level_pos.angle_to_point(bus_pos_global)
	line.scale.x = (level_pos - bus_pos_global).length()


## level_pos is global and bus_pos is local
func setup(p_level_pos: Vector2, p_bus_pos: Vector2, level: StaticBody2D, p_bus: RigidBody2D) -> void:
	level_pos = p_level_pos
	bus_pos = p_bus_pos
	bus = p_bus
	rid = PhysicsServer2D.joint_create()
	PhysicsServer2D.joint_make_damped_spring(rid, level_pos, bus.global_transform * bus_pos, level.get_rid(), bus.get_rid())


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		PhysicsServer2D.free_rid(rid)
