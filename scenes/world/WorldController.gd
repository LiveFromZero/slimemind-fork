extends Node2D
class_name WorldController

# --- Nodes ---
@onready var arm_root: Node = $"../ArmRoot"
@onready var food_root: Node = $"../../Food/FoodManager"

@onready var ui_slider_humidity := get_node("../../Ui/Control_UI/VBoxContainer/LuftfeuchtigkeitSlider") as HSlider
@onready var ui_slider_lifepoints := get_node("../../Ui/Control_UI/VBoxContainer/LebenspunkteSlider") as HSlider
@onready var ui_slider_sunlight := get_node("../../Ui/Control_UI/VBoxContainer/SonnenlichtSlider") as HSlider
@onready var ui_slider_temperature := get_node("../../Ui/Control_UI/VBoxContainer/TemperaturSlider") as HSlider
@onready var ui_slider_foodamount := get_node("../../Ui/Control_UI/VBoxContainer/FuttermengeSlider") as HSlider
@onready var ui_slider_foodcount := get_node("../../Ui/Control_UI/VBoxContainer/FutteranzahlSlider") as HSlider
@onready var ui_slider_countarms := get_node("../../Ui/Control_UI/VBoxContainer/StartarmeSlider") as HSlider
@onready var ui_slider_simulationspeed := get_node("../../Ui/Control_UI/VBoxContainer/SimulationSpeedSlider") as HSlider
@onready var ui_slider_fieldsize := get_node("../../Ui/Control_UI/VBoxContainer/FeldgrößeSlider") as HSlider

# --- Scenes / Data ---
var arm_scene: PackedScene = load("res://scenes/arms/ArmSegment.tscn") as PackedScene
var arm_segments: Array[ArmSegment] = []

# --- Simulation ---
@export var grow_interval: float = 0.02 # Sekunden zwischen Wachstumsschüben (Basis-Intervall)
var sim_speed: float = 1.0

# Timer statt per-frame While-Schleife (respektiert Engine.time_scale)
var _grow_timer: Timer
var _rng := RandomNumberGenerator.new()

# --- World State (from UI) ---
var sunlightamountInWorld: float
var humidityInWorld: float
var temperatureInWorld: float

var BASE_Growth: float = 0.01
var Max_Food_Arm_Segment: float
var MaxFoodAmount: int
var MaxFoodCount: int
var FieldSize: float
var ArmCount: int

# World-Multiplier für Schaden
var ArmSegmentDamage: float = 1.0

# --- Signals ---
signal grow_arm(arm_node: ArmSegment, MaxFoodArmSegment: float)
signal spawnFood(Food_Amount: float, Food_Count: int, Field_Size: float)
signal reset_game
signal updateFoodTimerSignal

# =============================================================================
# Lifecycle
# =============================================================================
func _ready() -> void:
	_rng.randomize()
	read_defaults_from_UI()
	_on_ui_arms_count_changed(ArmCount)

	slider_update_growthinterval() # setzt grow_interval
	slider_update_damage()         # setzt ArmSegmentDamage

	# Wachstumstimer anlegen (billiger als pro Frame while/catch-up)
	_grow_timer = Timer.new()
	_grow_timer.name = "GrowTimer"
	_grow_timer.one_shot = false
	_grow_timer.ignore_time_scale = false # Engine.time_scale soll wirken
	_grow_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(_grow_timer)
	_grow_timer.timeout.connect(_on_grow_timer_timeout)

	_update_grow_timer()

	# Alle bereits existierenden Arme ins Tracking aufnehmen + Damage anwenden
	for arm in arm_root.get_children():
		var seg := arm as ArmSegment
		if seg:
			_register_segment(seg)
			arm_segments.append(seg)
			_apply_damage_multiplier(seg)

	# Falls UI-Speed schon gesetzt ist
	if ui_slider_simulationspeed:
		set_sim_speed(ui_slider_simulationspeed.value)

# =============================================================================
# Simulation Control
# =============================================================================
func set_sim_speed(v: float) -> void:
	sim_speed = maxf(v, 0.0)
	_update_grow_timer()

func _update_grow_timer() -> void:
	# Grow interval sanity
	if grow_interval <= 0.0 or is_nan(grow_interval) or is_inf(grow_interval):
		if is_instance_valid(_grow_timer):
			_grow_timer.stop()
		return

	# sim_speed = 0 => Simulation pausiert
	if sim_speed <= 0.0:
		if is_instance_valid(_grow_timer):
			_grow_timer.stop()
		return

	# Effektives Intervall: grow_interval skaliert durch sim_speed.
	# Engine.time_scale wirkt automatisch, weil Timer nicht ignoriert.
	var effective_interval := grow_interval / sim_speed

	# Timer-Granularität: absurd kleine Werte bringen nix außer CPU-Last
	effective_interval = maxf(effective_interval, 0.001)

	if !is_instance_valid(_grow_timer):
		return

	# Nur anfassen, wenn sich wirklich was ändert
	if absf(_grow_timer.wait_time - effective_interval) > 0.0005:
		_grow_timer.wait_time = effective_interval

	if !_grow_timer.is_stopped():
		return
	_grow_timer.start()

func _on_grow_timer_timeout() -> void:
	if arm_segments.is_empty():
		get_tree().call_group("Statistik", "all_non_feeding_segments_are_dead")
		return

	for i in range(int(sim_speed)):
		var idx := _rng.randi_range(0, arm_segments.size() - 1)
		var arm: ArmSegment = arm_segments[idx]
		if !is_instance_valid(arm):
			arm_segments.remove_at(idx)
			return

		grow_arm.emit(arm, Max_Food_Arm_Segment)

# =============================================================================
# Arms Management
# =============================================================================
func _spawn_arms(amount: int) -> void:
	if amount <= 0:
		return

	for _i in range(amount):
		var arm := arm_scene.instantiate() as ArmSegment
		arm.depth = 1
		arm.max_life_points = Max_Food_Arm_Segment
		arm.life_points = arm.max_life_points

		arm_root.add_child(arm)

		_register_segment(arm)
		arm_segments.append(arm)

		_apply_damage_multiplier(arm)

func _remove_arms(amount: int) -> void:
	if amount <= 0:
		return

	for _i in range(amount):
		var count := arm_root.get_child_count()
		if count <= 0:
			break
		var arm := arm_root.get_child(count - 1)
		if arm:
			arm.queue_free()
			arm_segments.erase(arm)

func _reposition_arms() -> void:
	var count: int = arm_root.get_child_count()
	if count == 0:
		return

	for i in range(count):
		var arm := arm_root.get_child(i)
		var angle: float = TAU * float(i) / float(count)

		arm.position = Vector2.ZERO
		arm.rotation = angle

func _on_ui_arms_count_changed(count: int) -> void:
	var current_count: int = arm_root.get_child_count()

	if count > current_count:
		_spawn_arms(count - current_count)
	elif count < current_count:
		_remove_arms(current_count - count)

	_reposition_arms()

# =============================================================================
# Segment Events / Tracking
# =============================================================================
func _on_growth_system_arm_has_grown_new_segment(arm: ArmSegment) -> void:
	arm_segments.erase(arm)

func _on_growth_system_new_segment_alive(segment: ArmSegment) -> void:
	_apply_damage_multiplier(segment)
	_register_segment(segment)
	arm_segments.append(segment)

func handle_segment_died(dead_segment: ArmSegment) -> void:
	_on_arm_segment_segment_died(dead_segment)

func _on_arm_segment_segment_died(arm_that_died: ArmSegment) -> void:
	arm_segments.erase(arm_that_died)

func _on_arm_segment_eating(segment: ArmSegment) -> void:
	arm_segments.erase(segment)

func _on_arm_segment_stopped_eating(segment: ArmSegment) -> void:
	if !is_instance_valid(segment):
		return
	if arm_segments.has(segment):
		return
	arm_segments.append(segment)

func _register_segment(seg: ArmSegment) -> void:
	if seg == null:
		return

	if !seg.eating.is_connected(_on_arm_segment_eating):
		seg.eating.connect(_on_arm_segment_eating)

	if !seg.stopped_eating.is_connected(_on_arm_segment_stopped_eating):
		seg.stopped_eating.connect(_on_arm_segment_stopped_eating)

	if !seg.segment_died.is_connected(handle_segment_died):
		seg.segment_died.connect(handle_segment_died)

# =============================================================================
# Damage Multiplier Application
# =============================================================================
func _apply_damage_multiplier(seg: ArmSegment) -> void:
	if !is_instance_valid(seg):
		return
	# Wichtig: immer vom Segment-Basiswert ausgehen (BASE_DAMAGE * depth),
	# damit Slider-Änderungen NICHT exponentiell eskalieren.
	seg._damage_per_second = ArmSegment.BASE_DAMAGE * float(seg.depth) * ArmSegmentDamage

func _apply_damage_to_all_segments() -> void:
	for child in arm_root.get_children():
		var seg := child as ArmSegment
		if seg:
			_apply_damage_multiplier(seg)

# =============================================================================
# Weather (affects grow_interval)
# =============================================================================
func slider_update_growthinterval() -> void:
	var tf: float = temp_fitness()
	var hf: float = humidity_fitness()
	var lf: float = light_fitness()

	var combined: float = (tf + hf + lf) / 3.0

	var floor_min: float = 0.02
	combined = lerp(floor_min, 1.0, combined)

	var fastest_interval := 0.005
	var slowest_interval := 3.0

	var interval: float = BASE_Growth / combined
	grow_interval = clampf(interval, fastest_interval, slowest_interval)

	_update_grow_timer()

func slider_update_damage() -> void:
	# Extreme zuerst, sonst sind sie durch "mildere" Bedingungen schon abgefangen.
	if temperatureInWorld > 75.0 and  sunlightamountInWorld > 75.0:
		ArmSegmentDamage = 15.0
	elif temperatureInWorld > 75 or sunlightamountInWorld > 75:
		ArmSegmentDamage = 10.0
	elif temperatureInWorld > 30.0 or sunlightamountInWorld > 60.0:
		ArmSegmentDamage = 2.0
	elif temperatureInWorld >= 18.0 and temperatureInWorld <= 28.0 and sunlightamountInWorld <10 and sunlightamountInWorld > 25:
		ArmSegmentDamage = 1.0
	else:
		ArmSegmentDamage = 1.5

	_apply_damage_to_all_segments()

func temp_fitness() -> float:
	var t: float = temperatureInWorld
	var optimum: float = 22.0
	var sigma: float = 12.0
	var x: float = (t - optimum) / sigma
	return clampf(exp(-0.5 * x * x), 0.0, 1.0)

func humidity_fitness() -> float:
	var h: float = clampf(humidityInWorld, 1.0, 100.0)
	var x: float = (h - 1.0) / 99.0
	return clampf(x * x * (3.0 - 2.0 * x), 0.0, 1.0)

func light_fitness() -> float:
	var l: float = clampf(sunlightamountInWorld, 1.0, 100.0)
	var optimum: float = 15.0
	var sigma: float = 18.0
	var x: float = (l - optimum) / sigma
	return clampf(exp(-0.5 * x * x), 0.0, 1.0)

# =============================================================================
# Food
# =============================================================================
func _on_ui_spawn_food() -> void:
	spawnFood.emit(MaxFoodAmount, MaxFoodCount, FieldSize)

# =============================================================================
# UI Handlers
# =============================================================================
func read_defaults_from_UI() -> void:
	humidityInWorld = ui_slider_humidity.value
	Max_Food_Arm_Segment = ui_slider_lifepoints.value
	sunlightamountInWorld = ui_slider_sunlight.value
	temperatureInWorld = ui_slider_temperature.value
	MaxFoodAmount = int(ui_slider_foodamount.value)
	MaxFoodCount = int(ui_slider_foodcount.value)
	FieldSize = ui_slider_fieldsize.value
	ArmCount = int(ui_slider_countarms.value)

func _on_ui_reset_simulation() -> void:
	var was_paused := get_tree().paused
	get_tree().paused = false

	if is_instance_valid(_grow_timer):
		_grow_timer.stop()

	for child in arm_root.get_children():
		child.free()
	for food_child in food_root.get_children():
		food_child.free()

	arm_segments.clear()

	ui_slider_countarms.value = 0.0
	reset_slider()
	read_defaults_from_UI()

	_reposition_arms()
	slider_update_growthinterval()
	slider_update_damage()

	_update_grow_timer()
	updateFoodTimer()

	get_tree().paused = was_paused

	reset_game.emit()

func updateFoodTimer() -> void:
	updateFoodTimerSignal.emit()

func reset_slider() -> void:
	ui_slider_foodcount.value = 100
	ui_slider_foodamount.value = 10000
	ui_slider_lifepoints.value = 50
	ui_slider_sunlight.value = 15.0
	ui_slider_temperature.value = 22.0
	ui_slider_humidity.value = 70.0
	ui_slider_countarms.value = 4.0
	ui_slider_simulationspeed.value = 1.0
	ui_slider_fieldsize.value = 7.0

func _on_ui_update_life_points_for_arms(slider_lifepoints: float) -> void:
	Max_Food_Arm_Segment = slider_lifepoints * 10.0

func _on_ui_update_lightamount(slider_lightamount: float) -> void:
	sunlightamountInWorld = slider_lightamount
	slider_update_growthinterval()
	slider_update_damage()

func _on_ui_update_temperature(slider_temperature: float) -> void:
	temperatureInWorld = slider_temperature
	slider_update_growthinterval()
	slider_update_damage()

func _on_ui_update_humidity(slider_humidity_updated_from_ui: float) -> void:
	humidityInWorld = slider_humidity_updated_from_ui
	slider_update_growthinterval()
	slider_update_damage()

func _on_ui_update_food_amount(slider_foodamount: int) -> void:
	MaxFoodAmount = int(slider_foodamount)

func _on_ui_update_food_count(slider_foodcount: int) -> void:
	MaxFoodCount = int(slider_foodcount)

func _on_ui_update_fieldsize(slider_fieldsize: float) -> void:
	FieldSize = slider_fieldsize
