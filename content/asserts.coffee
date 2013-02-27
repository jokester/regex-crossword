assert = ( desc, expected, actual ) ->
  test_fun = ->
    deepEqual(expected,actual,desc)
  test( desc, test_fun )

