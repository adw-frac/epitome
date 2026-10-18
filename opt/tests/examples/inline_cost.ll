; smaugian-opt: -O2
; How the cost model weighs calls. See the remarks at the top of the
; expected output.
;
; - @tiny is cheaper than the call itself: inlined everywhere.
; - @mode_op branches on its first argument. Where that is a constant the
;   branch would fold, which earns a bonus.
; - @big costs more than the threshold, and is called from several places:
;   kept as a call. At -O3 it would be inlined.
; - @big_once is just as big, but internal and called once: inlining it
;   lets it be deleted, so code size does not grow.
; - @never is marked noinline.
; - The call to @big in %fail leads only to unreachable, so it is cold:
;   only inlined if it costs nothing.
define internal i32 @tiny(i32 %x) {
entry:
  %y = add i32 %x, 1
  ret i32 %y
}

define internal i32 @mode_op(i32 %mode, i32 %a, i32 %b) {
entry:
  switch i32 %mode, label %other [
    i32 0, label %add
    i32 1, label %sub
  ]
add:
  %s = add i32 %a, %b
  ret i32 %s
sub:
  %d = sub i32 %a, %b
  ret i32 %d
other:
  %m = mul i32 %a, %b
  ret i32 %m
}

define internal i32 @big(i32 %x) {
entry:
  %t0 = add i32 %x, 3
  %t1 = mul i32 %t0, 10
  %t2 = xor i32 %t1, 17
  %t3 = sub i32 %t2, 24
  %t4 = add i32 %t3, 31
  %t5 = mul i32 %t4, 38
  %t6 = xor i32 %t5, 45
  %t7 = sub i32 %t6, 52
  %t8 = add i32 %t7, 59
  %t9 = mul i32 %t8, 66
  %t10 = xor i32 %t9, 73
  %t11 = sub i32 %t10, 80
  %t12 = add i32 %t11, 87
  %t13 = mul i32 %t12, 94
  %t14 = xor i32 %t13, 101
  %t15 = sub i32 %t14, 108
  %t16 = add i32 %t15, 115
  %t17 = mul i32 %t16, 122
  %t18 = xor i32 %t17, 129
  %t19 = sub i32 %t18, 136
  %t20 = add i32 %t19, 143
  %t21 = mul i32 %t20, 150
  %t22 = xor i32 %t21, 157
  %t23 = sub i32 %t22, 164
  %t24 = add i32 %t23, 171
  %t25 = mul i32 %t24, 178
  %t26 = xor i32 %t25, 185
  %t27 = sub i32 %t26, 192
  %t28 = add i32 %t27, 199
  %t29 = mul i32 %t28, 206
  %t30 = xor i32 %t29, 213
  %t31 = sub i32 %t30, 220
  %t32 = add i32 %t31, 227
  %t33 = mul i32 %t32, 234
  %t34 = xor i32 %t33, 241
  %t35 = sub i32 %t34, 248
  %t36 = add i32 %t35, 255
  %t37 = mul i32 %t36, 262
  %t38 = xor i32 %t37, 269
  %t39 = sub i32 %t38, 276
  %t40 = add i32 %t39, 283
  %t41 = mul i32 %t40, 290
  %t42 = xor i32 %t41, 297
  %t43 = sub i32 %t42, 304
  %t44 = add i32 %t43, 311
  %t45 = mul i32 %t44, 318
  %t46 = xor i32 %t45, 325
  %t47 = sub i32 %t46, 332
  %t48 = add i32 %t47, 339
  %t49 = mul i32 %t48, 346
  %t50 = xor i32 %t49, 353
  %t51 = sub i32 %t50, 360
  %t52 = add i32 %t51, 367
  %t53 = mul i32 %t52, 374
  %t54 = xor i32 %t53, 381
  %t55 = sub i32 %t54, 388
  %t56 = add i32 %t55, 395
  %t57 = mul i32 %t56, 402
  %t58 = xor i32 %t57, 409
  %t59 = sub i32 %t58, 416
  %t60 = add i32 %t59, 423
  %t61 = mul i32 %t60, 430
  %t62 = xor i32 %t61, 437
  %t63 = sub i32 %t62, 444
  %t64 = add i32 %t63, 451
  %t65 = mul i32 %t64, 458
  %t66 = xor i32 %t65, 465
  %t67 = sub i32 %t66, 472
  %t68 = add i32 %t67, 479
  %t69 = mul i32 %t68, 486
  %t70 = xor i32 %t69, 493
  %t71 = sub i32 %t70, 500
  %t72 = add i32 %t71, 507
  %t73 = mul i32 %t72, 514
  %t74 = xor i32 %t73, 521
  %t75 = sub i32 %t74, 528
  %t76 = add i32 %t75, 535
  %t77 = mul i32 %t76, 542
  %t78 = xor i32 %t77, 549
  %t79 = sub i32 %t78, 556
  %t80 = add i32 %t79, 563
  %t81 = mul i32 %t80, 570
  %t82 = xor i32 %t81, 577
  %t83 = sub i32 %t82, 584
  %t84 = add i32 %t83, 591
  %t85 = mul i32 %t84, 598
  %t86 = xor i32 %t85, 605
  %t87 = sub i32 %t86, 612
  %t88 = add i32 %t87, 619
  %t89 = mul i32 %t88, 626
  %t90 = xor i32 %t89, 633
  %t91 = sub i32 %t90, 640
  %t92 = add i32 %t91, 647
  %t93 = mul i32 %t92, 654
  %t94 = xor i32 %t93, 661
  %t95 = sub i32 %t94, 668
  %t96 = add i32 %t95, 675
  %t97 = mul i32 %t96, 682
  %t98 = xor i32 %t97, 689
  %t99 = sub i32 %t98, 696
  %t100 = add i32 %t99, 703
  %t101 = mul i32 %t100, 710
  %t102 = xor i32 %t101, 717
  %t103 = sub i32 %t102, 724
  %t104 = add i32 %t103, 731
  %t105 = mul i32 %t104, 738
  %t106 = xor i32 %t105, 745
  %t107 = sub i32 %t106, 752
  %t108 = add i32 %t107, 759
  %t109 = mul i32 %t108, 766
  ret i32 %t109
}

define internal i32 @big_once(i32 %x) {
entry:
  %t0 = add i32 %x, 3
  %t1 = mul i32 %t0, 10
  %t2 = xor i32 %t1, 17
  %t3 = sub i32 %t2, 24
  %t4 = add i32 %t3, 31
  %t5 = mul i32 %t4, 38
  %t6 = xor i32 %t5, 45
  %t7 = sub i32 %t6, 52
  %t8 = add i32 %t7, 59
  %t9 = mul i32 %t8, 66
  %t10 = xor i32 %t9, 73
  %t11 = sub i32 %t10, 80
  %t12 = add i32 %t11, 87
  %t13 = mul i32 %t12, 94
  %t14 = xor i32 %t13, 101
  %t15 = sub i32 %t14, 108
  %t16 = add i32 %t15, 115
  %t17 = mul i32 %t16, 122
  %t18 = xor i32 %t17, 129
  %t19 = sub i32 %t18, 136
  %t20 = add i32 %t19, 143
  %t21 = mul i32 %t20, 150
  %t22 = xor i32 %t21, 157
  %t23 = sub i32 %t22, 164
  %t24 = add i32 %t23, 171
  %t25 = mul i32 %t24, 178
  %t26 = xor i32 %t25, 185
  %t27 = sub i32 %t26, 192
  %t28 = add i32 %t27, 199
  %t29 = mul i32 %t28, 206
  %t30 = xor i32 %t29, 213
  %t31 = sub i32 %t30, 220
  %t32 = add i32 %t31, 227
  %t33 = mul i32 %t32, 234
  %t34 = xor i32 %t33, 241
  %t35 = sub i32 %t34, 248
  %t36 = add i32 %t35, 255
  %t37 = mul i32 %t36, 262
  %t38 = xor i32 %t37, 269
  %t39 = sub i32 %t38, 276
  %t40 = add i32 %t39, 283
  %t41 = mul i32 %t40, 290
  %t42 = xor i32 %t41, 297
  %t43 = sub i32 %t42, 304
  %t44 = add i32 %t43, 311
  %t45 = mul i32 %t44, 318
  %t46 = xor i32 %t45, 325
  %t47 = sub i32 %t46, 332
  %t48 = add i32 %t47, 339
  %t49 = mul i32 %t48, 346
  %t50 = xor i32 %t49, 353
  %t51 = sub i32 %t50, 360
  %t52 = add i32 %t51, 367
  %t53 = mul i32 %t52, 374
  %t54 = xor i32 %t53, 381
  %t55 = sub i32 %t54, 388
  %t56 = add i32 %t55, 395
  %t57 = mul i32 %t56, 402
  %t58 = xor i32 %t57, 409
  %t59 = sub i32 %t58, 416
  %t60 = add i32 %t59, 423
  %t61 = mul i32 %t60, 430
  %t62 = xor i32 %t61, 437
  %t63 = sub i32 %t62, 444
  %t64 = add i32 %t63, 451
  %t65 = mul i32 %t64, 458
  %t66 = xor i32 %t65, 465
  %t67 = sub i32 %t66, 472
  %t68 = add i32 %t67, 479
  %t69 = mul i32 %t68, 486
  %t70 = xor i32 %t69, 493
  %t71 = sub i32 %t70, 500
  %t72 = add i32 %t71, 507
  %t73 = mul i32 %t72, 514
  %t74 = xor i32 %t73, 521
  %t75 = sub i32 %t74, 528
  %t76 = add i32 %t75, 535
  %t77 = mul i32 %t76, 542
  %t78 = xor i32 %t77, 549
  %t79 = sub i32 %t78, 556
  %t80 = add i32 %t79, 563
  %t81 = mul i32 %t80, 570
  %t82 = xor i32 %t81, 577
  %t83 = sub i32 %t82, 584
  %t84 = add i32 %t83, 591
  %t85 = mul i32 %t84, 598
  %t86 = xor i32 %t85, 605
  %t87 = sub i32 %t86, 612
  %t88 = add i32 %t87, 619
  %t89 = mul i32 %t88, 626
  %t90 = xor i32 %t89, 633
  %t91 = sub i32 %t90, 640
  %t92 = add i32 %t91, 647
  %t93 = mul i32 %t92, 654
  %t94 = xor i32 %t93, 661
  %t95 = sub i32 %t94, 668
  %t96 = add i32 %t95, 675
  %t97 = mul i32 %t96, 682
  %t98 = xor i32 %t97, 689
  %t99 = sub i32 %t98, 696
  %t100 = add i32 %t99, 703
  %t101 = mul i32 %t100, 710
  %t102 = xor i32 %t101, 717
  %t103 = sub i32 %t102, 724
  %t104 = add i32 %t103, 731
  %t105 = mul i32 %t104, 738
  %t106 = xor i32 %t105, 745
  %t107 = sub i32 %t106, 752
  %t108 = add i32 %t107, 759
  %t109 = mul i32 %t108, 766
  ret i32 %t109
}

define internal i32 @never(i32 %x) noinline {
entry:
  %y = mul i32 %x, %x
  ret i32 %y
}

declare void @abort()

define i32 @main(i32 %argc) {
entry:
  %a = call i32 @tiny(i32 %argc)
  %b = call i32 @tiny(i32 %a)
  %c = call i32 @mode_op(i32 0, i32 %a, i32 %b)
  %d = call i32 @mode_op(i32 %argc, i32 %a, i32 %b)
  %e = call i32 @big(i32 %c)
  %f = call i32 @big(i32 %d)
  %g = call i32 @big_once(i32 %e)
  %h = call i32 @never(i32 %f)
  %sum1 = add i32 %e, %f
  %sum2 = add i32 %g, %h
  %sum = add i32 %sum1, %sum2
  %bad = icmp eq i32 %sum, 12345
  br i1 %bad, label %fail, label %ok

fail:
  %z = call i32 @big(i32 %sum)
  call void @abort()
  unreachable

ok:
  ret i32 %sum
}
