; ModuleID = 'eh.cpp'
source_filename = "eh.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%class.anon.3 = type { ptr, ptr, ptr }
%"class.std::__1::vector" = type { ptr, ptr, %struct.anon }
%struct.anon = type { ptr }
%"class.std::__1::basic_string" = type { %struct.anon.0 }
%struct.anon.0 = type { %"union.std::__1::basic_string<char>::__rep" }
%"union.std::__1::basic_string<char>::__rep" = type { %"struct.std::__1::basic_string<char>::__long" }
%"struct.std::__1::basic_string<char>::__long" = type { ptr, i64, i64 }

@.str = private unnamed_addr constant [4 x i8] c"neg\00", align 1
@_ZTISt13runtime_error = external constant ptr
@_ZTISt9exception = external constant ptr
@.str.2 = private unnamed_addr constant [7 x i8] c"vector\00", align 1
@_ZTISt12length_error = external constant ptr
@_ZTVSt12length_error = external unnamed_addr constant { [5 x ptr] }, align 8
@_ZTISt20bad_array_new_length = external constant ptr
@.str.3 = private unnamed_addr constant [13 x i8] c"basic_string\00", align 1
@llvm.global_ctors = appending global [0 x { i32, ptr, ptr }] zeroinitializer

; Function Attrs: mustprogress ssp uwtable(sync)
define i32 @_Z3usei(i32 noundef %0) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  %3 = alloca %class.anon.3, align 8
  %4 = alloca %"class.std::__1::vector", align 8
  %5 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %4) #17
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %4, i8 0, i64 24, i1 false)
  %6 = icmp sgt i32 %0, 0
  tail call void @llvm.assume(i1 %6)
  %7 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %8 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %9 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %10 = getelementptr inbounds nuw i8, ptr %3, i64 16
  br label %93

11:                                               ; preds = %105
  %12 = load ptr, ptr %4, align 8, !tbaa !6
  %13 = load i32, ptr %12, align 4, !tbaa !13
  call void @llvm.assume(i1 true) [ "align"(ptr %12, i64 4) ]
  call void @llvm.assume(i1 true) [ "align"(ptr %106, i64 4) ]
  %14 = icmp eq ptr %12, %106
  br i1 %14, label %91, label %15

15:                                               ; preds = %11
  %16 = ptrtoint ptr %12 to i64
  %17 = ptrtoint ptr %106 to i64
  %18 = sub i64 %17, %16
  %19 = add i64 %18, -4
  %20 = lshr exact i64 %19, 2
  %21 = add nuw nsw i64 %20, 1
  %22 = icmp ult i64 %19, 12
  br i1 %22, label %81, label %23

23:                                               ; preds = %15
  %24 = icmp ult i64 %19, 60
  br i1 %24, label %61, label %25

25:                                               ; preds = %23
  %26 = and i64 %21, 9223372036854775792
  %27 = insertelement <4 x i32> poison, i32 %13, i64 0
  %28 = shufflevector <4 x i32> %27, <4 x i32> poison, <4 x i32> zeroinitializer
  br label %29

29:                                               ; preds = %29, %25
  %30 = phi i64 [ 0, %25 ], [ %48, %29 ]
  %31 = phi <4 x i32> [ %28, %25 ], [ %44, %29 ]
  %32 = phi <4 x i32> [ %28, %25 ], [ %45, %29 ]
  %33 = phi <4 x i32> [ %28, %25 ], [ %46, %29 ]
  %34 = phi <4 x i32> [ %28, %25 ], [ %47, %29 ]
  %35 = shl i64 %30, 2
  %36 = getelementptr i8, ptr %12, i64 %35
  %37 = getelementptr i8, ptr %36, i64 16
  %38 = getelementptr i8, ptr %36, i64 32
  %39 = getelementptr i8, ptr %36, i64 48
  %40 = load <4 x i32>, ptr %36, align 4, !tbaa !13
  %41 = load <4 x i32>, ptr %37, align 4, !tbaa !13
  %42 = load <4 x i32>, ptr %38, align 4, !tbaa !13
  %43 = load <4 x i32>, ptr %39, align 4, !tbaa !13
  %44 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %40, <4 x i32> %31)
  %45 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %41, <4 x i32> %32)
  %46 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %42, <4 x i32> %33)
  %47 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %43, <4 x i32> %34)
  %48 = add nuw i64 %30, 16
  %49 = icmp eq i64 %48, %26
  br i1 %49, label %50, label %29, !llvm.loop !15

50:                                               ; preds = %29
  %51 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %44, <4 x i32> %45)
  %52 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %51, <4 x i32> %46)
  %53 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %52, <4 x i32> %47)
  %54 = call i32 @llvm.vector.reduce.smax.v4i32(<4 x i32> %53)
  %55 = icmp eq i64 %21, %26
  br i1 %55, label %91, label %56

56:                                               ; preds = %50
  %57 = shl i64 %26, 2
  %58 = getelementptr i8, ptr %12, i64 %57
  %59 = and i64 %21, 12
  %60 = icmp eq i64 %59, 0
  br i1 %60, label %81, label %61

61:                                               ; preds = %56, %23
  %62 = phi i64 [ %26, %56 ], [ 0, %23 ]
  %63 = phi i32 [ %54, %56 ], [ %13, %23 ]
  %64 = and i64 %21, 9223372036854775804
  %65 = shl i64 %64, 2
  %66 = getelementptr i8, ptr %12, i64 %65
  %67 = insertelement <4 x i32> poison, i32 %63, i64 0
  %68 = shufflevector <4 x i32> %67, <4 x i32> poison, <4 x i32> zeroinitializer
  br label %69

69:                                               ; preds = %69, %61
  %70 = phi i64 [ %62, %61 ], [ %76, %69 ]
  %71 = phi <4 x i32> [ %68, %61 ], [ %75, %69 ]
  %72 = shl i64 %70, 2
  %73 = getelementptr i8, ptr %12, i64 %72
  %74 = load <4 x i32>, ptr %73, align 4, !tbaa !13
  %75 = call <4 x i32> @llvm.smax.v4i32(<4 x i32> %74, <4 x i32> %71)
  %76 = add nuw i64 %70, 4
  %77 = icmp eq i64 %76, %64
  br i1 %77, label %78, label %69, !llvm.loop !18

78:                                               ; preds = %69
  %79 = call i32 @llvm.vector.reduce.smax.v4i32(<4 x i32> %75)
  %80 = icmp eq i64 %21, %64
  br i1 %80, label %91, label %81

81:                                               ; preds = %56, %78, %15
  %82 = phi i32 [ %13, %15 ], [ %54, %56 ], [ %79, %78 ]
  %83 = phi ptr [ %12, %15 ], [ %58, %56 ], [ %66, %78 ]
  br label %84

84:                                               ; preds = %81, %84
  %85 = phi i32 [ %88, %84 ], [ %82, %81 ]
  %86 = phi ptr [ %89, %84 ], [ %83, %81 ]
  %87 = load i32, ptr %86, align 4, !tbaa !13
  %88 = call i32 @llvm.smax.i32(i32 %87, i32 %85)
  %89 = getelementptr inbounds nuw i8, ptr %86, i64 4
  %90 = icmp eq ptr %89, %106
  br i1 %90, label %91, label %84, !llvm.loop !19

91:                                               ; preds = %84, %50, %78, %11
  %92 = phi i32 [ %13, %11 ], [ %54, %50 ], [ %79, %78 ], [ %88, %84 ]
  store ptr %12, ptr %7, align 8, !tbaa !20
  call void @_ZdlPv(ptr noundef nonnull %12) #18
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4) #17
  ret i32 %92

93:                                               ; preds = %1, %105
  %94 = phi ptr [ null, %1 ], [ %106, %105 ]
  %95 = phi i32 [ 0, %1 ], [ %107, %105 ]
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %5) #17
  %96 = mul nuw nsw i32 %95, 3
  %97 = urem i32 %96, 7
  store i32 %97, ptr %5, align 4, !tbaa !13
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %2) #17
  store ptr %94, ptr %2, align 8, !tbaa !21
  %98 = load ptr, ptr %8, align 8, !tbaa !22
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3) #17
  store ptr %2, ptr %3, align 8, !tbaa !23
  store ptr %5, ptr %9, align 8, !tbaa !21
  store ptr %4, ptr %10, align 8, !tbaa !26
  %99 = icmp ult ptr %94, %98
  br i1 %99, label %100, label %102, !prof !29

100:                                              ; preds = %93
  store i32 %97, ptr %94, align 4, !tbaa !13
  %101 = getelementptr inbounds nuw i8, ptr %94, i64 4
  br label %105

102:                                              ; preds = %93
  invoke void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE0_clEv(ptr noundef nonnull %3)
          to label %103 unwind label %109

103:                                              ; preds = %102
  %104 = load ptr, ptr %2, align 8, !tbaa !21
  br label %105

105:                                              ; preds = %103, %100
  %106 = phi ptr [ %101, %100 ], [ %104, %103 ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3) #17
  store ptr %106, ptr %7, align 8, !tbaa !20
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %2) #17
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %5) #17
  %107 = add nuw nsw i32 %95, 1
  %108 = icmp eq i32 %107, %0
  br i1 %108, label %11, label %93, !llvm.loop !30

109:                                              ; preds = %102
  %110 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %5) #17
  %111 = load ptr, ptr %4, align 8, !tbaa !6
  %112 = icmp eq ptr %111, null
  br i1 %112, label %114, label %113

113:                                              ; preds = %109
  store ptr %111, ptr %7, align 8, !tbaa !20
  call void @_ZdlPv(ptr noundef nonnull %111) #18
  br label %114

114:                                              ; preds = %109, %113
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4) #17
  resume { ptr, i32 } %110
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress ssp uwtable(sync)
define range(i32 0, -2147483648) i32 @_Z7throweri(i32 noundef returned %0) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
  %2 = icmp slt i32 %0, 0
  br i1 %2, label %3, label %9

3:                                                ; preds = %1
  %4 = tail call ptr @__cxa_allocate_exception(i64 16) #17
  %5 = invoke ptr @_ZNSt13runtime_errorC1EPKc(ptr noundef %4, ptr noundef nonnull @.str)
          to label %6 unwind label %7

6:                                                ; preds = %3
  call void @_Z7throweri.cold.1(ptr %4) #19
  unreachable

7:                                                ; preds = %3
  %8 = landingpad { ptr, i32 }
          cleanup
  tail call void @__cxa_free_exception(ptr %4) #17
  resume { ptr, i32 } %8

9:                                                ; preds = %1
  ret i32 %0
}

declare ptr @__cxa_allocate_exception(i64) local_unnamed_addr

declare ptr @_ZNSt13runtime_errorC1EPKc(ptr noundef returned, ptr noundef) unnamed_addr #2

declare void @__cxa_free_exception(ptr) local_unnamed_addr

; Function Attrs: nounwind
declare ptr @_ZNSt13runtime_errorD1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: cold noreturn
declare void @__cxa_throw(ptr, ptr, ptr) local_unnamed_addr #4

; Function Attrs: mustprogress ssp uwtable(sync)
define range(i32 -2, -2147483648) i32 @_Z7catcheri(i32 noundef %0) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
  %2 = icmp slt i32 %0, 0
  br i1 %2, label %3, label %20

3:                                                ; preds = %1
  %4 = tail call ptr @__cxa_allocate_exception(i64 16) #17
  %5 = invoke ptr @_ZNSt13runtime_errorC1EPKc(ptr noundef %4, ptr noundef nonnull @.str)
          to label %6 unwind label %8

6:                                                ; preds = %3
  invoke void @__cxa_throw(ptr %4, ptr nonnull @_ZTISt13runtime_error, ptr nonnull @_ZNSt13runtime_errorD1Ev) #20
          to label %7 unwind label %10

7:                                                ; preds = %6
  unreachable

8:                                                ; preds = %3
  %9 = landingpad { ptr, i32 }
          catch ptr @_ZTISt9exception
          catch ptr null
  tail call void @__cxa_free_exception(ptr %4) #17
  br label %12

10:                                               ; preds = %6
  %11 = landingpad { ptr, i32 }
          catch ptr @_ZTISt9exception
          catch ptr null
  br label %12

12:                                               ; preds = %8, %10
  %13 = phi { ptr, i32 } [ %11, %10 ], [ %9, %8 ]
  %14 = extractvalue { ptr, i32 } %13, 0
  %15 = extractvalue { ptr, i32 } %13, 1
  %16 = tail call i32 @llvm.eh.typeid.for.p0(ptr nonnull @_ZTISt9exception) #17
  %17 = icmp eq i32 %15, %16
  %18 = tail call ptr @__cxa_begin_catch(ptr %14) #17
  tail call void @__cxa_end_catch()
  %19 = select i1 %17, i32 -1, i32 -2
  br label %20

20:                                               ; preds = %1, %12
  %21 = phi i32 [ %19, %12 ], [ %0, %1 ]
  ret i32 %21
}

; Function Attrs: nofree nosync nounwind memory(none)
declare i32 @llvm.eh.typeid.for.p0(ptr) #5

declare ptr @__cxa_begin_catch(ptr) local_unnamed_addr

declare void @__cxa_end_catch() local_unnamed_addr

; Function Attrs: mustprogress ssp uwtable(sync)
define void @_Z4joinRKNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEES7_(ptr dead_on_unwind noalias writable writeonly sret(%"class.std::__1::basic_string") align 8 captures(none) %0, ptr noundef nonnull readonly align 8 captures(none) dereferenceable(24) %1, ptr noundef nonnull align 8 dereferenceable(24) %2) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
  %4 = alloca %"class.std::__1::basic_string", align 8
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %4) #17
  tail call void @llvm.experimental.noalias.scope.decl(metadata !32)
  %5 = getelementptr inbounds nuw i8, ptr %1, i64 23
  %6 = load i8, ptr %5, align 1, !noalias !32
  %7 = icmp slt i8 %6, 0
  %8 = load ptr, ptr %1, align 8, !noalias !32
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %10 = load i64, ptr %9, align 8, !noalias !32
  %11 = zext nneg i8 %6 to i64
  %12 = select i1 %7, i64 %10, i64 %11
  tail call void @llvm.experimental.noalias.scope.decl(metadata !35)
  %13 = add i64 %12, 1
  %14 = icmp ugt i64 %13, 9223372036854775798
  br i1 %14, label %15, label %16

15:                                               ; preds = %3
  tail call void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE20__throw_length_errorB9nqe220106Ev() #20, !noalias !38
  unreachable

16:                                               ; preds = %3
  %17 = icmp samesign ugt i64 %13, 22
  br i1 %17, label %21, label %18

18:                                               ; preds = %16
  %19 = trunc nuw nsw i64 %13 to i8
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 23
  store i8 %19, ptr %20, align 1, !alias.scope !38
  br label %30

21:                                               ; preds = %16
  %22 = and i64 %13, 9223372036854775800
  %23 = add nuw nsw i64 %22, 8
  %24 = icmp eq i64 %23, 24
  %25 = select i1 %24, i64 25, i64 %23
  %26 = tail call noalias nonnull ptr @_Znwm(i64 noundef %25) #21, !noalias !39
  %27 = or disjoint i64 %25, -9223372036854775808
  store ptr %26, ptr %4, align 8, !tbaa !42, !alias.scope !38
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %13, ptr %28, align 8, !tbaa !44, !alias.scope !38
  %29 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %27, ptr %29, align 8, !tbaa !46, !alias.scope !38
  br label %30

30:                                               ; preds = %18, %21
  %31 = phi ptr [ %4, %18 ], [ %26, %21 ]
  %32 = select i1 %7, ptr %8, ptr %1
  call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %31, ptr align 1 %32, i64 %12, i1 false)
  %33 = getelementptr i8, ptr %31, i64 %12
  store i8 44, ptr %33, align 1
  %34 = getelementptr i8, ptr %33, i64 1
  store i8 0, ptr %34, align 1, !tbaa !46
  %35 = getelementptr inbounds nuw i8, ptr %2, i64 23
  %36 = load i8, ptr %35, align 1, !noalias !47
  %37 = icmp slt i8 %36, 0
  %38 = load ptr, ptr %2, align 8, !noalias !47
  %39 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %40 = load i64, ptr %39, align 8, !noalias !47
  %41 = zext nneg i8 %36 to i64
  %42 = select i1 %37, ptr %38, ptr %2
  %43 = select i1 %37, i64 %40, i64 %41
  %44 = invoke noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendEPKcm(ptr noundef nonnull align 8 dereferenceable(24) %4, ptr noundef %42, i64 noundef %43)
          to label %45 unwind label %52

45:                                               ; preds = %30
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %44, i64 24, i1 false), !tbaa.struct !50
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %44, i8 0, i64 24, i1 false), !noalias !47
  %46 = getelementptr inbounds nuw i8, ptr %4, i64 23
  %47 = load i8, ptr %46, align 1
  %48 = icmp slt i8 %47, 0
  br i1 %48, label %49, label %51

49:                                               ; preds = %45
  %50 = load ptr, ptr %4, align 8, !tbaa !46
  call void @_ZdlPv(ptr noundef %50) #18
  br label %51

51:                                               ; preds = %45, %49
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4) #17
  ret void

52:                                               ; preds = %30
  %53 = landingpad { ptr, i32 }
          cleanup
  %54 = getelementptr inbounds nuw i8, ptr %4, i64 23
  %55 = load i8, ptr %54, align 1
  %56 = icmp slt i8 %55, 0
  br i1 %56, label %57, label %59

57:                                               ; preds = %52
  %58 = load ptr, ptr %4, align 8, !tbaa !46
  call void @_ZdlPv(ptr noundef %58) #18
  br label %59

59:                                               ; preds = %52, %57
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4) #17
  resume { ptr, i32 } %53
}

; Function Attrs: mustprogress ssp uwtable(sync)
define i32 @_Z4virtP4Base(ptr noundef %0) local_unnamed_addr #0 {
  %2 = load ptr, ptr %0, align 8, !tbaa !51
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %4 = load ptr, ptr %3, align 8
  %5 = tail call i32 %4(ptr noundef nonnull %0, i32 noundef 3)
  ret i32 %5
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) local_unnamed_addr #6

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #7

; Function Attrs: inlinehint mustprogress ssp uwtable(sync)
define linkonce_odr void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE0_clEv(ptr noundef %0) local_unnamed_addr #8 personality ptr @__gxx_personality_v0 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %3 = load ptr, ptr %2, align 8, !tbaa !26
  %4 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %5 = load ptr, ptr %4, align 8, !tbaa !53, !nonnull !54, !align !55
  %6 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %7 = load ptr, ptr %6, align 8, !tbaa !20
  %8 = load ptr, ptr %3, align 8, !tbaa !6
  %9 = ptrtoint ptr %7 to i64
  %10 = ptrtoint ptr %8 to i64
  %11 = sub i64 %9, %10
  %12 = ashr exact i64 %11, 2
  %13 = add nsw i64 %12, 1
  %14 = icmp ugt i64 %13, 4611686018427387903
  br i1 %14, label %15, label %16

15:                                               ; preds = %1
  tail call void @_ZNSt3__16vectorIiNS_9allocatorIiEEE20__throw_length_errorB9nqe220106Ev() #20
  unreachable

16:                                               ; preds = %1
  %17 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %18 = load ptr, ptr %17, align 8, !tbaa !22
  %19 = ptrtoint ptr %18 to i64
  %20 = sub i64 %19, %10
  %21 = icmp ult i64 %20, 9223372036854775804
  %22 = ashr exact i64 %20, 1
  %23 = tail call i64 @llvm.umax.i64(i64 %22, i64 %13)
  %24 = select i1 %21, i64 %23, i64 4611686018427387903
  %25 = icmp ne i64 %24, 0
  tail call void @llvm.assume(i1 %25)
  %26 = icmp ugt i64 %24, 4611686018427387903
  br i1 %26, label %27, label %28

27:                                               ; preds = %16
  tail call void @_ZSt28__throw_bad_array_new_lengthB9nqe220106v() #20
  unreachable

28:                                               ; preds = %16
  %29 = shl nuw i64 %24, 2
  %30 = tail call noalias nonnull ptr @_Znwm(i64 noundef %29) #21
  %31 = getelementptr inbounds nuw i8, ptr %30, i64 %11
  %32 = getelementptr inbounds nuw i32, ptr %30, i64 %24
  %33 = load i32, ptr %5, align 4, !tbaa !13
  store i32 %33, ptr %31, align 4, !tbaa !13
  %34 = getelementptr inbounds nuw i8, ptr %31, i64 4
  %35 = sub nsw i64 0, %12
  %36 = getelementptr inbounds i32, ptr %31, i64 %35
  tail call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 1 %36, ptr align 4 %8, i64 %11, i1 false)
  store ptr %36, ptr %3, align 8, !tbaa !21
  store ptr %34, ptr %6, align 8, !tbaa !21
  store ptr %32, ptr %17, align 8, !tbaa !21
  %37 = icmp eq ptr %8, null
  br i1 %37, label %39, label %38

38:                                               ; preds = %28
  tail call void @_ZdlPv(ptr noundef nonnull %8) #18
  br label %39

39:                                               ; preds = %28, %38
  %40 = load ptr, ptr %0, align 8, !tbaa !56, !nonnull !54, !align !57
  store ptr %34, ptr %40, align 8, !tbaa !21
  ret void
}

; Function Attrs: mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE20__throw_length_errorB9nqe220106Ev() local_unnamed_addr #9 {
  tail call void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef nonnull @.str.2) #20
  unreachable
}

; Function Attrs: inlinehint mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef %0) local_unnamed_addr #10 personality ptr @__gxx_personality_v0 {
  %2 = tail call ptr @__cxa_allocate_exception(i64 16) #17
  %3 = invoke ptr @_ZNSt12length_errorC1B9nqe220106EPKc(ptr noundef %2, ptr noundef %0)
          to label %4 unwind label %5

4:                                                ; preds = %1
  tail call void @__cxa_throw(ptr %2, ptr nonnull @_ZTISt12length_error, ptr nonnull @_ZNSt12length_errorD1Ev) #20
  unreachable

5:                                                ; preds = %1
  %6 = landingpad { ptr, i32 }
          cleanup
  tail call void @__cxa_free_exception(ptr %2) #17
  resume { ptr, i32 } %6
}

; Function Attrs: mustprogress ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt12length_errorC1B9nqe220106EPKc(ptr noundef returned %0, ptr noundef %1) unnamed_addr #0 {
  %3 = tail call ptr @_ZNSt11logic_errorC2EPKc(ptr noundef %0, ptr noundef %1)
  store ptr getelementptr inbounds nuw inrange(-16, 24) (i8, ptr @_ZTVSt12length_error, i64 16), ptr %0, align 8, !tbaa !51
  ret ptr %0
}

; Function Attrs: nounwind
declare ptr @_ZNSt12length_errorD1Ev(ptr noundef returned) unnamed_addr #3

declare ptr @_ZNSt11logic_errorC2EPKc(ptr noundef returned, ptr noundef) unnamed_addr #2

; Function Attrs: inlinehint mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZSt28__throw_bad_array_new_lengthB9nqe220106v() local_unnamed_addr #10 {
  %1 = tail call ptr @__cxa_allocate_exception(i64 8) #17
  %2 = tail call ptr @_ZNSt20bad_array_new_lengthC1Ev(ptr noundef %1) #17
  tail call void @__cxa_throw(ptr %1, ptr nonnull @_ZTISt20bad_array_new_length, ptr nonnull @_ZNSt20bad_array_new_lengthD1Ev) #20
  unreachable
}

; Function Attrs: nounwind
declare ptr @_ZNSt20bad_array_new_lengthC1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: nounwind
declare ptr @_ZNSt20bad_array_new_lengthD1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #11

; Function Attrs: nobuiltin allocsize(0)
declare nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #12

; Function Attrs: mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE20__throw_length_errorB9nqe220106Ev() local_unnamed_addr #9 {
  tail call void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef nonnull @.str.3) #20
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #7

declare noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendEPKcm(ptr noundef, ptr noundef, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #14

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #15

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.smax.v4i32(<4 x i32>, <4 x i32>) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.vector.reduce.smax.v4i32(<4 x i32>) #14

; Function Attrs: cold minsize mustprogress noreturn ssp uwtable(sync)
define internal void @_Z7throweri.cold.1(ptr %0) #16 personality ptr @__gxx_personality_v0 {
  br label %2

2:                                                ; preds = %1
  tail call void @__cxa_throw(ptr %0, ptr nonnull @_ZTISt13runtime_error, ptr nonnull @_ZNSt13runtime_errorD1Ev) #20
  unreachable
}

attributes #0 = { mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { cold noreturn }
attributes #5 = { nofree nosync nounwind memory(none) }
attributes #6 = { nobuiltin nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { inlinehint mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #10 = { inlinehint mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #11 = { mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #12 = { nobuiltin allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #13 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #14 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #15 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #16 = { cold minsize mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #17 = { nounwind }
attributes #18 = { builtin nounwind }
attributes #19 = { noinline }
attributes #20 = { noreturn }
attributes #21 = { builtin allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = !{!7, !8, i64 0}
!7 = !{!"_ZTSNSt3__16vectorIiNS_9allocatorIiEEEE", !8, i64 0, !8, i64 8, !12, i64 16}
!8 = !{!"p1 int", !9, i64 0}
!9 = !{!"any pointer", !10, i64 0}
!10 = !{!"omnipotent char", !11, i64 0}
!11 = !{!"Simple C++ TBAA"}
!12 = !{!"_ZTSNSt3__16vectorIiNS_9allocatorIiEEEUt_E", !8, i64 0}
!13 = !{!14, !14, i64 0}
!14 = !{!"int", !10, i64 0}
!15 = distinct !{!15, !16, !17}
!16 = !{!"llvm.loop.isvectorized", i32 1}
!17 = !{!"llvm.loop.unroll.runtime.disable"}
!18 = distinct !{!18, !16, !17}
!19 = distinct !{!19, !17, !16}
!20 = !{!7, !8, i64 8}
!21 = !{!8, !8, i64 0}
!22 = !{!7, !8, i64 16}
!23 = !{!24, !24, i64 0}
!24 = !{!"p2 int", !25, i64 0}
!25 = !{!"any p2 pointer", !9, i64 0}
!26 = !{!27, !28, i64 16}
!27 = !{!"_ZTSZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_EUlvE0_", !24, i64 0, !8, i64 8, !28, i64 16}
!28 = !{!"p1 _ZTSNSt3__16vectorIiNS_9allocatorIiEEEE", !9, i64 0}
!29 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!30 = distinct !{!30, !31}
!31 = !{!"llvm.loop.mustprogress"}
!32 = !{!33}
!33 = distinct !{!33, !34, !"_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS9_PKS6_: argument 0"}
!34 = distinct !{!34, !"_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS9_PKS6_"}
!35 = !{!36}
!36 = distinct !{!36, !37, !"_ZNSt3__121__concatenate_stringsB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS8_NS_15__type_identityINS_17basic_string_viewIS6_S7_EEE4typeESG_: argument 0"}
!37 = distinct !{!37, !"_ZNSt3__121__concatenate_stringsB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS8_NS_15__type_identityINS_17basic_string_viewIS6_S7_EEE4typeESG_"}
!38 = !{!36, !33}
!39 = !{!40, !36, !33}
!40 = distinct !{!40, !41, !"_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__allocate_long_bufferB9nqe220106ERS4_m: argument 0"}
!41 = distinct !{!41, !"_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__allocate_long_bufferB9nqe220106ERS4_m"}
!42 = !{!43, !43, i64 0}
!43 = !{!"p1 omnipotent char", !9, i64 0}
!44 = !{!45, !45, i64 0}
!45 = !{!"long", !10, i64 0}
!46 = !{!10, !10, i64 0}
!47 = !{!48}
!48 = distinct !{!48, !49, !"_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EEOS9_RKS9_: argument 0"}
!49 = distinct !{!49, !"_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EEOS9_RKS9_"}
!50 = !{i64 0, i64 24, !46}
!51 = !{!52, !52, i64 0}
!52 = !{!"vtable pointer", !11, i64 0}
!53 = !{!27, !8, i64 8}
!54 = !{}
!55 = !{i64 4}
!56 = !{!27, !24, i64 0}
!57 = !{i64 8}
