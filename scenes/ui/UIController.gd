extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)
signal reset_simulation

signal update_life_points_for_arms(slider_lifepoints:float)
signal update_lightamount(slider_lightamount:float)
signal update_temperature(slider_temperature:float)
signal update_humidity(slider_humidity:float)
signal update_food_amount(slider_foodamount:int)
signal update_food_count(slider_foodcount:int)
signal spawn_food
signal update_simulation_speed(slider_simulationspeed:float)
signal update_fieldsize(slider_fieldsize:float)
signal statistikPressed

@onready var summaryUI = $Summary_UI
@onready var startButton = $Control_UI/VBoxContainer/Button

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)

func _on_button_pressed() -> void:
	simulation_toggled.emit()
	get_tree().call_group("Statistik", "startTimer")
	startButton.disabled = true

func _on_reset_button_pressed() -> void:
	reset_simulation.emit()
	var foodspawn_button = $Control_UI/VBoxContainer/FoodSpawnButton
	foodspawn_button.disabled = false
	startButton.disabled = false
	get_tree().call_group("Statistik", "set_defaults")

func _on_menu_button_pressed() -> void:
	$Control_UI/VBoxContainer.visible = !$Control_UI/VBoxContainer.visible
	$Control_UI/Panel.visible = !$Control_UI/Panel.visible

func _on_futteranzahl_value_changed(value: float) -> void:
	update_food_count.emit(value)
	var label = $"Control_UI/VBoxContainer/Anzahl Futterquellen"
	label.text = label_updater(label, value)

func _on_futtergröße_value_changed(value: float) -> void:
	value = int(value)
	update_food_amount.emit(value)
	var label = $"Control_UI/VBoxContainer/Größe einer Futterquelle"
	label.text = label_updater(label, value)

func _on_robustheit_arme_lebenspunkte_value_changed(value: float) -> void:
	update_life_points_for_arms.emit(value)
	var label = $"Control_UI/VBoxContainer/Widerstandsfähigkeit"
	label.text = label_updater(label, value)

func _on_sonnenlicht_value_changed(value: float) -> void:
	update_lightamount.emit(value)
	var label = $Control_UI/VBoxContainer/Sonnenlicht
	label.text = label_updater(label, value)

func _on_temperatur_value_changed(value: float) -> void:
	update_temperature.emit(value)
	var label = $Control_UI/VBoxContainer/Temperatur
	label.text = label_updater(label, value)

func _on_luftfeuchtigkeit_value_changed(value: float) -> void:
	update_humidity.emit(value)
	var label = $Control_UI/VBoxContainer/Luftfeuchtigkeit
	label.text = label_updater(label, value)

func _on_food_spawn_button_pressed() -> void:
	spawn_food.emit()
	var foodspawn_button = $Control_UI/VBoxContainer/FoodSpawnButton
	foodspawn_button.disabled = true

func _on_simulation_speed_value_changed(value: float) -> void:
	update_simulation_speed.emit(value)
	var label = $Control_UI/VBoxContainer/Simulationsgeschwindigkeit
	label.text = label_updater(label, value)

func _on_feldgröße_value_changed(value: float) -> void:
	update_fieldsize.emit(value)
	var label = $"Control_UI/VBoxContainer/Feldgröße"
	label.text = label_updater(label, value)

func label_updater(label:Label, value:float) -> String:
	var finalText = label.name + ": " + str(value)
	return finalText

func summaryPopUp() -> void:
	summaryUI.visible = true

func _on_statistik_pressed() -> void:
	summaryPopUp()
	statistikPressed.emit()

func _on_hide_ui_button_pressed() -> void:
	summaryUI.visible = false

func _on_close_programm_button_pressed() -> void:
	get_tree().quit()

func _on_world_statistik_simulation_over_signal() -> void:
	summaryPopUp()
