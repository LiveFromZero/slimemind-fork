extends Node

var is_paused: bool = true
	
func _ready() -> void:
	get_tree().paused = true

func _on_ui_simulation_toggled() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
