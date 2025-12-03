extends Node2D

var arm_segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")

var count_of_Arms = 0
var simulation_active := false

func _ready() -> void:
	recreate_arms()

func _process(delta):
	if not simulation_active:
		return
	# Rest deines Simulationscodes


func recreate_arms() -> void:
	# lösche alte Arme
	for c in get_children():
		c.queue_free()

	# Positionen und Rotationen vorbereiten
	var positions = [
		{ "pos": Vector2(0, -20), "rot": 0 },
		{ "pos": Vector2(20, 0), "rot": 90 },
		{ "pos": Vector2(0, 20), "rot": 180 },
		{ "pos": Vector2(-20, 0), "rot": 270 }
	]

	# Für count_of_Arms die passenden Arme erzeugen
	for i in range(count_of_Arms):
		var arm = arm_segment_scene.instantiate()
		arm.global_position = positions[i]["pos"]
		arm.global_rotation_degrees = positions[i]["rot"]
		add_child(arm)


func _on_h_slider_value_changed(value: float) -> void:
	count_of_Arms = int(value)
	recreate_arms()


func _on_button_pressed() -> void:
	simulation_active = not simulation_active
