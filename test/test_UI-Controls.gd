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

func test_StartButtonStartsSim():
	# initiate
	var segments = runnerWorld.find_child("ArmRoot")
	var segmentsArray
	var isPausedBefore : bool
	var isPausedAfter : bool
	
	# run
	isPausedBefore = segments.get_tree().paused
	StartButton.pressed.emit()
	isPausedAfter = segments.get_tree().paused
	await get_tree().create_timer(1).timeout
	segmentsArray = segments.get_children()
	#compare
	assert_bool(isPausedBefore).is_equal(true)
	assert_bool(isPausedAfter).is_equal(false)
	assert_int(segmentsArray.size()).is_greater(StartarmeSlider.value)


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
	[FuttermengeSlider.min_value],
	[FuttermengeSlider.max_value]
]):
	#initiate
	var foodRoot : Node2D = runnerWorld.find_child("FoodManager")
	var foodSpawned : Array
	
	# run
	FuttermengeSlider.value_changed.emit(foodAmount)
	SpawnFoodButton.pressed.emit()
	
	foodSpawned = foodRoot.get_children()
	# compare
	assert_array(foodSpawned).is_not_empty()
	for food:FoodSource in foodSpawned:
		assert_float(food.total_nutrients).is_between(FuttermengeSlider.min_value, FuttermengeSlider.max_value)

func test_UIweatherSlider(sliderValueSun:float, sliderValueTemp:float, sliderValueHydro:float, test_parameters:=[
	[SonnenlichtSlider.value, TemperaturSlider.value, LuftfeuchtigkeitSlider.value],
	[SonnenlichtSlider.min_value, TemperaturSlider.min_value, LuftfeuchtigkeitSlider.min_value],
	[SonnenlichtSlider.max_value, TemperaturSlider.max_value, LuftfeuchtigkeitSlider.max_value]
]):
	SonnenlichtSlider.value_changed.emit(sliderValueSun)
	TemperaturSlider.value_changed.emit(sliderValueTemp)
	LuftfeuchtigkeitSlider.value_changed.emit(sliderValueHydro)
	
	StartButton.pressed.emit()
	var segments = runnerWorld.find_child("ArmRoot")
	await get_tree().create_timer(1).timeout
	var segmentsArray = segments.get_children()
	assert_int(segmentsArray.size()).is_greater(StartarmeSlider.value)
