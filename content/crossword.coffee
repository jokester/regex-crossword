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
  # use a 3-component coord sys mentioned by http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
  constructor: (@radius) ->
    @cells = {}
    for x in [ -@radius .. +@radius ]
      for y in [ -@radius .. +@radius ]
        @set_cell(x,y,"?") if @contains( {x:x,y:y} )
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
        when "x+pi/6"
          new_point.x += varing
          # z -= varing
        when "y+pi/6"
          new_point.x -= varing
          new_point.y += varing
        when "z+pi/6"
          new_point.y += varing
          # z -=
      points.push( new_point ) if @contains( new_point )
    points

@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid6
