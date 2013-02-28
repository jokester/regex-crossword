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

g = new @crossword.Grid(2)

assertEq "Grid.turn-1",
  g.turn({x:1,y:0,z:-1}),
  {x:-1,y:1,z:0}
assertEq "Grid.turn-2",
  g.turn({x:-2,y:1,z:1}),
  {x:1,y:-2,z:1}

assertEq "Grid.contains-1",
  g.contains({x:-1,y:1,z:0}),
  true
assertEq "Grid.contains-2",
  g.contains({x:1,y:-1,z:0}),
  true
assertEq "Grid.contains-3",
  g.contains({x:1,y:1,z:0}),  # not legal form
  false
assertEq "Grid.contains-4",
  g.contains({x:3,y:-2,z:-1}), # out of field
  false

assertEq "Grid.row-1",
  g.row( {x:0,y:0,z:0}, "Px" ),
  [ -2..2 ].map( (v) -> { x:0, y:-v, z:v } )
assertEq "Grid.row-2",
  g.row( {x:0,y:1,z:-1}, "Py" ),
  [ -3..0 ].map( (v) -> { x:1+v, y:1, z:-2-v } )
