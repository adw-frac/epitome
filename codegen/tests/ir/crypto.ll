; CRC32, SHA-1, SHA-256, SHA-512 and AES intrinsics (clang -O2 of C using
; arm_acle.h and arm_neon.h), as 45-crypto.ll has them.
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: nofree norecurse nosync nounwind ssp memory(argmem: read) uwtable(sync)
define i32 @crc(ptr noundef readonly captures(none) %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = icmp slt i32 %1, 8
  br i1 %4, label %7, label %5

5:                                                ; preds = %3
  %6 = zext nneg i32 %1 to i64
  br label %12

7:                                                ; preds = %3
  %8 = icmp sgt i32 %1, 0
  br i1 %8, label %9, label %24

9:                                                ; preds = %12, %7
  %10 = phi i32 [ %2, %7 ], [ %20, %12 ]
  %11 = zext nneg i32 %1 to i64
  br label %26

12:                                               ; preds = %5, %12
  %13 = phi i64 [ 0, %5 ], [ %23, %12 ]
  %14 = phi i64 [ 8, %5 ], [ %21, %12 ]
  %15 = phi i32 [ %2, %5 ], [ %20, %12 ]
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 %13
  %17 = load i64, ptr %16, align 1
  %18 = tail call i32 @llvm.aarch64.crc32x(i32 %15, i64 %17)
  %19 = xor i64 %17, 1
  %20 = tail call i32 @llvm.aarch64.crc32cx(i32 %18, i64 %19)
  %21 = add nuw nsw i64 %14, 8
  %22 = icmp samesign ugt i64 %21, %6
  %23 = add nuw nsw i64 %13, 8
  br i1 %22, label %9, label %12, !llvm.loop !6

24:                                               ; preds = %26, %7
  %25 = phi i32 [ %2, %7 ], [ %43, %26 ]
  ret i32 %25

26:                                               ; preds = %9, %26
  %27 = phi i64 [ 0, %9 ], [ %44, %26 ]
  %28 = phi i32 [ %10, %9 ], [ %43, %26 ]
  %29 = getelementptr inbounds nuw i8, ptr %0, i64 %27
  %30 = load i8, ptr %29, align 1, !tbaa !8
  %31 = zext i8 %30 to i32
  %32 = tail call i32 @llvm.aarch64.crc32b(i32 %28, i32 %31)
  %33 = add i8 %30, 1
  %34 = zext i8 %33 to i32
  %35 = tail call i32 @llvm.aarch64.crc32cb(i32 %32, i32 %34)
  %36 = mul nuw nsw i32 %31, 3
  %37 = tail call i32 @llvm.aarch64.crc32h(i32 %35, i32 %36)
  %38 = mul nuw nsw i32 %31, 77777
  %39 = tail call i32 @llvm.aarch64.crc32cw(i32 %37, i32 range(i32 0, 19833136) %38)
  %40 = trunc nuw nsw i64 %27 to i32
  %41 = tail call i32 @llvm.aarch64.crc32w(i32 %39, i32 range(i32 -2147483648, 2147483646) %40)
  %42 = and i32 %40, 65535
  %43 = tail call i32 @llvm.aarch64.crc32ch(i32 %41, i32 %42)
  %44 = add nuw nsw i64 %27, 1
  %45 = icmp eq i64 %44, %11
  br i1 %45, label %24, label %26, !llvm.loop !11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @sha256(ptr noundef captures(none) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #1 {
  %3 = load <4 x i32>, ptr %0, align 16, !tbaa !8
  %4 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %5 = load <4 x i32>, ptr %4, align 16, !tbaa !8
  %6 = load <4 x i32>, ptr %1, align 16, !tbaa !8
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %8 = load <4 x i32>, ptr %7, align 16, !tbaa !8
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %10 = load <4 x i32>, ptr %9, align 16, !tbaa !8
  %11 = getelementptr inbounds nuw i8, ptr %1, i64 48
  %12 = load <4 x i32>, ptr %11, align 16, !tbaa !8
  %13 = add <4 x i32> %6, splat (i32 1116352408)
  %14 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32> %3, <4 x i32> %5, <4 x i32> %13)
  %15 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32> %5, <4 x i32> %3, <4 x i32> %13)
  %16 = add <4 x i32> %8, splat (i32 1116352409)
  %17 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32> %14, <4 x i32> %15, <4 x i32> %16)
  %18 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32> %15, <4 x i32> %14, <4 x i32> %16)
  %19 = add <4 x i32> %10, splat (i32 1116352410)
  %20 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32> %17, <4 x i32> %18, <4 x i32> %19)
  %21 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32> %18, <4 x i32> %17, <4 x i32> %19)
  %22 = add <4 x i32> %12, splat (i32 1116352411)
  %23 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32> %20, <4 x i32> %21, <4 x i32> %22)
  %24 = tail call <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32> %21, <4 x i32> %20, <4 x i32> %22)
  store <4 x i32> %23, ptr %0, align 16, !tbaa !8
  store <4 x i32> %24, ptr %4, align 16, !tbaa !8
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @sha1(ptr noundef captures(none) initializes((16, 32)) %0, ptr noundef captures(none) %1, ptr noundef readonly captures(none) %2) local_unnamed_addr #1 {
  %4 = load <4 x i32>, ptr %0, align 16, !tbaa !8
  %5 = load i32, ptr %1, align 4, !tbaa !12
  %6 = load <4 x i32>, ptr %2, align 16, !tbaa !8
  %7 = tail call <4 x i32> @llvm.aarch64.crypto.sha1c(<4 x i32> %4, i32 %5, <4 x i32> %6)
  %8 = extractelement <4 x i32> %7, i64 0
  %9 = tail call i32 @llvm.aarch64.crypto.sha1h(i32 %8)
  %10 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %11 = load <4 x i32>, ptr %10, align 16, !tbaa !8
  %12 = tail call <4 x i32> @llvm.aarch64.crypto.sha1p(<4 x i32> %7, i32 %9, <4 x i32> %11)
  %13 = add i32 %9, 5
  %14 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %15 = load <4 x i32>, ptr %14, align 16, !tbaa !8
  %16 = tail call <4 x i32> @llvm.aarch64.crypto.sha1m(<4 x i32> %12, i32 %13, <4 x i32> %15)
  store <4 x i32> %16, ptr %0, align 16, !tbaa !8
  %17 = load <4 x i32>, ptr %2, align 16, !tbaa !8
  %18 = load <4 x i32>, ptr %10, align 16, !tbaa !8
  %19 = load <4 x i32>, ptr %14, align 16, !tbaa !8
  %20 = tail call <4 x i32> @llvm.aarch64.crypto.sha1su0(<4 x i32> %17, <4 x i32> %18, <4 x i32> %19)
  %21 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %22 = load <4 x i32>, ptr %21, align 16, !tbaa !8
  %23 = tail call <4 x i32> @llvm.aarch64.crypto.sha1su1(<4 x i32> %20, <4 x i32> %22)
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store <4 x i32> %23, ptr %24, align 16, !tbaa !8
  store i32 %9, ptr %1, align 4, !tbaa !12
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @sha512(ptr noundef captures(none) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #1 {
  %3 = load <2 x i64>, ptr %0, align 16, !tbaa !8
  %4 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %5 = load <2 x i64>, ptr %4, align 16, !tbaa !8
  %6 = load <2 x i64>, ptr %1, align 16, !tbaa !8
  %7 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64> %3, <2 x i64> %5, <2 x i64> %6)
  %8 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %9 = load <2 x i64>, ptr %8, align 16, !tbaa !8
  %10 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64> %7, <2 x i64> %3, <2 x i64> %9)
  %11 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64> %6, <2 x i64> %9)
  %12 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %13 = load <2 x i64>, ptr %12, align 16, !tbaa !8
  %14 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64> %11, <2 x i64> %13, <2 x i64> %7)
  %15 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64> %14, <2 x i64> %10, <2 x i64> %9)
  %16 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64> %15, <2 x i64> %14, <2 x i64> %13)
  %17 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64> %9, <2 x i64> %13)
  %18 = getelementptr inbounds nuw i8, ptr %1, i64 48
  %19 = load <2 x i64>, ptr %18, align 16, !tbaa !8
  %20 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64> %17, <2 x i64> %19, <2 x i64> %15)
  %21 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64> %20, <2 x i64> %16, <2 x i64> %13)
  %22 = tail call <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64> %21, <2 x i64> %20, <2 x i64> %19)
  %23 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64> %13, <2 x i64> %19)
  %24 = getelementptr inbounds nuw i8, ptr %1, i64 64
  %25 = load <2 x i64>, ptr %24, align 16, !tbaa !8
  %26 = tail call <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64> %23, <2 x i64> %25, <2 x i64> %21)
  store <2 x i64> %26, ptr %0, align 16, !tbaa !8
  store <2 x i64> %22, ptr %4, align 16, !tbaa !8
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync)
define void @aes(ptr noundef captures(none) initializes((16, 32)) %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #1 {
  %3 = load <16 x i8>, ptr %0, align 16, !tbaa !8
  %4 = load <16 x i8>, ptr %1, align 16, !tbaa !8
  %5 = tail call <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8> %3, <16 x i8> %4)
  %6 = tail call <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8> %5)
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %8 = load <16 x i8>, ptr %7, align 16, !tbaa !8
  %9 = tail call <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8> %6, <16 x i8> %8)
  %10 = tail call <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8> %9)
  %11 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %12 = load <16 x i8>, ptr %11, align 16, !tbaa !8
  %13 = tail call <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8> %10, <16 x i8> %12)
  %14 = tail call <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8> %13)
  %15 = getelementptr inbounds nuw i8, ptr %1, i64 48
  %16 = load <16 x i8>, ptr %15, align 16, !tbaa !8
  %17 = tail call <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8> %14, <16 x i8> %16)
  %18 = tail call <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8> %17)
  store <16 x i8> %18, ptr %0, align 16, !tbaa !8
  %19 = getelementptr inbounds nuw i8, ptr %1, i64 64
  %20 = load <16 x i8>, ptr %19, align 16, !tbaa !8
  %21 = tail call <16 x i8> @llvm.aarch64.crypto.aesd(<16 x i8> %18, <16 x i8> %20)
  %22 = tail call <16 x i8> @llvm.aarch64.crypto.aesimc(<16 x i8> %21)
  %23 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store <16 x i8> %22, ptr %23, align 16, !tbaa !8
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32x(i32, i64) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32cx(i32, i64) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32b(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32cb(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32h(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32cw(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32w(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crc32ch(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32>, <4 x i32>, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32>, <4 x i32>, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha1c(<4 x i32>, i32, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.aarch64.crypto.sha1h(i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha1p(<4 x i32>, i32, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha1m(<4 x i32>, i32, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha1su1(<4 x i32>, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <4 x i32> @llvm.aarch64.crypto.sha1su0(<4 x i32>, <4 x i32>, <4 x i32>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64>, <2 x i64>, <2 x i64>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64>, <2 x i64>, <2 x i64>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64>, <2 x i64>, <2 x i64>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64>, <2 x i64>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8>, <16 x i8>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.crypto.aesimc(<16 x i8>) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <16 x i8> @llvm.aarch64.crypto.aesd(<16 x i8>, <16 x i8>) #2

attributes #0 = { nofree norecurse nosync nounwind ssp memory(argmem: read) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+fp-armv8,+lse,+neon,+ras,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8a" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(argmem: readwrite) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+fp-armv8,+lse,+neon,+ras,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8a" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{!9, !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C/C++ TBAA"}
!11 = distinct !{!11, !7}
!12 = !{!13, !13, i64 0}
!13 = !{!"int", !9, i64 0}
