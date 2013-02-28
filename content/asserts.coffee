assertEq = ( desc, expected, actual ) ->
  test_fun = ->
    deepEqual(expected,actual,desc)
  test( desc, test_fun )

assertEq "crossword.coor2cellid",
  @crossword.coor2cellid({x:1,y:2,z:-1}),
  "cell_1_2_-1"
assertEq "crossword.cellid2coor",
  @crossword.cellid2coor("cell_-1_-2_-3"),
  {x:-1,y:-2,z:-3}

g = new @crossword.Grid(1)

assertEq "Grid.turn",
  g.turn({x:1,y:0,z:-1}),
  {x:-1,y:1,z:0}
assertEq "Grid.turn",
  g.turn({x:-1,y:1,z:0}),
  {x:0,y:-1,z:1}

assertEq "Grid.contains",
  g.contains({x:-1,y:1,z:1}),
  true
assertEq "Grid.contains",
  g.contains({x:-2,y:-1,z:1}),
  false
