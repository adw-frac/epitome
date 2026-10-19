; @f: combine: (constant to the right) x1, (dead) x3, (folded) x10, (reassociated) x1

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

%pt = type { i32, i64, [2 x i16] }

@table = private constant [4 x i32] [i32 10, i32 20, i32 30, i32 40]
@pt = internal constant %pt { i32 1, i64 2, [2 x i16] [i16 3, i16 4] }
@str = private constant [6 x i8] c"hello\00"
@var = global i32 5
@weak = weak constant i32 6

define i64 @f() {
  %e = load i32, ptr @var
  %w = load i32, ptr @weak
  %e64 = zext i32 %e to i64
  %w64 = zext i32 %w to i64
  %1 = add i64 %e64, %w64
  %s5 = add i64 %1, 1869376649
  ret i64 %s5
}
