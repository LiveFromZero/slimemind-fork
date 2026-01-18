extends Node
class_name LifeAndDeathSystem

func _on_arm_segment_segment_died(dead_segment: ArmSegment) -> void:
	_kill_subtree_recursive(dead_segment)

	if dead_segment.predecessor:
		dead_segment.predecessor.children.erase(dead_segment)

		if dead_segment.predecessor.children.is_empty():
			dead_segment.predecessor._die()

func _kill_subtree_recursive(segment: ArmSegment) -> void:
	for child in segment.children.duplicate():
		_kill_subtree_recursive(child)
		child._die()
