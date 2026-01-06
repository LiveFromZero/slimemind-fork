extends Node

var predecessor: Node2D
var children: Array [Node2D]
var position_information = self.global_position
var life_points = (randf() * 10) + 75
var damage_per_second: float = 1.0  # 1 Punkt pro Sekunde
var depth: int

signal color_changed(new_color: Color)
signal segment_died

func _process(delta: float):
	life_points -= damage_per_second * delta
	if life_points < 75:
		set_color("green_yellow")
	if life_points < 50:
		set_color("olive-drab")
	if life_points < 25:
		set_color("olive")
	if life_points < 1:
		set_color("brown")
		segment_died.emit()


func set_color(new_color: Color) -> void:
	color_changed.emit(new_color)
