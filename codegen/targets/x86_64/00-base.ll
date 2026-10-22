; The x86-64 description: the files, and the machine as a whole. The
; conventions are those of codegen/targets/aarch64/00-base.ll; the plan is
; docs/design/x86.md.
;
; The description is these files, read in name order as one module:
;
;   00-base.ll      registers, parameters, relocations, and the encoding
;                   fragments (REX, ModRM, SIB, displacements)
;   80-asm.ll       integer instructions for assembly and disassembly
;                   ("asmonly"), written by gen_x86.py
;
; Assembly is AT&T's, as clang, llvm-mc and objdump write it on Linux.
; Encodings are from the Intel SDM and the AMD APM, and every entry is
; checked against llvm-mc. Not yet: selection, the calling convention,
; SSE, AVX.

; ===========================================================================
; Registers. The integer file, r, by hardware number: rax, rcx, rdx, rbx,
; rsp, rbp, rsi, rdi, r8-r15, seen as 64, 32, 16 and 8 bits. The byte
; registers are those REX gives (spl, bpl, sil, dil), never ah-bh.

!target.registers = !{!1000, !1001, !1002, !1003}
!1000 = !{!"r64", !"%rax", !"%rcx", !"%rdx", !"%rbx", !"%rsp", !"%rbp", !"%rsi", !"%rdi", !"%r{8-15}"}
!1001 = !{!"r32", !"%eax", !"%ecx", !"%edx", !"%ebx", !"%esp", !"%ebp", !"%esi", !"%edi", !"%r{8-15}d"}
!1002 = !{!"r16", !"%ax", !"%cx", !"%dx", !"%bx", !"%sp", !"%bp", !"%si", !"%di", !"%r{8-15}w"}
!1003 = !{!"r8", !"%al", !"%cl", !"%dl", !"%bl", !"%spl", !"%bpl", !"%sil", !"%dil", !"%r{8-15}b"}

!target.classes = !{!1010, !1011, !1012, !1013}
!1010 = !{!"r64", !"file", !"r", !"bits", !"64", !"holds", !"int"}
!1011 = !{!"r32", !"file", !"r", !"bits", !"32", !"holds", !"int"}
!1012 = !{!"r16", !"file", !"r", !"bits", !"16", !"holds", !"int"}
!1013 = !{!"r8", !"file", !"r", !"bits", !"8", !"holds", !"int"}

; ===========================================================================
; Parameters.

!target.params = !{!1100, !1101, !1102, !1103, !1104, !1105, !1106, !1107}
!1100 = !{!"sp", !"%rsp"}
!1101 = !{!"vector-bits", !"0"}
!1102 = !{!"elf-machine", !"62"}
!1103 = !{!"elf-format", !"elf64-x86-64"}
!1104 = !{!"asm-comment", !"#"}
!1105 = !{!"cpu", !"x86-64"}
!1106 = !{!"cfi-data-align", !"-8"}
!1107 = !{!"external-via-got", !"no"}

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

; DWARF's numbers for the registers: rax, rdx, rcx, rbx, rsi, rdi, rbp,
; rsp, then r8-r15 (not the hardware order).
!target.dwarf = !{!1400}
!1400 = !{!"r", !"0"}

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
; rm(r, base, index, scale, disp, sym): ModRM, SIB and displacement for a
; memory operand [base + index*scale + disp]: base 0-15, or 16 for RIP
; (then sym + disp, from the instruction's end); index 4 (rsp) for none.
; The shortest form that holds it is the one used:
;   - RIP-relative: mod 00, rm 101, disp32;
;   - no index: mod 00 (not rbp or r13, which mean a displacement; not rsp
;     or r12, which mean a SIB byte), mod 01 with disp8, mod 10 with disp32;
;   - with a SIB byte (an index, or a base of rsp or r12): the same three.

!target.encodings = !{!1500, !1501, !1502, !1503}
!1500 = !{!"rex", !"w r x b", !"{ if(w==0) if(r<8) if(x<8) if(b<8) ; 0100 W:1=w R:1=r>>3 X:1=x>>3 B:1=b>>3 }"}
!1501 = !{!"rexm", !"w r base index", !"{ if(base==16) rex(w, r, 0, 0) ; rex(w, r, index, base) }"}
!1502 = !{!"rr", !"r b", !"11 reg:3=r&7 rm:3=b&7"}
!1503 = !{!"rm", !"r base index scale disp sym", !"{ rip:0=base-16 i:0=index-4 s:0=scale-1 00 reg:3=r&7 101 | disp:s32=sym+disp-end ; if((base&7)!=4) if((base&7)!=5) i:0=index-4 s:0=scale-1 z:0=disp 00 reg:3=r&7 rm:3=base&7 ; if((base&7)!=4) i:0=index-4 s:0=scale-1 01 reg:3=r&7 rm:3=base&7 | disp:s8=disp ; if((base&7)!=4) i:0=index-4 s:0=scale-1 10 reg:3=r&7 rm:3=base&7 | disp:s32=disp ; if((base&7)!=5) z:0=disp 00 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 ; 01 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 | disp:s8=disp ; 10 reg:3=r&7 100 | ss:2=log2(scale) idx:3=index&7 bs:3=base&7 | disp:s32=disp }"}
