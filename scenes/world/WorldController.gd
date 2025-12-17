extends Node

# Methode zum Spawnen eines Segments
func spawn_segment() -> void:
	# Lade die Szene als PackedScene
	var packed: PackedScene = load("res://scenes/arms/ArmSegment.tscn") as PackedScene
	
	# Instanziiere die Szene
	var instance: Node = packed.instantiate()
	
	# Füge sie im Baum hinzu
	var parent_node: Node = get_node("/root/Main/World/ArmRoot")
	parent_node.add_child(instance)


func _on_ui_spawn_arm() -> void:
	spawn_segment()
