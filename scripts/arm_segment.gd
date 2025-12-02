extends Node2D

# Pfad zu der ArmSegment.tscn-Datei
@onready var segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")

# Referenz auf den Marker
@onready var attachment_point: Marker2D = $Marker2D

var has_grown: bool = false
const GROWTH_INTERVAL: float = 0.3
var time_since_growth: float = 0.0 # Wird von Delta gesetzt
var length_of_arm: int = -50
var random_arm_split_chance: float = 0.3
var rng = RandomNumberGenerator.new()
var randomRotationOptions = [-5,-3,-1,2,4,6]
var randomRotationOutOfOptions = randomRotationOptions.pick_random()
var hasSplit: bool = false

func _process(delta: float) -> void:
	time_since_growth += delta
	
	if not has_grown and not hasSplit and time_since_growth >= GROWTH_INTERVAL:
		grow_new_segment()
		if rng.randf_range(0,1) <= random_arm_split_chance:
			grow_new_segment()
			hasSplit = true
		has_grown = true
		
func grow_new_segment() -> void:
	
	# 1. Neues Segment instanziieren
	var new_segment: Node2D = segment_scene.instantiate()
	
	# 5. Das neue Segment als Kind zum obersten Root-Node hinzufügen
	get_parent().add_child(new_segment)
		
	new_segment.global_transform = attachment_point.global_transform
	new_segment.rotation_degrees += randomRotationOutOfOptions
	new_segment.global_position += new_segment.global_transform.y * length_of_arm
		
