extends GdUnitTestSuite

func test_hello():
	# Given that I have two variables
	var a:int = 5
	var b:int = 10
	# If I take the minimum of these two variables
	var result:int = min(a,b)
	# The result is the smaller of the two
	assert_int(result).is_equal(a)
