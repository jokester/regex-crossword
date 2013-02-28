assertEq = ( desc, expected, actual ) ->
  test_fun = ->
    deepEqual(expected,actual,desc)
  test( desc, test_fun )

assertEq "crossword.coor2cellid",
  @crossword.coor2cellid({x:1,y:2}),
  "cell_1_2"
assertEq "crossword.cellid2coor",
  @crossword.cellid2coor("cell_-1_-2"),
  {x:-1,y:-2}

g = new @crossword.Grid(3)
# 3-4-5-4-3

assertEq "Grid.contains-1",
  g.contains({x:-1,y:1}),
  true
assertEq "Grid.contains-2",
  g.contains({x:2,y:-1}),
  true
assertEq "Grid.contains-3",
  g.contains({x:3,y:1}), # out of field
  false

assertEq "Grid.row-1",
  g.row( {x:0,y:0}, 0 ),
  [ -2..2 ].map( (v) -> { x:v, y:0 } )
assertEq "Grid.row-2",
  g.row( {x:-1,y:1}, 1 ),
  [ -2..2 ].map( (v) -> { x:-v, y: v } )
assertEq "Grid.row-3",
  g.row( {x:2,y:-1}, 2 ),
  [ -2..0 ].map( (v) -> { x:2, y:v } )
