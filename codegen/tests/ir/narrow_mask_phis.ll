; Masks of comparisons of vectors narrower than a register (<2 x i8>,
; done lane by lane) in a loop's phis, selected by a scalar, ored, and a
; select of masks: itertools' positions(), vectorised two at a time.
target triple = "arm64-apple-macosx14.0.0"
declare i64 @llvm.experimental.vector.extract.last.active.v2i64(<2 x i64>, <2 x i1>, i64)
define void @f(ptr %o, ptr %p, i64 %n) {
entry:
  br label %body
body:
  %i = phi i64 [ 0, %entry ], [ %i2, %body ]
  %ind = phi <2 x i64> [ <i64 0, i64 1>, %entry ], [ %ind2, %body ]
  %last = phi <2 x i64> [ zeroinitializer, %entry ], [ %last2, %body ]
  %m = phi <2 x i1> [ zeroinitializer, %entry ], [ %m2, %body ]
  %any = phi <2 x i1> [ zeroinitializer, %entry ], [ %any2, %body ]
  %q = getelementptr i8, ptr %p, i64 %i
  %w = load <2 x i8>, ptr %q, align 1
  %u = urem <2 x i8> %w, splat (i8 5)
  %c = icmp eq <2 x i8> %u, zeroinitializer
  %bits = bitcast <2 x i1> %c to i2
  %none = icmp eq i2 %bits, 0
  %m2 = select i1 %none, <2 x i1> %m, <2 x i1> %c
  %last2 = select i1 %none, <2 x i64> %last, <2 x i64> %ind
  %any2 = or <2 x i1> %any, %c
  %both = select <2 x i1> %any2, <2 x i1> %c, <2 x i1> %m2
  %i2 = add i64 %i, 2
  %ind2 = add <2 x i64> %ind, splat (i64 2)
  %done = icmp eq i64 %i2, %n
  br i1 %done, label %out, label %body
out:
  %r = call i64 @llvm.experimental.vector.extract.last.active.v2i64(<2 x i64> %last2, <2 x i1> %m2, i64 -1)
  store i64 %r, ptr %o
  %ab = bitcast <2 x i1> %any2 to i2
  %az = zext i2 %ab to i64
  %o1 = getelementptr i64, ptr %o, i64 1
  store i64 %az, ptr %o1
  %bb = bitcast <2 x i1> %both to i2
  %bz = zext i2 %bb to i64
  %o2 = getelementptr i64, ptr %o, i64 2
  store i64 %bz, ptr %o2
  ret void
}
