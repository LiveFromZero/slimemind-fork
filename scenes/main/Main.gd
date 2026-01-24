extends Node

var is_paused: bool = true

func _ready() -> void:
	get_tree().paused = true
	Engine.time_scale = 1.0

func _on_ui_simulation_toggled() -> void:
	is_paused = false
	get_tree().paused = is_paused

func _on_ui_update_simulation_speed(slider_simulationspeed: float) -> void:
	Engine.time_scale = slider_simulationspeed

func _on_world_controller_reset_game() -> void:
	get_tree().paused = true

func _on_world_statistik_simulation_over_signal() -> void:
	get_tree().paused = true
