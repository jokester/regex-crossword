return unless $ or $=jQuery

# common util func/consts
coor2cellid = (p)->
  "cell_#{p.x}_#{p.y}"

cellid_regex = /^cell_(-?\d+)_(-?\d+)$/
cellid2coor = (id)->
  match = cellid_regex.exec(id)
  if match
    x: parseInt(match[1])
    y: parseInt(match[2])
  else
    throw "invalid cellid"
char_at = (p)->
  $($("##{coor2cellid(p)}")[0]).attr("char")

legal_directions = ["-","\\","/"]
check_direction = (dir)->
  dir in legal_directions or throw "illegal direction:#{dir}"

rule2id = (direction,lineNo)->
  "rule_#{legal_directions.indexOf(direction)}_#{lineNo}"
next_direction = (direction)->
  legal_directions[ ( legal_directions.indexOf(direction)+1 )%3 ]

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
  true and console.log arg...

compareNum = (a,b) -> a-b

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
    @line_cb =
      "-" :{}
      "\\":{}
      "/" :{}

  when_changed: (@cb)->

  when_line_changed: ( direction, lineno, cb ) =>
    @line_cb[direction][lineno] = cb

  line_changed: (direction, lineno)=>
    cb = @line_cb[direction][lineno]
    cb(direction,lineno) if cb
    @cb(direction,lineno) if @cb

  change_cell: (cellid,char) =>
    p = cellid2coor(cellid)
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

  rotate: (p) =>
    x: -(p.x+p.y)
    y: p.x


class Krossword
  # - draw html
  # - set callback
  constructor: ( @parent, @radius, rules )->

    @grid = grid = new Grid6( @radius )
    @rules = rules

    grid.when_changed (direction,lineNo)->
      points = grid.line(direction,lineNo)
      str = points.map( char_at ).join("")
      rule = $("##{rule2id(direction,lineNo)}")
      regex = new RegExp("^#{rule.text()}$")
      if regex.exec(str)
        rule.addClass("matched")
      else
        rule.removeClass("matched")

    @callback_cell_click = (td)->
      return if @changing
      @changing = true

      input = $("<input>").attr({type:"text", maxlength:1, value: $(@).attr("char")})

      change_done = =>
        new_char = input.val()
        if @char isnt new_char
          $(@).attr(char: new_char)
          $(@).html(new_char)
          grid.change_cell(@id, new_char)
        @changing = false

      input.on "focusout", change_done
      $(@).html(input)
      input.focus()

    parent.append( @draw_table() )
    $("#control").append @draw_button "clockwise",()=>
      @rotate true
    $("#control").append @draw_button "counter",()=>
      @rotate false

  compile_rule: (rules)->
    compiled = {}
    for direction, lines of rules
      compiled[direction] = {}
      for lineNo, regex of lines
        compiled[direction][lineNo] = new RegExp("^#{regex}$" or "")
    return compiled

  enum_coord: ()->
    ret = {}        # { y: [x] }     # not as y, x is sorted
    for y in [ (@radius)  ..  -(@radius) ]
      x_start = # TODO a more general expression
        if 0 == @radius%2
          -(@radius-1) - Math.floor(y/2)
        else
          -(@radius-1) - Math.ceil(y/2)
      ret[y] = [ x_start-1 .. x_start + 2*(@radius-1)+1 ]
    ret.ys = [ (@radius)  ..  -(@radius) ]
    return ret

  draw_table: ()->
    table = $("<table></table>")
    coords = @enum_coord()
    table.addClass("hextable")
    for y in coords.ys
      table.append( @draw_tr(y, coords[y] ))

  draw_tr: (y,xs) ->
    tr = $("<tr></tr>")
    for x in xs
      tr.append( @draw_td( x, y ) )
    tr

  draw_td: (x,y) ->
    td = $("<td></td>")
    if @grid.contains( x:x, y:y )
      td
        .addClass("inuse")
        .attr("id", coor2cellid(x:x, y:y))
        .attr("char", init_char )
        .on("click", @callback_cell_click)
        .html(init_char)
    else if @grid.contains( x:x+1, y:y )
      td
        .addClass("rule deg0")
        .append @draw_rule(x,y,"-",-y)
    else if @grid.contains( x:x, y:y-1 )
      td
        .addClass("rule deg240")
        .append @draw_rule(x,y,"/",-x)
    else if @grid.contains( x:x-1, y:y+1 )
      td
        .addClass("rule deg120")
        .append @draw_rule(x,y,"\\",x+y)
    else
      td
        .addClass("padding")
    return td

  draw_rule: (x,y,direction,lineNo)->
    check_direction( direction )
    rule_parent = $("<div>")
      .addClass("rule_parent")
    rule_text = $("<span>")
      .addClass("rule_text")
      .attr( "id", rule2id(direction,lineNo) )
      .html( @rules[direction][lineNo] )
    rule_parent.append(rule_text)

  draw_button : (text,cb)->
    $("<button>").html(text).on "click",cb

  rotate: (clockwise)->
    @rotate_cell clockwise
    @rotate_rules clockwise

  rotate_cell: (clockwise)->
    for x in [ 0 .. @radius-1 ]
      for y in [ -(x-1) .. @radius-1 ]
        a = x:x, y:y
        if @grid.contains( a )
          b = @grid.rotate(a)
          c = @grid.rotate(b)
          ids = ("##{coor2cellid(p)}" for p in [a,b,c])
          ids.reverse() if clockwise
          @exchange3cells( ids ... )

  rotate_rules: (clockwise)->
    directions = legal_directions.slice(0)
    directions.reverse() if clockwise
    for lineNo in [ -(@radius-1) .. +(@radius-1) ]
      @exchange3rules lineNo, directions

  exchange3cells: (a,b,c)->
    #  a>b, b>c, c>a
    a=$(a)
    b=$(b)
    c=$(c)
    ta=a.text()
    tb=b.text()
    tc=c.text()
    a.text(tc).attr( char: tc )
    c.text(tb).attr( char: tb )
    b.text(ta).attr( char: ta )

  exchange3rules: (lineNo, directions) ->
    cache = {}
    for dir in directions
      id = "#" + rule2id(dir,lineNo)
      elem = $(id)
      cache[dir] =
        id: id
        elem: elem
        text: elem.text()
        matched: elem.hasClass("matched")
    for dir,old_index in directions
      new_dir = directions[old_index+1] or directions[0]
      new_elem = cache[new_dir].elem
      old = cache[dir]
      new_elem.text( old.text      )
      if old.matched
        new_elem.addClass("matched")
      else
        new_elem.removeClass("matched")

@crossword =
  coor2cellid: coor2cellid
  cellid2coor: cellid2coor
  Grid: Grid6
  Krossword: Krossword
