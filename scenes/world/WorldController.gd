extends Node2D
class_name WorldController

@onready var arm_root := $"../ArmRoot"

var arm_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var arm_segments: Array[ArmSegment] = []
@export var grow_interval: float = 0.01       # Sekunden zwischen Wachstumsschüben
var grow_timer: float = 0.0
var sunlightamountInWorld = 1
var humidityInWorld = 1
var temperatureInWorld = 1
var BASE_Growth := 0.01

signal grow_arm(arm_node: ArmSegment)  # Signal, das den ausgewählten Arm mitgibt

func _spawn_arms(amount: int) -> void:
	for i in amount:
		var arm = arm_scene.instantiate() as ArmSegment
		arm.depth = 1
		arm_root.add_child(arm)
		_register_segment(arm)
		arm_segments.append(arm)

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

func _on_growth_system_arm_has_grown_new_segment(arm: ArmSegment) -> void:
	arm_segments.erase(arm)

func _ready() -> void:
	# Alle bereits existierenden Arme ins Tracking aufnehmen
	for arm in arm_root.get_children():
		var seg := arm as ArmSegment
		if seg:
			_register_segment(seg)
			arm_segments.append(seg)
	slider_update_growthinterval()

func _on_ui_reset_simulation() -> void:
	var allChildren = arm_root.get_children()
	for child in allChildren:
		child.queue_free()
	arm_segments = []

func handle_segment_died(dead_segment: ArmSegment) -> void:
	_on_arm_segment_segment_died(dead_segment)

func _on_arm_segment_segment_died(arm_that_died: ArmSegment) -> void:
	if arm_segments.has(arm_that_died):
		arm_segments.erase(arm_that_died)
		
func _on_arm_segment_eating(segment : ArmSegment) -> void:
	arm_segments.erase(segment)

func _on_arm_segment_stopped_eating(segment: ArmSegment) -> void:
	if !is_instance_valid(segment):
		return
	if arm_segments.has(segment):
		return
	arm_segments.append(segment)

func _on_growth_system_new_segment_alive(segment: ArmSegment) -> void:
	_register_segment(segment)
	arm_segments.append(segment)

func _register_segment(seg: ArmSegment) -> void:
	if seg == null:
		return

	# Doppelt verbinden vermeiden
	if !seg.eating.is_connected(_on_arm_segment_eating):
		seg.eating.connect(_on_arm_segment_eating)

	if !seg.stopped_eating.is_connected(_on_arm_segment_stopped_eating):
		seg.stopped_eating.connect(_on_arm_segment_stopped_eating)

	if !seg.segment_died.is_connected(handle_segment_died):
		seg.segment_died.connect(handle_segment_died)

# Wetter

func slider_update_growthinterval() -> void:
	grow_interval = BASE_Growth * temp_factor() * humidity_factor() * light_factor()

func temp_factor() -> float:
	return temperatureInWorld/100
	#return bell(temperatureInWorld, 24.0, 8.0)

func humidity_factor() -> float:
	return humidityInWorld/100
	#return bell(humidityInWorld, 90.0, 15)

func light_factor() -> float:
	return sunlightamountInWorld/100
	#return bell(sunlightamountInWorld, 15.0, 20.0)

func slider_update_sunlight(sunlightamountFromSlider:float) -> void:
	sunlightamountInWorld = sunlightamountFromSlider

func slider_update_humidity(humidityFromSlider:float) -> void:
	humidityInWorld = humidityFromSlider

func slider_update_temperature(temperatureFromSlider:float) -> void:
	temperatureInWorld = temperatureFromSlider
