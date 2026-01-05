extends Node

var id
var vorgaenger
var position_information = self.global_position
var life_points = 100

signal color_changed(new_color: Color)
signal segment_died

func set_color(new_color: Color) -> void:
	color_changed.emit(new_color)

func _on_tree_entered() -> void:
	var birthTime = get_process_delta_time()
	
