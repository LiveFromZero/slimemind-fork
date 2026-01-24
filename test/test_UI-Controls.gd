extends GdUnitTestSuite

var runnerWorld: GdUnitSceneRunner
var runnerArmSegment: GdUnitSceneRunner
var FutteranzahlSlider : HSlider

func before_test() -> void:
	runnerWorld = scene_runner("res://test/test_main.tscn")
	FutteranzahlSlider = runnerWorld.find_child("FutteranzahlSlider")

func test_AnzahlFutterquellen(foodAmount:float, test_parameters := [
	[FutteranzahlSlider.min_value],
	[FutteranzahlSlider.max_value]
]):
	# initiate
	var slider : HSlider = runnerWorld.find_child("FutteranzahlSlider")
	var spawnFoodButton : Button = runnerWorld.find_child("FoodSpawnButton")
	var foodRoot : Node2D = runnerWorld.find_child("FoodManager")
	var foodSpawned : float
	
	# run
	slider.value_changed.emit(foodAmount)
	spawnFoodButton.pressed.emit()
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
