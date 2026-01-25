extends Node2D
class_name FoodManager

@export var food_scene: PackedScene

# Spawn-Feld (lokal zum FoodManager). Einfach im Inspector einstellen.
@export var spawn_rect := Rect2(Vector2(-500, -300), Vector2(1000, 600))

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
@export var exp_mean_interval: float = 120.0 # Sekunden (Erwartungswert)
@export var exp_min_interval: float = 60.0
@export var exp_max_interval: float = 480.0

var _spawn_timer: Timer
var _last_food_amount: float = 0.0
var _last_food_count: int = 0
var _last_field_size: float = 1.0


func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_world_controller_spawn_food(food_amount: float, food_count: int, field_size: float) -> void:
	# Werte merken, damit Auto-Spawn später dasselbe Setup benutzen kann
	_last_food_amount = food_amount
	_last_food_count = food_count
	_last_field_size = field_size

	_spawn_food_batch(food_amount, food_count, field_size)

	if auto_spawn_enabled:
		_schedule_next_spawn()


func _on_spawn_timer_timeout() -> void:
	# Wenn nie per UI/WorldController initialisiert wurde, spawnen wir nicht ins Nichts.
	if _last_food_count <= 0 or _last_food_amount <= 0.0:
		return

	_spawn_food_batch(_last_food_amount, _last_food_count, _last_field_size)

	if auto_spawn_enabled:
		_schedule_next_spawn()


func _schedule_next_spawn() -> void:
	if not is_instance_valid(_spawn_timer):
		return

	var dt := _sample_exponential_interval(exp_mean_interval)
	dt = clampf(dt, exp_min_interval, exp_max_interval)

	_spawn_timer.start(dt)


func _sample_exponential_interval(mean: float) -> float:
	# Exponentialverteilung für Wartezeiten:
	# T = -ln(U) * mean, mit U ∈ (0,1)
	var m := maxf(0.0001, mean)
	var u := randf()
	u = maxf(u, 0.000001) # log(0) vermeiden
	return -log(u) * m


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


func _sample_food_amount(mean_amount: float) -> float:
	var mean := maxf(1.0, mean_amount)
	var sigma := maxf(1.0, mean * bell_sigma_fraction)

	# Godot 4: Normalverteilung
	var v := randfn(mean, sigma)

	# Clamp gegen Quatschwerte
	v = clampf(v, mean * min_food_multiplier, mean * max_food_multiplier)
	return v


func _distance_scale_from_amount(amount: float, ref: float) -> float:
	# wenn amount = 4x ref -> scale ~ sqrt(4)=2 -> Abstand etwa doppelt
	var r := maxf(1.0, ref)
	return clampf(pow(maxf(0.0, amount / r), 0.5), 0.8, 1.6)


func _pick_position(existing: Array[Vector2], local_min_distance: float) -> Variant:
	for i in range(max_tries_per_food):
		var r := _get_spawn_rect_local()
		var x := randf_range(r.position.x, r.position.x + r.size.x)
		var y := randf_range(r.position.y, r.position.y + r.size.y)
		var candidate := to_global(Vector2(x, y))

		var ok := true
		for p in existing:
			if p.distance_to(candidate) < local_min_distance:
				ok = false
				break

		if ok:
			return candidate

	return null


func _get_spawn_rect_local() -> Rect2:
	return Rect2(spawn_center - spawn_size * 0.5, spawn_size)
