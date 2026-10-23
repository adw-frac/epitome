; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

declare void @free(ptr)

declare ptr @malloc(i64)

declare void @exit(i32)

define void @CombOps_main() {
  %1 = call ptr @malloc(i64 65)
  call void @llvm.memset.p0.i64(ptr %1, i8 0, i64 65, i1 false)
  %2 = getelementptr i8, ptr %1, i32 16
  %3 = load i64, ptr %2, align 8
  br label %4

4:                                                ; preds = %7, %0
  %5 = phi i64 [ %9, %7 ], [ %3, %0 ]
  %6 = icmp ne i64 %5, -1
  br i1 %6, label %7, label %10

7:                                                ; preds = %4
  %8 = phi i64 [ %5, %4 ]
  store i64 %8, ptr %1, align 8
  call void @CombOps_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @free(ptr %1)
  ret void
}

define void @CombOps_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i8, ptr %3, align 1
  %5 = getelementptr i8, ptr %0, i32 25
  %6 = load i8, ptr %5, align 1
  %7 = add i8 %4, %6
  %8 = getelementptr i8, ptr %0, i32 30
  store i8 %7, ptr %8, align 1
  %9 = load i8, ptr %3, align 1
  %10 = load i8, ptr %5, align 1
  %11 = sub i8 %9, %10
  %12 = getelementptr i8, ptr %0, i32 31
  store i8 %11, ptr %12, align 1
  %13 = load i8, ptr %3, align 1
  %14 = load i8, ptr %5, align 1
  %15 = mul i8 %13, %14
  %16 = getelementptr i8, ptr %0, i32 32
  store i8 %15, ptr %16, align 1
  %17 = load i8, ptr %3, align 1
  %18 = load i8, ptr %5, align 1
  %19 = icmp eq i8 %18, 0
  %20 = select i1 %19, i8 1, i8 %18
  %21 = udiv i8 %17, %20
  %22 = getelementptr i8, ptr %0, i32 33
  store i8 %21, ptr %22, align 1
  %23 = load i8, ptr %3, align 1
  %24 = load i8, ptr %5, align 1
  %25 = icmp eq i8 %24, 0
  %26 = icmp eq i8 %23, -128
  %27 = icmp eq i8 %24, -1
  %28 = and i1 %26, %27
  %29 = or i1 %25, %28
  %30 = select i1 %29, i8 1, i8 %24
  %31 = sdiv i8 %23, %30
  %32 = select i1 %28, i8 -128, i8 %31
  %33 = getelementptr i8, ptr %0, i32 34
  store i8 %32, ptr %33, align 1
  %34 = load i8, ptr %3, align 1
  %35 = load i8, ptr %5, align 1
  %36 = icmp eq i8 %35, 0
  %37 = select i1 %36, i8 1, i8 %35
  %38 = urem i8 %34, %37
  %39 = getelementptr i8, ptr %0, i32 35
  store i8 %38, ptr %39, align 1
  %40 = load i8, ptr %3, align 1
  %41 = load i8, ptr %5, align 1
  %42 = icmp eq i8 %41, 0
  %43 = icmp eq i8 %40, -128
  %44 = icmp eq i8 %41, -1
  %45 = and i1 %43, %44
  %46 = or i1 %42, %45
  %47 = select i1 %46, i8 1, i8 %41
  %48 = srem i8 %40, %47
  %49 = select i1 %45, i8 0, i8 %48
  %50 = getelementptr i8, ptr %0, i32 36
  store i8 %49, ptr %50, align 1
  %51 = load i8, ptr %3, align 1
  %52 = load i8, ptr %5, align 1
  %53 = shl i8 %51, %52
  %54 = icmp uge i8 %52, 8
  %55 = select i1 %54, i8 0, i8 %53
  %56 = getelementptr i8, ptr %0, i32 37
  store i8 %55, ptr %56, align 1
  %57 = load i8, ptr %3, align 1
  %58 = load i8, ptr %5, align 1
  %59 = lshr i8 %57, %58
  %60 = icmp uge i8 %58, 8
  %61 = select i1 %60, i8 0, i8 %59
  %62 = getelementptr i8, ptr %0, i32 38
  store i8 %61, ptr %62, align 1
  %63 = load i8, ptr %3, align 1
  %64 = load i8, ptr %5, align 1
  %65 = call i8 @llvm.umin.i8(i8 %64, i8 7)
  %66 = ashr i8 %63, %65
  %67 = getelementptr i8, ptr %0, i32 39
  store i8 %66, ptr %67, align 1
  %68 = load i8, ptr %3, align 1
  %69 = load i8, ptr %5, align 1
  %70 = and i8 %68, %69
  %71 = getelementptr i8, ptr %0, i32 40
  store i8 %70, ptr %71, align 1
  %72 = load i8, ptr %3, align 1
  %73 = load i8, ptr %5, align 1
  %74 = or i8 %72, %73
  %75 = getelementptr i8, ptr %0, i32 41
  store i8 %74, ptr %75, align 1
  %76 = load i8, ptr %3, align 1
  %77 = load i8, ptr %5, align 1
  %78 = xor i8 %76, %77
  %79 = getelementptr i8, ptr %0, i32 42
  store i8 %78, ptr %79, align 1
  %80 = load i8, ptr %3, align 1
  %81 = xor i8 %80, -1
  %82 = getelementptr i8, ptr %0, i32 43
  store i8 %81, ptr %82, align 1
  %83 = load i8, ptr %3, align 1
  %84 = load i8, ptr %5, align 1
  %85 = icmp ult i8 %83, %84
  %86 = getelementptr i8, ptr %0, i32 44
  store i1 %85, ptr %86, align 1
  %87 = load i8, ptr %3, align 1
  %88 = load i8, ptr %5, align 1
  %89 = icmp slt i8 %87, %88
  %90 = getelementptr i8, ptr %0, i32 45
  store i1 %89, ptr %90, align 1
  %91 = load i8, ptr %3, align 1
  %92 = load i8, ptr %5, align 1
  %93 = icmp eq i8 %91, %92
  %94 = getelementptr i8, ptr %0, i32 46
  store i1 %93, ptr %94, align 1
  %95 = load i8, ptr %3, align 1
  %96 = load i8, ptr %5, align 1
  %97 = icmp ne i8 %95, %96
  %98 = getelementptr i8, ptr %0, i32 47
  store i1 %97, ptr %98, align 1
  %99 = load i8, ptr %3, align 1
  %100 = load i8, ptr %5, align 1
  %101 = icmp uge i8 %99, %100
  %102 = getelementptr i8, ptr %0, i32 48
  store i1 %101, ptr %102, align 1
  %103 = load i8, ptr %3, align 1
  %104 = load i8, ptr %5, align 1
  %105 = icmp sgt i8 %103, %104
  %106 = getelementptr i8, ptr %0, i32 49
  store i1 %105, ptr %106, align 1
  %107 = load i8, ptr %3, align 1
  %108 = load i8, ptr %5, align 1
  %109 = icmp eq i8 %107, %108
  %110 = getelementptr i8, ptr %0, i32 50
  store i1 %109, ptr %110, align 1
  %111 = load i8, ptr %3, align 1
  %112 = load i8, ptr %5, align 1
  %113 = icmp eq i8 %111, %112
  %114 = getelementptr i8, ptr %0, i32 51
  store i1 %113, ptr %114, align 1
  %115 = load i8, ptr %3, align 1
  %116 = call i8 @llvm.ctpop.i8(i8 %115)
  %117 = trunc i8 %116 to i1
  %118 = getelementptr i8, ptr %0, i32 52
  store i1 %117, ptr %118, align 1
  %119 = load i8, ptr %3, align 1
  %120 = lshr i8 %119, 2
  %121 = trunc i8 %120 to i4
  %122 = getelementptr i8, ptr %0, i32 53
  store i4 %121, ptr %122, align 1
  %123 = load i8, ptr %3, align 1
  %124 = getelementptr i8, ptr %0, i32 28
  %125 = load i12, ptr %124, align 2
  %126 = zext i12 %125 to i20
  %127 = zext i8 %123 to i20
  %128 = shl i20 %127, 12
  %129 = or i20 %126, %128
  %130 = getelementptr i8, ptr %0, i32 56
  store i20 %129, ptr %130, align 4
  %131 = load i8, ptr %3, align 1
  %132 = zext i8 %131 to i24
  %133 = shl i24 %132, 16
  %134 = or i24 %132, %133
  %135 = shl i24 %132, 8
  %136 = or i24 %134, %135
  %137 = getelementptr i8, ptr %0, i32 60
  store i24 %136, ptr %137, align 4
  %138 = getelementptr i8, ptr %0, i32 26
  %139 = load i1, ptr %138, align 1
  %140 = load i8, ptr %3, align 1
  %141 = load i8, ptr %5, align 1
  %142 = select i1 %139, i8 %140, i8 %141
  %143 = getelementptr i8, ptr %0, i32 63
  store i8 %142, ptr %143, align 1
  %144 = load i8, ptr %3, align 1
  %145 = call i8 @llvm.bitreverse.i8(i8 %144)
  %146 = getelementptr i8, ptr %0, i32 64
  store i8 %145, ptr %146, align 1
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umin.i8(i8, i8) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.ctpop.i8(i8) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.bitreverse.i8(i8) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
