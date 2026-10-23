"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[1,1,5,5],f32>) -> !torch.vtensor<[1,2,5,5],f32>, sym_name = "conv2d"}> ({
  ^bb0(%arg0: !torch.vtensor<[1,1,5,5],f32>):
    %0 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>}> : () -> !torch.vtensor<[2,1,3,3],f32>
    %1 = "torch.vtensor.literal"() <{value = dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>}> : () -> !torch.vtensor<[2],f32>
    %2 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %3 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %4 = "torch.prim.ListConstruct"(%2, %3) : (!torch.int, !torch.int) -> !torch.list<int>
    %5 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %6 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %7 = "torch.prim.ListConstruct"(%5, %6) : (!torch.int, !torch.int) -> !torch.list<int>
    %8 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %9 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %10 = "torch.prim.ListConstruct"(%8, %9) : (!torch.int, !torch.int) -> !torch.list<int>
    %11 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool
    %12 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %13 = "torch.constant.int"() <{value = 0 : i64}> : () -> !torch.int
    %14 = "torch.prim.ListConstruct"(%12, %13) : (!torch.int, !torch.int) -> !torch.list<int>
    %15 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %16 = "torch.aten.convolution"(%arg0, %0, %1, %4, %7, %10, %11, %14, %15) : (!torch.vtensor<[1,1,5,5],f32>, !torch.vtensor<[2,1,3,3],f32>, !torch.vtensor<[2],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,2,5,5],f32>
    "func.return"(%16) : (!torch.vtensor<[1,2,5,5],f32>) -> ()
  }) : () -> ()
}) : () -> ()

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE",
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE"
    }
  }
#-}

