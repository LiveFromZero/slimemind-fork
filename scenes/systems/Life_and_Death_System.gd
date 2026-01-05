extends Node

var all_living_nodes: = []

func _on_arm_root_new_arm_grew(arm: Node) -> void:
	all_living_nodes.append(arm)
