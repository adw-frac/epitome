module {
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.mlir.global private constant @__constant_8x4xf32(dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<8 x array<4 x f32>>
  llvm.mlir.global private constant @__constant_8xf32(dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<8 x f32>
  llvm.mlir.global private constant @__constant_2x8xf32(dense_resource<torch_tensor_2_8_torch.float32> : tensor<2x8xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<2 x array<8 x f32>>
  llvm.mlir.global private constant @__constant_2xf32(dense_resource<torch_tensor_2_torch.float32> : tensor<2xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<2 x f32>
  llvm.func @mlp(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg2, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg5, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg4, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg6, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.constant(2 : index) : i64
    %9 = llvm.mlir.constant(8 : index) : i64
    %10 = llvm.mlir.constant(1 : index) : i64
    %11 = llvm.mlir.constant(4 : index) : i64
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %14 = llvm.mlir.constant(2 : index) : i64
    %15 = llvm.mlir.constant(1 : index) : i64
    %16 = llvm.mlir.zero : !llvm.ptr
    %17 = llvm.getelementptr %16[%14] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %18 = llvm.ptrtoint %17 : !llvm.ptr to i64
    %19 = llvm.mlir.addressof @__constant_2xf32 : !llvm.ptr
    %20 = llvm.getelementptr %19[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x f32>
    %21 = llvm.mlir.constant(3735928559 : index) : i64
    %22 = llvm.inttoptr %21 : i64 to !llvm.ptr
    %23 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %24 = llvm.insertvalue %22, %23[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %25 = llvm.insertvalue %20, %24[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %26 = llvm.mlir.constant(0 : index) : i64
    %27 = llvm.insertvalue %26, %25[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %28 = llvm.insertvalue %14, %27[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %29 = llvm.insertvalue %15, %28[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %30 = llvm.mlir.constant(2 : index) : i64
    %31 = llvm.mlir.constant(8 : index) : i64
    %32 = llvm.mlir.constant(1 : index) : i64
    %33 = llvm.mlir.constant(16 : index) : i64
    %34 = llvm.mlir.zero : !llvm.ptr
    %35 = llvm.getelementptr %34[%33] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %36 = llvm.ptrtoint %35 : !llvm.ptr to i64
    %37 = llvm.mlir.addressof @__constant_2x8xf32 : !llvm.ptr
    %38 = llvm.getelementptr %37[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x array<8 x f32>>
    %39 = llvm.mlir.constant(3735928559 : index) : i64
    %40 = llvm.inttoptr %39 : i64 to !llvm.ptr
    %41 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %42 = llvm.insertvalue %40, %41[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.insertvalue %38, %42[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.mlir.constant(0 : index) : i64
    %45 = llvm.insertvalue %44, %43[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.insertvalue %30, %45[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %31, %46[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.insertvalue %31, %47[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.insertvalue %32, %48[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.mlir.constant(8 : index) : i64
    %51 = llvm.mlir.constant(1 : index) : i64
    %52 = llvm.mlir.zero : !llvm.ptr
    %53 = llvm.getelementptr %52[%50] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %54 = llvm.ptrtoint %53 : !llvm.ptr to i64
    %55 = llvm.mlir.addressof @__constant_8xf32 : !llvm.ptr
    %56 = llvm.getelementptr %55[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<8 x f32>
    %57 = llvm.mlir.constant(3735928559 : index) : i64
    %58 = llvm.inttoptr %57 : i64 to !llvm.ptr
    %59 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %60 = llvm.insertvalue %58, %59[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %61 = llvm.insertvalue %56, %60[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %62 = llvm.mlir.constant(0 : index) : i64
    %63 = llvm.insertvalue %62, %61[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %64 = llvm.insertvalue %50, %63[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %65 = llvm.insertvalue %51, %64[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %66 = llvm.mlir.constant(8 : index) : i64
    %67 = llvm.mlir.constant(4 : index) : i64
    %68 = llvm.mlir.constant(1 : index) : i64
    %69 = llvm.mlir.constant(32 : index) : i64
    %70 = llvm.mlir.zero : !llvm.ptr
    %71 = llvm.getelementptr %70[%69] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %72 = llvm.ptrtoint %71 : !llvm.ptr to i64
    %73 = llvm.mlir.addressof @__constant_8x4xf32 : !llvm.ptr
    %74 = llvm.getelementptr %73[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<8 x array<4 x f32>>
    %75 = llvm.mlir.constant(3735928559 : index) : i64
    %76 = llvm.inttoptr %75 : i64 to !llvm.ptr
    %77 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %78 = llvm.insertvalue %76, %77[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %79 = llvm.insertvalue %74, %78[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %80 = llvm.mlir.constant(0 : index) : i64
    %81 = llvm.insertvalue %80, %79[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %82 = llvm.insertvalue %66, %81[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %83 = llvm.insertvalue %67, %82[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %84 = llvm.insertvalue %67, %83[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %85 = llvm.insertvalue %68, %84[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %86 = llvm.mlir.constant(4 : index) : i64
    %87 = llvm.mlir.constant(8 : index) : i64
    %88 = llvm.mlir.constant(1 : index) : i64
    %89 = llvm.mlir.constant(32 : index) : i64
    %90 = llvm.mlir.zero : !llvm.ptr
    %91 = llvm.getelementptr %90[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %92 = llvm.ptrtoint %91 : !llvm.ptr to i64
    %93 = llvm.mlir.constant(64 : index) : i64
    %94 = llvm.add %92, %93 : i64
    %95 = llvm.call @malloc(%94) : (i64) -> !llvm.ptr
    %96 = llvm.ptrtoint %95 : !llvm.ptr to i64
    %97 = llvm.mlir.constant(1 : index) : i64
    %98 = llvm.sub %93, %97 : i64
    %99 = llvm.add %96, %98 : i64
    %100 = llvm.urem %99, %93 : i64
    %101 = llvm.sub %99, %100 : i64
    %102 = llvm.inttoptr %101 : i64 to !llvm.ptr
    %103 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %104 = llvm.insertvalue %95, %103[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.insertvalue %102, %104[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %106 = llvm.mlir.constant(0 : index) : i64
    %107 = llvm.insertvalue %106, %105[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %108 = llvm.insertvalue %86, %107[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %109 = llvm.insertvalue %87, %108[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %110 = llvm.insertvalue %87, %109[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %111 = llvm.insertvalue %88, %110[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%12 : i64)
  ^bb1(%112: i64):  // 2 preds: ^bb0, ^bb5
    %113 = llvm.icmp "slt" %112, %11 : i64
    llvm.cond_br %113, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%12 : i64)
  ^bb3(%114: i64):  // 2 preds: ^bb2, ^bb4
    %115 = llvm.icmp "slt" %114, %9 : i64
    llvm.cond_br %115, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %116 = llvm.extractvalue %85[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %117 = llvm.mlir.constant(4 : index) : i64
    %118 = llvm.mul %114, %117 overflow<nsw, nuw> : i64
    %119 = llvm.add %118, %112 overflow<nsw, nuw> : i64
    %120 = llvm.getelementptr inbounds|nuw %116[%119] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %121 = llvm.load %120 : !llvm.ptr -> f32
    %122 = llvm.extractvalue %111[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %123 = llvm.mlir.constant(8 : index) : i64
    %124 = llvm.mul %112, %123 overflow<nsw, nuw> : i64
    %125 = llvm.add %124, %114 overflow<nsw, nuw> : i64
    %126 = llvm.getelementptr inbounds|nuw %122[%125] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %121, %126 : f32, !llvm.ptr
    %127 = llvm.add %114, %10 : i64
    llvm.br ^bb3(%127 : i64)
  ^bb5:  // pred: ^bb3
    %128 = llvm.add %112, %10 : i64
    llvm.br ^bb1(%128 : i64)
  ^bb6:  // pred: ^bb1
    %129 = llvm.mlir.constant(1 : index) : i64
    %130 = llvm.mlir.constant(8 : index) : i64
    %131 = llvm.mlir.constant(1 : index) : i64
    %132 = llvm.mlir.constant(8 : index) : i64
    %133 = llvm.mlir.zero : !llvm.ptr
    %134 = llvm.getelementptr %133[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %135 = llvm.ptrtoint %134 : !llvm.ptr to i64
    %136 = llvm.mlir.constant(64 : index) : i64
    %137 = llvm.add %135, %136 : i64
    %138 = llvm.call @malloc(%137) : (i64) -> !llvm.ptr
    %139 = llvm.ptrtoint %138 : !llvm.ptr to i64
    %140 = llvm.mlir.constant(1 : index) : i64
    %141 = llvm.sub %136, %140 : i64
    %142 = llvm.add %139, %141 : i64
    %143 = llvm.urem %142, %136 : i64
    %144 = llvm.sub %142, %143 : i64
    %145 = llvm.inttoptr %144 : i64 to !llvm.ptr
    %146 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %147 = llvm.insertvalue %138, %146[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %148 = llvm.insertvalue %145, %147[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %149 = llvm.mlir.constant(0 : index) : i64
    %150 = llvm.insertvalue %149, %148[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %151 = llvm.insertvalue %129, %150[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %152 = llvm.insertvalue %130, %151[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %153 = llvm.insertvalue %130, %152[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %154 = llvm.insertvalue %131, %153[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %155 = llvm.mlir.constant(1 : index) : i64
    %156 = llvm.mlir.constant(8 : index) : i64
    %157 = llvm.mlir.constant(1 : index) : i64
    %158 = llvm.mlir.constant(8 : index) : i64
    %159 = llvm.mlir.zero : !llvm.ptr
    %160 = llvm.getelementptr %159[%158] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %161 = llvm.ptrtoint %160 : !llvm.ptr to i64
    %162 = llvm.mlir.constant(64 : index) : i64
    %163 = llvm.add %161, %162 : i64
    %164 = llvm.call @malloc(%163) : (i64) -> !llvm.ptr
    %165 = llvm.ptrtoint %164 : !llvm.ptr to i64
    %166 = llvm.mlir.constant(1 : index) : i64
    %167 = llvm.sub %162, %166 : i64
    %168 = llvm.add %165, %167 : i64
    %169 = llvm.urem %168, %162 : i64
    %170 = llvm.sub %168, %169 : i64
    %171 = llvm.inttoptr %170 : i64 to !llvm.ptr
    %172 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %173 = llvm.insertvalue %164, %172[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %174 = llvm.insertvalue %171, %173[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %175 = llvm.mlir.constant(0 : index) : i64
    %176 = llvm.insertvalue %175, %174[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %177 = llvm.insertvalue %155, %176[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %178 = llvm.insertvalue %156, %177[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %179 = llvm.insertvalue %156, %178[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %180 = llvm.insertvalue %157, %179[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb7(%12 : i64)
  ^bb7(%181: i64):  // 2 preds: ^bb6, ^bb11
    %182 = llvm.icmp "slt" %181, %10 : i64
    llvm.cond_br %182, ^bb8, ^bb12
  ^bb8:  // pred: ^bb7
    llvm.br ^bb9(%12 : i64)
  ^bb9(%183: i64):  // 2 preds: ^bb8, ^bb10
    %184 = llvm.icmp "slt" %183, %9 : i64
    llvm.cond_br %184, ^bb10, ^bb11
  ^bb10:  // pred: ^bb9
    %185 = llvm.extractvalue %180[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %186 = llvm.mlir.constant(8 : index) : i64
    %187 = llvm.mul %181, %186 overflow<nsw, nuw> : i64
    %188 = llvm.add %187, %183 overflow<nsw, nuw> : i64
    %189 = llvm.getelementptr inbounds|nuw %185[%188] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %13, %189 : f32, !llvm.ptr
    %190 = llvm.add %183, %10 : i64
    llvm.br ^bb9(%190 : i64)
  ^bb11:  // pred: ^bb9
    %191 = llvm.add %181, %10 : i64
    llvm.br ^bb7(%191 : i64)
  ^bb12:  // pred: ^bb7
    llvm.br ^bb13(%12 : i64)
  ^bb13(%192: i64):  // 2 preds: ^bb12, ^bb20
    %193 = llvm.icmp "slt" %192, %10 : i64
    llvm.cond_br %193, ^bb14, ^bb21
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%12 : i64)
  ^bb15(%194: i64):  // 2 preds: ^bb14, ^bb19
    %195 = llvm.icmp "slt" %194, %9 : i64
    llvm.cond_br %195, ^bb16, ^bb20
  ^bb16:  // pred: ^bb15
    llvm.br ^bb17(%12 : i64)
  ^bb17(%196: i64):  // 2 preds: ^bb16, ^bb18
    %197 = llvm.icmp "slt" %196, %11 : i64
    llvm.cond_br %197, ^bb18, ^bb19
  ^bb18:  // pred: ^bb17
    %198 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %199 = llvm.mlir.constant(4 : index) : i64
    %200 = llvm.mul %192, %199 overflow<nsw, nuw> : i64
    %201 = llvm.add %200, %196 overflow<nsw, nuw> : i64
    %202 = llvm.getelementptr inbounds|nuw %198[%201] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %203 = llvm.load %202 : !llvm.ptr -> f32
    %204 = llvm.extractvalue %111[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %205 = llvm.mlir.constant(8 : index) : i64
    %206 = llvm.mul %196, %205 overflow<nsw, nuw> : i64
    %207 = llvm.add %206, %194 overflow<nsw, nuw> : i64
    %208 = llvm.getelementptr inbounds|nuw %204[%207] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %209 = llvm.load %208 : !llvm.ptr -> f32
    %210 = llvm.extractvalue %180[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %211 = llvm.mlir.constant(8 : index) : i64
    %212 = llvm.mul %192, %211 overflow<nsw, nuw> : i64
    %213 = llvm.add %212, %194 overflow<nsw, nuw> : i64
    %214 = llvm.getelementptr inbounds|nuw %210[%213] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %215 = llvm.load %214 : !llvm.ptr -> f32
    %216 = llvm.fmul %203, %209 : f32
    %217 = llvm.fadd %215, %216 : f32
    %218 = llvm.extractvalue %180[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %219 = llvm.mlir.constant(8 : index) : i64
    %220 = llvm.mul %192, %219 overflow<nsw, nuw> : i64
    %221 = llvm.add %220, %194 overflow<nsw, nuw> : i64
    %222 = llvm.getelementptr inbounds|nuw %218[%221] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %217, %222 : f32, !llvm.ptr
    %223 = llvm.add %196, %10 : i64
    llvm.br ^bb17(%223 : i64)
  ^bb19:  // pred: ^bb17
    %224 = llvm.add %194, %10 : i64
    llvm.br ^bb15(%224 : i64)
  ^bb20:  // pred: ^bb15
    %225 = llvm.add %192, %10 : i64
    llvm.br ^bb13(%225 : i64)
  ^bb21:  // pred: ^bb13
    llvm.br ^bb22(%12 : i64)
  ^bb22(%226: i64):  // 2 preds: ^bb21, ^bb26
    %227 = llvm.icmp "slt" %226, %10 : i64
    llvm.cond_br %227, ^bb23, ^bb27
  ^bb23:  // pred: ^bb22
    llvm.br ^bb24(%12 : i64)
  ^bb24(%228: i64):  // 2 preds: ^bb23, ^bb25
    %229 = llvm.icmp "slt" %228, %9 : i64
    llvm.cond_br %229, ^bb25, ^bb26
  ^bb25:  // pred: ^bb24
    %230 = llvm.extractvalue %65[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %231 = llvm.getelementptr inbounds|nuw %230[%228] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %232 = llvm.load %231 : !llvm.ptr -> f32
    %233 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %234 = llvm.mlir.constant(8 : index) : i64
    %235 = llvm.mul %226, %234 overflow<nsw, nuw> : i64
    %236 = llvm.add %235, %228 overflow<nsw, nuw> : i64
    %237 = llvm.getelementptr inbounds|nuw %233[%236] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %232, %237 : f32, !llvm.ptr
    %238 = llvm.add %228, %10 : i64
    llvm.br ^bb24(%238 : i64)
  ^bb26:  // pred: ^bb24
    %239 = llvm.add %226, %10 : i64
    llvm.br ^bb22(%239 : i64)
  ^bb27:  // pred: ^bb22
    llvm.br ^bb28(%12 : i64)
  ^bb28(%240: i64):  // 2 preds: ^bb27, ^bb32
    %241 = llvm.icmp "slt" %240, %10 : i64
    llvm.cond_br %241, ^bb29, ^bb33
  ^bb29:  // pred: ^bb28
    llvm.br ^bb30(%12 : i64)
  ^bb30(%242: i64):  // 2 preds: ^bb29, ^bb31
    %243 = llvm.icmp "slt" %242, %9 : i64
    llvm.cond_br %243, ^bb31, ^bb32
  ^bb31:  // pred: ^bb30
    %244 = llvm.extractvalue %180[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %245 = llvm.mlir.constant(8 : index) : i64
    %246 = llvm.mul %240, %245 overflow<nsw, nuw> : i64
    %247 = llvm.add %246, %242 overflow<nsw, nuw> : i64
    %248 = llvm.getelementptr inbounds|nuw %244[%247] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %249 = llvm.load %248 : !llvm.ptr -> f32
    %250 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %251 = llvm.mlir.constant(8 : index) : i64
    %252 = llvm.mul %240, %251 overflow<nsw, nuw> : i64
    %253 = llvm.add %252, %242 overflow<nsw, nuw> : i64
    %254 = llvm.getelementptr inbounds|nuw %250[%253] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %255 = llvm.load %254 : !llvm.ptr -> f32
    %256 = llvm.fadd %249, %255 : f32
    %257 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %258 = llvm.mlir.constant(8 : index) : i64
    %259 = llvm.mul %240, %258 overflow<nsw, nuw> : i64
    %260 = llvm.add %259, %242 overflow<nsw, nuw> : i64
    %261 = llvm.getelementptr inbounds|nuw %257[%260] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %256, %261 : f32, !llvm.ptr
    %262 = llvm.add %242, %10 : i64
    llvm.br ^bb30(%262 : i64)
  ^bb32:  // pred: ^bb30
    %263 = llvm.add %240, %10 : i64
    llvm.br ^bb28(%263 : i64)
  ^bb33:  // pred: ^bb28
    llvm.br ^bb34(%12 : i64)
  ^bb34(%264: i64):  // 2 preds: ^bb33, ^bb38
    %265 = llvm.icmp "slt" %264, %10 : i64
    llvm.cond_br %265, ^bb35, ^bb39
  ^bb35:  // pred: ^bb34
    llvm.br ^bb36(%12 : i64)
  ^bb36(%266: i64):  // 2 preds: ^bb35, ^bb37
    %267 = llvm.icmp "slt" %266, %9 : i64
    llvm.cond_br %267, ^bb37, ^bb38
  ^bb37:  // pred: ^bb36
    %268 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %269 = llvm.mlir.constant(8 : index) : i64
    %270 = llvm.mul %264, %269 overflow<nsw, nuw> : i64
    %271 = llvm.add %270, %266 overflow<nsw, nuw> : i64
    %272 = llvm.getelementptr inbounds|nuw %268[%271] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %273 = llvm.load %272 : !llvm.ptr -> f32
    %274 = llvm.fcmp "ugt" %273, %13 : f32
    %275 = llvm.select %274, %273, %13 : i1, f32
    %276 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %277 = llvm.mlir.constant(8 : index) : i64
    %278 = llvm.mul %264, %277 overflow<nsw, nuw> : i64
    %279 = llvm.add %278, %266 overflow<nsw, nuw> : i64
    %280 = llvm.getelementptr inbounds|nuw %276[%279] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %275, %280 : f32, !llvm.ptr
    %281 = llvm.add %266, %10 : i64
    llvm.br ^bb36(%281 : i64)
  ^bb38:  // pred: ^bb36
    %282 = llvm.add %264, %10 : i64
    llvm.br ^bb34(%282 : i64)
  ^bb39:  // pred: ^bb34
    %283 = llvm.mlir.constant(8 : index) : i64
    %284 = llvm.mlir.constant(2 : index) : i64
    %285 = llvm.mlir.constant(1 : index) : i64
    %286 = llvm.mlir.constant(16 : index) : i64
    %287 = llvm.mlir.zero : !llvm.ptr
    %288 = llvm.getelementptr %287[%286] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %289 = llvm.ptrtoint %288 : !llvm.ptr to i64
    %290 = llvm.mlir.constant(64 : index) : i64
    %291 = llvm.add %289, %290 : i64
    %292 = llvm.call @malloc(%291) : (i64) -> !llvm.ptr
    %293 = llvm.ptrtoint %292 : !llvm.ptr to i64
    %294 = llvm.mlir.constant(1 : index) : i64
    %295 = llvm.sub %290, %294 : i64
    %296 = llvm.add %293, %295 : i64
    %297 = llvm.urem %296, %290 : i64
    %298 = llvm.sub %296, %297 : i64
    %299 = llvm.inttoptr %298 : i64 to !llvm.ptr
    %300 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %301 = llvm.insertvalue %292, %300[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %302 = llvm.insertvalue %299, %301[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %303 = llvm.mlir.constant(0 : index) : i64
    %304 = llvm.insertvalue %303, %302[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %305 = llvm.insertvalue %283, %304[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %306 = llvm.insertvalue %284, %305[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %307 = llvm.insertvalue %284, %306[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %308 = llvm.insertvalue %285, %307[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb40(%12 : i64)
  ^bb40(%309: i64):  // 2 preds: ^bb39, ^bb44
    %310 = llvm.icmp "slt" %309, %9 : i64
    llvm.cond_br %310, ^bb41, ^bb45
  ^bb41:  // pred: ^bb40
    llvm.br ^bb42(%12 : i64)
  ^bb42(%311: i64):  // 2 preds: ^bb41, ^bb43
    %312 = llvm.icmp "slt" %311, %8 : i64
    llvm.cond_br %312, ^bb43, ^bb44
  ^bb43:  // pred: ^bb42
    %313 = llvm.extractvalue %49[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %314 = llvm.mlir.constant(8 : index) : i64
    %315 = llvm.mul %311, %314 overflow<nsw, nuw> : i64
    %316 = llvm.add %315, %309 overflow<nsw, nuw> : i64
    %317 = llvm.getelementptr inbounds|nuw %313[%316] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %318 = llvm.load %317 : !llvm.ptr -> f32
    %319 = llvm.extractvalue %308[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %320 = llvm.mlir.constant(2 : index) : i64
    %321 = llvm.mul %309, %320 overflow<nsw, nuw> : i64
    %322 = llvm.add %321, %311 overflow<nsw, nuw> : i64
    %323 = llvm.getelementptr inbounds|nuw %319[%322] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %318, %323 : f32, !llvm.ptr
    %324 = llvm.add %311, %10 : i64
    llvm.br ^bb42(%324 : i64)
  ^bb44:  // pred: ^bb42
    %325 = llvm.add %309, %10 : i64
    llvm.br ^bb40(%325 : i64)
  ^bb45:  // pred: ^bb40
    %326 = llvm.mlir.constant(1 : index) : i64
    %327 = llvm.mlir.constant(2 : index) : i64
    %328 = llvm.mlir.constant(1 : index) : i64
    %329 = llvm.mlir.constant(2 : index) : i64
    %330 = llvm.mlir.zero : !llvm.ptr
    %331 = llvm.getelementptr %330[%329] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %332 = llvm.ptrtoint %331 : !llvm.ptr to i64
    %333 = llvm.mlir.constant(64 : index) : i64
    %334 = llvm.add %332, %333 : i64
    %335 = llvm.call @malloc(%334) : (i64) -> !llvm.ptr
    %336 = llvm.ptrtoint %335 : !llvm.ptr to i64
    %337 = llvm.mlir.constant(1 : index) : i64
    %338 = llvm.sub %333, %337 : i64
    %339 = llvm.add %336, %338 : i64
    %340 = llvm.urem %339, %333 : i64
    %341 = llvm.sub %339, %340 : i64
    %342 = llvm.inttoptr %341 : i64 to !llvm.ptr
    %343 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %344 = llvm.insertvalue %335, %343[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %345 = llvm.insertvalue %342, %344[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %346 = llvm.mlir.constant(0 : index) : i64
    %347 = llvm.insertvalue %346, %345[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %348 = llvm.insertvalue %326, %347[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %349 = llvm.insertvalue %327, %348[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %350 = llvm.insertvalue %327, %349[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %351 = llvm.insertvalue %328, %350[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %352 = llvm.mlir.constant(1 : index) : i64
    %353 = llvm.mlir.constant(2 : index) : i64
    %354 = llvm.mlir.constant(1 : index) : i64
    %355 = llvm.mlir.constant(2 : index) : i64
    %356 = llvm.mlir.zero : !llvm.ptr
    %357 = llvm.getelementptr %356[%355] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %358 = llvm.ptrtoint %357 : !llvm.ptr to i64
    %359 = llvm.mlir.constant(64 : index) : i64
    %360 = llvm.add %358, %359 : i64
    %361 = llvm.call @malloc(%360) : (i64) -> !llvm.ptr
    %362 = llvm.ptrtoint %361 : !llvm.ptr to i64
    %363 = llvm.mlir.constant(1 : index) : i64
    %364 = llvm.sub %359, %363 : i64
    %365 = llvm.add %362, %364 : i64
    %366 = llvm.urem %365, %359 : i64
    %367 = llvm.sub %365, %366 : i64
    %368 = llvm.inttoptr %367 : i64 to !llvm.ptr
    %369 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %370 = llvm.insertvalue %361, %369[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %371 = llvm.insertvalue %368, %370[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %372 = llvm.mlir.constant(0 : index) : i64
    %373 = llvm.insertvalue %372, %371[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %374 = llvm.insertvalue %352, %373[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %375 = llvm.insertvalue %353, %374[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %376 = llvm.insertvalue %353, %375[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %377 = llvm.insertvalue %354, %376[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb46(%12 : i64)
  ^bb46(%378: i64):  // 2 preds: ^bb45, ^bb50
    %379 = llvm.icmp "slt" %378, %10 : i64
    llvm.cond_br %379, ^bb47, ^bb51
  ^bb47:  // pred: ^bb46
    llvm.br ^bb48(%12 : i64)
  ^bb48(%380: i64):  // 2 preds: ^bb47, ^bb49
    %381 = llvm.icmp "slt" %380, %8 : i64
    llvm.cond_br %381, ^bb49, ^bb50
  ^bb49:  // pred: ^bb48
    %382 = llvm.extractvalue %377[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %383 = llvm.mlir.constant(2 : index) : i64
    %384 = llvm.mul %378, %383 overflow<nsw, nuw> : i64
    %385 = llvm.add %384, %380 overflow<nsw, nuw> : i64
    %386 = llvm.getelementptr inbounds|nuw %382[%385] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %13, %386 : f32, !llvm.ptr
    %387 = llvm.add %380, %10 : i64
    llvm.br ^bb48(%387 : i64)
  ^bb50:  // pred: ^bb48
    %388 = llvm.add %378, %10 : i64
    llvm.br ^bb46(%388 : i64)
  ^bb51:  // pred: ^bb46
    llvm.br ^bb52(%12 : i64)
  ^bb52(%389: i64):  // 2 preds: ^bb51, ^bb59
    %390 = llvm.icmp "slt" %389, %10 : i64
    llvm.cond_br %390, ^bb53, ^bb60
  ^bb53:  // pred: ^bb52
    llvm.br ^bb54(%12 : i64)
  ^bb54(%391: i64):  // 2 preds: ^bb53, ^bb58
    %392 = llvm.icmp "slt" %391, %8 : i64
    llvm.cond_br %392, ^bb55, ^bb59
  ^bb55:  // pred: ^bb54
    llvm.br ^bb56(%12 : i64)
  ^bb56(%393: i64):  // 2 preds: ^bb55, ^bb57
    %394 = llvm.icmp "slt" %393, %9 : i64
    llvm.cond_br %394, ^bb57, ^bb58
  ^bb57:  // pred: ^bb56
    %395 = llvm.extractvalue %154[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %396 = llvm.mlir.constant(8 : index) : i64
    %397 = llvm.mul %389, %396 overflow<nsw, nuw> : i64
    %398 = llvm.add %397, %393 overflow<nsw, nuw> : i64
    %399 = llvm.getelementptr inbounds|nuw %395[%398] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %400 = llvm.load %399 : !llvm.ptr -> f32
    %401 = llvm.extractvalue %308[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %402 = llvm.mlir.constant(2 : index) : i64
    %403 = llvm.mul %393, %402 overflow<nsw, nuw> : i64
    %404 = llvm.add %403, %391 overflow<nsw, nuw> : i64
    %405 = llvm.getelementptr inbounds|nuw %401[%404] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %406 = llvm.load %405 : !llvm.ptr -> f32
    %407 = llvm.extractvalue %377[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %408 = llvm.mlir.constant(2 : index) : i64
    %409 = llvm.mul %389, %408 overflow<nsw, nuw> : i64
    %410 = llvm.add %409, %391 overflow<nsw, nuw> : i64
    %411 = llvm.getelementptr inbounds|nuw %407[%410] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %412 = llvm.load %411 : !llvm.ptr -> f32
    %413 = llvm.fmul %400, %406 : f32
    %414 = llvm.fadd %412, %413 : f32
    %415 = llvm.extractvalue %377[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %416 = llvm.mlir.constant(2 : index) : i64
    %417 = llvm.mul %389, %416 overflow<nsw, nuw> : i64
    %418 = llvm.add %417, %391 overflow<nsw, nuw> : i64
    %419 = llvm.getelementptr inbounds|nuw %415[%418] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %414, %419 : f32, !llvm.ptr
    %420 = llvm.add %393, %10 : i64
    llvm.br ^bb56(%420 : i64)
  ^bb58:  // pred: ^bb56
    %421 = llvm.add %391, %10 : i64
    llvm.br ^bb54(%421 : i64)
  ^bb59:  // pred: ^bb54
    %422 = llvm.add %389, %10 : i64
    llvm.br ^bb52(%422 : i64)
  ^bb60:  // pred: ^bb52
    llvm.br ^bb61(%12 : i64)
  ^bb61(%423: i64):  // 2 preds: ^bb60, ^bb65
    %424 = llvm.icmp "slt" %423, %10 : i64
    llvm.cond_br %424, ^bb62, ^bb66
  ^bb62:  // pred: ^bb61
    llvm.br ^bb63(%12 : i64)
  ^bb63(%425: i64):  // 2 preds: ^bb62, ^bb64
    %426 = llvm.icmp "slt" %425, %8 : i64
    llvm.cond_br %426, ^bb64, ^bb65
  ^bb64:  // pred: ^bb63
    %427 = llvm.extractvalue %29[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %428 = llvm.getelementptr inbounds|nuw %427[%425] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %429 = llvm.load %428 : !llvm.ptr -> f32
    %430 = llvm.extractvalue %351[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %431 = llvm.mlir.constant(2 : index) : i64
    %432 = llvm.mul %423, %431 overflow<nsw, nuw> : i64
    %433 = llvm.add %432, %425 overflow<nsw, nuw> : i64
    %434 = llvm.getelementptr inbounds|nuw %430[%433] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %429, %434 : f32, !llvm.ptr
    %435 = llvm.add %425, %10 : i64
    llvm.br ^bb63(%435 : i64)
  ^bb65:  // pred: ^bb63
    %436 = llvm.add %423, %10 : i64
    llvm.br ^bb61(%436 : i64)
  ^bb66:  // pred: ^bb61
    llvm.br ^bb67(%12 : i64)
  ^bb67(%437: i64):  // 2 preds: ^bb66, ^bb71
    %438 = llvm.icmp "slt" %437, %10 : i64
    llvm.cond_br %438, ^bb68, ^bb72
  ^bb68:  // pred: ^bb67
    llvm.br ^bb69(%12 : i64)
  ^bb69(%439: i64):  // 2 preds: ^bb68, ^bb70
    %440 = llvm.icmp "slt" %439, %8 : i64
    llvm.cond_br %440, ^bb70, ^bb71
  ^bb70:  // pred: ^bb69
    %441 = llvm.extractvalue %377[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %442 = llvm.mlir.constant(2 : index) : i64
    %443 = llvm.mul %437, %442 overflow<nsw, nuw> : i64
    %444 = llvm.add %443, %439 overflow<nsw, nuw> : i64
    %445 = llvm.getelementptr inbounds|nuw %441[%444] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %446 = llvm.load %445 : !llvm.ptr -> f32
    %447 = llvm.extractvalue %351[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %448 = llvm.mlir.constant(2 : index) : i64
    %449 = llvm.mul %437, %448 overflow<nsw, nuw> : i64
    %450 = llvm.add %449, %439 overflow<nsw, nuw> : i64
    %451 = llvm.getelementptr inbounds|nuw %447[%450] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %452 = llvm.load %451 : !llvm.ptr -> f32
    %453 = llvm.fadd %446, %452 : f32
    %454 = llvm.extractvalue %351[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %455 = llvm.mlir.constant(2 : index) : i64
    %456 = llvm.mul %437, %455 overflow<nsw, nuw> : i64
    %457 = llvm.add %456, %439 overflow<nsw, nuw> : i64
    %458 = llvm.getelementptr inbounds|nuw %454[%457] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %453, %458 : f32, !llvm.ptr
    %459 = llvm.add %439, %10 : i64
    llvm.br ^bb69(%459 : i64)
  ^bb71:  // pred: ^bb69
    %460 = llvm.add %437, %10 : i64
    llvm.br ^bb67(%460 : i64)
  ^bb72:  // pred: ^bb67
    llvm.return %351 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_mlp(%arg0: !llvm.ptr, %arg1: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.call @mlp(%1, %2, %3, %4, %5, %6, %7) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %8, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
}

{-#
  dialect_resources: {
    builtin: {
      torch_tensor_8_4_torch.float32: "0x04000000005475BB5E54893E16B3D2BE8066BCBEF43245BEEC4B093E404F22BCCEFACA3E70BF35BD4C7B073EACBB1ABE7048C9BDB891F4BE528BA9BEE80E53BE00BB973C60694A3E189B993E8C8DADBEFCF45EBE98F7393E4E94D43E48BDD2BD5C91BF3E400DA5BD10B5583D4ACDE73ECE7BEDBE6629A1BEE09E01BEDC9347BE282FDD3E",
      torch_tensor_8_torch.float32: "0x040000001AEFA5BEC0B06BBE1ADAB2BE76C2EFBE047095BE9E0EDC3EBC76643E0027783E",
      torch_tensor_2_8_torch.float32: "0x040000004952983C7B9C39BE6E01753D4D04A9BE68CC82BE4CA43ABE876C643E5D45543EF68F20BEF20251BCB38B673E12F5B33ECBAF0F3EA6A2433DF2BD723E522B55BE",
      torch_tensor_2_torch.float32: "0x0400000070ED863D65588CBE"
    }
  }
#-}
