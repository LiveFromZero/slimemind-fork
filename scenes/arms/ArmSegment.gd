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

# ArmSegment.gd

func eat(food_amount: float) -> void:
	life_points = max_life_points
	if predecessor != null:
		predecessor.eat(food_amount)


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
