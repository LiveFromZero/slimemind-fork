extends Node2D
class_name  WorldStatistic

signal sendDataToSummary(_time:float, _foodEaten:int, _foodAmountEaten: float, _longestArm:int)

var time : float
var foodEaten : int
var foodAmountEaten : float
var longestArm : int

func _ready() -> void:
	set_defaults()

func set_defaults() -> void:
	time = 0
	foodEaten = 0
	foodAmountEaten = 0
	longestArm = 0

func calculateTime(sekunden:float) -> void:
	var minuten = sekunden/60
	time = minuten
	sendDataToSummary.emit(time, foodEaten, foodAmountEaten, longestArm)

func calculateFoodEaten(amount:int) -> void:
	foodEaten = amount

func calculateLongestArm() -> void:
	pass
