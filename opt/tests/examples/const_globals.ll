; draconian-opt: --passes=combine
; Loads from constant globals fold to the initialiser's value; a global
; that is not constant, or whose definition may be replaced (weak), stays.
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
%pt = type { i32, i64, [2 x i16] }
@table = private constant [4 x i32] [i32 10, i32 20, i32 30, i32 40]
@pt = internal constant %pt { i32 1, i64 2, [2 x i16] [i16 3, i16 4] }
@str = private constant [6 x i8] c"hello\00"
@var = global i32 5
@weak = weak constant i32 6

define i64 @f() {
  %p = getelementptr inbounds [4 x i32], ptr @table, i64 0, i64 2
  %a = load i32, ptr %p
  %b = load i64, ptr getelementptr inbounds (%pt, ptr @pt, i32 0, i32 1)
  %q = getelementptr inbounds %pt, ptr @pt, i32 0, i32 2, i64 1
  %c = load i16, ptr %q
  %d = load i32, ptr getelementptr inbounds (i8, ptr @str, i64 1)
  %e = load i32, ptr @var
  %w = load i32, ptr @weak
  %a64 = zext i32 %a to i64
  %c64 = zext i16 %c to i64
  %d64 = zext i32 %d to i64
  %e64 = zext i32 %e to i64
  %w64 = zext i32 %w to i64
  %s1 = add i64 %a64, %b
  %s2 = add i64 %s1, %c64
  %s3 = add i64 %s2, %d64
  %s4 = add i64 %s3, %e64
  %s5 = add i64 %s4, %w64
  ret i64 %s5
}
