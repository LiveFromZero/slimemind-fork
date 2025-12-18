extends Node

@onready var arm_root := $"../ArmRoot"

var arm_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var arm_segments = []

func _on_arm_root_arm_grew(arm: Node) -> void:
	arm_segments.append(arm)


func _spawn_arms(amount: int) -> void:
	for i in amount:
		var arm = arm_scene.instantiate()
		arm_root.add_child(arm)

func _remove_arms(amount: int) -> void:
	for i in amount:
		var arm = arm_root.get_child(-1)
		arm.queue_free()

func _reposition_arms() -> void:
	var count := arm_root.get_child_count()
	if count == 0:
		return

	var radius := 200.0
	for i in count:
		var angle := TAU * i / count
		var arm := arm_root.get_child(i)
		arm.position = Vector2(cos(angle), sin(angle)) * radius


func _on_ui_arms_count_changed(count: int) -> void:
	var current_count := arm_root.get_child_count()
	if count > current_count:
		_spawn_arms(count - current_count)
		_reposition_arms()
	elif count < current_count:
		_remove_arms(current_count - count)
		_reposition_arms()
