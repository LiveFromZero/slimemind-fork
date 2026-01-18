class_name ArmSegment
extends Node2D

var predecessor: ArmSegment
var children: Array [ArmSegment] = []
@export var max_life_points = 500
var life_points = max_life_points
@export var depth: int
var base_damage = 0.2
var damage_per_second
var is_eating: bool = false
const FOOD_TO_LIFE := 0.08 # Balancing-Wert
const UP_SHARE := 0.6
const SIB_SHARE := 0.2 # Anteil vom eigenen Life-Gewinn an Geschwister

signal color_changed(new_color: Color)
signal segment_died(arm_that_died: ArmSegment)
signal eating(arm_that_eats: ArmSegment) # wird: started eating
signal stopped_eating(arm_that_stops: ArmSegment)


func _process(delta: float):
	life_points -= damage_per_second * delta
	if life_points < 350:
		_set_color(Color("yellow"))
	if life_points < 250:
		_set_color(Color("olive-drab"))
	if life_points < 150:
		_set_color(Color("olive"))
	if life_points <= 0:
		_set_color(Color("brown"))
		_die()

func _ready() -> void:
	if depth == 0:  # Falls irgendwie vergessen wurde
		depth = 1
	damage_per_second = base_damage * depth

func _set_color(new_color: Color) -> void:
	color_changed.emit(new_color)
	

func _die() -> void:
	# Verhindere Mehrfach-Auslösung
	set_process(false)
	segment_died.emit(self)
	_set_color(Color("brown"))

# Food

func eat(food_amount: float) -> void:
	var gained := food_amount * FOOD_TO_LIFE

	# eigenes Segment
	life_points = min(max_life_points, life_points + gained)

	# nach oben (Strang)
	if predecessor != null:
		predecessor.eat(food_amount * UP_SHARE)

	# Geschwister-Ast mitversorgen
	_feed_split_partner(gained * SIB_SHARE)

func start_eating() -> void:
	if is_eating:
		return
	is_eating = true
	eating.emit(self) # EINMAL beim Start

func stop_eating() -> void:
	if !is_eating:
		return
	is_eating = false
	stopped_eating.emit(self)

func feed_tick(amount: float) -> void:
	# Minimal: "arm gets energy and doesn't die"
	# You said "complete arm", so we refresh the whole connected subtree.
	_refresh_life_whole_arm()

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

	for child in predecessor.get_children():
		var sibling := child as ArmSegment
		if sibling == null:
			continue
		if sibling == self:
			continue

		# Split-Partner + dessen Subtree versorgen
		sibling._feed_descendants(life_amount, 2)

func _feed_descendants(life_amount: float, depth: int) -> void:
	if life_amount <= 0.0 or depth <= 0:
		return
	# dieses Segment selbst
	life_points = min(max_life_points, life_points + life_amount)

	for child in get_children():
		var seg := child as ArmSegment
		if seg == null:
			continue

		# pro Ebene weniger Energie
		seg._feed_descendants(life_amount * 0.6, depth - 1)
