// How each `torch` operation becomes `linalg` on tensors: data for
// `mlir/src/torch_to_linalg.rs`. See `docs/design/mlir.md`, section 6.
//
// Each entry describes one operation for one kind of element, `float` or
// `int`. Its body is the `linalg.generic` body, written for `f32` (or
// `i32`), which stands for the result's element type. The body's
// arguments are the operation's tensor and scalar operands, in order,
// then the output element (the accumulator of a reduction).
//
// `operands` gives each operand's role:
//
//   tensor     an input of the `linalg.generic`
//   scalar     a constant number, given to the body as a constant
//   init       a tensor (or none) the output starts as, read by `init_map`;
//              none, or a reduction without one, starts at zero
//   list       a list of constant integers, read by `symbols` and `pad`
//   perm       a list giving the output's dimensions in the input's order
//   swap       two of these: dimensions to exchange
//   dims       a list of dimensions to reduce (empty: all of them)
//   keepdim    whether reduced dimensions stay, with size 1
//   false, 1   a constant that must have this value
//   ignore     not used
//
// Without `indexing_maps`, an entry is element by element, with inputs
// broadcast to the result's shape as PyTorch broadcasts them.

"epitome.lowering"() <{op = "torch.aten.add.Tensor", element = "float", operands = ["tensor", "tensor", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %alpha: f32, %out: f32):
  %s = arith.mulf %b, %alpha : f32
  %r = arith.addf %a, %s : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.add.Tensor", element = "int", operands = ["tensor", "tensor", "scalar"]}> ({
^bb0(%a: i32, %b: i32, %alpha: i32, %out: i32):
  %s = arith.muli %b, %alpha : i32
  %r = arith.addi %a, %s : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.sub.Tensor", element = "float", operands = ["tensor", "tensor", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %alpha: f32, %out: f32):
  %s = arith.mulf %b, %alpha : f32
  %r = arith.subf %a, %s : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.sub.Tensor", element = "int", operands = ["tensor", "tensor", "scalar"]}> ({
^bb0(%a: i32, %b: i32, %alpha: i32, %out: i32):
  %s = arith.muli %b, %alpha : i32
  %r = arith.subi %a, %s : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.mul.Tensor", element = "float", operands = ["tensor", "tensor"]}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.mulf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.mul.Tensor", element = "int", operands = ["tensor", "tensor"]}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = arith.muli %a, %b : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.div.Tensor", element = "float", operands = ["tensor", "tensor"]}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.divf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.add.Scalar", element = "float", operands = ["tensor", "scalar", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %alpha: f32, %out: f32):
  %s = arith.mulf %b, %alpha : f32
  %r = arith.addf %a, %s : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.add.Scalar", element = "int", operands = ["tensor", "scalar", "scalar"]}> ({
^bb0(%a: i32, %b: i32, %alpha: i32, %out: i32):
  %s = arith.muli %b, %alpha : i32
  %r = arith.addi %a, %s : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.sub.Scalar", element = "float", operands = ["tensor", "scalar", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %alpha: f32, %out: f32):
  %s = arith.mulf %b, %alpha : f32
  %r = arith.subf %a, %s : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.rsub.Scalar", element = "float", operands = ["tensor", "scalar", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %alpha: f32, %out: f32):
  %s = arith.mulf %a, %alpha : f32
  %r = arith.subf %b, %s : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.mul.Scalar", element = "float", operands = ["tensor", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.mulf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.mul.Scalar", element = "int", operands = ["tensor", "scalar"]}> ({
^bb0(%a: i32, %b: i32, %out: i32):
  %r = arith.muli %a, %b : i32
  linalg.yield %r : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.div.Scalar", element = "float", operands = ["tensor", "scalar"]}> ({
^bb0(%a: f32, %b: f32, %out: f32):
  %r = arith.divf %a, %b : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.neg", element = "float", operands = ["tensor"]}> ({
^bb0(%a: f32, %out: f32):
  %r = arith.negf %a : f32
  linalg.yield %r : f32
}) : () -> ()

// Below zero gives zero; NaN stays NaN, as in PyTorch.
"epitome.lowering"() <{op = "torch.aten.relu", element = "float", operands = ["tensor"]}> ({
^bb0(%a: f32, %out: f32):
  %zero = arith.constant 0.000000e+00 : f32
  %below = arith.cmpf olt, %a, %zero : f32
  %r = arith.select %below, %zero, %a : f32
  linalg.yield %r : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.relu", element = "int", operands = ["tensor"]}> ({
^bb0(%a: i32, %out: i32):
  %zero = arith.constant 0 : i32
  %below = arith.cmpi slt, %a, %zero : i32
  %r = arith.select %below, %zero, %a : i32
  linalg.yield %r : i32
}) : () -> ()

// Copies, converting the element type where the result's differs.
"epitome.lowering"() <{op = "torch.aten.broadcast_to", element = "float", operands = ["tensor", "ignore"]}> ({
^bb0(%a: f32, %out: f32):
  linalg.yield %a : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.broadcast_to", element = "int", operands = ["tensor", "ignore"]}> ({
^bb0(%a: i32, %out: i32):
  linalg.yield %a : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.expand", element = "float", operands = ["tensor", "ignore", "ignore"]}> ({
^bb0(%a: f32, %out: f32):
  linalg.yield %a : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.to.dtype", element = "float", operands = ["tensor", "ignore", "ignore", "ignore", "ignore"]}> ({
^bb0(%a: f32, %out: f32):
  linalg.yield %a : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.to.dtype", element = "int", operands = ["tensor", "ignore", "ignore", "ignore", "ignore"]}> ({
^bb0(%a: i32, %out: i32):
  linalg.yield %a : i32
}) : () -> ()

// Moving elements: the maps come from the operands.
"epitome.lowering"() <{op = "torch.aten.permute", element = "float", operands = ["tensor", "perm"]}> ({
^bb0(%a: f32, %out: f32):
  linalg.yield %a : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.permute", element = "int", operands = ["tensor", "perm"]}> ({
^bb0(%a: i32, %out: i32):
  linalg.yield %a : i32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.transpose.int", element = "float", operands = ["tensor", "swap", "swap"]}> ({
^bb0(%a: f32, %out: f32):
  linalg.yield %a : f32
}) : () -> ()

// Matrix products: the sum over d2 of a[d0, d2] * b[d2, d1].
"epitome.lowering"() <{op = "torch.aten.mm", element = "float", operands = ["tensor", "tensor"],
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>, affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"]}> ({
^bb0(%a: f32, %b: f32, %acc: f32):
  %p = arith.mulf %a, %b : f32
  %s = arith.addf %acc, %p : f32
  linalg.yield %s : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.mm", element = "int", operands = ["tensor", "tensor"],
    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>, affine_map<(d0, d1, d2) -> (d0, d1)>],
    iterator_types = ["parallel", "parallel", "reduction"]}> ({
^bb0(%a: i32, %b: i32, %acc: i32):
  %p = arith.muli %a, %b : i32
  %s = arith.addi %acc, %p : i32
  linalg.yield %s : i32
}) : () -> ()

// Two-dimensional convolution, NCHW, one group: the output starts as the
// bias, and the input is padded with zeros. The symbols are the strides
// and dilations.
"epitome.lowering"() <{op = "torch.aten.convolution", element = "float",
    operands = ["tensor", "tensor", "init", "list", "list", "list", "false", "ignore", "1"],
    indexing_maps = [affine_map<(d0, d1, d2, d3, d4, d5, d6)[s0, s1, s2, s3] -> (d0, d4, d2 * s0 + d5 * s2, d3 * s1 + d6 * s3)>,
                     affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d1, d4, d5, d6)>,
                     affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>],
    iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"],
    symbols = [[3, 0], [3, 1], [5, 0], [5, 1]], pad = [0, 4],
    init_map = affine_map<(d0, d1, d2, d3) -> (d1)>}> ({
^bb0(%x: f32, %w: f32, %acc: f32):
  %p = arith.mulf %x, %w : f32
  %s = arith.addf %acc, %p : f32
  linalg.yield %s : f32
}) : () -> ()

// Sums over some dimensions, or all.
"epitome.lowering"() <{op = "torch.aten.sum.dim_IntList", element = "float", operands = ["tensor", "dims", "keepdim", "ignore"]}> ({
^bb0(%a: f32, %acc: f32):
  %s = arith.addf %acc, %a : f32
  linalg.yield %s : f32
}) : () -> ()

"epitome.lowering"() <{op = "torch.aten.sum.dim_IntList", element = "int", operands = ["tensor", "dims", "keepdim", "ignore"]}> ({
^bb0(%a: i32, %acc: i32):
  %s = arith.addi %acc, %a : i32
  linalg.yield %s : i32
}) : () -> ()
