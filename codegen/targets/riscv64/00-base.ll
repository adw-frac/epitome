; The RISC-V RV64 description: the files, and the machine as a whole. Written by gen_riscv64.py; the
; conventions are those of codegen/targets/aarch64/00-base.ll.

; The description is these files, read in name order as one module:
;
;   00-base.ll      registers, parameters, CPUs, relocations
;   10-integer.ll   RV64I: arithmetic, logic, shifts, comparisons, moves,
;                   constants, loads and stores, branches, calls
;   20-m.ll         the M extension: multiplication and division
;   30-zbb.ll       Zbb (basic bit manipulation), used when it is on
;   40-float.ll     the F and D extensions
;   60-recipes.ll   recipes: IR with no single instruction
;   70-abi.ll       the LP64D calling convention
;
; Not yet: compressed instructions (C), atomics (A), vectors (V), PIC.

; ===========================================================================
; Registers, by their ABI names, in two files: the integer registers
; x0-x31 (x0 reads as zero) and the floating-point ones f0-f31. The w
; classes are the integer registers holding 32-bit values, which are kept
; sign-extended to 64 bits ("narrow-results"="sign"); s and d are the
; floating-point registers holding floats and doubles.

!target.registers = !{!1000, !1001, !1002, !1003, !1004, !1005}
!1000 = !{!"x", !"zero", !"ra", !"sp", !"gp", !"tp", !"t{0-2}", !"s{0-1}", !"a{0-7}", !"s{2-11}", !"t{3-6}"}
!1001 = !{!"w", !"zero", !"ra", !"sp", !"gp", !"tp", !"t{0-2}", !"s{0-1}", !"a{0-7}", !"s{2-11}", !"t{3-6}"}
!1002 = !{!"xsp", !"zero", !"ra", !"sp", !"gp", !"tp", !"t{0-2}", !"s{0-1}", !"a{0-7}", !"s{2-11}", !"t{3-6}"}
!1003 = !{!"wsp", !"zero", !"ra", !"sp", !"gp", !"tp", !"t{0-2}", !"s{0-1}", !"a{0-7}", !"s{2-11}", !"t{3-6}"}
!1004 = !{!"d", !"ft{0-7}", !"fs{0-1}", !"fa{0-7}", !"fs{2-11}", !"ft{8-11}"}
!1005 = !{!"s", !"ft{0-7}", !"fs{0-1}", !"fa{0-7}", !"fs{2-11}", !"ft{8-11}"}

!target.classes = !{!1010, !1011, !1012, !1013, !1014, !1015}
!1010 = !{!"x", !"file", !"x", !"bits", !"64", !"holds", !"int"}
!1011 = !{!"w", !"file", !"x", !"bits", !"32", !"holds", !"int"}
!1012 = !{!"xsp", !"file", !"x", !"bits", !"64", !"holds", !"int", !"sp", !"yes"}
!1013 = !{!"wsp", !"file", !"x", !"bits", !"32", !"holds", !"int", !"sp", !"yes"}
!1014 = !{!"d", !"file", !"f", !"bits", !"64", !"holds", !"float"}
!1015 = !{!"s", !"file", !"f", !"bits", !"32", !"holds", !"float"}

; ===========================================================================
; Parameters. No vector registers (V is not described): vectors are done
; lane by lane. Globals are reached by their absolute addresses (the medlow
; code model), not through a GOT. Branches compare whole registers.

!target.params = !{!1100, !1101, !1102, !1103, !1104, !1105, !1106, !1107, !1108, !1109}
!1100 = !{!"sp", !"sp"}
!1101 = !{!"zero", !"zero"}
!1102 = !{!"vector-bits", !"0"}
!1103 = !{!"narrow-results", !"sign"}
!1104 = !{!"external-via-got", !"no"}
!1105 = !{!"elf-machine", !"243"}
; EF_RISCV_FLOAT_ABI_DOUBLE: the LP64D convention.
!1106 = !{!"elf-flags", !"4"}
!1107 = !{!"cpu", !"generic-rv64"}
!1108 = !{!"boolean-branches", !"compare"}
!1109 = !{!"elf-format", !"elf64-littleriscv"}

; ===========================================================================
; CPUs, by LLVM's names for them and their features.

!target.cpus = !{!1150}
!1150 = !{!"generic-rv64", !"m", !"f", !"d"}

; ===========================================================================
; Relocations, from the RISC-V ELF psABI.

!target.relocs = !{!1200, !1201, !1202, !1203, !1210, !1211, !1212, !1213, !1214, !1215, !1216, !1217, !1218}
!1200 = !{!"name", !"jal", !"elf", !"17", !"elf-name", !"R_RISCV_JAL", !"use", !"call", !"target", !"pc + v"}
!1201 = !{!"name", !"hi20", !"elf", !"26", !"elf-name", !"R_RISCV_HI20", !"elf-syntax", !"%hi({s})", !"target", !"v << 12"}
!1202 = !{!"name", !"lo12_i", !"elf", !"27", !"elf-name", !"R_RISCV_LO12_I", !"elf-syntax", !"%lo({s})"}
!1203 = !{!"name", !"abs64", !"elf", !"2", !"elf-name", !"R_RISCV_64", !"use", !"data8"}
!1210 = !{!"name", !"none", !"elf", !"0", !"elf-name", !"R_RISCV_NONE"}
!1211 = !{!"name", !"abs32", !"elf", !"1", !"elf-name", !"R_RISCV_32"}
!1212 = !{!"name", !"branch", !"elf", !"16", !"elf-name", !"R_RISCV_BRANCH"}
!1213 = !{!"name", !"call", !"elf", !"18", !"elf-name", !"R_RISCV_CALL"}
!1214 = !{!"name", !"call_plt", !"elf", !"19", !"elf-name", !"R_RISCV_CALL_PLT"}
!1215 = !{!"name", !"got_hi20", !"elf", !"20", !"elf-name", !"R_RISCV_GOT_HI20"}
!1216 = !{!"name", !"pcrel_hi20", !"elf", !"23", !"elf-name", !"R_RISCV_PCREL_HI20"}
!1217 = !{!"name", !"pcrel_lo12_i", !"elf", !"24", !"elf-name", !"R_RISCV_PCREL_LO12_I"}
!1218 = !{!"name", !"lo12_s", !"elf", !"28", !"elf-name", !"R_RISCV_LO12_S"}
