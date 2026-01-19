extends Node2D
class_name FoodManager

@export var food_scene: PackedScene

# Spawn-Feld (lokal zum FoodManager). Einfach im Inspector einstellen.
@export var spawn_rect := Rect2(Vector2(-500, -300), Vector2(1000, 600))

# Optional: wie weit Food voneinander weg sein soll (gegen Overlap-Spam)
@export var min_distance: float = 32.0
@export var max_tries_per_food: int = 30


func _on_world_controller_spawn_food(food_amount: float, food_count: int) -> void:
	if food_scene == null:
		push_error("FoodManager: food_scene ist nicht gesetzt.")
		return

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
		# optional: food.current_nutrients = food_amount  # falls du _ready umgehen willst

		food.global_position = pos
		add_child(food)

		placed_positions.append(pos)


func _pick_position(existing: Array[Vector2]) -> Variant:
	for i in range(max_tries_per_food):
		var x := randf_range(spawn_rect.position.x, spawn_rect.position.x + spawn_rect.size.x)
		var y := randf_range(spawn_rect.position.y, spawn_rect.position.y + spawn_rect.size.y)

		var candidate := to_global(Vector2(x, y))  # weil spawn_rect lokal ist

		var ok := true
		for p in existing:
			if p.distance_to(candidate) < min_distance:
				ok = false
				break

		if ok:
			return candidate

	return null
