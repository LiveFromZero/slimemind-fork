extends Node

var segment_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var length: float = 30.0

signal arm_grew(arm : Node2D)

func _on_world_controller_grow_arm(arm_node: Node) -> void:
	spawn_segment_at_node(arm_node)

func spawn_segment_at_node(reference_node: Node2D) -> void:
	# 1. Instanziere das Segment
	var new_segment = segment_scene.instantiate() as Node2D

	# 2. Berechne Richtung
	var max_degrees_offset = 10.0  # maximale Abweichung
	var random_offset = deg_to_rad(randf_range(-max_degrees_offset, max_degrees_offset))
	var direction = Vector2.UP.rotated(reference_node.global_rotation + random_offset)

	# 3. Positioniere das neue Segment am Ende des Referenz-Segments
	new_segment.global_position = reference_node.global_position + direction * length

	# 4. Rotation übernehmen
	new_segment.rotation = reference_node.rotation + random_offset  # lokale Rotation plus Zufall

	# 5. Parent setzen
	reference_node.get_parent().add_child(new_segment)

	# 6. Signal senden
	arm_grew.emit(reference_node)
