; ModuleID = 'x86.c'
source_filename = "x86.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@ld = dso_local local_unnamed_addr global x86_fp80 0xK3FFF8CCCCCCCCCCCCCCD, align 16
@q = dso_local local_unnamed_addr global fp128 0xL00000000000000004000400000000000, align 16
@gotos.t = internal unnamed_addr constant [2 x ptr] [ptr blockaddress(@gotos, %7), ptr blockaddress(@gotos, %6)], align 16
@tl = dso_local thread_local local_unnamed_addr global i32 5, align 4

@alias_fn = dso_local alias i32 (), ptr @target_alias

@ifn = dso_local ifunc i32 (), ptr @resolve

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef x86_fp80 @addl(x86_fp80 noundef %0, x86_fp80 noundef %1) local_unnamed_addr #0 {
  %3 = tail call x86_fp80 @llvm.fmuladd.f80(x86_fp80 %0, x86_fp80 %1, x86_fp80 0xK3FFBCCCCCCCCCCCCCCCD)
  ret x86_fp80 %3
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare x86_fp80 @llvm.fmuladd.f80(x86_fp80, x86_fp80, x86_fp80) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) uwtable
define dso_local fp128 @addq(fp128 noundef %0) local_unnamed_addr #2 {
  %2 = load fp128, ptr @q, align 16, !tbaa !5
  %3 = fadd fp128 %0, %2
  ret fp128 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef half @h(half noundef %0) local_unnamed_addr #0 {
  %2 = fmul half %0, 0xH34CD
  ret half %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef bfloat @bf(bfloat noundef returned %0) local_unnamed_addr #0 {
  ret bfloat %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 1, 3) i32 @gotos(i32 noundef %0) local_unnamed_addr #0 {
  %2 = and i32 %0, 1
  %3 = zext nneg i32 %2 to i64
  %4 = getelementptr inbounds nuw [2 x ptr], ptr @gotos.t, i64 0, i64 %3
  %5 = load ptr, ptr %4, align 8, !tbaa !9
  indirectbr ptr %5, [label %7, label %6]

6:                                                ; preds = %1
  br label %7

7:                                                ; preds = %1, %6
  %8 = phi i32 [ 2, %6 ], [ 1, %1 ]
  ret i32 %8
}

; Function Attrs: nounwind uwtable
define dso_local i32 @asmf(i32 noundef %0) local_unnamed_addr #3 {
  %2 = tail call i32 asm sideeffect "bswap $0", "=r,0,~{memory},~{dirflag},~{fpsr},~{flags}"(i32 %0) #5, !srcloc !11
  ret i32 %2
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 0, 2) i32 @ga(i32 noundef %0) local_unnamed_addr #3 {
  callbr void asm sideeffect "jmp ${1:l}", "r,!i,~{dirflag},~{fpsr},~{flags}"(i32 %0) #5
          to label %3 [label %2], !srcloc !12

2:                                                ; preds = %1
  br label %3

3:                                                ; preds = %1, %2
  %4 = phi i32 [ 1, %2 ], [ 0, %1 ]
  ret i32 %4
}

; Function Attrs: nounwind uwtable
define weak dso_local void @wk() local_unnamed_addr #3 {
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @target_alias() #0 {
  ret i32 0
}

; Function Attrs: disable_sanitizer_instrumentation nounwind uwtable
define internal ptr @resolve() #4 {
  ret ptr @target_alias
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { disable_sanitizer_instrumentation nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"__float128", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"any pointer", !7, i64 0}
!11 = !{i64 388}
!12 = !{i64 468}
