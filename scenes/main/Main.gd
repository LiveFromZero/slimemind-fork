extends Node

var is_running: bool = true

func _on_ui_simulation_toggled() -> void:
	is_running = !is_running
	get_tree().paused = !is_running
