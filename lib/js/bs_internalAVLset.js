'use strict';


function height(n) {
  if (n !== null) {
    return n.h;
  } else {
    return 0;
  }
}

function create(l, v, r) {
  var hl = l !== null ? l.h : 0;
  var hr = r !== null ? r.h : 0;
  return {
          left: l,
          value: v,
          right: r,
          h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
        };
}

function bal(l, v, r) {
  var hl = l !== null ? l.h : 0;
  var hr = r !== null ? r.h : 0;
  if (hl > (hr + 2 | 0)) {
    if (l !== null) {
      var ll = l.left;
      var lv = l.value;
      var lr = l.right;
      if (height(ll) >= height(lr)) {
        return create(ll, lv, create(lr, v, r));
      } else if (lr !== null) {
        var lrl = lr.left;
        var lrv = lr.value;
        var lrr = lr.right;
        return create(create(ll, lv, lrl), lrv, create(lrr, v, r));
      } else {
        return /* assert false */0;
      }
    } else {
      return /* assert false */0;
    }
  } else if (hr > (hl + 2 | 0)) {
    if (r !== null) {
      var rl = r.left;
      var rv = r.value;
      var rr = r.right;
      if (height(rr) >= height(rl)) {
        return create(create(l, v, rl), rv, rr);
      } else if (rl !== null) {
        var rll = rl.left;
        var rlv = rl.value;
        var rlr = rl.right;
        return create(create(l, v, rll), rlv, create(rlr, rv, rr));
      } else {
        return /* assert false */0;
      }
    } else {
      return /* assert false */0;
    }
  } else {
    return {
            left: l,
            value: v,
            right: r,
            h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
          };
  }
}

function singleton0(x) {
  return {
          left: null,
          value: x,
          right: null,
          h: 1
        };
}

function add_min_element(v, n) {
  if (n !== null) {
    return bal(add_min_element(v, n.left), n.value, n.right);
  } else {
    return singleton0(v);
  }
}

function add_max_element(v, n) {
  if (n !== null) {
    return bal(n.left, n.value, add_max_element(v, n.right));
  } else {
    return singleton0(v);
  }
}

function join(ln, v, rn) {
  if (ln !== null) {
    if (rn !== null) {
      var lh = ln.h;
      var rh = rn.h;
      if (lh > (rh + 2 | 0)) {
        return bal(ln.left, ln.value, join(ln.right, v, rn));
      } else if (rh > (lh + 2 | 0)) {
        return bal(join(ln, v, rn.left), rn.value, rn.right);
      } else {
        return create(ln, v, rn);
      }
    } else {
      return add_max_element(v, ln);
    }
  } else {
    return add_min_element(v, rn);
  }
}

function min0Aux(_n) {
  while(true) {
    var n = _n;
    var match = n.left;
    if (match !== null) {
      _n = match;
      continue ;
      
    } else {
      return n.value;
    }
  };
}

function min0(n) {
  if (n !== null) {
    return /* Some */[min0Aux(n)];
  } else {
    return /* None */0;
  }
}

function max0Aux(_n) {
  while(true) {
    var n = _n;
    var match = n.right;
    if (match !== null) {
      _n = match;
      continue ;
      
    } else {
      return n.value;
    }
  };
}

function max0(n) {
  if (n !== null) {
    return /* Some */[max0Aux(n)];
  } else {
    return /* None */0;
  }
}

function min_eltAssert0(n) {
  if (n !== null) {
    return min0Aux(n);
  } else {
    return /* assert false */0;
  }
}

function removeMinAux(n) {
  var rn = n.right;
  var ln = n.left;
  if (ln !== null) {
    return bal(removeMinAux(ln), n.value, rn);
  } else {
    return rn;
  }
}

function remove_min_elt(n) {
  if (n !== null) {
    return removeMinAux(n);
  } else {
    return /* assert false */0;
  }
}

function merge(t1, t2) {
  if (t1 !== null) {
    if (t2 !== null) {
      return bal(t1, min0Aux(t2), removeMinAux(t2));
    } else {
      return t1;
    }
  } else {
    return t2;
  }
}

function concat(t1, t2) {
  if (t1 !== null) {
    if (t2 !== null) {
      return join(t1, min0Aux(t2), removeMinAux(t2));
    } else {
      return t1;
    }
  } else {
    return t2;
  }
}

var empty0 = null;

function isEmpty0(n) {
  if (n !== null) {
    return /* false */0;
  } else {
    return /* true */1;
  }
}

function cons_enum(_s, _e) {
  while(true) {
    var e = _e;
    var s = _s;
    if (s !== null) {
      _e = /* More */[
        s.value,
        s.right,
        e
      ];
      _s = s.left;
      continue ;
      
    } else {
      return e;
    }
  };
}

function iter0(f, _n) {
  while(true) {
    var n = _n;
    if (n !== null) {
      iter0(f, n.left);
      f(n.value);
      _n = n.right;
      continue ;
      
    } else {
      return /* () */0;
    }
  };
}

function fold0(f, _s, _accu) {
  while(true) {
    var accu = _accu;
    var s = _s;
    if (s !== null) {
      _accu = f(s.value, fold0(f, s.left, accu));
      _s = s.right;
      continue ;
      
    } else {
      return accu;
    }
  };
}

function forAll0(p, _n) {
  while(true) {
    var n = _n;
    if (n !== null) {
      if (p(n.value)) {
        if (forAll0(p, n.left)) {
          _n = n.right;
          continue ;
          
        } else {
          return /* false */0;
        }
      } else {
        return /* false */0;
      }
    } else {
      return /* true */1;
    }
  };
}

function exists0(p, _n) {
  while(true) {
    var n = _n;
    if (n !== null) {
      if (p(n.value)) {
        return /* true */1;
      } else if (exists0(p, n.left)) {
        return /* true */1;
      } else {
        _n = n.right;
        continue ;
        
      }
    } else {
      return /* false */0;
    }
  };
}

function filter0(p, n) {
  if (n !== null) {
    var l$prime = filter0(p, n.left);
    var v = n.value;
    var pv = p(v);
    var r$prime = filter0(p, n.right);
    if (pv) {
      return join(l$prime, v, r$prime);
    } else {
      return concat(l$prime, r$prime);
    }
  } else {
    return null;
  }
}

function partition0(p, n) {
  if (n !== null) {
    var match = partition0(p, n.left);
    var lf = match[1];
    var lt = match[0];
    var v = n.value;
    var pv = p(v);
    var match$1 = partition0(p, n.right);
    var rf = match$1[1];
    var rt = match$1[0];
    if (pv) {
      return /* tuple */[
              join(lt, v, rt),
              concat(lf, rf)
            ];
    } else {
      return /* tuple */[
              concat(lt, rt),
              join(lf, v, rf)
            ];
    }
  } else {
    return /* tuple */[
            null,
            null
          ];
  }
}

function cardinal0(n) {
  if (n !== null) {
    return (cardinal0(n.left) + 1 | 0) + cardinal0(n.right) | 0;
  } else {
    return 0;
  }
}

function elements_aux(_accu, _n) {
  while(true) {
    var n = _n;
    var accu = _accu;
    if (n !== null) {
      _n = n.left;
      _accu = /* :: */[
        n.value,
        elements_aux(accu, n.right)
      ];
      continue ;
      
    } else {
      return accu;
    }
  };
}

function elements0(s) {
  return elements_aux(/* [] */0, s);
}

exports.height          = height;
exports.create          = create;
exports.bal             = bal;
exports.singleton0      = singleton0;
exports.add_min_element = add_min_element;
exports.add_max_element = add_max_element;
exports.join            = join;
exports.min0Aux         = min0Aux;
exports.min0            = min0;
exports.max0Aux         = max0Aux;
exports.max0            = max0;
exports.min_eltAssert0  = min_eltAssert0;
exports.removeMinAux    = removeMinAux;
exports.remove_min_elt  = remove_min_elt;
exports.merge           = merge;
exports.concat          = concat;
exports.empty0          = empty0;
exports.isEmpty0        = isEmpty0;
exports.cons_enum       = cons_enum;
exports.iter0           = iter0;
exports.fold0           = fold0;
exports.forAll0         = forAll0;
exports.exists0         = exists0;
exports.filter0         = filter0;
exports.partition0      = partition0;
exports.cardinal0       = cardinal0;
exports.elements_aux    = elements_aux;
exports.elements0       = elements0;
/* empty0 Not a pure module */
