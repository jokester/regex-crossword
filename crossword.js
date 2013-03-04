(function() {
  var $, Grid6, Krossword, cellid2coor, cellid_regex, char_at, check_direction, compareNum, coor2cellid, css_cache, init_char, legal_directions, log, next_direction, rotate120, rule2id,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (!($ || ($ = jQuery))) {
    return;
  }

  coor2cellid = function(p) {
    return "cell_" + p.x + "_" + p.y;
  };

  cellid_regex = /^cell_(-?\d+)_(-?\d+)$/;

  cellid2coor = function(id) {
    var match;
    match = cellid_regex.exec(id);
    if (match) {
      return {
        x: parseInt(match[1]),
        y: parseInt(match[2])
      };
    } else {
      throw "invalid cellid";
    }
  };

  char_at = function(p) {
    return $($("#" + (coor2cellid(p)))[0]).attr("char");
  };

  legal_directions = ["-", "\\", "/"];

  check_direction = function(dir) {
    return __indexOf.call(legal_directions, dir) >= 0 || (function() {
      throw "illegal direction:" + dir;
    })();
  };

  rule2id = function(direction, lineNo) {
    return "rule_" + (legal_directions.indexOf(direction)) + "_" + lineNo;
  };

  next_direction = function(direction) {
    return legal_directions[(legal_directions.indexOf(direction) + 1) % 3];
  };

  init_char = "?";

  css_cache = {};

  rotate120 = function(elem) {
    if (elem.hasClass("rot120")) {
      elem.removeClass("rot120");
      return elem.addClass("rot240");
    } else if (elem.hasClass("rot240")) {
      return elem.removeClass("rot240");
    } else {
      return elem.addClass("rot120");
    }
  };

  log = function() {
    var arg;
    arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return true && console.log.apply(console, arg);
  };

  compareNum = function(a, b) {
    return a - b;
  };

  Grid6 = (function() {

    function Grid6(radius) {
      this.radius = radius;
      this.rotate = __bind(this.rotate, this);
      this.line = __bind(this.line, this);
      this.lineNo = __bind(this.lineNo, this);
      this.contains = __bind(this.contains, this);
      this.change_cell = __bind(this.change_cell, this);
      this.line_changed = __bind(this.line_changed, this);
      this.when_line_changed = __bind(this.when_line_changed, this);
      this.line_cb = {
        "-": {},
        "\\": {},
        "/": {}
      };
    }

    Grid6.prototype.when_changed = function(cb) {
      this.cb = cb;
    };

    Grid6.prototype.when_line_changed = function(direction, lineno, cb) {
      return this.line_cb[direction][lineno] = cb;
    };

    Grid6.prototype.line_changed = function(direction, lineno) {
      var cb;
      cb = this.line_cb[direction][lineno];
      if (cb) {
        cb(direction, lineno);
      }
      if (this.cb) {
        return this.cb(direction, lineno);
      }
    };

    Grid6.prototype.change_cell = function(cellid, char) {
      var direction, p, _i, _len, _results;
      p = cellid2coor(cellid);
      _results = [];
      for (_i = 0, _len = legal_directions.length; _i < _len; _i++) {
        direction = legal_directions[_i];
        _results.push(this.line_changed(direction, this.lineNo(direction, p)));
      }
      return _results;
    };

    Grid6.prototype.distance = function(p) {
      return Math.max.apply(Math, [p.x, p.y, p.x + p.y].map(Math.abs));
    };

    Grid6.prototype.contains = function(p) {
      return this.distance(p) < this.radius;
    };

    Grid6.prototype.lineNo = function(direction, p) {
      check_direction(direction);
      switch (direction) {
        case "-":
          return -p.y;
        case "/":
          return -p.x;
        case '\\':
          return p.x + p.y;
      }
    };

    Grid6.prototype.line = function(direction, lineNo) {
      var new_point, p, steps, _i, _j, _len, _ref, _results, _results1;
      if (!(Math.abs(lineNo) < this.radius)) {
        throw "not in grid";
      }
      check_direction(direction);
      new_point = (function() {
        switch (direction) {
          case "-":
            return function(v) {
              return {
                x: v,
                y: -lineNo
              };
            };
          case "\\":
            return function(v) {
              return {
                x: -v,
                y: lineNo + v
              };
            };
          case "/":
            return function(v) {
              return {
                x: -lineNo,
                y: -v
              };
            };
        }
      })();
      steps = this.radius - Math.abs(lineNo) + 1;
      _ref = (function() {
        _results1 = [];
        for (var _j = -steps; -steps <= +steps ? _j <= +steps : _j >= +steps; -steps <= +steps ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this).map(new_point);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (this.contains(p)) {
          _results.push(p);
        }
      }
      return _results;
    };

    Grid6.prototype.rotate = function(p) {
      return {
        x: -(p.x + p.y),
        y: p.x
      };
    };

    return Grid6;

  })();

  Krossword = (function() {

    function Krossword(parent, radius, rules) {
      var grid,
        _this = this;
      this.parent = parent;
      this.radius = radius;
      this.grid = grid = new Grid6(this.radius);
      this.rules = rules;
      grid.when_changed(function(direction, lineNo) {
        var points, regex, rule, str;
        points = grid.line(direction, lineNo);
        str = points.map(char_at).join("");
        rule = $("#" + (rule2id(direction, lineNo)));
        regex = new RegExp("^" + (rule.text()) + "$");
        if (regex.exec(str)) {
          return rule.addClass("matched");
        } else {
          return rule.removeClass("matched");
        }
      });
      this.callback_cell_click = function(td) {
        var change_done, input,
          _this = this;
        if (this.changing) {
          return;
        }
        this.changing = true;
        input = $("<input>").attr({
          type: "text",
          maxlength: 1,
          value: $(this).attr("char")
        });
        change_done = function() {
          var new_char;
          new_char = input.val();
          if (_this.char !== new_char) {
            $(_this).attr({
              char: new_char
            });
            $(_this).html(new_char);
            grid.change_cell(_this.id, new_char);
          }
          return _this.changing = false;
        };
        input.on("focusout", change_done);
        $(this).html(input);
        return input.focus();
      };
      parent.append(this.draw_table());
      $("#control").append(this.draw_button("clockwise", function() {
        return _this.rotate(true);
      }));
      $("#control").append(this.draw_button("counter", function() {
        return _this.rotate(false);
      }));
    }

    Krossword.prototype.compile_rule = function(rules) {
      var compiled, direction, lineNo, lines, regex;
      compiled = {};
      for (direction in rules) {
        lines = rules[direction];
        compiled[direction] = {};
        for (lineNo in lines) {
          regex = lines[lineNo];
          compiled[direction][lineNo] = new RegExp(("^" + regex + "$") || "");
        }
      }
      return compiled;
    };

    Krossword.prototype.enum_coord = function() {
      var ret, x_start, y, _i, _j, _k, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1;
      ret = {};
      for (y = _i = _ref = this.radius, _ref1 = -this.radius; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; y = _ref <= _ref1 ? ++_i : --_i) {
        x_start = 0 === this.radius % 2 ? -(this.radius - 1) - Math.floor(y / 2) : -(this.radius - 1) - Math.ceil(y / 2);
        ret[y] = (function() {
          _results = [];
          for (var _j = _ref2 = x_start - 1, _ref3 = x_start + 2 * (this.radius - 1) + 1; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; _ref2 <= _ref3 ? _j++ : _j--){ _results.push(_j); }
          return _results;
        }).apply(this);
      }
      ret.ys = (function() {
        _results1 = [];
        for (var _k = _ref4 = this.radius, _ref5 = -this.radius; _ref4 <= _ref5 ? _k <= _ref5 : _k >= _ref5; _ref4 <= _ref5 ? _k++ : _k--){ _results1.push(_k); }
        return _results1;
      }).apply(this);
      return ret;
    };

    Krossword.prototype.draw_table = function() {
      var coords, table, y, _i, _len, _ref, _results;
      table = $("<table></table>");
      coords = this.enum_coord();
      table.addClass("hextable");
      _ref = coords.ys;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        y = _ref[_i];
        _results.push(table.append(this.draw_tr(y, coords[y])));
      }
      return _results;
    };

    Krossword.prototype.draw_tr = function(y, xs) {
      var tr, x, _i, _len;
      tr = $("<tr></tr>");
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        tr.append(this.draw_td(x, y));
      }
      return tr;
    };

    Krossword.prototype.draw_td = function(x, y) {
      var td;
      td = $("<td></td>");
      if (this.grid.contains({
        x: x,
        y: y
      })) {
        td.addClass("inuse").attr("id", coor2cellid({
          x: x,
          y: y
        })).attr("char", init_char).on("click", this.callback_cell_click).html(init_char);
      } else if (this.grid.contains({
        x: x + 1,
        y: y
      })) {
        td.addClass("rule deg0").append(this.draw_rule(x, y, "-", -y));
      } else if (this.grid.contains({
        x: x,
        y: y - 1
      })) {
        td.addClass("rule deg240").append(this.draw_rule(x, y, "/", -x));
      } else if (this.grid.contains({
        x: x - 1,
        y: y + 1
      })) {
        td.addClass("rule deg120").append(this.draw_rule(x, y, "\\", x + y));
      } else {
        td.addClass("padding");
      }
      return td;
    };

    Krossword.prototype.draw_rule = function(x, y, direction, lineNo) {
      var rule_parent, rule_text;
      check_direction(direction);
      rule_parent = $("<div>").addClass("rule_parent");
      rule_text = $("<span>").addClass("rule_text").attr("id", rule2id(direction, lineNo)).html(this.rules[direction][lineNo]);
      return rule_parent.append(rule_text);
    };

    Krossword.prototype.draw_button = function(text, cb) {
      return $("<button>").html(text).on("click", cb);
    };

    Krossword.prototype.rotate = function(clockwise) {
      this.rotate_cell(clockwise);
      return this.rotate_rules(clockwise);
    };

    Krossword.prototype.rotate_cell = function(clockwise) {
      var a, b, c, ids, p, x, y, _i, _ref, _results;
      _results = [];
      for (x = _i = 0, _ref = this.radius - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _ref2, _results1;
          _results1 = [];
          for (y = _j = _ref1 = -(x - 1), _ref2 = this.radius - 1; _ref1 <= _ref2 ? _j <= _ref2 : _j >= _ref2; y = _ref1 <= _ref2 ? ++_j : --_j) {
            a = {
              x: x,
              y: y
            };
            if (this.grid.contains(a)) {
              b = this.grid.rotate(a);
              c = this.grid.rotate(b);
              ids = (function() {
                var _k, _len, _ref3, _results2;
                _ref3 = [a, b, c];
                _results2 = [];
                for (_k = 0, _len = _ref3.length; _k < _len; _k++) {
                  p = _ref3[_k];
                  _results2.push("#" + (coor2cellid(p)));
                }
                return _results2;
              })();
              if (clockwise) {
                ids.reverse();
              }
              _results1.push(this.exchange3cells.apply(this, ids));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Krossword.prototype.rotate_rules = function(clockwise) {
      var directions, lineNo, _i, _ref, _ref1, _results;
      directions = legal_directions.slice(0);
      if (clockwise) {
        directions.reverse();
      }
      _results = [];
      for (lineNo = _i = _ref = -(this.radius - 1), _ref1 = +(this.radius - 1); _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; lineNo = _ref <= _ref1 ? ++_i : --_i) {
        _results.push(this.exchange3rules(lineNo, directions));
      }
      return _results;
    };

    Krossword.prototype.exchange3cells = function(a, b, c) {
      var ta, tb, tc;
      a = $(a);
      b = $(b);
      c = $(c);
      ta = a.text();
      tb = b.text();
      tc = c.text();
      a.text(tc).attr({
        char: tc
      });
      c.text(tb).attr({
        char: tb
      });
      return b.text(ta).attr({
        char: ta
      });
    };

    Krossword.prototype.exchange3rules = function(lineNo, directions) {
      var cache, dir, elem, id, new_dir, new_elem, old, old_index, _i, _j, _len, _len1, _results;
      cache = {};
      for (_i = 0, _len = directions.length; _i < _len; _i++) {
        dir = directions[_i];
        id = "#" + rule2id(dir, lineNo);
        elem = $(id);
        cache[dir] = {
          id: id,
          elem: elem,
          text: elem.text(),
          matched: elem.hasClass("matched")
        };
      }
      _results = [];
      for (old_index = _j = 0, _len1 = directions.length; _j < _len1; old_index = ++_j) {
        dir = directions[old_index];
        new_dir = directions[old_index + 1] || directions[0];
        new_elem = cache[new_dir].elem;
        old = cache[dir];
        new_elem.text(old.text);
        if (old.matched) {
          _results.push(new_elem.addClass("matched"));
        } else {
          _results.push(new_elem.removeClass("matched"));
        }
      }
      return _results;
    };

    return Krossword;

  })();

  this.crossword = {
    coor2cellid: coor2cellid,
    cellid2coor: cellid2coor,
    Grid: Grid6,
    Krossword: Krossword
  };

}).call(this);
