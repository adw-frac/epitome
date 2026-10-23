; x86-64's flags and the conditions that read them. The conventions are
; those of codegen/targets/aarch64/00-base.ll.
;
; The flags, lazily: the two values last compared, sign-extended (which
; keeps both their signed and unsigned order), as AArch64's are. cmp and
; test set them ("sets"); most arithmetic writes them too ("clobbers"="flags"),
; so a compare's user follows it directly. The letters are ZF, CF, SF, OF.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"

%flags = type { i64, i64 }

define i1 @cc.b(%flags %f) "cond"="2" "asm"="b" "reads"="c" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp ult i64 %a, %b
  ret i1 %c
}

define i1 @cc.ae(%flags %f) "cond"="3" "asm"="ae" "reads"="c" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp uge i64 %a, %b
  ret i1 %c
}

define i1 @cc.e(%flags %f) "cond"="4" "asm"="e" "reads"="z" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp eq i64 %a, %b
  ret i1 %c
}

define i1 @cc.ne(%flags %f) "cond"="5" "asm"="ne" "reads"="z" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp ne i64 %a, %b
  ret i1 %c
}

define i1 @cc.be(%flags %f) "cond"="6" "asm"="be" "reads"="cz" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp ule i64 %a, %b
  ret i1 %c
}

define i1 @cc.a(%flags %f) "cond"="7" "asm"="a" "reads"="cz" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp ugt i64 %a, %b
  ret i1 %c
}

define i1 @cc.l(%flags %f) "cond"="12" "asm"="l" "reads"="so" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp slt i64 %a, %b
  ret i1 %c
}

define i1 @cc.ge(%flags %f) "cond"="13" "asm"="ge" "reads"="so" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp sge i64 %a, %b
  ret i1 %c
}

define i1 @cc.le(%flags %f) "cond"="14" "asm"="le" "reads"="zso" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp sle i64 %a, %b
  ret i1 %c
}

define i1 @cc.g(%flags %f) "cond"="15" "asm"="g" "reads"="zso" {
  %a = extractvalue %flags %f, 0
  %b = extractvalue %flags %f, 1
  %c = icmp sgt i64 %a, %b
  ret i1 %c
}
