; @main: inlined @tiny: cost 1, bonus 6, threshold 100
; @main: inlined @tiny: cost 1, bonus 6, threshold 100
; @main: inlined @mode_op: cost 5, bonus 18, threshold 100
; @main: inlined @mode_op: cost 5, bonus 8, threshold 100
; @main: not inlined @big: cost 110 - bonus 6 > threshold 100
; @main: not inlined @big: cost 110 - bonus 6 > threshold 100
; @main: inlined @big_once: cost 110, bonus 121, threshold 100
; @main: not inlined @never: noinline
; @main: not inlined @big: cost 110 - bonus 6 > threshold 0
; @tiny: deleted, no longer used
; @mode_op: deleted, no longer used
; @big_once: deleted, no longer used


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

define internal i32 @never(i32 %x) noinline {
entry:
  %y = mul i32 %x, %x
  ret i32 %y
}

declare void @abort()

define i32 @main(i32 %argc) {
entry:
  %y.i = add i32 %argc, 1
  %y.i1 = add i32 %y.i, 1
  switch i32 0, label %other.i [
    i32 0, label %add.i
    i32 1, label %sub.i
  ]

add.i:                                            ; preds = %entry
  %s.i = add i32 %y.i, %y.i1
  br label %mode_op.exit

sub.i:                                            ; preds = %entry
  %d.i = sub i32 %y.i, %y.i1
  br label %mode_op.exit

other.i:                                          ; preds = %entry
  %m.i = mul i32 %y.i, %y.i1
  br label %mode_op.exit

mode_op.exit:                                     ; preds = %other.i, %sub.i, %add.i
  %c1 = phi i32 [ %s.i, %add.i ], [ %d.i, %sub.i ], [ %m.i, %other.i ]
  switch i32 %argc, label %other.i1 [
    i32 0, label %add.i1
    i32 1, label %sub.i1
  ]

add.i1:                                           ; preds = %mode_op.exit
  %s.i1 = add i32 %y.i, %y.i1
  br label %mode_op.exit1

sub.i1:                                           ; preds = %mode_op.exit
  %d.i1 = sub i32 %y.i, %y.i1
  br label %mode_op.exit1

other.i1:                                         ; preds = %mode_op.exit
  %m.i1 = mul i32 %y.i, %y.i1
  br label %mode_op.exit1

mode_op.exit1:                                    ; preds = %other.i1, %sub.i1, %add.i1
  %d1 = phi i32 [ %s.i1, %add.i1 ], [ %d.i1, %sub.i1 ], [ %m.i1, %other.i1 ]
  %e = call i32 @big(i32 %c1)
  %f = call i32 @big(i32 %d1)
  %t0.i = add i32 %e, 3
  %t1.i = mul i32 %t0.i, 10
  %t2.i = xor i32 %t1.i, 17
  %t3.i = sub i32 %t2.i, 24
  %t4.i = add i32 %t3.i, 31
  %t5.i = mul i32 %t4.i, 38
  %t6.i = xor i32 %t5.i, 45
  %t7.i = sub i32 %t6.i, 52
  %t8.i = add i32 %t7.i, 59
  %t9.i = mul i32 %t8.i, 66
  %t10.i = xor i32 %t9.i, 73
  %t11.i = sub i32 %t10.i, 80
  %t12.i = add i32 %t11.i, 87
  %t13.i = mul i32 %t12.i, 94
  %t14.i = xor i32 %t13.i, 101
  %t15.i = sub i32 %t14.i, 108
  %t16.i = add i32 %t15.i, 115
  %t17.i = mul i32 %t16.i, 122
  %t18.i = xor i32 %t17.i, 129
  %t19.i = sub i32 %t18.i, 136
  %t20.i = add i32 %t19.i, 143
  %t21.i = mul i32 %t20.i, 150
  %t22.i = xor i32 %t21.i, 157
  %t23.i = sub i32 %t22.i, 164
  %t24.i = add i32 %t23.i, 171
  %t25.i = mul i32 %t24.i, 178
  %t26.i = xor i32 %t25.i, 185
  %t27.i = sub i32 %t26.i, 192
  %t28.i = add i32 %t27.i, 199
  %t29.i = mul i32 %t28.i, 206
  %t30.i = xor i32 %t29.i, 213
  %t31.i = sub i32 %t30.i, 220
  %t32.i = add i32 %t31.i, 227
  %t33.i = mul i32 %t32.i, 234
  %t34.i = xor i32 %t33.i, 241
  %t35.i = sub i32 %t34.i, 248
  %t36.i = add i32 %t35.i, 255
  %t37.i = mul i32 %t36.i, 262
  %t38.i = xor i32 %t37.i, 269
  %t39.i = sub i32 %t38.i, 276
  %t40.i = add i32 %t39.i, 283
  %t41.i = mul i32 %t40.i, 290
  %t42.i = xor i32 %t41.i, 297
  %t43.i = sub i32 %t42.i, 304
  %t44.i = add i32 %t43.i, 311
  %t45.i = mul i32 %t44.i, 318
  %t46.i = xor i32 %t45.i, 325
  %t47.i = sub i32 %t46.i, 332
  %t48.i = add i32 %t47.i, 339
  %t49.i = mul i32 %t48.i, 346
  %t50.i = xor i32 %t49.i, 353
  %t51.i = sub i32 %t50.i, 360
  %t52.i = add i32 %t51.i, 367
  %t53.i = mul i32 %t52.i, 374
  %t54.i = xor i32 %t53.i, 381
  %t55.i = sub i32 %t54.i, 388
  %t56.i = add i32 %t55.i, 395
  %t57.i = mul i32 %t56.i, 402
  %t58.i = xor i32 %t57.i, 409
  %t59.i = sub i32 %t58.i, 416
  %t60.i = add i32 %t59.i, 423
  %t61.i = mul i32 %t60.i, 430
  %t62.i = xor i32 %t61.i, 437
  %t63.i = sub i32 %t62.i, 444
  %t64.i = add i32 %t63.i, 451
  %t65.i = mul i32 %t64.i, 458
  %t66.i = xor i32 %t65.i, 465
  %t67.i = sub i32 %t66.i, 472
  %t68.i = add i32 %t67.i, 479
  %t69.i = mul i32 %t68.i, 486
  %t70.i = xor i32 %t69.i, 493
  %t71.i = sub i32 %t70.i, 500
  %t72.i = add i32 %t71.i, 507
  %t73.i = mul i32 %t72.i, 514
  %t74.i = xor i32 %t73.i, 521
  %t75.i = sub i32 %t74.i, 528
  %t76.i = add i32 %t75.i, 535
  %t77.i = mul i32 %t76.i, 542
  %t78.i = xor i32 %t77.i, 549
  %t79.i = sub i32 %t78.i, 556
  %t80.i = add i32 %t79.i, 563
  %t81.i = mul i32 %t80.i, 570
  %t82.i = xor i32 %t81.i, 577
  %t83.i = sub i32 %t82.i, 584
  %t84.i = add i32 %t83.i, 591
  %t85.i = mul i32 %t84.i, 598
  %t86.i = xor i32 %t85.i, 605
  %t87.i = sub i32 %t86.i, 612
  %t88.i = add i32 %t87.i, 619
  %t89.i = mul i32 %t88.i, 626
  %t90.i = xor i32 %t89.i, 633
  %t91.i = sub i32 %t90.i, 640
  %t92.i = add i32 %t91.i, 647
  %t93.i = mul i32 %t92.i, 654
  %t94.i = xor i32 %t93.i, 661
  %t95.i = sub i32 %t94.i, 668
  %t96.i = add i32 %t95.i, 675
  %t97.i = mul i32 %t96.i, 682
  %t98.i = xor i32 %t97.i, 689
  %t99.i = sub i32 %t98.i, 696
  %t100.i = add i32 %t99.i, 703
  %t101.i = mul i32 %t100.i, 710
  %t102.i = xor i32 %t101.i, 717
  %t103.i = sub i32 %t102.i, 724
  %t104.i = add i32 %t103.i, 731
  %t105.i = mul i32 %t104.i, 738
  %t106.i = xor i32 %t105.i, 745
  %t107.i = sub i32 %t106.i, 752
  %t108.i = add i32 %t107.i, 759
  %t109.i = mul i32 %t108.i, 766
  %h = call i32 @never(i32 %f)
  %sum1 = add i32 %e, %f
  %sum2 = add i32 %t109.i, %h
  %sum = add i32 %sum1, %sum2
  %bad = icmp eq i32 %sum, 12345
  br i1 %bad, label %fail, label %ok

fail:                                             ; preds = %mode_op.exit1
  %z = call i32 @big(i32 %sum)
  call void @abort()
  unreachable

ok:                                               ; preds = %mode_op.exit1
  ret i32 %sum
}
