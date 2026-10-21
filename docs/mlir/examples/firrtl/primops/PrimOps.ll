; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"

declare void @free(ptr)

declare ptr @malloc(i64)

declare void @exit(i32)

define void @PrimOps_main() {
  %1 = call ptr @malloc(i64 78)
  call void @llvm.memset.p0.i64(ptr %1, i8 0, i64 78, i1 false)
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
  call void @PrimOps_eval(ptr %1)
  %9 = load i64, ptr %2, align 8
  br label %4

10:                                               ; preds = %4
  call void @free(ptr %1)
  ret void
}

define void @PrimOps_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i8, ptr %3, align 1
  %5 = zext i8 %4 to i9
  %6 = getelementptr i8, ptr %0, i32 25
  %7 = load i4, ptr %6, align 1
  %8 = zext i4 %7 to i9
  %9 = add i9 %5, %8
  %10 = getelementptr i8, ptr %0, i32 30
  store i9 %9, ptr %10, align 2
  %11 = sub i9 %5, %8
  %12 = getelementptr i8, ptr %0, i32 32
  store i9 %11, ptr %12, align 2
  %13 = load i4, ptr %6, align 1
  %14 = zext i4 %13 to i12
  %15 = load i8, ptr %3, align 1
  %16 = zext i8 %15 to i12
  %17 = mul i12 %16, %14
  %18 = getelementptr i8, ptr %0, i32 34
  store i12 %17, ptr %18, align 2
  %19 = load i4, ptr %6, align 1
  %20 = zext i4 %19 to i8
  %21 = load i8, ptr %3, align 1
  %22 = icmp eq i8 %20, 0
  %23 = select i1 %22, i8 1, i8 %20
  %24 = udiv i8 %21, %23
  %25 = getelementptr i8, ptr %0, i32 36
  store i8 %24, ptr %25, align 1
  %26 = load i8, ptr %3, align 1
  %27 = urem i8 %26, %23
  %28 = trunc i8 %27 to i4
  %29 = getelementptr i8, ptr %0, i32 37
  store i4 %28, ptr %29, align 1
  %30 = getelementptr i8, ptr %0, i32 27
  %31 = load i4, ptr %30, align 1
  %32 = lshr i4 %31, 3
  %33 = trunc i4 %32 to i1
  %34 = getelementptr i8, ptr %0, i32 26
  %35 = load i8, ptr %34, align 1
  %36 = sext i1 %33 to i5
  %37 = zext i4 %31 to i9
  %38 = zext i5 %36 to i9
  %39 = shl i9 %38, 4
  %40 = or i9 %37, %39
  %41 = lshr i8 %35, 7
  %42 = trunc i8 %41 to i1
  %43 = zext i8 %35 to i9
  %44 = zext i1 %42 to i9
  %45 = shl i9 %44, 8
  %46 = or i9 %43, %45
  %47 = icmp eq i9 %40, 0
  %48 = icmp eq i9 %46, -256
  %49 = icmp eq i9 %40, -1
  %50 = and i1 %48, %49
  %51 = or i1 %47, %50
  %52 = select i1 %51, i9 1, i9 %40
  %53 = sdiv i9 %46, %52
  %54 = select i1 %50, i9 -256, i9 %53
  %55 = getelementptr i8, ptr %0, i32 38
  store i9 %54, ptr %55, align 2
  %56 = load i4, ptr %30, align 1
  %57 = sext i1 %33 to i4
  %58 = zext i4 %56 to i8
  %59 = zext i4 %57 to i8
  %60 = shl i8 %59, 4
  %61 = or i8 %58, %60
  %62 = load i8, ptr %34, align 1
  %63 = icmp eq i8 %61, 0
  %64 = icmp eq i8 %62, -128
  %65 = icmp eq i8 %61, -1
  %66 = and i1 %64, %65
  %67 = or i1 %63, %66
  %68 = select i1 %67, i8 1, i8 %61
  %69 = srem i8 %62, %68
  %70 = select i1 %66, i8 0, i8 %69
  %71 = trunc i8 %70 to i4
  %72 = getelementptr i8, ptr %0, i32 40
  store i4 %71, ptr %72, align 1
  %73 = load i8, ptr %3, align 1
  %74 = icmp ult i8 %73, %20
  %75 = getelementptr i8, ptr %0, i32 41
  store i1 %74, ptr %75, align 1
  %76 = load i8, ptr %34, align 1
  %77 = icmp slt i8 %76, %61
  %78 = getelementptr i8, ptr %0, i32 42
  store i1 %77, ptr %78, align 1
  %79 = getelementptr i8, ptr %0, i32 44
  store i12 %14, ptr %79, align 2
  %80 = load i4, ptr %30, align 1
  %81 = sext i1 %33 to i8
  %82 = zext i4 %80 to i12
  %83 = zext i8 %81 to i12
  %84 = shl i12 %83, 4
  %85 = or i12 %82, %84
  %86 = getelementptr i8, ptr %0, i32 46
  store i12 %85, ptr %86, align 2
  %87 = load i8, ptr %34, align 1
  %88 = getelementptr i8, ptr %0, i32 48
  store i8 %87, ptr %88, align 1
  %89 = load i8, ptr %3, align 1
  %90 = zext i8 %89 to i11
  %91 = shl i11 %90, 3
  %92 = getelementptr i8, ptr %0, i32 50
  store i11 %91, ptr %92, align 2
  %93 = load i8, ptr %3, align 1
  %94 = lshr i8 %93, 3
  %95 = trunc i8 %94 to i5
  %96 = getelementptr i8, ptr %0, i32 52
  store i5 %95, ptr %96, align 1
  %97 = load i8, ptr %34, align 1
  %98 = lshr i8 %97, 3
  %99 = trunc i8 %98 to i5
  %100 = getelementptr i8, ptr %0, i32 53
  store i5 %99, ptr %100, align 1
  %101 = load i4, ptr %6, align 1
  %102 = load i8, ptr %3, align 1
  %103 = zext i4 %101 to i23
  %104 = zext i8 %102 to i23
  %105 = shl i23 %104, %103
  %106 = icmp uge i23 %103, 23
  %107 = select i1 %106, i23 0, i23 %105
  %108 = getelementptr i8, ptr %0, i32 56
  store i23 %107, ptr %108, align 4
  %109 = load i8, ptr %3, align 1
  %110 = lshr i8 %109, %20
  %111 = icmp uge i8 %20, 8
  %112 = select i1 %111, i8 0, i8 %110
  %113 = getelementptr i8, ptr %0, i32 59
  store i8 %112, ptr %113, align 1
  %114 = load i8, ptr %34, align 1
  %115 = call i8 @llvm.umin.i8(i8 %20, i8 7)
  %116 = ashr i8 %114, %115
  %117 = getelementptr i8, ptr %0, i32 60
  store i8 %116, ptr %117, align 1
  %118 = getelementptr i8, ptr %0, i32 62
  store i9 %5, ptr %118, align 2
  %119 = sub i9 0, %5
  %120 = getelementptr i8, ptr %0, i32 64
  store i9 %119, ptr %120, align 2
  %121 = load i8, ptr %3, align 1
  %122 = xor i8 %121, -1
  %123 = getelementptr i8, ptr %0, i32 66
  store i8 %122, ptr %123, align 1
  %124 = load i8, ptr %3, align 1
  %125 = load i4, ptr %6, align 1
  %126 = trunc i8 %124 to i4
  %127 = and i4 %126, %125
  %128 = zext i4 %127 to i8
  %129 = getelementptr i8, ptr %0, i32 67
  store i8 %128, ptr %129, align 1
  %130 = load i8, ptr %3, align 1
  %131 = icmp eq i8 %130, -1
  %132 = getelementptr i8, ptr %0, i32 68
  store i1 %131, ptr %132, align 1
  %133 = load i8, ptr %3, align 1
  %134 = icmp ne i8 %133, 0
  %135 = getelementptr i8, ptr %0, i32 69
  store i1 %134, ptr %135, align 1
  %136 = load i8, ptr %3, align 1
  %137 = call i8 @llvm.ctpop.i8(i8 %136)
  %138 = trunc i8 %137 to i1
  %139 = getelementptr i8, ptr %0, i32 70
  store i1 %138, ptr %139, align 1
  %140 = load i8, ptr %3, align 1
  %141 = load i4, ptr %6, align 1
  %142 = getelementptr i8, ptr %0, i32 28
  %143 = load i1, ptr %142, align 1
  %144 = zext i1 %143 to i13
  %145 = zext i8 %140 to i13
  %146 = shl i13 %145, 5
  %147 = or i13 %144, %146
  %148 = zext i4 %141 to i13
  %149 = shl i13 %148, 1
  %150 = or i13 %147, %149
  %151 = getelementptr i8, ptr %0, i32 72
  store i13 %150, ptr %151, align 2
  %152 = load i8, ptr %3, align 1
  %153 = lshr i8 %152, 2
  %154 = trunc i8 %153 to i5
  %155 = getelementptr i8, ptr %0, i32 74
  store i5 %154, ptr %155, align 1
  %156 = load i8, ptr %3, align 1
  %157 = lshr i8 %156, 5
  %158 = trunc i8 %157 to i3
  %159 = getelementptr i8, ptr %0, i32 75
  store i3 %158, ptr %159, align 1
  %160 = load i8, ptr %3, align 1
  %161 = trunc i8 %160 to i5
  %162 = getelementptr i8, ptr %0, i32 76
  store i5 %161, ptr %162, align 1
  %163 = load i1, ptr %142, align 1
  %164 = load i8, ptr %3, align 1
  %165 = select i1 %163, i8 %164, i8 %20
  %166 = getelementptr i8, ptr %0, i32 77
  store i8 %165, ptr %166, align 1
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umin.i8(i8, i8) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.ctpop.i8(i8) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
