extends Node2D

signal new_arm_grew(arm: Node)

func _on_child_entered_tree(node: Node) -> void:
	new_arm_grew.emit(node)
