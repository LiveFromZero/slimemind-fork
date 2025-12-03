extends Camera2D

# -----------------------------
# Einstellungen (kannst du ändern)
# -----------------------------
@export var edge_size: int = 25
@export var scroll_speed: float = 800.0
@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.1
@export var zoom_min: float = 0.4
@export var zoom_max: float = 3.0

# -----------------------------
# Private Variablen
# -----------------------------
var dragging := false
var last_mouse_pos := Vector2.ZERO

func _ready():
	# Damit die Kamera tatsächlich vom Script steuerbar ist
	zoom = Vector2.ONE


func _process(delta: float):
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse = get_viewport().get_mouse_position()

	# ---------------------------------
	# EDGE SCROLLING (Maus am Rand)
	# ---------------------------------
	if mouse.x < edge_size:
		global_position.x -= scroll_speed * delta
	elif mouse.x > viewport_size.x - edge_size:
		global_position.x += scroll_speed * delta

	if mouse.y < edge_size:
		global_position.y -= scroll_speed * delta
	elif mouse.y > viewport_size.y - edge_size:
		global_position.y += scroll_speed * delta
	
	# Begrenzung
	global_position.x = clamp(global_position.x, limit_left, limit_right)
	global_position.y = clamp(global_position.y, limit_top, limit_bottom)

func _unhandled_input(event):
	# ---------------------------------
	# MIDDLE MOUSE DRAGGING
	# ---------------------------------
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			if dragging:
				last_mouse_pos = event.position

		# ---------------------------------
		# ZOOM
		# ---------------------------------
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = (zoom - Vector2.ONE * zoom_step).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = (zoom + Vector2.ONE * zoom_step).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))

	# Drag-Bewegung
	if event is InputEventMouseMotion and dragging:
		var delta = event.relative * drag_speed * -1
		global_position += delta
