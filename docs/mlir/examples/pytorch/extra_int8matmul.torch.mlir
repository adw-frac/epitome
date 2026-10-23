module {
  func.func @int8matmul(%arg0: !torch.vtensor<[32,8],si8>, %arg1: !torch.vtensor<[8,8],si8>) -> !torch.vtensor<[32,8],si32> {
    %0 = torch.aten.mm %arg0, %arg1 : !torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8> -> !torch.vtensor<[32,8],si32>
    return %0 : !torch.vtensor<[32,8],si32>
  }
}
