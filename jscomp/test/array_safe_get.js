// Generated by BUCKLESCRIPT VERSION 1.5.3+dev, PLEASE EDIT WITH CARE
'use strict';

var Caml_array              = require("bs-platform/lib/js/caml_array");
var Caml_builtin_exceptions = require("bs-platform/lib/js/caml_builtin_exceptions");

var x = /* int array */[
  1,
  2
];

var y;

try {
  y = Caml_array.caml_array_get(x, 3);
}
catch (exn){
  if (exn[0] === Caml_builtin_exceptions.invalid_argument) {
    console.log(exn[1]);
    y = 0;
  }
  else {
    throw exn;
  }
}

exports.x = x;
exports.y = y;
/* y Not a pure module */
