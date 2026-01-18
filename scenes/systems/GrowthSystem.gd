extends Node

var segment_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var length: float = 30.0

@export var split_chance: float = 0.1
@export var split_angle: float = 15.0

# Schritt 1: Pfade exportierbar machen (kein harter String im Code)
@export var life_system_path: NodePath = ^"/root/Main/ArmGrowth/Life_and_Death_System"
@export var world_controller_path: NodePath = ^"/root/Main/World/WorldController"

@onready var _life_system: Node = get_node(life_system_path)
@onready var _world_controller: Node = get_node(world_controller_path)

signal arm_has_grown_new_segment(arm: ArmSegment)
signal new_segment_alive(segment: ArmSegment)

func _on_world_controller_grow_arm(arm_node: ArmSegment) -> void:
	spawn_segment_at_node(arm_node)

func spawn_segment_at_node(reference_node: ArmSegment) -> void:
	if randf() < split_chance:
		_spawn_split(reference_node)
	else:
		_spawn_single(reference_node)

func _spawn_single(reference_node: ArmSegment) -> void:
	var new_segment: ArmSegment = segment_scene.instantiate()

	new_segment.predecessor = reference_node
	new_segment.depth = reference_node.depth + 1
	reference_node.children.append(new_segment)

	var random_offset: float = deg_to_rad(randf_range(-10.0, 10.0))
	var direction: Vector2 = Vector2.UP.rotated(reference_node.global_rotation + random_offset)

	new_segment.global_position = reference_node.global_position + direction * length
	new_segment.rotation = reference_node.rotation + random_offset

	reference_node.get_parent().add_child(new_segment)
	_connect_death_handlers(new_segment)

	arm_has_grown_new_segment.emit(reference_node)
	new_segment_alive.emit(new_segment)

func _spawn_split(reference_node: ArmSegment) -> void:
	var parent: Node = reference_node.get_parent()

	for i: int in [-1, 1]:
		var new_segment: ArmSegment = segment_scene.instantiate()

		new_segment.predecessor = reference_node
		new_segment.depth = reference_node.depth + 1
		reference_node.children.append(new_segment)

		var angle_offset: float = deg_to_rad(split_angle) * float(i)
		var drift: float = deg_to_rad(randf_range(-5.0, 5.0))
		var final_angle: float = reference_node.global_rotation + angle_offset + drift

		var direction: Vector2 = Vector2.UP.rotated(final_angle)
		new_segment.global_position = reference_node.global_position + direction * length
		new_segment.rotation = reference_node.rotation + angle_offset + drift

		parent.add_child(new_segment)
		_connect_death_handlers(new_segment)

		arm_has_grown_new_segment.emit(reference_node)
		new_segment_alive.emit(new_segment)

func _connect_death_handlers(segment: ArmSegment) -> void:
	# exakt dieselbe Funktionalität wie vorher, nur ohne harte Pfade + ohne Duplikate
	segment.segment_died.connect(_life_system._on_arm_segment_segment_died)
	segment.segment_died.connect(_world_controller._on_arm_segment_segment_died)
