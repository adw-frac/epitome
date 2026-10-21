; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul_bias(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18) {
  %20 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %14, 0
  %21 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %20, ptr %15, 1
  %22 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, i64 %16, 2
  %23 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %22, i64 %17, 3, 0
  %24 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %23, i64 %18, 4, 0
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %7, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %8, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %9, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %10, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %12, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %11, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %13, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %0, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %1, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %2, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %3, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %5, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %4, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %6, 4, 1
  %39 = call ptr @malloc(i64 96)
  %40 = ptrtoint ptr %39 to i64
  %41 = add i64 %40, 63
  %42 = urem i64 %41, 64
  %43 = sub i64 %41, %42
  %44 = inttoptr i64 %43 to ptr
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %39, 0
  %46 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, ptr %44, 1
  %47 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, i64 0, 2
  %48 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %47, i64 2, 3, 0
  %49 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %48, i64 4, 3, 1
  %50 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %49, i64 4, 4, 0
  %51 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %50, i64 1, 4, 1
  br label %52

52:                                               ; preds = %65, %19
  %53 = phi i64 [ %66, %65 ], [ 0, %19 ]
  %54 = icmp slt i64 %53, 2
  br i1 %54, label %55, label %67

55:                                               ; preds = %52
  br label %56

56:                                               ; preds = %59, %55
  %57 = phi i64 [ %64, %59 ], [ 0, %55 ]
  %58 = icmp slt i64 %57, 4
  br i1 %58, label %59, label %65

59:                                               ; preds = %56
  %60 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, 1
  %61 = mul nuw nsw i64 %53, 4
  %62 = add nuw nsw i64 %61, %57
  %63 = getelementptr inbounds nuw float, ptr %60, i64 %62
  store float 0.000000e+00, ptr %63, align 4
  %64 = add i64 %57, 1
  br label %56

65:                                               ; preds = %56
  %66 = add i64 %53, 1
  br label %52

67:                                               ; preds = %52
  br label %68

68:                                               ; preds = %104, %67
  %69 = phi i64 [ %105, %104 ], [ 0, %67 ]
  %70 = icmp slt i64 %69, 2
  br i1 %70, label %71, label %106

71:                                               ; preds = %68
  br label %72

72:                                               ; preds = %102, %71
  %73 = phi i64 [ %103, %102 ], [ 0, %71 ]
  %74 = icmp slt i64 %73, 4
  br i1 %74, label %75, label %104

75:                                               ; preds = %72
  br label %76

76:                                               ; preds = %79, %75
  %77 = phi i64 [ %101, %79 ], [ 0, %75 ]
  %78 = icmp slt i64 %77, 3
  br i1 %78, label %79, label %102

79:                                               ; preds = %76
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %81 = mul nuw nsw i64 %69, 3
  %82 = add nuw nsw i64 %81, %77
  %83 = getelementptr inbounds nuw float, ptr %80, i64 %82
  %84 = load float, ptr %83, align 4
  %85 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, 1
  %86 = mul nuw nsw i64 %77, 4
  %87 = add nuw nsw i64 %86, %73
  %88 = getelementptr inbounds nuw float, ptr %85, i64 %87
  %89 = load float, ptr %88, align 4
  %90 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, 1
  %91 = mul nuw nsw i64 %69, 4
  %92 = add nuw nsw i64 %91, %73
  %93 = getelementptr inbounds nuw float, ptr %90, i64 %92
  %94 = load float, ptr %93, align 4
  %95 = fmul float %84, %89
  %96 = fadd float %94, %95
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, 1
  %98 = mul nuw nsw i64 %69, 4
  %99 = add nuw nsw i64 %98, %73
  %100 = getelementptr inbounds nuw float, ptr %97, i64 %99
  store float %96, ptr %100, align 4
  %101 = add i64 %77, 1
  br label %76

102:                                              ; preds = %76
  %103 = add i64 %73, 1
  br label %72

104:                                              ; preds = %72
  %105 = add i64 %69, 1
  br label %68

106:                                              ; preds = %68
  br label %107

107:                                              ; preds = %129, %106
  %108 = phi i64 [ %130, %129 ], [ 0, %106 ]
  %109 = icmp slt i64 %108, 2
  br i1 %109, label %110, label %131

110:                                              ; preds = %107
  br label %111

111:                                              ; preds = %114, %110
  %112 = phi i64 [ %128, %114 ], [ 0, %110 ]
  %113 = icmp slt i64 %112, 4
  br i1 %113, label %114, label %129

114:                                              ; preds = %111
  %115 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, 1
  %116 = mul nuw nsw i64 %108, 4
  %117 = add nuw nsw i64 %116, %112
  %118 = getelementptr inbounds nuw float, ptr %115, i64 %117
  %119 = load float, ptr %118, align 4
  %120 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %24, 1
  %121 = getelementptr inbounds nuw float, ptr %120, i64 %112
  %122 = load float, ptr %121, align 4
  %123 = fadd float %119, %122
  %124 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, 1
  %125 = mul nuw nsw i64 %108, 4
  %126 = add nuw nsw i64 %125, %112
  %127 = getelementptr inbounds nuw float, ptr %124, i64 %126
  store float %123, ptr %127, align 4
  %128 = add i64 %112, 1
  br label %111

129:                                              ; preds = %111
  %130 = add i64 %108, 1
  br label %107

131:                                              ; preds = %107
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %51
}

define void @_mlir_ciface_matmul_bias(ptr %0, ptr %1, ptr %2, ptr %3) {
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %1, align 8
  %6 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 0
  %7 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 1
  %8 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 2
  %9 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 3, 0
  %10 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 3, 1
  %11 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 4, 0
  %12 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %5, 4, 1
  %13 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %2, align 8
  %14 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 0
  %15 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 1
  %16 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 2
  %17 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 3, 0
  %18 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 3, 1
  %19 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 4, 0
  %20 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 4, 1
  %21 = load { ptr, ptr, i64, [1 x i64], [1 x i64] }, ptr %3, align 8
  %22 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, 0
  %23 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, 1
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, 2
  %25 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, 3, 0
  %26 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, 4, 0
  %27 = call { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul_bias(ptr %6, ptr %7, i64 %8, i64 %9, i64 %10, i64 %11, i64 %12, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20, ptr %22, ptr %23, i64 %24, i64 %25, i64 %26)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, ptr %0, align 8
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
