; The x86-64 description: the files, and the machine as a whole. The
; conventions are those of codegen/targets/aarch64/00-base.ll; the plan is
; docs/design/x86.md.
;
; The description is these files, read in name order as one module:
;
;   00-base.ll      registers, parameters, relocations, and the encoding
;                   fragments (REX, ModRM, SIB, displacements)
;   02-xed.ll       every instruction llvm-mc 18 assembles, for assembly and
;                   disassembly ("asmonly"): integer, x87, MMX, SSE to 4.2,
;                   AVX, AVX2, FMA, AVX-512 with masks, broadcasts and
;                   rounding, AMX, and the rest; written by gen_xed.py from
;                   Intel XED's tables. First, so that the assembler prefers
;                   its entries, which encode as llvm-mc does
;   05-cond.ll      the flags, and the conditions that read them
;   10-integer.ll   integer instructions for selection, with bodies;
;                   written by gen_sel.py
;   70-abi.ll       the System V calling convention
;
; Assembly is AT&T's, as clang, llvm-mc and objdump write it on Linux.
; The fragments here follow the Intel SDM and the AMD APM; the entries are
; XED's, and every one is checked against llvm-mc (tests/x86.rs). Not yet:
; selection and the calling convention.

; ===========================================================================
; Registers. The integer file, r, by hardware number: rax, rcx, rdx, rbx,
; rsp, rbp, rsi, rdi, r8-r15, seen as 64, 32, 16 and 8 bits. The byte
; registers are those REX gives (spl, bpl, sil, dil), never ah-bh.

!target.registers = !{!1000, !1001, !1002, !1003, !1004, !1005, !1006, !1007, !1008, !1009, !1040, !1041, !1042, !1043, !1044, !1045, !1046, !1047, !1048}
!1000 = !{!"r64", !"%rax", !"%rcx", !"%rdx", !"%rbx", !"%rsp", !"%rbp", !"%rsi", !"%rdi", !"%r{8-15}"}
!1001 = !{!"r32", !"%eax", !"%ecx", !"%edx", !"%ebx", !"%esp", !"%ebp", !"%esi", !"%edi", !"%r{8-15}d"}
!1002 = !{!"r16", !"%ax", !"%cx", !"%dx", !"%bx", !"%sp", !"%bp", !"%si", !"%di", !"%r{8-15}w"}
!1003 = !{!"r8", !"%al", !"%cl", !"%dl", !"%bl", !"%spl", !"%bpl", !"%sil", !"%dil", !"%r{8-15}b"}
; The vector file, v: 16 registers with SSE and VEX (x, y), all 32 with
; EVEX (xe, ye, z). The mask file, k.
!1004 = !{!"x", !"%xmm{0-15}"}
!1005 = !{!"y", !"%ymm{0-15}"}
!1006 = !{!"xe", !"%xmm{0-31}"}
!1007 = !{!"ye", !"%ymm{0-31}"}
!1008 = !{!"z", !"%zmm{0-31}"}
!1009 = !{!"k", !"%k{0-7}"}
; For assembly: MMX, the x87 stack, the segment, control and debug
; registers, and AMX's tiles.
!1040 = !{!"mm", !"%mm{0-7}"}
!1041 = !{!"st", !"%st({0-7})"}
!1042 = !{!"seg", !"%es", !"%cs", !"%ss", !"%ds", !"%fs", !"%gs"}
!1043 = !{!"cr", !"%cr{0-15}"}
!1044 = !{!"dr", !"%dr{0-15}"}
!1045 = !{!"tmm", !"%tmm{0-7}"}
; The registers some instructions take fixed: a division's rax and rdx, a
; shift's count in rcx (cl).
!1046 = !{!"rax", !"%rax", !"%rcx", !"%rdx", !"%rbx", !"%rsp", !"%rbp", !"%rsi", !"%rdi", !"%r{8-15}"}
!1047 = !{!"rdx", !"%rax", !"%rcx", !"%rdx", !"%rbx", !"%rsp", !"%rbp", !"%rsi", !"%rdi", !"%r{8-15}"}
!1048 = !{!"rcx", !"%rax", !"%rcx", !"%rdx", !"%rbx", !"%rsp", !"%rbp", !"%rsi", !"%rdi", !"%r{8-15}"}

!target.classes = !{!1010, !1011, !1012, !1013, !1014, !1015, !1016, !1017, !1018, !1019, !1050, !1051, !1052, !1053, !1054, !1055, !1056, !1057, !1058}
!1010 = !{!"r64", !"file", !"r", !"bits", !"64", !"holds", !"int"}
!1011 = !{!"r32", !"file", !"r", !"bits", !"32", !"holds", !"int"}
!1012 = !{!"r16", !"file", !"r"}
!1013 = !{!"r8", !"file", !"r"}
!1014 = !{!"x", !"file", !"v", !"bits", !"128", !"holds", !"vector"}
!1015 = !{!"y", !"file", !"v", !"bits", !"256", !"holds", !"vector"}
!1016 = !{!"xe", !"file", !"v", !"bits", !"128", !"holds", !"vector"}
!1017 = !{!"ye", !"file", !"v", !"bits", !"256", !"holds", !"vector"}
!1018 = !{!"z", !"file", !"v", !"bits", !"512", !"holds", !"vector"}
!1019 = !{!"k", !"file", !"k", !"bits", !"64", !"holds", !"int"}
!1050 = !{!"mm", !"file", !"mm"}
!1051 = !{!"st", !"file", !"st"}
!1052 = !{!"seg", !"file", !"seg"}
!1053 = !{!"cr", !"file", !"cr"}
!1054 = !{!"dr", !"file", !"dr"}
!1055 = !{!"tmm", !"file", !"tmm"}
!1056 = !{!"rax", !"file", !"r", !"fixed", !"%rax"}
!1057 = !{!"rdx", !"file", !"r", !"fixed", !"%rdx"}
!1058 = !{!"rcx", !"file", !"r", !"fixed", !"%rcx"}

; ===========================================================================
; Parameters.

!target.params = !{!1100, !1101, !1102, !1103, !1104, !1105, !1106, !1107, !1108, !1109, !1110, !1111, !1112, !1113, !1114}
!1100 = !{!"sp", !"%rsp"}
!1101 = !{!"vector-bits", !"0"}
!1102 = !{!"elf-machine", !"62"}
!1103 = !{!"elf-format", !"elf64-x86-64"}
!1104 = !{!"asm-comment", !"#"}
!1105 = !{!"cpu", !"x86-64"}
!1106 = !{!"cfi-data-align", !"-8"}
!1107 = !{!"external-via-got", !"no"}
; Instructions are 1 to 15 bytes; the entries are many, so their encodings
; are read when first used.
!1108 = !{!"instruction-unit", !"1"}
!1109 = !{!"lazy-encodings", !"1"}
; A 32-bit result clears the top half; branches compare whole registers.
!1110 = !{!"narrow-results", !"zero"}
!1111 = !{!"boolean-branches", !"compare"}
!1112 = !{!"flags", !"zcso"}
; Unwind tables: the CFA is rsp + 8 on entry, the return address at CFA - 8,
; in DWARF's column 16 (rip).
!1113 = !{!"cfi-cfa-offset", !"8"}
!1114 = !{!"cfi-return-column", !"16"}

!target.cpus = !{!1150}
!1150 = !{!"x86-64"}

; ===========================================================================
; Relocations, from the System V x86-64 psABI. A field measures a symbol
; from its instruction's start; a PC-relative relocation measures from the
; field, so its addend is what the field's expression adds (the
; instruction's end subtracted) plus the field's place in the instruction.

!target.relocs = !{!1200, !1201, !1202, !1203, !1204, !1205}
!1200 = !{!"name", !"abs64", !"elf", !"1", !"elf-name", !"R_X86_64_64", !"use", !"data8"}
!1201 = !{!"name", !"pc32", !"elf", !"2", !"elf-name", !"R_X86_64_PC32", !"use", !"eh-pcrel", !"target", !"pc + v"}
!1202 = !{!"name", !"plt32", !"elf", !"4", !"elf-name", !"R_X86_64_PLT32", !"use", !"call", !"target", !"pc + v"}
!1203 = !{!"name", !"gotpcrel", !"elf", !"9", !"elf-name", !"R_X86_64_GOTPCREL", !"elf-syntax", !"{s}@GOTPCREL", !"use", !"got", !"target", !"pc + v"}
!1204 = !{!"name", !"abs32s", !"elf", !"11", !"elf-name", !"R_X86_64_32S"}
!1205 = !{!"name", !"pc32x", !"elf", !"2", !"elf-name", !"R_X86_64_PC32", !"target", !"pc + v"}

; DWARF's numbers for the registers, by hardware number: DWARF orders them
; rax, rdx, rcx, rbx, rsi, rdi, rbp, rsp, then r8-r15; xmm0-xmm31 from 17.
!target.dwarf = !{!1400, !1401}
!1400 = !{!"r", !"0", !"2", !"1", !"3", !"7", !"6", !"4", !"5", !"8", !"9", !"10", !"11", !"12", !"13", !"14", !"15"}
!1401 = !{!"v", !"17"}

; ===========================================================================
; Encodings. An instruction is a list of bytes (pieces, written most
; significant bit first); these fragments are the parts most share.
;
; rex(w, r, x, b): the REX prefix, 0100WRXB, where W is a 64-bit operand
; and R, X and B the fourth bits of ModRM.reg, SIB.index and ModRM.rm (or
; SIB.base). Left out when nothing needs it.
;
; rexm(w, r, base, index): REX for a memory operand: a RIP-relative one
; (base 16) has no base or index bits.
;
; rr(r, b): ModRM for two registers, mod 11.
;
; rm(r, base, index, scale, disp, sym, n): ModRM, SIB and displacement for
; a memory operand [base + index*scale + disp]: base 0-15, or 16 for RIP
; (then sym + disp, from the instruction's end); index 4 (rsp) for none. A
; byte displacement counts units of n bytes (EVEX's disp8*N; else 1).
; The shortest form that holds it is the one used:
;   - RIP-relative: mod 00, rm 101, disp32;
;   - no index: mod 00 (not rbp or r13, which mean a displacement; not rsp
;     or r12, which mean a SIB byte), mod 01 with disp8, mod 10 with disp32;
;   - with a SIB byte (an index, or a base of rsp or r12): the same three.

!target.encodings = !{!1500, !1501, !1502, !1503, !1504, !1505, !1506, !1507, !1508}
!1500 = !{!"rex", !"w r x b", !"{ if(w==0) if(r<8) if(x<8) if(b<8) ; 0100 W:1=w R:1=r>>3 X:1=x>>3 B:1=b>>3 }"}
!1501 = !{!"rexm", !"w r base index", !"{ if(base==16) rex(w, r, 0, 0) ; rex(w, r, index, base) }"}
!1502 = !{!"rr", !"r b", !"11 reg:3=r&7 rm:3=b&7"}
!1503 = !{!"rm", !"r base index scale disp sym n", !"{ rip:0=base-16 i:0=index-4 s:0=scale-1 00 reg:3=r&7 101 | disp:s32=sym+disp-end ; if((base&7)!=4) if((base&7)!=5) i:0=index-4 s:0=scale-1 z:0=disp 00 reg:3=r&7 rm:3=base&7 ; if((base&7)!=4) i:0=index-4 s:0=scale-1 01 reg:3=r&7 rm:3=base&7 | disp:s8=disp/n ; if((base&7)!=4) i:0=index-4 s:0=scale-1 10 reg:3=r&7 rm:3=base&7 | disp:s32=disp ; if((base&7)!=5) z:0=disp 00 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 ; 01 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 | disp:s8=disp/n ; 10 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 | disp:s32=disp }"}

; vex(r, x, b, map, w, v, l, pp): the VEX prefix. Two bytes (C5) when it
; can be: map 0F, W 0, no X or B; else three (C4). R, X, B and vvvv are
; stored inverted. map: 1 0F, 2 0F38, 3 0F3A; pp: 0 none, 1 66, 2 F3, 3 F2;
; l: 0 128 bits, 1 256.
;
; vexm(r, base, index, map, w, v, l, pp): VEX for a memory operand.
;
; evex(r, x, b, map, w, v, ll, pp, bc, aaa, z): the EVEX prefix (62), for
; a memory operand's index and base registers, x and b; evexr(r, b, ...)
; for a register b (0-31: its fifth bit is in X). R' and V' are the fifth
; bits of ModRM.reg and vvvv, inverted as the others are; ll: 0 128 bits,
; 1 256, 2 512 (with bc, of registers: the rounding); bc broadcast, or of
; registers, rounding or {sae}; aaa the mask register; z zeroing.
!1504 = !{!"vex", !"r x b map w v l pp", !"{ if(x<8) if(b<8) m1:0=map-1 w0:0=w 11000101 | R:1=(r>>3)^1 vv:4=v^15 L:1=l pp:2=pp ; 11000100 | R:1=(r>>3)^1 X:1=(x>>3)^1 B:1=(b>>3)^1 mm:5=map | W:1=w vv:4=v^15 L:1=l pp:2=pp }"}
!1505 = !{!"vexm", !"r base index map w v l pp", !"{ if(base==16) vex(r, 0, 0, map, w, v, l, pp) ; vex(r, index, base, map, w, v, l, pp) }"}
!1506 = !{!"evex", !"r x b map w v ll pp bc aaa z", !"01100010 | R:1=((r>>3)&1)^1 X:1=((x>>3)&1)^1 B:1=((b>>3)&1)^1 R1:1=(r>>4)^1 0 mm:3=map | W:1=w vv:4=(v&15)^15 1 pp:2=pp | Z:1=z LL:2=ll bc:1=bc V1:1=(v>>4)^1 aaa:3=aaa"}
!1507 = !{!"evexr", !"r b map w v ll pp bc aaa z", !"01100010 | R:1=((r>>3)&1)^1 X:1=(b>>4)^1 B:1=((b>>3)&1)^1 R1:1=(r>>4)^1 0 mm:3=map | W:1=w vv:4=(v&15)^15 1 pp:2=pp | Z:1=z LL:2=ll bc:1=bc V1:1=(v>>4)^1 aaa:3=aaa"}
!1508 = !{!"evexm", !"r base index map w v ll pp bc aaa z", !"{ if(base==16) evex(r, 0, 0, map, w, v, ll, pp, bc, aaa, z) ; evex(r, index, base, map, w, v, ll, pp, bc, aaa, z) }"}
