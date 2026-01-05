extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)
signal reset_simulation

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)

func _on_button_pressed() -> void:
	emit_signal("simulation_toggled")

func _on_reset_button_pressed() -> void:
	reset_simulation.emit()

func _on_menu_button_pressed() -> void:
	$CanvasLayer2/VBoxContainer.visible = !$CanvasLayer2/VBoxContainer.visible
