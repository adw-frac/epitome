; x86-64's instructions, for assembly and disassembly ("asmonly").
; Written by gen_x86.py from the opcode tables of the Intel SDM and the AMD
; APM; every entry is checked against llvm-mc. Do not edit: change the
; script.

define void @ADDPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011000 | rr(d, s)" "asm"="addps {s}, {d}" "asmonly" {
  ret void
}

define void @ADDPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="addps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADDPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="addps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADDPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="addps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADDPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011000 | rr(d, s)" "asm"="addpd {s}, {d}" "asmonly" {
  ret void
}

define void @ADDPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="addpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADDPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="addpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADDPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="addpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADDSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011000 | rr(d, s)" "asm"="addss {s}, {d}" "asmonly" {
  ret void
}

define void @ADDSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="addss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADDSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="addss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADDSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="addss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADDSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011000 | rr(d, s)" "asm"="addsd {s}, {d}" "asmonly" {
  ret void
}

define void @ADDSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="addsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADDSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="addsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADDSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="addsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MULPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011001 | rr(d, s)" "asm"="mulps {s}, {d}" "asmonly" {
  ret void
}

define void @mULPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="mulps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xULPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="mulps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pULPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="mulps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MULPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011001 | rr(d, s)" "asm"="mulpd {s}, {d}" "asmonly" {
  ret void
}

define void @mULPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="mulpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xULPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="mulpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pULPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="mulpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MULSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011001 | rr(d, s)" "asm"="mulss {s}, {d}" "asmonly" {
  ret void
}

define void @mULSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="mulss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xULSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="mulss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pULSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="mulss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MULSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011001 | rr(d, s)" "asm"="mulsd {s}, {d}" "asmonly" {
  ret void
}

define void @mULSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="mulsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xULSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="mulsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pULSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="mulsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUBPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011100 | rr(d, s)" "asm"="subps {s}, {d}" "asmonly" {
  ret void
}

define void @SUBPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="subps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUBPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="subps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUBPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="subps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUBPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011100 | rr(d, s)" "asm"="subpd {s}, {d}" "asmonly" {
  ret void
}

define void @SUBPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="subpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUBPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="subpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUBPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="subpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUBSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011100 | rr(d, s)" "asm"="subss {s}, {d}" "asmonly" {
  ret void
}

define void @SUBSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="subss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUBSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="subss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUBSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="subss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUBSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011100 | rr(d, s)" "asm"="subsd {s}, {d}" "asmonly" {
  ret void
}

define void @SUBSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="subsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUBSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="subsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUBSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="subsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MINPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011101 | rr(d, s)" "asm"="minps {s}, {d}" "asmonly" {
  ret void
}

define void @mINPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="minps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xINPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="minps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pINPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="minps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MINPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011101 | rr(d, s)" "asm"="minpd {s}, {d}" "asmonly" {
  ret void
}

define void @mINPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="minpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xINPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="minpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pINPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="minpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MINSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011101 | rr(d, s)" "asm"="minss {s}, {d}" "asmonly" {
  ret void
}

define void @mINSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="minss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xINSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="minss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pINSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="minss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MINSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011101 | rr(d, s)" "asm"="minsd {s}, {d}" "asmonly" {
  ret void
}

define void @mINSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="minsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xINSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="minsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pINSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="minsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIVPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011110 | rr(d, s)" "asm"="divps {s}, {d}" "asmonly" {
  ret void
}

define void @DIVPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="divps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @DIVPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="divps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @DIVPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="divps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIVPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011110 | rr(d, s)" "asm"="divpd {s}, {d}" "asmonly" {
  ret void
}

define void @DIVPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="divpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @DIVPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="divpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @DIVPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="divpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIVSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011110 | rr(d, s)" "asm"="divss {s}, {d}" "asmonly" {
  ret void
}

define void @DIVSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="divss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @DIVSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="divss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @DIVSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="divss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIVSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011110 | rr(d, s)" "asm"="divsd {s}, {d}" "asmonly" {
  ret void
}

define void @DIVSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="divsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @DIVSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="divsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @DIVSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="divsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MAXPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011111 | rr(d, s)" "asm"="maxps {s}, {d}" "asmonly" {
  ret void
}

define void @mAXPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="maxps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xAXPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="maxps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pAXPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="maxps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MAXPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01011111 | rr(d, s)" "asm"="maxpd {s}, {d}" "asmonly" {
  ret void
}

define void @mAXPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="maxpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xAXPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="maxpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pAXPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="maxpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MAXSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011111 | rr(d, s)" "asm"="maxss {s}, {d}" "asmonly" {
  ret void
}

define void @mAXSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="maxss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xAXSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="maxss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pAXSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="maxss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MAXSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011111 | rr(d, s)" "asm"="maxsd {s}, {d}" "asmonly" {
  ret void
}

define void @mAXSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="maxsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xAXSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="maxsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pAXSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="maxsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SQRTPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01010001 | rr(d, s)" "asm"="sqrtps {s}, {d}" "asmonly" {
  ret void
}

define void @SQRTPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="sqrtps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SQRTPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="sqrtps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SQRTPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="sqrtps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SQRTPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01010001 | rr(d, s)" "asm"="sqrtpd {s}, {d}" "asmonly" {
  ret void
}

define void @SQRTPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="sqrtpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SQRTPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="sqrtpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SQRTPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="sqrtpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SQRTSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01010001 | rr(d, s)" "asm"="sqrtss {s}, {d}" "asmonly" {
  ret void
}

define void @SQRTSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="sqrtss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SQRTSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="sqrtss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SQRTSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="sqrtss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SQRTSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01010001 | rr(d, s)" "asm"="sqrtsd {s}, {d}" "asmonly" {
  ret void
}

define void @SQRTSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="sqrtsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SQRTSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="sqrtsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SQRTSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="sqrtsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ANDPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01010100 | rr(d, s)" "asm"="andps {s}, {d}" "asmonly" {
  ret void
}

define void @ANDPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="andps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ANDPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="andps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ANDPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="andps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ANDPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01010100 | rr(d, s)" "asm"="andpd {s}, {d}" "asmonly" {
  ret void
}

define void @ANDPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="andpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ANDPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="andpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ANDPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="andpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ANDNPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01010101 | rr(d, s)" "asm"="andnps {s}, {d}" "asmonly" {
  ret void
}

define void @ANDNPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01010101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="andnps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ANDNPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01010101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="andnps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ANDNPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01010101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="andnps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ANDNPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01010101 | rr(d, s)" "asm"="andnpd {s}, {d}" "asmonly" {
  ret void
}

define void @ANDNPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01010101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="andnpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ANDNPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01010101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="andnpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ANDNPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01010101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="andnpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ORPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01010110 | rr(d, s)" "asm"="orps {s}, {d}" "asmonly" {
  ret void
}

define void @ORPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="orps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ORPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="orps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ORPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="orps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ORPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01010110 | rr(d, s)" "asm"="orpd {s}, {d}" "asmonly" {
  ret void
}

define void @ORPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="orpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ORPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="orpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ORPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="orpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XORPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01010111 | rr(d, s)" "asm"="xorps {s}, {d}" "asmonly" {
  ret void
}

define void @XORPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="xorps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XORPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="xorps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XORPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="xorps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XORPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01010111 | rr(d, s)" "asm"="xorpd {s}, {d}" "asmonly" {
  ret void
}

define void @XORPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="xorpd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XORPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="xorpd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XORPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="xorpd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVAPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00101000 | rr(d, s)" "asm"="movaps {s}, {d}" "asmonly" {
  ret void
}

define void @mOVAPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movaps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVAPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movaps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVAPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movaps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVAPSmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="rex(0, s, 4, m.base) | 00001111 | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movaps {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVAPSxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00001111 | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movaps {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVAPSpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="rex(0, s, 0, 0) | 00001111 | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movaps {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVAPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00101000 | rr(d, s)" "asm"="movapd {s}, {d}" "asmonly" {
  ret void
}

define void @mOVAPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movapd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVAPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movapd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVAPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movapd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVAPDmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00001111 | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movapd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVAPDxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00001111 | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movapd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVAPDpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00001111 | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movapd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVUPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00010000 | rr(d, s)" "asm"="movups {s}, {d}" "asmonly" {
  ret void
}

define void @mOVUPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movups {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVUPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movups {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVUPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movups {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVUPSmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="rex(0, s, 4, m.base) | 00001111 | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movups {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVUPSxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00001111 | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movups {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVUPSpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="rex(0, s, 0, 0) | 00001111 | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movups {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVUPDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00010000 | rr(d, s)" "asm"="movupd {s}, {d}" "asmonly" {
  ret void
}

define void @mOVUPDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movupd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVUPDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movupd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVUPDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movupd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVUPDmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00001111 | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movupd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVUPDxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00001111 | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movupd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVUPDpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00001111 | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movupd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 00010000 | rr(d, s)" "asm"="movss {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVSSmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="11110011 | rex(0, s, 4, m.base) | 00001111 | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movss {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVSSxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 11110011 | rex(0, s, m.index, m.base) | 00001111 | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movss {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVSSpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="11110011 | rex(0, s, 0, 0) | 00001111 | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movss {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 00010000 | rr(d, s)" "asm"="movsd {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movsd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movsd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movsd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVSDmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="11110010 | rex(0, s, 4, m.base) | 00001111 | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movsd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVSDxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 11110010 | rex(0, s, m.index, m.base) | 00001111 | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movsd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVSDpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="11110010 | rex(0, s, 0, 0) | 00001111 | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movsd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVDQArr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01101111 | rr(d, s)" "asm"="movdqa {s}, {d}" "asmonly" {
  ret void
}

define void @mOVDQArm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movdqa {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVDQArx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movdqa {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVDQArp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movdqa {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVDQAmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00001111 | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movdqa {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVDQAxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00001111 | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movdqa {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVDQApr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00001111 | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movdqa {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVDQUrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01101111 | rr(d, s)" "asm"="movdqu {s}, {d}" "asmonly" {
  ret void
}

define void @mOVDQUrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movdqu {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVDQUrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movdqu {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVDQUrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movdqu {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVDQUmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="11110011 | rex(0, s, 4, m.base) | 00001111 | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movdqu {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVDQUxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 11110011 | rex(0, s, m.index, m.base) | 00001111 | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movdqu {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVDQUpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="11110011 | rex(0, s, 0, 0) | 00001111 | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movdqu {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @UCOMISSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00101110 | rr(d, s)" "asm"="ucomiss {s}, {d}" "asmonly" {
  ret void
}

define void @UCOmISSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00101110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="ucomiss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @UCOxISSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00101110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="ucomiss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @UCOpISSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00101110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="ucomiss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @UCOMISDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00101110 | rr(d, s)" "asm"="ucomisd {s}, {d}" "asmonly" {
  ret void
}

define void @UCOmISDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00101110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="ucomisd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @UCOxISDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00101110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="ucomisd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @UCOpISDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00101110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="ucomisd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @COMISSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00101111 | rr(d, s)" "asm"="comiss {s}, {d}" "asmonly" {
  ret void
}

define void @COmISSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00101111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="comiss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @COxISSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="comiss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @COpISSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00101111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="comiss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @COMISDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00101111 | rr(d, s)" "asm"="comisd {s}, {d}" "asmonly" {
  ret void
}

define void @COmISDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00101111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="comisd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @COxISDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="comisd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @COpISDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00101111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="comisd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSS2SDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011010 | rr(d, s)" "asm"="cvtss2sd {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSS2SDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtss2sd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSS2SDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtss2sd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSS2SDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtss2sd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSD2SSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 01011010 | rr(d, s)" "asm"="cvtsd2ss {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSD2SSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 01011010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtsd2ss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSD2SSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 01011010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtsd2ss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSD2SSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 01011010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtsd2ss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTDQ2PSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01011011 | rr(d, s)" "asm"="cvtdq2ps {s}, {d}" "asmonly" {
  ret void
}

define void @CVTDQ2PSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01011011 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtdq2ps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTDQ2PSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtdq2ps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTDQ2PSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01011011 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtdq2ps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTTPS2DQrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 01011011 | rr(d, s)" "asm"="cvttps2dq {s}, {d}" "asmonly" {
  ret void
}

define void @CVTTPS2DQrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01011011 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvttps2dq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTTPS2DQrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvttps2dq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTTPS2DQrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01011011 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvttps2dq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @UNPCKLPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00010100 | rr(d, s)" "asm"="unpcklps {s}, {d}" "asmonly" {
  ret void
}

define void @UNPCKLPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00010100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="unpcklps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @UNPCKLPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="unpcklps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @UNPCKLPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00010100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="unpcklps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @UNPCKHPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="rex(0, d, 0, s) | 00001111 | 00010101 | rr(d, s)" "asm"="unpckhps {s}, {d}" "asmonly" {
  ret void
}

define void @UNPCKHPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 00010101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="unpckhps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @UNPCKHPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 00010101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="unpckhps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @UNPCKHPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 00010101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="unpckhps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PADDBrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11111100 | rr(d, s)" "asm"="paddb {s}, {d}" "asmonly" {
  ret void
}

define void @PADDBrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11111100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="paddb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PADDBrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11111100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="paddb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PADDBrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11111100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="paddb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PADDWrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11111101 | rr(d, s)" "asm"="paddw {s}, {d}" "asmonly" {
  ret void
}

define void @PADDWrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11111101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="paddw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PADDWrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11111101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="paddw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PADDWrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11111101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="paddw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PADDDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11111110 | rr(d, s)" "asm"="paddd {s}, {d}" "asmonly" {
  ret void
}

define void @PADDDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11111110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="paddd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PADDDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="paddd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PADDDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11111110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="paddd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PADDQrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11010100 | rr(d, s)" "asm"="paddq {s}, {d}" "asmonly" {
  ret void
}

define void @PADDQrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11010100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="paddq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PADDQrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="paddq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PADDQrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11010100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="paddq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PSUBDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11111010 | rr(d, s)" "asm"="psubd {s}, {d}" "asmonly" {
  ret void
}

define void @PSUBDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11111010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="psubd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PSUBDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11111010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="psubd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PSUBDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11111010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="psubd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PSUBQrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11111011 | rr(d, s)" "asm"="psubq {s}, {d}" "asmonly" {
  ret void
}

define void @PSUBQrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11111011 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="psubq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PSUBQrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11111011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="psubq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PSUBQrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11111011 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="psubq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PANDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11011011 | rr(d, s)" "asm"="pand {s}, {d}" "asmonly" {
  ret void
}

define void @PANDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11011011 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pand {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PANDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pand {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PANDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11011011 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pand {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PANDNrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11011111 | rr(d, s)" "asm"="pandn {s}, {d}" "asmonly" {
  ret void
}

define void @PANDNrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11011111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pandn {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PANDNrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pandn {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PANDNrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11011111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pandn {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PORrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11101011 | rr(d, s)" "asm"="por {s}, {d}" "asmonly" {
  ret void
}

define void @PORrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11101011 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="por {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PORrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11101011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="por {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PORrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11101011 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="por {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PXORrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11101111 | rr(d, s)" "asm"="pxor {s}, {d}" "asmonly" {
  ret void
}

define void @PXORrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pxor {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PXORrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pxor {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PXORrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pxor {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PCMPEQDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01110110 | rr(d, s)" "asm"="pcmpeqd {s}, {d}" "asmonly" {
  ret void
}

define void @PCmPEQDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01110110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pcmpeqd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PCxPEQDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01110110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pcmpeqd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PCpPEQDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01110110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pcmpeqd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PMULUDQrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11110100 | rr(d, s)" "asm"="pmuludq {s}, {d}" "asmonly" {
  ret void
}

define void @PmULUDQrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11110100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pmuludq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PxULUDQrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11110100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pmuludq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PpULUDQrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11110100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pmuludq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PMADDWDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 11110101 | rr(d, s)" "asm"="pmaddwd {s}, {d}" "asmonly" {
  ret void
}

define void @PmADDWDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 11110101 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pmaddwd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PxADDWDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 11110101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pmaddwd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PpADDWDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 11110101 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pmaddwd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PMULLDrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00111000 | 01000000 | rr(d, s)" "asm"="pmulld {s}, {d}" "asmonly" {
  ret void
}

define void @PmULLDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00111000 | 01000000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pmulld {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PxULLDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00111000 | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pmulld {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PpULLDrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00111000 | 01000000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pmulld {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PSHUFBrr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 00111000 | 00000000 | rr(d, s)" "asm"="pshufb {s}, {d}" "asmonly" {
  ret void
}

define void @PSHUFBrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 00111000 | 00000000 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="pshufb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PSHUFBrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 00111000 | 00000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="pshufb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PSHUFBrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 00111000 | 00000000 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="pshufb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHUFPSrr(i64 "reg"="x" %d, i64 "reg"="x" %s, i64 "imm" %c) "enc"="rex(0, d, 0, s) | 00001111 | 11000110 | rr(d, s) | ib:8=c" "asm"="shufps ${c}, {s}, {d}" "asmonly" {
  ret void
}

define void @SHUFPSrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="rex(0, d, 4, m.base) | 00001111 | 11000110 | rm(d, m.base, 4, 1, m.disp, 0, 1) | ib:8=c" "asm"="shufps ${c}, {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SHUFPSrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 11000110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) | ib:8=c }" "asm"="shufps ${c}, {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SHUFPSrp(i64 "reg"="x" %d, ptr "sym" %m.sym, i64 "imm" %c) "enc"="rex(0, d, 0, 0) | 00001111 | 11000110 | rm(d, 16, 4, 1, 0, m.sym, 1) | ib:8=c" "asm"="shufps ${c}, {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @PSHUFDrr(i64 "reg"="x" %d, i64 "reg"="x" %s, i64 "imm" %c) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01110000 | rr(d, s) | ib:8=c" "asm"="pshufd ${c}, {s}, {d}" "asmonly" {
  ret void
}

define void @PSHUFDrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01110000 | rm(d, m.base, 4, 1, m.disp, 0, 1) | ib:8=c" "asm"="pshufd ${c}, {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @PSHUFDrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01110000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) | ib:8=c }" "asm"="pshufd ${c}, {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @PSHUFDrp(i64 "reg"="x" %d, ptr "sym" %m.sym, i64 "imm" %c) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01110000 | rm(d, 16, 4, 1, 0, m.sym, 1) | ib:8=c" "asm"="pshufd ${c}, {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSI2SD32rr(i64 "reg"="x" %d, i64 "reg"="r32" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 00101010 | rr(d, s)" "asm"="cvtsi2sdl {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD32rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 00101010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtsi2sdl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD32rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 00101010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtsi2sdl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD32rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 00101010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtsi2sdl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSI2SD64rr(i64 "reg"="x" %d, i64 "reg"="r64" %s) "enc"="11110010 | rex(1, d, 0, s) | 00001111 | 00101010 | rr(d, s)" "asm"="cvtsi2sdq {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD64rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(1, d, 4, m.base) | 00001111 | 00101010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtsi2sdq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD64rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(1, d, m.index, m.base) | 00001111 | 00101010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtsi2sdq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SD64rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(1, d, 0, 0) | 00001111 | 00101010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtsi2sdq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSI2SS32rr(i64 "reg"="x" %d, i64 "reg"="r32" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 00101010 | rr(d, s)" "asm"="cvtsi2ssl {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS32rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 00101010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtsi2ssl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS32rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 00101010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtsi2ssl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS32rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 00101010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtsi2ssl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTSI2SS64rr(i64 "reg"="x" %d, i64 "reg"="r64" %s) "enc"="11110011 | rex(1, d, 0, s) | 00001111 | 00101010 | rr(d, s)" "asm"="cvtsi2ssq {s}, {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS64rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(1, d, 4, m.base) | 00001111 | 00101010 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvtsi2ssq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS64rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(1, d, m.index, m.base) | 00001111 | 00101010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvtsi2ssq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTSI2SS64rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(1, d, 0, 0) | 00001111 | 00101010 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvtsi2ssq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTTSD2SI32rr(i64 "reg"="r32" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(0, d, 0, s) | 00001111 | 00101100 | rr(d, s)" "asm"="cvttsd2si {s}, {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(0, d, 4, m.base) | 00001111 | 00101100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvttsd2si {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(0, d, m.index, m.base) | 00001111 | 00101100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvttsd2si {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(0, d, 0, 0) | 00001111 | 00101100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvttsd2si {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTTSD2SI64rr(i64 "reg"="r64" %d, i64 "reg"="x" %s) "enc"="11110010 | rex(1, d, 0, s) | 00001111 | 00101100 | rr(d, s)" "asm"="cvttsd2si {s}, {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110010 | rex(1, d, 4, m.base) | 00001111 | 00101100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvttsd2si {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110010 | rex(1, d, m.index, m.base) | 00001111 | 00101100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvttsd2si {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTTSD2SI64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="11110010 | rex(1, d, 0, 0) | 00001111 | 00101100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvttsd2si {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTTSS2SI32rr(i64 "reg"="r32" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 00101100 | rr(d, s)" "asm"="cvttss2si {s}, {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 00101100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvttss2si {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 00101100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvttss2si {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 00101100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvttss2si {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CVTTSS2SI64rr(i64 "reg"="r64" %d, i64 "reg"="x" %s) "enc"="11110011 | rex(1, d, 0, s) | 00001111 | 00101100 | rr(d, s)" "asm"="cvttss2si {s}, {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(1, d, 4, m.base) | 00001111 | 00101100 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="cvttss2si {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(1, d, m.index, m.base) | 00001111 | 00101100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="cvttss2si {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CVTTSS2SI64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(1, d, 0, 0) | 00001111 | 00101100 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="cvttss2si {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVDxrrr(i64 "reg"="x" %d, i64 "reg"="r32" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01101110 | rr(d, s)" "asm"="movd {s}, {d}" "asmonly" {
  ret void
}

define void @mOVDxrrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01101110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVDxrrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01101110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVDxrrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01101110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVQxrrr(i64 "reg"="x" %d, i64 "reg"="r64" %s) "enc"="01100110 | rex(1, d, 0, s) | 00001111 | 01101110 | rr(d, s)" "asm"="movq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVQxrm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 01111110 | rm(d, m.base, 4, 1, m.disp, 0, 1)" "asm"="movq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVQxrx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 01111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVQxrp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 01111110 | rm(d, 16, 4, 1, 0, m.sym, 1)" "asm"="movq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOVQxmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00001111 | 11010110 | rm(s, m.base, 4, 1, m.disp, 0, 1)" "asm"="movq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOVQxxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00001111 | 11010110 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="movq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOVQxpr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00001111 | 11010110 | rm(s, 16, 4, 1, 0, m.sym, 1)" "asm"="movq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVDrx(i64 "reg"="r32" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(0, s, 0, d) | 00001111 | 01111110 | rr(s, d)" "asm"="movd {s}, {d}" "asmonly" {
  ret void
}

define void @MOVQrx(i64 "reg"="r64" %d, i64 "reg"="x" %s) "enc"="01100110 | rex(1, s, 0, d) | 00001111 | 01111110 | rr(s, d)" "asm"="movq {s}, {d}" "asmonly" {
  ret void
}

define void @VADDPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 0) | 01011000 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 0) | 01011000 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 0) | 01011000 | rr(d, s) }" "asm"="vaddps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 0) | 01011000 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 0) | 01011000 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 0) | 01011000 | rr(d, s) }" "asm"="vaddps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 01011000 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 01011000 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 01011000 | rr(d, s) }" "asm"="vaddpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 01011000 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 01011000 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 01011000 | rr(d, s) }" "asm"="vaddpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011000 | rr(d, s)" "asm"="vaddss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011000 | rr(d, s)" "asm"="vaddsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vaddsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vaddsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vaddsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 0) | 01011001 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 0) | 01011001 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 0) | 01011001 | rr(d, s) }" "asm"="vmulps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 0) | 01011001 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 0) | 01011001 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 0) | 01011001 | rr(d, s) }" "asm"="vmulps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 01011001 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 01011001 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 01011001 | rr(d, s) }" "asm"="vmulpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 01011001 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 01011001 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 01011001 | rr(d, s) }" "asm"="vmulpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011001 | rr(d, s)" "asm"="vmulss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011001 | rr(d, s)" "asm"="vmulsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmulsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmulsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmulsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 0) | 01011100 | rr(d, s)" "asm"="vsubps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 0) | 01011100 | rr(d, s)" "asm"="vsubps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 1) | 01011100 | rr(d, s)" "asm"="vsubpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 1) | 01011100 | rr(d, s)" "asm"="vsubpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011100 | rr(d, s)" "asm"="vsubss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011100 | rr(d, s)" "asm"="vsubsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsubsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsubsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsubsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 0) | 01011101 | rr(d, s)" "asm"="vminps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 0) | 01011101 | rr(d, s)" "asm"="vminps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 1) | 01011101 | rr(d, s)" "asm"="vminpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 1) | 01011101 | rr(d, s)" "asm"="vminpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011101 | rr(d, s)" "asm"="vminss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011101 | rr(d, s)" "asm"="vminsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vminsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vminsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vminsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 0) | 01011110 | rr(d, s)" "asm"="vdivps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 0) | 01011110 | rr(d, s)" "asm"="vdivps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 1) | 01011110 | rr(d, s)" "asm"="vdivpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 1) | 01011110 | rr(d, s)" "asm"="vdivpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011110 | rr(d, s)" "asm"="vdivss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011110 | rr(d, s)" "asm"="vdivsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vdivsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vdivsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vdivsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 0) | 01011111 | rr(d, s)" "asm"="vmaxps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 0) | 01011111 | rr(d, s)" "asm"="vmaxps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 1) | 01011111 | rr(d, s)" "asm"="vmaxpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 1) | 01011111 | rr(d, s)" "asm"="vmaxpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 2) | 01011111 | rr(d, s)" "asm"="vmaxss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 2) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 2) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 2) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXSD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 3) | 01011111 | rr(d, s)" "asm"="vmaxsd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 3) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmaxsd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 3) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmaxsd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXSD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 3) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmaxsd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VANDPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 0) | 01010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 0) | 01010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 0) | 01010100 | rr(d, s) }" "asm"="vandps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vandps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vandps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vandps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VANDPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 0) | 01010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 0) | 01010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 0) | 01010100 | rr(d, s) }" "asm"="vandps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vandps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vandps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vandps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VANDPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 01010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 01010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 01010100 | rr(d, s) }" "asm"="vandpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vandpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vandpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vandpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VANDPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 01010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 01010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 01010100 | rr(d, s) }" "asm"="vandpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vandpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vandpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VANDPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vandpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VORPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 0) | 01010110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 0) | 01010110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 0) | 01010110 | rr(d, s) }" "asm"="vorps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vorps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vorps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vorps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VORPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 0) | 01010110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 0) | 01010110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 0) | 01010110 | rr(d, s) }" "asm"="vorps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vorps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vorps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vorps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VORPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 01010110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 01010110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 01010110 | rr(d, s) }" "asm"="vorpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vorpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vorpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vorpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VORPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 01010110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 01010110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 01010110 | rr(d, s) }" "asm"="vorpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01010110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vorpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01010110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vorpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VORPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01010110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vorpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VXORPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 0) | 01010111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 0) | 01010111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 0) | 01010111 | rr(d, s) }" "asm"="vxorps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 0) | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vxorps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 0) | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vxorps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 0) | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vxorps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VXORPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 0) | 01010111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 0) | 01010111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 0) | 01010111 | rr(d, s) }" "asm"="vxorps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 0) | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vxorps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 0) | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vxorps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 0) | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vxorps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VXORPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 01010111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 01010111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 01010111 | rr(d, s) }" "asm"="vxorpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vxorpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vxorpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vxorpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VXORPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 01010111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 01010111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 01010111 | rr(d, s) }" "asm"="vxorpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 01010111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vxorpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 01010111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vxorpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VXORPD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 01010111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vxorpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11111110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11111110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11111110 | rr(d, s) }" "asm"="vpaddd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11111110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpaddd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpaddd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11111110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpaddd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11111110 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11111110 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11111110 | rr(d, s) }" "asm"="vpaddd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11111110 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpaddd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpaddd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11111110 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpaddd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDQ128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11010100 | rr(d, s) }" "asm"="vpaddq {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpaddq {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpaddq {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpaddq {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDQ256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11010100 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11010100 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11010100 | rr(d, s) }" "asm"="vpaddq {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11010100 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpaddq {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpaddq {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQ256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11010100 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpaddq {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSUBD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, v, 0, 1) | 11111010 | rr(d, s)" "asm"="vpsubd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11111010 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpsubd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11111010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpsubd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11111010 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpsubd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSUBD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, v, 1, 1) | 11111010 | rr(d, s)" "asm"="vpsubd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11111010 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpsubd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11111010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpsubd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11111010 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpsubd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXOR128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11101111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11101111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11101111 | rr(d, s) }" "asm"="vpxor {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpxor {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpxor {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpxor {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXOR256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11101111 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11101111 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11101111 | rr(d, s) }" "asm"="vpxor {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpxor {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpxor {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXOR256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpxor {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPAND128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11011011 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11011011 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11011011 | rr(d, s) }" "asm"="vpand {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11011011 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpand {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpand {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11011011 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpand {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPAND256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11011011 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11011011 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11011011 | rr(d, s) }" "asm"="vpand {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11011011 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpand {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpand {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPAND256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11011011 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpand {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPOR128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11101011 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11101011 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11101011 | rr(d, s) }" "asm"="vpor {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11101011 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpor {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11101011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpor {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11101011 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpor {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPOR256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11101011 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11101011 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11101011 | rr(d, s) }" "asm"="vpor {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11101011 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpor {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11101011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpor {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPOR256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11101011 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpor {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPMADDWD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 0, 1) | 11110101 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 0, 1) | 11110101 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 0, 1) | 11110101 | rr(d, s) }" "asm"="vpmaddwd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 0, 1) | 11110101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpmaddwd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 0, 1) | 11110101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpmaddwd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 0, 1) | 11110101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpmaddwd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPMADDWD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, v, 1, 1) | 11110101 | rr(d, s) ; if(v<8) vex(d, 0, v, 1, 0, s, 1, 1) | 11110101 | rr(d, v) ; vex(d, 0, s, 1, 0, v, 1, 1) | 11110101 | rr(d, s) }" "asm"="vpmaddwd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, v, 1, 1) | 11110101 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpmaddwd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, v, 1, 1) | 11110101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpmaddwd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMADDWD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, v, 1, 1) | 11110101 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpmaddwd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPMULLD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 01000000 | rr(d, s)" "asm"="vpmulld {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 01000000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpmulld {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpmulld {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 01000000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpmulld {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPMULLD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 0, v, 1, 1) | 01000000 | rr(d, s)" "asm"="vpmulld {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 1, 1) | 01000000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpmulld {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 1, 1) | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpmulld {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPMULLD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 1, 1) | 01000000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpmulld {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSHUFB128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 00000000 | rr(d, s)" "asm"="vpshufb {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 00000000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpshufb {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 00000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpshufb {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 00000000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpshufb {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSHUFB256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 0, v, 1, 1) | 00000000 | rr(d, s)" "asm"="vpshufb {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 1, 1) | 00000000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpshufb {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 1, 1) | 00000000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpshufb {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSHUFB256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 1, 1) | 00000000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpshufb {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10011000 | rr(d, s)" "asm"="vfmadd132ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 0, v, 1, 1) | 10011000 | rr(d, s)" "asm"="vfmadd132ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 1, 1) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 1, 1) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 1, 1) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10011000 | rr(d, s)" "asm"="vfmadd132pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 1, v, 1, 1) | 10011000 | rr(d, s)" "asm"="vfmadd132pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 1, 1) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 1, 1) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 1, 1) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132SSrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10011001 | rr(d, s)" "asm"="vfmadd132ss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SSrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132ss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SSrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132ss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SSrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132ss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132SDrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10011001 | rr(d, s)" "asm"="vfmadd132sd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SDrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10011001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd132sd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SDrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd132sd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132SDrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10011001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd132sd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10101000 | rr(d, s)" "asm"="vfmadd213ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 0, v, 1, 1) | 10101000 | rr(d, s)" "asm"="vfmadd213ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 1, 1) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 1, 1) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 1, 1) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10101000 | rr(d, s)" "asm"="vfmadd213pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 1, v, 1, 1) | 10101000 | rr(d, s)" "asm"="vfmadd213pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 1, 1) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 1, 1) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 1, 1) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213SSrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10101001 | rr(d, s)" "asm"="vfmadd213ss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SSrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10101001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213ss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SSrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10101001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213ss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SSrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10101001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213ss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213SDrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10101001 | rr(d, s)" "asm"="vfmadd213sd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SDrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10101001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd213sd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SDrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10101001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd213sd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213SDrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10101001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd213sd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PS128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10111000 | rr(d, s)" "asm"="vfmadd231ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PS256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 0, v, 1, 1) | 10111000 | rr(d, s)" "asm"="vfmadd231ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 1, 1) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 1, 1) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PS256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 1, 1) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PD128rr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10111000 | rr(d, s)" "asm"="vfmadd231pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD128rm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD128rx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD128rp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PD256rr(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 2, 1, v, 1, 1) | 10111000 | rr(d, s)" "asm"="vfmadd231pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD256rm(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 1, 1) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD256rx(i64 "reg"="y" %d, i64 "reg"="y" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 1, 1) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PD256rp(i64 "reg"="y" %d, i64 "reg"="y" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 1, 1) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231SSrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, v, 0, 1) | 10111001 | rr(d, s)" "asm"="vfmadd231ss {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SSrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, v, 0, 1) | 10111001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231ss {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SSrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, v, 0, 1) | 10111001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231ss {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SSrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, v, 0, 1) | 10111001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231ss {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231SDrr(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 1, v, 0, 1) | 10111001 | rr(d, s)" "asm"="vfmadd231sd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SDrm(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 1, v, 0, 1) | 10111001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vfmadd231sd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SDrx(i64 "reg"="x" %d, i64 "reg"="x" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 1, v, 0, 1) | 10111001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vfmadd231sd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231SDrp(i64 "reg"="x" %d, i64 "reg"="x" %v, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 1, v, 0, 1) | 10111001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vfmadd231sd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 0) | 00101000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 0) | 00101001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 0) | 00101000 | rr(d, s) }" "asm"="vmovaps {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPS128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 0) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovaps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPS128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 0) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovaps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPS128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 0) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovaps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPS128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 0) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovaps {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPS128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 0) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovaps {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPS128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovaps {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 0) | 00101000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 0) | 00101001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 0) | 00101000 | rr(d, s) }" "asm"="vmovaps {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPS256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 0) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovaps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPS256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 0) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovaps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPS256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 0) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovaps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPS256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 0) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovaps {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPS256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 0) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovaps {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPS256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovaps {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 0) | 00010000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 0) | 00010001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 0) | 00010000 | rr(d, s) }" "asm"="vmovups {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPS128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 0) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovups {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPS128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 0) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovups {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPS128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 0) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovups {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPS128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 0) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovups {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPS128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 0) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovups {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPS128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovups {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 0) | 00010000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 0) | 00010001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 0) | 00010000 | rr(d, s) }" "asm"="vmovups {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPS256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 0) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovups {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPS256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 0) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovups {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPS256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 0) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovups {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPS256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 0) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovups {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPS256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 0) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovups {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPS256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovups {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 1) | 00101000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 1) | 00101001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 1) | 00101000 | rr(d, s) }" "asm"="vmovapd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPD128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 1) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovapd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPD128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 1) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovapd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPD128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 1) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovapd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPD128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 1) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovapd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPD128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 1) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovapd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPD128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 1) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovapd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 1) | 00101000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 1) | 00101001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 1) | 00101000 | rr(d, s) }" "asm"="vmovapd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPD256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 1) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovapd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPD256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 1) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovapd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPD256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 1) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovapd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPD256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 1) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovapd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPD256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 1) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovapd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPD256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 1) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovapd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPD128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 1) | 00010000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 1) | 00010001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 1) | 00010000 | rr(d, s) }" "asm"="vmovupd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPD128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 1) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovupd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPD128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 1) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovupd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPD128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 1) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovupd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPD128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 1) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovupd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPD128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 1) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovupd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPD128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 1) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovupd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPD256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 1) | 00010000 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 1) | 00010001 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 1) | 00010000 | rr(d, s) }" "asm"="vmovupd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPD256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 1) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovupd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPD256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 1) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovupd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPD256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 1) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovupd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPD256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 1) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovupd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPD256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 1) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovupd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPD256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 1) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovupd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQA128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 1) | 01101111 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 1) | 01111111 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 1) | 01101111 | rr(d, s) }" "asm"="vmovdqa {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQA128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 1) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqa {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQA128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 1) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqa {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQA128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 1) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqa {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQA128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 1) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqa {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQA128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 1) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqa {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQA128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 1) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqa {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQA256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 1) | 01101111 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 1) | 01111111 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 1) | 01101111 | rr(d, s) }" "asm"="vmovdqa {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQA256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 1) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqa {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQA256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 1) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqa {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQA256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 1) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqa {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQA256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 1) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqa {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQA256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 1) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqa {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQA256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 1) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqa {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 0, 2) | 01101111 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 0, 2) | 01111111 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 0, 2) | 01101111 | rr(d, s) }" "asm"="vmovdqu {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQU128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 2) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqu {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 2) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqu {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 2) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqu {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU128mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 0, 2) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqu {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQU128xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="x" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 0, 2) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqu {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQU128pr(ptr "sym" %m.sym, i64 "reg"="x" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 0, 2) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqu {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="{ if(s<8) vex(d, 0, s, 1, 0, 0, 1, 2) | 01101111 | rr(d, s) ; if(d<8) vex(s, 0, d, 1, 0, 0, 1, 2) | 01111111 | rr(s, d) ; vex(d, 0, s, 1, 0, 0, 1, 2) | 01101111 | rr(d, s) }" "asm"="vmovdqu {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQU256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 2) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqu {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 2) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqu {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 2) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqu {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU256mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ vexm(s, m.base, 4, 1, 0, 0, 1, 2) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vmovdqu {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQU256xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="y" %s) "enc"="{ if(m.index!=4) vexm(s, m.base, m.index, 1, 0, 0, 1, 2) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vmovdqu {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQU256pr(ptr "sym" %m.sym, i64 "reg"="y" %s) "enc"="{ vexm(s, 16, 4, 1, 0, 0, 1, 2) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 1) }" "asm"="vmovdqu {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VBROADCASTSS128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, 0, 0, 1) | 00011000 | rr(d, s)" "asm"="vbroadcastss {s}, {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, 0, 0, 1) | 00011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vbroadcastss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, 0, 0, 1) | 00011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vbroadcastss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, 0, 0, 1) | 00011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vbroadcastss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VBROADCASTSS256rr(i64 "reg"="y" %d, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, 0, 1, 1) | 00011000 | rr(d, s)" "asm"="vbroadcastss {s}, {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, 0, 1, 1) | 00011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vbroadcastss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, 0, 1, 1) | 00011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vbroadcastss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSS256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, 0, 1, 1) | 00011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vbroadcastss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPBROADCASTD128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, 0, 0, 1) | 01011000 | rr(d, s)" "asm"="vpbroadcastd {s}, {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, 0, 0, 1) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpbroadcastd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, 0, 0, 1) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpbroadcastd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, 0, 0, 1) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpbroadcastd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPBROADCASTD256rr(i64 "reg"="y" %d, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 2, 0, 0, 1, 1) | 01011000 | rr(d, s)" "asm"="vpbroadcastd {s}, {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 2, 0, 0, 1, 1) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vpbroadcastd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 2, 0, 0, 1, 1) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vpbroadcastd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VPBROADCASTD256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 2, 0, 0, 1, 1) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vpbroadcastd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSQRTPS128rr(i64 "reg"="x" %d, i64 "reg"="x" %s) "enc"="vex(d, 0, s, 1, 0, 0, 0, 0) | 01010001 | rr(d, s)" "asm"="vsqrtps {s}, {d}" "asmonly" {
  ret void
}

define void @VSQRTPS128rm(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 0, 0) | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsqrtps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VSQRTPS128rx(i64 "reg"="x" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 0, 0) | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsqrtps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VSQRTPS128rp(i64 "reg"="x" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 0, 0) | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsqrtps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSQRTPS256rr(i64 "reg"="y" %d, i64 "reg"="y" %s) "enc"="vex(d, 0, s, 1, 0, 0, 1, 0) | 01010001 | rr(d, s)" "asm"="vsqrtps {s}, {d}" "asmonly" {
  ret void
}

define void @VSQRTPS256rm(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ vexm(d, m.base, 4, 1, 0, 0, 1, 0) | 01010001 | rm(d, m.base, 4, 1, m.disp, 0, 1) }" "asm"="vsqrtps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VSQRTPS256rx(i64 "reg"="y" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) vexm(d, m.base, m.index, 1, 0, 0, 1, 0) | 01010001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 1) }" "asm"="vsqrtps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VSQRTPS256rp(i64 "reg"="y" %d, ptr "sym" %m.sym) "enc"="{ vexm(d, 16, 4, 1, 0, 0, 1, 0) | 01010001 | rm(d, 16, 4, 1, 0, m.sym, 1) }" "asm"="vsqrtps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VZEROUPPER() "enc"="11000101 | 11111000 | 01110111" "asm"="vzeroupper" "asmonly" {
  ret void
}

define void @VADDPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011000 | rr(d, s)" "asm"="vaddps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vaddps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vaddps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vaddps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vaddps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vaddps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vaddps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011000 | rr(d, s)" "asm"="vaddpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vaddpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vaddpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vaddpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VADDPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011000 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vaddpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vaddpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VADDPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011000 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vaddpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011001 | rr(d, s)" "asm"="vmulps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmulps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmulps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmulps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vmulps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vmulps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vmulps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011001 | rr(d, s)" "asm"="vmulpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmulpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmulpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmulpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMULPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011001 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vmulpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011001 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vmulpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMULPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011001 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vmulpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011100 | rr(d, s)" "asm"="vsubps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vsubps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vsubps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vsubps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vsubps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vsubps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vsubps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011100 | rr(d, s)" "asm"="vsubpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vsubpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vsubpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vsubpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VSUBPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011100 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vsubpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vsubpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VSUBPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011100 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vsubpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011101 | rr(d, s)" "asm"="vminps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vminps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vminps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vminps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vminps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vminps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vminps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011101 | rr(d, s)" "asm"="vminpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vminpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vminpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vminpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMINPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011101 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vminpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011101 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vminpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMINPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011101 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vminpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011110 | rr(d, s)" "asm"="vdivps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vdivps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vdivps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vdivps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vdivps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vdivps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vdivps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011110 | rr(d, s)" "asm"="vdivpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vdivpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vdivpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vdivpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDIVPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011110 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vdivpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vdivpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDIVPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011110 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vdivpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 0, 0, 0) | 01011111 | rr(d, s)" "asm"="vmaxps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmaxps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 0, 0, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmaxps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 0, 0, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmaxps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vmaxps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 0, 1, 0, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vmaxps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 0, 1, 0, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vmaxps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 01011111 | rr(d, s)" "asm"="vmaxpd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmaxpd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmaxpd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmaxpd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMAXPDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011111 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vmaxpd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 01011111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vmaxpd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VMAXPDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 01011111 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vmaxpd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 1, 0, 0) | 10011000 | rr(d, s)" "asm"="vfmadd132ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd132ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd132ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd132ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vfmadd132ps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vfmadd132ps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vfmadd132ps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 1, v, 2, 1, 0, 0) | 10011000 | rr(d, s)" "asm"="vfmadd132pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd132pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd132pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd132pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD132PDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vfmadd132pd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vfmadd132pd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD132PDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10011000 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vfmadd132pd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 1, 0, 0) | 10101000 | rr(d, s)" "asm"="vfmadd213ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd213ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd213ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd213ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vfmadd213ps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vfmadd213ps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vfmadd213ps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 1, v, 2, 1, 0, 0) | 10101000 | rr(d, s)" "asm"="vfmadd213pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd213pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd213pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd213pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD213PDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vfmadd213pd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vfmadd213pd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD213PDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10101000 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vfmadd213pd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 1, 0, 0) | 10111000 | rr(d, s)" "asm"="vfmadd231ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd231ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd231ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd231ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vfmadd231ps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vfmadd231ps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vfmadd231ps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 1, v, 2, 1, 0, 0) | 10111000 | rr(d, s)" "asm"="vfmadd231pd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vfmadd231pd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vfmadd231pd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 0, 0, 0) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vfmadd231pd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VFMADD231PDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vfmadd231pd {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 1, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vfmadd231pd {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VFMADD231PDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 1, v, 2, 1, 1, 0, 0) | 10111000 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vfmadd231pd {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, 0, 2, 0, 0, 0) | 00101000 | rr(d, s)" "asm"="vmovaps {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPSZrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovaps {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPSZrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, 0, 2, 0, 0, 0, 0) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovaps {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPSZrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovaps {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPSZmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovaps {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPSZxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 0, 0, 2, 0, 0, 0, 0) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovaps {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPSZpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovaps {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPSZrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, 0, 2, 0, 0, 0) | 00010000 | rr(d, s)" "asm"="vmovups {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPSZrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovups {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPSZrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, 0, 2, 0, 0, 0, 0) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovups {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPSZrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovups {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPSZmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovups {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPSZxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 0, 0, 2, 0, 0, 0, 0) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovups {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPSZpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 0, 0, 2, 0, 0, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovups {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, 0, 2, 1, 0, 0) | 00101000 | rr(d, s)" "asm"="vmovapd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVAPDZrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00101000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovapd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPDZrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, 0, 2, 1, 0, 0, 0) | 00101000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovapd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVAPDZrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00101000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovapd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVAPDZmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovapd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVAPDZxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 1, 0, 2, 1, 0, 0, 0) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovapd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVAPDZpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovapd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPDZrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, 0, 2, 1, 0, 0) | 00010000 | rr(d, s)" "asm"="vmovupd {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVUPDZrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00010000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovupd {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPDZrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, 0, 2, 1, 0, 0, 0) | 00010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovupd {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVUPDZrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00010000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovupd {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVUPDZmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovupd {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVUPDZxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 1, 0, 2, 1, 0, 0, 0) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovupd {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVUPDZpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 1, 0, 2, 1, 0, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovupd {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU32Zrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, 0, 2, 2, 0, 0) | 01101111 | rr(d, s)" "asm"="vmovdqu32 {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQU32Zrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovdqu32 {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU32Zrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovdqu32 {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU32Zrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovdqu32 {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU32Zmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 0, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovdqu32 {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQU32Zxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 0, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovdqu32 {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQU32Zpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 0, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovdqu32 {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU64Zrr(i64 "reg"="z" %d, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, 0, 2, 2, 0, 0) | 01101111 | rr(d, s)" "asm"="vmovdqu64 {s}, {d}" "asmonly" {
  ret void
}

define void @VMOVDQU64Zrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovdqu64 {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU64Zrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovdqu64 {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VMOVDQU64Zrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, 0, 2, 2, 0, 0, 0) | 01101111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovdqu64 {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VMOVDQU64Zmr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ evexm(s, m.base, 4, 1, 1, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vmovdqu64 {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @VMOVDQU64Zxr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="z" %s) "enc"="{ if(m.index!=4) evexm(s, m.base, m.index, 1, 1, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vmovdqu64 {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @VMOVDQU64Zpr(ptr "sym" %m.sym, i64 "reg"="z" %s) "enc"="{ evexm(s, 16, 4, 1, 1, 0, 2, 2, 0, 0, 0) | 01111111 | rm(s, 16, 4, 1, 0, m.sym, 64) }" "asm"="vmovdqu64 {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 1, 0, 0) | 11111110 | rr(d, s)" "asm"="vpaddd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11111110 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpaddd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 0, 0, 0) | 11111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpaddd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11111110 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpaddd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11111110 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpaddd {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 1, 0, 0) | 11111110 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpaddd {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11111110 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpaddd {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDQZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 11010100 | rr(d, s)" "asm"="vpaddq {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 11010100 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpaddq {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 11010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpaddq {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 11010100 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpaddq {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPADDQZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 11010100 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vpaddq {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 11010100 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vpaddq {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPADDQZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 11010100 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vpaddq {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSUBDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 1, 0, 0) | 11111010 | rr(d, s)" "asm"="vpsubd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11111010 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpsubd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 0, 0, 0) | 11111010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpsubd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11111010 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpsubd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPSUBDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11111010 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpsubd {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 1, 0, 0) | 11111010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpsubd {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPSUBDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11111010 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpsubd {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXORDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 1, 0, 0) | 11101111 | rr(d, s)" "asm"="vpxord {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpxord {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpxord {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpxord {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXORDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpxord {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpxord {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpxord {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXORQZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 1, v, 2, 1, 0, 0) | 11101111 | rr(d, s)" "asm"="vpxorq {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORQZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpxorq {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORQZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpxorq {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORQZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 0, 0, 0) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpxorq {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPXORQZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 1, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, m.base, 4, 1, m.disp, 0, 8) }" "asm"="vpxorq {m.disp}({m.base}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORQZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 1, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, m.base, m.index, m.scale, m.disp, 0, 8) }" "asm"="vpxorq {m.disp}({m.base},{m.index},{m.scale}){lb}1to8{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPXORQZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 1, v, 2, 1, 1, 0, 0) | 11101111 | rm(d, 16, 4, 1, 0, m.sym, 8) }" "asm"="vpxorq {m.sym}(%rip){lb}1to8{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPANDDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 1, 0, 0) | 11011011 | rr(d, s)" "asm"="vpandd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPANDDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11011011 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpandd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPANDDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 0, 0, 0) | 11011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpandd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPANDDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11011011 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpandd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPANDDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11011011 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpandd {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPANDDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 1, 0, 0) | 11011011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpandd {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPANDDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11011011 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpandd {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPORDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 1, 0, v, 2, 1, 0, 0) | 11101011 | rr(d, s)" "asm"="vpord {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPORDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11101011 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpord {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPORDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 0, 0, 0) | 11101011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpord {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPORDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 0, 0, 0) | 11101011 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpord {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPORDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11101011 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpord {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPORDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 1, 0, v, 2, 1, 1, 0, 0) | 11101011 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpord {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPORDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 1, 0, v, 2, 1, 1, 0, 0) | 11101011 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpord {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPDPBUSDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 1, 0, 0) | 01010000 | rr(d, s)" "asm"="vpdpbusd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPBUSDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 0, 0, 0) | 01010000 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpdpbusd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPBUSDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 0, 0, 0) | 01010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpdpbusd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPBUSDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 0, 0, 0) | 01010000 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpdpbusd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPDPBUSDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 1, 0, 0) | 01010000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpdpbusd {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPBUSDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 1, 0, 0) | 01010000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpdpbusd {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPBUSDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 1, 0, 0) | 01010000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpdpbusd {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPDPWSSDZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 1, 0, 0) | 01010010 | rr(d, s)" "asm"="vpdpwssd {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPWSSDZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 0, 0, 0) | 01010010 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vpdpwssd {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPWSSDZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 0, 0, 0) | 01010010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vpdpwssd {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPWSSDZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 0, 0, 0) | 01010010 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vpdpwssd {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VPDPWSSDZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 1, 1, 0, 0) | 01010010 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vpdpwssd {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPWSSDZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 1, 1, 0, 0) | 01010010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vpdpwssd {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VPDPWSSDZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 1, 1, 0, 0) | 01010010 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vpdpwssd {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDPBF16PSZrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 2, 0, 0) | 01010010 | rr(d, s)" "asm"="vdpbf16ps {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDPBF16PSZrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 2, 0, 0, 0) | 01010010 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vdpbf16ps {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDPBF16PSZrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 2, 0, 0, 0) | 01010010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vdpbf16ps {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VDPBF16PSZrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 2, 0, 0, 0) | 01010010 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vdpbf16ps {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VDPBF16PSZrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 2, 1, 0, 0) | 01010010 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vdpbf16ps {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDPBF16PSZrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 2, 1, 0, 0) | 01010010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vdpbf16ps {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VDPBF16PSZrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 2, 1, 0, 0) | 01010010 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vdpbf16ps {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VCVTNE2PS2BF16Zrr(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="z" %s) "enc"="evexr(d, s, 2, 0, v, 2, 3, 0, 0) | 01110010 | rr(d, s)" "asm"="vcvtne2ps2bf16 {s}, {v}, {d}" "asmonly" {
  ret void
}

define void @VCVTNE2PS2BF16Zrm(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 3, 0, 0, 0) | 01110010 | rm(d, m.base, 4, 1, m.disp, 0, 64) }" "asm"="vcvtne2ps2bf16 {m.disp}({m.base}), {v}, {d}" "asmonly" {
  ret void
}

define void @VCVTNE2PS2BF16Zrx(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 3, 0, 0, 0) | 01110010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 64) }" "asm"="vcvtne2ps2bf16 {m.disp}({m.base},{m.index},{m.scale}), {v}, {d}" "asmonly" {
  ret void
}

define void @VCVTNE2PS2BF16Zrp(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 3, 0, 0, 0) | 01110010 | rm(d, 16, 4, 1, 0, m.sym, 64) }" "asm"="vcvtne2ps2bf16 {m.sym}(%rip), {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VCVTNE2PS2BF16Zrmb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, v, 2, 3, 1, 0, 0) | 01110010 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vcvtne2ps2bf16 {m.disp}({m.base}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VCVTNE2PS2BF16Zrxb(i64 "reg"="z" %d, i64 "reg"="z" %v, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, v, 2, 3, 1, 0, 0) | 01110010 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vcvtne2ps2bf16 {m.disp}({m.base},{m.index},{m.scale}){lb}1to16{rb}, {v}, {d}" "asmonly" {
  ret void
}

define void @VCVTNE2PS2BF16Zrpb(i64 "reg"="z" %d, i64 "reg"="z" %v, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, v, 2, 3, 1, 0, 0) | 01110010 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vcvtne2ps2bf16 {m.sym}(%rip){lb}1to16{rb}, {v}, {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @VBROADCASTSSZrr(i64 "reg"="z" %d, i64 "reg"="xe" %s) "enc"="evexr(d, s, 2, 0, 0, 2, 1, 0, 0) | 00011000 | rr(d, s)" "asm"="vbroadcastss {s}, {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSSZrm(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ evexm(d, m.base, 4, 2, 0, 0, 2, 1, 0, 0, 0) | 00011000 | rm(d, m.base, 4, 1, m.disp, 0, 4) }" "asm"="vbroadcastss {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSSZrx(i64 "reg"="z" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) evexm(d, m.base, m.index, 2, 0, 0, 2, 1, 0, 0, 0) | 00011000 | rm(d, m.base, m.index, m.scale, m.disp, 0, 4) }" "asm"="vbroadcastss {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @VBROADCASTSSZrp(i64 "reg"="z" %d, ptr "sym" %m.sym) "enc"="{ evexm(d, 16, 4, 2, 0, 0, 2, 1, 0, 0, 0) | 00011000 | rm(d, 16, 4, 1, 0, m.sym, 4) }" "asm"="vbroadcastss {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}
