extends Node2D
class_name  WorldStatistic

signal sendDataToSummary(_time:String, _foodEaten:int, _foodAmountEaten: int, _countDeadSegments:int)

var time : String
var foodEaten : int
var foodAmountEaten : int
var countDeadSegments : int
var startTimeSecond : int
var endTimeSecond : int

func _ready() -> void:
	add_to_group("Statistik")
	set_defaults()

func set_defaults() -> void:
	time = "0"
	foodEaten = 0
	startTimeSecond = 0
	foodEaten = 0
	foodAmountEaten = 0
	countDeadSegments = 0

func _on_ui_statistik_pressed() -> void:
	endTimeSecond = Time.get_ticks_msec()
	calculateTime()
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, countDeadSegments)

func add_count_of_dead_segment() -> void:
	countDeadSegments = countDeadSegments +1

func add_count_of_depleted_foodpiles() -> void:
	foodEaten = foodEaten + 1

func add_count_of_fooadmount(amount:int) -> void:
	foodAmountEaten = foodAmountEaten + amount

func startTimer() -> void:
	startTimeSecond = Time.get_ticks_msec()

func calculateTime() -> void:
	if startTimeSecond == 0:
		time= "00:00"
		return
	
	var total_ms: int = max(0, endTimeSecond - startTimeSecond)

	var total_seconds: int = total_ms / 1000
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60

	time = "%02d:%02d" % [minutes, seconds]
