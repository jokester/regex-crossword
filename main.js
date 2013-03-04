(function() {
  var grid, kross, rules;

  rules = {};

  rules["-"] = {
    "-6": ".*H.*H.*",
    "-5": "(DI|NS|TH|OM)*",
    "-4": "F.*[AO].*[AO].*",
    "-3": "(O|RHH|MM)*",
    "-2": ".*",
    "-1": "C*MC(CCC|MM)*",
    "0": "[^C]*[^R]*III.*",
    "1": "(...?)\\1*",
    "2": "([^X]|XCC)*",
    "3": "(RR|HHH)*.?",
    "4": "N.*X.X.X.*E",
    "5": "R*D*M*",
    "6": ".(C|HH)*"
  };

  rules["\\"] = {
    "-6": ".*G.*V.*H.*",
    "-5": "[CR]*",
    "-4": ".*XEXM*",
    "-3": ".*DD.*CCM.*",
    "-2": ".*XHCR.*X.*",
    "-1": ".*(.)(.)(.)(.)\\4\\3\\2\\1.*",
    "0": ".*(IN|SE|HI)",
    "1": "[^C]*MMM[^C]*",
    "2": ".*(.)C\\1X\\1.*",
    "3": "[CEIMU]*OH[AEMOR]*",
    "4": "(RX|[^R])*",
    "5": "[^M]*M[^M]*",
    "6": "(S|MM|HHH)*"
  };

  rules["/"] = {
    "-6": ".*SE.*UE.*",
    "-5": ".*LR.*RL.*",
    "-4": ".*OXR.*",
    "-3": "([^EMC]|EM)*",
    "-2": "(HHX|[^HX])*",
    "-1": ".*PRR.*DDC.*",
    "0": ".*",
    "1": "[AM]*CM(RC)*R?",
    "2": "([^MC]|MM|CC)*",
    "3": "(E|CR|MN)*",
    "4": "P+(..)\\1.*",
    "5": "[CHMNOR]*I[CHMNOR]*",
    "6": "(ND|ET|IN)[^X]*"
  };

  if (grid = $("#kgrid")) {
    kross = new this.crossword.Krossword(grid, 7, rules);
  }

}).call(this);
