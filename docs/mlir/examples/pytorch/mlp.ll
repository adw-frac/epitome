; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@__constant_8x4xf32 = private constant [8 x [4 x float]] [[4 x float] [float -3.743410e-03, float f0x3E89545E, float f0xBED2B316, float f0xBEBC6680], [4 x float] [float f0xBE4532F4, float f0x3E094BEC, float f0xBC224F40, float f0x3ECAFACE], [4 x float] [float f0xBD35BF70, float f0x3E077B4C, float f0xBE1ABBAC, float f0xBDC94870], [4 x float] [float f0xBEF491B8, float f0xBEA98B52, float f0xBE530EE8, float f0x3C97BB00], [4 x float] [float f0x3E4A6960, float f0x3E999B18, float f0xBEAD8D8C, float f0xBE5EF4FC], [4 x float] [float f0x3E39F798, float f0x3ED4944E, float f0xBDD2BD48, float f0x3EBF915C], [4 x float] [float f0xBDA50D40, float f0x3D58B510, float f0x3EE7CD4A, float f0xBEED7BCE], [4 x float] [float f0xBEA12966, float f0xBE019EE0, float f0xBE4793DC, float f0x3EDD2F28]], align 64
@__constant_8xf32 = private constant [8 x float] [float f0xBEA5EF1A, float f0xBE6BB0C0, float f0xBEB2DA1A, float f0xBEEFC276, float f0xBE957004, float f0x3EDC0E9E, float f0x3E6476BC, float f0x3E782700], align 64
@__constant_2x8xf32 = private constant [2 x [8 x float]] [[8 x float] [float f0x3C985249, float f0xBE399C7B, float f0x3D75016E, float f0xBEA9044D, float f0xBE82CC68, float f0xBE3AA44C, float f0x3E646C87, float f0x3E54455D], [8 x float] [float f0xBE208FF6, float f0xBC5102F2, float f0x3E678BB3, float f0x3EB3F512, float f0x3E0FAFCB, float f0x3D43A2A6, float f0x3E72BDF2, float f0xBE552B52]], align 64
@__constant_2xf32 = private constant [2 x float] [float f0x3D86ED70, float f0xBE8C5865], align 64

declare ptr @malloc(i64)

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @mlp(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6) {
  %8 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %0, 0
  %9 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %8, ptr %1, 1
  %10 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %9, i64 %2, 2
  %11 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %10, i64 %3, 3, 0
  %12 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %11, i64 %5, 4, 0
  %13 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %12, i64 %4, 3, 1
  %14 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, i64 %6, 4, 1
  %15 = call ptr @malloc(i64 192)
  %16 = ptrtoint ptr %15 to i64
  %17 = add i64 %16, 63
  %18 = urem i64 %17, 64
  %19 = sub i64 %17, %18
  %20 = inttoptr i64 %19 to ptr
  %21 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %15, 0
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, ptr %20, 1
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, i64 0, 2
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 4, 3, 0
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 8, 3, 1
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 8, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 1, 4, 1
  br label %28

28:                                               ; preds = %45, %7
  %29 = phi i64 [ %46, %45 ], [ 0, %7 ]
  %30 = icmp slt i64 %29, 4
  br i1 %30, label %31, label %47

31:                                               ; preds = %28
  br label %32

32:                                               ; preds = %35, %31
  %33 = phi i64 [ %44, %35 ], [ 0, %31 ]
  %34 = icmp slt i64 %33, 8
  br i1 %34, label %35, label %45

35:                                               ; preds = %32
  %36 = mul nuw nsw i64 %33, 4
  %37 = add nuw nsw i64 %36, %29
  %38 = getelementptr inbounds nuw float, ptr @__constant_8x4xf32, i64 %37
  %39 = load float, ptr %38, align 4
  %40 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, 1
  %41 = mul nuw nsw i64 %29, 8
  %42 = add nuw nsw i64 %41, %33
  %43 = getelementptr inbounds nuw float, ptr %40, i64 %42
  store float %39, ptr %43, align 4
  %44 = add i64 %33, 1
  br label %32

45:                                               ; preds = %32
  %46 = add i64 %29, 1
  br label %28

47:                                               ; preds = %28
  %48 = call ptr @malloc(i64 96)
  %49 = ptrtoint ptr %48 to i64
  %50 = add i64 %49, 63
  %51 = urem i64 %50, 64
  %52 = sub i64 %50, %51
  %53 = inttoptr i64 %52 to ptr
  %54 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %48, 0
  %55 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, ptr %53, 1
  %56 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, i64 0, 2
  %57 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %56, i64 1, 3, 0
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %57, i64 8, 3, 1
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, i64 8, 4, 0
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 1, 4, 1
  %61 = call ptr @malloc(i64 96)
  %62 = ptrtoint ptr %61 to i64
  %63 = add i64 %62, 63
  %64 = urem i64 %63, 64
  %65 = sub i64 %63, %64
  %66 = inttoptr i64 %65 to ptr
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %61, 0
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, ptr %66, 1
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 0, 2
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, i64 1, 3, 0
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 8, 3, 1
  %72 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, i64 8, 4, 0
  %73 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %72, i64 1, 4, 1
  br label %74

74:                                               ; preds = %87, %47
  %75 = phi i64 [ %88, %87 ], [ 0, %47 ]
  %76 = icmp slt i64 %75, 1
  br i1 %76, label %77, label %89

77:                                               ; preds = %74
  br label %78

78:                                               ; preds = %81, %77
  %79 = phi i64 [ %86, %81 ], [ 0, %77 ]
  %80 = icmp slt i64 %79, 8
  br i1 %80, label %81, label %87

81:                                               ; preds = %78
  %82 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, 1
  %83 = mul nuw nsw i64 %75, 8
  %84 = add nuw nsw i64 %83, %79
  %85 = getelementptr inbounds nuw float, ptr %82, i64 %84
  store float 0.000000e+00, ptr %85, align 4
  %86 = add i64 %79, 1
  br label %78

87:                                               ; preds = %78
  %88 = add i64 %75, 1
  br label %74

89:                                               ; preds = %74
  br label %90

90:                                               ; preds = %126, %89
  %91 = phi i64 [ %127, %126 ], [ 0, %89 ]
  %92 = icmp slt i64 %91, 1
  br i1 %92, label %93, label %128

93:                                               ; preds = %90
  br label %94

94:                                               ; preds = %124, %93
  %95 = phi i64 [ %125, %124 ], [ 0, %93 ]
  %96 = icmp slt i64 %95, 8
  br i1 %96, label %97, label %126

97:                                               ; preds = %94
  br label %98

98:                                               ; preds = %101, %97
  %99 = phi i64 [ %123, %101 ], [ 0, %97 ]
  %100 = icmp slt i64 %99, 4
  br i1 %100, label %101, label %124

101:                                              ; preds = %98
  %102 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %14, 1
  %103 = mul nuw nsw i64 %91, 4
  %104 = add nuw nsw i64 %103, %99
  %105 = getelementptr inbounds nuw float, ptr %102, i64 %104
  %106 = load float, ptr %105, align 4
  %107 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, 1
  %108 = mul nuw nsw i64 %99, 8
  %109 = add nuw nsw i64 %108, %95
  %110 = getelementptr inbounds nuw float, ptr %107, i64 %109
  %111 = load float, ptr %110, align 4
  %112 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, 1
  %113 = mul nuw nsw i64 %91, 8
  %114 = add nuw nsw i64 %113, %95
  %115 = getelementptr inbounds nuw float, ptr %112, i64 %114
  %116 = load float, ptr %115, align 4
  %117 = fmul float %106, %111
  %118 = fadd float %116, %117
  %119 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, 1
  %120 = mul nuw nsw i64 %91, 8
  %121 = add nuw nsw i64 %120, %95
  %122 = getelementptr inbounds nuw float, ptr %119, i64 %121
  store float %118, ptr %122, align 4
  %123 = add i64 %99, 1
  br label %98

124:                                              ; preds = %98
  %125 = add i64 %95, 1
  br label %94

126:                                              ; preds = %94
  %127 = add i64 %91, 1
  br label %90

128:                                              ; preds = %90
  br label %129

129:                                              ; preds = %144, %128
  %130 = phi i64 [ %145, %144 ], [ 0, %128 ]
  %131 = icmp slt i64 %130, 1
  br i1 %131, label %132, label %146

132:                                              ; preds = %129
  br label %133

133:                                              ; preds = %136, %132
  %134 = phi i64 [ %143, %136 ], [ 0, %132 ]
  %135 = icmp slt i64 %134, 8
  br i1 %135, label %136, label %144

136:                                              ; preds = %133
  %137 = getelementptr inbounds nuw float, ptr @__constant_8xf32, i64 %134
  %138 = load float, ptr %137, align 4
  %139 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %140 = mul nuw nsw i64 %130, 8
  %141 = add nuw nsw i64 %140, %134
  %142 = getelementptr inbounds nuw float, ptr %139, i64 %141
  store float %138, ptr %142, align 4
  %143 = add i64 %134, 1
  br label %133

144:                                              ; preds = %133
  %145 = add i64 %130, 1
  br label %129

146:                                              ; preds = %129
  br label %147

147:                                              ; preds = %171, %146
  %148 = phi i64 [ %172, %171 ], [ 0, %146 ]
  %149 = icmp slt i64 %148, 1
  br i1 %149, label %150, label %173

150:                                              ; preds = %147
  br label %151

151:                                              ; preds = %154, %150
  %152 = phi i64 [ %170, %154 ], [ 0, %150 ]
  %153 = icmp slt i64 %152, 8
  br i1 %153, label %154, label %171

154:                                              ; preds = %151
  %155 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %73, 1
  %156 = mul nuw nsw i64 %148, 8
  %157 = add nuw nsw i64 %156, %152
  %158 = getelementptr inbounds nuw float, ptr %155, i64 %157
  %159 = load float, ptr %158, align 4
  %160 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %161 = mul nuw nsw i64 %148, 8
  %162 = add nuw nsw i64 %161, %152
  %163 = getelementptr inbounds nuw float, ptr %160, i64 %162
  %164 = load float, ptr %163, align 4
  %165 = fadd float %159, %164
  %166 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %167 = mul nuw nsw i64 %148, 8
  %168 = add nuw nsw i64 %167, %152
  %169 = getelementptr inbounds nuw float, ptr %166, i64 %168
  store float %165, ptr %169, align 4
  %170 = add i64 %152, 1
  br label %151

171:                                              ; preds = %151
  %172 = add i64 %148, 1
  br label %147

173:                                              ; preds = %147
  br label %174

174:                                              ; preds = %194, %173
  %175 = phi i64 [ %195, %194 ], [ 0, %173 ]
  %176 = icmp slt i64 %175, 1
  br i1 %176, label %177, label %196

177:                                              ; preds = %174
  br label %178

178:                                              ; preds = %181, %177
  %179 = phi i64 [ %193, %181 ], [ 0, %177 ]
  %180 = icmp slt i64 %179, 8
  br i1 %180, label %181, label %194

181:                                              ; preds = %178
  %182 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %183 = mul nuw nsw i64 %175, 8
  %184 = add nuw nsw i64 %183, %179
  %185 = getelementptr inbounds nuw float, ptr %182, i64 %184
  %186 = load float, ptr %185, align 4
  %187 = fcmp ugt float %186, 0.000000e+00
  %188 = select i1 %187, float %186, float 0.000000e+00
  %189 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %190 = mul nuw nsw i64 %175, 8
  %191 = add nuw nsw i64 %190, %179
  %192 = getelementptr inbounds nuw float, ptr %189, i64 %191
  store float %188, ptr %192, align 4
  %193 = add i64 %179, 1
  br label %178

194:                                              ; preds = %178
  %195 = add i64 %175, 1
  br label %174

196:                                              ; preds = %174
  %197 = call ptr @malloc(i64 128)
  %198 = ptrtoint ptr %197 to i64
  %199 = add i64 %198, 63
  %200 = urem i64 %199, 64
  %201 = sub i64 %199, %200
  %202 = inttoptr i64 %201 to ptr
  %203 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %197, 0
  %204 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %203, ptr %202, 1
  %205 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %204, i64 0, 2
  %206 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %205, i64 8, 3, 0
  %207 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %206, i64 2, 3, 1
  %208 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %207, i64 2, 4, 0
  %209 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %208, i64 1, 4, 1
  br label %210

210:                                              ; preds = %227, %196
  %211 = phi i64 [ %228, %227 ], [ 0, %196 ]
  %212 = icmp slt i64 %211, 8
  br i1 %212, label %213, label %229

213:                                              ; preds = %210
  br label %214

214:                                              ; preds = %217, %213
  %215 = phi i64 [ %226, %217 ], [ 0, %213 ]
  %216 = icmp slt i64 %215, 2
  br i1 %216, label %217, label %227

217:                                              ; preds = %214
  %218 = mul nuw nsw i64 %215, 8
  %219 = add nuw nsw i64 %218, %211
  %220 = getelementptr inbounds nuw float, ptr @__constant_2x8xf32, i64 %219
  %221 = load float, ptr %220, align 4
  %222 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %209, 1
  %223 = mul nuw nsw i64 %211, 2
  %224 = add nuw nsw i64 %223, %215
  %225 = getelementptr inbounds nuw float, ptr %222, i64 %224
  store float %221, ptr %225, align 4
  %226 = add i64 %215, 1
  br label %214

227:                                              ; preds = %214
  %228 = add i64 %211, 1
  br label %210

229:                                              ; preds = %210
  %230 = call ptr @malloc(i64 72)
  %231 = ptrtoint ptr %230 to i64
  %232 = add i64 %231, 63
  %233 = urem i64 %232, 64
  %234 = sub i64 %232, %233
  %235 = inttoptr i64 %234 to ptr
  %236 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %230, 0
  %237 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %236, ptr %235, 1
  %238 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %237, i64 0, 2
  %239 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %238, i64 1, 3, 0
  %240 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %239, i64 2, 3, 1
  %241 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %240, i64 2, 4, 0
  %242 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %241, i64 1, 4, 1
  %243 = call ptr @malloc(i64 72)
  %244 = ptrtoint ptr %243 to i64
  %245 = add i64 %244, 63
  %246 = urem i64 %245, 64
  %247 = sub i64 %245, %246
  %248 = inttoptr i64 %247 to ptr
  %249 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %243, 0
  %250 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %249, ptr %248, 1
  %251 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %250, i64 0, 2
  %252 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %251, i64 1, 3, 0
  %253 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %252, i64 2, 3, 1
  %254 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %253, i64 2, 4, 0
  %255 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %254, i64 1, 4, 1
  br label %256

256:                                              ; preds = %269, %229
  %257 = phi i64 [ %270, %269 ], [ 0, %229 ]
  %258 = icmp slt i64 %257, 1
  br i1 %258, label %259, label %271

259:                                              ; preds = %256
  br label %260

260:                                              ; preds = %263, %259
  %261 = phi i64 [ %268, %263 ], [ 0, %259 ]
  %262 = icmp slt i64 %261, 2
  br i1 %262, label %263, label %269

263:                                              ; preds = %260
  %264 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %265 = mul nuw nsw i64 %257, 2
  %266 = add nuw nsw i64 %265, %261
  %267 = getelementptr inbounds nuw float, ptr %264, i64 %266
  store float 0.000000e+00, ptr %267, align 4
  %268 = add i64 %261, 1
  br label %260

269:                                              ; preds = %260
  %270 = add i64 %257, 1
  br label %256

271:                                              ; preds = %256
  br label %272

272:                                              ; preds = %308, %271
  %273 = phi i64 [ %309, %308 ], [ 0, %271 ]
  %274 = icmp slt i64 %273, 1
  br i1 %274, label %275, label %310

275:                                              ; preds = %272
  br label %276

276:                                              ; preds = %306, %275
  %277 = phi i64 [ %307, %306 ], [ 0, %275 ]
  %278 = icmp slt i64 %277, 2
  br i1 %278, label %279, label %308

279:                                              ; preds = %276
  br label %280

280:                                              ; preds = %283, %279
  %281 = phi i64 [ %305, %283 ], [ 0, %279 ]
  %282 = icmp slt i64 %281, 8
  br i1 %282, label %283, label %306

283:                                              ; preds = %280
  %284 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %285 = mul nuw nsw i64 %273, 8
  %286 = add nuw nsw i64 %285, %281
  %287 = getelementptr inbounds nuw float, ptr %284, i64 %286
  %288 = load float, ptr %287, align 4
  %289 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %209, 1
  %290 = mul nuw nsw i64 %281, 2
  %291 = add nuw nsw i64 %290, %277
  %292 = getelementptr inbounds nuw float, ptr %289, i64 %291
  %293 = load float, ptr %292, align 4
  %294 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %295 = mul nuw nsw i64 %273, 2
  %296 = add nuw nsw i64 %295, %277
  %297 = getelementptr inbounds nuw float, ptr %294, i64 %296
  %298 = load float, ptr %297, align 4
  %299 = fmul float %288, %293
  %300 = fadd float %298, %299
  %301 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %302 = mul nuw nsw i64 %273, 2
  %303 = add nuw nsw i64 %302, %277
  %304 = getelementptr inbounds nuw float, ptr %301, i64 %303
  store float %300, ptr %304, align 4
  %305 = add i64 %281, 1
  br label %280

306:                                              ; preds = %280
  %307 = add i64 %277, 1
  br label %276

308:                                              ; preds = %276
  %309 = add i64 %273, 1
  br label %272

310:                                              ; preds = %272
  br label %311

311:                                              ; preds = %326, %310
  %312 = phi i64 [ %327, %326 ], [ 0, %310 ]
  %313 = icmp slt i64 %312, 1
  br i1 %313, label %314, label %328

314:                                              ; preds = %311
  br label %315

315:                                              ; preds = %318, %314
  %316 = phi i64 [ %325, %318 ], [ 0, %314 ]
  %317 = icmp slt i64 %316, 2
  br i1 %317, label %318, label %326

318:                                              ; preds = %315
  %319 = getelementptr inbounds nuw float, ptr @__constant_2xf32, i64 %316
  %320 = load float, ptr %319, align 4
  %321 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %242, 1
  %322 = mul nuw nsw i64 %312, 2
  %323 = add nuw nsw i64 %322, %316
  %324 = getelementptr inbounds nuw float, ptr %321, i64 %323
  store float %320, ptr %324, align 4
  %325 = add i64 %316, 1
  br label %315

326:                                              ; preds = %315
  %327 = add i64 %312, 1
  br label %311

328:                                              ; preds = %311
  br label %329

329:                                              ; preds = %353, %328
  %330 = phi i64 [ %354, %353 ], [ 0, %328 ]
  %331 = icmp slt i64 %330, 1
  br i1 %331, label %332, label %355

332:                                              ; preds = %329
  br label %333

333:                                              ; preds = %336, %332
  %334 = phi i64 [ %352, %336 ], [ 0, %332 ]
  %335 = icmp slt i64 %334, 2
  br i1 %335, label %336, label %353

336:                                              ; preds = %333
  %337 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %255, 1
  %338 = mul nuw nsw i64 %330, 2
  %339 = add nuw nsw i64 %338, %334
  %340 = getelementptr inbounds nuw float, ptr %337, i64 %339
  %341 = load float, ptr %340, align 4
  %342 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %242, 1
  %343 = mul nuw nsw i64 %330, 2
  %344 = add nuw nsw i64 %343, %334
  %345 = getelementptr inbounds nuw float, ptr %342, i64 %344
  %346 = load float, ptr %345, align 4
  %347 = fadd float %341, %346
  %348 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %242, 1
  %349 = mul nuw nsw i64 %330, 2
  %350 = add nuw nsw i64 %349, %334
  %351 = getelementptr inbounds nuw float, ptr %348, i64 %350
  store float %347, ptr %351, align 4
  %352 = add i64 %334, 1
  br label %333

353:                                              ; preds = %333
  %354 = add i64 %330, 1
  br label %329

355:                                              ; preds = %329
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %242
}

define void @_mlir_ciface_mlp(ptr %0, ptr %1) {
  %3 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %1, align 8
  %4 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 0
  %5 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 1
  %6 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 2
  %7 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 3, 0
  %8 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 3, 1
  %9 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 4, 0
  %10 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %3, 4, 1
  %11 = call { ptr, ptr, i64, [2 x i64], [2 x i64] } @mlp(ptr %4, ptr %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %11, ptr %0, align 8
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
