extends Area2D
class_name FoodSource

@export var total_nutrients: float = 10000.0
@export var absorption_rate: float = 100.0 # nutrients per second per consumer

# Referenzwert für Skalierung (wird vom FoodManager auf den Slider-Wert gesetzt)
@export var nutrients_scale_reference: float = 10000.0

# Wie stark Größenunterschiede sichtbar werden
@export var scale_power: float = 0.5 # 0.5 = sqrt -> Fläche ~ Nährstoffe (ganz brauchbar)
@export var min_visual_scale: float = 0.6
@export var max_visual_scale: float = 1.8

var current_nutrients: float
var _consumers: Array[ArmSegment] = []

func _ready() -> void:
	current_nutrients = total_nutrients
	_update_visual_scale()

func _update_visual_scale() -> void:
	var ref := maxf(1.0, nutrients_scale_reference)
	var ratio := maxf(0.0, total_nutrients / ref)

	# sqrt(ratio) (oder allgemein ratio^scale_power), damit 4x nutrients nicht 4x Radius wird
	var s := pow(ratio, scale_power)
	s = clampf(s, min_visual_scale, max_visual_scale)

	scale = Vector2.ONE * s

func _process(delta: float) -> void:
	if current_nutrients <= 0.0:
		for c in _consumers:
			if is_instance_valid(c):
				c.stop_eating()
		_consumers.clear()
		queue_free()
		get_tree().call_group("Statistik", "add_count_of_depleted_foodpiles")
		return

	_consumers = _consumers.filter(func(c): return is_instance_valid(c))

	var drain_per_consumer := absorption_rate * delta

	for i in range(_consumers.size() - 1, -1, -1):
		var consumer := _consumers[i]
		if !is_instance_valid(consumer):
			_consumers.remove_at(i)
			continue

		if current_nutrients <= 0.0:
			break

		var drained := minf(drain_per_consumer, current_nutrients)
		current_nutrients -= drained
		consumer.eat(drained)

func _on_area_entered(area: Area2D) -> void:
	var consumer := area.get_parent() as ArmSegment
	if consumer == null:
		return

	if !_consumers.has(consumer):
		_consumers.append(consumer)
		consumer.start_eating()

func _on_area_exited(area: Area2D) -> void:
	var consumer := area.get_parent() as ArmSegment
	if consumer == null:
		return

	_consumers.erase(consumer)
	consumer.stop_eating()
