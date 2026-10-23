"builtin.module"() ({
  "func.func"() <{function_type = (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>, sym_name = "qmatmul"}> ({
  ^bb0(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>):
    %0 = "tosa.const"() <{values = dense<0> : tensor<1xi8>}> : () -> tensor<1xi8>
    %1 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32>
    %2 = "tosa.const_shape"() <{values = dense<[1, 2, 3]> : tensor<3xindex>}> : () -> !tosa.shape<3>
    %3 = "tosa.const_shape"() <{values = dense<[1, 3, 4]> : tensor<3xindex>}> : () -> !tosa.shape<3>
    %4 = "tosa.const_shape"() <{values = dense<[2, 4]> : tensor<2xindex>}> : () -> !tosa.shape<2>
    %5 = "tosa.const"() <{values = dense<2.000000e+01> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %6 = "tosa.const"() <{values = dense<5.000000e-01> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %7 = "tosa.const"() <{values = dense<2.000000e+00> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %8 = "tosa.const"() <{values = dense<3.000000e+00> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %9 = "tosa.const"() <{values = dense<1.000000e+01> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %10 = "tosa.const"() <{values = dense<3> : tensor<1x1xi32>}> : () -> tensor<1x1xi32>
    %11 = "tosa.const"() <{values = dense<5.000000e-02> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %12 = "tosa.const"() <{values = dense<1.000000e-01> : tensor<1x1xf32>}> : () -> tensor<1x1xf32>
    %13 = "tosa.mul"(%arg0, %5, %0) : (tensor<2x3xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<2x3xf32>
    %14 = "tosa.floor"(%13) : (tensor<2x3xf32>) -> tensor<2x3xf32>
    %15 = "tosa.sub"(%13, %14) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
    %16 = "tosa.ceil"(%13) : (tensor<2x3xf32>) -> tensor<2x3xf32>
    %17 = "tosa.mul"(%14, %6, %0) : (tensor<2x3xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<2x3xf32>
    %18 = "tosa.floor"(%17) : (tensor<2x3xf32>) -> tensor<2x3xf32>
    %19 = "tosa.mul"(%18, %7, %0) : (tensor<2x3xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<2x3xf32>
    %20 = "tosa.equal"(%14, %19) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xi1>
    %21 = "tosa.equal"(%15, %6) : (tensor<2x3xf32>, tensor<1x1xf32>) -> tensor<2x3xi1>
    %22 = "tosa.greater"(%6, %15) : (tensor<1x1xf32>, tensor<2x3xf32>) -> tensor<2x3xi1>
    %23 = "tosa.logical_and"(%21, %20) : (tensor<2x3xi1>, tensor<2x3xi1>) -> tensor<2x3xi1>
    %24 = "tosa.logical_or"(%22, %23) : (tensor<2x3xi1>, tensor<2x3xi1>) -> tensor<2x3xi1>
    %25 = "tosa.select"(%24, %14, %16) : (tensor<2x3xi1>, tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
    %26 = "tosa.add"(%25, %8) : (tensor<2x3xf32>, tensor<1x1xf32>) -> tensor<2x3xf32>
    %27 = "tosa.clamp"(%26) <{max_val = 1.270000e+02 : f32, min_val = -1.280000e+02 : f32, nan_mode = #tosa.nan_mode<PROPAGATE>}> : (tensor<2x3xf32>) -> tensor<2x3xf32>
    %28 = "tosa.cast"(%27) : (tensor<2x3xf32>) -> tensor<2x3xi8>
    %29 = "tosa.mul"(%arg1, %9, %0) : (tensor<3x4xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<3x4xf32>
    %30 = "tosa.floor"(%29) : (tensor<3x4xf32>) -> tensor<3x4xf32>
    %31 = "tosa.sub"(%29, %30) : (tensor<3x4xf32>, tensor<3x4xf32>) -> tensor<3x4xf32>
    %32 = "tosa.ceil"(%29) : (tensor<3x4xf32>) -> tensor<3x4xf32>
    %33 = "tosa.mul"(%30, %6, %0) : (tensor<3x4xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<3x4xf32>
    %34 = "tosa.floor"(%33) : (tensor<3x4xf32>) -> tensor<3x4xf32>
    %35 = "tosa.mul"(%34, %7, %0) : (tensor<3x4xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<3x4xf32>
    %36 = "tosa.equal"(%30, %35) : (tensor<3x4xf32>, tensor<3x4xf32>) -> tensor<3x4xi1>
    %37 = "tosa.equal"(%31, %6) : (tensor<3x4xf32>, tensor<1x1xf32>) -> tensor<3x4xi1>
    %38 = "tosa.greater"(%6, %31) : (tensor<1x1xf32>, tensor<3x4xf32>) -> tensor<3x4xi1>
    %39 = "tosa.logical_and"(%37, %36) : (tensor<3x4xi1>, tensor<3x4xi1>) -> tensor<3x4xi1>
    %40 = "tosa.logical_or"(%38, %39) : (tensor<3x4xi1>, tensor<3x4xi1>) -> tensor<3x4xi1>
    %41 = "tosa.select"(%40, %30, %32) : (tensor<3x4xi1>, tensor<3x4xf32>, tensor<3x4xf32>) -> tensor<3x4xf32>
    %42 = "tosa.clamp"(%41) <{max_val = 1.270000e+02 : f32, min_val = -1.280000e+02 : f32, nan_mode = #tosa.nan_mode<PROPAGATE>}> : (tensor<3x4xf32>) -> tensor<3x4xf32>
    %43 = "tosa.cast"(%42) : (tensor<3x4xf32>) -> tensor<3x4xi8>
    %44 = "tosa.cast"(%28) : (tensor<2x3xi8>) -> tensor<2x3xi32>
    %45 = "tosa.sub"(%44, %10) : (tensor<2x3xi32>, tensor<1x1xi32>) -> tensor<2x3xi32>
    %46 = "tosa.cast"(%45) : (tensor<2x3xi32>) -> tensor<2x3xf32>
    %47 = "tosa.mul"(%46, %11, %0) : (tensor<2x3xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<2x3xf32>
    %48 = "tosa.cast"(%43) : (tensor<3x4xi8>) -> tensor<3x4xf32>
    %49 = "tosa.mul"(%48, %12, %0) : (tensor<3x4xf32>, tensor<1x1xf32>, tensor<1xi8>) -> tensor<3x4xf32>
    %50 = "tosa.reshape"(%47, %2) : (tensor<2x3xf32>, !tosa.shape<3>) -> tensor<1x2x3xf32>
    %51 = "tosa.reshape"(%49, %3) : (tensor<3x4xf32>, !tosa.shape<3>) -> tensor<1x3x4xf32>
    %52 = "tosa.matmul"(%50, %51, %1, %1) : (tensor<1x2x3xf32>, tensor<1x3x4xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x2x4xf32>
    %53 = "tosa.reshape"(%52, %4) : (tensor<1x2x4xf32>, !tosa.shape<2>) -> tensor<2x4xf32>
    "func.return"(%53) : (tensor<2x4xf32>) -> ()
  }) : () -> ()
}) : () -> ()

