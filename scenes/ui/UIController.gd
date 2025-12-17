extends Control  # oder Panel, je nach UI-Node

signal simulation_toggled
signal spawn_arm

func _ready() -> void:
	var start_btn = get_node("CanvasLayer2/Button") as Button
	start_btn.pressed.connect(_on_start_button_pressed)
	
	var spawn_btn = get_node("CanvasLayer2/Button2") as Button
	spawn_btn.pressed.connect(_spawn_button_pressed)

func _on_start_button_pressed() -> void:
	emit_signal("simulation_toggled")

func _spawn_button_pressed() -> void:
	emit_signal("spawn_arm")
