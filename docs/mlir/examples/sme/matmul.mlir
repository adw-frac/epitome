// C[16, 20] = A[16, 4] B[4, 20], as torch-mlir writes a matmul: linalg on
// tensors, the output filled with zero first. The stages of its lowering,
// with matrix products on SME, are the files stage*.mlir, matmul.ll,
// matmul.opt.ll and matmul.s next to this one (see README.md).
"builtin.module"() ({
  "func.func"() <{function_type = (tensor<16x4xf32>, tensor<4x20xf32>) -> tensor<16x20xf32>, sym_name = "matmul"}> ({
  ^bb0(%a: tensor<16x4xf32>, %b: tensor<4x20xf32>):
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<16x20xf32>
    %f = "linalg.fill"(%zero, %e) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%x: f32, %y: f32):
      linalg.yield %x : f32
    }) : (f32, tensor<16x20xf32>) -> tensor<16x20xf32>
    %r = "linalg.matmul"(%a, %b, %f) <{operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%p: f32, %q: f32, %acc: f32):
      %m = arith.mulf %p, %q : f32
      %s = arith.addf %acc, %m : f32
      linalg.yield %s : f32
    }) : (tensor<16x4xf32>, tensor<4x20xf32>, tensor<16x20xf32>) -> tensor<16x20xf32>
    return %r : tensor<16x20xf32>
  }) : () -> ()
}) : () -> ()
