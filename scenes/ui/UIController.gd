extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)

func _on_button_pressed() -> void:
	emit_signal("simulation_toggled")
