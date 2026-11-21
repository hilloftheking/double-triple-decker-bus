extends Node


func _ready() -> void:
	for child in get_children():
		if child is Polygon2D:
			var col_poly := CollisionPolygon2D.new()
			col_poly.polygon = child.polygon
			col_poly.transform = child.transform
			add_child.call_deferred(col_poly)
