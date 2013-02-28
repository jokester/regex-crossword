return unless $

# monkey patches
Array.prototype.sum = ()-> @reduce( (x,y) -> x+y )

coor2cellid = (p)->
  "cell_#{p.x}_#{p.y}_#{p.z}"

cellid_regex = /^cell_(-?\d+)_(-?\d+)_(-?\d+)$/
cellid2coor = (id)->
  match = cellid_regex.exec(id)
  if match
    x: parseInt(match[1])
    y: parseInt(match[2])
    z: parseInt(match[3])
  else
    match

class Grid6
  constructor: (@radius) ->
    @cells = {}
    for x in [ -@radius .. +@radius ]
      for y in [ -@radius .. +@radius ]
        z = 0-x-y
        @set_cell(x,y,z,"?") if @contains( {x:x,y:y,z:z} )
  set_cell: (x,y,z,char) =>
    @cells[ coor2cellid( {x:x,y:y,z:z} ) ] = char
  turn: (p) ->
    # turn coord by 2pi/3, in a 3-component coord sys mentioned by http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
    y: p.x
    z: p.y
    x: p.z
  distance: (p) ->
    Math.max( [ p.x, p.y, p.z ].map(Math.abs)... )
  legal: (p) ->
    p.x + p.y + p.z == 0
  contains: (p) =>
    @legal(p) and @distance(p)<=@radius
  row: (p,direction) =>
    throw "not in grid" unless @contains(p)
    points = []
    steps = 2*@radius - @distance( p )
    for varing in [ -steps .. +steps ]
      new_point = $.extend( {}, p )
      switch direction
        when "Px"
          new_point.y -= varing
          new_point.z += varing
        when "Py"
          new_point.z -= varing
          new_point.x += varing
        when "Pz"
          new_point.x -= varing
          new_point.y += varing
      points.push( new_point ) if @contains( new_point )
    points

@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid6
