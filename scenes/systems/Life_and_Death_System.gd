extends Node

func _on_arm_segment_segment_died(dead_segment: ArmSegment) -> void:
	# 1. Den gesamten Unterzweig (Kinder + Kindeskinder) sofort töten
	_kill_subtree_recursive(dead_segment)
	
	# 2. Referenzen beim Vorgänger aufräumen
	if dead_segment.predecessor:
		dead_segment.predecessor.children.erase(dead_segment)
		
		# 3. Rückwärts-Check: Nur wenn der Vorgänger jetzt KEINE Kinder mehr hat,
		#    stirbt er auch (und löst wieder die Kette aus)
		if dead_segment.predecessor.children.is_empty():
			dead_segment.predecessor._die()

# Rekursiv den ganzen Ast unter dem toten Segment killen
func _kill_subtree_recursive(segment: ArmSegment) -> void:
	for child in segment.children.duplicate():  # duplicate() sicherheitshalber
		_kill_subtree_recursive(child)  # erst Kinder töten
		child._die()                    # dann das Kind selbst
	# Nach der Rekursion: das Segment selbst wird außerhalb (durch emit) gekillt
