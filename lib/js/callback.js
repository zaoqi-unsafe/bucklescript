'use strict';

var Obj      = require("./obj.js");
var Caml_obj = require("./caml_obj.js");

function register(_, _$1) {
  return /* () */0;
}

function register_exception(_, exn) {
  Caml_obj.caml_obj_tag(exn) === Obj.object_tag ? exn : exn[0];
  return /* () */0;
}

exports.register           = register;
exports.register_exception = register_exception;
/* No side effect */
