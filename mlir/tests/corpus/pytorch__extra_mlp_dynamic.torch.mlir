#map = affine_map<()[s0] -> (s0, 4)>
#map1 = affine_map<()[s0] -> (s0, 8)>
#map2 = affine_map<()[s0] -> (s0, 2)>
"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[?,4],f32>) -> !torch.vtensor<[?,2],f32>, sym_name = "mlp_dyn"}> ({
  ^bb0(%arg0: !torch.vtensor<[?,4],f32>):
    %0 = "torch.constant.int"() <{value = 2 : i64}> : () -> !torch.int
    %1 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32>
    %2 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>}> : () -> !torch.vtensor<[2,8],f32>
    %3 = "torch.constant.int"() <{value = 8 : i64}> : () -> !torch.int
    %4 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>}> : () -> !torch.vtensor<[8],f32>
    %5 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %6 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>}> : () -> !torch.vtensor<[8,4],f32>
    %7 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %8 = "torch.symbolic_int"() <{max_val = 9223372036854775807 : i64, min_val = 0 : i64, symbol_name = "s77"}> : () -> !torch.int
    "torch.bind_symbolic_shape"(%arg0, %8) <{shape_expressions = #map}> : (!torch.vtensor<[?,4],f32>, !torch.int) -> ()
    %9 = "torch.aten.size.int"(%arg0, %7) : (!torch.vtensor<[?,4],f32>, !torch.int) -> !torch.int
    %10 = "torch.prim.ListConstruct"(%5, %7) : (!torch.int, !torch.int) -> !torch.list<int>
    %11 = "torch.aten.permute"(%6, %10) : (!torch.vtensor<[8,4],f32>, !torch.list<int>) -> !torch.vtensor<[4,8],f32>
    %12 = "torch.aten.mm"(%arg0, %11) : (!torch.vtensor<[?,4],f32>, !torch.vtensor<[4,8],f32>) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%12, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %13 = "torch.aten.mul.Scalar"(%12, %5) : (!torch.vtensor<[?,8],f32>, !torch.int) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%13, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %14 = "torch.prim.ListConstruct"(%9, %3) : (!torch.int, !torch.int) -> !torch.list<int>
    %15 = "torch.aten.broadcast_to"(%4, %14) : (!torch.vtensor<[8],f32>, !torch.list<int>) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%15, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %16 = "torch.aten.mul.Scalar"(%15, %5) : (!torch.vtensor<[?,8],f32>, !torch.int) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%16, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %17 = "torch.aten.add.Tensor"(%13, %16, %5) : (!torch.vtensor<[?,8],f32>, !torch.vtensor<[?,8],f32>, !torch.int) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%17, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %18 = "torch.aten.relu"(%17) : (!torch.vtensor<[?,8],f32>) -> !torch.vtensor<[?,8],f32>
    "torch.bind_symbolic_shape"(%18, %8) <{shape_expressions = #map1}> : (!torch.vtensor<[?,8],f32>, !torch.int) -> ()
    %19 = "torch.prim.ListConstruct"(%5, %7) : (!torch.int, !torch.int) -> !torch.list<int>
    %20 = "torch.aten.permute"(%2, %19) : (!torch.vtensor<[2,8],f32>, !torch.list<int>) -> !torch.vtensor<[8,2],f32>
    %21 = "torch.aten.mm"(%18, %20) : (!torch.vtensor<[?,8],f32>, !torch.vtensor<[8,2],f32>) -> !torch.vtensor<[?,2],f32>
    "torch.bind_symbolic_shape"(%21, %8) <{shape_expressions = #map2}> : (!torch.vtensor<[?,2],f32>, !torch.int) -> ()
    %22 = "torch.aten.mul.Scalar"(%21, %5) : (!torch.vtensor<[?,2],f32>, !torch.int) -> !torch.vtensor<[?,2],f32>
    "torch.bind_symbolic_shape"(%22, %8) <{shape_expressions = #map2}> : (!torch.vtensor<[?,2],f32>, !torch.int) -> ()
    %23 = "torch.prim.ListConstruct"(%9, %0) : (!torch.int, !torch.int) -> !torch.list<int>
    %24 = "torch.aten.broadcast_to"(%1, %23) : (!torch.vtensor<[2],f32>, !torch.list<int>) -> !torch.vtensor<[?,2],f32>
    "torch.bind_symbolic_shape"(%24, %8) <{shape_expressions = #map2}> : (!torch.vtensor<[?,2],f32>, !torch.int) -> ()
    %25 = "torch.aten.mul.Scalar"(%24, %5) : (!torch.vtensor<[?,2],f32>, !torch.int) -> !torch.vtensor<[?,2],f32>
    "torch.bind_symbolic_shape"(%25, %8) <{shape_expressions = #map2}> : (!torch.vtensor<[?,2],f32>, !torch.int) -> ()
    %26 = "torch.aten.add.Tensor"(%22, %25, %5) : (!torch.vtensor<[?,2],f32>, !torch.vtensor<[?,2],f32>, !torch.int) -> !torch.vtensor<[?,2],f32>
    "torch.bind_symbolic_shape"(%26, %8) <{shape_expressions = #map2}> : (!torch.vtensor<[?,2],f32>, !torch.int) -> ()
    "func.return"(%26) : (!torch.vtensor<[?,2],f32>) -> ()
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

