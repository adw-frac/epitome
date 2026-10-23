source_filename = "LLVMDialectModule"

define void @__epitome_sme_matmul_f32(ptr %0, i64 %1, ptr %2, i64 %3, ptr %4, i64 %5, i64 %6, i64 %7) {
  tail call void @llvm.epitome.sme.start()
  tail call void @llvm.epitome.sme.ptrue.p0.s()
  tail call void @llvm.epitome.sme.whilelt.p1.s(i64 %7)
  br label %9

9:                                                ; preds = %9, %8
  %10 = phi i64 [ 0, %8 ], [ %14, %9 ]
  %11 = mul i64 %10, %1
  %12 = getelementptr float, ptr %0, i64 %11
  %13 = trunc i64 %10 to i32
  tail call void @llvm.epitome.sme.ld1w.za0h.s(ptr %12, i32 %13)
  %14 = add i64 %10, 1
  %15 = icmp slt i64 %14, 16
  br i1 %15, label %9, label %loop.preheader

loop.preheader:                                   ; preds = %9
  %16 = icmp sgt i64 %6, 0
  br i1 %16, label %17, label %25

17:                                               ; preds = %17, %loop.preheader
  %18 = phi i64 [ 0, %loop.preheader ], [ %23, %17 ]
  %19 = mul i64 %18, %3
  %20 = getelementptr float, ptr %2, i64 %19
  %21 = mul i64 %18, %5
  %22 = getelementptr float, ptr %4, i64 %21
  tail call void @llvm.epitome.sme.fmopa.za0.s(ptr %20, ptr %22)
  %23 = add i64 %18, 1
  %24 = icmp slt i64 %23, %6
  br i1 %24, label %17, label %25

25:                                               ; preds = %25, %17, %loop.preheader
  %26 = phi i64 [ %30, %25 ], [ 0, %loop.preheader ], [ 0, %17 ]
  %27 = mul i64 %26, %1
  %28 = getelementptr float, ptr %0, i64 %27
  %29 = trunc i64 %26 to i32
  tail call void @llvm.epitome.sme.st1w.za0h.s(ptr %28, i32 %29)
  %30 = add i64 %26, 1
  %31 = icmp slt i64 %30, 16
  br i1 %31, label %25, label %32

32:                                               ; preds = %25
  tail call void @llvm.epitome.sme.stop()
  ret void
}

define void @matmul(ptr %0, ptr %1, ptr %2) {
  %4 = tail call ptr @malloc(i64 1280)
  br label %loop.preheader

loop.preheader:                                   ; preds = %13, %3
  %5 = phi i64 [ 0, %3 ], [ %14, %13 ]
  %6 = mul i64 %5, 20
  br label %7

7:                                                ; preds = %7, %loop.preheader
  %8 = phi i64 [ 0, %loop.preheader ], [ %11, %7 ]
  %9 = add i64 %6, %8
  %10 = getelementptr float, ptr %4, i64 %9
  store float 0.000000e+00, ptr %10
  %11 = add i64 %8, 1
  %12 = icmp slt i64 %11, 20
  br i1 %12, label %7, label %13

13:                                               ; preds = %7
  %14 = add i64 %5, 1
  %15 = icmp slt i64 %14, 16
  br i1 %15, label %loop.preheader, label %16

16:                                               ; preds = %13
  %17 = tail call ptr @malloc(i64 256)
  br label %loop.preheader1

loop.preheader1:                                  ; preds = %30, %16
  %18 = phi i64 [ 0, %16 ], [ %31, %30 ]
  %19 = shl i64 %18, 4
  br label %20

20:                                               ; preds = %20, %loop.preheader1
  %21 = phi i64 [ 0, %loop.preheader1 ], [ %28, %20 ]
  %22 = shl i64 %21, 2
  %23 = add i64 %22, %18
  %24 = getelementptr float, ptr %0, i64 %23
  %25 = load float, ptr %24
  %26 = add i64 %19, %21
  %27 = getelementptr float, ptr %17, i64 %26
  store float %25, ptr %27
  %28 = add i64 %21, 1
  %29 = icmp slt i64 %28, 16
  br i1 %29, label %20, label %30

30:                                               ; preds = %20
  %31 = add i64 %18, 1
  %32 = icmp slt i64 %31, 4
  br i1 %32, label %loop.preheader1, label %33

33:                                               ; preds = %30
  %34 = ptrtoint ptr %17 to i64
  %35 = inttoptr i64 %34 to ptr
  %36 = ptrtoint ptr %1 to i64
  %37 = inttoptr i64 %36 to ptr
  %38 = ptrtoint ptr %4 to i64
  %39 = inttoptr i64 %38 to ptr
  br label %loop.preheader2

loop.preheader2:                                  ; preds = %76, %33
  %40 = phi i64 [ 0, %33 ], [ %77, %76 ]
  %41 = mul i64 %40, 20
  %42 = getelementptr float, ptr %35, i64 %40
  br label %43

43:                                               ; preds = %73, %loop.preheader2
  %44 = phi i64 [ 0, %loop.preheader2 ], [ %74, %73 ]
  %45 = sub i64 20, %44
  %46 = icmp slt i64 %45, 16
  %47 = select i1 %46, i64 %45, i64 16
  %48 = add i64 %41, %44
  %49 = getelementptr float, ptr %39, i64 %48
  %50 = getelementptr float, ptr %37, i64 %44
  tail call void @llvm.epitome.sme.start()
  tail call void @llvm.epitome.sme.ptrue.p0.s()
  tail call void @llvm.epitome.sme.whilelt.p1.s(i64 %47)
  br label %51

51:                                               ; preds = %51, %43
  %52 = phi i64 [ 0, %43 ], [ %56, %51 ]
  %53 = mul i64 %52, 20
  %54 = getelementptr float, ptr %49, i64 %53
  %55 = trunc i64 %52 to i32
  tail call void @llvm.epitome.sme.ld1w.za0h.s(ptr %54, i32 %55)
  %56 = add i64 %52, 1
  %57 = icmp slt i64 %56, 16
  br i1 %57, label %51, label %58

58:                                               ; preds = %58, %51
  %59 = phi i64 [ %64, %58 ], [ 0, %51 ]
  %60 = shl i64 %59, 4
  %61 = getelementptr float, ptr %42, i64 %60
  %62 = mul i64 %59, 20
  %63 = getelementptr float, ptr %50, i64 %62
  tail call void @llvm.epitome.sme.fmopa.za0.s(ptr %61, ptr %63)
  %64 = add i64 %59, 1
  %65 = icmp slt i64 %64, 4
  br i1 %65, label %58, label %66

66:                                               ; preds = %66, %58
  %67 = phi i64 [ %71, %66 ], [ 0, %58 ]
  %68 = mul i64 %67, 20
  %69 = getelementptr float, ptr %49, i64 %68
  %70 = trunc i64 %67 to i32
  tail call void @llvm.epitome.sme.st1w.za0h.s(ptr %69, i32 %70)
  %71 = add i64 %67, 1
  %72 = icmp slt i64 %71, 16
  br i1 %72, label %66, label %73

73:                                               ; preds = %66
  tail call void @llvm.epitome.sme.stop()
  %74 = add i64 %44, 16
  %75 = icmp slt i64 %74, 20
  br i1 %75, label %43, label %76

76:                                               ; preds = %73
  %77 = add i64 %40, 16
  %78 = icmp slt i64 %77, 16
  br i1 %78, label %loop.preheader2, label %79

79:                                               ; preds = %76
  tail call void @free(ptr %17)
  tail call void @llvm.memcpy.p0.p0.i64(ptr %2, ptr %4, i64 1280, i1 false)
  tail call void @free(ptr %4)
  ret void
}

declare ptr @malloc(i64)

declare void @free(ptr)

declare void @llvm.epitome.sme.start()

declare void @llvm.epitome.sme.ptrue.p0.s()

declare void @llvm.epitome.sme.whilelt.p1.s(i64)

declare void @llvm.epitome.sme.stop()

declare void @llvm.epitome.sme.st1w.za0h.s(ptr, i32)

declare void @llvm.epitome.sme.fmopa.za0.s(ptr, ptr)

declare void @llvm.epitome.sme.ld1w.za0h.s(ptr, i32)

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)
