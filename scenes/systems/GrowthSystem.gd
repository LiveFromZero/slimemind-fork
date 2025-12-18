extends Node

var segment_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var length: float = 30.0

@export var split_chance: float = 0.1  # 20% Chance pro Wachstum
@export var split_angle: float = 15.0  # max Winkelabweichung links/rechts beim Split

signal arm_grew(arm : Node2D)

func _on_world_controller_grow_arm(arm_node: Node) -> void:
	spawn_segment_at_node(arm_node)

func spawn_segment_at_node(reference_node: Node2D) -> void:
	# Zufall, ob gesplittet wird
	if randf() < split_chance:
		# Splitten in 2 Segmente
		_spawn_split(reference_node)
	else:
		# normales Wachstum
		_spawn_single(reference_node)

func _spawn_single(reference_node: Node2D) -> void:
	var new_segment = segment_scene.instantiate() as Node2D

	# kleine Zufallsabweichung
	var random_offset = deg_to_rad(randf_range(-10, 10))
	var direction = Vector2.UP.rotated(reference_node.global_rotation + random_offset)
	new_segment.global_position = reference_node.global_position + direction * length
	new_segment.rotation = reference_node.rotation + random_offset

	reference_node.get_parent().add_child(new_segment)
	arm_grew.emit(reference_node)

func _spawn_split(reference_node: Node2D) -> void:
	var parent = reference_node.get_parent()
	for i in [-1, 1]:  # 2 Segmente: links und rechts
		var new_segment = segment_scene.instantiate() as Node2D
		
		var angle_offset = deg_to_rad(split_angle) * i
		var drift = deg_to_rad(randf_range(-5, 5))  # optional kleine Zufallsabweichung
		var final_angle = reference_node.global_rotation + angle_offset + drift
		
		var direction = Vector2.UP.rotated(final_angle)
		new_segment.global_position = reference_node.global_position + direction * length
		new_segment.rotation = reference_node.rotation + angle_offset + drift
		
		parent.add_child(new_segment)
		arm_grew.emit(reference_node)
