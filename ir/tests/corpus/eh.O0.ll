; ModuleID = 'eh.cpp'
source_filename = "eh.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Derived = type <{ %struct.Base, i32, [4 x i8] }>
%struct.Base = type { ptr }
%"class.std::__1::vector" = type { ptr, ptr, %struct.anon }
%struct.anon = type { ptr }
%"class.std::__1::__wrap_iter" = type { ptr }
%"class.std::__1::basic_string" = type { %struct.anon.0 }
%struct.anon.0 = type { %"union.std::__1::basic_string<char>::__rep" }
%"union.std::__1::basic_string<char>::__rep" = type { %"struct.std::__1::basic_string<char>::__long" }
%"struct.std::__1::basic_string<char>::__long" = type { ptr, i64, i64 }
%"class.std::__1::allocator.5" = type { i8 }
%"class.std::__1::basic_string_view" = type { ptr, i64 }
%"class.std::__1::vector<int>::__destroy_vector" = type { ptr }
%class.anon = type { ptr, ptr, ptr }
%class.anon.2 = type { ptr, ptr, ptr }
%"struct.std::__1::vector<int>::_ConstructTransaction" = type { ptr, ptr, ptr }
%"struct.std::__1::__split_buffer" = type { ptr, ptr, ptr, %struct.anon.3 }
%struct.anon.3 = type { ptr, ptr }
%"struct.std::__1::__less" = type { i8 }
%"struct.std::__1::__allocation_result" = type { ptr, i64 }
%"struct.std::__1::integral_constant" = type { i8 }
%"struct.std::__1::__uninitialized_size_tag" = type { i8 }
%"struct.std::__1::basic_string_view<char>::__assume_valid" = type { i8 }
%"struct.std::__1::basic_string<char>::__short" = type { [23 x i8], i8 }
%"struct.std::__1::__allocation_result.8" = type { ptr, i64 }
%class.anon.9 = type { i8 }

@.str = private unnamed_addr constant [4 x i8] c"neg\00", align 1
@_ZTISt13runtime_error = external constant ptr
@_ZTISt9exception = external constant ptr
@.str.1 = private unnamed_addr constant [2 x i8] c",\00", align 1
@_ZL8global_d = internal global %struct.Derived zeroinitializer, align 8
@__dso_handle = external hidden global i8
@_ZTV7Derived = linkonce_odr unnamed_addr constant { [5 x ptr] } { [5 x ptr] [ptr null, ptr @_ZTI7Derived, ptr @_ZN7DerivedD1Ev, ptr @_ZN7DerivedD0Ev, ptr @_ZN7Derived1fEi] }, align 8
@_ZTI7Derived = linkonce_odr hidden constant { ptr, ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2), ptr inttoptr (i64 add (i64 ptrtoint (ptr @_ZTS7Derived to i64), i64 -9223372036854775808) to ptr), ptr @_ZTI4Base }, align 8
@_ZTVN10__cxxabiv120__si_class_type_infoE = external global [0 x ptr]
@_ZTS7Derived = linkonce_odr hidden constant [9 x i8] c"7Derived\00", align 1
@_ZTI4Base = linkonce_odr hidden constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), ptr inttoptr (i64 add (i64 ptrtoint (ptr @_ZTS4Base to i64), i64 -9223372036854775808) to ptr) }, align 8
@_ZTVN10__cxxabiv117__class_type_infoE = external global [0 x ptr]
@_ZTS4Base = linkonce_odr hidden constant [6 x i8] c"4Base\00", align 1
@_ZTV4Base = linkonce_odr unnamed_addr constant { [5 x ptr] } { [5 x ptr] [ptr null, ptr @_ZTI4Base, ptr @_ZN4BaseD1Ev, ptr @_ZN4BaseD0Ev, ptr @_ZN4Base1fEi] }, align 8
@.str.2 = private unnamed_addr constant [7 x i8] c"vector\00", align 1
@_ZTISt12length_error = external constant ptr
@_ZTVSt12length_error = external unnamed_addr constant { [5 x ptr] }, align 8
@_ZTISt20bad_array_new_length = external constant ptr
@.str.3 = private unnamed_addr constant [13 x i8] c"basic_string\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_eh.cpp, ptr null }]

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z3usei(i32 noundef %0) #0 personality ptr @__gxx_personality_v0 {
  %2 = alloca i32, align 4
  %3 = alloca %"class.std::__1::vector", align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %8 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEEC1B9nqe220106Ev(ptr noundef %3) #6
  store i32 0, ptr %4, align 4
  br label %9

9:                                                ; preds = %18, %1
  %10 = load i32, ptr %4, align 4
  %11 = load i32, ptr %2, align 4
  %12 = icmp slt i32 %10, %11
  br i1 %12, label %13, label %26

13:                                               ; preds = %9
  %14 = load i32, ptr %4, align 4
  %15 = mul nsw i32 %14, 3
  %16 = srem i32 %15, 7
  store i32 %16, ptr %5, align 4
  invoke void @_ZNSt3__16vectorIiNS_9allocatorIiEEE9push_backB9nqe220106EOi(ptr noundef %3, ptr noundef nonnull align 4 dereferenceable(4) %5)
          to label %17 unwind label %21

17:                                               ; preds = %13
  br label %18

18:                                               ; preds = %17
  %19 = load i32, ptr %4, align 4
  %20 = add nsw i32 %19, 1
  store i32 %20, ptr %4, align 4
  br label %9, !llvm.loop !6

21:                                               ; preds = %26, %13
  %22 = landingpad { ptr, i32 }
          cleanup
  %23 = extractvalue { ptr, i32 } %22, 0
  store ptr %23, ptr %6, align 8
  %24 = extractvalue { ptr, i32 } %22, 1
  store i32 %24, ptr %7, align 4
  %25 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEED1B9nqe220106Ev(ptr noundef %3) #6
  br label %30

26:                                               ; preds = %9
  %27 = invoke i32 @_Z5maxofIiET_RKNSt3__16vectorIS0_NS1_9allocatorIS0_EEEE(ptr noundef nonnull align 8 dereferenceable(24) %3)
          to label %28 unwind label %21

28:                                               ; preds = %26
  %29 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEED1B9nqe220106Ev(ptr noundef %3) #6
  ret i32 %27

30:                                               ; preds = %21
  %31 = load ptr, ptr %6, align 8
  %32 = load i32, ptr %7, align 4
  %33 = insertvalue { ptr, i32 } poison, ptr %31, 0
  %34 = insertvalue { ptr, i32 } %33, i32 %32, 1
  resume { ptr, i32 } %34
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEEC1B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEEC2B9nqe220106Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE9push_backB9nqe220106EOi(ptr noundef %0, ptr noundef nonnull align 4 dereferenceable(4) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8, !align !9
  %7 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_(ptr noundef %5, ptr noundef nonnull align 4 dereferenceable(4) %6)
  ret void
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i32 @_Z5maxofIiET_RKNSt3__16vectorIS0_NS1_9allocatorIS0_EEEE(ptr noundef nonnull align 8 dereferenceable(24) %0) #1 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca %"class.std::__1::__wrap_iter", align 8
  %6 = alloca %"class.std::__1::__wrap_iter", align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %8 = load ptr, ptr %2, align 8, !nonnull !8, !align !10
  %9 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEEixB9nqe220106Em(ptr noundef %8, i64 noundef 0) #6
  %10 = load i32, ptr %9, align 4
  store i32 %10, ptr %3, align 4
  %11 = load ptr, ptr %2, align 8, !nonnull !8, !align !10
  store ptr %11, ptr %4, align 8
  %12 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %13 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE5beginB9nqe220106Ev(ptr noundef %12) #6
  %14 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %5, i32 0, i32 0
  %15 = inttoptr i64 %13 to ptr
  store ptr %15, ptr %14, align 8
  %16 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %17 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE3endB9nqe220106Ev(ptr noundef %16) #6
  %18 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %6, i32 0, i32 0
  %19 = inttoptr i64 %17 to ptr
  store ptr %19, ptr %18, align 8
  br label %20

20:                                               ; preds = %32, %1
  %21 = call zeroext i1 @_ZNSt3__1neB9nqe220106IPKiEEbRKNS_11__wrap_iterIT_EES7_(ptr noundef nonnull align 8 dereferenceable(8) %5, ptr noundef nonnull align 8 dereferenceable(8) %6) #6
  br i1 %21, label %22, label %34

22:                                               ; preds = %20
  %23 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt3__111__wrap_iterIPKiEdeB9nqe220106Ev(ptr noundef %5) #6
  store ptr %23, ptr %7, align 8
  %24 = load ptr, ptr %7, align 8, !nonnull !8, !align !9
  %25 = load i32, ptr %24, align 4
  %26 = load i32, ptr %3, align 4
  %27 = icmp sgt i32 %25, %26
  br i1 %27, label %28, label %31

28:                                               ; preds = %22
  %29 = load ptr, ptr %7, align 8, !nonnull !8, !align !9
  %30 = load i32, ptr %29, align 4
  store i32 %30, ptr %3, align 4
  br label %31

31:                                               ; preds = %28, %22
  br label %32

32:                                               ; preds = %31
  %33 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__111__wrap_iterIPKiEppB9nqe220106Ev(ptr noundef %5) #6
  br label %20

34:                                               ; preds = %20
  %35 = load i32, ptr %3, align 4
  ret i32 %35
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEED1B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEED2B9nqe220106Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z7throweri(i32 noundef %0) #0 personality ptr @__gxx_personality_v0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  %6 = icmp slt i32 %5, 0
  br i1 %6, label %7, label %15

7:                                                ; preds = %1
  %8 = call ptr @__cxa_allocate_exception(i64 16) #6
  %9 = invoke ptr @_ZNSt13runtime_errorC1EPKc(ptr noundef %8, ptr noundef @.str)
          to label %10 unwind label %11

10:                                               ; preds = %7
  call void @__cxa_throw(ptr %8, ptr @_ZTISt13runtime_error, ptr @_ZNSt13runtime_errorD1Ev) #15
  unreachable

11:                                               ; preds = %7
  %12 = landingpad { ptr, i32 }
          cleanup
  %13 = extractvalue { ptr, i32 } %12, 0
  store ptr %13, ptr %3, align 8
  %14 = extractvalue { ptr, i32 } %12, 1
  store i32 %14, ptr %4, align 4
  call void @__cxa_free_exception(ptr %8) #6
  br label %17

15:                                               ; preds = %1
  %16 = load i32, ptr %2, align 4
  ret i32 %16

17:                                               ; preds = %11
  %18 = load ptr, ptr %3, align 8
  %19 = load i32, ptr %4, align 4
  %20 = insertvalue { ptr, i32 } poison, ptr %18, 0
  %21 = insertvalue { ptr, i32 } %20, i32 %19, 1
  resume { ptr, i32 } %21
}

declare ptr @__cxa_allocate_exception(i64)

declare ptr @_ZNSt13runtime_errorC1EPKc(ptr noundef returned, ptr noundef) unnamed_addr #2

declare void @__cxa_free_exception(ptr)

; Function Attrs: nounwind
declare ptr @_ZNSt13runtime_errorD1Ev(ptr noundef returned) unnamed_addr #3

declare void @__cxa_throw(ptr, ptr, ptr)

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z7catcheri(i32 noundef %0) #0 personality ptr @__gxx_personality_v0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  store i32 %0, ptr %3, align 4
  %7 = load i32, ptr %3, align 4
  %8 = invoke i32 @_Z7throweri(i32 noundef %7)
          to label %9 unwind label %10

9:                                                ; preds = %1
  store i32 %8, ptr %2, align 4
  br label %24

10:                                               ; preds = %1
  %11 = landingpad { ptr, i32 }
          catch ptr @_ZTISt9exception
          catch ptr null
  %12 = extractvalue { ptr, i32 } %11, 0
  store ptr %12, ptr %4, align 8
  %13 = extractvalue { ptr, i32 } %11, 1
  store i32 %13, ptr %5, align 4
  br label %14

14:                                               ; preds = %10
  %15 = load i32, ptr %5, align 4
  %16 = call i32 @llvm.eh.typeid.for.p0(ptr @_ZTISt9exception) #6
  %17 = icmp eq i32 %15, %16
  br i1 %17, label %18, label %21

18:                                               ; preds = %14
  %19 = load ptr, ptr %4, align 8
  %20 = call ptr @__cxa_begin_catch(ptr %19) #6
  store ptr %20, ptr %6, align 8
  store i32 -1, ptr %2, align 4
  call void @__cxa_end_catch()
  br label %24

21:                                               ; preds = %14
  %22 = load ptr, ptr %4, align 8
  %23 = call ptr @__cxa_begin_catch(ptr %22) #6
  store i32 -2, ptr %2, align 4
  call void @__cxa_end_catch()
  br label %24

24:                                               ; preds = %9, %21, %18
  %25 = load i32, ptr %2, align 4
  ret i32 %25
}

; Function Attrs: nounwind memory(none)
declare i32 @llvm.eh.typeid.for.p0(ptr) #4

declare ptr @__cxa_begin_catch(ptr)

declare void @__cxa_end_catch()

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4joinRKNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEES7_(ptr dead_on_unwind noalias writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 8 dereferenceable(24) %1, ptr noundef nonnull align 8 dereferenceable(24) %2) #0 personality ptr @__gxx_personality_v0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca %"class.std::__1::basic_string", align 8
  %8 = alloca ptr, align 8
  %9 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %10 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  call void @_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS9_PKS6_(ptr dead_on_unwind writable sret(%"class.std::__1::basic_string") align 8 %7, ptr noundef nonnull align 8 dereferenceable(24) %10, ptr noundef @.str.1)
  %11 = load ptr, ptr %6, align 8, !nonnull !8, !align !10
  invoke void @_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EEOS9_RKS9_(ptr dead_on_unwind writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 8 dereferenceable(24) %7, ptr noundef nonnull align 8 dereferenceable(24) %11)
          to label %12 unwind label %14

12:                                               ; preds = %3
  %13 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEED1Ev(ptr noundef %7) #6
  ret void

14:                                               ; preds = %3
  %15 = landingpad { ptr, i32 }
          cleanup
  %16 = extractvalue { ptr, i32 } %15, 0
  store ptr %16, ptr %8, align 8
  %17 = extractvalue { ptr, i32 } %15, 1
  store i32 %17, ptr %9, align 4
  %18 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEED1Ev(ptr noundef %7) #6
  br label %19

19:                                               ; preds = %14
  %20 = load ptr, ptr %8, align 8
  %21 = load i32, ptr %9, align 4
  %22 = insertvalue { ptr, i32 } poison, ptr %20, 0
  %23 = insertvalue { ptr, i32 } %22, i32 %21, 1
  resume { ptr, i32 } %23
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EEOS9_RKS9_(ptr dead_on_unwind noalias writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 8 dereferenceable(24) %1, ptr noundef nonnull align 8 dereferenceable(24) %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %8 = load ptr, ptr %6, align 8, !nonnull !8, !align !10
  %9 = call noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendB9nqe220106ERKS5_(ptr noundef %7, ptr noundef nonnull align 8 dereferenceable(24) %8)
  %10 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106EOS5_(ptr noundef %0, ptr noundef nonnull align 8 dereferenceable(24) %9) #6
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__1plB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS9_PKS6_(ptr dead_on_unwind noalias writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 8 dereferenceable(24) %1, ptr noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca %"class.std::__1::allocator.5", align 1
  %8 = alloca %"class.std::__1::allocator.5", align 1
  %9 = alloca %"class.std::__1::basic_string_view", align 8
  %10 = alloca %"class.std::__1::basic_string_view", align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %11 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13get_allocatorB9nqe220106Ev(ptr noundef %11) #6
  %12 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %13 = call [2 x i64] @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEcvNS_17basic_string_viewIcS2_EEB9nqe220106Ev(ptr noundef %12) #6
  store [2 x i64] %13, ptr %9, align 8
  %14 = load ptr, ptr %6, align 8
  %15 = call ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC1B9nqe220106EPKc(ptr noundef %10, ptr noundef %14)
  %16 = load [2 x i64], ptr %9, align 8
  %17 = load [2 x i64], ptr %10, align 8
  call void @_ZNSt3__121__concatenate_stringsB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS8_NS_15__type_identityINS_17basic_string_viewIS6_S7_EEE4typeESG_(ptr dead_on_unwind writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 1 dereferenceable(1) %7, [2 x i64] %16, [2 x i64] %17)
  ret void
}

; Function Attrs: nounwind
declare ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEED1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z4virtP4Base(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = getelementptr inbounds ptr, ptr %4, i64 2
  %6 = load ptr, ptr %5, align 8
  %7 = call i32 %6(ptr noundef %3, i32 noundef 3)
  ret i32 %7
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init() #5 section "__TEXT,__StaticInit,regular,pure_instructions" {
  %1 = call ptr @_ZN7DerivedC1Ev(ptr noundef @_ZL8global_d) #6
  %2 = call i32 @__cxa_atexit(ptr @_ZN7DerivedD1Ev, ptr @_ZL8global_d, ptr @__dso_handle) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN7DerivedC1Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN7DerivedC2Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN7DerivedD1Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN7DerivedD2Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #6

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN7DerivedC2Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN4BaseC2Ev(ptr noundef %3) #6
  store ptr getelementptr inbounds inrange(-16, 24) ({ [5 x ptr] }, ptr @_ZTV7Derived, i32 0, i32 0, i32 2), ptr %3, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN4BaseC2Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  store ptr getelementptr inbounds inrange(-16, 24) ({ [5 x ptr] }, ptr @_ZTV4Base, i32 0, i32 0, i32 2), ptr %3, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZN7DerivedD0Ev(ptr noundef %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN7DerivedD1Ev(ptr noundef %3) #6
  call void @_ZdlPv(ptr noundef %3) #16
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i32 @_ZN7Derived1fEi(ptr noundef %0, i32 noundef %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  %5 = load ptr, ptr %3, align 8
  %6 = load i32, ptr %4, align 4
  %7 = getelementptr inbounds nuw %struct.Derived, ptr %5, i32 0, i32 1
  %8 = load i32, ptr %7, align 8
  %9 = mul nsw i32 %6, %8
  ret i32 %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN4BaseD1Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN4BaseD2Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZN4BaseD0Ev(ptr noundef %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN4BaseD1Ev(ptr noundef %3) #6
  call void @_ZdlPv(ptr noundef %3) #16
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i32 @_ZN4Base1fEi(ptr noundef %0, i32 noundef %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  %5 = load ptr, ptr %3, align 8
  %6 = load i32, ptr %4, align 4
  ret i32 %6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN4BaseD2Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) #7

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZN7DerivedD2Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZN4BaseD2Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEEC2B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 0
  store ptr null, ptr %4, align 8
  %5 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 1
  store ptr null, ptr %5, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 2
  %7 = getelementptr inbounds nuw %struct.anon, ptr %6, i32 0, i32 0
  store ptr null, ptr %7, align 8
  %8 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 2
  %9 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 2
  %10 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 2
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEED2B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  %3 = alloca %"class.std::__1::vector<int>::__destroy_vector", align 8
  store ptr %0, ptr %2, align 8
  %4 = load ptr, ptr %2, align 8
  %5 = invoke ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorC1B9nqe220106ERS3_(ptr noundef %3, ptr noundef nonnull align 8 dereferenceable(24) %4)
          to label %6 unwind label %8

6:                                                ; preds = %1
  invoke void @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorclB9nqe220106Ev(ptr noundef %3)
          to label %7 unwind label %8

7:                                                ; preds = %6
  ret ptr %4

8:                                                ; preds = %6, %1
  %9 = landingpad { ptr, i32 }
          catch ptr null
  %10 = extractvalue { ptr, i32 } %9, 0
  call void @__clang_call_terminate(ptr %10) #17
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorC1B9nqe220106ERS3_(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1) unnamed_addr #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorC2B9nqe220106ERS3_(ptr noundef %5, ptr noundef nonnull align 8 dereferenceable(24) %6)
  ret ptr %5
}

; Function Attrs: noinline noreturn nounwind ssp uwtable(sync)
define linkonce_odr hidden void @__clang_call_terminate(ptr noundef %0) #8 {
  %2 = call ptr @__cxa_begin_catch(ptr %0) #6
  call void @_ZSt9terminatev() #17
  unreachable
}

declare void @_ZSt9terminatev()

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorclB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  %8 = icmp ne ptr %7, null
  br i1 %8, label %9, label %24

9:                                                ; preds = %1
  %10 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %11 = load ptr, ptr %10, align 8, !nonnull !8, !align !10
  call void @_ZNSt3__16vectorIiNS_9allocatorIiEEE5clearB9nqe220106Ev(ptr noundef %11) #6
  %12 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %13 = load ptr, ptr %12, align 8, !nonnull !8, !align !10
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_deleteB9nqe220106Ev(ptr noundef %13) #6
  %14 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %15 = load ptr, ptr %14, align 8, !nonnull !8, !align !10
  %16 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %15, i32 0, i32 2
  %17 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %18 = load ptr, ptr %17, align 8, !nonnull !8, !align !10
  %19 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %18, i32 0, i32 0
  %20 = load ptr, ptr %19, align 8
  %21 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %3, i32 0, i32 0
  %22 = load ptr, ptr %21, align 8, !nonnull !8, !align !10
  %23 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %22) #6
  call void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE10deallocateB9nqe220106ERS2_Pim(ptr noundef nonnull align 1 dereferenceable(1) %16, ptr noundef %20, i64 noundef %23) #6
  br label %24

24:                                               ; preds = %9, %1
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE16__destroy_vectorC2B9nqe220106ERS3_(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector<int>::__destroy_vector", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  store ptr %7, ptr %6, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE5clearB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  %3 = alloca i64, align 8
  store ptr %0, ptr %2, align 8
  %4 = load ptr, ptr %2, align 8
  %5 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %4) #6
  store i64 %5, ptr %3, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %4, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  call void @_ZNSt3__16vectorIiNS_9allocatorIiEEE22__base_destruct_at_endB9nqe220106EPi(ptr noundef %4, ptr noundef %7) #6
  %8 = load i64, ptr %3, align 8
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_shrinkB9nqe220106Em(ptr noundef %4, i64 noundef %8) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_deleteB9nqe220106Ev(ptr noundef %0) #1 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %3) #6
  %5 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %3) #6
  %6 = getelementptr inbounds nuw i32, ptr %4, i64 %5
  %7 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %3) #6
  %8 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %3) #6
  %9 = getelementptr inbounds nuw i32, ptr %7, i64 %8
  invoke void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE31__annotate_contiguous_containerB9nqe220106EPKvS5_(ptr noundef %3, ptr noundef %6, ptr noundef %9)
          to label %10 unwind label %11

10:                                               ; preds = %1
  ret void

11:                                               ; preds = %1
  %12 = landingpad { ptr, i32 }
          catch ptr null
  %13 = extractvalue { ptr, i32 } %12, 0
  call void @__clang_call_terminate(ptr %13) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE10deallocateB9nqe220106ERS2_Pim(ptr noundef nonnull align 1 dereferenceable(1) %0, ptr noundef %1, i64 noundef %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8, !nonnull !8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  call void @_ZNSt3__19allocatorIiE10deallocateB9nqe220106EPim(ptr noundef %7, ptr noundef %8, i64 noundef %9) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 2
  %5 = getelementptr inbounds nuw %struct.anon, ptr %4, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 0
  %8 = load ptr, ptr %7, align 8
  %9 = ptrtoint ptr %6 to i64
  %10 = ptrtoint ptr %8 to i64
  %11 = sub i64 %9, %10
  %12 = sdiv exact i64 %11, 4
  ret i64 %12
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 1
  %5 = load ptr, ptr %4, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  %8 = ptrtoint ptr %5 to i64
  %9 = ptrtoint ptr %7 to i64
  %10 = sub i64 %8, %9
  %11 = sdiv exact i64 %10, 4
  ret i64 %11
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE22__base_destruct_at_endB9nqe220106EPi(ptr noundef %0, ptr noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8
  %7 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  %8 = load ptr, ptr %7, align 8
  store ptr %8, ptr %5, align 8
  br label %9

9:                                                ; preds = %18, %2
  %10 = load ptr, ptr %4, align 8
  %11 = load ptr, ptr %5, align 8
  %12 = icmp ne ptr %10, %11
  br i1 %12, label %13, label %19

13:                                               ; preds = %9
  %14 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 2
  %15 = load ptr, ptr %5, align 8
  %16 = getelementptr inbounds i32, ptr %15, i32 -1
  store ptr %16, ptr %5, align 8
  %17 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %16) #6
  invoke void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE7destroyB9nqe220106IiLi0EEEvRS2_PT_(ptr noundef nonnull align 1 dereferenceable(1) %14, ptr noundef %17)
          to label %18 unwind label %22

18:                                               ; preds = %13
  br label %9, !llvm.loop !11

19:                                               ; preds = %9
  %20 = load ptr, ptr %4, align 8
  %21 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  store ptr %20, ptr %21, align 8
  ret void

22:                                               ; preds = %13
  %23 = landingpad { ptr, i32 }
          catch ptr null
  %24 = extractvalue { ptr, i32 } %23, 0
  call void @__clang_call_terminate(ptr %24) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_shrinkB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %7 = load i64, ptr %4, align 8
  %8 = getelementptr inbounds nuw i32, ptr %6, i64 %7
  %9 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %10 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %5) #6
  %11 = getelementptr inbounds nuw i32, ptr %9, i64 %10
  invoke void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE31__annotate_contiguous_containerB9nqe220106EPKvS5_(ptr noundef %5, ptr noundef %8, ptr noundef %11)
          to label %12 unwind label %13

12:                                               ; preds = %2
  ret void

13:                                               ; preds = %2
  %14 = landingpad { ptr, i32 }
          catch ptr null
  %15 = extractvalue { ptr, i32 } %14, 0
  call void @__clang_call_terminate(ptr %15) #17
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE7destroyB9nqe220106IiLi0EEEvRS2_PT_(ptr noundef nonnull align 1 dereferenceable(1) %0, ptr noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8, !nonnull !8
  %6 = load ptr, ptr %4, align 8
  call void @_ZNSt3__19allocatorIiE7destroyB9nqe220106EPi(ptr noundef %5, ptr noundef %6)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__19allocatorIiE7destroyB9nqe220106EPi(ptr noundef %0, ptr noundef %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE31__annotate_contiguous_containerB9nqe220106EPKvS5_(ptr noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %7) #6
  %9 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %7) #6
  %10 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %7) #6
  %11 = getelementptr inbounds nuw i32, ptr %9, i64 %10
  %12 = load ptr, ptr %5, align 8
  %13 = load ptr, ptr %6, align 8
  call void @_ZNSt3__131__annotate_contiguous_containerB9nqe220106INS_9allocatorIiEEEEvPKvS4_S4_S4_(ptr noundef %8, ptr noundef %11, ptr noundef %12, ptr noundef %13)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8
  %6 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %5) #6
  ret ptr %6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__131__annotate_contiguous_containerB9nqe220106INS_9allocatorIiEEEEvPKvS4_S4_S4_(ptr noundef %0, ptr noundef %1, ptr noundef %2, ptr noundef %3) #1 {
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  store ptr %3, ptr %8, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__19allocatorIiE10deallocateB9nqe220106EPim(ptr noundef %0, ptr noundef %1, i64 noundef %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  call void @_ZNSt3__119__libcpp_deallocateB9nqe220106IiEEvPNS_15__type_identityIT_E4typeENS_15__element_countEm(ptr noundef %8, i64 noundef %9, i64 noundef 4) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__119__libcpp_deallocateB9nqe220106IiEEvPNS_15__type_identityIT_E4typeENS_15__element_countEm(ptr noundef %0, i64 noundef %1, i64 noundef %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %8 = load i64, ptr %5, align 8
  %9 = mul i64 %8, 4
  store i64 %9, ptr %7, align 8
  %10 = load i64, ptr %6, align 8
  %11 = call zeroext i1 @_ZNSt3__124__is_overaligned_for_newB9nqe220106Em(i64 noundef %10) #6
  br i1 %11, label %12, label %15

12:                                               ; preds = %3
  %13 = load ptr, ptr %4, align 8
  %14 = load i64, ptr %6, align 8
  call void @_ZdlPvSt11align_val_t(ptr noundef %13, i64 noundef %14) #16
  br label %17

15:                                               ; preds = %3
  %16 = load ptr, ptr %4, align 8
  call void @_ZdlPv(ptr noundef %16) #16
  br label %17

17:                                               ; preds = %15, %12
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNSt3__124__is_overaligned_for_newB9nqe220106Em(i64 noundef %0) #1 {
  %2 = alloca i64, align 8
  store i64 %0, ptr %2, align 8
  %3 = load i64, ptr %2, align 8
  %4 = icmp ugt i64 %3, 16
  ret i1 %4
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvSt11align_val_t(ptr noundef, i64 noundef) #7

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(4) ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_(ptr noundef %0, ptr noundef nonnull align 4 dereferenceable(4) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca %class.anon, align 8
  %7 = alloca %class.anon.2, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %8 = load ptr, ptr %3, align 8
  %9 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 1
  %10 = load ptr, ptr %9, align 8
  store ptr %10, ptr %5, align 8
  %11 = load ptr, ptr %5, align 8
  %12 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 2
  %13 = getelementptr inbounds nuw %struct.anon, ptr %12, i32 0, i32 0
  %14 = load ptr, ptr %13, align 8
  %15 = icmp ult ptr %11, %14
  %16 = getelementptr inbounds nuw %class.anon, ptr %6, i32 0, i32 0
  %17 = load ptr, ptr %4, align 8, !nonnull !8, !align !9
  store ptr %17, ptr %16, align 8
  %18 = getelementptr inbounds nuw %class.anon, ptr %6, i32 0, i32 1
  store ptr %8, ptr %18, align 8
  %19 = getelementptr inbounds nuw %class.anon, ptr %6, i32 0, i32 2
  store ptr %5, ptr %19, align 8
  %20 = getelementptr inbounds nuw %class.anon.2, ptr %7, i32 0, i32 0
  store ptr %5, ptr %20, align 8
  %21 = getelementptr inbounds nuw %class.anon.2, ptr %7, i32 0, i32 1
  %22 = load ptr, ptr %4, align 8, !nonnull !8, !align !9
  store ptr %22, ptr %21, align 8
  %23 = getelementptr inbounds nuw %class.anon.2, ptr %7, i32 0, i32 2
  store ptr %8, ptr %23, align 8
  call void @_ZNSt3__116__if_likely_elseB9nqe220106IZNS_6vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_EUlvE_ZNS5_IJiEEES6_S9_EUlvE0_EEvbT_T0_(i1 noundef zeroext %15, ptr noundef %6, ptr noundef %7)
  %24 = load ptr, ptr %5, align 8
  %25 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 1
  store ptr %24, ptr %25, align 8
  %26 = load ptr, ptr %5, align 8
  %27 = getelementptr inbounds i32, ptr %26, i64 -1
  ret ptr %27
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__116__if_likely_elseB9nqe220106IZNS_6vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_EUlvE_ZNS5_IJiEEES6_S9_EUlvE0_EEvbT_T0_(i1 noundef zeroext %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = alloca i8, align 1
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = zext i1 %0 to i8
  store i8 %7, ptr %4, align 1
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %8 = load i8, ptr %4, align 1
  %9 = trunc i8 %8 to i1
  %10 = call i1 @llvm.is.constant.i1(i1 %9)
  br i1 %10, label %11, label %17

11:                                               ; preds = %3
  %12 = load i8, ptr %4, align 1
  %13 = trunc i8 %12 to i1
  br i1 %13, label %14, label %15

14:                                               ; preds = %11
  call void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE_clEv(ptr noundef %1)
  br label %16

15:                                               ; preds = %11
  call void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE0_clEv(ptr noundef %2)
  br label %16

16:                                               ; preds = %15, %14
  br label %23

17:                                               ; preds = %3
  %18 = load i8, ptr %4, align 1
  %19 = trunc i8 %18 to i1
  br i1 %19, label %20, label %21

20:                                               ; preds = %17
  call void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE_clEv(ptr noundef %1)
  br label %22

21:                                               ; preds = %17
  call void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE0_clEv(ptr noundef %2)
  br label %22

22:                                               ; preds = %21, %20
  br label %23

23:                                               ; preds = %22, %16
  ret void
}

; Function Attrs: convergent nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.is.constant.i1(i1) #9

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE_clEv(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %class.anon, ptr %3, i32 0, i32 1
  %5 = load ptr, ptr %4, align 8
  %6 = getelementptr inbounds nuw %class.anon, ptr %3, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8, !nonnull !8, !align !9
  call void @_ZNSt3__16vectorIiNS_9allocatorIiEEE30__emplace_back_assume_capacityB9nqe220106IJiEEEvDpOT_(ptr noundef %5, ptr noundef nonnull align 4 dereferenceable(4) %7)
  %8 = getelementptr inbounds nuw %class.anon, ptr %3, i32 0, i32 2
  %9 = load ptr, ptr %8, align 8, !nonnull !8, !align !10
  %10 = load ptr, ptr %9, align 8
  %11 = getelementptr inbounds nuw i32, ptr %10, i32 1
  store ptr %11, ptr %9, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZZNSt3__16vectorIiNS_9allocatorIiEEE12emplace_backIJiEEERiDpOT_ENKUlvE0_clEv(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %class.anon.2, ptr %3, i32 0, i32 2
  %5 = load ptr, ptr %4, align 8
  %6 = getelementptr inbounds nuw %class.anon.2, ptr %3, i32 0, i32 1
  %7 = load ptr, ptr %6, align 8, !nonnull !8, !align !9
  %8 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE24__emplace_back_slow_pathIJiEEEPiDpOT_(ptr noundef %5, ptr noundef nonnull align 4 dereferenceable(4) %7)
  %9 = getelementptr inbounds nuw %class.anon.2, ptr %3, i32 0, i32 0
  %10 = load ptr, ptr %9, align 8, !nonnull !8, !align !10
  store ptr %8, ptr %10, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__16vectorIiNS_9allocatorIiEEE30__emplace_back_assume_capacityB9nqe220106IJiEEEvDpOT_(ptr noundef %0, ptr noundef nonnull align 4 dereferenceable(4) %1) #0 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca %"struct.std::__1::vector<int>::_ConstructTransaction", align 8
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %8 = load ptr, ptr %3, align 8
  %9 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionC1B9nqe220106ERS3_m(ptr noundef %5, ptr noundef nonnull align 8 dereferenceable(24) %8, i64 noundef 1)
  %10 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 2
  %11 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %5, i32 0, i32 1
  %12 = load ptr, ptr %11, align 8
  %13 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %12) #6
  %14 = load ptr, ptr %4, align 8, !nonnull !8, !align !9
  invoke void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE9constructB9nqe220106IiJiELi0EEEvRS2_PT_DpOT0_(ptr noundef nonnull align 1 dereferenceable(1) %10, ptr noundef %13, ptr noundef nonnull align 4 dereferenceable(4) %14)
          to label %15 unwind label %20

15:                                               ; preds = %2
  %16 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %5, i32 0, i32 1
  %17 = load ptr, ptr %16, align 8
  %18 = getelementptr inbounds nuw i32, ptr %17, i32 1
  store ptr %18, ptr %16, align 8
  %19 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionD1B9nqe220106Ev(ptr noundef %5) #6
  ret void

20:                                               ; preds = %2
  %21 = landingpad { ptr, i32 }
          cleanup
  %22 = extractvalue { ptr, i32 } %21, 0
  store ptr %22, ptr %6, align 8
  %23 = extractvalue { ptr, i32 } %21, 1
  store i32 %23, ptr %7, align 4
  %24 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionD1B9nqe220106Ev(ptr noundef %5) #6
  br label %25

25:                                               ; preds = %20
  %26 = load ptr, ptr %6, align 8
  %27 = load i32, ptr %7, align 4
  %28 = insertvalue { ptr, i32 } poison, ptr %26, 0
  %29 = insertvalue { ptr, i32 } %28, i32 %27, 1
  resume { ptr, i32 } %29
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionC1B9nqe220106ERS3_m(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1, i64 noundef %2) unnamed_addr #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  %10 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionC2B9nqe220106ERS3_m(ptr noundef %7, ptr noundef nonnull align 8 dereferenceable(24) %8, i64 noundef %9)
  ret ptr %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE9constructB9nqe220106IiJiELi0EEEvRS2_PT_DpOT0_(ptr noundef nonnull align 1 dereferenceable(1) %0, ptr noundef %1, ptr noundef nonnull align 4 dereferenceable(4) %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8, !nonnull !8
  %8 = load ptr, ptr %5, align 8
  %9 = load ptr, ptr %6, align 8, !nonnull !8, !align !9
  call void @_ZNSt3__19allocatorIiE9constructB9nqe220106IiJiEEEvPT_DpOT0_(ptr noundef %7, ptr noundef %8, ptr noundef nonnull align 4 dereferenceable(4) %9)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionD1B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionD2B9nqe220106Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionC2B9nqe220106ERS3_m(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  store ptr %9, ptr %8, align 8
  %10 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %7, i32 0, i32 1
  %11 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %12 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %11, i32 0, i32 1
  %13 = load ptr, ptr %12, align 8
  store ptr %13, ptr %10, align 8
  %14 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %7, i32 0, i32 2
  %15 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %16 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %15, i32 0, i32 1
  %17 = load ptr, ptr %16, align 8
  %18 = load i64, ptr %6, align 8
  %19 = getelementptr inbounds nuw i32, ptr %17, i64 %18
  store ptr %19, ptr %14, align 8
  %20 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %7, i32 0, i32 0
  %21 = load ptr, ptr %20, align 8, !nonnull !8, !align !10
  %22 = load i64, ptr %6, align 8
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE19__annotate_increaseB9nqe220106Em(ptr noundef %21, i64 noundef %22) #6
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE19__annotate_increaseB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %7 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %5) #6
  %8 = getelementptr inbounds nuw i32, ptr %6, i64 %7
  %9 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %10 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %5) #6
  %11 = getelementptr inbounds nuw i32, ptr %9, i64 %10
  %12 = load i64, ptr %4, align 8
  %13 = getelementptr inbounds nuw i32, ptr %11, i64 %12
  invoke void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE31__annotate_contiguous_containerB9nqe220106EPKvS5_(ptr noundef %5, ptr noundef %8, ptr noundef %13)
          to label %14 unwind label %15

14:                                               ; preds = %2
  ret void

15:                                               ; preds = %2
  %16 = landingpad { ptr, i32 }
          catch ptr null
  %17 = extractvalue { ptr, i32 } %16, 0
  call void @__clang_call_terminate(ptr %17) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__19allocatorIiE9constructB9nqe220106IiJiEEEvPT_DpOT0_(ptr noundef %0, ptr noundef %1, ptr noundef nonnull align 4 dereferenceable(4) %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load ptr, ptr %6, align 8, !nonnull !8, !align !9
  %10 = load i32, ptr %9, align 4
  store i32 %10, ptr %8, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE21_ConstructTransactionD2B9nqe220106Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  store ptr %4, ptr %2, align 8
  %5 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 1
  %6 = load ptr, ptr %5, align 8
  %7 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 0
  %8 = load ptr, ptr %7, align 8, !nonnull !8, !align !10
  %9 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 1
  store ptr %6, ptr %9, align 8
  %10 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 1
  %11 = load ptr, ptr %10, align 8
  %12 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 2
  %13 = load ptr, ptr %12, align 8
  %14 = icmp ne ptr %11, %13
  br i1 %14, label %15, label %28

15:                                               ; preds = %1
  %16 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 0
  %17 = load ptr, ptr %16, align 8, !nonnull !8, !align !10
  %18 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 2
  %19 = load ptr, ptr %18, align 8
  %20 = getelementptr inbounds nuw %"struct.std::__1::vector<int>::_ConstructTransaction", ptr %4, i32 0, i32 0
  %21 = load ptr, ptr %20, align 8, !nonnull !8, !align !10
  %22 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %21, i32 0, i32 0
  %23 = load ptr, ptr %22, align 8
  %24 = ptrtoint ptr %19 to i64
  %25 = ptrtoint ptr %23 to i64
  %26 = sub i64 %24, %25
  %27 = sdiv exact i64 %26, 4
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_shrinkB9nqe220106Em(ptr noundef %17, i64 noundef %27) #6
  br label %28

28:                                               ; preds = %15, %1
  %29 = load ptr, ptr %2, align 8
  ret ptr %29
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE24__emplace_back_slow_pathIJiEEEPiDpOT_(ptr noundef %0, ptr noundef nonnull align 4 dereferenceable(4) %1) #0 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca %"struct.std::__1::__split_buffer", align 8
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %8 = load ptr, ptr %3, align 8
  %9 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %8) #6
  %10 = add i64 %9, 1
  %11 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE11__recommendB9nqe220106Em(ptr noundef %8, i64 noundef %10)
  %12 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %8) #6
  %13 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 2
  %14 = call ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEEC1EmmS3_(ptr noundef %5, i64 noundef %11, i64 noundef %12, ptr noundef nonnull align 1 dereferenceable(1) %13)
  %15 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 2
  %16 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %5, i32 0, i32 2
  %17 = load ptr, ptr %16, align 8
  %18 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %17) #6
  %19 = load ptr, ptr %4, align 8, !nonnull !8, !align !9
  invoke void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE9constructB9nqe220106IiJiELi0EEEvRS2_PT_DpOT0_(ptr noundef nonnull align 1 dereferenceable(1) %15, ptr noundef %18, ptr noundef nonnull align 4 dereferenceable(4) %19)
          to label %20 unwind label %28

20:                                               ; preds = %2
  %21 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %5, i32 0, i32 2
  %22 = load ptr, ptr %21, align 8
  %23 = getelementptr inbounds nuw i32, ptr %22, i32 1
  store ptr %23, ptr %21, align 8
  invoke void @_ZNSt3__16vectorIiNS_9allocatorIiEEE26__swap_out_circular_bufferERNS_14__split_bufferIiRS2_EE(ptr noundef %8, ptr noundef nonnull align 8 dereferenceable(40) %5)
          to label %24 unwind label %28

24:                                               ; preds = %20
  %25 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %8, i32 0, i32 1
  %26 = load ptr, ptr %25, align 8
  %27 = call ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEED1Ev(ptr noundef %5) #6
  ret ptr %26

28:                                               ; preds = %20, %2
  %29 = landingpad { ptr, i32 }
          cleanup
  %30 = extractvalue { ptr, i32 } %29, 0
  store ptr %30, ptr %6, align 8
  %31 = extractvalue { ptr, i32 } %29, 1
  store i32 %31, ptr %7, align 4
  %32 = call ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEED1Ev(ptr noundef %5) #6
  br label %33

33:                                               ; preds = %28
  %34 = load ptr, ptr %6, align 8
  %35 = load i32, ptr %7, align 4
  %36 = insertvalue { ptr, i32 } poison, ptr %34, 0
  %37 = insertvalue { ptr, i32 } %36, i32 %35, 1
  resume { ptr, i32 } %37
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE11__recommendB9nqe220106Em(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i64, align 8
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %9 = load ptr, ptr %4, align 8
  %10 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8max_sizeB9nqe220106Ev(ptr noundef %9) #6
  store i64 %10, ptr %6, align 8
  %11 = load i64, ptr %5, align 8
  %12 = load i64, ptr %6, align 8
  %13 = icmp ugt i64 %11, %12
  br i1 %13, label %14, label %15

14:                                               ; preds = %2
  call void @_ZNSt3__16vectorIiNS_9allocatorIiEEE20__throw_length_errorB9nqe220106Ev() #15
  unreachable

15:                                               ; preds = %2
  %16 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %9) #6
  store i64 %16, ptr %7, align 8
  %17 = load i64, ptr %7, align 8
  %18 = load i64, ptr %6, align 8
  %19 = udiv i64 %18, 2
  %20 = icmp uge i64 %17, %19
  br i1 %20, label %21, label %23

21:                                               ; preds = %15
  %22 = load i64, ptr %6, align 8
  store i64 %22, ptr %3, align 8
  br label %28

23:                                               ; preds = %15
  %24 = load i64, ptr %7, align 8
  %25 = mul i64 2, %24
  store i64 %25, ptr %8, align 8
  %26 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13maxB9nqe220106ImEERKT_S3_S3_(ptr noundef nonnull align 8 dereferenceable(8) %8, ptr noundef nonnull align 8 dereferenceable(8) %5)
  %27 = load i64, ptr %26, align 8
  store i64 %27, ptr %3, align 8
  br label %28

28:                                               ; preds = %23, %21
  %29 = load i64, ptr %3, align 8
  ret i64 %29
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEEC1EmmS3_(ptr noundef returned %0, i64 noundef %1, i64 noundef %2, ptr noundef nonnull align 1 dereferenceable(1) %3) unnamed_addr #0 {
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  store ptr %3, ptr %8, align 8
  %9 = load ptr, ptr %5, align 8
  %10 = load i64, ptr %6, align 8
  %11 = load i64, ptr %7, align 8
  %12 = load ptr, ptr %8, align 8
  %13 = call ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEEC2EmmS3_(ptr noundef %9, i64 noundef %10, i64 noundef %11, ptr noundef nonnull align 1 dereferenceable(1) %12)
  ret ptr %9
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE26__swap_out_circular_bufferERNS_14__split_bufferIiRS2_EE(ptr noundef %0, ptr noundef nonnull align 8 dereferenceable(40) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE17__annotate_deleteB9nqe220106Ev(ptr noundef %6) #6
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %8 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %7, i32 0, i32 1
  %9 = load ptr, ptr %8, align 8
  %10 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  %11 = load ptr, ptr %10, align 8
  %12 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 0
  %13 = load ptr, ptr %12, align 8
  %14 = ptrtoint ptr %11 to i64
  %15 = ptrtoint ptr %13 to i64
  %16 = sub i64 %14, %15
  %17 = sdiv exact i64 %16, 4
  %18 = sub i64 0, %17
  %19 = getelementptr inbounds i32, ptr %9, i64 %18
  store ptr %19, ptr %5, align 8
  %20 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 2
  %21 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 0
  %22 = load ptr, ptr %21, align 8
  %23 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %22) #6
  %24 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  %25 = load ptr, ptr %24, align 8
  %26 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %25) #6
  %27 = load ptr, ptr %5, align 8
  %28 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %27) #6
  call void @_ZNSt3__134__uninitialized_allocator_relocateB9nqe220106INS_9allocatorIiEEPiEEvRT_T0_S6_S6_(ptr noundef nonnull align 1 dereferenceable(1) %20, ptr noundef %23, ptr noundef %26, ptr noundef %28)
  %29 = load ptr, ptr %5, align 8
  %30 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %31 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %30, i32 0, i32 1
  store ptr %29, ptr %31, align 8
  %32 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 0
  %33 = load ptr, ptr %32, align 8
  %34 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  store ptr %33, ptr %34, align 8
  %35 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 0
  %36 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %37 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %36, i32 0, i32 1
  call void @_ZNSt3__14swapB9nqe220106IPiEENS_9enable_ifIXaasr21is_move_constructibleIT_EE5valuesr18is_move_assignableIS3_EE5valueEvE4typeERS3_S6_(ptr noundef nonnull align 8 dereferenceable(8) %35, ptr noundef nonnull align 8 dereferenceable(8) %37) #6
  %38 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 1
  %39 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %40 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %39, i32 0, i32 2
  call void @_ZNSt3__14swapB9nqe220106IPiEENS_9enable_ifIXaasr21is_move_constructibleIT_EE5valuesr18is_move_assignableIS3_EE5valueEvE4typeERS3_S6_(ptr noundef nonnull align 8 dereferenceable(8) %38, ptr noundef nonnull align 8 dereferenceable(8) %40) #6
  %41 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %6, i32 0, i32 2
  %42 = getelementptr inbounds nuw %struct.anon, ptr %41, i32 0, i32 0
  %43 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %44 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %43, i32 0, i32 3
  %45 = getelementptr inbounds nuw %struct.anon.3, ptr %44, i32 0, i32 0
  call void @_ZNSt3__14swapB9nqe220106IPiEENS_9enable_ifIXaasr21is_move_constructibleIT_EE5valuesr18is_move_assignableIS3_EE5valueEvE4typeERS3_S6_(ptr noundef nonnull align 8 dereferenceable(8) %42, ptr noundef nonnull align 8 dereferenceable(8) %45) #6
  %46 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %47 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %46, i32 0, i32 1
  %48 = load ptr, ptr %47, align 8
  %49 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %50 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %49, i32 0, i32 0
  store ptr %48, ptr %50, align 8
  %51 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4sizeB9nqe220106Ev(ptr noundef %6) #6
  call void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE14__annotate_newB9nqe220106Em(ptr noundef %6, i64 noundef %51) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEED1Ev(ptr noundef returned %0) unnamed_addr #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEED2Ev(ptr noundef %3) #6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8max_sizeB9nqe220106Ev(ptr noundef %0) #1 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %2, align 8
  %5 = load ptr, ptr %2, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %5, i32 0, i32 2
  %7 = call i64 @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %6) #6
  store i64 %7, ptr %3, align 8
  %8 = call i64 @_ZNSt3__114numeric_limitsIlE3maxB9nqe220106Ev() #6
  store i64 %8, ptr %4, align 8
  %9 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13minB9nqe220106ImEERKT_S3_S3_(ptr noundef nonnull align 8 dereferenceable(8) %3, ptr noundef nonnull align 8 dereferenceable(8) %4)
          to label %10 unwind label %12

10:                                               ; preds = %1
  %11 = load i64, ptr %9, align 8
  ret i64 %11

12:                                               ; preds = %1
  %13 = landingpad { ptr, i32 }
          catch ptr null
  %14 = extractvalue { ptr, i32 } %13, 0
  call void @__clang_call_terminate(ptr %14) #17
  unreachable
}

; Function Attrs: mustprogress noinline noreturn optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIiNS_9allocatorIiEEE20__throw_length_errorB9nqe220106Ev() #10 {
  call void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef @.str.2) #15
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13maxB9nqe220106ImEERKT_S3_S3_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca %"struct.std::__1::__less", align 1
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %8 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13maxB9nqe220106ImNS_6__lessIvvEEEERKT_S5_S5_T0_(ptr noundef nonnull align 8 dereferenceable(8) %6, ptr noundef nonnull align 8 dereferenceable(8) %7)
  ret ptr %8
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13minB9nqe220106ImEERKT_S3_S3_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca %"struct.std::__1::__less", align 1
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %8 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13minB9nqe220106ImNS_6__lessIvvEEEERKT_S5_S5_T0_(ptr noundef nonnull align 8 dereferenceable(8) %6, ptr noundef nonnull align 8 dereferenceable(8) %7)
  ret ptr %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i64 @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8, !nonnull !8
  %4 = call i64 @_ZNKSt3__19allocatorIiE8max_sizeB9nqe220106Ev(ptr noundef %3) #6
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__114numeric_limitsIlE3maxB9nqe220106Ev() #1 {
  %1 = call i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3maxB9nqe220106Ev() #6
  ret i64 %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13minB9nqe220106ImNS_6__lessIvvEEEERKT_S5_S5_T0_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #0 {
  %3 = alloca %"struct.std::__1::__less", align 1
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %8 = call zeroext i1 @_ZNKSt3__16__lessIvvEclB9nqe220106ImmEEbRKT_RKT0_(ptr noundef %3, ptr noundef nonnull align 8 dereferenceable(8) %6, ptr noundef nonnull align 8 dereferenceable(8) %7)
  br i1 %8, label %9, label %11

9:                                                ; preds = %2
  %10 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  br label %13

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  br label %13

13:                                               ; preds = %11, %9
  %14 = phi ptr [ %10, %9 ], [ %12, %11 ]
  ret ptr %14
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNKSt3__16__lessIvvEclB9nqe220106ImmEEbRKT_RKT0_(ptr noundef %0, ptr noundef nonnull align 8 dereferenceable(8) %1, ptr noundef nonnull align 8 dereferenceable(8) %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %9 = load i64, ptr %8, align 8
  %10 = load ptr, ptr %6, align 8, !nonnull !8, !align !10
  %11 = load i64, ptr %10, align 8
  %12 = icmp ult i64 %9, %11
  ret i1 %12
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__19allocatorIiE8max_sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret i64 4611686018427387903
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3maxB9nqe220106Ev() #1 {
  ret i64 9223372036854775807
}

; Function Attrs: mustprogress noinline noreturn optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef %0) #10 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  %5 = call ptr @__cxa_allocate_exception(i64 16) #6
  %6 = load ptr, ptr %2, align 8
  %7 = invoke ptr @_ZNSt12length_errorC1B9nqe220106EPKc(ptr noundef %5, ptr noundef %6)
          to label %8 unwind label %9

8:                                                ; preds = %1
  call void @__cxa_throw(ptr %5, ptr @_ZTISt12length_error, ptr @_ZNSt12length_errorD1Ev) #15
  unreachable

9:                                                ; preds = %1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  store ptr %11, ptr %3, align 8
  %12 = extractvalue { ptr, i32 } %10, 1
  store i32 %12, ptr %4, align 4
  call void @__cxa_free_exception(ptr %5) #6
  br label %13

13:                                               ; preds = %9
  %14 = load ptr, ptr %3, align 8
  %15 = load i32, ptr %4, align 4
  %16 = insertvalue { ptr, i32 } poison, ptr %14, 0
  %17 = insertvalue { ptr, i32 } %16, i32 %15, 1
  resume { ptr, i32 } %17
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt12length_errorC1B9nqe220106EPKc(ptr noundef returned %0, ptr noundef %1) unnamed_addr #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt12length_errorC2B9nqe220106EPKc(ptr noundef %5, ptr noundef %6)
  ret ptr %5
}

; Function Attrs: nounwind
declare ptr @_ZNSt12length_errorD1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt12length_errorC2B9nqe220106EPKc(ptr noundef returned %0, ptr noundef %1) unnamed_addr #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt11logic_errorC2EPKc(ptr noundef %5, ptr noundef %6)
  store ptr getelementptr inbounds inrange(-16, 24) ({ [5 x ptr] }, ptr @_ZTVSt12length_error, i32 0, i32 0, i32 2), ptr %5, align 8
  ret ptr %5
}

declare ptr @_ZNSt11logic_errorC2EPKc(ptr noundef returned, ptr noundef) unnamed_addr #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__13maxB9nqe220106ImNS_6__lessIvvEEEERKT_S5_S5_T0_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #1 {
  %3 = alloca %"struct.std::__1::__less", align 1
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %7 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %8 = call zeroext i1 @_ZNKSt3__16__lessIvvEclB9nqe220106ImmEEbRKT_RKT0_(ptr noundef %3, ptr noundef nonnull align 8 dereferenceable(8) %6, ptr noundef nonnull align 8 dereferenceable(8) %7)
  br i1 %8, label %9, label %11

9:                                                ; preds = %2
  %10 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  br label %13

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  br label %13

13:                                               ; preds = %11, %9
  %14 = phi ptr [ %10, %9 ], [ %12, %11 ]
  ret ptr %14
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEEC2EmmS3_(ptr noundef returned %0, i64 noundef %1, i64 noundef %2, ptr noundef nonnull align 1 dereferenceable(1) %3) unnamed_addr #0 {
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca ptr, align 8
  %10 = alloca %"struct.std::__1::__allocation_result", align 8
  store ptr %0, ptr %6, align 8
  store i64 %1, ptr %7, align 8
  store i64 %2, ptr %8, align 8
  store ptr %3, ptr %9, align 8
  %11 = load ptr, ptr %6, align 8
  store ptr %11, ptr %5, align 8
  %12 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %13 = getelementptr inbounds nuw %struct.anon.3, ptr %12, i32 0, i32 0
  store ptr null, ptr %13, align 8
  %14 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %15 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %16 = getelementptr inbounds nuw %struct.anon.3, ptr %15, i32 0, i32 1
  %17 = load ptr, ptr %9, align 8, !nonnull !8
  store ptr %17, ptr %16, align 8
  %18 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %19 = load i64, ptr %7, align 8
  %20 = icmp eq i64 %19, 0
  br i1 %20, label %21, label %23

21:                                               ; preds = %4
  %22 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 0
  store ptr null, ptr %22, align 8
  br label %34

23:                                               ; preds = %4
  %24 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %25 = getelementptr inbounds nuw %struct.anon.3, ptr %24, i32 0, i32 1
  %26 = load ptr, ptr %25, align 8, !nonnull !8
  %27 = load i64, ptr %7, align 8
  %28 = call [2 x i64] @_ZNSt3__119__allocate_at_leastB9nqe220106INS_9allocatorIiEENS_16allocator_traitsIS2_EEEENS_19__allocation_resultINT0_7pointerENS6_9size_typeEEERT_m(ptr noundef nonnull align 1 dereferenceable(1) %26, i64 noundef %27)
  store [2 x i64] %28, ptr %10, align 8
  %29 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result", ptr %10, i32 0, i32 0
  %30 = load ptr, ptr %29, align 8
  %31 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 0
  store ptr %30, ptr %31, align 8
  %32 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result", ptr %10, i32 0, i32 1
  %33 = load i64, ptr %32, align 8
  store i64 %33, ptr %7, align 8
  br label %34

34:                                               ; preds = %23, %21
  %35 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 0
  %36 = load ptr, ptr %35, align 8
  %37 = load i64, ptr %8, align 8
  %38 = getelementptr inbounds nuw i32, ptr %36, i64 %37
  %39 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 2
  store ptr %38, ptr %39, align 8
  %40 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 1
  store ptr %38, ptr %40, align 8
  %41 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 0
  %42 = load ptr, ptr %41, align 8
  %43 = load i64, ptr %7, align 8
  %44 = getelementptr inbounds nuw i32, ptr %42, i64 %43
  %45 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %11, i32 0, i32 3
  %46 = getelementptr inbounds nuw %struct.anon.3, ptr %45, i32 0, i32 0
  store ptr %44, ptr %46, align 8
  %47 = load ptr, ptr %5, align 8
  ret ptr %47
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden [2 x i64] @_ZNSt3__119__allocate_at_leastB9nqe220106INS_9allocatorIiEENS_16allocator_traitsIS2_EEEENS_19__allocation_resultINT0_7pointerENS6_9size_typeEEERT_m(ptr noundef nonnull align 1 dereferenceable(1) %0, i64 noundef %1) #0 {
  %3 = alloca %"struct.std::__1::__allocation_result", align 8
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8
  %7 = load i64, ptr %5, align 8
  %8 = call ptr @_ZNSt3__19allocatorIiE8allocateB9nqe220106Em(ptr noundef %6, i64 noundef %7)
  %9 = load i64, ptr %5, align 8
  %10 = call ptr @_ZNSt3__119__allocation_resultIPimEC1B9nqe220106ES1_m(ptr noundef %3, ptr noundef %8, i64 noundef %9)
  %11 = load [2 x i64], ptr %3, align 8
  ret [2 x i64] %11
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__19allocatorIiE8allocateB9nqe220106Em(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load i64, ptr %4, align 8
  %7 = call i64 @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %5) #6
  %8 = icmp ugt i64 %6, %7
  br i1 %8, label %9, label %10

9:                                                ; preds = %2
  call void @_ZSt28__throw_bad_array_new_lengthB9nqe220106v() #15
  unreachable

10:                                               ; preds = %2
  %11 = load i64, ptr %4, align 8
  %12 = call ptr @_ZNSt3__117__libcpp_allocateB9nqe220106IiEEPT_NS_15__element_countEm(i64 noundef %11, i64 noundef 4)
  ret ptr %12
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__119__allocation_resultIPimEC1B9nqe220106ES1_m(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  %10 = call ptr @_ZNSt3__119__allocation_resultIPimEC2B9nqe220106ES1_m(ptr noundef %7, ptr noundef %8, i64 noundef %9)
  ret ptr %7
}

; Function Attrs: mustprogress noinline noreturn optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZSt28__throw_bad_array_new_lengthB9nqe220106v() #10 {
  %1 = call ptr @__cxa_allocate_exception(i64 8) #6
  %2 = call ptr @_ZNSt20bad_array_new_lengthC1Ev(ptr noundef %1) #6
  call void @__cxa_throw(ptr %1, ptr @_ZTISt20bad_array_new_length, ptr @_ZNSt20bad_array_new_lengthD1Ev) #15
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117__libcpp_allocateB9nqe220106IiEEPT_NS_15__element_countEm(i64 noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  store i64 %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %7 = load i64, ptr %4, align 8
  %8 = mul i64 %7, 4
  store i64 %8, ptr %6, align 8
  %9 = load i64, ptr %5, align 8
  %10 = call zeroext i1 @_ZNSt3__124__is_overaligned_for_newB9nqe220106Em(i64 noundef %9) #6
  br i1 %10, label %11, label %15

11:                                               ; preds = %2
  %12 = load i64, ptr %6, align 8
  %13 = load i64, ptr %5, align 8
  %14 = call noalias nonnull ptr @_ZnwmSt11align_val_t(i64 noundef %12, i64 noundef %13) #18
  call void @llvm.assume(i1 true) [ "align"(ptr %14, i64 %13) ]
  store ptr %14, ptr %3, align 8
  br label %18

15:                                               ; preds = %2
  %16 = load i64, ptr %6, align 8
  %17 = call noalias nonnull ptr @_Znwm(i64 noundef %16) #18
  store ptr %17, ptr %3, align 8
  br label %18

18:                                               ; preds = %15, %11
  %19 = load ptr, ptr %3, align 8
  ret ptr %19
}

; Function Attrs: nounwind
declare ptr @_ZNSt20bad_array_new_lengthC1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: nounwind
declare ptr @_ZNSt20bad_array_new_lengthD1Ev(ptr noundef returned) unnamed_addr #3

; Function Attrs: nobuiltin allocsize(0)
declare nonnull ptr @_ZnwmSt11align_val_t(i64 noundef, i64 noundef) #11

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #12

; Function Attrs: nobuiltin allocsize(0)
declare nonnull ptr @_Znwm(i64 noundef) #11

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__119__allocation_resultIPimEC2B9nqe220106ES1_m(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result", ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %5, align 8
  store ptr %9, ptr %8, align 8
  %10 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result", ptr %7, i32 0, i32 1
  %11 = load i64, ptr %6, align 8
  store i64 %11, ptr %10, align 8
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__134__uninitialized_allocator_relocateB9nqe220106INS_9allocatorIiEEPiEEvRT_T0_S6_S6_(ptr noundef nonnull align 1 dereferenceable(1) %0, ptr noundef %1, ptr noundef %2, ptr noundef %3) #1 {
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  store ptr %3, ptr %8, align 8
  %9 = load ptr, ptr %8, align 8
  %10 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %9) #6
  %11 = load ptr, ptr %6, align 8
  %12 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %11) #6
  %13 = load ptr, ptr %7, align 8
  %14 = load ptr, ptr %6, align 8
  %15 = ptrtoint ptr %13 to i64
  %16 = ptrtoint ptr %14 to i64
  %17 = sub i64 %15, %16
  %18 = sdiv exact i64 %17, 4
  %19 = mul i64 4, %18
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %10, ptr align 4 %12, i64 %19, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__14swapB9nqe220106IPiEENS_9enable_ifIXaasr21is_move_constructibleIT_EE5valuesr18is_move_assignableIS3_EE5valueEvE4typeERS3_S6_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  %7 = load ptr, ptr %6, align 8
  store ptr %7, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %9 = load ptr, ptr %8, align 8
  %10 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  store ptr %9, ptr %10, align 8
  %11 = load ptr, ptr %5, align 8
  %12 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  store ptr %11, ptr %12, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE14__annotate_newB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %7 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %5) #6
  %8 = getelementptr inbounds nuw i32, ptr %6, i64 %7
  %9 = call ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %10 = load i64, ptr %4, align 8
  %11 = getelementptr inbounds nuw i32, ptr %9, i64 %10
  invoke void @_ZNKSt3__16vectorIiNS_9allocatorIiEEE31__annotate_contiguous_containerB9nqe220106EPKvS5_(ptr noundef %5, ptr noundef %8, ptr noundef %11)
          to label %12 unwind label %13

12:                                               ; preds = %2
  ret void

13:                                               ; preds = %2
  %14 = landingpad { ptr, i32 }
          catch ptr null
  %15 = extractvalue { ptr, i32 } %14, 0
  call void @__clang_call_terminate(ptr %15) #17
  unreachable
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #13

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEED2Ev(ptr noundef returned %0) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  store ptr %4, ptr %2, align 8
  call void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE5clearB9nqe220106Ev(ptr noundef %4) #6
  %5 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %4, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %8, label %16

8:                                                ; preds = %1
  %9 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %4, i32 0, i32 3
  %10 = getelementptr inbounds nuw %struct.anon.3, ptr %9, i32 0, i32 1
  %11 = load ptr, ptr %10, align 8, !nonnull !8
  %12 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %4, i32 0, i32 0
  %13 = load ptr, ptr %12, align 8
  %14 = invoke i64 @_ZNKSt3__114__split_bufferIiRNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %4)
          to label %15 unwind label %18

15:                                               ; preds = %8
  call void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE10deallocateB9nqe220106ERS2_Pim(ptr noundef nonnull align 1 dereferenceable(1) %11, ptr noundef %13, i64 noundef %14) #6
  br label %16

16:                                               ; preds = %15, %1
  %17 = load ptr, ptr %2, align 8
  ret ptr %17

18:                                               ; preds = %8
  %19 = landingpad { ptr, i32 }
          catch ptr null
  %20 = extractvalue { ptr, i32 } %19, 0
  call void @__clang_call_terminate(ptr %20) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE5clearB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %3, i32 0, i32 1
  %5 = load ptr, ptr %4, align 8
  call void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE17__destruct_at_endB9nqe220106EPi(ptr noundef %3, ptr noundef %5) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__114__split_bufferIiRNS_9allocatorIiEEE8capacityB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %3, i32 0, i32 3
  %5 = getelementptr inbounds nuw %struct.anon.3, ptr %4, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %3, i32 0, i32 0
  %8 = load ptr, ptr %7, align 8
  %9 = ptrtoint ptr %6 to i64
  %10 = ptrtoint ptr %8 to i64
  %11 = sub i64 %9, %10
  %12 = sdiv exact i64 %11, 4
  ret i64 %12
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE17__destruct_at_endB9nqe220106EPi(ptr noundef %0, ptr noundef %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca %"struct.std::__1::integral_constant", align 1
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %6 = load ptr, ptr %3, align 8
  %7 = load ptr, ptr %4, align 8
  call void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE17__destruct_at_endB9nqe220106EPiNS_17integral_constantIbLb0EEE(ptr noundef %6, ptr noundef %7) #6
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__114__split_bufferIiRNS_9allocatorIiEEE17__destruct_at_endB9nqe220106EPiNS_17integral_constantIbLb0EEE(ptr noundef %0, ptr noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca %"struct.std::__1::integral_constant", align 1
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  br label %7

7:                                                ; preds = %20, %2
  %8 = load ptr, ptr %5, align 8
  %9 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %6, i32 0, i32 2
  %10 = load ptr, ptr %9, align 8
  %11 = icmp ne ptr %8, %10
  br i1 %11, label %12, label %21

12:                                               ; preds = %7
  %13 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %6, i32 0, i32 3
  %14 = getelementptr inbounds nuw %struct.anon.3, ptr %13, i32 0, i32 1
  %15 = load ptr, ptr %14, align 8, !nonnull !8
  %16 = getelementptr inbounds nuw %"struct.std::__1::__split_buffer", ptr %6, i32 0, i32 2
  %17 = load ptr, ptr %16, align 8
  %18 = getelementptr inbounds i32, ptr %17, i32 -1
  store ptr %18, ptr %16, align 8
  %19 = call ptr @_ZNSt3__112__to_addressB9nqe220106IiEEPT_S2_(ptr noundef %18) #6
  invoke void @_ZNSt3__116allocator_traitsINS_9allocatorIiEEE7destroyB9nqe220106IiLi0EEEvRS2_PT_(ptr noundef nonnull align 1 dereferenceable(1) %15, ptr noundef %19)
          to label %20 unwind label %22

20:                                               ; preds = %12
  br label %7, !llvm.loop !12

21:                                               ; preds = %7
  ret void

22:                                               ; preds = %12
  %23 = landingpad { ptr, i32 }
          catch ptr null
  %24 = extractvalue { ptr, i32 } %23, 0
  call void @__clang_call_terminate(ptr %24) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt3__16vectorIiNS_9allocatorIiEEEixB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  %8 = load i64, ptr %4, align 8
  %9 = getelementptr inbounds nuw i32, ptr %7, i64 %8
  ret ptr %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE5beginB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca %"class.std::__1::__wrap_iter", align 8
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %4, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE26__add_alignment_assumptionB9nqe220106IPiLi0EEES5_T_(ptr noundef %6) #6
  %8 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE11__make_iterB9nqe220106EPKi(ptr noundef %4, ptr noundef %7) #6
  %9 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %2, i32 0, i32 0
  %10 = inttoptr i64 %8 to ptr
  store ptr %10, ptr %9, align 8
  %11 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %2, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8
  %13 = ptrtoint ptr %12 to i64
  ret i64 %13
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE3endB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca %"class.std::__1::__wrap_iter", align 8
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = getelementptr inbounds nuw %"class.std::__1::vector", ptr %4, i32 0, i32 1
  %6 = load ptr, ptr %5, align 8
  %7 = call ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE26__add_alignment_assumptionB9nqe220106IPiLi0EEES5_T_(ptr noundef %6) #6
  %8 = call i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE11__make_iterB9nqe220106EPKi(ptr noundef %4, ptr noundef %7) #6
  %9 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %2, i32 0, i32 0
  %10 = inttoptr i64 %8 to ptr
  store ptr %10, ptr %9, align 8
  %11 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %2, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8
  %13 = ptrtoint ptr %12 to i64
  ret i64 %13
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNSt3__1neB9nqe220106IPKiEEbRKNS_11__wrap_iterIT_EES7_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  %6 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %7 = call zeroext i1 @_ZNSt3__1eqB9nqe220106IPKiEEbRKNS_11__wrap_iterIT_EES7_(ptr noundef nonnull align 8 dereferenceable(8) %5, ptr noundef nonnull align 8 dereferenceable(8) %6) #6
  %8 = xor i1 %7, true
  ret i1 %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt3__111__wrap_iterIPKiEdeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt3__111__wrap_iterIPKiEppB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8
  %6 = getelementptr inbounds nuw i32, ptr %5, i32 1
  store ptr %6, ptr %4, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__16vectorIiNS_9allocatorIiEEE11__make_iterB9nqe220106EPKi(ptr noundef %0, ptr noundef %1) #1 {
  %3 = alloca %"class.std::__1::__wrap_iter", align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = load ptr, ptr %5, align 8
  %8 = call ptr @_ZNSt3__111__wrap_iterIPKiEC1B9nqe220106ES2_(ptr noundef %3, ptr noundef %7) #6
  %9 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %3, i32 0, i32 0
  %10 = load ptr, ptr %9, align 8
  %11 = ptrtoint ptr %10 to i64
  ret i64 %11
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr ptr @_ZNSt3__16vectorIiNS_9allocatorIiEEE26__add_alignment_assumptionB9nqe220106IPiLi0EEES5_T_(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  call void @llvm.assume(i1 true) [ "align"(ptr %3, i64 4) ]
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__111__wrap_iterIPKiEC1B9nqe220106ES2_(ptr noundef returned %0, ptr noundef %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt3__111__wrap_iterIPKiEC2B9nqe220106ES2_(ptr noundef %5, ptr noundef %6) #6
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__111__wrap_iterIPKiEC2B9nqe220106ES2_(ptr noundef returned %0, ptr noundef %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %4, align 8
  store ptr %7, ptr %6, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNSt3__1eqB9nqe220106IPKiEEbRKNS_11__wrap_iterIT_EES7_(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8, !nonnull !8, !align !10
  %6 = call ptr @_ZNKSt3__111__wrap_iterIPKiE4baseB9nqe220106Ev(ptr noundef %5) #6
  %7 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %8 = call ptr @_ZNKSt3__111__wrap_iterIPKiE4baseB9nqe220106Ev(ptr noundef %7) #6
  %9 = icmp eq ptr %6, %8
  ret i1 %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__111__wrap_iterIPKiE4baseB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::__wrap_iter", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__121__concatenate_stringsB9nqe220106IcNS_11char_traitsIcEENS_9allocatorIcEEEENS_12basic_stringIT_T0_T1_EERKS8_NS_15__type_identityINS_17basic_string_viewIS6_S7_EEE4typeESG_(ptr dead_on_unwind noalias writable sret(%"class.std::__1::basic_string") align 8 %0, ptr noundef nonnull align 1 dereferenceable(1) %1, [2 x i64] %2, [2 x i64] %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca %"class.std::__1::basic_string_view", align 8
  %7 = alloca %"class.std::__1::basic_string_view", align 8
  %8 = alloca ptr, align 8
  %9 = alloca i1, align 1
  %10 = alloca %"struct.std::__1::__uninitialized_size_tag", align 1
  %11 = alloca %"class.std::__1::allocator.5", align 1
  %12 = alloca %"class.std::__1::allocator.5", align 1
  %13 = alloca ptr, align 8
  %14 = alloca i8, align 1
  store ptr %0, ptr %5, align 8
  store [2 x i64] %2, ptr %6, align 8
  store [2 x i64] %3, ptr %7, align 8
  store ptr %1, ptr %8, align 8
  store i1 false, ptr %9, align 1
  %15 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %6) #6
  %16 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %7) #6
  %17 = add i64 %15, %16
  %18 = load ptr, ptr %8, align 8, !nonnull !8
  call void @_ZNSt3__116allocator_traitsINS_9allocatorIcEEE37select_on_container_copy_constructionB9nqe220106IS2_Li0EEES2_RKS2_(ptr noundef nonnull align 1 dereferenceable(1) %18)
  %19 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106ENS_24__uninitialized_size_tagEmRKS4_(ptr noundef %0, i64 noundef %17, ptr noundef nonnull align 1 dereferenceable(1) %11)
  %20 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__get_pointerB9nqe220106Ev(ptr noundef %0) #6
  %21 = call ptr @_ZNSt3__112__to_addressB9nqe220106IcEEPT_S2_(ptr noundef %20) #6
  store ptr %21, ptr %13, align 8
  %22 = load ptr, ptr %13, align 8
  %23 = call ptr @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4dataB9nqe220106Ev(ptr noundef %6) #6
  %24 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %6) #6
  %25 = call ptr @_ZNSt3__111char_traitsIcE4copyB9nqe220106EPcPKcm(ptr noundef %22, ptr noundef %23, i64 noundef %24) #6
  %26 = load ptr, ptr %13, align 8
  %27 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %6) #6
  %28 = getelementptr inbounds nuw i8, ptr %26, i64 %27
  %29 = call ptr @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4dataB9nqe220106Ev(ptr noundef %7) #6
  %30 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %7) #6
  %31 = call ptr @_ZNSt3__111char_traitsIcE4copyB9nqe220106EPcPKcm(ptr noundef %28, ptr noundef %29, i64 noundef %30) #6
  %32 = load ptr, ptr %13, align 8
  %33 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %6) #6
  %34 = call i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %7) #6
  %35 = add i64 %33, %34
  %36 = getelementptr inbounds nuw i8, ptr %32, i64 %35
  store i8 0, ptr %14, align 1
  call void @_ZNSt3__111char_traitsIcE6assignB9nqe220106ERcRKc(ptr noundef nonnull align 1 dereferenceable(1) %36, ptr noundef nonnull align 1 dereferenceable(1) %14) #6
  store i1 true, ptr %9, align 1
  %37 = load i1, ptr %9, align 1
  br i1 %37, label %40, label %38

38:                                               ; preds = %4
  %39 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEED1Ev(ptr noundef %0) #6
  br label %40

40:                                               ; preds = %38, %4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13get_allocatorB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden [2 x i64] @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEcvNS_17basic_string_viewIcS2_EEB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca %"class.std::__1::basic_string_view", align 8
  %3 = alloca ptr, align 8
  %4 = alloca %"struct.std::__1::basic_string_view<char>::__assume_valid", align 1
  store ptr %0, ptr %3, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %7 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeB9nqe220106Ev(ptr noundef %5) #6
  %8 = call ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC1B9nqe220106ENS3_14__assume_validEPKcm(ptr noundef %2, ptr noundef %6, i64 noundef %7) #6
  %9 = load [2 x i64], ptr %2, align 8
  ret [2 x i64] %9
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC1B9nqe220106EPKc(ptr noundef returned %0, ptr noundef %1) unnamed_addr #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC2B9nqe220106EPKc(ptr noundef %5, ptr noundef %6)
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %3, i32 0, i32 1
  %5 = load i64, ptr %4, align 8
  ret i64 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__116allocator_traitsINS_9allocatorIcEEE37select_on_container_copy_constructionB9nqe220106IS2_Li0EEES2_RKS2_(ptr noundef nonnull align 1 dereferenceable(1) %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8, !nonnull !8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106ENS_24__uninitialized_size_tagEmRKS4_(ptr noundef returned %0, i64 noundef %1, ptr noundef nonnull align 1 dereferenceable(1) %2) unnamed_addr #0 {
  %4 = alloca %"struct.std::__1::__uninitialized_size_tag", align 1
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  %10 = load ptr, ptr %7, align 8
  %11 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC2B9nqe220106ENS_24__uninitialized_size_tagEmRKS4_(ptr noundef %8, i64 noundef %9, ptr noundef nonnull align 1 dereferenceable(1) %10)
  ret ptr %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112__to_addressB9nqe220106IcEEPT_S2_(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__get_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %3) #6
  br i1 %4, label %5, label %7

5:                                                ; preds = %1
  %6 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE18__get_long_pointerB9nqe220106Ev(ptr noundef %3) #6
  br label %9

7:                                                ; preds = %1
  %8 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE19__get_short_pointerB9nqe220106Ev(ptr noundef %3) #6
  br label %9

9:                                                ; preds = %7, %5
  %10 = phi ptr [ %6, %5 ], [ %8, %7 ]
  ret ptr %10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__111char_traitsIcE4copyB9nqe220106EPcPKcm(ptr noundef %0, ptr noundef %1, i64 noundef %2) #1 personality ptr @__gxx_personality_v0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  %10 = invoke ptr @_ZNSt3__119__constexpr_memmoveB9nqe220106IcKcEEPT_S3_PT0_NS_15__element_countE(ptr noundef %7, ptr noundef %8, i64 noundef %9)
          to label %11 unwind label %13

11:                                               ; preds = %3
  %12 = load ptr, ptr %4, align 8
  ret ptr %12

13:                                               ; preds = %3
  %14 = landingpad { ptr, i32 }
          catch ptr null
  %15 = extractvalue { ptr, i32 } %14, 0
  call void @__clang_call_terminate(ptr %15) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__117basic_string_viewIcNS_11char_traitsIcEEE4dataB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %3, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__111char_traitsIcE6assignB9nqe220106ERcRKc(ptr noundef nonnull align 1 dereferenceable(1) %0, ptr noundef nonnull align 1 dereferenceable(1) %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %4, align 8, !nonnull !8
  %6 = load i8, ptr %5, align 1
  %7 = load ptr, ptr %3, align 8, !nonnull !8
  store i8 %6, ptr %7, align 1
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC2B9nqe220106ENS_24__uninitialized_size_tagEmRKS4_(ptr noundef returned %0, i64 noundef %1, ptr noundef nonnull align 1 dereferenceable(1) %2) unnamed_addr #0 {
  %4 = alloca %"struct.std::__1::__uninitialized_size_tag", align 1
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %10 = getelementptr inbounds nuw %struct.anon.0, ptr %9, i32 0, i32 0
  %11 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %12 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %13 = load ptr, ptr %7, align 8, !nonnull !8
  %14 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %15 = load i64, ptr %6, align 8
  %16 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__init_internal_bufferB9nqe220106Em(ptr noundef %8, i64 noundef %15)
  ret ptr %8
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__init_internal_bufferB9nqe220106Em(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca %"struct.std::__1::basic_string<char>::__long", align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load i64, ptr %5, align 8
  %9 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE8max_sizeB9nqe220106Ev(ptr noundef %7) #6
  %10 = icmp ugt i64 %8, %9
  br i1 %10, label %11, label %12

11:                                               ; preds = %2
  call void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE20__throw_length_errorB9nqe220106Ev() #15
  unreachable

12:                                               ; preds = %2
  %13 = load i64, ptr %5, align 8
  %14 = call zeroext i1 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__fits_in_ssoB9nqe220106Em(i64 noundef %13)
  br i1 %14, label %15, label %19

15:                                               ; preds = %12
  %16 = load i64, ptr %5, align 8
  call void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE16__set_short_sizeB9nqe220106Em(ptr noundef %7, i64 noundef %16) #6
  %17 = load i64, ptr %5, align 8
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__annotate_newB9nqe220106Em(ptr noundef %7, i64 noundef %17) #6
  %18 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE19__get_short_pointerB9nqe220106Ev(ptr noundef %7) #6
  store ptr %18, ptr %3, align 8
  br label %26

19:                                               ; preds = %12
  %20 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %7, i32 0, i32 0
  %21 = load i64, ptr %5, align 8
  call void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__allocate_long_bufferB9nqe220106ERS4_m(ptr dead_on_unwind writable sret(%"struct.std::__1::basic_string<char>::__long") align 8 %6, ptr noundef nonnull align 1 dereferenceable(1) %20, i64 noundef %21)
  %22 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %7, i32 0, i32 0
  %23 = getelementptr inbounds nuw %struct.anon.0, ptr %22, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %23, ptr align 8 %6, i64 24, i1 false)
  %24 = load i64, ptr %5, align 8
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__annotate_newB9nqe220106Em(ptr noundef %7, i64 noundef %24) #6
  %25 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE18__get_long_pointerB9nqe220106Ev(ptr noundef %7) #6
  store ptr %25, ptr %3, align 8
  br label %26

26:                                               ; preds = %19, %15
  %27 = load ptr, ptr %3, align 8
  ret ptr %27
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE8max_sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca i64, align 8
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i8, align 1
  store ptr %0, ptr %3, align 8
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %7, i32 0, i32 0
  %9 = call i64 @_ZNSt3__116allocator_traitsINS_9allocatorIcEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %8) #6
  store i64 %9, ptr %4, align 8
  %10 = load i64, ptr %4, align 8
  %11 = call i64 @_ZNSt3__114numeric_limitsImE3maxB9nqe220106Ev() #6
  %12 = udiv i64 %11, 2
  %13 = icmp ule i64 %10, %12
  br i1 %13, label %14, label %19

14:                                               ; preds = %1
  %15 = load i64, ptr %4, align 8
  %16 = sub i64 %15, 8
  store i64 %16, ptr %5, align 8
  %17 = load i64, ptr %5, align 8
  %18 = sub i64 %17, 1
  store i64 %18, ptr %2, align 8
  br label %33

19:                                               ; preds = %1
  store i8 0, ptr %6, align 1
  %20 = load i8, ptr %6, align 1
  %21 = trunc i8 %20 to i1
  br i1 %21, label %22, label %26

22:                                               ; preds = %19
  %23 = load i64, ptr %4, align 8
  %24 = sub i64 %23, 8
  %25 = sub i64 %24, 1
  br label %31

26:                                               ; preds = %19
  %27 = load i64, ptr %4, align 8
  %28 = udiv i64 %27, 2
  %29 = sub i64 %28, 8
  %30 = sub i64 %29, 1
  br label %31

31:                                               ; preds = %26, %22
  %32 = phi i64 [ %25, %22 ], [ %30, %26 ]
  store i64 %32, ptr %2, align 8
  br label %33

33:                                               ; preds = %31, %14
  %34 = load i64, ptr %2, align 8
  ret i64 %34
}

; Function Attrs: mustprogress noinline noreturn optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE20__throw_length_errorB9nqe220106Ev() #10 {
  call void @_ZNSt3__120__throw_length_errorB9nqe220106EPKc(ptr noundef @.str.3) #15
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__fits_in_ssoB9nqe220106Em(i64 noundef %0) #1 {
  %2 = alloca i64, align 8
  store i64 %0, ptr %2, align 8
  %3 = load i64, ptr %2, align 8
  %4 = icmp ult i64 %3, 23
  ret i1 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE16__set_short_sizeB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load i64, ptr %4, align 8
  %7 = trunc i64 %6 to i8
  %8 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %5, i32 0, i32 0
  %9 = getelementptr inbounds nuw %struct.anon.0, ptr %8, i32 0, i32 0
  %10 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %9, i32 0, i32 1
  %11 = load i8, ptr %10, align 1
  %12 = and i8 %7, 127
  %13 = and i8 %11, -128
  %14 = or i8 %13, %12
  store i8 %14, ptr %10, align 1
  %15 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %5, i32 0, i32 0
  %16 = getelementptr inbounds nuw %struct.anon.0, ptr %15, i32 0, i32 0
  %17 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %16, i32 0, i32 1
  %18 = load i8, ptr %17, align 1
  %19 = and i8 %18, 127
  %20 = or i8 %19, 0
  store i8 %20, ptr %17, align 1
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__annotate_newB9nqe220106Em(ptr noundef %0, i64 noundef %1) #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %7 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE8capacityB9nqe220106Ev(ptr noundef %5) #6
  %8 = getelementptr inbounds nuw i8, ptr %6, i64 %7
  %9 = getelementptr inbounds i8, ptr %8, i64 1
  %10 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %5) #6
  %11 = load i64, ptr %4, align 8
  %12 = getelementptr inbounds nuw i8, ptr %10, i64 %11
  %13 = getelementptr inbounds i8, ptr %12, i64 1
  invoke void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE31__annotate_contiguous_containerB9nqe220106EPKvS7_(ptr noundef %5, ptr noundef %9, ptr noundef %13)
          to label %14 unwind label %15

14:                                               ; preds = %2
  ret void

15:                                               ; preds = %2
  %16 = landingpad { ptr, i32 }
          catch ptr null
  %17 = extractvalue { ptr, i32 } %16, 0
  call void @__clang_call_terminate(ptr %17) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE19__get_short_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %5, i32 0, i32 0
  %7 = getelementptr inbounds [23 x i8], ptr %6, i64 0, i64 0
  %8 = call ptr @_ZNSt3__114pointer_traitsIPcE10pointer_toB9nqe220106ERc(ptr noundef nonnull align 1 dereferenceable(1) %7) #6
  ret ptr %8
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE22__allocate_long_bufferB9nqe220106ERS4_m(ptr dead_on_unwind noalias writable sret(%"struct.std::__1::basic_string<char>::__long") align 8 %0, ptr noundef nonnull align 1 dereferenceable(1) %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca %"struct.std::__1::__allocation_result.8", align 8
  %7 = alloca %"struct.std::__1::__allocation_result.8", align 8
  store ptr %1, ptr %4, align 8
  store i64 %2, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8, !nonnull !8
  %9 = load i64, ptr %5, align 8
  %10 = call i64 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE23__align_allocation_sizeB9nqe220106Em(i64 noundef %9) #6
  %11 = call [2 x i64] @_ZNSt3__119__allocate_at_leastB9nqe220106INS_9allocatorIcEENS_16allocator_traitsIS2_EEEENS_19__allocation_resultINT0_7pointerENS6_9size_typeEEERT_m(ptr noundef nonnull align 1 dereferenceable(1) %8, i64 noundef %10)
  store [2 x i64] %11, ptr %6, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %7, ptr align 8 %6, i64 16, i1 false)
  %12 = load i64, ptr %5, align 8
  %13 = load [2 x i64], ptr %7, align 8
  %14 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6__longC1B9nqe220106ENS_19__allocation_resultIPcmEEm(ptr noundef %0, [2 x i64] %13, i64 noundef %12)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE18__get_long_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i64 @_ZNSt3__116allocator_traitsINS_9allocatorIcEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8, !nonnull !8
  %4 = call i64 @_ZNKSt3__19allocatorIcE8max_sizeB9nqe220106Ev(ptr noundef %3) #6
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__114numeric_limitsImE3maxB9nqe220106Ev() #1 {
  %1 = call i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3maxB9nqe220106Ev() #6
  ret i64 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__19allocatorIcE8max_sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret i64 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3maxB9nqe220106Ev() #1 {
  ret i64 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE31__annotate_contiguous_containerB9nqe220106EPKvS7_(ptr noundef %0, ptr noundef %1, ptr noundef %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__get_pointerB9nqe220106Ev(ptr noundef %3) #6
  %5 = call ptr @_ZNSt3__112__to_addressB9nqe220106IKcEEPT_S3_(ptr noundef %4) #6
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE8capacityB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %3) #6
  br i1 %4, label %5, label %7

5:                                                ; preds = %1
  %6 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__get_long_capB9nqe220106Ev(ptr noundef %3) #6
  br label %8

7:                                                ; preds = %1
  br label %8

8:                                                ; preds = %7, %5
  %9 = phi i64 [ %6, %5 ], [ 23, %7 ]
  %10 = sub i64 %9, 1
  ret i64 %10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112__to_addressB9nqe220106IKcEEPT_S3_(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE13__get_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %3) #6
  br i1 %4, label %5, label %7

5:                                                ; preds = %1
  %6 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE18__get_long_pointerB9nqe220106Ev(ptr noundef %3) #6
  br label %9

7:                                                ; preds = %1
  %8 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE19__get_short_pointerB9nqe220106Ev(ptr noundef %3) #6
  br label %9

9:                                                ; preds = %7, %5
  %10 = phi ptr [ %6, %5 ], [ %8, %7 ]
  ret ptr %10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %5, i32 0, i32 1
  %7 = load i8, ptr %6, align 1
  %8 = lshr i8 %7, 7
  %9 = icmp ne i8 %8, 0
  ret i1 %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE18__get_long_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE19__get_short_pointerB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %5, i32 0, i32 0
  %7 = getelementptr inbounds [23 x i8], ptr %6, i64 0, i64 0
  %8 = call ptr @_ZNSt3__114pointer_traitsIPKcE10pointer_toB9nqe220106ERS1_(ptr noundef nonnull align 1 dereferenceable(1) %7) #6
  ret ptr %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114pointer_traitsIPKcE10pointer_toB9nqe220106ERS1_(ptr noundef nonnull align 1 dereferenceable(1) %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8, !nonnull !8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__get_long_capB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %5, i32 0, i32 2
  %7 = load i64, ptr %6, align 8
  %8 = and i64 %7, 9223372036854775807
  %9 = mul i64 %8, 1
  ret i64 %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__114pointer_traitsIPcE10pointer_toB9nqe220106ERc(ptr noundef nonnull align 1 dereferenceable(1) %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8, !nonnull !8
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden [2 x i64] @_ZNSt3__119__allocate_at_leastB9nqe220106INS_9allocatorIcEENS_16allocator_traitsIS2_EEEENS_19__allocation_resultINT0_7pointerENS6_9size_typeEEERT_m(ptr noundef nonnull align 1 dereferenceable(1) %0, i64 noundef %1) #0 {
  %3 = alloca %"struct.std::__1::__allocation_result.8", align 8
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8
  %7 = load i64, ptr %5, align 8
  %8 = call ptr @_ZNSt3__19allocatorIcE8allocateB9nqe220106Em(ptr noundef %6, i64 noundef %7)
  %9 = load i64, ptr %5, align 8
  %10 = call ptr @_ZNSt3__119__allocation_resultIPcmEC1B9nqe220106ES1_m(ptr noundef %3, ptr noundef %8, i64 noundef %9)
  %11 = load [2 x i64], ptr %3, align 8
  ret [2 x i64] %11
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE23__align_allocation_sizeB9nqe220106Em(i64 noundef %0) #1 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store i64 %0, ptr %2, align 8
  store i64 8, ptr %3, align 8
  %5 = load i64, ptr %2, align 8
  %6 = add i64 %5, 1
  %7 = call i64 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE10__align_itB9nqe220106ILm8EEEmm(i64 noundef %6) #6
  store i64 %7, ptr %4, align 8
  %8 = load i64, ptr %4, align 8
  %9 = icmp eq i64 %8, 24
  br i1 %9, label %10, label %13

10:                                               ; preds = %1
  %11 = load i64, ptr %4, align 8
  %12 = add i64 %11, 1
  store i64 %12, ptr %4, align 8
  br label %13

13:                                               ; preds = %10, %1
  %14 = load i64, ptr %4, align 8
  ret i64 %14
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6__longC1B9nqe220106ENS_19__allocation_resultIPcmEEm(ptr noundef returned %0, [2 x i64] %1, i64 noundef %2) unnamed_addr #0 {
  %4 = alloca %"struct.std::__1::__allocation_result.8", align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store [2 x i64] %1, ptr %4, align 8
  store ptr %0, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %5, align 8
  %8 = load i64, ptr %6, align 8
  %9 = load [2 x i64], ptr %4, align 8
  %10 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6__longC2B9nqe220106ENS_19__allocation_resultIPcmEEm(ptr noundef %7, [2 x i64] %9, i64 noundef %8)
  ret ptr %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__19allocatorIcE8allocateB9nqe220106Em(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load i64, ptr %4, align 8
  %7 = call i64 @_ZNSt3__116allocator_traitsINS_9allocatorIcEEE8max_sizeB9nqe220106IS2_Li0EEEmRKS2_(ptr noundef nonnull align 1 dereferenceable(1) %5) #6
  %8 = icmp ugt i64 %6, %7
  br i1 %8, label %9, label %10

9:                                                ; preds = %2
  call void @_ZSt28__throw_bad_array_new_lengthB9nqe220106v() #15
  unreachable

10:                                               ; preds = %2
  %11 = load i64, ptr %4, align 8
  %12 = call ptr @_ZNSt3__117__libcpp_allocateB9nqe220106IcEEPT_NS_15__element_countEm(i64 noundef %11, i64 noundef 1)
  ret ptr %12
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__119__allocation_resultIPcmEC1B9nqe220106ES1_m(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load i64, ptr %6, align 8
  %10 = call ptr @_ZNSt3__119__allocation_resultIPcmEC2B9nqe220106ES1_m(ptr noundef %7, ptr noundef %8, i64 noundef %9)
  ret ptr %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117__libcpp_allocateB9nqe220106IcEEPT_NS_15__element_countEm(i64 noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  store i64 %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %7 = load i64, ptr %4, align 8
  %8 = mul i64 %7, 1
  store i64 %8, ptr %6, align 8
  %9 = load i64, ptr %5, align 8
  %10 = call zeroext i1 @_ZNSt3__124__is_overaligned_for_newB9nqe220106Em(i64 noundef %9) #6
  br i1 %10, label %11, label %15

11:                                               ; preds = %2
  %12 = load i64, ptr %6, align 8
  %13 = load i64, ptr %5, align 8
  %14 = call noalias nonnull ptr @_ZnwmSt11align_val_t(i64 noundef %12, i64 noundef %13) #18
  call void @llvm.assume(i1 true) [ "align"(ptr %14, i64 %13) ]
  store ptr %14, ptr %3, align 8
  br label %18

15:                                               ; preds = %2
  %16 = load i64, ptr %6, align 8
  %17 = call noalias nonnull ptr @_Znwm(i64 noundef %16) #18
  store ptr %17, ptr %3, align 8
  br label %18

18:                                               ; preds = %15, %11
  %19 = load ptr, ptr %3, align 8
  ret ptr %19
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__119__allocation_resultIPcmEC2B9nqe220106ES1_m(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result.8", ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %5, align 8
  store ptr %9, ptr %8, align 8
  %10 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result.8", ptr %7, i32 0, i32 1
  %11 = load i64, ptr %6, align 8
  store i64 %11, ptr %10, align 8
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr i64 @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE10__align_itB9nqe220106ILm8EEEmm(i64 noundef %0) #1 {
  %2 = alloca i64, align 8
  store i64 %0, ptr %2, align 8
  %3 = load i64, ptr %2, align 8
  %4 = add i64 %3, 7
  %5 = and i64 %4, -8
  ret i64 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6__longC2B9nqe220106ENS_19__allocation_resultIPcmEEm(ptr noundef returned %0, [2 x i64] %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca %"struct.std::__1::__allocation_result.8", align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  store [2 x i64] %1, ptr %4, align 8
  store ptr %0, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load ptr, ptr %5, align 8
  %8 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %7, i32 0, i32 0
  %9 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result.8", ptr %4, i32 0, i32 0
  %10 = load ptr, ptr %9, align 8
  store ptr %10, ptr %8, align 8
  %11 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %7, i32 0, i32 1
  %12 = load i64, ptr %6, align 8
  store i64 %12, ptr %11, align 8
  %13 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %7, i32 0, i32 2
  %14 = getelementptr inbounds nuw %"struct.std::__1::__allocation_result.8", ptr %4, i32 0, i32 1
  %15 = load i64, ptr %14, align 8
  %16 = udiv i64 %15, 1
  %17 = load i64, ptr %13, align 8
  %18 = and i64 %16, 9223372036854775807
  %19 = and i64 %17, -9223372036854775808
  %20 = or i64 %19, %18
  store i64 %20, ptr %13, align 8
  %21 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %7, i32 0, i32 2
  %22 = load i64, ptr %21, align 8
  %23 = and i64 %22, 9223372036854775807
  %24 = or i64 %23, -9223372036854775808
  store i64 %24, ptr %21, align 8
  ret ptr %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__119__constexpr_memmoveB9nqe220106IcKcEEPT_S3_PT0_NS_15__element_countE(ptr noundef %0, ptr noundef %1, i64 noundef %2) #1 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %8 = load i64, ptr %6, align 8
  store i64 %8, ptr %7, align 8
  %9 = load ptr, ptr %4, align 8
  %10 = load ptr, ptr %5, align 8
  %11 = load i64, ptr %7, align 8
  %12 = mul i64 %11, 1
  call void @llvm.memmove.p0.p0.i64(ptr align 1 %9, ptr align 1 %10, i64 %12, i1 false)
  %13 = load ptr, ptr %4, align 8
  ret ptr %13
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #13

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %3) #6
  br i1 %4, label %5, label %7

5:                                                ; preds = %1
  %6 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE15__get_long_sizeB9nqe220106Ev(ptr noundef %3) #6
  br label %9

7:                                                ; preds = %1
  %8 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE16__get_short_sizeB9nqe220106Ev(ptr noundef %3) #6
  br label %9

9:                                                ; preds = %7, %5
  %10 = phi i64 [ %6, %5 ], [ %8, %7 ]
  ret i64 %10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC1B9nqe220106ENS3_14__assume_validEPKcm(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca %"struct.std::__1::basic_string_view<char>::__assume_valid", align 1
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = load ptr, ptr %6, align 8
  %10 = load i64, ptr %7, align 8
  %11 = call ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC2B9nqe220106ENS3_14__assume_validEPKcm(ptr noundef %8, ptr noundef %9, i64 noundef %10) #6
  ret ptr %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE15__get_long_sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__long", ptr %5, i32 0, i32 1
  %7 = load i64, ptr %6, align 8
  ret i64 %7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE16__get_short_sizeB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %3, i32 0, i32 0
  %5 = getelementptr inbounds nuw %struct.anon.0, ptr %4, i32 0, i32 0
  %6 = getelementptr inbounds nuw %"struct.std::__1::basic_string<char>::__short", ptr %5, i32 0, i32 1
  %7 = load i8, ptr %6, align 1
  %8 = and i8 %7, 127
  %9 = zext i8 %8 to i64
  ret i64 %9
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC2B9nqe220106ENS3_14__assume_validEPKcm(ptr noundef returned %0, ptr noundef %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca %"struct.std::__1::basic_string_view<char>::__assume_valid", align 1
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %8, i32 0, i32 0
  %10 = load ptr, ptr %6, align 8
  store ptr %10, ptr %9, align 8
  %11 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %8, i32 0, i32 1
  %12 = load i64, ptr %7, align 8
  store i64 %12, ptr %11, align 8
  ret ptr %8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__117basic_string_viewIcNS_11char_traitsIcEEEC2B9nqe220106EPKc(ptr noundef returned %0, ptr noundef %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %5, i32 0, i32 0
  %7 = load ptr, ptr %4, align 8
  store ptr %7, ptr %6, align 8
  %8 = getelementptr inbounds nuw %"class.std::__1::basic_string_view", ptr %5, i32 0, i32 1
  %9 = load ptr, ptr %4, align 8
  %10 = call i64 @_ZNSt3__128__char_traits_length_checkedB9nqe220106INS_11char_traitsIcEEEEmPKNT_9char_typeE(ptr noundef %9) #6
  store i64 %10, ptr %8, align 8
  ret ptr %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__128__char_traits_length_checkedB9nqe220106INS_11char_traitsIcEEEEmPKNT_9char_typeE(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call i64 @_ZNSt3__111char_traitsIcE6lengthB9nqe220106EPKc(ptr noundef %3) #6
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__111char_traitsIcE6lengthB9nqe220106EPKc(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call i64 @_ZNSt3__118__constexpr_strlenB9nqe220106IcEEmPKT_(ptr noundef %3) #6
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden i64 @_ZNSt3__118__constexpr_strlenB9nqe220106IcEEmPKT_(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call i64 @strlen(ptr noundef %3) #6
  ret i64 %4
}

; Function Attrs: nounwind
declare i64 @strlen(ptr noundef) #3

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendB9nqe220106ERKS5_(ptr noundef %0, ptr noundef nonnull align 8 dereferenceable(24) %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %7 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %6) #6
  %8 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %9 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeB9nqe220106Ev(ptr noundef %8) #6
  %10 = call noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendEPKcm(ptr noundef %5, ptr noundef %7, i64 noundef %9)
  ret ptr %10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106EOS5_(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1) unnamed_addr #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = call ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC2B9nqe220106EOS5_(ptr noundef %5, ptr noundef nonnull align 8 dereferenceable(24) %6) #6
  ret ptr %5
}

declare noundef nonnull align 8 dereferenceable(24) ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendEPKcm(ptr noundef, ptr noundef, i64 noundef) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden ptr @_ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC2B9nqe220106EOS5_(ptr noundef returned %0, ptr noundef nonnull align 8 dereferenceable(24) %1) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca %class.anon.9, align 1
  %7 = alloca %"union.std::__1::basic_string<char>::__rep", align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  store ptr %8, ptr %3, align 8
  %9 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %10 = getelementptr inbounds nuw %struct.anon.0, ptr %9, i32 0, i32 0
  %11 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %12 = invoke noundef nonnull align 8 dereferenceable(24) ptr @_ZZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106EOS5_ENKUlRS5_E_clES7_(ptr noundef %6, ptr noundef nonnull align 8 dereferenceable(24) %11)
          to label %13 unwind label %28

13:                                               ; preds = %2
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %10, ptr align 8 %12, i64 24, i1 false)
  %14 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %15 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  %16 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %17 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %16, i32 0, i32 0
  %18 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %8, i32 0, i32 0
  call void @llvm.memset.p0.i64(ptr align 8 %7, i8 0, i64 24, i1 false)
  %19 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  %20 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %19, i32 0, i32 0
  %21 = getelementptr inbounds nuw %struct.anon.0, ptr %20, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %21, ptr align 8 %7, i64 24, i1 false)
  %22 = load ptr, ptr %5, align 8, !nonnull !8, !align !10
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__annotate_newB9nqe220106Em(ptr noundef %22, i64 noundef 0) #6
  %23 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %8) #6
  br i1 %23, label %26, label %24

24:                                               ; preds = %13
  %25 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeB9nqe220106Ev(ptr noundef %8) #6
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE14__annotate_newB9nqe220106Em(ptr noundef %8, i64 noundef %25) #6
  br label %26

26:                                               ; preds = %24, %13
  %27 = load ptr, ptr %3, align 8
  ret ptr %27

28:                                               ; preds = %2
  %29 = landingpad { ptr, i32 }
          catch ptr null
  %30 = extractvalue { ptr, i32 } %29, 0
  call void @__clang_call_terminate(ptr %30) #17
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef nonnull align 8 dereferenceable(24) ptr @_ZZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1B9nqe220106EOS5_ENKUlRS5_E_clES7_(ptr noundef %0, ptr noundef nonnull align 8 dereferenceable(24) %1) #1 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %7 = call zeroext i1 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__is_longB9nqe220106Ev(ptr noundef %6) #6
  br i1 %7, label %10, label %8

8:                                                ; preds = %2
  %9 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE17__annotate_deleteB9nqe220106Ev(ptr noundef %9) #6
  br label %10

10:                                               ; preds = %8, %2
  %11 = load ptr, ptr %4, align 8, !nonnull !8, !align !10
  %12 = getelementptr inbounds nuw %"class.std::__1::basic_string", ptr %11, i32 0, i32 0
  %13 = getelementptr inbounds nuw %struct.anon.0, ptr %12, i32 0, i32 0
  ret ptr %13
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #14

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE17__annotate_deleteB9nqe220106Ev(ptr noundef %0) #1 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %3) #6
  %5 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeB9nqe220106Ev(ptr noundef %3) #6
  %6 = getelementptr inbounds nuw i8, ptr %4, i64 %5
  %7 = getelementptr inbounds i8, ptr %6, i64 1
  %8 = call ptr @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4dataB9nqe220106Ev(ptr noundef %3) #6
  %9 = call i64 @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE8capacityB9nqe220106Ev(ptr noundef %3) #6
  %10 = getelementptr inbounds nuw i8, ptr %8, i64 %9
  %11 = getelementptr inbounds i8, ptr %10, i64 1
  call void @_ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE31__annotate_contiguous_containerB9nqe220106EPKvS7_(ptr noundef %3, ptr noundef %7, ptr noundef %11)
  ret void
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @_GLOBAL__sub_I_eh.cpp() #5 section "__TEXT,__StaticInit,regular,pure_instructions" {
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { nounwind memory(none) }
attributes #5 = { noinline ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { nounwind }
attributes #7 = { nobuiltin nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #8 = { noinline noreturn nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { convergent nocallback nofree nosync nounwind willreturn memory(none) }
attributes #10 = { mustprogress noinline noreturn optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #11 = { nobuiltin allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #12 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #13 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #14 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #15 = { noreturn }
attributes #16 = { builtin nounwind }
attributes #17 = { noreturn nounwind }
attributes #18 = { builtin allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 21.0.0 (clang-2100.3.34.2)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{}
!9 = !{i64 4}
!10 = !{i64 8}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
