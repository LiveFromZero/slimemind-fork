extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)
signal reset_simulation

signal update_life_points_for_arms(slider_lifepoints:float)
signal update_lightamount(slider_lightamount:float)
signal update_temperature(slider_temperature:float)
signal update_humidity(slider_humidity:float)
signal update_food_amount(slider_foodamount:float)

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)

func _on_button_pressed() -> void:
	simulation_toggled.emit()

func _on_reset_button_pressed() -> void:
	reset_simulation.emit()

func _on_menu_button_pressed() -> void:
	$CanvasLayer2/VBoxContainer.visible = !$CanvasLayer2/VBoxContainer.visible

func _on_futteranzahl_value_changed(value: float) -> void:
	update_food_amount.emit(value)

func _on_futtergröße_value_changed(value: float) -> void:
	pass

func _on_robustheit_arme_lebenspunkte_value_changed(value: float) -> void:
	update_life_points_for_arms.emit(value)

func _on_sonnenlicht_value_changed(value: float) -> void:
	update_lightamount.emit(value)

func _on_temperatur_value_changed(value: float) -> void:
	update_temperature.emit(value)

func _on_luftfeuchtigkeit_value_changed(value: float) -> void:
	update_humidity.emit(value)
