; ModuleID = 'smoke.c'
source_filename = "smoke.c"

@table = dso_local local_unnamed_addr global <{ i32, i32, i32, i32, [12 x i32] }> <{ i32 1, i32 2, i32 3, i32 4, [12 x i32] zeroinitializer }>, align 4
@.str = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@message = dso_local local_unnamed_addr global ptr @.str, align 8
@counter = external local_unnamed_addr global i32, align 4
@.str.1 = private unnamed_addr constant [10 x i8] c"%d %g %s\0A\00", align 1
@switch.table.calls = private unnamed_addr constant [8 x i32] [i32 10, i32 21, i32 32, i32 43, i32 -1, i32 -1, i32 -1, i32 74], align 4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 -32896, 98685) i32 @narrow(i8 noundef %0, i16 noundef %1, i8 noundef %2, i16 noundef %3) local_unnamed_addr #0 {
  %5 = sext i8 %0 to i32
  %6 = sext i16 %1 to i32
  %7 = add nsw i32 %6, %5
  %8 = zext i8 %2 to i32
  %9 = add nsw i32 %7, %8
  %10 = zext i16 %3 to i32
  %11 = add nsw i32 %9, %10
  ret i32 %11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i8 @add8(i8 noundef %0, i8 noundef %1) local_unnamed_addr #0 {
  %3 = add i8 %1, %0
  ret i8 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i16 @neg16(i16 noundef %0) local_unnamed_addr #0 {
  %2 = sub i16 0, %0
  ret i16 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @arith32(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = mul i32 %1, %0
  %4 = lshr i32 %0, 3
  %5 = add i32 %3, %4
  %6 = shl i32 %1, 5
  %7 = xor i32 %5, %6
  %8 = xor i32 %1, -1
  %9 = and i32 %0, %8
  %10 = or i32 %7, %9
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i64 @arith64(i64 noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = mul i64 %1, %0
  %4 = lshr i64 %0, 3
  %5 = add i64 %3, %4
  %6 = shl i64 %1, 5
  %7 = xor i64 %5, %6
  %8 = xor i64 %1, -1
  %9 = and i64 %0, %8
  %10 = or i64 %7, %9
  ret i64 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @sdiv(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = sdiv i32 %0, %1
  %4 = mul i32 %3, %1
  %5 = sub i32 %0, %4
  %6 = add nsw i32 %5, %3
  ret i32 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i64 @udiv(i64 noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = udiv i64 %0, %1
  %4 = mul i64 %3, %1
  %5 = sub i64 %0, %4
  %6 = add i64 %5, %3
  ret i64 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 -306783387, 306783388) i32 @div_const(i32 noundef %0) local_unnamed_addr #0 {
  %2 = sdiv i32 %0, 7
  %3 = srem i32 %0, 10
  %4 = add nsw i32 %2, %3
  ret i32 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i64 @constants() local_unnamed_addr #0 {
  ret i64 163971058432973790
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @min(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = tail call i32 @llvm.smin.i32(i32 %0, i32 %1)
  ret i32 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @umax(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = tail call i32 @llvm.umax.i32(i32 %0, i32 %1)
  ret i32 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 8) i32 @compare(i64 noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = icmp slt i64 %0, %1
  %4 = zext i1 %3 to i32
  %5 = icmp eq i64 %0, %1
  %6 = select i1 %5, i32 2, i32 0
  %7 = or disjoint i32 %6, %4
  %8 = icmp ugt i64 %0, %1
  %9 = select i1 %8, i32 4, i32 0
  %10 = or disjoint i32 %7, %9
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i1 @is_odd(i32 noundef %0) local_unnamed_addr #0 {
  %2 = and i32 %0, 1
  %3 = icmp ne i32 %2, 0
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 33) i32 @popcount(i32 noundef %0) local_unnamed_addr #0 {
  %2 = tail call range(i32 0, 33) i32 @llvm.ctpop.i32(i32 %0)
  ret i32 %2
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctpop.i32(i32) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 65) i32 @clz(i64 noundef %0) local_unnamed_addr #0 {
  %2 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %0, i1 false)
  %3 = trunc nuw nsw i64 %2 to i32
  ret i32 %3
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @bswap(i32 noundef %0) local_unnamed_addr #0 {
  %2 = tail call i32 @llvm.bswap.i32(i32 %0)
  ret i32 %2
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.bswap.i32(i32) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @rotate(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = tail call i32 @llvm.fshl.i32(i32 %0, i32 %0, i32 %1)
  ret i32 %3
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local i32 @sum(ptr noundef readonly captures(none) %0, i32 noundef %1) local_unnamed_addr #2 {
  %3 = icmp sgt i32 %1, 0
  br i1 %3, label %4, label %23

4:                                                ; preds = %2
  %5 = zext nneg i32 %1 to i64
  %6 = icmp ult i32 %1, 4
  br i1 %6, label %20, label %7

7:                                                ; preds = %4
  %8 = and i64 %5, 2147483644
  br label %9

9:                                                ; preds = %9, %7
  %10 = phi i64 [ 0, %7 ], [ %15, %9 ]
  %11 = phi <4 x i32> [ zeroinitializer, %7 ], [ %14, %9 ]
  %12 = getelementptr inbounds nuw i32, ptr %0, i64 %10
  %13 = load <4 x i32>, ptr %12, align 4, !tbaa !6
  %14 = add <4 x i32> %13, %11
  %15 = add nuw i64 %10, 4
  %16 = icmp eq i64 %15, %8
  br i1 %16, label %17, label %9, !llvm.loop !10

17:                                               ; preds = %9
  %18 = tail call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> %14)
  %19 = icmp eq i64 %8, %5
  br i1 %19, label %23, label %20

20:                                               ; preds = %4, %17
  %21 = phi i64 [ 0, %4 ], [ %8, %17 ]
  %22 = phi i32 [ 0, %4 ], [ %18, %17 ]
  br label %25

23:                                               ; preds = %25, %17, %2
  %24 = phi i32 [ 0, %2 ], [ %18, %17 ], [ %30, %25 ]
  ret i32 %24

25:                                               ; preds = %20, %25
  %26 = phi i64 [ %31, %25 ], [ %21, %20 ]
  %27 = phi i32 [ %30, %25 ], [ %22, %20 ]
  %28 = getelementptr inbounds nuw i32, ptr %0, i64 %26
  %29 = load i32, ptr %28, align 4, !tbaa !6
  %30 = add nsw i32 %29, %27
  %31 = add nuw nsw i64 %26, 1
  %32 = icmp eq i64 %31, %5
  br i1 %32, label %23, label %25, !llvm.loop !15
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #3

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @scale(ptr noundef captures(none) %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #4 {
  %4 = icmp sgt i32 %1, 0
  br i1 %4, label %5, label %23

5:                                                ; preds = %3
  %6 = zext nneg i32 %1 to i64
  %7 = icmp ult i32 %1, 4
  br i1 %7, label %21, label %8

8:                                                ; preds = %5
  %9 = and i64 %6, 2147483644
  %10 = insertelement <4 x i32> poison, i32 %2, i64 0
  %11 = shufflevector <4 x i32> %10, <4 x i32> poison, <4 x i32> zeroinitializer
  br label %12

12:                                               ; preds = %12, %8
  %13 = phi i64 [ 0, %8 ], [ %17, %12 ]
  %14 = getelementptr inbounds nuw i32, ptr %0, i64 %13
  %15 = load <4 x i32>, ptr %14, align 4, !tbaa !6
  %16 = mul nsw <4 x i32> %15, %11
  store <4 x i32> %16, ptr %14, align 4, !tbaa !6
  %17 = add nuw i64 %13, 4
  %18 = icmp eq i64 %17, %9
  br i1 %18, label %19, label %12, !llvm.loop !16

19:                                               ; preds = %12
  %20 = icmp eq i64 %9, %6
  br i1 %20, label %23, label %21

21:                                               ; preds = %5, %19
  %22 = phi i64 [ 0, %5 ], [ %9, %19 ]
  br label %24

23:                                               ; preds = %24, %19, %3
  ret void

24:                                               ; preds = %21, %24
  %25 = phi i64 [ %29, %24 ], [ %22, %21 ]
  %26 = getelementptr inbounds nuw i32, ptr %0, i64 %25
  %27 = load i32, ptr %26, align 4, !tbaa !6
  %28 = mul nsw i32 %27, %2
  store i32 %28, ptr %26, align 4, !tbaa !6
  %29 = add nuw nsw i64 %25, 1
  %30 = icmp eq i64 %29, %6
  br i1 %30, label %23, label %24, !llvm.loop !17
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 -1, 75) i32 @classify(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp ult i32 %0, 8
  br i1 %2, label %3, label %7

3:                                                ; preds = %1
  %4 = zext nneg i32 %0 to i64
  %5 = getelementptr inbounds nuw [8 x i32], ptr @switch.table.calls, i64 0, i64 %4
  %6 = load i32, ptr %5, align 4
  br label %7

7:                                                ; preds = %1, %3
  %8 = phi i32 [ %6, %3 ], [ -1, %1 ]
  ret i32 %8
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, argmem: read, inaccessiblemem: none) uwtable
define dso_local i32 @globals(i32 noundef %0) local_unnamed_addr #5 {
  %2 = load i32, ptr @counter, align 4, !tbaa !6
  %3 = and i32 %0, 15
  %4 = zext nneg i32 %3 to i64
  %5 = getelementptr inbounds nuw [16 x i32], ptr @table, i64 0, i64 %4
  %6 = load i32, ptr %5, align 4, !tbaa !6
  %7 = add nsw i32 %6, %2
  store i32 %7, ptr %5, align 4, !tbaa !6
  %8 = add nsw i32 %0, 1
  %9 = and i32 %8, 15
  %10 = zext nneg i32 %9 to i64
  %11 = getelementptr inbounds nuw [16 x i32], ptr @table, i64 0, i64 %10
  %12 = load i32, ptr %11, align 4, !tbaa !6
  %13 = load ptr, ptr @message, align 8, !tbaa !18
  %14 = load i8, ptr %13, align 1, !tbaa !21
  %15 = zext i8 %14 to i32
  %16 = add nsw i32 %12, %15
  ret i32 %16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @many_args(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3, i32 noundef %4, i32 noundef %5, i32 noundef %6, i32 noundef %7, i32 noundef %8, i32 noundef %9, i64 noundef %10) local_unnamed_addr #0 {
  %12 = mul nsw i32 %2, %1
  %13 = mul nsw i32 %5, %4
  %14 = mul nsw i32 %8, %7
  %15 = trunc i64 %10 to i32
  %16 = add i32 %12, %0
  %17 = add i32 %16, %13
  %18 = add i32 %3, %6
  %19 = add i32 %17, %14
  %20 = add i32 %18, %9
  %21 = sub i32 %19, %20
  %22 = add nsw i32 %21, %15
  ret i32 %22
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 -2147483639, -2147483648) i32 @calls(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp ult i32 %0, 8
  br i1 %2, label %3, label %7

3:                                                ; preds = %1
  %4 = zext nneg i32 %0 to i64
  %5 = getelementptr inbounds nuw [8 x i32], ptr @switch.table.calls, i64 0, i64 %4
  %6 = load i32, ptr %5, align 4
  br label %7

7:                                                ; preds = %1, %3
  %8 = phi i32 [ %6, %3 ], [ -1, %1 ]
  %9 = add i32 %0, 70
  %10 = add nsw i32 %9, %8
  ret i32 %10
}

; Function Attrs: nofree nounwind uwtable
define dso_local noundef i32 @variadic_call(i32 noundef %0, double noundef %1) local_unnamed_addr #6 {
  %3 = load ptr, ptr @message, align 8, !tbaa !18
  %4 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %0, double noundef %1, ptr noundef %3)
  ret i32 %4
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #7

; Function Attrs: nounwind uwtable
define dso_local i32 @big_frame(i32 noundef %0) local_unnamed_addr #8 {
  %2 = alloca [3000 x i32], align 4
  call void @llvm.lifetime.start.p0(i64 12000, ptr nonnull %2) #14
  call void @ext(ptr noundef nonnull %2) #14
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds [3000 x i32], ptr %2, i64 0, i64 %3
  store i32 %0, ptr %4, align 4, !tbaa !6
  call void @ext(ptr noundef nonnull %2) #14
  %5 = sub nsw i32 2999, %0
  %6 = sext i32 %5 to i64
  %7 = getelementptr inbounds [3000 x i32], ptr %2, i64 0, i64 %6
  %8 = load i32, ptr %7, align 4, !tbaa !6
  call void @llvm.lifetime.end.p0(i64 12000, ptr nonnull %2) #14
  ret i32 %8
}

declare void @ext(ptr noundef) local_unnamed_addr #9

; Function Attrs: nounwind uwtable
define dso_local i32 @many_live(ptr noundef %0) local_unnamed_addr #8 {
  %2 = load i32, ptr %0, align 4, !tbaa !6
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %4 = load i32, ptr %3, align 4, !tbaa !6
  %5 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %7 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 60
  %9 = load <8 x i32>, ptr %7, align 4, !tbaa !6
  %10 = load i32, ptr %8, align 4, !tbaa !6
  %11 = shufflevector <8 x i32> %9, <8 x i32> poison, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %12 = shufflevector <8 x i32> %9, <8 x i32> poison, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %13 = mul nsw <4 x i32> %11, %12
  %14 = add i32 %4, 1
  %15 = load <4 x i32>, ptr %5, align 4, !tbaa !6
  %16 = load <2 x i32>, ptr %6, align 4, !tbaa !6
  tail call void @ext(ptr noundef nonnull %0) #14
  %17 = shufflevector <2 x i32> %16, <2 x i32> poison, <4 x i32> <i32 0, i32 1, i32 poison, i32 poison>
  %18 = shufflevector <4 x i32> %15, <4 x i32> %17, <4 x i32> <i32 poison, i32 1, i32 3, i32 5>
  %19 = insertelement <4 x i32> %18, i32 %14, i64 0
  %20 = shufflevector <4 x i32> %15, <4 x i32> %17, <4 x i32> <i32 poison, i32 0, i32 2, i32 4>
  %21 = insertelement <4 x i32> %20, i32 %2, i64 0
  %22 = mul <4 x i32> %19, %21
  %23 = add <4 x i32> %22, %13
  %24 = tail call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> %23)
  %25 = add i32 %24, %10
  ret i32 %25
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef double @fp(double noundef %0, float noundef %1, i32 noundef %2, i64 noundef %3) local_unnamed_addr #0 {
  %5 = fpext float %1 to double
  %6 = sitofp i32 %2 to double
  %7 = tail call double @llvm.fmuladd.f64(double %0, double %5, double %6)
  %8 = sitofp i64 %3 to double
  %9 = fdiv double %8, %0
  %10 = fsub double %7, %9
  %11 = fsub double %0, %5
  %12 = fptrunc double %11 to float
  %13 = fpext float %12 to double
  %14 = fadd double %10, %13
  ret double %14
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef float @ffp(float noundef %0, float noundef %1) local_unnamed_addr #0 {
  %3 = fcmp olt float %0, %1
  br i1 %3, label %4, label %6

4:                                                ; preds = %2
  %5 = fmul float %0, %1
  br label %9

6:                                                ; preds = %2
  %7 = fdiv float %0, %1
  %8 = fadd float %7, 1.500000e+00
  br label %9

9:                                                ; preds = %6, %4
  %10 = phi float [ %5, %4 ], [ %8, %6 ]
  ret float %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 8) i32 @fcmp(double noundef %0, double noundef %1) local_unnamed_addr #0 {
  %3 = fcmp olt double %0, %1
  %4 = zext i1 %3 to i32
  %5 = fcmp oeq double %0, %1
  %6 = select i1 %5, i32 2, i32 0
  %7 = fcmp uno double %0, 0.000000e+00
  %8 = select i1 %7, i32 4, i32 0
  %9 = or disjoint i32 %8, %4
  %10 = or disjoint i32 %9, %6
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i64 @to_int(double noundef %0) local_unnamed_addr #0 {
  %2 = fptosi double %0 to i64
  %3 = fptrunc double %0 to float
  %4 = fptoui float %3 to i32
  %5 = zext i32 %4 to i64
  %6 = add nsw i64 %5, %2
  ret i64 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef double @to_fp(i64 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = uitofp i64 %0 to double
  %4 = sitofp i32 %1 to float
  %5 = fpext float %4 to double
  %6 = fadd double %3, %5
  ret double %6
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @vec_add(ptr noalias noundef writeonly captures(none) %0, ptr noalias noundef readonly captures(none) %1, ptr noalias noundef readonly captures(none) %2, i32 noundef %3) local_unnamed_addr #4 {
  %5 = icmp sgt i32 %3, 0
  br i1 %5, label %6, label %26

6:                                                ; preds = %4
  %7 = zext nneg i32 %3 to i64
  %8 = icmp ult i32 %3, 4
  br i1 %8, label %24, label %9

9:                                                ; preds = %6
  %10 = and i64 %7, 2147483644
  br label %11

11:                                               ; preds = %11, %9
  %12 = phi i64 [ 0, %9 ], [ %20, %11 ]
  %13 = getelementptr inbounds nuw i32, ptr %1, i64 %12
  %14 = load <4 x i32>, ptr %13, align 4, !tbaa !6
  %15 = getelementptr inbounds nuw i32, ptr %2, i64 %12
  %16 = load <4 x i32>, ptr %15, align 4, !tbaa !6
  %17 = mul nsw <4 x i32> %16, splat (i32 3)
  %18 = add nsw <4 x i32> %17, %14
  %19 = getelementptr inbounds nuw i32, ptr %0, i64 %12
  store <4 x i32> %18, ptr %19, align 4, !tbaa !6
  %20 = add nuw i64 %12, 4
  %21 = icmp eq i64 %20, %10
  br i1 %21, label %22, label %11, !llvm.loop !22

22:                                               ; preds = %11
  %23 = icmp eq i64 %10, %7
  br i1 %23, label %26, label %24

24:                                               ; preds = %6, %22
  %25 = phi i64 [ 0, %6 ], [ %10, %22 ]
  br label %27

26:                                               ; preds = %27, %22, %4
  ret void

27:                                               ; preds = %24, %27
  %28 = phi i64 [ %36, %27 ], [ %25, %24 ]
  %29 = getelementptr inbounds nuw i32, ptr %1, i64 %28
  %30 = load i32, ptr %29, align 4, !tbaa !6
  %31 = getelementptr inbounds nuw i32, ptr %2, i64 %28
  %32 = load i32, ptr %31, align 4, !tbaa !6
  %33 = mul nsw i32 %32, 3
  %34 = add nsw i32 %33, %30
  %35 = getelementptr inbounds nuw i32, ptr %0, i64 %28
  store i32 %34, ptr %35, align 4, !tbaa !6
  %36 = add nuw nsw i64 %28, 1
  %37 = icmp eq i64 %36, %7
  br i1 %37, label %26, label %27, !llvm.loop !23
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local float @vec_dot(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1, i32 noundef %2) local_unnamed_addr #2 {
  %4 = icmp sgt i32 %2, 0
  br i1 %4, label %5, label %26

5:                                                ; preds = %3
  %6 = zext nneg i32 %2 to i64
  %7 = icmp ult i32 %2, 4
  br i1 %7, label %23, label %8

8:                                                ; preds = %5
  %9 = and i64 %6, 2147483644
  br label %10

10:                                               ; preds = %10, %8
  %11 = phi i64 [ 0, %8 ], [ %19, %10 ]
  %12 = phi float [ 0.000000e+00, %8 ], [ %18, %10 ]
  %13 = getelementptr inbounds nuw float, ptr %0, i64 %11
  %14 = load <4 x float>, ptr %13, align 4, !tbaa !24
  %15 = getelementptr inbounds nuw float, ptr %1, i64 %11
  %16 = load <4 x float>, ptr %15, align 4, !tbaa !24
  %17 = fmul <4 x float> %14, %16
  %18 = tail call float @llvm.vector.reduce.fadd.v4f32(float %12, <4 x float> %17)
  %19 = add nuw i64 %11, 4
  %20 = icmp eq i64 %19, %9
  br i1 %20, label %21, label %10, !llvm.loop !26

21:                                               ; preds = %10
  %22 = icmp eq i64 %9, %6
  br i1 %22, label %26, label %23

23:                                               ; preds = %5, %21
  %24 = phi i64 [ 0, %5 ], [ %9, %21 ]
  %25 = phi float [ 0.000000e+00, %5 ], [ %18, %21 ]
  br label %28

26:                                               ; preds = %28, %21, %3
  %27 = phi float [ 0.000000e+00, %3 ], [ %18, %21 ], [ %35, %28 ]
  ret float %27

28:                                               ; preds = %23, %28
  %29 = phi i64 [ %36, %28 ], [ %24, %23 ]
  %30 = phi float [ %35, %28 ], [ %25, %23 ]
  %31 = getelementptr inbounds nuw float, ptr %0, i64 %29
  %32 = load float, ptr %31, align 4, !tbaa !24
  %33 = getelementptr inbounds nuw float, ptr %1, i64 %29
  %34 = load float, ptr %33, align 4, !tbaa !24
  %35 = tail call float @llvm.fmuladd.f32(float %32, float %34, float %30)
  %36 = add nuw nsw i64 %29, 1
  %37 = icmp eq i64 %36, %6
  br i1 %37, label %26, label %28, !llvm.loop !27
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #1

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @bytes(ptr noalias noundef captures(none) %0, ptr noalias noundef readonly captures(none) %1, i32 noundef %2) local_unnamed_addr #4 {
  %4 = icmp sgt i32 %2, 0
  br i1 %4, label %5, label %42

5:                                                ; preds = %3
  %6 = zext nneg i32 %2 to i64
  %7 = icmp ult i32 %2, 4
  br i1 %7, label %8, label %10

8:                                                ; preds = %25, %40, %5
  %9 = phi i64 [ 0, %5 ], [ %13, %25 ], [ %30, %40 ]
  br label %43

10:                                               ; preds = %5
  %11 = icmp ult i32 %2, 16
  br i1 %11, label %28, label %12

12:                                               ; preds = %10
  %13 = and i64 %6, 2147483632
  br label %14

14:                                               ; preds = %14, %12
  %15 = phi i64 [ 0, %12 ], [ %21, %14 ]
  %16 = getelementptr inbounds nuw i8, ptr %1, i64 %15
  %17 = load <16 x i8>, ptr %16, align 1, !tbaa !21
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 %15
  %19 = load <16 x i8>, ptr %18, align 1, !tbaa !21
  %20 = tail call <16 x i8> @llvm.umax.v16i8(<16 x i8> %17, <16 x i8> %19)
  store <16 x i8> %20, ptr %18, align 1, !tbaa !21
  %21 = add nuw i64 %15, 16
  %22 = icmp eq i64 %21, %13
  br i1 %22, label %23, label %14, !llvm.loop !28

23:                                               ; preds = %14
  %24 = icmp eq i64 %13, %6
  br i1 %24, label %42, label %25

25:                                               ; preds = %23
  %26 = and i64 %6, 12
  %27 = icmp eq i64 %26, 0
  br i1 %27, label %8, label %28

28:                                               ; preds = %25, %10
  %29 = phi i64 [ %13, %25 ], [ 0, %10 ]
  %30 = and i64 %6, 2147483644
  br label %31

31:                                               ; preds = %31, %28
  %32 = phi i64 [ %29, %28 ], [ %38, %31 ]
  %33 = getelementptr inbounds nuw i8, ptr %1, i64 %32
  %34 = load <4 x i8>, ptr %33, align 1, !tbaa !21
  %35 = getelementptr inbounds nuw i8, ptr %0, i64 %32
  %36 = load <4 x i8>, ptr %35, align 1, !tbaa !21
  %37 = tail call <4 x i8> @llvm.umax.v4i8(<4 x i8> %34, <4 x i8> %36)
  store <4 x i8> %37, ptr %35, align 1, !tbaa !21
  %38 = add nuw i64 %32, 4
  %39 = icmp eq i64 %38, %30
  br i1 %39, label %40, label %31, !llvm.loop !29

40:                                               ; preds = %31
  %41 = icmp eq i64 %30, %6
  br i1 %41, label %42, label %8

42:                                               ; preds = %43, %23, %40, %3
  ret void

43:                                               ; preds = %8, %43
  %44 = phi i64 [ %50, %43 ], [ %9, %8 ]
  %45 = getelementptr inbounds nuw i8, ptr %1, i64 %44
  %46 = load i8, ptr %45, align 1, !tbaa !21
  %47 = getelementptr inbounds nuw i8, ptr %0, i64 %44
  %48 = load i8, ptr %47, align 1, !tbaa !21
  %49 = tail call i8 @llvm.umax.i8(i8 %46, i8 %48)
  store i8 %49, ptr %47, align 1, !tbaa !21
  %50 = add nuw nsw i64 %44, 1
  %51 = icmp eq i64 %50, %6
  br i1 %51, label %42, label %43, !llvm.loop !30
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local [2 x i64] @make_pair(i64 noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = add nsw i64 %1, %0
  %4 = sub nsw i64 %0, %1
  %5 = insertvalue [2 x i64] poison, i64 %3, 0
  %6 = insertvalue [2 x i64] %5, i64 %4, 1
  ret [2 x i64] %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i64 @use_pair([2 x i64] %0) local_unnamed_addr #0 {
  %2 = extractvalue [2 x i64] %0, 0
  %3 = extractvalue [2 x i64] %0, 1
  %4 = mul nsw i64 %2, %3
  ret i64 %4
}

; Function Attrs: nounwind memory(inaccessiblemem: write) uwtable
define dso_local void @trap(i32 noundef %0) local_unnamed_addr #10 {
  %2 = icmp eq i32 %0, 0
  br i1 %2, label %4, label %3

3:                                                ; preds = %1
  tail call void @llvm.trap()
  unreachable

4:                                                ; preds = %1
  ret void
}

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #11

; Function Attrs: mustprogress nofree norecurse noreturn nosync nounwind willreturn memory(none) uwtable
define dso_local void @never() local_unnamed_addr #12 {
  unreachable
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umax.i32(i32, i32) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fshl.i32(i32, i32, i32) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umax.i8(i8, i8) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.vector.reduce.add.v4i32(<4 x i32>) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.vector.reduce.fadd.v4f32(float, <4 x float>) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.umax.v16i8(<16 x i8>, <16 x i8>) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i8> @llvm.umax.v4i8(<4 x i8>, <4 x i8>) #13

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nofree norecurse nosync nounwind memory(argmem: read) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, argmem: read, inaccessiblemem: none) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #6 = { nofree nounwind uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #7 = { nofree nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #8 = { nounwind uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #9 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #10 = { nounwind memory(inaccessiblemem: write) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #11 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #12 = { mustprogress nofree norecurse noreturn nosync nounwind willreturn memory(none) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #13 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #14 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = distinct !{!10, !11, !12, !13, !14}
!11 = !{!"llvm.loop.mustprogress"}
!12 = !{!"llvm.loop.unroll.disable"}
!13 = !{!"llvm.loop.isvectorized", i32 1}
!14 = !{!"llvm.loop.unroll.runtime.disable"}
!15 = distinct !{!15, !11, !12, !13}
!16 = distinct !{!16, !11, !12, !13, !14}
!17 = distinct !{!17, !11, !12, !13}
!18 = !{!19, !19, i64 0}
!19 = !{!"p1 omnipotent char", !20, i64 0}
!20 = !{!"any pointer", !8, i64 0}
!21 = !{!8, !8, i64 0}
!22 = distinct !{!22, !11, !12, !13, !14}
!23 = distinct !{!23, !11, !12, !13}
!24 = !{!25, !25, i64 0}
!25 = !{!"float", !8, i64 0}
!26 = distinct !{!26, !11, !12, !13, !14}
!27 = distinct !{!27, !11, !12, !13}
!28 = distinct !{!28, !11, !12, !13, !14}
!29 = distinct !{!29, !11, !12, !13, !14}
!30 = distinct !{!30, !11, !12, !13}
