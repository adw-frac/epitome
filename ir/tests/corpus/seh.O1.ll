; ModuleID = 'seh.cpp'
source_filename = "seh.cpp"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.33.0"

%rtti.TypeDescriptor2 = type { ptr, ptr, [3 x i8] }
%struct.S = type { i8 }

$"??_R0H@8" = comdat any

@"??_7type_info@@6B@" = external constant ptr
@"??_R0H@8" = linkonce_odr global %rtti.TypeDescriptor2 { ptr @"??_7type_info@@6B@", ptr null, [3 x i8] c".H\00" }, comdat

; Function Attrs: mustprogress uwtable
define dso_local noundef range(i32 0, 2) i32 @"?f@@YAHXZ"() local_unnamed_addr #0 personality ptr @__CxxFrameHandler3 {
  %1 = alloca %struct.S, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %1) #4
  invoke void @"?may_throw@@YAXXZ"()
          to label %6 unwind label %2

2:                                                ; preds = %0
  %3 = catchswitch within none [label %4] unwind label %8

4:                                                ; preds = %2
  %5 = catchpad within %3 [ptr @"??_R0H@8", i32 0, ptr null]
  catchret from %5 to label %6

6:                                                ; preds = %0, %4
  %7 = phi i32 [ 1, %4 ], [ 0, %0 ]
  call void @"??1S@@QEAA@XZ"(ptr noundef nonnull align 1 dereferenceable(1) %1) #4
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %1) #4
  ret i32 %7

8:                                                ; preds = %2
  %9 = cleanuppad within none []
  call void @"??1S@@QEAA@XZ"(ptr noundef nonnull align 1 dereferenceable(1) %1) #4 [ "funclet"(token %9) ]
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %1) #4
  cleanupret from %9 unwind to caller
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

declare dso_local void @"?may_throw@@YAXXZ"() local_unnamed_addr #2

declare dso_local i32 @__CxxFrameHandler3(...)

; Function Attrs: nounwind
declare dso_local void @"??1S@@QEAA@XZ"(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "Apple clang version 21.0.0 (clang-2100.3.34.2)", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "seh.cpp", directory: "/corpus")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
