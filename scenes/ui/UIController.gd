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

func _on_futtermenge_value_changed(value: float) -> void:
	pass # Replace with function body.

func _on_futtergröße_value_changed(value: float) -> void:
	get_tree().call_group("SliderUpdate", "update_total_nutrients", value)

func _on_robustheit_arme_lebenspunkte_value_changed(value: float) -> void:
	get_tree().call_group("SliderUpdate", "slider_update_maxlifepoints", value)

func _on_sonnenlicht_value_changed(value: float) -> void:
	get_tree().call_group("SliderUpdate", "slider_update_sunlight", value)

func _on_temperatur_value_changed(value: float) -> void:
		get_tree().call_group("SliderUpdate", "slider_update_temperature", value)

func _on_luftfeuchtigkeit_value_changed(value: float) -> void:
	get_tree().call_group("SliderUpdate", "slider_update_humidity", value)
