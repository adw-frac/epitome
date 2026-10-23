module {
  llvm.func @memrefCopy(i64, !llvm.ptr, !llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.mlir.global private constant @__constant_2xf32(dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<2 x f32>
  llvm.mlir.global private constant @__constant_2x1x3x3xf32(dense_resource<torch_tensor_2_1_3_3_torch.float32> : tensor<2x1x3x3xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<2 x array<1 x array<3 x array<3 x f32>>>>
  llvm.func @conv2d(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %3 = llvm.insertvalue %arg2, %2[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %5 = llvm.insertvalue %arg7, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %6 = llvm.insertvalue %arg4, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %7 = llvm.insertvalue %arg8, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %8 = llvm.insertvalue %arg5, %7[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %9 = llvm.insertvalue %arg9, %8[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %10 = llvm.insertvalue %arg6, %9[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %11 = llvm.insertvalue %arg10, %10[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %12 = llvm.mlir.constant(3 : index) : i64
    %13 = llvm.mlir.constant(5 : index) : i64
    %14 = llvm.mlir.constant(2 : index) : i64
    %15 = llvm.mlir.constant(7 : index) : i64
    %16 = llvm.mlir.constant(1 : index) : i64
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %19 = llvm.mlir.constant(2 : index) : i64
    %20 = llvm.mlir.constant(1 : index) : i64
    %21 = llvm.mlir.constant(3 : index) : i64
    %22 = llvm.mlir.constant(3 : index) : i64
    %23 = llvm.mlir.constant(1 : index) : i64
    %24 = llvm.mlir.constant(9 : index) : i64
    %25 = llvm.mlir.constant(9 : index) : i64
    %26 = llvm.mlir.constant(18 : index) : i64
    %27 = llvm.mlir.zero : !llvm.ptr
    %28 = llvm.getelementptr %27[%26] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %29 = llvm.ptrtoint %28 : !llvm.ptr to i64
    %30 = llvm.mlir.addressof @__constant_2x1x3x3xf32 : !llvm.ptr
    %31 = llvm.getelementptr %30[0, 0, 0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x array<1 x array<3 x array<3 x f32>>>>
    %32 = llvm.mlir.constant(3735928559 : index) : i64
    %33 = llvm.inttoptr %32 : i64 to !llvm.ptr
    %34 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %35 = llvm.insertvalue %33, %34[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %36 = llvm.insertvalue %31, %35[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %37 = llvm.mlir.constant(0 : index) : i64
    %38 = llvm.insertvalue %37, %36[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %39 = llvm.insertvalue %19, %38[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %40 = llvm.insertvalue %20, %39[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %41 = llvm.insertvalue %21, %40[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %42 = llvm.insertvalue %22, %41[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %43 = llvm.insertvalue %25, %42[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %44 = llvm.insertvalue %24, %43[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %45 = llvm.insertvalue %22, %44[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %46 = llvm.insertvalue %23, %45[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %47 = llvm.mlir.constant(2 : index) : i64
    %48 = llvm.mlir.constant(1 : index) : i64
    %49 = llvm.mlir.zero : !llvm.ptr
    %50 = llvm.getelementptr %49[%47] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %51 = llvm.ptrtoint %50 : !llvm.ptr to i64
    %52 = llvm.mlir.addressof @__constant_2xf32 : !llvm.ptr
    %53 = llvm.getelementptr %52[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x f32>
    %54 = llvm.mlir.constant(3735928559 : index) : i64
    %55 = llvm.inttoptr %54 : i64 to !llvm.ptr
    %56 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %57 = llvm.insertvalue %55, %56[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %58 = llvm.insertvalue %53, %57[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %59 = llvm.mlir.constant(0 : index) : i64
    %60 = llvm.insertvalue %59, %58[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %61 = llvm.insertvalue %47, %60[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %62 = llvm.insertvalue %48, %61[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %63 = llvm.mlir.constant(1 : index) : i64
    %64 = llvm.mlir.constant(1 : index) : i64
    %65 = llvm.mlir.constant(7 : index) : i64
    %66 = llvm.mlir.constant(7 : index) : i64
    %67 = llvm.mlir.constant(1 : index) : i64
    %68 = llvm.mlir.constant(49 : index) : i64
    %69 = llvm.mlir.constant(49 : index) : i64
    %70 = llvm.mlir.constant(49 : index) : i64
    %71 = llvm.mlir.zero : !llvm.ptr
    %72 = llvm.getelementptr %71[%70] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %73 = llvm.ptrtoint %72 : !llvm.ptr to i64
    %74 = llvm.mlir.constant(64 : index) : i64
    %75 = llvm.add %73, %74 : i64
    %76 = llvm.call @malloc(%75) : (i64) -> !llvm.ptr
    %77 = llvm.ptrtoint %76 : !llvm.ptr to i64
    %78 = llvm.mlir.constant(1 : index) : i64
    %79 = llvm.sub %74, %78 : i64
    %80 = llvm.add %77, %79 : i64
    %81 = llvm.urem %80, %74 : i64
    %82 = llvm.sub %80, %81 : i64
    %83 = llvm.inttoptr %82 : i64 to !llvm.ptr
    %84 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %85 = llvm.insertvalue %76, %84[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %86 = llvm.insertvalue %83, %85[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %87 = llvm.mlir.constant(0 : index) : i64
    %88 = llvm.insertvalue %87, %86[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %89 = llvm.insertvalue %63, %88[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %90 = llvm.insertvalue %64, %89[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %91 = llvm.insertvalue %65, %90[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %92 = llvm.insertvalue %66, %91[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %93 = llvm.insertvalue %69, %92[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %94 = llvm.insertvalue %68, %93[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %95 = llvm.insertvalue %66, %94[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %96 = llvm.insertvalue %67, %95[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    llvm.br ^bb1(%17 : i64)
  ^bb1(%97: i64):  // 2 preds: ^bb0, ^bb11
    %98 = llvm.icmp "slt" %97, %16 : i64
    llvm.cond_br %98, ^bb2, ^bb12
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%17 : i64)
  ^bb3(%99: i64):  // 2 preds: ^bb2, ^bb10
    %100 = llvm.icmp "slt" %99, %16 : i64
    llvm.cond_br %100, ^bb4, ^bb11
  ^bb4:  // pred: ^bb3
    llvm.br ^bb5(%17 : i64)
  ^bb5(%101: i64):  // 2 preds: ^bb4, ^bb9
    %102 = llvm.icmp "slt" %101, %15 : i64
    llvm.cond_br %102, ^bb6, ^bb10
  ^bb6:  // pred: ^bb5
    llvm.br ^bb7(%17 : i64)
  ^bb7(%103: i64):  // 2 preds: ^bb6, ^bb8
    %104 = llvm.icmp "slt" %103, %15 : i64
    llvm.cond_br %104, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %105 = llvm.extractvalue %96[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %106 = llvm.mlir.constant(49 : index) : i64
    %107 = llvm.mul %97, %106 overflow<nsw, nuw> : i64
    %108 = llvm.mlir.constant(49 : index) : i64
    %109 = llvm.mul %99, %108 overflow<nsw, nuw> : i64
    %110 = llvm.add %107, %109 overflow<nsw, nuw> : i64
    %111 = llvm.mlir.constant(7 : index) : i64
    %112 = llvm.mul %101, %111 overflow<nsw, nuw> : i64
    %113 = llvm.add %110, %112 overflow<nsw, nuw> : i64
    %114 = llvm.add %113, %103 overflow<nsw, nuw> : i64
    %115 = llvm.getelementptr inbounds|nuw %105[%114] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %18, %115 : f32, !llvm.ptr
    %116 = llvm.add %103, %16 : i64
    llvm.br ^bb7(%116 : i64)
  ^bb9:  // pred: ^bb7
    %117 = llvm.add %101, %16 : i64
    llvm.br ^bb5(%117 : i64)
  ^bb10:  // pred: ^bb5
    %118 = llvm.add %99, %16 : i64
    llvm.br ^bb3(%118 : i64)
  ^bb11:  // pred: ^bb3
    %119 = llvm.add %97, %16 : i64
    llvm.br ^bb1(%119 : i64)
  ^bb12:  // pred: ^bb1
    %120 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %121 = llvm.extractvalue %96[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %122 = llvm.extractvalue %96[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %123 = llvm.insertvalue %121, %120[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %124 = llvm.insertvalue %122, %123[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %125 = llvm.mlir.constant(8 : index) : i64
    %126 = llvm.insertvalue %125, %124[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %127 = llvm.mlir.constant(1 : index) : i64
    %128 = llvm.insertvalue %127, %126[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %129 = llvm.mlir.constant(49 : index) : i64
    %130 = llvm.insertvalue %129, %128[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %131 = llvm.mlir.constant(1 : index) : i64
    %132 = llvm.insertvalue %131, %130[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %133 = llvm.mlir.constant(49 : index) : i64
    %134 = llvm.insertvalue %133, %132[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %135 = llvm.mlir.constant(5 : index) : i64
    %136 = llvm.insertvalue %135, %134[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %137 = llvm.mlir.constant(7 : index) : i64
    %138 = llvm.insertvalue %137, %136[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %139 = llvm.mlir.constant(5 : index) : i64
    %140 = llvm.insertvalue %139, %138[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %141 = llvm.mlir.constant(1 : index) : i64
    %142 = llvm.insertvalue %141, %140[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %143 = llvm.intr.stacksave : !llvm.ptr
    %144 = llvm.mlir.constant(4 : i64) : i64
    %145 = llvm.mlir.constant(1 : index) : i64
    %146 = llvm.alloca %145 x !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %11, %146 : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr
    %147 = llvm.mlir.poison : !llvm.struct<(i64, ptr)>
    %148 = llvm.insertvalue %144, %147[0] : !llvm.struct<(i64, ptr)> 
    %149 = llvm.insertvalue %146, %148[1] : !llvm.struct<(i64, ptr)> 
    %150 = llvm.mlir.constant(4 : i64) : i64
    %151 = llvm.mlir.constant(1 : index) : i64
    %152 = llvm.alloca %151 x !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %142, %152 : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr
    %153 = llvm.mlir.poison : !llvm.struct<(i64, ptr)>
    %154 = llvm.insertvalue %150, %153[0] : !llvm.struct<(i64, ptr)> 
    %155 = llvm.insertvalue %152, %154[1] : !llvm.struct<(i64, ptr)> 
    %156 = llvm.mlir.constant(1 : index) : i64
    %157 = llvm.alloca %156 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %149, %157 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %158 = llvm.alloca %156 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %155, %158 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %159 = llvm.mlir.zero : !llvm.ptr
    %160 = llvm.getelementptr %159[1] : (!llvm.ptr) -> !llvm.ptr, f32
    %161 = llvm.ptrtoint %160 : !llvm.ptr to i64
    llvm.call @memrefCopy(%161, %157, %158) : (i64, !llvm.ptr, !llvm.ptr) -> ()
    llvm.intr.stackrestore %143 : !llvm.ptr
    %162 = llvm.mlir.constant(1 : index) : i64
    %163 = llvm.mlir.constant(2 : index) : i64
    %164 = llvm.mlir.constant(5 : index) : i64
    %165 = llvm.mlir.constant(5 : index) : i64
    %166 = llvm.mlir.constant(1 : index) : i64
    %167 = llvm.mlir.constant(25 : index) : i64
    %168 = llvm.mlir.constant(50 : index) : i64
    %169 = llvm.mlir.constant(50 : index) : i64
    %170 = llvm.mlir.zero : !llvm.ptr
    %171 = llvm.getelementptr %170[%169] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %172 = llvm.ptrtoint %171 : !llvm.ptr to i64
    %173 = llvm.mlir.constant(64 : index) : i64
    %174 = llvm.add %172, %173 : i64
    %175 = llvm.call @malloc(%174) : (i64) -> !llvm.ptr
    %176 = llvm.ptrtoint %175 : !llvm.ptr to i64
    %177 = llvm.mlir.constant(1 : index) : i64
    %178 = llvm.sub %173, %177 : i64
    %179 = llvm.add %176, %178 : i64
    %180 = llvm.urem %179, %173 : i64
    %181 = llvm.sub %179, %180 : i64
    %182 = llvm.inttoptr %181 : i64 to !llvm.ptr
    %183 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %184 = llvm.insertvalue %175, %183[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %185 = llvm.insertvalue %182, %184[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %186 = llvm.mlir.constant(0 : index) : i64
    %187 = llvm.insertvalue %186, %185[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %188 = llvm.insertvalue %162, %187[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %189 = llvm.insertvalue %163, %188[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %190 = llvm.insertvalue %164, %189[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %191 = llvm.insertvalue %165, %190[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %192 = llvm.insertvalue %168, %191[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %193 = llvm.insertvalue %167, %192[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %194 = llvm.insertvalue %165, %193[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %195 = llvm.insertvalue %166, %194[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    llvm.br ^bb13(%17 : i64)
  ^bb13(%196: i64):  // 2 preds: ^bb12, ^bb23
    %197 = llvm.icmp "slt" %196, %16 : i64
    llvm.cond_br %197, ^bb14, ^bb24
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%17 : i64)
  ^bb15(%198: i64):  // 2 preds: ^bb14, ^bb22
    %199 = llvm.icmp "slt" %198, %14 : i64
    llvm.cond_br %199, ^bb16, ^bb23
  ^bb16:  // pred: ^bb15
    llvm.br ^bb17(%17 : i64)
  ^bb17(%200: i64):  // 2 preds: ^bb16, ^bb21
    %201 = llvm.icmp "slt" %200, %13 : i64
    llvm.cond_br %201, ^bb18, ^bb22
  ^bb18:  // pred: ^bb17
    llvm.br ^bb19(%17 : i64)
  ^bb19(%202: i64):  // 2 preds: ^bb18, ^bb20
    %203 = llvm.icmp "slt" %202, %13 : i64
    llvm.cond_br %203, ^bb20, ^bb21
  ^bb20:  // pred: ^bb19
    %204 = llvm.extractvalue %62[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %205 = llvm.getelementptr inbounds|nuw %204[%198] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %206 = llvm.load %205 : !llvm.ptr -> f32
    %207 = llvm.extractvalue %195[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %208 = llvm.mlir.constant(50 : index) : i64
    %209 = llvm.mul %196, %208 overflow<nsw, nuw> : i64
    %210 = llvm.mlir.constant(25 : index) : i64
    %211 = llvm.mul %198, %210 overflow<nsw, nuw> : i64
    %212 = llvm.add %209, %211 overflow<nsw, nuw> : i64
    %213 = llvm.mlir.constant(5 : index) : i64
    %214 = llvm.mul %200, %213 overflow<nsw, nuw> : i64
    %215 = llvm.add %212, %214 overflow<nsw, nuw> : i64
    %216 = llvm.add %215, %202 overflow<nsw, nuw> : i64
    %217 = llvm.getelementptr inbounds|nuw %207[%216] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %206, %217 : f32, !llvm.ptr
    %218 = llvm.add %202, %16 : i64
    llvm.br ^bb19(%218 : i64)
  ^bb21:  // pred: ^bb19
    %219 = llvm.add %200, %16 : i64
    llvm.br ^bb17(%219 : i64)
  ^bb22:  // pred: ^bb17
    %220 = llvm.add %198, %16 : i64
    llvm.br ^bb15(%220 : i64)
  ^bb23:  // pred: ^bb15
    %221 = llvm.add %196, %16 : i64
    llvm.br ^bb13(%221 : i64)
  ^bb24:  // pred: ^bb13
    llvm.br ^bb25(%17 : i64)
  ^bb25(%222: i64):  // 2 preds: ^bb24, ^bb44
    %223 = llvm.icmp "slt" %222, %16 : i64
    llvm.cond_br %223, ^bb26, ^bb45
  ^bb26:  // pred: ^bb25
    llvm.br ^bb27(%17 : i64)
  ^bb27(%224: i64):  // 2 preds: ^bb26, ^bb43
    %225 = llvm.icmp "slt" %224, %14 : i64
    llvm.cond_br %225, ^bb28, ^bb44
  ^bb28:  // pred: ^bb27
    llvm.br ^bb29(%17 : i64)
  ^bb29(%226: i64):  // 2 preds: ^bb28, ^bb42
    %227 = llvm.icmp "slt" %226, %13 : i64
    llvm.cond_br %227, ^bb30, ^bb43
  ^bb30:  // pred: ^bb29
    llvm.br ^bb31(%17 : i64)
  ^bb31(%228: i64):  // 2 preds: ^bb30, ^bb41
    %229 = llvm.icmp "slt" %228, %13 : i64
    llvm.cond_br %229, ^bb32, ^bb42
  ^bb32:  // pred: ^bb31
    llvm.br ^bb33(%17 : i64)
  ^bb33(%230: i64):  // 2 preds: ^bb32, ^bb40
    %231 = llvm.icmp "slt" %230, %16 : i64
    llvm.cond_br %231, ^bb34, ^bb41
  ^bb34:  // pred: ^bb33
    llvm.br ^bb35(%17 : i64)
  ^bb35(%232: i64):  // 2 preds: ^bb34, ^bb39
    %233 = llvm.icmp "slt" %232, %12 : i64
    llvm.cond_br %233, ^bb36, ^bb40
  ^bb36:  // pred: ^bb35
    llvm.br ^bb37(%17 : i64)
  ^bb37(%234: i64):  // 2 preds: ^bb36, ^bb38
    %235 = llvm.icmp "slt" %234, %12 : i64
    llvm.cond_br %235, ^bb38, ^bb39
  ^bb38:  // pred: ^bb37
    %236 = llvm.add %226, %232 : i64
    %237 = llvm.add %228, %234 : i64
    %238 = llvm.extractvalue %96[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %239 = llvm.mlir.constant(49 : index) : i64
    %240 = llvm.mul %222, %239 overflow<nsw, nuw> : i64
    %241 = llvm.mlir.constant(49 : index) : i64
    %242 = llvm.mul %230, %241 overflow<nsw, nuw> : i64
    %243 = llvm.add %240, %242 overflow<nsw, nuw> : i64
    %244 = llvm.mlir.constant(7 : index) : i64
    %245 = llvm.mul %236, %244 overflow<nsw, nuw> : i64
    %246 = llvm.add %243, %245 overflow<nsw, nuw> : i64
    %247 = llvm.add %246, %237 overflow<nsw, nuw> : i64
    %248 = llvm.getelementptr inbounds|nuw %238[%247] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %249 = llvm.load %248 : !llvm.ptr -> f32
    %250 = llvm.extractvalue %46[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %251 = llvm.mlir.constant(9 : index) : i64
    %252 = llvm.mul %224, %251 overflow<nsw, nuw> : i64
    %253 = llvm.mlir.constant(9 : index) : i64
    %254 = llvm.mul %230, %253 overflow<nsw, nuw> : i64
    %255 = llvm.add %252, %254 overflow<nsw, nuw> : i64
    %256 = llvm.mlir.constant(3 : index) : i64
    %257 = llvm.mul %232, %256 overflow<nsw, nuw> : i64
    %258 = llvm.add %255, %257 overflow<nsw, nuw> : i64
    %259 = llvm.add %258, %234 overflow<nsw, nuw> : i64
    %260 = llvm.getelementptr inbounds|nuw %250[%259] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %261 = llvm.load %260 : !llvm.ptr -> f32
    %262 = llvm.extractvalue %195[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %263 = llvm.mlir.constant(50 : index) : i64
    %264 = llvm.mul %222, %263 overflow<nsw, nuw> : i64
    %265 = llvm.mlir.constant(25 : index) : i64
    %266 = llvm.mul %224, %265 overflow<nsw, nuw> : i64
    %267 = llvm.add %264, %266 overflow<nsw, nuw> : i64
    %268 = llvm.mlir.constant(5 : index) : i64
    %269 = llvm.mul %226, %268 overflow<nsw, nuw> : i64
    %270 = llvm.add %267, %269 overflow<nsw, nuw> : i64
    %271 = llvm.add %270, %228 overflow<nsw, nuw> : i64
    %272 = llvm.getelementptr inbounds|nuw %262[%271] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %273 = llvm.load %272 : !llvm.ptr -> f32
    %274 = llvm.fmul %249, %261 : f32
    %275 = llvm.fadd %273, %274 : f32
    %276 = llvm.extractvalue %195[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %277 = llvm.mlir.constant(50 : index) : i64
    %278 = llvm.mul %222, %277 overflow<nsw, nuw> : i64
    %279 = llvm.mlir.constant(25 : index) : i64
    %280 = llvm.mul %224, %279 overflow<nsw, nuw> : i64
    %281 = llvm.add %278, %280 overflow<nsw, nuw> : i64
    %282 = llvm.mlir.constant(5 : index) : i64
    %283 = llvm.mul %226, %282 overflow<nsw, nuw> : i64
    %284 = llvm.add %281, %283 overflow<nsw, nuw> : i64
    %285 = llvm.add %284, %228 overflow<nsw, nuw> : i64
    %286 = llvm.getelementptr inbounds|nuw %276[%285] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %275, %286 : f32, !llvm.ptr
    %287 = llvm.add %234, %16 : i64
    llvm.br ^bb37(%287 : i64)
  ^bb39:  // pred: ^bb37
    %288 = llvm.add %232, %16 : i64
    llvm.br ^bb35(%288 : i64)
  ^bb40:  // pred: ^bb35
    %289 = llvm.add %230, %16 : i64
    llvm.br ^bb33(%289 : i64)
  ^bb41:  // pred: ^bb33
    %290 = llvm.add %228, %16 : i64
    llvm.br ^bb31(%290 : i64)
  ^bb42:  // pred: ^bb31
    %291 = llvm.add %226, %16 : i64
    llvm.br ^bb29(%291 : i64)
  ^bb43:  // pred: ^bb29
    %292 = llvm.add %224, %16 : i64
    llvm.br ^bb27(%292 : i64)
  ^bb44:  // pred: ^bb27
    %293 = llvm.add %222, %16 : i64
    llvm.br ^bb25(%293 : i64)
  ^bb45:  // pred: ^bb25
    llvm.return %195 : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
  }
  llvm.func @_mlir_ciface_conv2d(%arg0: !llvm.ptr, %arg1: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %6 = llvm.extractvalue %0[3, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %7 = llvm.extractvalue %0[3, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %8 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %9 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %10 = llvm.extractvalue %0[4, 2] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %11 = llvm.extractvalue %0[4, 3] : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> 
    %12 = llvm.call @conv2d(%1, %2, %3, %4, %5, %6, %7, %8, %9, %10, %11) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    llvm.store %12, %arg0 : !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr
    llvm.return
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_2_torch.float32: "0x04000000D0D1EEBDD2E18BBE",
      torch_tensor_2_1_3_3_torch.float32: "0x040000004EC90BBE208A4A3EF6B64FBE9BDB9A3E6BEA693E98EB8FBEB0E7A9BD006E763C2034473D36E9A13DE8F2053E4091A33CDE8B26BEE383213E3AB6A3BE804F4ABE50E4AABD9E4426BE"
    }
  }
#-}
