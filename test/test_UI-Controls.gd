extends GdUnitTestSuite

var runnerWorld: GdUnitSceneRunner
var runnerArmSegment: GdUnitSceneRunner
var FutteranzahlSlider : HSlider
var FuttermengeSlider : HSlider
var FeldgroesseSlider : HSlider
var SpawnFoodButton : Button
var LebenspunkteSlider : HSlider

func before_test() -> void:
	runnerWorld = scene_runner("res://test/test_main.tscn")
	FutteranzahlSlider = runnerWorld.find_child("FutteranzahlSlider")
	FuttermengeSlider = runnerWorld.find_child("FuttermengeSlider")
	FeldgroesseSlider = runnerWorld.find_child("FeldgrößeSlider")
	SpawnFoodButton = runnerWorld.find_child("FoodSpawnButton")
	LebenspunkteSlider = runnerWorld.find_child("LebenspunkteSlider")

func test_UIFutterquellen(foodAmount:float, fieldSize:float,  test_parameters := [
	[FutteranzahlSlider.min_value, FeldgroesseSlider.min_value],
	[FutteranzahlSlider.max_value, FeldgroesseSlider.min_value],
	[FutteranzahlSlider.min_value, FeldgroesseSlider.max_value],
	[FutteranzahlSlider.max_value, FeldgroesseSlider.max_value]
]):
	# initiate
	var foodRoot : Node2D = runnerWorld.find_child("FoodManager")
	var foodSpawned : float
	
	# run
	FutteranzahlSlider.value_changed.emit(foodAmount)
	FeldgroesseSlider.value_changed.emit(fieldSize)
	SpawnFoodButton.pressed.emit()
	foodSpawned = foodRoot.get_child_count(true)
	
	#compare
	assert_float(foodSpawned).is_equal(foodAmount)


func test_StartButtonStartsSim():
	# initiate
	var startButton = runnerWorld.find_child("Button")
	var segments = runnerWorld.find_child("ArmRoot")
	var segmentsArray = segments.get_children()
	
	# run
	startButton.pressed.emit()
	
	#compare
	assert_array(segmentsArray).is_not_empty()
