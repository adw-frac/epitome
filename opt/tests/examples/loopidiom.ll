; Loop idiom recognition (loopidiom.rs): loops that only set memory to one
; byte become memsets, a loop nest one memset; loops that store a value
; whose bytes differ, or also read memory, stay loops.

@grid = global [4 x [10 x float]] zeroinitializer
@row = global [16 x i32] zeroinitializer
@other = global [16 x i32] zeroinitializer

; The rows of @grid set to 0.0, as linalg-to-loops writes a fill.
define void @fill(ptr %p) noinline {
entry:
  br label %rows
rows:
  %i = phi i64 [ 0, %entry ], [ %i.next, %row.end ]
  %more.rows = icmp slt i64 %i, 4
  br i1 %more.rows, label %cols, label %done
cols:
  %j = phi i64 [ 0, %rows ], [ %j.next, %col ]
  %more.cols = icmp slt i64 %j, 10
  br i1 %more.cols, label %col, label %row.end
col:
  %base = mul i64 %i, 10
  %at = add i64 %base, %j
  %a = getelementptr float, ptr %p, i64 %at
  store float 0.0, ptr %a
  %j.next = add i64 %j, 1
  br label %cols
row.end:
  %i.next = add i64 %i, 1
  br label %rows
done:
  ret void
}

; n words of -1 from p: a memset of n * 4 bytes, when n > 0.
define void @ones(ptr %p, i64 %n) noinline {
entry:
  %any = icmp sgt i64 %n, 0
  br i1 %any, label %loop, label %done
loop:
  %k = phi i64 [ 0, %entry ], [ %k.next, %loop ]
  %a = getelementptr i32, ptr %p, i64 %k
  store i32 -1, ptr %a
  %k.next = add nsw i64 %k, 1
  %again = icmp slt i64 %k.next, %n
  br i1 %again, label %loop, label %done
done:
  ret void
}

; 1 is not one byte four times: stays a loop.
define void @not_a_byte(ptr %p) noinline {
entry:
  br label %loop
loop:
  %k = phi i64 [ 0, %entry ], [ %k.next, %loop ]
  %a = getelementptr i32, ptr %p, i64 %k
  store i32 1, ptr %a
  %k.next = add i64 %k, 1
  %again = icmp slt i64 %k.next, 16
  br i1 %again, label %loop, label %done
done:
  ret void
}

; Also reads memory: stays a loop.
define void @copy_and_clear(ptr %p, ptr %q) noinline {
entry:
  br label %loop
loop:
  %k = phi i64 [ 0, %entry ], [ %k.next, %loop ]
  %a = getelementptr i32, ptr %p, i64 %k
  %b = getelementptr i32, ptr %q, i64 %k
  %x = load i32, ptr %a
  store i32 %x, ptr %b
  store i32 0, ptr %a
  %k.next = add i64 %k, 1
  %again = icmp slt i64 %k.next, 16
  br i1 %again, label %loop, label %done
done:
  ret void
}

define i32 @main() {
entry:
  store float 3.0, ptr getelementptr (float, ptr @grid, i64 17)
  call void @fill(ptr @grid)
  %g = load float, ptr getelementptr (float, ptr @grid, i64 17)
  %gz = fcmp oeq float %g, 0.0
  call void @ones(ptr @row, i64 5)
  %r4 = load i32, ptr getelementptr (i32, ptr @row, i64 4)
  %r5 = load i32, ptr getelementptr (i32, ptr @row, i64 5)
  call void @not_a_byte(ptr @other)
  %o = load i32, ptr getelementptr (i32, ptr @other, i64 15)
  call void @copy_and_clear(ptr @other, ptr @row)
  %c = load i32, ptr getelementptr (i32, ptr @row, i64 15)
  %z = load i32, ptr getelementptr (i32, ptr @other, i64 15)
  ; -1 + 0 + 1 + 1 + 0, and 10 more if the grid was cleared.
  %s1 = add i32 %r4, %r5
  %s2 = add i32 %s1, %o
  %s3 = add i32 %s2, %c
  %s4 = add i32 %s3, %z
  %gi = select i1 %gz, i32 10, i32 0
  %s = add i32 %s4, %gi
  ret i32 %s
}
