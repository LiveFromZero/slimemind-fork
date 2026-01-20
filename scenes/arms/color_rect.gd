extends ColorRect

@export var fade_duration := 6.0

var _tween: Tween
var _target_color: Color

func _ready() -> void:
	_target_color = color

func _on_arm_segment_color_changed(new_color: Color) -> void:
	if new_color == _target_color:
		return
	_target_color = new_color

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "color", new_color, fade_duration)
