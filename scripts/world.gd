extends Node2D

var arm_segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")

var count_of_Arms = 4
var allplaced = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# func _on_h_slider_value_changed(value: float) -> void:
#	count_of_Arms = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_segment: Node2D = arm_segment_scene.instantiate()
	arm_segment.global_position = Vector2(0,-20)
	var arm_segment2: Node2D = arm_segment_scene.instantiate()
	arm_segment2.global_position = Vector2(20,0)
	arm_segment2.global_rotation_degrees = 90
	var arm_segment3: Node2D = arm_segment_scene.instantiate()
	arm_segment3.global_position = Vector2(0,20)
	arm_segment3.global_rotation_degrees = 180
	var arm_segment4: Node2D = arm_segment_scene.instantiate()
	arm_segment4.global_position = Vector2(-20,0)
	arm_segment4.global_rotation_degrees = 270
	
	if allplaced == false:
		match count_of_Arms:
			1:
				get_parent().add_child(arm_segment)
				allplaced = true
			2: 
				get_parent().add_child(arm_segment)
				get_parent().add_child(arm_segment2)
				allplaced = true
			3:
				get_parent().add_child(arm_segment)
				get_parent().add_child(arm_segment2)
				get_parent().add_child(arm_segment3)
				allplaced = true
			4:
				get_parent().add_child(arm_segment)
				get_parent().add_child(arm_segment2)
				get_parent().add_child(arm_segment3)
				get_parent().add_child(arm_segment4)
				allplaced = true
			_:
				pass
	
