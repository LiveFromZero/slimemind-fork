extends ColorRect

func _ready() -> void:
	get_parent().color_changed.connect(_on_color_changed)
	color = get_parent().segment_color

func _on_color_changed(new_color: Color) -> void:
	color = new_color
