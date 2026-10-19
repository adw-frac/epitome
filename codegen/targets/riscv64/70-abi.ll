; The RISC-V RV64 description: the LP64D calling convention. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

; The RISC-V ELF psABI's LP64D: integer arguments in a0-a7, floating-point
; ones in fa0-fa7, stack arguments in 8-byte slots, and variadic arguments
; where named ones would go but in the integer registers, floating-point
; ones too. s0 is the frame pointer; gp and tp are the platform's. t5 and
; t6 (and ft9-ft11) are kept for spill code, and t4 for the addresses of
; stack slots too far for an offset ("far-scratch").

!abi.lp64d = !{!100, !101, !102, !103, !104, !105, !106, !107, !108, !109, !110, !111, !112, !113, !114, !115, !116}
!100 = !{!"args", !"a0-a7"}
!101 = !{!"result", !"a0"}
!102 = !{!"clobbers", !"ra", !"t0-t2", !"a0-a7", !"t3-t6"}
!103 = !{!"saved", !"s1", !"s2-s11"}
!104 = !{!"reserved", !"gp", !"tp"}
!105 = !{!"scratch", !"t5-t6"}
!106 = !{!"frame", !"s0", !"ra"}
!107 = !{!"stack-args", !"slots"}
!108 = !{!"variadic", !"integer"}
!109 = !{!"syntax", !"elf"}
!110 = !{!"triples", !"riscv64", !"linux", !"elf", !"none"}
!111 = !{!"fp-args", !"fa0-fa7"}
!112 = !{!"fp-result", !"fa0"}
!113 = !{!"fp-clobbers", !"ft0-ft7", !"fa0-fa7", !"ft8-ft11"}
!114 = !{!"fp-saved", !"fs0-fs1", !"fs2-fs11"}
!115 = !{!"fp-scratch", !"ft9-ft11"}
!116 = !{!"far-scratch", !"t4"}
