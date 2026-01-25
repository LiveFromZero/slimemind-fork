extends GdUnitTestSuite

var _armScene : GdUnitSceneRunner
var _armRoot : Node2D
var _worldController : WorldController
var ArmSegmentScene : PackedScene

func before() -> void:
	_armScene = scene_runner("res://test/test_ArmSegment.tscn")
	_armRoot = _armScene.find_child("ArmRoot")
	_worldController = _armScene.find_child("WorldController") as WorldController
	ArmSegmentScene = preload("res://scenes/arms/ArmSegment.tscn")

func test_armSpawn():
	#initiate
	var seg = ArmSegment.new()
	_armRoot.add_child(seg)
	
	#run
	_worldController.arm_segments.append(seg)
	_worldController.grow_arm.emit(seg, 50)
	
	#compare
	assert_int(_armRoot.get_child_count()).is_greater(1)
	

func test_armLiveAndDie():
	#initiate
	get_tree().paused = false
	var seg : ArmSegment = ArmSegmentScene.instantiate()
	seg.max_life_points = 5
	seg.depth = 5
	_armRoot.add_child(seg)
	
	#run
	await get_tree().create_timer(10).timeout
	
	#compare
	assert_bool(seg._is_dead).is_equal(true)
