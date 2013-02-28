return unless $
grid = $("#grid")

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

class Grid
  constructor: (@radius) ->
  turn: (p) ->
    # turn coord by 2pi/3, in a 3-component coord sys mentioned by http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
    y: p.x
    z: p.y
    x: p.z
  contains: (p) =>
    coord_abs = [ p.x, p.y, p.z ].map(Math.abs)
    Math.max.apply( Math, coord_abs) <= @radius

@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid
