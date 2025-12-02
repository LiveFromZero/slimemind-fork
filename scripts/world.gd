extends Node2D

var arm_segment_scene: PackedScene = preload("res://scenes/arm_segment.tscn")

var count_of_Arms = 1
var allplaced = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_h_slider_value_changed(value: float) -> void:
	count_of_Arms = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_segment: Node2D = arm_segment_scene.instantiate()
	if allplaced == false:
		match count_of_Arms:
			1:
				get_parent().add_child(arm_segment)
				allplaced = true
			2: # nor working
				get_parent().add_child(arm_segment)
				get_parent().add_child(arm_segment)
				allplaced = true
			
			_:
				pass
	
