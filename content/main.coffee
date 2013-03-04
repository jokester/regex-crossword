rules = {}
rules["-"] =
  "-1": "ab"
  "0" : "cde"
  "1" : "fg"

rules["\\"] =
  "-1": "fc"
  "0" : "gda"
  "1" : "eb"

rules["/"] =
  "-1": "eg"
  "0" : "bdf"
  "1" : "ac"

if grid=$("#kgrid")
  kross = new @crossword.Krossword(grid, 2, rules)
