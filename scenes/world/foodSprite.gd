extends Sprite2D
class_name FoodSourceSprite

@export var total_nutrients: float = 0.0
@export var current_nutrients: float = 0.0

@onready var rect: Sprite2D = $Sprite2D

func set_visual_size_px(size_px: float) -> void:
	# ColorRect.size ist in Pixeln (UI-Logik), aber in Godot 4 geht das sauber.
	# Wir zentrieren ihn um seine Mitte.
	rect.size = Vector2(size_px, size_px)
	rect.position = -rect.size * 0.5
