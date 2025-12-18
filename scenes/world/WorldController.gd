extends Node

@onready var arm_root := $"../ArmRoot"

var arm_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var arm_segments: Array[Node] = []
@export var grow_interval: float = 0.01       # Sekunden zwischen Wachstumsschüben
var grow_timer: float = 0.0
signal grow_arm(arm_node: Node)  # Signal, das den ausgewählten Arm mitgibt

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
		arm_segments.erase(arm)

func _reposition_arms() -> void:
	var count = arm_root.get_child_count()
	if count == 0:
		return
	
	var radius = 100.0  # Länge der Arme
	for i in count:
		var arm = arm_root.get_child(i)
		var angle = TAU * i / count  # gleichmäßig verteilen

		# Arm bleibt am Ursprung
		arm.position = Vector2.ZERO

		# Arm zeigt nach außen
		arm.rotation = angle

func _on_ui_arms_count_changed(count: int) -> void:
	
	var current_count := arm_root.get_child_count()
	if count > current_count:
		_spawn_arms(count - current_count)
		
	elif count < current_count:
		_remove_arms(current_count - count)
	
	_reposition_arms()

# Zufälliger Arm wird ausgewählt, der wachsen darf

func _process(delta: float) -> void:
	if arm_segments.size() == 0:
		return  # nichts zu tun
	
	# Timer runterzählen
	grow_timer -= delta
	if grow_timer <= 0:
		# zufälligen Arm auswählen
		var arm = arm_segments[randi() % arm_segments.size()]
		
		# Signal senden mit dem Arm als Parameter
		emit_signal("grow_arm", arm)
		
		# Timer zurücksetzen (hier konstant, kann auch zufällig sein)
		grow_timer = grow_interval

func _on_growth_system_arm_grew(arm: Node2D) -> void:
	arm_segments.erase(arm)
