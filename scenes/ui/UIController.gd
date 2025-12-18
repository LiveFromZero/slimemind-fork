extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal arms_count_changed(count: int)

func _ready() -> void:
	var start_btn = get_node("CanvasLayer2/Button") as Button
	start_btn.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	emit_signal("simulation_toggled")

func _on_h_slider_value_changed(value: float) -> void:
	arms_count_changed.emit(value)
