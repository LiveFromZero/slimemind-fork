extends Node2D

signal arm_grew(arm: Node)

func _on_child_entered_tree(node: Node) -> void:
	arm_grew.emit(node)
