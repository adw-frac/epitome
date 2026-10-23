module {
  func.func @dtypes(%arg0: !torch.vtensor<[2],i1>, %arg1: !torch.vtensor<[2],si64>, %arg2: !torch.vtensor<[2],ui8>, %arg3: !torch.vtensor<[2],f16>, %arg4: !torch.vtensor<[2],bf16>, %arg5: !torch.vtensor<[],f64>) -> (!torch.vtensor<[],si64>, !torch.vtensor<[2],si64>, !torch.vtensor<[2],ui8>, !torch.vtensor<[2],f16>, !torch.vtensor<[2],bf16>, !torch.vtensor<[],f64>) {
    %0 = torch.prim.ListConstruct  : () -> !torch.list<int>
    %false = torch.constant.bool false
    %none = torch.constant.none
    %1 = torch.aten.sum.dim_IntList %arg0, %0, %false, %none : !torch.vtensor<[2],i1>, !torch.list<int>, !torch.bool, !torch.none -> !torch.vtensor<[],si64>
    %int1 = torch.constant.int 1
    %int1_0 = torch.constant.int 1
    %2 = torch.aten.add.Scalar %arg1, %int1, %int1_0 : !torch.vtensor<[2],si64>, !torch.int, !torch.int -> !torch.vtensor<[2],si64>
    %int2 = torch.constant.int 2
    %3 = torch.aten.mul.Scalar %arg3, %int2 : !torch.vtensor<[2],f16>, !torch.int -> !torch.vtensor<[2],f16>
    return %1, %2, %arg2, %3, %arg4, %arg5 : !torch.vtensor<[],si64>, !torch.vtensor<[2],si64>, !torch.vtensor<[2],ui8>, !torch.vtensor<[2],f16>, !torch.vtensor<[2],bf16>, !torch.vtensor<[],f64>
  }
}
