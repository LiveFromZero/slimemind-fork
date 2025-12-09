extends Node

var is_running = false

func _ready():
	$Ui.simulation_toggled.connect(_on_ui_simulation_toggled)

func _on_ui_simulation_toggled() -> void:
	is_running = !is_running
	get_tree().paused = !is_running
