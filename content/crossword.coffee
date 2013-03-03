return unless $ or $=jQuery

# common util func/consts
coor2cellid = (p)->
  "cell_#{p.x}_#{p.y}"

cellid_regex = /^cell_(-?\d+)_(-?\d+)$/
cellid2coor = (id)->
  match = cellid_regex.exec(id)
  if match
    x: parseInt(match[1]) or throw "invalid x"
    y: parseInt(match[2]) or throw "invalid y"
  else
    throw "invalid cellid"

legal_directions = ["-","\\","/"]
check_direction = (dir)->
  dir in legal_directions or throw "illegal direction:#{dir}"

init_char="?"
css_cache={}

rotate120 = (elem) ->
  if elem.hasClass("rot120")
    elem.removeClass("rot120")
    elem.addClass("rot240")
  else if elem.hasClass("rot240")
    elem.removeClass("rot240")
  else
    elem.addClass("rot120")

log = (arg...) ->
  console.log arg...

class Grid6
  # coord system
  # 3-component coord sys, as mentioned by
  #   >> http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
  # cell in hex grid are denoted by <x,y> pair ( redudant z is not used )
  #
  # a hex grid with radius=3 is like
  #      -2,2  -1,2  0,2
  #   -2,1  -1,1  0,1  1,1
  # -2,0  -1,0  0,0  1,0  2,0
  #   -1,-1  0,-1  1,-1  2,-1
  #      0,-2   1,-2  2,-2
  #
  # direction - := y = Const        unit vector <1,0>     Const = -lineNo
  #           \ := -z= Const = x+y              <-1,1>             lineNo
  #           / := x = Const                    <0,-1>            -lineNo
  # lines : <direction,lineno>
  #         the line contains <0,0> has lineno=0
  #         e.g   <0,-1> -- <-1,0>  has direction="\", lineno=-1
  #               <1,0>  -- <0,1>   has direction="\", lineno=0
  #
  constructor: (@radius) ->
    @cells = {}   # { x: { y: char } }
    @rules =   # { direction: { lineno: callback } }
      "-" : {}
      "/" : {}
      "\\": {}
    for x in [ -@radius .. +@radius ]
      for y in [ -@radius .. +@radius ]
        @set_cell(x,y,"?") if @contains( {x:x,y:y} )

  when_line_changed: ( direction, lineno, cb ) =>
    @rules[direction][lineno] = cb

  line_changed: (direction, lineno)=>
    cb = @rules[direction][lineno]
    cb(direction,lineno) if cb

  set_cell: (x,y,char) =>
    @cells[x] = @cells[x] or {}
    @cells[x][y] = char
  get_cell: (x,y) =>
    @cells[x][y]

  change_cell: (cellid,char) =>
    p = cellid2coor(cellid)
    return if char == @get_cell(p.x,p.y)
    @set_cell( p.x, p.y, char )
    for direction in legal_directions
      @line_changed( direction, @lineNo(direction,p) )

  distance: (p) ->
    Math.max( [ p.x, p.y, p.x+p.y ].map(Math.abs) ... )

  contains: (p) =>
    @distance(p) < @radius

  lineNo: (direction,p) =>
    check_direction(direction)
    switch direction
      when "-"
        return -p.y
      when "/"
        return -p.x
      when '\\'
        return p.x+p.y

  line: (direction,lineNo) =>
    throw "not in grid" unless Math.abs(lineNo) < @radius
    check_direction( direction )
    new_point = switch direction
      when "-"  then (v)->{x:v, y:-lineNo  }
      when "\\" then (v)->{x:-v, y:lineNo+v}
      when "/"  then (v)->{x:-lineNo, y:-v }
    steps = @radius-Math.abs(lineNo)+1
    (p for p in [ -steps .. +steps ].map( new_point ) when @contains(p) )

  lineStr: (direction, lineNo) =>
    (@get_cell(p.x,p.y) for p in @line(direction,lineNo) ).join("")

class Krossword
  # - draw html
  # - set callback
  constructor: ( parent, @radius, @rules )->
    @grid = new Grid6( @radius )
    parent.append( @draw_table() )

  draw_table: ()->
    table = $("<table></table>")
    for y in [ (@radius-1)  ..  -(@radius-1) ]
      table.append( @draw_tr(y) )
    table.addClass("hextable")

  draw_tr: (y) ->
    tr = $("<tr></tr>")
    x_start = # TODO a more general expression
      if 0 == @radius%2
        -(@radius-1) - Math.ceil(y/2)
      else
        -(@radius-1) - Math.floor(y/2)

    for x in [ x_start .. x_start + 2*(@radius-1) ]
      tr.append( @draw_td( x, y ) )

  draw_td: (x,y) ->
    #TODO callback
    td = $("<td></td>")
    td.html("#{x},#{y}")
    p = x:x, y:y
    if @grid.contains( p )
      log? p, "in"
      #td.html(init_char)
      #else if @grid.contains( { x:x+1, y:y } )
      #  # TODO create and insert rule
      #  # td.append(rule)
      #  td.addClass("rule")
      td.addClass("not-pad")
    else
      log? p, "OUT"
      td.addClass("pad")
    if x==0 and y==0
      td.append( @draw_rule_set() )
    td
  draw_rule_set: (direction,lineNo)->
    rule = $("<span></span>").html("!")


# exports
@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid6
  Krossword: Krossword
