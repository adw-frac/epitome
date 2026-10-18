; @sum_to: mem2reg: 4 allocas promoted (7 loads, 6 stores removed)
; @sum_to: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @sum_to: rotate: 1 loops rotated
; @sum_to: combine: (constant to the right) x1
; @sum_to: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @sum_to: indvars: loop %for.body runs %n times when entered
; @sum_to: indvars: 1 exact exit tests, 0 exit values, 1 counters widened
; @last: mem2reg: 2 allocas promoted (4 loads, 3 stores removed)
; @last: simplifycfg: 0 unreachable blocks removed, 1 empty blocks bypassed, 0 selects made, 0 blocks merged
; @last: rotate: 1 loops rotated
; @last: combine: (constant to the right) x1
; @last: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @last: indvars: loop %for.inc runs %n times when entered
; @last: indvars: 1 exact exit tests, 1 exit values, 0 counters widened
; @count_down: mem2reg: 3 allocas promoted (6 loads, 5 stores removed)
; @count_down: combine: icmp_ugt_zero x1
; @count_down: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @count_down: rotate: 1 loops rotated
; @count_down: combine: icmp_ne_add x1
; @count_down: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @count_down: indvars: loop %for.body runs %n times when entered
; @squares: mem2reg: 2 allocas promoted (6 loads, 4 stores removed)
; @squares: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @squares: rotate: 1 loops rotated
; @squares: combine: (folded) x2, br_true x1
; @squares: simplifycfg: 0 unreachable blocks removed, 0 empty blocks bypassed, 0 selects made, 1 blocks merged
; @squares: indvars: loop %for.body runs 10 times when entered
; @squares: indvars: 1 exact exit tests, 0 exit values, 0 counters widened
; @squares: combine: icmp_ne_add x1
; @main: mem2reg: 1 allocas promoted (0 loads, 1 stores removed)

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"

@__const.main.a = private unnamed_addr constant [7 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7], align 4

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i64 @sum_to(ptr noundef %a, i32 noundef %n) #0 {
entry:
  %cmp1 = icmp sgt i32 %n, 0
  %wide.bound = sext i32 %n to i64
  br i1 %cmp1, label %for.body, label %for.end

for.body:                                         ; preds = %for.body, %entry
  %i.wide = phi i64 [ 0, %entry ], [ %i.wide.next, %for.body ]
  %s = phi i64 [ 0, %entry ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds i32, ptr %a, i64 %i.wide
  %0 = load i32, ptr %arrayidx, align 4
  %conv = sext i32 %0 to i64
  %add = add nsw i64 %s, %conv
  %i.wide.next = add nsw i64 %i.wide, 1
  %cmp = icmp ne i64 %i.wide.next, %wide.bound
  br i1 %cmp, label %for.body, label %for.end

for.end:                                          ; preds = %for.body, %entry
  %s1 = phi i64 [ 0, %entry ], [ %add, %for.body ]
  ret i64 %s1
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @last(i32 noundef %n) #0 {
entry:
  %cmp1 = icmp sgt i32 %n, 0
  br i1 %cmp1, label %for.inc, label %for.end

for.inc:                                          ; preds = %for.inc, %entry
  %i = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %inc = add nsw i32 %i, 1
  %cmp = icmp ne i32 %inc, %n
  br i1 %cmp, label %for.inc, label %for.end

for.end:                                          ; preds = %for.inc, %entry
  %i1 = phi i32 [ 0, %entry ], [ %n, %for.inc ]
  ret i32 %i1
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @count_down(i32 noundef %n) #0 {
entry:
  %cmp1 = icmp ne i32 %n, 0
  br i1 %cmp1, label %for.body, label %for.end

for.body:                                         ; preds = %for.body, %entry
  %i = phi i32 [ %n, %entry ], [ %dec, %for.body ]
  %t = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %add = add i32 %t, %i
  %dec = add i32 %i, -1
  %cmp = icmp ne i32 %i, 1
  br i1 %cmp, label %for.body, label %for.end

for.end:                                          ; preds = %for.body, %entry
  %t1 = phi i32 [ 0, %entry ], [ %add, %for.body ]
  ret i32 %t1
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @squares() #0 {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %t = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %i = phi i32 [ 3, %entry ], [ %inc, %for.body ]
  %mul = mul nsw i32 %i, %i
  %add = add nsw i32 %t, %mul
  %inc = add nsw i32 %i, 1
  %cmp = icmp ne i32 %i, 12
  br i1 %cmp, label %for.body, label %for.end

for.end:                                          ; preds = %for.body
  ret i32 %add
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 {
entry:
  %a = alloca [7 x i32], align 4
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

!llvm.module.flags = !{!0, !1, !2, !3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 1}
