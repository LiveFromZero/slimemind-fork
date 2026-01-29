extends Node2D
class_name FoodManager

@export var food_scene: PackedScene

@export var min_distance: float = 32.0
@export var max_tries_per_food: int = 30

@export var spawn_center: Vector2 = Vector2.ZERO

# Basisgröße, damit field_size nicht jedes Mal kumuliert
@export var base_spawn_size: Vector2 = Vector2(1000, 600)
var spawn_size: Vector2

# Glockenkurve / Zufallsverteilung
@export var bell_sigma_fraction: float = 0.12 # 12% vom food_amount -> stark konzentriert
@export var min_food_multiplier: float = 0.4  # clamp: mindestens 40% vom Sliderwert
@export var max_food_multiplier: float = 2.2  # clamp: maximal 220% vom Sliderwert

# --- Exponentialverteiltes Auto-Spawn-Intervall (Wartezeit) ---
@export var auto_spawn_enabled: bool = false
@export var target_average_spawn_interval: float = 20.0 # Sekunden (Erwartungswert)
@export var min_spawn_interval: float = 5.0
@export var max_spawn_interval: float = 30.0

var food_spawn_timer: Timer
var _last_food_amount: float = 10000.0
var _last_food_count: int = 15
var _last_field_size: float = 7.0
var default_food_count: int = 15 # Die Menge an erschaffenen Futterhaufen pro Timer-Ablauf

func _ready() -> void:
	initialiseFoodTimer()
	
func initialiseFoodTimer() -> void:
	food_spawn_timer = Timer.new()
	food_spawn_timer.one_shot = true
	add_child(food_spawn_timer)
	food_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_world_controller_spawn_food(food_amount: float, food_count: int, field_size: float) -> void:
	# Werte merken, damit Auto-Spawn später dasselbe Setup benutzen kann
	_last_food_amount = food_amount
	_last_food_count = default_food_count
	_last_field_size = field_size

	_spawn_food_batch(food_amount, food_count, field_size)

	if auto_spawn_enabled:
		schedule_next_food_spawn()

func _on_spawn_timer_timeout() -> void:
	# Wenn nie per UI/WorldController initialisiert wurde, spawnen wir nicht ins Nichts.
	if _last_food_count <= 0 or _last_food_amount <= 0.0:
		return

	_spawn_food_batch(_last_food_amount, _last_food_count, _last_field_size)

	if auto_spawn_enabled:
		schedule_next_food_spawn()


func schedule_next_food_spawn() -> void:
	if not is_instance_valid(food_spawn_timer):
		return

	var next_spawn_delay := _sample_exponential_interval(target_average_spawn_interval)
	next_spawn_delay = clampf(next_spawn_delay, min_spawn_interval, max_spawn_interval)

	food_spawn_timer.start(next_spawn_delay)


func _sample_exponential_interval(target_average_interval: float) -> float:
	# Erzeugt ein zufälliges Zeitintervall mit gegebenem Durchschnitt
	# Formel: T = -ln(U) * target_average_interval

	var safe_average := maxf(0.0001, target_average_interval)
	var uniform_random := randf()
	var safe_random := maxf(uniform_random, 0.000001)

	return -log(safe_random) * safe_average


func _spawn_food_batch(food_amount: float, food_count: int, field_size: float) -> void:
	if food_scene == null:
		push_error("FoodManager: food_scene ist nicht gesetzt.")
		return

	# Kein Feld-Wachstum pro Klick mehr.
	spawn_size = base_spawn_size * field_size

	var placed_positions: Array[Vector2] = []

	for n in range(food_count):
		# Nährstoffe pro Instanz: Glockenkurve um food_amount
		var nutrients := _sample_food_amount(food_amount)

		# Optional: Mindestabstand leicht an Größe koppeln (damit große Brocken nicht überlappen)
		var local_min_dist := min_distance * _distance_scale_from_amount(nutrients, food_amount)

		var pos: Vector2 = _pick_position(placed_positions, local_min_dist)
		if pos == null:
			print("FoodManager: Konnte keinen freien Spawnplatz finden für Food ", n)
			continue

		var food := food_scene.instantiate() as FoodSource

		food.total_nutrients = nutrients
		food.current_nutrients = nutrients

		# Referenz für die Visual-Skalierung (damit Sliderwert = “normale” Größe)
		food.nutrients_scale_reference = maxf(1.0, food_amount)

		food.global_position = pos
		add_child(food)

		placed_positions.append(pos)


func _sample_food_amount(target_food_amount: float) -> float:
	var base_food_amount := maxf(1.0, target_food_amount)
	var random_spread_amount := maxf(1.0, base_food_amount * bell_sigma_fraction)

	# Godot 4: Normalverteilung
	var generated_food_amount := randfn(base_food_amount, random_spread_amount)

	# Clamp gegen Quatschwerte
	generated_food_amount = clampf(
		generated_food_amount,
		base_food_amount * min_food_multiplier,
		base_food_amount * max_food_multiplier
	)
	return generated_food_amount

func _distance_scale_from_amount(object_amount: float, reference_amount: float) -> float:
	# Wenn object_amount = 4x reference_amount
	# -> Abstandsskala ≈ sqrt(4) = 2  (also etwa doppelt so viel Abstand)

	var safe_reference_amount := maxf(1.0, reference_amount)

	var relative_size_factor := maxf(0.0, object_amount / safe_reference_amount)
	var distance_scale := pow(relative_size_factor, 0.5)

	return clampf(distance_scale, 0.8, 1.6)


func _pick_position(existing_positions: Array[Vector2], minimum_distance: float) -> Variant:
	for attempt_index in range(max_tries_per_food):
		var local_spawn_area := _get_spawn_rect_local()

		var random_x := randf_range(
			local_spawn_area.position.x,
			local_spawn_area.position.x + local_spawn_area.size.x
		)

		var random_y := randf_range(
			local_spawn_area.position.y,
			local_spawn_area.position.y + local_spawn_area.size.y
		)

		var candidate_position := to_global(Vector2(random_x, random_y))

		var is_position_valid := true
		for placed_position in existing_positions:
			if placed_position.distance_to(candidate_position) < minimum_distance:
				is_position_valid = false
				break

		if is_position_valid:
			return candidate_position

	return null


func _get_spawn_rect_local() -> Rect2:
	return Rect2(spawn_center - spawn_size * 0.5, spawn_size)

func _on_world_controller_update_food_timer_signal() -> void:
	initialiseFoodTimer()
