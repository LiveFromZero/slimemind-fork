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

@onready var _life_system: LifeAndDeathSystem = get_node(life_system_path) as LifeAndDeathSystem
@onready var _world_controller: WorldController = get_node(world_controller_path) as WorldController

signal arm_has_grown_new_segment(arm: ArmSegment)
signal new_segment_alive(segment: ArmSegment)
signal segments_spawned(parent: ArmSegment, new_segments: Array[ArmSegment])


func _ready() -> void:
	assert(_life_system != null, "Life system not found or wrong type at: %s" % [life_system_path])
	assert(_world_controller != null, "WorldController not found or wrong type at: %s" % [world_controller_path])

func _emit_spawn_events(parent_segment: ArmSegment, spawned: Array[ArmSegment]) -> void:
	# Per-segment events (backwards compatible behavior: same count as before)
	for seg in spawned:
		new_segment_alive.emit(seg)
		arm_has_grown_new_segment.emit(parent_segment)

	# Batch event (once per growth)
	segments_spawned.emit(parent_segment, spawned)


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
	_place_segment(segment, reference_node, random_offset, random_offset)

	_finalize_new_segment(reference_node, segment, reference_node.get_parent())

	_emit_spawn_events(reference_node, [segment])


func _spawn_split(reference_node: ArmSegment) -> void:
	var parent: Node = reference_node.get_parent()
	var spawned: Array[ArmSegment] = []

	for i: int in [-1, 1]:
		var angle_offset: float = deg_to_rad(split_angle) * float(i)
		var drift: float = deg_to_rad(randf_range(-SPLIT_DRIFT_DEG, SPLIT_DRIFT_DEG))

		var segment := _create_child_segment(reference_node)
		_place_segment(segment, reference_node, angle_offset + drift, angle_offset + drift)

		_finalize_new_segment(reference_node, segment, parent)
		spawned.append(segment)

	_emit_spawn_events(reference_node, spawned)


func _create_child_segment(reference_node: ArmSegment) -> ArmSegment:
	var seg: ArmSegment = segment_scene.instantiate()
	seg.predecessor = reference_node
	seg.depth = reference_node.depth + 0.5
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

func _finalize_new_segment(reference_node: ArmSegment, segment: ArmSegment, parent: Node) -> void:
	parent.add_child(segment)
	_connect_death_handlers(segment)

func _connect_death_handlers(segment: ArmSegment) -> void:
	segment.segment_died.connect(_life_system.handle_segment_died)
	segment.segment_died.connect(_world_controller.handle_segment_died)
