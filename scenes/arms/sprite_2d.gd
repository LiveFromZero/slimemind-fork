extends Sprite2D

@export var fade_duration := 3.0

var _target_color: Color

func _ready() -> void:
	_target_color = modulate

func _process(delta: float) -> void:
	# Exponentielles Nachziehen: stabil, weich, keine Tween-Orgie.
	# fade_duration ~ Zeitkonstante: größer = träger.
	var d := maxf(0.001, fade_duration)
	var k := 1.0 - exp(-delta / d)
	modulate = modulate.lerp(_target_color, k)

func _on_arm_segment_color_changed(new_color: Color) -> void:
	_target_color = new_color
