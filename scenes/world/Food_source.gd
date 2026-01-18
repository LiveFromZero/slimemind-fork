extends Area2D
class_name FoodSource

@export var total_nutrients: float = 10_000.0
@export var absorption_rate: float = 100.0 # nutrients per second per consumer

var current_nutrients: float
var _consumers: Array[ArmSegment] = []

func _ready() -> void:
	current_nutrients = total_nutrients

func _process(delta: float) -> void:
	if current_nutrients <= 0.0:
		# aktiv alle beenden
		for c in _consumers:
			if is_instance_valid(c):
				c.stop_eating()
		_consumers.clear()
		queue_free()
		return
	_consumers = _consumers.filter(func(c): return is_instance_valid(c))



	# Drain per consumer, per second.
	var drain_per_consumer := absorption_rate * delta

	# Iterate backwards so we can remove invalid consumers safely.
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
