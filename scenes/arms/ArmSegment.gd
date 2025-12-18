extends Node

var id
var vorgaenger
var position_information = self.global_position

signal color_changed(new_color: Color)

var segment_color: Color = Color.WHITE

func set_color(new_color: Color) -> void:
	segment_color = new_color
	color_changed.emit(new_color)
