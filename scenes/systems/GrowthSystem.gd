extends Node

var segment_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var length: float = 30.0

@export var split_chance: float = 0.1  # 20% Chance pro Wachstum
@export var split_angle: float = 15.0  # max Winkelabweichung links/rechts beim Split

signal arm_has_grown_new_segment(arm : ArmSegment)
signal new_segment_alive(segment: ArmSegment)

func _on_world_controller_grow_arm(arm_node: ArmSegment) -> void:
	spawn_segment_at_node(arm_node)

func spawn_segment_at_node(reference_node: ArmSegment) -> void:
	# Zufall, ob gesplittet wird
	if randf() < split_chance:
		# Splitten in 2 Segmente
		_spawn_split(reference_node)
	else:
		# normales Wachstum
		_spawn_single(reference_node)

func _spawn_single(reference_node: ArmSegment) -> void:
	var new_segment = segment_scene.instantiate() as ArmSegment
	
	new_segment.predecessor = reference_node
	new_segment.depth = reference_node.depth + 1
	reference_node.children.append(new_segment)

	# kleine Zufallsabweichung
	var random_offset = deg_to_rad(randf_range(-10, 10))
	var direction = Vector2.UP.rotated(reference_node.global_rotation + random_offset)
	new_segment.global_position = reference_node.global_position + direction * length
	new_segment.rotation = reference_node.rotation + random_offset

	reference_node.get_parent().add_child(new_segment)
	new_segment.segment_died.connect(get_tree().root.get_node("Main/ArmGrowth/Life_and_Death_System")._on_arm_segment_segment_died)
	new_segment.segment_died.connect(get_tree().root.get_node("Main/World/WorldController")._on_arm_segment_segment_died)
	
	arm_has_grown_new_segment.emit(reference_node)
	new_segment_alive.emit(new_segment)

func _spawn_split(reference_node: ArmSegment) -> void:
	var parent = reference_node.get_parent()
	for i in [-1, 1]:  # 2 Segmente: links und rechts
		var new_segment = segment_scene.instantiate() as ArmSegment
		
		new_segment.predecessor = reference_node
		new_segment.depth = reference_node.depth + 1
		reference_node.children.append(new_segment)
		
		var angle_offset = deg_to_rad(split_angle) * i
		var drift = deg_to_rad(randf_range(-5, 5))  # optional kleine Zufallsabweichung
		var final_angle = reference_node.global_rotation + angle_offset + drift
		
		var direction = Vector2.UP.rotated(final_angle)
		new_segment.global_position = reference_node.global_position + direction * length
		new_segment.rotation = reference_node.rotation + angle_offset + drift
		
		parent.add_child(new_segment)
		new_segment.segment_died.connect(get_tree().root.get_node("Main/ArmGrowth/Life_and_Death_System")._on_arm_segment_segment_died)
		new_segment.segment_died.connect(get_tree().root.get_node("Main/World/WorldController")._on_arm_segment_segment_died)
		
		arm_has_grown_new_segment.emit(reference_node)
		new_segment_alive.emit(new_segment)
