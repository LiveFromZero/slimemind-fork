extends Camera2D

# Geschwindigkeit für Bewegung
@export var pan_speed: float = 600.0
# Zoom-Geschwindigkeit
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

# Randbereich für Edge-Scrolling (in Pixeln)
@export var edge_size: int = 20

var middle_mouse_down := false
var drag_last_pos := Vector2.ZERO

func _input(event: InputEvent) -> void:
	_handle_zoom(event)
	_handle_middle_mouse_drag(event)

func _handle_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom -= Vector2(zoom_step, zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom += Vector2(zoom_step, zoom_step)

		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)


# --- Neue Methode für Middle Mouse Drag ---
func _handle_middle_mouse_drag(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				middle_mouse_down = true
				drag_last_pos = event.position
			else:
				middle_mouse_down = false

	if event is InputEventMouseMotion and middle_mouse_down:
		var delta_pos = drag_last_pos - event.position
		position += delta_pos
		drag_last_pos = event.position
