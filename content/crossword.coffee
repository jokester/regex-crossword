return unless $

# monkey patches
Array.prototype.sum = ()-> @reduce( (x,y) -> x+y )

coor2cellid = (p)->
  "cell_#{p.x}_#{p.y}"

cellid_regex = /^cell_(-?\d+)_(-?\d+)$/
cellid2coor = (id)->
  match = cellid_regex.exec(id)
  if match
    x: parseInt(match[1])
    y: parseInt(match[2])
  else
    match

class Grid6
  # coord system
  # 3-component coord sys, as mentioned by
  #   >> http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
  # cell in hex grid are denoted by <x,y> pair ( redudant z is not used )
  #
  # a hex grid with radius=2 is like
  #     -1,1  0,1
  #   -1,0  0,0  1,0
  #      0,-1  1,-1
  #
  # direction 0 := y = Const        unit vector <1,0>
  #           1 := -z= Const = x+y              <-1,1>
  #           2 := x = Const                    <0,-1>
  constructor: (@radius) ->
    @cells = {}     # { {x:x, y:y} : cell }
    @rules = [[], [], []] # [ direction: [ no: callback ] ]
    for x in [ -@radius .. +@radius ]
      for y in [ -@radius .. +@radius ]
        @set_cell(x,y,"?") if @contains( {x:x,y:y} )

  add_rule: (direction, rowno, cb )=>
    @rules[direction][rowno]=cb

  cell_changed: (cellid)=>
    p = cellid2coor( cellid )

  set_cell: (x,y,char) =>
    @cells[ coor2cellid( {x:x,y:y} ) ] = char

  distance: (p) ->
    Math.max( [ p.x, p.y, p.x+p.y ].map(Math.abs) ... )

  contains: (p) =>
    @distance(p) < @radius

  row: (p,direction) =>
    throw "not in grid" unless @contains(p)
    points = []
    steps = @radius
    for varing in [ -steps .. +steps ]
      new_point = $.extend( {}, p )
      switch direction
        when 0
          new_point.x += varing
          # z -= varing
        when 1
          new_point.x -= varing
          new_point.y += varing
        when 2
          new_point.y += varing
          # z -=
      points.push( new_point ) if @contains( new_point )
    points

@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid6
