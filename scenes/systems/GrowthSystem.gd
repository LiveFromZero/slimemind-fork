extends Node

var segment_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var length: float = 30.0

@export var split_chance: float = 0.1
@export var split_angle: float = 15.0

# Optional but recommended: make these "magic numbers" explicit.
const SINGLE_RANDOM_DEG: float = 10.0
const SPLIT_DRIFT_DEG: float = 5.0

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
	var random_offset: float = deg_to_rad(randf_range(-SINGLE_RANDOM_DEG, SINGLE_RANDOM_DEG))
	var segment := _create_child_segment(reference_node)
	_place_segment(segment, reference_node, random_offset, random_offset) # same as before
	_finalize_new_segment(reference_node, segment)

func _spawn_split(reference_node: ArmSegment) -> void:
	var parent: Node = reference_node.get_parent()

	for i: int in [-1, 1]:
		var angle_offset: float = deg_to_rad(split_angle) * float(i)
		var drift: float = deg_to_rad(randf_range(-SPLIT_DRIFT_DEG, SPLIT_DRIFT_DEG))

		var segment := _create_child_segment(reference_node)
		_place_segment(segment, reference_node, angle_offset + drift, angle_offset + drift)
		parent.add_child(segment)

		_connect_death_handlers(segment)
		arm_has_grown_new_segment.emit(reference_node)
		new_segment_alive.emit(segment)

func _create_child_segment(reference_node: ArmSegment) -> ArmSegment:
	var seg: ArmSegment = segment_scene.instantiate()
	seg.predecessor = reference_node
	seg.depth = reference_node.depth + 1
	reference_node.children.append(seg)
	return seg

func _place_segment(
	segment: ArmSegment,
	reference_node: ArmSegment,
	global_angle_offset: float,
	local_rotation_offset: float
) -> void:
	# Keeps the original behavior:
	# - position uses reference_node.global_rotation (+ offset)
	# - rotation uses reference_node.rotation (+ offset)
	var direction: Vector2 = Vector2.UP.rotated(reference_node.global_rotation + global_angle_offset)
	segment.global_position = reference_node.global_position + direction * length
	segment.rotation = reference_node.rotation + local_rotation_offset

func _finalize_new_segment(reference_node: ArmSegment, segment: ArmSegment) -> void:
	reference_node.get_parent().add_child(segment)
	_connect_death_handlers(segment)
	arm_has_grown_new_segment.emit(reference_node)
	new_segment_alive.emit(segment)

func _connect_death_handlers(segment: ArmSegment) -> void:
	segment.segment_died.connect(_life_system._on_arm_segment_segment_died)
	segment.segment_died.connect(_world_controller._on_arm_segment_segment_died)
