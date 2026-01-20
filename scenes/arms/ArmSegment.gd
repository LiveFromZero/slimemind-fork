class_name ArmSegment
extends Node2D

@onready var visual: CanvasItem = $ColorRect2 # ggf. anpassen (Line2D, ColorRect, etc.)

var predecessor: ArmSegment
var children: Array[ArmSegment] = []

@export var max_life_points: float
var life_points: float
var depth: int
var base_damage := 0.2
var damage_per_second: float

var is_eating: bool = false
var _base_color: Color
var _current_target_color: Color = Color.GREEN

# Wie oft die Farbe neu berechnet wird (kleiner = reaktiver, größer = billiger)
@export var color_update_interval: float = 0.15

const FOOD_TO_LIFE := 1.0 # Balancing-Wert
const UP_SHARE := 1.0
const SIB_SHARE := 1.0 # Anteil vom eigenen Life-Gewinn an Geschwister
const EATING_COLOR := Color(1.0, 0.85, 0.3) # warm/gelb
const FED_COLOR := Color(0.4, 1.0, 0.6)     # grünlich

signal color_changed(new_color: Color)
signal segment_died(arm_that_died: ArmSegment)
signal eating(arm_that_eats: ArmSegment) # started eating
signal stopped_eating(arm_that_stops: ArmSegment)

var _color_timer: Timer
var _is_dead := false

func _ready() -> void:
	if depth == 0: # Falls irgendwie vergessen wurde
		depth = 1

	damage_per_second = base_damage * depth
	_base_color = visual.modulate
	life_points = max_life_points

	# Farb-Updates auslagern: Timer statt jedes Physik-Frame rechnen
	_color_timer = Timer.new()
	_color_timer.name = "ColorTimer"
	_color_timer.one_shot = false
	_color_timer.wait_time = max(0.03, color_update_interval)
	_color_timer.ignore_time_scale = false # wichtig: Engine.time_scale soll wirken
	_color_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(_color_timer)

	_color_timer.timeout.connect(_update_color)
	_color_timer.start()

	# Initiale Farbe einmal setzen
	_update_color(true)

func _physics_process(delta: float) -> void:
	# Minimaler Hot-Path: nur Leben runter, clamp, ggf. sterben.
	if _is_dead:
		return

	life_points -= damage_per_second * delta
	if life_points <= 0.0:
		life_points = 0.0
		_die()

func _update_color(force: bool = false) -> void:
	# Farbe nur getaktet (oder forced), nicht pro Frame.
	if _is_dead:
		return

	if max_life_points <= 0.0:
		return

	var life_ratio: float = life_points / max_life_points

	var target: Color
	if life_ratio <= 0.3:
		target = Color.SANDY_BROWN
	elif life_ratio <= 0.5:
		target = Color.YELLOW
	elif life_ratio <= 0.75:
		target = Color.YELLOW_GREEN
	else:
		target = Color.GREEN

	if force or target != _current_target_color:
		_current_target_color = target
		_set_color(target)

func _set_color(new_color: Color) -> void:
	color_changed.emit(new_color)

func _die() -> void:
	# Verhindere Mehrfach-Auslösung
	if _is_dead:
		return
	_is_dead = true

	set_physics_process(false)
	if is_instance_valid(_color_timer):
		_color_timer.stop()

	segment_died.emit(self)
	_set_color(Color.WEB_MAROON)

	var tween := create_tween()
	tween.tween_property(
		self,
		"modulate:a", # nur Alpha ändern
		0.1,          # Ziel: komplett transparent
		12.0          # Dauer in Sekunden
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.finished.connect(queue_free)

# Food

func eat(food_amount: float) -> void:
	var gained := food_amount * FOOD_TO_LIFE

	# eigenes Segment
	life_points = max_life_points

	# Farbe sofort aktualisieren (damit es nicht erst beim Timer-Tick sichtbar wird)
	_update_color(true)

	# nach oben (Strang)
	if predecessor != null:
		predecessor.eat(food_amount * UP_SHARE)

	# Geschwister-Ast mitversorgen
	_feed_split_partner(gained * SIB_SHARE)

func start_eating() -> void:
	if is_eating:
		return
	is_eating = true
	visual.modulate = _base_color.lerp(EATING_COLOR, 0.35)
	eating.emit(self)

	# Optional: Farbe sofort neu ausgeben
	_update_color(true)

func stop_eating() -> void:
	if !is_eating:
		return
	is_eating = false
	visual.modulate = _base_color
	stopped_eating.emit(self)

	_update_color(true)

func feed_tick() -> void:
	# Minimal: "arm gets energy and doesn't die"
	# You said "complete arm", so we refresh the whole connected subtree.
	_refresh_life_whole_arm()
	_update_color(true)

func _refresh_life_whole_arm() -> void:
	var root := self
	while root.predecessor != null:
		root = root.predecessor

	# refresh root + all children
	_refresh_subtree(root)

func _refresh_subtree(seg: ArmSegment) -> void:
	seg.life_points = seg.max_life_points
	for c in seg.children:
		_refresh_subtree(c)

func _add_life(amount: float) -> void:
	if amount <= 0.0:
		return
	life_points = min(max_life_points, life_points + amount)

func _feed_split_partner(life_amount: float) -> void:
	if life_amount <= 0.0:
		return
	if predecessor == null:
		return

	# NICHT predecessor.get_children() (Node-Children) + casts: nutz deine echte children-Liste
	for sibling in predecessor.children:
		if sibling == null:
			continue
		if sibling == self:
			continue
		sibling._feed_descendants(life_amount, 2)

func _feed_descendants(life_amount: float, depth_: int) -> void:
	if life_amount <= 0.0 or depth_ <= 0:
		return

	_add_life(life_amount)

	for seg in children:
		if seg == null:
			continue
		# pro Ebene weniger Energie
		seg._feed_descendants(life_amount * 0.6, depth_ - 1)
