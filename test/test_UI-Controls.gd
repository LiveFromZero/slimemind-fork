extends GdUnitTestSuite

var runnerWorld: GdUnitSceneRunner
var StartButton : Button
var FutteranzahlSlider : HSlider
var FuttermengeSlider : HSlider
var FeldgroesseSlider : HSlider
var SpawnFoodButton : Button
var LebenspunkteSlider : HSlider
var SonnenlichtSlider : HSlider
var TemperaturSlider : HSlider
var LuftfeuchtigkeitSlider : HSlider
var StartarmeSlider : HSlider
var SimulationSpeedSlider : HSlider
var ResetButton : Button
var StatButton : Button

func before_test() -> void:
	runnerWorld = scene_runner("res://test/test_main.tscn")
	StartButton = runnerWorld.find_child("Button")
	FutteranzahlSlider = runnerWorld.find_child("FutteranzahlSlider")
	FuttermengeSlider = runnerWorld.find_child("FuttermengeSlider")
	FeldgroesseSlider = runnerWorld.find_child("FeldgrößeSlider")
	SpawnFoodButton = runnerWorld.find_child("FoodSpawnButton")
	LebenspunkteSlider = runnerWorld.find_child("LebenspunkteSlider")
	SonnenlichtSlider = runnerWorld.find_child("SonnenlichtSlider")
	TemperaturSlider = runnerWorld.find_child("TemperaturSlider")
	LuftfeuchtigkeitSlider = runnerWorld.find_child("LuftfeuchtigkeitSlider")
	StartarmeSlider = runnerWorld.find_child("StartarmeSlider")
	SimulationSpeedSlider = runnerWorld.find_child("SimulationSpeedSlider")
	ResetButton = runnerWorld.find_child("ResetButton")
	StatButton = runnerWorld.find_child("Statistik")

func test_UIFutterquellen(foodCount:float, fieldSize:float, test_parameters := [
	[FutteranzahlSlider.min_value, FeldgroesseSlider.min_value],
	[FutteranzahlSlider.max_value, FeldgroesseSlider.min_value],
	[FutteranzahlSlider.min_value, FeldgroesseSlider.max_value],
	[FutteranzahlSlider.max_value, FeldgroesseSlider.max_value]
]):
	# initiate
	var foodRoot : Node2D = runnerWorld.find_child("FoodManager")
	var foodSpawned : float
	
	# run
	FutteranzahlSlider.value_changed.emit(foodCount)
	FeldgroesseSlider.value_changed.emit(fieldSize)
	SpawnFoodButton.pressed.emit()
	foodSpawned = foodRoot.get_child_count(true)
	
	#compare
	assert_float(foodSpawned).is_equal(foodCount)

func test_UIFuttergroesse(foodAmount:float, test_parameters := [
	[FuttermengeSlider.min_value]
]):
	#initiate
	var foodRoot : Node2D = runnerWorld.find_child("FoodManager")
	var foodSpawned : Array
	
	# run
	FuttermengeSlider.value_changed.emit(foodAmount)
	SpawnFoodButton.pressed.emit()
	
	foodSpawned = foodRoot.get_children()
	# compare
	for food:FoodSource in foodSpawned:
		assert_float(food.total_nutrients).is_between(FuttermengeSlider.min_value, FuttermengeSlider.max_value)

func test_StartButtonStartsSim():
	# initiate
	var segments = runnerWorld.find_child("ArmRoot")
	var segmentsArray = segments.get_children()
	
	# run
	StartButton.pressed.emit()
	
	#compare
	assert_array(segmentsArray).is_not_empty()
