// How each element-wise `stablehlo` operation becomes the body of a
// `linalg.generic`: data for `mlir/src/stablehlo_to_linalg.rs`. See
// `docs/design/mlir.md`, section 5.10.
//
// Each entry describes one operation for one kind of element, `float` or
// `int`. Its body is written for `f32` (or `i32`), which stands for the
// result's element type. The body's arguments are the operation's operands'
// elements, in order, then the output's element (unused: StableHLO's
// element-wise operations take operands of the result's shape, with no
// implicit broadcasting).
//
// What each computes is as the StableHLO specification defines it:
// `maximum` and `minimum` propagate NaN, `logistic` is 1 / (1 + e^-x),
// `remainder` takes the sign of the dividend.

"epitome.lowering"() <{op = "stablehlo.add", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.addf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.add", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = arith.addi %a, %b : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.subtract", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.subf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.subtract", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = arith.subi %a, %b : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.multiply", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.mulf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.multiply", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = arith.muli %a, %b : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.divide", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.divf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.divide", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.divsi"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.remainder", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.remf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.remainder", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.remsi"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.maximum", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.maximumf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.maximum", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.maxsi"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.minimum", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.minimumf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.minimum", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.minsi"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.power", element = "float"}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = "math.powf"(%a, %b) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.and", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.andi"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.or", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.ori"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.xor", element = "int"}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = "arith.xori"(%a, %b) : (i32, i32) -> i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.negate", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = arith.negf %a : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.negate", element = "int"}> ({
^bb0(%a: i32, %out: i32):
  %z = arith.constant 0 : i32
  %r = arith.subi %z, %a : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.abs", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.absf"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.exponential", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.exp"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.log", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.log"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.logistic", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %one = arith.constant 1.0 : f32
  %n = arith.negf %a : f32
  %e = "math.exp"(%n) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  %d = arith.addf %e, %one : f32
  %r = arith.divf %one, %d : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.tanh", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.tanh"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.sqrt", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.sqrt"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.rsqrt", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.rsqrt"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.sine", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.sin"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.cosine", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.cos"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.floor", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.floor"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "stablehlo.ceil", element = "float"}> ({
^bb0(%a: f32, %out: f32):
  %r = "math.ceil"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
  linalg.yield %r : f32
}) : () -> ()
