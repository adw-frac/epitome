; Hand-written, in the printer's canonical layout, so printing must give
; back exactly this text. Forms come from the LLVM Language Reference.
source_filename = "features.ll"
target datalayout = "e-m:e-i64:64-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

module asm "nop"

%pair = type { i32, i32 }
%packed = type <{ i8, i32 }>
%opaque = type opaque
%0 = type { ptr }

$c1 = comdat any
$c2 = comdat largest

@g = global i32 17, comdat($c1), align 4
@arr = constant [3 x i32] [i32 1, i32 2, i32 3]
@str = private unnamed_addr constant [4 x i8] c"a\22\5C\00", align 1
@zero = global [4 x i32] zeroinitializer
@pk = global %packed <{ i8 1, i32 2 }>
@vec = global <4 x i32> <i32 1, i32 2, i32 3, i32 4>
@spl = global <2 x float> splat (float 1.000000e+00)
@ce = global i64 ptrtoint (ptr @g to i64)
@gep = global ptr getelementptr inbounds (i8, ptr @arr, i64 4)
@sum = global i64 add nuw (i64 1, i64 2)
@ext = external global %opaque
@weak = extern_weak global i32
@tls = thread_local(initialexec) global i32 0, section "tdata", align 8
@as = addrspace(3) global i32 0
@own = linkonce_odr global i32 0, comdat
@h = hidden global half 0xH3C00
@bf = global bfloat 0xR3F80
@tgt = global target("spirv.Image", void, 1) zeroinitializer
@0 = global i32 1
@one = global ptr @0
@tok = global [2 x ptr] [ptr blockaddress(@branchy, %b1), ptr blockaddress(@branchy, %b2)]

@al = alias i32, ptr @g

@ifn = ifunc void (), ptr @resolver

define i32 @arith(i32 %a, i32 %b) {
entry:
  %s = add nuw nsw i32 %a, %b
  %d = sdiv exact i32 %s, 4
  %o = or disjoint i32 %d, 1
  %x = xor i32 %o, -1
  %c = icmp samesign ult i32 %x, %a
  %t = trunc nuw i32 %x to i8
  %z = zext nneg i8 %t to i32
  %r = select i1 %c, i32 %z, i32 %a
  %f = freeze i32 %r
  ret i32 %f
}

define float @fp(float %a, double %b) {
  %n = fneg fast float %a
  %m = fmul nnan ninf float %n, 2.500000e+00
  %t = fptrunc double %b to float
  %c = fcmp olt float %m, %t
  %r = select nsz i1 %c, float %m, float 0x3FB99999A0000000
  ret float %r
}

define void @memory(ptr %p, i32 %v) {
  %a = alloca i32, i32 4, align 16
  %l = load volatile i32, ptr %p, align 4
  store atomic i32 %v, ptr %p syncscope("singlethread") release, align 4
  %la = load atomic i32, ptr %p acquire, align 4
  fence seq_cst
  %x = cmpxchg weak volatile ptr %p, i32 %l, i32 %v acq_rel monotonic, align 4
  %ok = extractvalue { i32, i1 } %x, 1
  %old = atomicrmw umax ptr %p, i32 %v seq_cst, align 4
  %q = getelementptr nusw nuw %pair, ptr %a, i64 0, i32 1
  ret void
}

define <4 x i32> @vectors(<4 x i32> %a, <4 x i32> %b) {
  %e = extractelement <4 x i32> %a, i64 0
  %i = insertelement <4 x i32> %b, i32 %e, i64 3
  %s = shufflevector <4 x i32> %a, <4 x i32> %i, <4 x i32> <i32 0, i32 4, i32 poison, i32 7>
  %sv = shufflevector <vscale x 4 x i32> poison, <vscale x 4 x i32> poison, <vscale x 4 x i32> zeroinitializer
  ret <4 x i32> %s
}

define i32 @branchy(i32 %x, ptr %ap) {
entry:
  br label %b1

b1:                                               ; preds = %b2, %entry
  %phi = phi i32 [ 0, %entry ], [ %next, %b2 ]
  %next = add i32 %phi, 1
  switch i32 %next, label %b2 [
    i32 1, label %done
    i32 2, label %b2
  ]

b2:                                               ; preds = %b1, %b1
  %va = va_arg ptr %ap, i32
  %cmp = icmp eq i32 %va, 0
  br i1 %cmp, label %b1, label %done

done:                                             ; preds = %b2, %b1
  indirectbr ptr %ap, [label %b1, label %b2]
}

define void @calls(ptr %f) personality ptr @pers {
  call void %f(i32 1) [ "deopt"(i32 10), "unknown"(ptr null) ]
  %r = tail call fastcc nonnull ptr @callee(ptr noalias sret(%pair) align 4 %f, metadata !"m") #0
  %v = call i32 (ptr, ...) @varargs(ptr %f, i32 1, double 2.000000e+00)
  %i = invoke i32 @plain()
          to label %ok unwind label %lp

ok:                                               ; preds = %0
  call void asm sideeffect inteldialect "nop", "~{memory}"()
  ret void

lp:                                               ; preds = %0
  %e = landingpad { ptr, i32 }
          cleanup
          catch ptr @g
          filter [1 x ptr] [ptr @g]
  resume { ptr, i32 } %e
}

define void @funclets() personality ptr @pers {
  invoke void @plain2()
          to label %done unwind label %dispatch

dispatch:                                         ; preds = %0
  %cs = catchswitch within none [label %handler] unwind to caller

handler:                                          ; preds = %dispatch
  %cp = catchpad within %cs [ptr null, i32 64, ptr null]
  catchret from %cp to label %done

done:                                             ; preds = %handler, %0
  %cl = cleanuppad within none []
  cleanupret from %cl unwind to caller
}

declare ptr @callee(ptr, metadata)

declare i32 @varargs(ptr, ...)

declare i32 @plain()

declare void @plain2()

declare i32 @pers(...)

declare void @resolver()

define internal fastcc void @attrs(ptr noundef nonnull align 8 dereferenceable(16) captures(none) %p, i32 range(i32 0, 10) %r) unnamed_addr #1 section ".text.attrs" align 16 gc "statepoint-example" !dbg !4 {
  ret void, !dbg !5
}

attributes #0 = { nounwind }
attributes #1 = { noinline nounwind memory(argmem: read, inaccessiblemem: write) uwtable(sync) alignstack=16 "frame-pointer"="all" "no-sse" }

!named = !{!0, !1}
!llvm.module.flags = !{!3}

!0 = !{i32 42, null, !"string", ptr @g}
!1 = distinct !{!1, !2}
!2 = !{!"llvm.loop.mustprogress"}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = distinct !DISubprogram(name: "attrs", flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition, line: -1)
!5 = !DILocation(line: 3, column: 5, scope: !4)
