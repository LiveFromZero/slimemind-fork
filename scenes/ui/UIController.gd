extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled

func _ready() -> void:
	var btn = get_node("CanvasLayer2/Button") as Button
	btn.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	emit_signal("simulation_toggled")
