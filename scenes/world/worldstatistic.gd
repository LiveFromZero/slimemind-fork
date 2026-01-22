extends Node2D
class_name  WorldStatistic

signal sendDataToSummary(_time:float, _foodEaten:int, _foodAmountEaten: float, _longestArm:int, _countDeadSegments)

var time : float
var foodEaten : int
var foodAmountEaten : float
var longestArm : int
var countDeadSegments : int

func _ready() -> void:
	add_to_group("Statistik")
	set_defaults()

func set_defaults() -> void:
	time = 0
	foodEaten = 0
	foodAmountEaten = 0
	longestArm = 0
	countDeadSegments = 0

func add_count_of_dead_segment() -> void:
	countDeadSegments = countDeadSegments +1

func _on_ui_statistik_pressed() -> void:
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, longestArm, countDeadSegments)
