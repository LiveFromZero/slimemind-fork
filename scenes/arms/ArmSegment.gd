class_name ArmSegment
extends Node2D

@onready var visual: CanvasItem = $ColorRect2

@export var max_life_points: float = 10.0
@export var depth: int = 1
@export var color_update_interval: float = 0.15

var predecessor: ArmSegment
var children: Array[ArmSegment] = []

var life_points: float
var is_eating := false

signal color_changed(new_color: Color)
signal segment_died(segment: ArmSegment)
signal eating(segment: ArmSegment)
signal stopped_eating(segment: ArmSegment)

const BASE_DAMAGE := 0.2
const FOOD_TO_LIFE := 1.0
const UP_SHARE := 1.0
const SIB_SHARE := 1.0
const EATING_COLOR := Color(1.0, 0.85, 0.3)

var _damage_per_second: float
var _health_color: Color = Color.GREEN
var _color_timer: Timer
var _is_dead := false


func _ready() -> void:
	depth = max(depth, 1)
	life_points = max_life_points
	_damage_per_second = BASE_DAMAGE * depth

	_color_timer = Timer.new()
	_color_timer.one_shot = false
	_color_timer.wait_time = max(0.03, color_update_interval)
	_color_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(_color_timer)

	_color_timer.timeout.connect(_update_visual)
	_color_timer.start()

	_update_visual(true)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	life_points -= _damage_per_second * delta
	if life_points <= 0.0:
		life_points = 0.0
		_die()


func eat(food_amount: float) -> void:
	if _is_dead:
		return

	# Minimaler "Essen"-Effekt: Segment wird voll, Kettenverteilung macht den Rest.
	life_points = max_life_points
	_update_visual(true)

	if predecessor != null and UP_SHARE > 0.0:
		predecessor.eat(food_amount * UP_SHARE)

	if predecessor != null and SIB_SHARE > 0.0:
		_feed_siblings(food_amount * FOOD_TO_LIFE * SIB_SHARE)


func start_eating() -> void:
	if _is_dead or is_eating:
		return
	is_eating = true
	eating.emit(self)
	_update_visual(true)


func stop_eating() -> void:
	if _is_dead or not is_eating:
		return
	is_eating = false
	stopped_eating.emit(self)
	_update_visual(true)


func feed_tick() -> void:
	if _is_dead:
		return
	_refresh_whole_arm_to_full()
	_update_visual(true)


func _update_visual(force: bool = false) -> void:
	if _is_dead or max_life_points <= 0.0:
		return

	var ratio := life_points / max_life_points
	var target := _color_for_ratio(ratio)

	if force or target != _health_color:
		_health_color = target

	# Wenn das Segment gerade frisst, wird die Health-Farbe warm getönt.
	# So bleibt die Info "gesund/krank" erhalten, plus "frisst gerade".
	var final_color := _health_color
	if is_eating:
		final_color = _health_color.lerp(EATING_COLOR, 0.35)

	visual.modulate = final_color
	color_changed.emit(final_color)


func _color_for_ratio(r: float) -> Color:
	if r <= 0.3:
		return Color.SANDY_BROWN
	if r <= 0.5:
		return Color.YELLOW
	if r <= 0.75:
		return Color.YELLOW_GREEN
	return Color.GREEN


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	set_physics_process(false)
	if is_instance_valid(_color_timer):
		_color_timer.stop()

	visual.modulate = Color.WEB_MAROON
	color_changed.emit(Color.WEB_MAROON)
	segment_died.emit(self)

	# Tween auf Node2D.modulate (nicht auf visual), damit du das Segment als Ganzes ausblendest.
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 12.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)


func _refresh_whole_arm_to_full() -> void:
	# Läuft zum Root hoch (predecessor-Kette) und füllt dann den gesamten Subtree.
	# Das ist bewusst O(n) über den Arm, aber nur bei "Feed-Events", nicht pro Frame.
	var root := self
	while root.predecessor != null:
		root = root.predecessor
	_fill_subtree(root)


func _fill_subtree(seg: ArmSegment) -> void:
	seg.life_points = seg.max_life_points
	for c in seg.children:
		if c != null:
			_fill_subtree(c)


func _feed_siblings(life_amount: float) -> void:
	if life_amount <= 0.0 or predecessor == null:
		return

	# Wir verwenden die eigene children-Liste als "Arm-Graph" (nicht Node-Children),
	# damit die Logik stabil bleibt, egal wie die Szene-Hierarchie aussieht.
	for sibling in predecessor.children:
		if sibling == null or sibling == self:
			continue
		sibling._feed_descendants(life_amount, 2)


func _feed_descendants(life_amount: float, depth_left: int) -> void:
	if life_amount <= 0.0 or depth_left <= 0 or _is_dead:
		return

	life_points = min(max_life_points, life_points + life_amount)

	for c in children:
		if c != null:
			c._feed_descendants(life_amount * 0.6, depth_left - 1)
