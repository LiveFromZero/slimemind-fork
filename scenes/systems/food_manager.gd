extends Node2D
class_name FoodManager

@export var food_scene: PackedScene

# Spawn-Feld (lokal zum FoodManager). Einfach im Inspector einstellen.
@export var spawn_rect := Rect2(Vector2(-500, -300), Vector2(1000, 600))

# Optional: wie weit Food voneinander weg sein soll (gegen Overlap-Spam)
@export var min_distance: float = 32.0
@export var max_tries_per_food: int = 30

@export var spawn_center: Vector2 = Vector2.ZERO
@export var spawn_size: Vector2 = Vector2(1000, 600) # Breite/Höhe

func _on_world_controller_spawn_food(food_amount: float, food_count: int, field_size:float) -> void:
	if food_scene == null:
		push_error("FoodManager: food_scene ist nicht gesetzt.")
		return
	
	spawn_size.x = spawn_size.x * field_size
	spawn_size.y = spawn_size.y * field_size
	
	var placed_positions: Array[Vector2] = []

	for n in range(food_count):
		var pos : Vector2 = _pick_position(placed_positions)
		if pos == null:
			# kein Platz gefunden, dann halt nicht (oder: einfach trotzdem random)
			print("FoodManager: Konnte keinen freien Spawnplatz finden für Food ", n)
			continue

		var food := food_scene.instantiate() as FoodSource
		food.total_nutrients = food_amount
		# optional: food.absorption_rate = ...
		food.current_nutrients = food_amount  # falls du _ready umgehen willst

		food.global_position = pos
		add_child(food)

		placed_positions.append(pos)

func _pick_position(existing: Array[Vector2]) -> Variant:
	for i in range(max_tries_per_food):
		var r := _get_spawn_rect_local()
		var x := randf_range(r.position.x, r.position.x + r.size.x)
		var y := randf_range(r.position.y, r.position.y + r.size.y)
		var candidate := to_global(Vector2(x, y))


		var ok := true
		for p in existing:
			if p.distance_to(candidate) < min_distance:
				ok = false
				break

		if ok:
			return candidate

	return null

func _get_spawn_rect_local() -> Rect2:
	return Rect2(spawn_center - spawn_size * 0.5, spawn_size)
