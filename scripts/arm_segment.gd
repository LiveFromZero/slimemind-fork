extends Node2D

# Pfad zu der ArmSegment.tscn-Datei
@onready var segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")

# Referenz auf den Marker
@onready var attachment_point: Marker2D = $Marker2D

var has_grown: bool = false
const GROWTH_INTERVAL: float = 0.2
var time_since_growth: float = 0.0

func _process(delta: float) -> void:
	time_since_growth += delta
	
	if not has_grown and time_since_growth >= GROWTH_INTERVAL:
		grow_new_segment()
		has_grown = true
		
func grow_new_segment() -> void:
	# 1. Neues Segment instanziieren
	var new_segment: Node2D = segment_scene.instantiate()
	
	# 5. Das neue Segment als Kind zum obersten Root-Node hinzufügen
	get_parent().add_child(new_segment)
	
	new_segment.global_rotation = attachment_point.global_rotation
	new_segment.global_position = attachment_point.global_position
	
	# 6. Transformation zuweisen -> Platzierung am Ankerpunkt
	new_segment.position += Vector2(0, -50)
