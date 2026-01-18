extends Area2D
class_name FoodSource
@export var total_nutrients: float = 10000.0
var current_nutrients: float = total_nutrients
var absorption_rate: float = 100.0  # pro Sekunde pro angedocktem Tip

func _on_area_entered(area: Area2D) -> void:
	var obj = area.owner
	while current_nutrients > 0:
		obj.eat(current_nutrients)
		current_nutrients -= absorption_rate
