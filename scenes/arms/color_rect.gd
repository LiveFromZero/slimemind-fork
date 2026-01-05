extends ColorRect

func _ready() -> void:
	color = "Yellow"

func _on_arm_segment_color_changed(new_color: Color) -> void:
	color = new_color
