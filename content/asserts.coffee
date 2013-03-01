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

assertEq "Grid.lineNo",
  g.lineNo("-", {x:-1, y:1}),
  -1
assertEq "Grid.lineNo",
  g.lineNo("\\", {x:-1, y:1}),
  0
assertEq "Grid.lineNo",
  g.lineNo("/", {x:1, y:1}),
  -1

assertEq "Grid.contains-1",
  g.contains({x:-1,y:1}),
  true
assertEq "Grid.contains-2",
  g.contains({x:0,y:-1}),
  true
assertEq "Grid.contains-3",
  g.contains({x:1,y:2}), # out of field
  false

assertEq "Grid.line-1",
  g.line( "-", 0 ),
  ( {x:v, y:0} for v in [-2..2] )
assertEq "Grid.line-2",
  g.line( "\\", 1 ),
  ( {x:2-v, y:-1+v} for v in [0..3] )
assertEq "Grid.line-3",
  g.line( "/", -2 ),
  ( {x:2, y:-v} for v in [0..2] )

g.set_cell(1,1,"X")
g.set_cell(2,0,"Y")
###
        ? ? ?
       ? ? ? X
      ? ? ? ? Y
       ? ? ? ?
        ? ? ?
###
assertEq "Grid.set_cell",
  g.get_cell(1,1),
  "X"
assertEq "Grid.lineStr-1",
  g.lineStr("-", 0 ),
  "????Y"
assertEq "Grid.lineStr-2",
  g.lineStr("\\", 2 ),
  "YX?"
assertEq "Grid.lineStr-3",
  g.lineStr("/", -1 ),
  "X???"
assertEq "Grid.lineStr-4",
  g.lineStr("/", -2 ),
  "Y??"

callbacks_invoked = []
cb = (a,b) -> callbacks_invoked.push [a,b]
for dir in ["-","\\","/"]
  for lineno in [-3..3]
    g.when_line_changed(dir,lineno,cb)

g.change_cell("cell_1_0","#")

assertEq "Grid.change_cell really changes cb",
  g.lineStr("-", 0 ),
  "???#Y"
assertEq "Grid.change_cell calls cb",
  callbacks_invoked,
  [
    [ "-", 0 ]
    [ "\\", 1 ]
    [ "/", -1 ]
  ]
