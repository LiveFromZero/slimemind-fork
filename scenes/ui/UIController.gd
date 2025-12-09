extends Node

signal simulation_toggled

func _on_StartPauseButton_pressed():
	emit_signal("simulation_toggled")
