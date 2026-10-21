source_filename = "LLVMDialectModule"

define void @__epitome_sme_matmul_f32(ptr %0, i64 %1, ptr %2, i64 %3, ptr %4, i64 %5, i64 %6, i64 %7) {
  call void @llvm.epitome.sme.start()
  call void @llvm.epitome.sme.ptrue.p0.s()
  call void @llvm.epitome.sme.whilelt.p1.s(i64 %7)
  br label %9

9:                                                ; preds = %12, %8
  %10 = phi i64 [ 0, %8 ], [ %16, %12 ]
  %11 = icmp slt i64 %10, 16
  br i1 %11, label %12, label %17

12:                                               ; preds = %9
  %13 = mul i64 %10, %1
  %14 = getelementptr float, ptr %0, i64 %13
  %15 = trunc i64 %10 to i32
  call void @llvm.epitome.sme.ld1w.za0h.s(ptr %14, i32 %15)
  %16 = add i64 %10, 1
  br label %9

17:                                               ; preds = %9
  br label %18

18:                                               ; preds = %21, %17
  %19 = phi i64 [ 0, %17 ], [ %26, %21 ]
  %20 = icmp slt i64 %19, %6
  br i1 %20, label %21, label %27

21:                                               ; preds = %18
  %22 = mul i64 %19, %3
  %23 = getelementptr float, ptr %2, i64 %22
  %24 = mul i64 %19, %5
  %25 = getelementptr float, ptr %4, i64 %24
  call void @llvm.epitome.sme.fmopa.za0.s(ptr %23, ptr %25)
  %26 = add i64 %19, 1
  br label %18

27:                                               ; preds = %18
  br label %28

28:                                               ; preds = %31, %27
  %29 = phi i64 [ 0, %27 ], [ %35, %31 ]
  %30 = icmp slt i64 %29, 16
  br i1 %30, label %31, label %36

31:                                               ; preds = %28
  %32 = mul i64 %29, %1
  %33 = getelementptr float, ptr %0, i64 %32
  %34 = trunc i64 %29 to i32
  call void @llvm.epitome.sme.st1w.za0h.s(ptr %33, i32 %34)
  %35 = add i64 %29, 1
  br label %28

36:                                               ; preds = %28
  call void @llvm.epitome.sme.stop()
  ret void
}

define void @matmul(ptr %0, ptr %1, ptr %2) {
  %4 = call ptr @malloc(i64 1280)
  br label %5

5:                                                ; preds = %17, %3
  %6 = phi i64 [ 0, %3 ], [ %18, %17 ]
  %7 = icmp slt i64 %6, 16
  br i1 %7, label %8, label %19

8:                                                ; preds = %5
  br label %9

9:                                                ; preds = %12, %8
  %10 = phi i64 [ 0, %8 ], [ %16, %12 ]
  %11 = icmp slt i64 %10, 20
  br i1 %11, label %12, label %17

12:                                               ; preds = %9
  %13 = mul i64 %6, 20
  %14 = add i64 %13, %10
  %15 = getelementptr float, ptr %4, i64 %14
  store float 0.000000e+00, ptr %15
  %16 = add i64 %10, 1
  br label %9

17:                                               ; preds = %9
  %18 = add i64 %6, 1
  br label %5

19:                                               ; preds = %5
  %20 = call ptr @malloc(i64 256)
  br label %21

21:                                               ; preds = %37, %19
  %22 = phi i64 [ 0, %19 ], [ %38, %37 ]
  %23 = icmp slt i64 %22, 4
  br i1 %23, label %24, label %39

24:                                               ; preds = %21
  br label %25

25:                                               ; preds = %28, %24
  %26 = phi i64 [ 0, %24 ], [ %36, %28 ]
  %27 = icmp slt i64 %26, 16
  br i1 %27, label %28, label %37

28:                                               ; preds = %25
  %29 = mul i64 %26, 4
  %30 = add i64 %29, %22
  %31 = getelementptr float, ptr %0, i64 %30
  %32 = load float, ptr %31
  %33 = mul i64 %22, 16
  %34 = add i64 %33, %26
  %35 = getelementptr float, ptr %20, i64 %34
  store float %32, ptr %35
  %36 = add i64 %26, 1
  br label %25

37:                                               ; preds = %25
  %38 = add i64 %22, 1
  br label %21

39:                                               ; preds = %21
  %40 = ptrtoint ptr %20 to i64
  %41 = inttoptr i64 %40 to ptr
  %42 = ptrtoint ptr %1 to i64
  %43 = inttoptr i64 %42 to ptr
  %44 = ptrtoint ptr %4 to i64
  %45 = inttoptr i64 %44 to ptr
  br label %46

46:                                               ; preds = %65, %39
  %47 = phi i64 [ 0, %39 ], [ %66, %65 ]
  %48 = icmp slt i64 %47, 16
  br i1 %48, label %49, label %67

49:                                               ; preds = %46
  br label %50

50:                                               ; preds = %53, %49
  %51 = phi i64 [ 0, %49 ], [ %64, %53 ]
  %52 = icmp slt i64 %51, 20
  br i1 %52, label %53, label %65

53:                                               ; preds = %50
  %54 = sub i64 20, %51
  %55 = icmp slt i64 %54, 16
  %56 = select i1 %55, i64 %54, i64 16
  %57 = mul i64 %47, 20
  %58 = add i64 %57, %51
  %59 = add i64 %58, 0
  %60 = getelementptr float, ptr %45, i64 %59
  %61 = getelementptr float, ptr %41, i64 %47
  %62 = add i64 %51, 0
  %63 = getelementptr float, ptr %43, i64 %62
  call void @__epitome_sme_matmul_f32(ptr %60, i64 20, ptr %61, i64 16, ptr %63, i64 20, i64 4, i64 %56)
  %64 = add i64 %51, 16
  br label %50

65:                                               ; preds = %50
  %66 = add i64 %47, 16
  br label %46

67:                                               ; preds = %46
  call void @free(ptr %20)
  call void @llvm.memcpy.p0.p0.i64(ptr %2, ptr %4, i64 1280, i1 false)
  call void @free(ptr %4)
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
