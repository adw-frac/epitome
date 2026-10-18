; draconian-opt: --no-inline
;
; Loop rotation and induction variables, from clang -O0 of:
;   long sum_to(int *a, int n) { long s = 0; for (int i = 0; i < n; i++) s += a[i]; return s; }
;   int last(int n) { int i; for (i = 0; i < n; i++) {} return i; }
;   unsigned count_down(unsigned n) { unsigned t = 0; for (unsigned i = n; i > 0; i--) t += i; return t; }
;   int squares(void) { int t = 0; for (int i = 3; i < 13; i++) t += i * i; return t; }
;   int main(void) {
;     int a[7] = {1, 2, 3, 4, 5, 6, 7};
;     return (int)(sum_to(a, 7) + last(5) + count_down(4) + squares()) & 255;
;   }

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"

@__const.main.a = private unnamed_addr constant [7 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7], align 4

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i64 @sum_to(ptr noundef %a, i32 noundef %n) #0 {
entry:
  %a.addr = alloca ptr, align 8
  %n.addr = alloca i32, align 4
  %s = alloca i64, align 8
  %i = alloca i32, align 4
  store ptr %a, ptr %a.addr, align 8
  store i32 %n, ptr %n.addr, align 4
  store i64 0, ptr %s, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %n.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load ptr, ptr %a.addr, align 8
  %3 = load i32, ptr %i, align 4
  %idxprom = sext i32 %3 to i64
  %arrayidx = getelementptr inbounds i32, ptr %2, i64 %idxprom
  %4 = load i32, ptr %arrayidx, align 4
  %conv = sext i32 %4 to i64
  %5 = load i64, ptr %s, align 8
  %add = add nsw i64 %5, %conv
  store i64 %add, ptr %s, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %6 = load i32, ptr %i, align 4
  %inc = add nsw i32 %6, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  %7 = load i64, ptr %s, align 8
  ret i64 %7
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @last(i32 noundef %n) #0 {
entry:
  %n.addr = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %n, ptr %n.addr, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %n.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32, ptr %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !8

for.end:                                          ; preds = %for.cond
  %3 = load i32, ptr %i, align 4
  ret i32 %3
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @count_down(i32 noundef %n) #0 {
entry:
  %n.addr = alloca i32, align 4
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %n, ptr %n.addr, align 4
  store i32 0, ptr %t, align 4
  %0 = load i32, ptr %n.addr, align 4
  store i32 %0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i32, ptr %i, align 4
  %cmp = icmp ugt i32 %1, 0
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32, ptr %i, align 4
  %3 = load i32, ptr %t, align 4
  %add = add i32 %3, %2
  store i32 %add, ptr %t, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %4 = load i32, ptr %i, align 4
  %dec = add i32 %4, -1
  store i32 %dec, ptr %i, align 4
  br label %for.cond, !llvm.loop !9

for.end:                                          ; preds = %for.cond
  %5 = load i32, ptr %t, align 4
  ret i32 %5
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @squares() #0 {
entry:
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, ptr %t, align 4
  store i32 3, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 13
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, ptr %i, align 4
  %2 = load i32, ptr %i, align 4
  %mul = mul nsw i32 %1, %2
  %3 = load i32, ptr %t, align 4
  %add = add nsw i32 %3, %mul
  store i32 %add, ptr %t, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %4 = load i32, ptr %i, align 4
  %inc = add nsw i32 %4, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !10

for.end:                                          ; preds = %for.cond
  %5 = load i32, ptr %t, align 4
  ret i32 %5
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %a = alloca [7 x i32], align 4
  store i32 0, ptr %retval, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 @__const.main.a, i64 28, i1 false)
  %arraydecay = getelementptr inbounds [7 x i32], ptr %a, i64 0, i64 0
  %call = call i64 @sum_to(ptr noundef %arraydecay, i32 noundef 7)
  %call1 = call i32 @last(i32 noundef 5)
  %conv = sext i32 %call1 to i64
  %add = add nsw i64 %call, %conv
  %call2 = call i32 @count_down(i32 noundef 4)
  %conv3 = zext i32 %call2 to i64
  %add4 = add nsw i64 %add, %conv3
  %call5 = call i32 @squares()
  %conv6 = sext i32 %call5 to i64
  %add7 = add nsw i64 %add4, %conv6
  %conv8 = trunc i64 %add7 to i32
  %and = and i32 %conv8, 255
  ret i32 %and
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!1, !2, !3, !4}

!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
