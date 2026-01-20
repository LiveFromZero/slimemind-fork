extends Node

var is_paused: bool = true
signal startbutton_pressed(pause_state)

func _ready() -> void:
	get_tree().paused = true
	Engine.time_scale = 1.0

func _on_ui_simulation_toggled() -> void:
	is_paused = !is_paused
	startbutton_pressed.emit(is_paused)
	get_tree().paused = is_paused

func _on_ui_update_simulation_speed(slider_simulationspeed: float) -> void:
	Engine.time_scale = slider_simulationspeed

	
