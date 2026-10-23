"builtin.module"() ({
  "func.func"() <{function_type = (!torch.vtensor<[2],i1>, !torch.vtensor<[2],si64>, !torch.vtensor<[2],ui8>, !torch.vtensor<[2],f16>, !torch.vtensor<[2],bf16>, !torch.vtensor<[],f64>) -> (!torch.vtensor<[],si64>, !torch.vtensor<[2],si64>, !torch.vtensor<[2],ui8>, !torch.vtensor<[2],f16>, !torch.vtensor<[2],bf16>, !torch.vtensor<[],f64>), sym_name = "dtypes"}> ({
  ^bb0(%arg0: !torch.vtensor<[2],i1>, %arg1: !torch.vtensor<[2],si64>, %arg2: !torch.vtensor<[2],ui8>, %arg3: !torch.vtensor<[2],f16>, %arg4: !torch.vtensor<[2],bf16>, %arg5: !torch.vtensor<[],f64>):
    %0 = "torch.prim.ListConstruct"() : () -> !torch.list<int>
    %1 = "torch.constant.bool"() <{value = false}> : () -> !torch.bool
    %2 = "torch.constant.none"() : () -> !torch.none
    %3 = "torch.aten.sum.dim_IntList"(%arg0, %0, %1, %2) : (!torch.vtensor<[2],i1>, !torch.list<int>, !torch.bool, !torch.none) -> !torch.vtensor<[],si64>
    %4 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %5 = "torch.constant.int"() <{value = 1 : i64}> : () -> !torch.int
    %6 = "torch.aten.add.Scalar"(%arg1, %4, %5) : (!torch.vtensor<[2],si64>, !torch.int, !torch.int) -> !torch.vtensor<[2],si64>
    %7 = "torch.constant.int"() <{value = 2 : i64}> : () -> !torch.int
    %8 = "torch.aten.mul.Scalar"(%arg3, %7) : (!torch.vtensor<[2],f16>, !torch.int) -> !torch.vtensor<[2],f16>
    "func.return"(%3, %6, %arg2, %8, %arg4, %arg5) : (!torch.vtensor<[],si64>, !torch.vtensor<[2],si64>, !torch.vtensor<[2],ui8>, !torch.vtensor<[2],f16>, !torch.vtensor<[2],bf16>, !torch.vtensor<[],f64>) -> ()
  }) : () -> ()
}) : () -> ()

