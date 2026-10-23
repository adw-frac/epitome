; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@__constant_2xf32 = private constant [2 x float] [float f0xBDEED1D0, float f0xBE8BE1D2], align 64
@__constant_2x1x3x3xf32 = private constant [2 x [1 x [3 x [3 x float]]]] [[1 x [3 x [3 x float]]] [[3 x [3 x float]] [[3 x float] [float f0xBE0BC94E, float f0x3E4A8A20, float f0xBE4FB6F6], [3 x float] [float f0x3E9ADB9B, float f0x3E69EA6B, float f0xBE8FEB98], [3 x float] [float f0xBDA9E7B0, float f0x3C766E00, float f0x3D473420]]], [1 x [3 x [3 x float]]] [[3 x [3 x float]] [[3 x float] [float f0x3DA1E936, float f0x3E05F2E8, float f0x3CA39140], [3 x float] [float f0xBE268BDE, float f0x3E2183E3, float f0xBEA3B63A], [3 x float] [float f0xBE4A4F80, float f0xBDAAE450, float f0xBE26449E]]]], align 64

declare void @memrefCopy(i64, ptr, ptr)

declare ptr @malloc(i64)

define { ptr, ptr, i64, [4 x i64], [4 x i64] } @conv2d(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10) {
  %12 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %0, 0
  %13 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %12, ptr %1, 1
  %14 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %13, i64 %2, 2
  %15 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %14, i64 %3, 3, 0
  %16 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %15, i64 %7, 4, 0
  %17 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %16, i64 %4, 3, 1
  %18 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %17, i64 %8, 4, 1
  %19 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %18, i64 %5, 3, 2
  %20 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %19, i64 %9, 4, 2
  %21 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %20, i64 %6, 3, 3
  %22 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %21, i64 %10, 4, 3
  %23 = call ptr @malloc(i64 260)
  %24 = ptrtoint ptr %23 to i64
  %25 = add i64 %24, 63
  %26 = urem i64 %25, 64
  %27 = sub i64 %25, %26
  %28 = inttoptr i64 %27 to ptr
  %29 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %23, 0
  %30 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %29, ptr %28, 1
  %31 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %30, i64 0, 2
  %32 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %31, i64 1, 3, 0
  %33 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %32, i64 1, 3, 1
  %34 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %33, i64 7, 3, 2
  %35 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %34, i64 7, 3, 3
  %36 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %35, i64 49, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %36, i64 49, 4, 1
  %38 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %37, i64 7, 4, 2
  %39 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %38, i64 1, 4, 3
  br label %40

40:                                               ; preds = %69, %11
  %41 = phi i64 [ %70, %69 ], [ 0, %11 ]
  %42 = icmp slt i64 %41, 1
  br i1 %42, label %43, label %71

43:                                               ; preds = %40
  br label %44

44:                                               ; preds = %67, %43
  %45 = phi i64 [ %68, %67 ], [ 0, %43 ]
  %46 = icmp slt i64 %45, 1
  br i1 %46, label %47, label %69

47:                                               ; preds = %44
  br label %48

48:                                               ; preds = %65, %47
  %49 = phi i64 [ %66, %65 ], [ 0, %47 ]
  %50 = icmp slt i64 %49, 7
  br i1 %50, label %51, label %67

51:                                               ; preds = %48
  br label %52

52:                                               ; preds = %55, %51
  %53 = phi i64 [ %64, %55 ], [ 0, %51 ]
  %54 = icmp slt i64 %53, 7
  br i1 %54, label %55, label %65

55:                                               ; preds = %52
  %56 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %39, 1
  %57 = mul nuw nsw i64 %41, 49
  %58 = mul nuw nsw i64 %45, 49
  %59 = add nuw nsw i64 %57, %58
  %60 = mul nuw nsw i64 %49, 7
  %61 = add nuw nsw i64 %59, %60
  %62 = add nuw nsw i64 %61, %53
  %63 = getelementptr inbounds nuw float, ptr %56, i64 %62
  store float 0.000000e+00, ptr %63, align 4
  %64 = add i64 %53, 1
  br label %52

65:                                               ; preds = %52
  %66 = add i64 %49, 1
  br label %48

67:                                               ; preds = %48
  %68 = add i64 %45, 1
  br label %44

69:                                               ; preds = %44
  %70 = add i64 %41, 1
  br label %40

71:                                               ; preds = %40
  %72 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %39, 0
  %73 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %39, 1
  %74 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %72, 0
  %75 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %74, ptr %73, 1
  %76 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %75, i64 8, 2
  %77 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %76, i64 1, 3, 0
  %78 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %77, i64 49, 4, 0
  %79 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %78, i64 1, 3, 1
  %80 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %79, i64 49, 4, 1
  %81 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %80, i64 5, 3, 2
  %82 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %81, i64 7, 4, 2
  %83 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %82, i64 5, 3, 3
  %84 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %83, i64 1, 4, 3
  %85 = call ptr @llvm.stacksave.p0()
  %86 = alloca { ptr, ptr, i64, [4 x i64], [4 x i64] }, i64 1, align 8
  store { ptr, ptr, i64, [4 x i64], [4 x i64] } %22, ptr %86, align 8
  %87 = insertvalue { i64, ptr } { i64 4, ptr poison }, ptr %86, 1
  %88 = alloca { ptr, ptr, i64, [4 x i64], [4 x i64] }, i64 1, align 8
  store { ptr, ptr, i64, [4 x i64], [4 x i64] } %84, ptr %88, align 8
  %89 = insertvalue { i64, ptr } { i64 4, ptr poison }, ptr %88, 1
  %90 = alloca { i64, ptr }, i64 1, align 8
  store { i64, ptr } %87, ptr %90, align 8
  %91 = alloca { i64, ptr }, i64 1, align 8
  store { i64, ptr } %89, ptr %91, align 8
  call void @memrefCopy(i64 4, ptr %90, ptr %91)
  call void @llvm.stackrestore.p0(ptr %85)
  %92 = call ptr @malloc(i64 264)
  %93 = ptrtoint ptr %92 to i64
  %94 = add i64 %93, 63
  %95 = urem i64 %94, 64
  %96 = sub i64 %94, %95
  %97 = inttoptr i64 %96 to ptr
  %98 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %92, 0
  %99 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %98, ptr %97, 1
  %100 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %99, i64 0, 2
  %101 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %100, i64 1, 3, 0
  %102 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, i64 2, 3, 1
  %103 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %102, i64 5, 3, 2
  %104 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %103, i64 5, 3, 3
  %105 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %104, i64 50, 4, 0
  %106 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %105, i64 25, 4, 1
  %107 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %106, i64 5, 4, 2
  %108 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %107, i64 1, 4, 3
  br label %109

109:                                              ; preds = %140, %71
  %110 = phi i64 [ %141, %140 ], [ 0, %71 ]
  %111 = icmp slt i64 %110, 1
  br i1 %111, label %112, label %142

112:                                              ; preds = %109
  br label %113

113:                                              ; preds = %138, %112
  %114 = phi i64 [ %139, %138 ], [ 0, %112 ]
  %115 = icmp slt i64 %114, 2
  br i1 %115, label %116, label %140

116:                                              ; preds = %113
  br label %117

117:                                              ; preds = %136, %116
  %118 = phi i64 [ %137, %136 ], [ 0, %116 ]
  %119 = icmp slt i64 %118, 5
  br i1 %119, label %120, label %138

120:                                              ; preds = %117
  br label %121

121:                                              ; preds = %124, %120
  %122 = phi i64 [ %135, %124 ], [ 0, %120 ]
  %123 = icmp slt i64 %122, 5
  br i1 %123, label %124, label %136

124:                                              ; preds = %121
  %125 = getelementptr inbounds nuw float, ptr @__constant_2xf32, i64 %114
  %126 = load float, ptr %125, align 4
  %127 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %108, 1
  %128 = mul nuw nsw i64 %110, 50
  %129 = mul nuw nsw i64 %114, 25
  %130 = add nuw nsw i64 %128, %129
  %131 = mul nuw nsw i64 %118, 5
  %132 = add nuw nsw i64 %130, %131
  %133 = add nuw nsw i64 %132, %122
  %134 = getelementptr inbounds nuw float, ptr %127, i64 %133
  store float %126, ptr %134, align 4
  %135 = add i64 %122, 1
  br label %121

136:                                              ; preds = %121
  %137 = add i64 %118, 1
  br label %117

138:                                              ; preds = %117
  %139 = add i64 %114, 1
  br label %113

140:                                              ; preds = %113
  %141 = add i64 %110, 1
  br label %109

142:                                              ; preds = %109
  br label %143

143:                                              ; preds = %220, %142
  %144 = phi i64 [ %221, %220 ], [ 0, %142 ]
  %145 = icmp slt i64 %144, 1
  br i1 %145, label %146, label %222

146:                                              ; preds = %143
  br label %147

147:                                              ; preds = %218, %146
  %148 = phi i64 [ %219, %218 ], [ 0, %146 ]
  %149 = icmp slt i64 %148, 2
  br i1 %149, label %150, label %220

150:                                              ; preds = %147
  br label %151

151:                                              ; preds = %216, %150
  %152 = phi i64 [ %217, %216 ], [ 0, %150 ]
  %153 = icmp slt i64 %152, 5
  br i1 %153, label %154, label %218

154:                                              ; preds = %151
  br label %155

155:                                              ; preds = %214, %154
  %156 = phi i64 [ %215, %214 ], [ 0, %154 ]
  %157 = icmp slt i64 %156, 5
  br i1 %157, label %158, label %216

158:                                              ; preds = %155
  br label %159

159:                                              ; preds = %212, %158
  %160 = phi i64 [ %213, %212 ], [ 0, %158 ]
  %161 = icmp slt i64 %160, 1
  br i1 %161, label %162, label %214

162:                                              ; preds = %159
  br label %163

163:                                              ; preds = %210, %162
  %164 = phi i64 [ %211, %210 ], [ 0, %162 ]
  %165 = icmp slt i64 %164, 3
  br i1 %165, label %166, label %212

166:                                              ; preds = %163
  br label %167

167:                                              ; preds = %170, %166
  %168 = phi i64 [ %209, %170 ], [ 0, %166 ]
  %169 = icmp slt i64 %168, 3
  br i1 %169, label %170, label %210

170:                                              ; preds = %167
  %171 = add i64 %152, %164
  %172 = add i64 %156, %168
  %173 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %39, 1
  %174 = mul nuw nsw i64 %144, 49
  %175 = mul nuw nsw i64 %160, 49
  %176 = add nuw nsw i64 %174, %175
  %177 = mul nuw nsw i64 %171, 7
  %178 = add nuw nsw i64 %176, %177
  %179 = add nuw nsw i64 %178, %172
  %180 = getelementptr inbounds nuw float, ptr %173, i64 %179
  %181 = load float, ptr %180, align 4
  %182 = mul nuw nsw i64 %148, 9
  %183 = mul nuw nsw i64 %160, 9
  %184 = add nuw nsw i64 %182, %183
  %185 = mul nuw nsw i64 %164, 3
  %186 = add nuw nsw i64 %184, %185
  %187 = add nuw nsw i64 %186, %168
  %188 = getelementptr inbounds nuw float, ptr @__constant_2x1x3x3xf32, i64 %187
  %189 = load float, ptr %188, align 4
  %190 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %108, 1
  %191 = mul nuw nsw i64 %144, 50
  %192 = mul nuw nsw i64 %148, 25
  %193 = add nuw nsw i64 %191, %192
  %194 = mul nuw nsw i64 %152, 5
  %195 = add nuw nsw i64 %193, %194
  %196 = add nuw nsw i64 %195, %156
  %197 = getelementptr inbounds nuw float, ptr %190, i64 %196
  %198 = load float, ptr %197, align 4
  %199 = fmul float %181, %189
  %200 = fadd float %198, %199
  %201 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %108, 1
  %202 = mul nuw nsw i64 %144, 50
  %203 = mul nuw nsw i64 %148, 25
  %204 = add nuw nsw i64 %202, %203
  %205 = mul nuw nsw i64 %152, 5
  %206 = add nuw nsw i64 %204, %205
  %207 = add nuw nsw i64 %206, %156
  %208 = getelementptr inbounds nuw float, ptr %201, i64 %207
  store float %200, ptr %208, align 4
  %209 = add i64 %168, 1
  br label %167

210:                                              ; preds = %167
  %211 = add i64 %164, 1
  br label %163

212:                                              ; preds = %163
  %213 = add i64 %160, 1
  br label %159

214:                                              ; preds = %159
  %215 = add i64 %156, 1
  br label %155

216:                                              ; preds = %155
  %217 = add i64 %152, 1
  br label %151

218:                                              ; preds = %151
  %219 = add i64 %148, 1
  br label %147

220:                                              ; preds = %147
  %221 = add i64 %144, 1
  br label %143

222:                                              ; preds = %143
  ret { ptr, ptr, i64, [4 x i64], [4 x i64] } %108
}

define void @_mlir_ciface_conv2d(ptr %0, ptr %1) {
  %3 = load { ptr, ptr, i64, [4 x i64], [4 x i64] }, ptr %1, align 8
  %4 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 0
  %5 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 1
  %6 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 2
  %7 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 3, 0
  %8 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 3, 1
  %9 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 3, 2
  %10 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 3, 3
  %11 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 4, 0
  %12 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 4, 1
  %13 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 4, 2
  %14 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %3, 4, 3
  %15 = call { ptr, ptr, i64, [4 x i64], [4 x i64] } @conv2d(ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, i64 %14)
  store { ptr, ptr, i64, [4 x i64], [4 x i64] } %15, ptr %0, align 8
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #0

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
