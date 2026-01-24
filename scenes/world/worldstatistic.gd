extends Node2D
class_name  WorldStatistic

signal sendDataToSummary(_time:String, _foodEaten:int, _foodAmountEaten: int, _countDeadSegments:int)
signal simulation_over_signal

var _simluation_over = false
var _all_non_feeding_segments_are_dead = false
var _all_feeding_segments_are_dead = false

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
	if _simluation_over == false:
		endTimeSecond = Time.get_ticks_msec()
		calculateTime()
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, countDeadSegments)
		

func simulation_over() -> void:
	_simluation_over = true
	endTimeSecond = Time.get_ticks_msec()
	calculateTime()
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, countDeadSegments)
	await get_tree().create_timer(15).timeout
	simulation_over_signal.emit()

func all_non_feeding_segments_are_dead() -> void:
	_all_non_feeding_segments_are_dead = true
	all_feeding_segments_are_dead()
	isSimulationOver()

func all_feeding_segments_are_dead() -> void:
	var allFoodPiles = $"../../Food/FoodManager".get_children(true)
	print(allFoodPiles)
	if allFoodPiles.is_empty():
		_all_feeding_segments_are_dead = true
	else:
		for onepile : FoodSource in allFoodPiles:
			if onepile._consumers.size() == 0:
				_all_feeding_segments_are_dead = true
			else: 
				_all_feeding_segments_are_dead = false
				_all_non_feeding_segments_are_dead = false
				break

func isSimulationOver() -> void:
	if _all_feeding_segments_are_dead && _all_non_feeding_segments_are_dead:
		simulation_over()

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
