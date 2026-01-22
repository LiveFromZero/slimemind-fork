extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)
signal reset_simulation

signal update_life_points_for_arms(slider_lifepoints:float)
signal update_lightamount(slider_lightamount:float)
signal update_temperature(slider_temperature:float)
signal update_humidity(slider_humidity:float)
signal update_food_amount(slider_foodamount:float)
signal update_food_count(slider_foodcount:float)
signal spawn_food
signal update_simulation_speed(slider_simulationspeed:float)
signal update_fieldsize(slider_fieldsize:float)
signal statistikPressed

@onready var summaryUI = $CanvasLayer

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)

func _on_button_pressed() -> void:
	simulation_toggled.emit()
	
func _on_reset_button_pressed() -> void:
	reset_simulation.emit()
	var foodspawn_button = $CanvasLayer2/VBoxContainer/FoodSpawnButton
	foodspawn_button.disabled = false

func _on_menu_button_pressed() -> void:
	$CanvasLayer2/VBoxContainer.visible = !$CanvasLayer2/VBoxContainer.visible

func _on_futteranzahl_value_changed(value: float) -> void:
	update_food_count.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Futteranzahl
	label.text = label_updater(label, value)

func _on_futtergröße_value_changed(value: float) -> void:
	update_food_amount.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Futtermenge
	label.text = label_updater(label, value)

func _on_robustheit_arme_lebenspunkte_value_changed(value: float) -> void:
	update_life_points_for_arms.emit(value)
	var label = $"CanvasLayer2/VBoxContainer/Widerstandsfähigkeit"
	label.text = label_updater(label, value)

func _on_sonnenlicht_value_changed(value: float) -> void:
	update_lightamount.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Sonnenlicht
	label.text = label_updater(label, value)

func _on_temperatur_value_changed(value: float) -> void:
	update_temperature.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Temperatur
	label.text = label_updater(label, value)

func _on_luftfeuchtigkeit_value_changed(value: float) -> void:
	update_humidity.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Luftfeuchtigkeit
	label.text = label_updater(label, value)

func _on_food_spawn_button_pressed() -> void:
	spawn_food.emit()
	var foodspawn_button = $CanvasLayer2/VBoxContainer/FoodSpawnButton
	foodspawn_button.disabled = true

func _on_simulation_speed_value_changed(value: float) -> void:
	update_simulation_speed.emit(value)
	var label = $CanvasLayer2/VBoxContainer/Simulationsgeschwindigkeit
	label.text = label_updater(label, value)

func _on_feldgröße_value_changed(value: float) -> void:
	update_fieldsize.emit(value)
	var label = $"CanvasLayer2/VBoxContainer/Feldgröße"
	label.text = label_updater(label, value)

func label_updater(label:Label, value:float) -> String:
	var finalText = label.name + ": " + str(value)
	return finalText

func summaryPopUp() -> void:
	summaryUI.visible = true


func _on_statistik_pressed() -> void:
	summaryPopUp()
	statistikPressed.emit()
