"builtin.module"() ({
  "func.func"() <{function_type = (tensor<32x8xi8>, tensor<8x8xi8>) -> tensor<32x8xi32>, sym_name = "int8matmul"}> ({
  ^bb0(%arg0: tensor<32x8xi8>, %arg1: tensor<8x8xi8>):
    %0 = "tosa.const"() <{values = dense<0> : tensor<1xi8>}> : () -> tensor<1xi8>
    %1 = "tosa.const_shape"() <{values = dense<[1, 32, 8]> : tensor<3xindex>}> : () -> !tosa.shape<3>
    %2 = "tosa.const_shape"() <{values = dense<[1, 8, 8]> : tensor<3xindex>}> : () -> !tosa.shape<3>
    %3 = "tosa.const_shape"() <{values = dense<[32, 8]> : tensor<2xindex>}> : () -> !tosa.shape<2>
    %4 = "tosa.reshape"(%arg0, %1) : (tensor<32x8xi8>, !tosa.shape<3>) -> tensor<1x32x8xi8>
    %5 = "tosa.reshape"(%arg1, %2) : (tensor<8x8xi8>, !tosa.shape<3>) -> tensor<1x8x8xi8>
    %6 = "tosa.matmul"(%4, %5, %0, %0) : (tensor<1x32x8xi8>, tensor<1x8x8xi8>, tensor<1xi8>, tensor<1xi8>) -> tensor<1x32x8xi32>
    %7 = "tosa.reshape"(%6, %3) : (tensor<1x32x8xi32>, !tosa.shape<2>) -> tensor<32x8xi32>
    "func.return"(%7) : (tensor<32x8xi32>) -> ()
  }) : () -> ()
}) : () -> ()

