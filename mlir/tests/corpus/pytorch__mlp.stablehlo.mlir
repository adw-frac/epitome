"builtin.module"() ({
  "func.func"() <{function_type = (tensor<1x4xf32>) -> tensor<1x2xf32>, sym_name = "mlp"}> ({
  ^bb0(%arg0: tensor<1x4xf32>):
    %0 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> tensor<2xf32>
    %1 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> tensor<2x8xf32>
    %2 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> tensor<8xf32>
    %3 = "stablehlo.constant"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> tensor<8x4xf32>
    %4 = "stablehlo.constant"() <{value = dense<0.000000e+00> : tensor<1x8xf32>}> : () -> tensor<1x8xf32>
    %5 = "arith.constant"() <{value = dense<1> : tensor<1xi64>}> : () -> tensor<1xi64>
    %6 = "stablehlo.transpose"(%3) <{permutation = array<i64: 1, 0>}> : (tensor<8x4xf32>) -> tensor<4x8xf32>
    %7 = "stablehlo.dot_general"(%arg0, %6) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<1x4xf32>, tensor<4x8xf32>) -> tensor<1x8xf32>
    %8 = "stablehlo.convert"(%5) : (tensor<1xi64>) -> tensor<1xf32>
    %9 = "stablehlo.reshape"(%8) : (tensor<1xf32>) -> tensor<f32>
    %10 = "stablehlo.broadcast_in_dim"(%9) <{broadcast_dimensions = array<i64>}> : (tensor<f32>) -> tensor<1x8xf32>
    %11 = "stablehlo.multiply"(%7, %10) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
    %12 = "stablehlo.broadcast_in_dim"(%2) <{broadcast_dimensions = array<i64: 1>}> : (tensor<8xf32>) -> tensor<1x8xf32>
    %13 = "stablehlo.multiply"(%12, %10) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
    %14 = "stablehlo.add"(%11, %13) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
    %15 = "stablehlo.maximum"(%14, %4) : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
    %16 = "stablehlo.transpose"(%1) <{permutation = array<i64: 1, 0>}> : (tensor<2x8xf32>) -> tensor<8x2xf32>
    %17 = "stablehlo.dot_general"(%15, %16) <{dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>}> : (tensor<1x8xf32>, tensor<8x2xf32>) -> tensor<1x2xf32>
    %18 = "stablehlo.broadcast_in_dim"(%9) <{broadcast_dimensions = array<i64>}> : (tensor<f32>) -> tensor<1x2xf32>
    %19 = "stablehlo.multiply"(%17, %18) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32>
    %20 = "stablehlo.broadcast_in_dim"(%0) <{broadcast_dimensions = array<i64: 1>}> : (tensor<2xf32>) -> tensor<1x2xf32>
    %21 = "stablehlo.multiply"(%20, %18) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32>
    %22 = "stablehlo.add"(%19, %21) : (tensor<1x2xf32>, tensor<1x2xf32>) -> tensor<1x2xf32>
    "func.return"(%22) : (tensor<1x2xf32>) -> ()
  }) : () -> ()
}) : () -> ()

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E"
    }
  }
#-}

