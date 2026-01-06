class_name ArmSegment
extends Node2D

var predecessor: ArmSegment
var children: Array [ArmSegment] = []
var life_points = 500
@export var depth: int
var base_damage = 0.2
var damage_per_second

signal color_changed(new_color: Color)
signal segment_died(arm_that_died: ArmSegment)

func _process(delta: float):
	life_points -= damage_per_second * delta
	if life_points < 350:
		set_color("yellow")
	if life_points < 250:
		set_color("olive-drab")
	if life_points < 150:
		set_color("olive")
	if life_points <= 0:
		set_color("brown")
		die()

func _ready() -> void:
	if depth == 0:  # Falls irgendwie vergessen wurde
		depth = 1
	damage_per_second = base_damage * depth

func set_color(new_color: Color) -> void:
	color_changed.emit(new_color)

func die() -> void:
	# Verhindere Mehrfach-Auslösung
	set_process(false)
	segment_died.emit(self)
	queue_free()
