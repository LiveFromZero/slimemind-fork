extends Node2D
class_name WorldController

@onready var arm_root := $"../ArmRoot"

var arm_scene := load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var arm_segments: Array[ArmSegment] = []
@export var grow_interval: float     # Sekunden zwischen Wachstumsschüben
var grow_timer: float = 0.0
var sunlightamountInWorld 
var humidityInWorld 
var temperatureInWorld 
var BASE_Growth := 0.01
var Max_Food_Arm_Segment
var MaxFoodAmount
var MaxFoodCount

signal grow_arm(arm_node: ArmSegment, MaxFoodArmSegment : float)  # Signal, das den ausgewählten Arm mitgibt
signal spawnFood(Food_Amount : float, Food_Count : int)

func _spawn_arms(amount: int) -> void:
	for i in amount:
		var arm = arm_scene.instantiate() as ArmSegment
		arm.depth = 1
		arm.max_life_points = Max_Food_Arm_Segment
		arm.life_points = arm.max_life_points
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
		grow_arm.emit(arm, Max_Food_Arm_Segment)
		
		# Timer zurücksetzen (hier konstant, kann auch zufällig sein)
		grow_timer = grow_interval

func _on_growth_system_arm_has_grown_new_segment(arm: ArmSegment) -> void:
	arm_segments.erase(arm)

func _ready() -> void:
	randomize()
	read_defaults_from_UI()
	# Alle bereits existierenden Arme ins Tracking aufnehmen
	for arm in arm_root.get_children():
		var seg := arm as ArmSegment
		if seg:
			_register_segment(seg)
			arm_segments.append(seg)

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
	var tf := temp_fitness()      # 0..1
	var hf := humidity_fitness()  # 0..1
	var lf := light_fitness()     # 0..1

	# Kombi: Mittelwert statt Produkt-Killer
	var combined := (tf + hf + lf) / 3.0  # 0..1

	# Nie komplett tot: floor = Mindest-“Fitness”
	var floor_min := 0.25
	combined = lerp(floor_min, 1.0, combined)

	# Intervall skaliert umgekehrt: weniger Fitness => längeres Intervall
	# clamp schützt vor absurd klein/groß
	var min_interval := 0.005
	var max_interval := 0.5

	var interval := BASE_Growth / combined
	grow_interval = clampf(interval, min_interval, max_interval)

func temp_fitness() -> float:
	var t : float = temperatureInWorld
	var optimum := 22.0
	var sigma := 12.0
	var x := (t - optimum) / sigma
	return clampf(exp(-0.5 * x * x), 0.0, 1.0)

func humidity_fitness() -> float:
	var h := clampf(humidityInWorld, 1.0, 100.0)
	var x := (h - 1.0) / 99.0
	return clampf(x * x * (3.0 - 2.0 * x), 0.0, 1.0)

func light_fitness() -> float:
	var l := clampf(sunlightamountInWorld, 1.0, 100.0)
	var optimum := 15.0
	var sigma := 18.0
	var x := (l - optimum) / sigma
	return clampf(exp(-0.5 * x * x), 0.0, 1.0)

# Food

func _on_ui_spawn_food() -> void:
	spawnFood.emit(MaxFoodAmount, MaxFoodCount)

# UI-Handler
func read_defaults_from_UI() -> void:
	var slider_humidity := get_node("../../Ui/CanvasLayer2/VBoxContainer/Luftfeuchtigkeit") as HSlider
	humidityInWorld = slider_humidity.value
	var slider_lifepoints := get_node("../../Ui/CanvasLayer2/VBoxContainer/Lebenspunkte") as HSlider
	Max_Food_Arm_Segment = slider_lifepoints.value
	var slider_sunlight := get_node("../../Ui/CanvasLayer2/VBoxContainer/Sonnenlicht") as HSlider
	sunlightamountInWorld = slider_sunlight.value
	var slider_temperature := get_node("../../Ui/CanvasLayer2/VBoxContainer/Temperatur") as HSlider
	temperatureInWorld = slider_temperature.value
	var slider_foodamount := get_node("../../Ui/CanvasLayer2/VBoxContainer/Futtergröße") as HSlider
	MaxFoodAmount = slider_foodamount.value
	var slider_foodcount := get_node("../../Ui/CanvasLayer2/VBoxContainer/Futteranzahl") as HSlider
	MaxFoodCount = slider_foodcount.value

func _on_ui_update_life_points_for_arms(slider_lifepoints: float) -> void:
	Max_Food_Arm_Segment = slider_lifepoints * 10

func _on_ui_update_lightamount(slider_lightamount: float) -> void:
	sunlightamountInWorld = slider_lightamount
	slider_update_growthinterval()

func _on_ui_update_temperature(slider_temperature: float) -> void:
	temperatureInWorld = slider_temperature
	slider_update_growthinterval()

func _on_ui_update_humidity(slider_humidity_updated_from_ui: float) -> void:
	humidityInWorld = slider_humidity_updated_from_ui
	slider_update_growthinterval()

func _on_ui_update_food_amount(slider_foodamount: float) -> void:
	MaxFoodAmount = slider_foodamount

func _on_ui_update_food_count(slider_foodcount: float) -> void:
	MaxFoodCount = slider_foodcount
