extends Node2D
class_name  WorldStatistic

signal sendDataToSummary(_time:String, _foodEaten:int, _foodAmountEaten: float, _longestArm:int, _countDeadSegments)

var time : String
var foodEaten : int
var foodAmountEaten : float
var longestArm : int
var countDeadSegments : int
var startTimeSecond
var endTimeSecond

func _ready() -> void:
	add_to_group("Statistik")
	set_defaults()

func set_defaults() -> void:
	time = "0"
	foodEaten = 0
	foodAmountEaten = 0.0
	longestArm = 0
	countDeadSegments = 0

func _on_ui_statistik_pressed() -> void:
	endTimeSecond = Time.get_ticks_msec()
	calculateTime()
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, longestArm, countDeadSegments)

func add_count_of_dead_segment() -> void:
	countDeadSegments = countDeadSegments +1

func startTimer() -> void:
	startTimeSecond = Time.get_ticks_msec()

func calculateTime() -> void:
	var total_seconds : float = endTimeSecond - startTimeSecond
	if total_seconds < 0:
		total_seconds = 0

	var minutes := int(total_seconds) / 60
	var seconds := int(total_seconds) % 60

	time = "%02d:%02d" % [minutes, seconds]
