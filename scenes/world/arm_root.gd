extends Node2D

signal new_arm_grew(arm: ArmSegment)

func _on_child_entered_tree(node: ArmSegment) -> void:
	new_arm_grew.emit(node)
