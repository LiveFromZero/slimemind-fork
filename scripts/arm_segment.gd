extends Node2D

@onready var segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")
@onready var attachment_point: Marker2D = $Marker2D

var game_controller

var has_grown: bool = false
var has_split: bool = false

const GROWTH_INTERVAL := 0.4
const ARM_LENGTH := -50
const SPLIT_CHANCE := 0.2

var time_since_growth := 0.0
var rng := RandomNumberGenerator.new()
var rotation_options := [-7, -5, -3, -1, 2, 4, 6, 8]
var chosen_rotation = rotation_options.pick_random()

func _ready() -> void:
	game_controller = get_node("/root/Main/World")

func _process(delta: float) -> void:
	if not game_controller.simulation_active:
		return

	time_since_growth += delta

	if has_grown or has_split or time_since_growth < GROWTH_INTERVAL:
		return

	if not $Area2D/RayCast2D.is_colliding():
		grow_new_segment()

		if rng.randf() <= SPLIT_CHANCE:
			grow_new_segment()
			has_split = true

		has_grown = true
		set_physics_process(false)
		set_process(false)

	else:
		has_grown = true
		set_physics_process(false)
		set_process(false)


func grow_new_segment() -> void:
	var new_segment: Node2D = segment_scene.instantiate()
	get_parent().add_child(new_segment)

	new_segment.global_transform = attachment_point.global_transform
	new_segment.rotation_degrees += chosen_rotation
	new_segment.global_position += new_segment.global_transform.y * ARM_LENGTH
