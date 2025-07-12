extends Node2D

func _ready() -> void:
	$StaticBody2D/CollisionPolygon2D.polygon = $Polygon2D.polygon
