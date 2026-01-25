extends Node2D

@export var fade_seconds: float = 1.5

# Temperatur-Grenzen (tunen nach Geschmack)
@export var winter_max: float = 0.0
@export var spring_max: float = 20.0
@export var summer_max: float = 40.0
# > summer_max => Herbst

# Sonne Tag/Nacht
@export var night_max: float = 40.0
@export var day_min: float = 60.0

# PNG-Pfade (8 Stück)
@export var tex_fruehling_tag: Texture2D
@export var tex_fruehling_nacht: Texture2D
@export var tex_sommer_tag: Texture2D
@export var tex_sommer_nacht: Texture2D
@export var tex_herbst_tag: Texture2D
@export var tex_herbst_nacht: Texture2D
@export var tex_winter_tag: Texture2D
@export var tex_winter_nacht: Texture2D

var _temp: float = 22.0
var _sun: float = 15.0
var _humidity: float = 50.0

@onready var _a: Sprite2D = $BgA
@onready var _b: Sprite2D = $BgB

var _active: Sprite2D
var _inactive: Sprite2D
var _current_key: StringName = &""
var _tween: Tween

func _ready() -> void:
	_active = _a
	_inactive = _b
	_a.modulate.a = 1.0
	_b.modulate.a = 0.0
	_apply_background(true)

func setTemp(temp: float) -> void:
	_temp = temp
	_apply_background(false)

func setSun(sun: float) -> void:
	_sun = sun
	_apply_background(false)

func setHumidity(humidity: float) -> void:
	_humidity = humidity
	# Optional: später Fog/Rain hier steuern.

func _apply_background(immediate: bool) -> void:
	var key := _desired_key()
	if key == _current_key:
		return

	var tex := _texture_for_key(key)
	if tex == null:
		push_warning("Missing texture for key: %s" % String(key))
		return

	_current_key = key

	if immediate:
		_active.texture = tex
		_active.modulate.a = 1.0
		_inactive.modulate.a = 0.0
		return

	_start_crossfade(tex)

func _start_crossfade(tex: Texture2D) -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_inactive.texture = tex
	_inactive.modulate.a = 0.0

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_inactive, "modulate:a", 1.0, fade_seconds)
	_tween.tween_property(_active, "modulate:a", 0.0, fade_seconds)
	_tween.set_parallel(false)
	_tween.tween_callback(_swap_layers)

func _swap_layers() -> void:
	var tmp := _active
	_active = _inactive
	_inactive = tmp
	_inactive.modulate.a = 0.0

func _desired_key() -> StringName:
	var season := _season_from_temp(_temp)
	var tod := _daynight_from_sun(_sun)
	return StringName("%s_%s" % [season, tod]) # z.B. "Winter_Tag"

func _season_from_temp(t: float) -> String:
	if t <= winter_max:
		return "Winter"
	if t <= spring_max:
		return "Fruehling"
	if t <= summer_max:
		return "Sommer"
	return "Herbst"

func _daynight_from_sun(s: float) -> String:
	if s <= night_max:
		return "Nacht"
	if s >= day_min:
		return "Tag"
	var k := inverse_lerp(night_max, day_min, s)
	return "Nacht" if k < 0.5 else "Tag"

func _texture_for_key(key: StringName) -> Texture2D:
	match String(key):
		"Fruehling_Tag": return tex_fruehling_tag
		"Fruehling_Nacht": return tex_fruehling_nacht
		"Sommer_Tag": return tex_sommer_tag
		"Sommer_Nacht": return tex_sommer_nacht
		"Herbst_Tag": return tex_herbst_tag
		"Herbst_Nacht": return tex_herbst_nacht
		"Winter_Tag": return tex_winter_tag
		"Winter_Nacht": return tex_winter_nacht
		_: return null
