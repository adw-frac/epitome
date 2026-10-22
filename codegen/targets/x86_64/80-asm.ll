; x86-64's integer instructions, for assembly and disassembly ("asmonly").
; Written by gen_x86.py from the opcode tables of the Intel SDM and the AMD
; APM; every entry is checked against llvm-mc. Do not edit: change the
; script.

define void @ADD64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00000001 | rr(s, d)" "asm"="addq {s}, {d}" "asmonly" {
  ret void
}

define void @ADD64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="addq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADD64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADD64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="addq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00000001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="addq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00000001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00000001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="addq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00000101 | iv:s32=c ; rex(1, 0, 0, d) | 10000001 | rr(0, d) | iv:s32=c }" "asm"="addq ${c}, {d}" "asmonly" {
  ret void
}

define void @ADD64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 0, 4, m.base) | 10000011 | rm(0, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 0, 4, m.base) | 10000001 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="addq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 10000011 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 0, m.index, m.base) | 10000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="addq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 0, 0, 0) | 10000011 | rm(0, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 0, 0, 0) | 10000001 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="addq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00000001 | rr(s, d)" "asm"="addl {s}, {d}" "asmonly" {
  ret void
}

define void @ADD32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="addl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADD32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADD32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="addl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00000001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="addl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00000001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00000001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="addl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00000101 | iv:s32=c ; rex(0, 0, 0, d) | 10000001 | rr(0, d) | iv:s32=c }" "asm"="addl ${c}, {d}" "asmonly" {
  ret void
}

define void @ADD32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 10000011 | rm(0, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 0, 4, m.base) | 10000001 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="addl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 10000011 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 0, m.index, m.base) | 10000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="addl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 10000011 | rm(0, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 0, 0, 0) | 10000001 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="addl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00000001 | rr(s, d)" "asm"="addw {s}, {d}" "asmonly" {
  ret void
}

define void @ADD16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="addw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADD16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADD16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="addw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00000001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="addw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00000001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00000001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="addw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 0, d) | 10000011 | rr(0, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00000101 | iv:s16=c ; 01100110 | rex(0, 0, 0, d) | 10000001 | rr(0, d) | iv:s16=c }" "asm"="addw ${c}, {d}" "asmonly" {
  ret void
}

define void @ADD16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 4, m.base) | 10000011 | rm(0, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 0, 4, m.base) | 10000001 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="addw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 10000011 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 10000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="addw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 0, 0) | 10000011 | rm(0, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 0, 0, 0) | 10000001 | rm(0, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="addw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00000000 | rr(s, d)" "asm"="addb {s}, {d}" "asmonly" {
  ret void
}

define void @ADD8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00000010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="addb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADD8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00000010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADD8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00000010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="addb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00000000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="addb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00000000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="addb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00000000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="addb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADD8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00000100 | iv:s8=c ; { if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(0, d) | iv:s8=c }" "asm"="addb ${c}, {d}" "asmonly" {
  ret void
}

define void @ADD8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 10000000 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="addb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADD8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 10000000 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="addb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADD8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 10000000 | rm(0, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="addb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00001001 | rr(s, d)" "asm"="orq {s}, {d}" "asmonly" {
  ret void
}

define void @OR64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="orq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @OR64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @OR64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="orq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="orq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="orq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 1, 0, d) | 10000011 | rr(1, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00001101 | iv:s32=c ; rex(1, 1, 0, d) | 10000001 | rr(1, d) | iv:s32=c }" "asm"="orq ${c}, {d}" "asmonly" {
  ret void
}

define void @OR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 1, 4, m.base) | 10000011 | rm(1, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 1, 4, m.base) | 10000001 | rm(1, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="orq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 1, m.index, m.base) | 10000011 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 1, m.index, m.base) | 10000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="orq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 1, 0, 0) | 10000011 | rm(1, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 1, 0, 0) | 10000001 | rm(1, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="orq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00001001 | rr(s, d)" "asm"="orl {s}, {d}" "asmonly" {
  ret void
}

define void @OR32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="orl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @OR32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @OR32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="orl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="orl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="orl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 1, 0, d) | 10000011 | rr(1, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00001101 | iv:s32=c ; rex(0, 1, 0, d) | 10000001 | rr(1, d) | iv:s32=c }" "asm"="orl ${c}, {d}" "asmonly" {
  ret void
}

define void @OR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 1, 4, m.base) | 10000011 | rm(1, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 1, 4, m.base) | 10000001 | rm(1, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="orl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 10000011 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 1, m.index, m.base) | 10000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="orl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 1, 0, 0) | 10000011 | rm(1, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 1, 0, 0) | 10000001 | rm(1, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="orl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00001001 | rr(s, d)" "asm"="orw {s}, {d}" "asmonly" {
  ret void
}

define void @OR16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="orw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @OR16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @OR16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="orw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="orw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="orw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 1, 0, d) | 10000011 | rr(1, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00001101 | iv:s16=c ; 01100110 | rex(0, 1, 0, d) | 10000001 | rr(1, d) | iv:s16=c }" "asm"="orw ${c}, {d}" "asmonly" {
  ret void
}

define void @OR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 1, 4, m.base) | 10000011 | rm(1, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 1, 4, m.base) | 10000001 | rm(1, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="orw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 10000011 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 10000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="orw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 1, 0, 0) | 10000011 | rm(1, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 1, 0, 0) | 10000001 | rm(1, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="orw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001000 | rr(s, d)" "asm"="orb {s}, {d}" "asmonly" {
  ret void
}

define void @OR8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00001010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="orb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @OR8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00001010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @OR8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00001010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="orb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00001000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="orb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00001000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="orb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00001000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="orb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @OR8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00001100 | iv:s8=c ; { if(d<4) rex(0, 1, 0, d) ; 0100 0 R:1=(1)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(1, d) | iv:s8=c }" "asm"="orb ${c}, {d}" "asmonly" {
  ret void
}

define void @OR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 1, 4, m.base) | 10000000 | rm(1, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="orb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @OR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 10000000 | rm(1, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="orb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @OR8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 1, 0, 0) | 10000000 | rm(1, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="orb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00010001 | rr(s, d)" "asm"="adcq {s}, {d}" "asmonly" {
  ret void
}

define void @ADC64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00010011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="adcq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADC64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00010011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADC64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00010011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="adcq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="adcq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="adcq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 2, 0, d) | 10000011 | rr(2, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00010101 | iv:s32=c ; rex(1, 2, 0, d) | 10000001 | rr(2, d) | iv:s32=c }" "asm"="adcq ${c}, {d}" "asmonly" {
  ret void
}

define void @ADC64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 2, 4, m.base) | 10000011 | rm(2, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 2, 4, m.base) | 10000001 | rm(2, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="adcq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 2, m.index, m.base) | 10000011 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 2, m.index, m.base) | 10000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="adcq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 2, 0, 0) | 10000011 | rm(2, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 2, 0, 0) | 10000001 | rm(2, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="adcq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00010001 | rr(s, d)" "asm"="adcl {s}, {d}" "asmonly" {
  ret void
}

define void @ADC32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00010011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="adcl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADC32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00010011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADC32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00010011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="adcl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="adcl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="adcl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 2, 0, d) | 10000011 | rr(2, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00010101 | iv:s32=c ; rex(0, 2, 0, d) | 10000001 | rr(2, d) | iv:s32=c }" "asm"="adcl ${c}, {d}" "asmonly" {
  ret void
}

define void @ADC32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 2, 4, m.base) | 10000011 | rm(2, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 2, 4, m.base) | 10000001 | rm(2, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="adcl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 10000011 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 2, m.index, m.base) | 10000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="adcl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 2, 0, 0) | 10000011 | rm(2, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 2, 0, 0) | 10000001 | rm(2, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="adcl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00010001 | rr(s, d)" "asm"="adcw {s}, {d}" "asmonly" {
  ret void
}

define void @ADC16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00010011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="adcw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADC16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00010011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADC16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00010011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="adcw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00010001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="adcw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00010001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00010001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="adcw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 2, 0, d) | 10000011 | rr(2, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00010101 | iv:s16=c ; 01100110 | rex(0, 2, 0, d) | 10000001 | rr(2, d) | iv:s16=c }" "asm"="adcw ${c}, {d}" "asmonly" {
  ret void
}

define void @ADC16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 2, 4, m.base) | 10000011 | rm(2, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 2, 4, m.base) | 10000001 | rm(2, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="adcw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 10000011 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 10000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="adcw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 2, 0, 0) | 10000011 | rm(2, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 2, 0, 0) | 10000001 | rm(2, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="adcw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00010000 | rr(s, d)" "asm"="adcb {s}, {d}" "asmonly" {
  ret void
}

define void @ADC8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00010010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="adcb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @ADC8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00010010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @ADC8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00010010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="adcb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00010000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="adcb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00010000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="adcb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00010000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="adcb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ADC8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00010100 | iv:s8=c ; { if(d<4) rex(0, 2, 0, d) ; 0100 0 R:1=(2)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(2, d) | iv:s8=c }" "asm"="adcb ${c}, {d}" "asmonly" {
  ret void
}

define void @ADC8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 2, 4, m.base) | 10000000 | rm(2, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="adcb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ADC8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 10000000 | rm(2, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="adcb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ADC8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 2, 0, 0) | 10000000 | rm(2, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="adcb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00011001 | rr(s, d)" "asm"="sbbq {s}, {d}" "asmonly" {
  ret void
}

define void @SBB64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00011011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="sbbq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SBB64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00011011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SBB64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00011011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="sbbq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00011001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="sbbq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00011001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00011001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="sbbq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 3, 0, d) | 10000011 | rr(3, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00011101 | iv:s32=c ; rex(1, 3, 0, d) | 10000001 | rr(3, d) | iv:s32=c }" "asm"="sbbq ${c}, {d}" "asmonly" {
  ret void
}

define void @SBB64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 3, 4, m.base) | 10000011 | rm(3, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 3, 4, m.base) | 10000001 | rm(3, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="sbbq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 3, m.index, m.base) | 10000011 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 3, m.index, m.base) | 10000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="sbbq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 3, 0, 0) | 10000011 | rm(3, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 3, 0, 0) | 10000001 | rm(3, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="sbbq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00011001 | rr(s, d)" "asm"="sbbl {s}, {d}" "asmonly" {
  ret void
}

define void @SBB32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00011011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="sbbl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SBB32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00011011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SBB32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00011011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="sbbl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00011001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="sbbl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00011001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00011001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="sbbl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 3, 0, d) | 10000011 | rr(3, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00011101 | iv:s32=c ; rex(0, 3, 0, d) | 10000001 | rr(3, d) | iv:s32=c }" "asm"="sbbl ${c}, {d}" "asmonly" {
  ret void
}

define void @SBB32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 3, 4, m.base) | 10000011 | rm(3, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 3, 4, m.base) | 10000001 | rm(3, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="sbbl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 10000011 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 3, m.index, m.base) | 10000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="sbbl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 3, 0, 0) | 10000011 | rm(3, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 3, 0, 0) | 10000001 | rm(3, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="sbbl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00011001 | rr(s, d)" "asm"="sbbw {s}, {d}" "asmonly" {
  ret void
}

define void @SBB16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00011011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="sbbw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SBB16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00011011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SBB16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00011011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="sbbw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00011001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="sbbw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00011001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00011001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="sbbw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 3, 0, d) | 10000011 | rr(3, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00011101 | iv:s16=c ; 01100110 | rex(0, 3, 0, d) | 10000001 | rr(3, d) | iv:s16=c }" "asm"="sbbw ${c}, {d}" "asmonly" {
  ret void
}

define void @SBB16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 3, 4, m.base) | 10000011 | rm(3, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 3, 4, m.base) | 10000001 | rm(3, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="sbbw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 10000011 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 10000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="sbbw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 3, 0, 0) | 10000011 | rm(3, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 3, 0, 0) | 10000001 | rm(3, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="sbbw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00011000 | rr(s, d)" "asm"="sbbb {s}, {d}" "asmonly" {
  ret void
}

define void @SBB8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00011010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="sbbb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SBB8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00011010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SBB8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00011010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="sbbb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00011000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="sbbb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00011000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sbbb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00011000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="sbbb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SBB8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00011100 | iv:s8=c ; { if(d<4) rex(0, 3, 0, d) ; 0100 0 R:1=(3)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(3, d) | iv:s8=c }" "asm"="sbbb ${c}, {d}" "asmonly" {
  ret void
}

define void @SBB8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 3, 4, m.base) | 10000000 | rm(3, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="sbbb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SBB8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 10000000 | rm(3, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="sbbb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SBB8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 3, 0, 0) | 10000000 | rm(3, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="sbbb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00100001 | rr(s, d)" "asm"="andq {s}, {d}" "asmonly" {
  ret void
}

define void @AND64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00100011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="andq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @AND64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00100011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @AND64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00100011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="andq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00100001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="andq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00100001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00100001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="andq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 4, 0, d) | 10000011 | rr(4, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00100101 | iv:s32=c ; rex(1, 4, 0, d) | 10000001 | rr(4, d) | iv:s32=c }" "asm"="andq ${c}, {d}" "asmonly" {
  ret void
}

define void @AND64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 4, 4, m.base) | 10000011 | rm(4, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 4, 4, m.base) | 10000001 | rm(4, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="andq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 4, m.index, m.base) | 10000011 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 4, m.index, m.base) | 10000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="andq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 4, 0, 0) | 10000011 | rm(4, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 4, 0, 0) | 10000001 | rm(4, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="andq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00100001 | rr(s, d)" "asm"="andl {s}, {d}" "asmonly" {
  ret void
}

define void @AND32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00100011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="andl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @AND32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00100011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @AND32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00100011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="andl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00100001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="andl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00100001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00100001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="andl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 4, 0, d) | 10000011 | rr(4, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00100101 | iv:s32=c ; rex(0, 4, 0, d) | 10000001 | rr(4, d) | iv:s32=c }" "asm"="andl ${c}, {d}" "asmonly" {
  ret void
}

define void @AND32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 4, 4, m.base) | 10000011 | rm(4, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 4, 4, m.base) | 10000001 | rm(4, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="andl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 10000011 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 4, m.index, m.base) | 10000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="andl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 4, 0, 0) | 10000011 | rm(4, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 4, 0, 0) | 10000001 | rm(4, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="andl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00100001 | rr(s, d)" "asm"="andw {s}, {d}" "asmonly" {
  ret void
}

define void @AND16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00100011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="andw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @AND16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00100011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @AND16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00100011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="andw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00100001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="andw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00100001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00100001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="andw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 4, 0, d) | 10000011 | rr(4, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00100101 | iv:s16=c ; 01100110 | rex(0, 4, 0, d) | 10000001 | rr(4, d) | iv:s16=c }" "asm"="andw ${c}, {d}" "asmonly" {
  ret void
}

define void @AND16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 4, 4, m.base) | 10000011 | rm(4, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 4, 4, m.base) | 10000001 | rm(4, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="andw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 10000011 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 10000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="andw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 4, 0, 0) | 10000011 | rm(4, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 4, 0, 0) | 10000001 | rm(4, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="andw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00100000 | rr(s, d)" "asm"="andb {s}, {d}" "asmonly" {
  ret void
}

define void @AND8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00100010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="andb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @AND8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00100010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @AND8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00100010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="andb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00100000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="andb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00100000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="andb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00100000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="andb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @AND8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00100100 | iv:s8=c ; { if(d<4) rex(0, 4, 0, d) ; 0100 0 R:1=(4)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(4, d) | iv:s8=c }" "asm"="andb ${c}, {d}" "asmonly" {
  ret void
}

define void @AND8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 4, 4, m.base) | 10000000 | rm(4, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="andb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @AND8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 10000000 | rm(4, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="andb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @AND8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 4, 0, 0) | 10000000 | rm(4, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="andb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00101001 | rr(s, d)" "asm"="subq {s}, {d}" "asmonly" {
  ret void
}

define void @SUB64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00101011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="subq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUB64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00101011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUB64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00101011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="subq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="subq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="subq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 5, 0, d) | 10000011 | rr(5, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00101101 | iv:s32=c ; rex(1, 5, 0, d) | 10000001 | rr(5, d) | iv:s32=c }" "asm"="subq ${c}, {d}" "asmonly" {
  ret void
}

define void @SUB64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 5, 4, m.base) | 10000011 | rm(5, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 5, 4, m.base) | 10000001 | rm(5, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="subq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 5, m.index, m.base) | 10000011 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 5, m.index, m.base) | 10000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="subq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 5, 0, 0) | 10000011 | rm(5, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 5, 0, 0) | 10000001 | rm(5, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="subq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00101001 | rr(s, d)" "asm"="subl {s}, {d}" "asmonly" {
  ret void
}

define void @SUB32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00101011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="subl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUB32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00101011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUB32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00101011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="subl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="subl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="subl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 5, 0, d) | 10000011 | rr(5, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00101101 | iv:s32=c ; rex(0, 5, 0, d) | 10000001 | rr(5, d) | iv:s32=c }" "asm"="subl ${c}, {d}" "asmonly" {
  ret void
}

define void @SUB32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 5, 4, m.base) | 10000011 | rm(5, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 5, 4, m.base) | 10000001 | rm(5, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="subl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 10000011 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 5, m.index, m.base) | 10000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="subl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 5, 0, 0) | 10000011 | rm(5, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 5, 0, 0) | 10000001 | rm(5, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="subl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00101001 | rr(s, d)" "asm"="subw {s}, {d}" "asmonly" {
  ret void
}

define void @SUB16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00101011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="subw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUB16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00101011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUB16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00101011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="subw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00101001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="subw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00101001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00101001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="subw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 5, 0, d) | 10000011 | rr(5, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00101101 | iv:s16=c ; 01100110 | rex(0, 5, 0, d) | 10000001 | rr(5, d) | iv:s16=c }" "asm"="subw ${c}, {d}" "asmonly" {
  ret void
}

define void @SUB16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 5, 4, m.base) | 10000011 | rm(5, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 5, 4, m.base) | 10000001 | rm(5, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="subw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 10000011 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 10000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="subw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 5, 0, 0) | 10000011 | rm(5, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 5, 0, 0) | 10000001 | rm(5, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="subw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00101000 | rr(s, d)" "asm"="subb {s}, {d}" "asmonly" {
  ret void
}

define void @SUB8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00101010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="subb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @SUB8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00101010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @SUB8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00101010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="subb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00101000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="subb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00101000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="subb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00101000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="subb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SUB8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00101100 | iv:s8=c ; { if(d<4) rex(0, 5, 0, d) ; 0100 0 R:1=(5)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(5, d) | iv:s8=c }" "asm"="subb ${c}, {d}" "asmonly" {
  ret void
}

define void @SUB8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 5, 4, m.base) | 10000000 | rm(5, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="subb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SUB8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 10000000 | rm(5, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="subb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SUB8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 5, 0, 0) | 10000000 | rm(5, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="subb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00110001 | rr(s, d)" "asm"="xorq {s}, {d}" "asmonly" {
  ret void
}

define void @XOR64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00110011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="xorq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XOR64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00110011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XOR64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00110011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="xorq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00110001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="xorq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00110001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00110001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="xorq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 6, 0, d) | 10000011 | rr(6, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00110101 | iv:s32=c ; rex(1, 6, 0, d) | 10000001 | rr(6, d) | iv:s32=c }" "asm"="xorq ${c}, {d}" "asmonly" {
  ret void
}

define void @XOR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 6, 4, m.base) | 10000011 | rm(6, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 6, 4, m.base) | 10000001 | rm(6, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="xorq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 6, m.index, m.base) | 10000011 | rm(6, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 6, m.index, m.base) | 10000001 | rm(6, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="xorq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 6, 0, 0) | 10000011 | rm(6, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 6, 0, 0) | 10000001 | rm(6, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="xorq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00110001 | rr(s, d)" "asm"="xorl {s}, {d}" "asmonly" {
  ret void
}

define void @XOR32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00110011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="xorl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XOR32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00110011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XOR32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00110011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="xorl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00110001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="xorl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00110001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00110001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="xorl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 6, 0, d) | 10000011 | rr(6, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00110101 | iv:s32=c ; rex(0, 6, 0, d) | 10000001 | rr(6, d) | iv:s32=c }" "asm"="xorl ${c}, {d}" "asmonly" {
  ret void
}

define void @XOR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 6, 4, m.base) | 10000011 | rm(6, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 6, 4, m.base) | 10000001 | rm(6, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="xorl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 6, m.index, m.base) | 10000011 | rm(6, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 6, m.index, m.base) | 10000001 | rm(6, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="xorl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 6, 0, 0) | 10000011 | rm(6, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 6, 0, 0) | 10000001 | rm(6, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="xorl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00110001 | rr(s, d)" "asm"="xorw {s}, {d}" "asmonly" {
  ret void
}

define void @XOR16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00110011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="xorw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XOR16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00110011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XOR16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00110011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="xorw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00110001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="xorw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00110001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00110001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="xorw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 6, 0, d) | 10000011 | rr(6, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00110101 | iv:s16=c ; 01100110 | rex(0, 6, 0, d) | 10000001 | rr(6, d) | iv:s16=c }" "asm"="xorw ${c}, {d}" "asmonly" {
  ret void
}

define void @XOR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 6, 4, m.base) | 10000011 | rm(6, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 6, 4, m.base) | 10000001 | rm(6, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="xorw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 6, m.index, m.base) | 10000011 | rm(6, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 6, m.index, m.base) | 10000001 | rm(6, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="xorw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 6, 0, 0) | 10000011 | rm(6, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 6, 0, 0) | 10000001 | rm(6, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="xorw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00110000 | rr(s, d)" "asm"="xorb {s}, {d}" "asmonly" {
  ret void
}

define void @XOR8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00110010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="xorb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @XOR8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00110010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @XOR8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00110010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="xorb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00110000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="xorb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00110000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="xorb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00110000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="xorb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @XOR8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00110100 | iv:s8=c ; { if(d<4) rex(0, 6, 0, d) ; 0100 0 R:1=(6)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(6, d) | iv:s8=c }" "asm"="xorb ${c}, {d}" "asmonly" {
  ret void
}

define void @XOR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 6, 4, m.base) | 10000000 | rm(6, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="xorb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @XOR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 6, m.index, m.base) | 10000000 | rm(6, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="xorb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @XOR8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 6, 0, 0) | 10000000 | rm(6, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="xorb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 00111001 | rr(s, d)" "asm"="cmpq {s}, {d}" "asmonly" {
  ret void
}

define void @CmP64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00111011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmpq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxP64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00111011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpP64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00111011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmpq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CmP64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 00111001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="cmpq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 00111001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 00111001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="cmpq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ rex(1, 7, 0, d) | 10000011 | rr(7, d) | ib:s8=c ; a:0=d rex(1, 0, 0, 0) | 00111101 | iv:s32=c ; rex(1, 7, 0, d) | 10000001 | rr(7, d) | iv:s32=c }" "asm"="cmpq ${c}, {d}" "asmonly" {
  ret void
}

define void @CmP64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 7, 4, m.base) | 10000011 | rm(7, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(1, 7, 4, m.base) | 10000001 | rm(7, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="cmpq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 7, m.index, m.base) | 10000011 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(1, 7, m.index, m.base) | 10000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="cmpq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 7, 0, 0) | 10000011 | rm(7, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(1, 7, 0, 0) | 10000001 | rm(7, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="cmpq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 00111001 | rr(s, d)" "asm"="cmpl {s}, {d}" "asmonly" {
  ret void
}

define void @CmP32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00111011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmpl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxP32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00111011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpP32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00111011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmpl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CmP32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 00111001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="cmpl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 00111001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 00111001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="cmpl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ rex(0, 7, 0, d) | 10000011 | rr(7, d) | ib:s8=c ; a:0=d rex(0, 0, 0, 0) | 00111101 | iv:s32=c ; rex(0, 7, 0, d) | 10000001 | rr(7, d) | iv:s32=c }" "asm"="cmpl ${c}, {d}" "asmonly" {
  ret void
}

define void @CmP32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 7, 4, m.base) | 10000011 | rm(7, m.base, 4, 1, m.disp, 0) | ib:s8=c ; rex(0, 7, 4, m.base) | 10000001 | rm(7, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="cmpl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 10000011 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) rex(0, 7, m.index, m.base) | 10000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="cmpl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 7, 0, 0) | 10000011 | rm(7, 16, 4, 1, 0, m.sym) | ib:s8=c ; rex(0, 7, 0, 0) | 10000001 | rm(7, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="cmpl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 00111001 | rr(s, d)" "asm"="cmpw {s}, {d}" "asmonly" {
  ret void
}

define void @CmP16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00111011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmpw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxP16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00111011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpP16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00111011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmpw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CmP16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 00111001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="cmpw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 00111001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 00111001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="cmpw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 7, 0, d) | 10000011 | rr(7, d) | ib:s8=c ; a:0=d 01100110 | rex(0, 0, 0, 0) | 00111101 | iv:s16=c ; 01100110 | rex(0, 7, 0, d) | 10000001 | rr(7, d) | iv:s16=c }" "asm"="cmpw ${c}, {d}" "asmonly" {
  ret void
}

define void @CmP16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 7, 4, m.base) | 10000011 | rm(7, m.base, 4, 1, m.disp, 0) | ib:s8=c ; 01100110 | rex(0, 7, 4, m.base) | 10000001 | rm(7, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="cmpw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 10000011 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:s8=c ; if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 10000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="cmpw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 7, 0, 0) | 10000011 | rm(7, 16, 4, 1, 0, m.sym) | ib:s8=c ; 01100110 | rex(0, 7, 0, 0) | 10000001 | rm(7, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="cmpw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00111000 | rr(s, d)" "asm"="cmpb {s}, {d}" "asmonly" {
  ret void
}

define void @CmP8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00111010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmpb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxP8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00111010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpP8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00111010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmpb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CmP8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 00111000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="cmpb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 00111000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmpb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 00111000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="cmpb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMP8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 00111100 | iv:s8=c ; { if(d<4) rex(0, 7, 0, d) ; 0100 0 R:1=(7)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000000 | rr(7, d) | iv:s8=c }" "asm"="cmpb ${c}, {d}" "asmonly" {
  ret void
}

define void @CmP8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 7, 4, m.base) | 10000000 | rm(7, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="cmpb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CxP8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 10000000 | rm(7, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="cmpb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CpP8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 7, 0, 0) | 10000000 | rm(7, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="cmpb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 10001001 | rr(s, d)" "asm"="movq {s}, {d}" "asmonly" {
  ret void
}

define void @mOV64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 10001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOV64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 10001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOV64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOV64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 10001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="movq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 10001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 10001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="movq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="rex(1, 0, 0, d) | 11000111 | rr(0, d) | iv:s32=c" "asm"="movq ${c}, {d}" "asmonly" {
  ret void
}

define void @mOV64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 0, 4, m.base) | 11000111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="movq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 11000111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="movq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 0, 0, 0) | 11000111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="movq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 10001001 | rr(s, d)" "asm"="movl {s}, {d}" "asmonly" {
  ret void
}

define void @mOV32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 10001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOV32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 10001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOV32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOV32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 10001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="movl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 10001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 10001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="movl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:s32=c" "asm"="movl ${c}, {d}" "asmonly" {
  ret void
}

define void @mOV32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 11000111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="movl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11000111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="movl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 11000111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="movl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 10001001 | rr(s, d)" "asm"="movw {s}, {d}" "asmonly" {
  ret void
}

define void @mOV16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 10001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOV16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 10001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOV16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOV16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 10001001 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="movw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 10001001 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 10001001 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="movw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="01100110 | rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:s16=c" "asm"="movw ${c}, {d}" "asmonly" {
  ret void
}

define void @mOV16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 4, m.base) | 11000111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="movw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11000111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="movw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 0, 0) | 11000111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="movw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10001000 | rr(s, d)" "asm"="movb {s}, {d}" "asmonly" {
  ret void
}

define void @mOV8rm(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="{ if(d<4) rex(0, d, 4, m.base) ; 0100 0 R:1=(d)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 10001010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movb {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOV8rx(i64 "reg"="r8" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) { if(d<4) rex(0, d, m.index, m.base) ; 0100 0 R:1=(d)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 10001010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movb {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOV8rp(i64 "reg"="r8" %d, ptr "sym" %m.sym) "enc"="{ if(d<4) rex(0, d, 0, 0) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 10001010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movb {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @mOV8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 10001000 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="movb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 10001000 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 10001000 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="movb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOV8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10110 o:3=d&7 | ib:s8=c" "asm"="movb ${c}, {d}" "asmonly" {
  ret void
}

define void @mOV8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 11000110 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="movb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xOV8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11000110 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="movb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pOV8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 11000110 | rm(0, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="movb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVABS64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="rex(1, 0, 0, d) | 10111 o:3=d&7 | io:s64=c" "asm"="movabsq ${c}, {d}" "asmonly" {
  ret void
}

define void @LEA64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 10001101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="leaq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @LEA64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 10001101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="leaq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @LEA64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 10001101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="leaq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @LEA32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 10001101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="leal {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @LEA32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 10001101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="leal {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @LEA32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 10001101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="leal {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVZB32rr(i64 "reg"="r32" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, d, 0, s) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(s)>>3 } | 00001111 | 10110110 | rr(d, s)" "asm"="movzbl {s}, {d}" "asmonly" {
  ret void
}

define void @mOVZB32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10110110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movzbl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVZB32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10110110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movzbl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVZB32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10110110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movzbl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVZB16rr(i64 "reg"="r16" %d, i64 "reg"="r8" %s) "enc"="01100110 | { if(s<4) rex(0, d, 0, s) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(s)>>3 } | 00001111 | 10110110 | rr(d, s)" "asm"="movzbw {s}, {d}" "asmonly" {
  ret void
}

define void @mOVZB16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 10110110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movzbw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVZB16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 10110110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movzbw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVZB16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 10110110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movzbw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVZB64rr(i64 "reg"="r64" %d, i64 "reg"="r8" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10110110 | rr(d, s)" "asm"="movzbq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVZB64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10110110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movzbq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVZB64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10110110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movzbq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVZB64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10110110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movzbq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVZW32rr(i64 "reg"="r32" %d, i64 "reg"="r16" %s) "enc"="rex(0, d, 0, s) | 00001111 | 10110111 | rr(d, s)" "asm"="movzwl {s}, {d}" "asmonly" {
  ret void
}

define void @mOVZW32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10110111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movzwl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVZW32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10110111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movzwl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVZW32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10110111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movzwl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVZW64rr(i64 "reg"="r64" %d, i64 "reg"="r16" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10110111 | rr(d, s)" "asm"="movzwq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVZW64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10110111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movzwq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVZW64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10110111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movzwq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVZW64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10110111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movzwq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSB32rr(i64 "reg"="r32" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, d, 0, s) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(s)>>3 } | 00001111 | 10111110 | rr(d, s)" "asm"="movsbl {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSB32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10111110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movsbl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSB32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10111110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movsbl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSB32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10111110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movsbl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSB16rr(i64 "reg"="r16" %d, i64 "reg"="r8" %s) "enc"="01100110 | { if(s<4) rex(0, d, 0, s) ; 0100 0 R:1=(d)>>3 X:1=(0)>>3 B:1=(s)>>3 } | 00001111 | 10111110 | rr(d, s)" "asm"="movsbw {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSB16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 10111110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movsbw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSB16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 10111110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movsbw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSB16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 10111110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movsbw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSB64rr(i64 "reg"="r64" %d, i64 "reg"="r8" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10111110 | rr(d, s)" "asm"="movsbq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSB64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10111110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movsbq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSB64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10111110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movsbq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSB64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10111110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movsbq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSW32rr(i64 "reg"="r32" %d, i64 "reg"="r16" %s) "enc"="rex(0, d, 0, s) | 00001111 | 10111111 | rr(d, s)" "asm"="movswl {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSW32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10111111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movswl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSW32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10111111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movswl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSW32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10111111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movswl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSW64rr(i64 "reg"="r64" %d, i64 "reg"="r16" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10111111 | rr(d, s)" "asm"="movswq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSW64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10111111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movswq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSW64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10111111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movswq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSW64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10111111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movswq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MOVSLQrr(i64 "reg"="r64" %d, i64 "reg"="r32" %s) "enc"="rex(1, d, 0, s) | 01100011 | rr(d, s)" "asm"="movslq {s}, {d}" "asmonly" {
  ret void
}

define void @mOVSLQrm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 01100011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="movslq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @xOVSLQrx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 01100011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="movslq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @pOVSLQrp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 01100011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="movslq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, d) | 10000101 | rr(s, d)" "asm"="testq {s}, {d}" "asmonly" {
  ret void
}

define void @TEST64mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="rex(1, s, 4, m.base) | 10000101 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="testq {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST64xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r64" %s) "enc"="{ if(m.index!=4) rex(1, s, m.index, m.base) | 10000101 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="testq {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST64pr(ptr "sym" %m.sym, i64 "reg"="r64" %s) "enc"="rex(1, s, 0, 0) | 10000101 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="testq {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST64ri(i64 "reg"="r64" %d, i64 "imm" %c) "enc"="{ a:0=d rex(1, 0, 0, 0) | 10101001 | iv:s32=c ; rex(1, 0, 0, d) | 11110111 | rr(0, d) | iv:s32=c }" "asm"="testq ${c}, {d}" "asmonly" {
  ret void
}

define void @TEST64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(1, 0, 4, m.base) | 11110111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="testq ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 11110111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="testq ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST64pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(1, 0, 0, 0) | 11110111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="testq ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, d) | 10000101 | rr(s, d)" "asm"="testl {s}, {d}" "asmonly" {
  ret void
}

define void @TEST32mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="rex(0, s, 4, m.base) | 10000101 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="testl {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST32xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r32" %s) "enc"="{ if(m.index!=4) rex(0, s, m.index, m.base) | 10000101 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="testl {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST32pr(ptr "sym" %m.sym, i64 "reg"="r32" %s) "enc"="rex(0, s, 0, 0) | 10000101 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="testl {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST32ri(i64 "reg"="r32" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 10101001 | iv:s32=c ; rex(0, 0, 0, d) | 11110111 | rr(0, d) | iv:s32=c }" "asm"="testl ${c}, {d}" "asmonly" {
  ret void
}

define void @TEST32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 11110111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s32=c }" "asm"="testl ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11110111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s32=c }" "asm"="testl ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST32pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 11110111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s32=c }" "asm"="testl ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, d) | 10000101 | rr(s, d)" "asm"="testw {s}, {d}" "asmonly" {
  ret void
}

define void @TEST16mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 4, m.base) | 10000101 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="testw {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST16xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r16" %s) "enc"="{ if(m.index!=4) 01100110 | rex(0, s, m.index, m.base) | 10000101 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="testw {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST16pr(ptr "sym" %m.sym, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, s, 0, 0) | 10000101 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="testw {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST16ri(i64 "reg"="r16" %d, i64 "imm" %c) "enc"="{ a:0=d 01100110 | rex(0, 0, 0, 0) | 10101001 | iv:s16=c ; 01100110 | rex(0, 0, 0, d) | 11110111 | rr(0, d) | iv:s16=c }" "asm"="testw ${c}, {d}" "asmonly" {
  ret void
}

define void @TEST16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 4, m.base) | 11110111 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s16=c }" "asm"="testw ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11110111 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s16=c }" "asm"="testw ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST16pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ 01100110 | rex(0, 0, 0, 0) | 11110111 | rm(0, 16, 4, 1, 0, m.sym) | iv:s16=c }" "asm"="testw ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST8rr(i64 "reg"="r8" %d, i64 "reg"="r8" %s) "enc"="{ if(s<4) if(d<4) rex(0, s, 0, d) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 10000100 | rr(s, d)" "asm"="testb {s}, {d}" "asmonly" {
  ret void
}

define void @TEST8mr(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 4, m.base) ; 0100 0 R:1=(s)>>3 X:1=(4)>>3 B:1=(m.base)>>3 } | 10000100 | rm(s, m.base, 4, 1, m.disp, 0)" "asm"="testb {s}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST8xr(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "reg"="r8" %s) "enc"="{ if(m.index!=4) { if(s<4) rex(0, s, m.index, m.base) ; 0100 0 R:1=(s)>>3 X:1=(m.index)>>3 B:1=(m.base)>>3 } | 10000100 | rm(s, m.base, m.index, m.scale, m.disp, 0) }" "asm"="testb {s}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST8pr(ptr "sym" %m.sym, i64 "reg"="r8" %s) "enc"="{ if(s<4) rex(0, s, 0, 0) ; 0100 0 R:1=(s)>>3 X:1=(0)>>3 B:1=(0)>>3 } | 10000100 | rm(s, 16, 4, 1, 0, m.sym)" "asm"="testb {s}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TEST8ri(i64 "reg"="r8" %d, i64 "imm" %c) "enc"="{ a:0=d rex(0, 0, 0, 0) | 10101000 | iv:s8=c ; { if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(0, d) | iv:s8=c }" "asm"="testb ${c}, {d}" "asmonly" {
  ret void
}

define void @TEST8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ rex(0, 0, 4, m.base) | 11110110 | rm(0, m.base, 4, 1, m.disp, 0) | iv:s8=c }" "asm"="testb ${c}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @TEST8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %c) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11110110 | rm(0, m.base, m.index, m.scale, m.disp, 0) | iv:s8=c }" "asm"="testb ${c}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @TEST8pi(ptr "sym" %m.sym, i64 "imm" %c) "enc"="{ rex(0, 0, 0, 0) | 11110110 | rm(0, 16, 4, 1, 0, m.sym) | iv:s8=c }" "asm"="testb ${c}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NOT64r(i64 "reg"="r64" %d) "enc"="rex(1, 2, 0, d) | 11110111 | rr(2, d)" "asm"="notq {d}" "asmonly" {
  ret void
}

define void @NOT64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 2, 4, m.base) | 11110111 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="notq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NOT64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 2, m.index, m.base) | 11110111 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="notq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NOT64p(ptr "sym" %m.sym) "enc"="rex(1, 2, 0, 0) | 11110111 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="notq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NOT32r(i64 "reg"="r32" %d) "enc"="rex(0, 2, 0, d) | 11110111 | rr(2, d)" "asm"="notl {d}" "asmonly" {
  ret void
}

define void @NOT32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 2, 4, m.base) | 11110111 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="notl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NOT32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11110111 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="notl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NOT32p(ptr "sym" %m.sym) "enc"="rex(0, 2, 0, 0) | 11110111 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="notl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NOT16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 2, 0, d) | 11110111 | rr(2, d)" "asm"="notw {d}" "asmonly" {
  ret void
}

define void @NOT16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 2, 4, m.base) | 11110111 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="notw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NOT16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 11110111 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="notw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NOT16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 2, 0, 0) | 11110111 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="notw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NOT8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 2, 0, d) ; 0100 0 R:1=(2)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(2, d)" "asm"="notb {d}" "asmonly" {
  ret void
}

define void @NOT8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 2, 4, m.base) | 11110110 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="notb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NOT8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11110110 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="notb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NOT8p(ptr "sym" %m.sym) "enc"="rex(0, 2, 0, 0) | 11110110 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="notb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NEG64r(i64 "reg"="r64" %d) "enc"="rex(1, 3, 0, d) | 11110111 | rr(3, d)" "asm"="negq {d}" "asmonly" {
  ret void
}

define void @NEG64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 3, 4, m.base) | 11110111 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="negq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NEG64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 3, m.index, m.base) | 11110111 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="negq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NEG64p(ptr "sym" %m.sym) "enc"="rex(1, 3, 0, 0) | 11110111 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="negq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NEG32r(i64 "reg"="r32" %d) "enc"="rex(0, 3, 0, d) | 11110111 | rr(3, d)" "asm"="negl {d}" "asmonly" {
  ret void
}

define void @NEG32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 3, 4, m.base) | 11110111 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="negl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NEG32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11110111 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="negl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NEG32p(ptr "sym" %m.sym) "enc"="rex(0, 3, 0, 0) | 11110111 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="negl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NEG16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 3, 0, d) | 11110111 | rr(3, d)" "asm"="negw {d}" "asmonly" {
  ret void
}

define void @NEG16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 3, 4, m.base) | 11110111 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="negw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NEG16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 11110111 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="negw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NEG16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 3, 0, 0) | 11110111 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="negw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @NEG8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 3, 0, d) ; 0100 0 R:1=(3)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(3, d)" "asm"="negb {d}" "asmonly" {
  ret void
}

define void @NEG8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 3, 4, m.base) | 11110110 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="negb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @NEG8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11110110 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="negb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @NEG8p(ptr "sym" %m.sym) "enc"="rex(0, 3, 0, 0) | 11110110 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="negb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MUL64r(i64 "reg"="r64" %d) "enc"="rex(1, 4, 0, d) | 11110111 | rr(4, d)" "asm"="mulq {d}" "asmonly" {
  ret void
}

define void @mUL64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 4, 4, m.base) | 11110111 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="mulq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xUL64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 4, m.index, m.base) | 11110111 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="mulq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pUL64p(ptr "sym" %m.sym) "enc"="rex(1, 4, 0, 0) | 11110111 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="mulq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MUL32r(i64 "reg"="r32" %d) "enc"="rex(0, 4, 0, d) | 11110111 | rr(4, d)" "asm"="mull {d}" "asmonly" {
  ret void
}

define void @mUL32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 4, 4, m.base) | 11110111 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="mull {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xUL32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11110111 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="mull {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pUL32p(ptr "sym" %m.sym) "enc"="rex(0, 4, 0, 0) | 11110111 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="mull {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MUL16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 4, 0, d) | 11110111 | rr(4, d)" "asm"="mulw {d}" "asmonly" {
  ret void
}

define void @mUL16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 4, 4, m.base) | 11110111 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="mulw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xUL16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 11110111 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="mulw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pUL16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 4, 0, 0) | 11110111 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="mulw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @MUL8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 4, 0, d) ; 0100 0 R:1=(4)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(4, d)" "asm"="mulb {d}" "asmonly" {
  ret void
}

define void @mUL8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 4, 4, m.base) | 11110110 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="mulb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @xUL8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11110110 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="mulb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @pUL8p(ptr "sym" %m.sym) "enc"="rex(0, 4, 0, 0) | 11110110 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="mulb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL64r(i64 "reg"="r64" %d) "enc"="rex(1, 5, 0, d) | 11110111 | rr(5, d)" "asm"="imulq {d}" "asmonly" {
  ret void
}

define void @ImUL64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 5, 4, m.base) | 11110111 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="imulq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IxUL64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 5, m.index, m.base) | 11110111 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imulq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IpUL64p(ptr "sym" %m.sym) "enc"="rex(1, 5, 0, 0) | 11110111 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="imulq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL32r(i64 "reg"="r32" %d) "enc"="rex(0, 5, 0, d) | 11110111 | rr(5, d)" "asm"="imull {d}" "asmonly" {
  ret void
}

define void @ImUL32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 5, 4, m.base) | 11110111 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="imull {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IxUL32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11110111 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imull {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IpUL32p(ptr "sym" %m.sym) "enc"="rex(0, 5, 0, 0) | 11110111 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="imull {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 5, 0, d) | 11110111 | rr(5, d)" "asm"="imulw {d}" "asmonly" {
  ret void
}

define void @ImUL16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 5, 4, m.base) | 11110111 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="imulw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IxUL16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 11110111 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imulw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IpUL16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 5, 0, 0) | 11110111 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="imulw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 5, 0, d) ; 0100 0 R:1=(5)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(5, d)" "asm"="imulb {d}" "asmonly" {
  ret void
}

define void @ImUL8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 5, 4, m.base) | 11110110 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="imulb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IxUL8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11110110 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imulb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IpUL8p(ptr "sym" %m.sym) "enc"="rex(0, 5, 0, 0) | 11110110 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="imulb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIV64r(i64 "reg"="r64" %d) "enc"="rex(1, 6, 0, d) | 11110111 | rr(6, d)" "asm"="divq {d}" "asmonly" {
  ret void
}

define void @DIV64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 6, 4, m.base) | 11110111 | rm(6, m.base, 4, 1, m.disp, 0)" "asm"="divq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DIV64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 6, m.index, m.base) | 11110111 | rm(6, m.base, m.index, m.scale, m.disp, 0) }" "asm"="divq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DIV64p(ptr "sym" %m.sym) "enc"="rex(1, 6, 0, 0) | 11110111 | rm(6, 16, 4, 1, 0, m.sym)" "asm"="divq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIV32r(i64 "reg"="r32" %d) "enc"="rex(0, 6, 0, d) | 11110111 | rr(6, d)" "asm"="divl {d}" "asmonly" {
  ret void
}

define void @DIV32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 6, 4, m.base) | 11110111 | rm(6, m.base, 4, 1, m.disp, 0)" "asm"="divl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DIV32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 6, m.index, m.base) | 11110111 | rm(6, m.base, m.index, m.scale, m.disp, 0) }" "asm"="divl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DIV32p(ptr "sym" %m.sym) "enc"="rex(0, 6, 0, 0) | 11110111 | rm(6, 16, 4, 1, 0, m.sym)" "asm"="divl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIV16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 6, 0, d) | 11110111 | rr(6, d)" "asm"="divw {d}" "asmonly" {
  ret void
}

define void @DIV16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 6, 4, m.base) | 11110111 | rm(6, m.base, 4, 1, m.disp, 0)" "asm"="divw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DIV16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 6, m.index, m.base) | 11110111 | rm(6, m.base, m.index, m.scale, m.disp, 0) }" "asm"="divw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DIV16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 6, 0, 0) | 11110111 | rm(6, 16, 4, 1, 0, m.sym)" "asm"="divw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DIV8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 6, 0, d) ; 0100 0 R:1=(6)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(6, d)" "asm"="divb {d}" "asmonly" {
  ret void
}

define void @DIV8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 6, 4, m.base) | 11110110 | rm(6, m.base, 4, 1, m.disp, 0)" "asm"="divb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DIV8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 6, m.index, m.base) | 11110110 | rm(6, m.base, m.index, m.scale, m.disp, 0) }" "asm"="divb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DIV8p(ptr "sym" %m.sym) "enc"="rex(0, 6, 0, 0) | 11110110 | rm(6, 16, 4, 1, 0, m.sym)" "asm"="divb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IDIV64r(i64 "reg"="r64" %d) "enc"="rex(1, 7, 0, d) | 11110111 | rr(7, d)" "asm"="idivq {d}" "asmonly" {
  ret void
}

define void @IDIV64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 7, 4, m.base) | 11110111 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="idivq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IDIV64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 7, m.index, m.base) | 11110111 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="idivq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IDIV64p(ptr "sym" %m.sym) "enc"="rex(1, 7, 0, 0) | 11110111 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="idivq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IDIV32r(i64 "reg"="r32" %d) "enc"="rex(0, 7, 0, d) | 11110111 | rr(7, d)" "asm"="idivl {d}" "asmonly" {
  ret void
}

define void @IDIV32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 7, 4, m.base) | 11110111 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="idivl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IDIV32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11110111 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="idivl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IDIV32p(ptr "sym" %m.sym) "enc"="rex(0, 7, 0, 0) | 11110111 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="idivl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IDIV16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 7, 0, d) | 11110111 | rr(7, d)" "asm"="idivw {d}" "asmonly" {
  ret void
}

define void @IDIV16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 7, 4, m.base) | 11110111 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="idivw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IDIV16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 11110111 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="idivw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IDIV16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 7, 0, 0) | 11110111 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="idivw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IDIV8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 7, 0, d) ; 0100 0 R:1=(7)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11110110 | rr(7, d)" "asm"="idivb {d}" "asmonly" {
  ret void
}

define void @IDIV8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 7, 4, m.base) | 11110110 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="idivb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @IDIV8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11110110 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="idivb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @IDIV8p(ptr "sym" %m.sym) "enc"="rex(0, 7, 0, 0) | 11110110 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="idivb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @INC64r(i64 "reg"="r64" %d) "enc"="rex(1, 0, 0, d) | 11111111 | rr(0, d)" "asm"="incq {d}" "asmonly" {
  ret void
}

define void @INC64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 0, 4, m.base) | 11111111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="incq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @INC64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 11111111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="incq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @INC64p(ptr "sym" %m.sym) "enc"="rex(1, 0, 0, 0) | 11111111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="incq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @INC32r(i64 "reg"="r32" %d) "enc"="rex(0, 0, 0, d) | 11111111 | rr(0, d)" "asm"="incl {d}" "asmonly" {
  ret void
}

define void @INC32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 11111111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="incl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @INC32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11111111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="incl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @INC32p(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 11111111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="incl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @INC16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 0, 0, d) | 11111111 | rr(0, d)" "asm"="incw {d}" "asmonly" {
  ret void
}

define void @INC16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 0, 4, m.base) | 11111111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="incw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @INC16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11111111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="incw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @INC16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 0, 0, 0) | 11111111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="incw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @INC8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11111110 | rr(0, d)" "asm"="incb {d}" "asmonly" {
  ret void
}

define void @INC8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 11111110 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="incb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @INC8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11111110 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="incb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @INC8p(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 11111110 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="incb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DEC64r(i64 "reg"="r64" %d) "enc"="rex(1, 1, 0, d) | 11111111 | rr(1, d)" "asm"="decq {d}" "asmonly" {
  ret void
}

define void @DEC64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 1, 4, m.base) | 11111111 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="decq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DEC64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 1, m.index, m.base) | 11111111 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="decq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DEC64p(ptr "sym" %m.sym) "enc"="rex(1, 1, 0, 0) | 11111111 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="decq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DEC32r(i64 "reg"="r32" %d) "enc"="rex(0, 1, 0, d) | 11111111 | rr(1, d)" "asm"="decl {d}" "asmonly" {
  ret void
}

define void @DEC32m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 1, 4, m.base) | 11111111 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="decl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DEC32x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11111111 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="decl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DEC32p(ptr "sym" %m.sym) "enc"="rex(0, 1, 0, 0) | 11111111 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="decl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DEC16r(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 1, 0, d) | 11111111 | rr(1, d)" "asm"="decw {d}" "asmonly" {
  ret void
}

define void @DEC16m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 1, 4, m.base) | 11111111 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="decw {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DEC16x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 11111111 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="decw {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DEC16p(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 1, 0, 0) | 11111111 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="decw {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @DEC8r(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 1, 0, d) ; 0100 0 R:1=(1)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11111110 | rr(1, d)" "asm"="decb {d}" "asmonly" {
  ret void
}

define void @DEC8m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 1, 4, m.base) | 11111110 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="decb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @DEC8x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11111110 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="decb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @DEC8p(ptr "sym" %m.sym) "enc"="rex(0, 1, 0, 0) | 11111110 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="decb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10101111 | rr(d, s)" "asm"="imulq {s}, {d}" "asmonly" {
  ret void
}

define void @ImUL64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10101111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="imulq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @IxUL64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10101111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imulq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @IpUL64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10101111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="imulq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL64rri(i64 "reg"="r64" %d, i64 "reg"="r64" %s, i64 "imm" %c) "enc"="{ rex(1, d, 0, s) | 01101011 | rr(d, s) | ib:s8=c ; rex(1, d, 0, s) | 01101001 | rr(d, s) | iv:s32=c }" "asm"="imulq ${c}, {s}, {d}" "asmonly" {
  ret void
}

define void @IMUL32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 10101111 | rr(d, s)" "asm"="imull {s}, {d}" "asmonly" {
  ret void
}

define void @ImUL32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10101111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="imull {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @IxUL32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10101111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imull {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @IpUL32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10101111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="imull {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL32rri(i64 "reg"="r32" %d, i64 "reg"="r32" %s, i64 "imm" %c) "enc"="{ rex(0, d, 0, s) | 01101011 | rr(d, s) | ib:s8=c ; rex(0, d, 0, s) | 01101001 | rr(d, s) | iv:s32=c }" "asm"="imull ${c}, {s}, {d}" "asmonly" {
  ret void
}

define void @IMUL16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 10101111 | rr(d, s)" "asm"="imulw {s}, {d}" "asmonly" {
  ret void
}

define void @ImUL16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 10101111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="imulw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @IxUL16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 10101111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="imulw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @IpUL16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 10101111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="imulw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @IMUL16rri(i64 "reg"="r16" %d, i64 "reg"="r16" %s, i64 "imm" %c) "enc"="{ 01100110 | rex(0, d, 0, s) | 01101011 | rr(d, s) | ib:s8=c ; 01100110 | rex(0, d, 0, s) | 01101001 | rr(d, s) | iv:s16=c }" "asm"="imulw ${c}, {s}, {d}" "asmonly" {
  ret void
}

define void @CQTO() "enc"="01001000 | 10011001" "asm"="cqto" "asmonly" {
  ret void
}

define void @CLTD() "enc"="10011001" "asm"="cltd" "asmonly" {
  ret void
}

define void @CLTQ() "enc"="01001000 | 10011000" "asm"="cltq" "asmonly" {
  ret void
}

define void @CWTL() "enc"="10011000" "asm"="cwtl" "asmonly" {
  ret void
}

define void @ROL64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 0, 0, d) | 11010001 | rr(0, d) | z:0=n-1 ; rex(1, 0, 0, d) | 11000001 | rr(0, d) | ib:8=n }" "asm"="rolq ${n}, {d}" "asmonly" {
  ret void
}

define void @ROL64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 0, 0, d) | 11010011 | rr(0, d)" "asm"="rolq %cl, {d}" "asmonly" {
  ret void
}

define void @ROL64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 0, 4, m.base) | 11010001 | rm(0, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 0, 4, m.base) | 11000001 | rm(0, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rolq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 11010001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 0, m.index, m.base) | 11000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rolq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 0, 0, 0) | 11010001 | rm(0, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 0, 0, 0) | 11000001 | rm(0, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rolq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 0, 4, m.base) | 11010011 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="rolq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 0, m.index, m.base) | 11010011 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rolq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL64pCL(ptr "sym" %m.sym) "enc"="rex(1, 0, 0, 0) | 11010011 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="rolq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 0, 0, d) | 11010001 | rr(0, d) | z:0=n-1 ; rex(0, 0, 0, d) | 11000001 | rr(0, d) | ib:8=n }" "asm"="roll ${n}, {d}" "asmonly" {
  ret void
}

define void @ROL32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 0, 0, d) | 11010011 | rr(0, d)" "asm"="roll %cl, {d}" "asmonly" {
  ret void
}

define void @ROL32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 0, 4, m.base) | 11010001 | rm(0, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 0, 4, m.base) | 11000001 | rm(0, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="roll ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11010001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 0, m.index, m.base) | 11000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="roll ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 0, 0, 0) | 11010001 | rm(0, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 0, 0, 0) | 11000001 | rm(0, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="roll ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 11010011 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="roll %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11010011 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="roll %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL32pCL(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 11010011 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="roll %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 0, 0, d) | 11010001 | rr(0, d) | z:0=n-1 ; 01100110 | rex(0, 0, 0, d) | 11000001 | rr(0, d) | ib:8=n }" "asm"="rolw ${n}, {d}" "asmonly" {
  ret void
}

define void @ROL16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 0, 0, d) | 11010011 | rr(0, d)" "asm"="rolw %cl, {d}" "asmonly" {
  ret void
}

define void @ROL16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 0, 4, m.base) | 11010001 | rm(0, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 0, 4, m.base) | 11000001 | rm(0, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rolw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11010001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11000001 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rolw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 0, 0, 0) | 11010001 | rm(0, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 0, 0, 0) | 11000001 | rm(0, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rolw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 0, 4, m.base) | 11010011 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="rolw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 0, m.index, m.base) | 11010011 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rolw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 0, 0, 0) | 11010011 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="rolw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(0, d) | z:0=n-1 ; { if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(0, d) | ib:8=n }" "asm"="rolb ${n}, {d}" "asmonly" {
  ret void
}

define void @ROL8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(0, d)" "asm"="rolb %cl, {d}" "asmonly" {
  ret void
}

define void @ROL8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 0, 4, m.base) | 11010000 | rm(0, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 0, 4, m.base) | 11000000 | rm(0, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rolb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11010000 | rm(0, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 0, m.index, m.base) | 11000000 | rm(0, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rolb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 0, 0, 0) | 11010000 | rm(0, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 0, 0, 0) | 11000000 | rm(0, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rolb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROL8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 11010010 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="rolb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROL8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 11010010 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rolb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROL8pCL(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 11010010 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="rolb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 1, 0, d) | 11010001 | rr(1, d) | z:0=n-1 ; rex(1, 1, 0, d) | 11000001 | rr(1, d) | ib:8=n }" "asm"="rorq ${n}, {d}" "asmonly" {
  ret void
}

define void @ROR64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 1, 0, d) | 11010011 | rr(1, d)" "asm"="rorq %cl, {d}" "asmonly" {
  ret void
}

define void @ROR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 1, 4, m.base) | 11010001 | rm(1, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 1, 4, m.base) | 11000001 | rm(1, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rorq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 1, m.index, m.base) | 11010001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 1, m.index, m.base) | 11000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rorq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 1, 0, 0) | 11010001 | rm(1, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 1, 0, 0) | 11000001 | rm(1, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rorq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 1, 4, m.base) | 11010011 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="rorq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 1, m.index, m.base) | 11010011 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rorq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR64pCL(ptr "sym" %m.sym) "enc"="rex(1, 1, 0, 0) | 11010011 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="rorq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 1, 0, d) | 11010001 | rr(1, d) | z:0=n-1 ; rex(0, 1, 0, d) | 11000001 | rr(1, d) | ib:8=n }" "asm"="rorl ${n}, {d}" "asmonly" {
  ret void
}

define void @ROR32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 1, 0, d) | 11010011 | rr(1, d)" "asm"="rorl %cl, {d}" "asmonly" {
  ret void
}

define void @ROR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 1, 4, m.base) | 11010001 | rm(1, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 1, 4, m.base) | 11000001 | rm(1, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rorl ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11010001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 1, m.index, m.base) | 11000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rorl ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 1, 0, 0) | 11010001 | rm(1, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 1, 0, 0) | 11000001 | rm(1, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rorl ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 1, 4, m.base) | 11010011 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="rorl %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11010011 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rorl %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR32pCL(ptr "sym" %m.sym) "enc"="rex(0, 1, 0, 0) | 11010011 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="rorl %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 1, 0, d) | 11010001 | rr(1, d) | z:0=n-1 ; 01100110 | rex(0, 1, 0, d) | 11000001 | rr(1, d) | ib:8=n }" "asm"="rorw ${n}, {d}" "asmonly" {
  ret void
}

define void @ROR16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 1, 0, d) | 11010011 | rr(1, d)" "asm"="rorw %cl, {d}" "asmonly" {
  ret void
}

define void @ROR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 1, 4, m.base) | 11010001 | rm(1, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 1, 4, m.base) | 11000001 | rm(1, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rorw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 11010001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 11000001 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rorw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 1, 0, 0) | 11010001 | rm(1, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 1, 0, 0) | 11000001 | rm(1, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rorw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 1, 4, m.base) | 11010011 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="rorw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 1, m.index, m.base) | 11010011 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rorw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 1, 0, 0) | 11010011 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="rorw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 1, 0, d) ; 0100 0 R:1=(1)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(1, d) | z:0=n-1 ; { if(d<4) rex(0, 1, 0, d) ; 0100 0 R:1=(1)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(1, d) | ib:8=n }" "asm"="rorb ${n}, {d}" "asmonly" {
  ret void
}

define void @ROR8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 1, 0, d) ; 0100 0 R:1=(1)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(1, d)" "asm"="rorb %cl, {d}" "asmonly" {
  ret void
}

define void @ROR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 1, 4, m.base) | 11010000 | rm(1, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 1, 4, m.base) | 11000000 | rm(1, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rorb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11010000 | rm(1, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 1, m.index, m.base) | 11000000 | rm(1, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rorb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 1, 0, 0) | 11010000 | rm(1, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 1, 0, 0) | 11000000 | rm(1, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rorb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @ROR8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 1, 4, m.base) | 11010010 | rm(1, m.base, 4, 1, m.disp, 0)" "asm"="rorb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @ROR8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 1, m.index, m.base) | 11010010 | rm(1, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rorb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @ROR8pCL(ptr "sym" %m.sym) "enc"="rex(0, 1, 0, 0) | 11010010 | rm(1, 16, 4, 1, 0, m.sym)" "asm"="rorb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 2, 0, d) | 11010001 | rr(2, d) | z:0=n-1 ; rex(1, 2, 0, d) | 11000001 | rr(2, d) | ib:8=n }" "asm"="rclq ${n}, {d}" "asmonly" {
  ret void
}

define void @RCL64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 2, 0, d) | 11010011 | rr(2, d)" "asm"="rclq %cl, {d}" "asmonly" {
  ret void
}

define void @RCL64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 2, 4, m.base) | 11010001 | rm(2, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 2, 4, m.base) | 11000001 | rm(2, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rclq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 2, m.index, m.base) | 11010001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 2, m.index, m.base) | 11000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rclq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 2, 0, 0) | 11010001 | rm(2, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 2, 0, 0) | 11000001 | rm(2, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rclq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 2, 4, m.base) | 11010011 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="rclq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 2, m.index, m.base) | 11010011 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rclq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL64pCL(ptr "sym" %m.sym) "enc"="rex(1, 2, 0, 0) | 11010011 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="rclq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 2, 0, d) | 11010001 | rr(2, d) | z:0=n-1 ; rex(0, 2, 0, d) | 11000001 | rr(2, d) | ib:8=n }" "asm"="rcll ${n}, {d}" "asmonly" {
  ret void
}

define void @RCL32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 2, 0, d) | 11010011 | rr(2, d)" "asm"="rcll %cl, {d}" "asmonly" {
  ret void
}

define void @RCL32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 2, 4, m.base) | 11010001 | rm(2, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 2, 4, m.base) | 11000001 | rm(2, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rcll ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11010001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 2, m.index, m.base) | 11000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rcll ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 2, 0, 0) | 11010001 | rm(2, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 2, 0, 0) | 11000001 | rm(2, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rcll ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 2, 4, m.base) | 11010011 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="rcll %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11010011 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rcll %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL32pCL(ptr "sym" %m.sym) "enc"="rex(0, 2, 0, 0) | 11010011 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="rcll %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 2, 0, d) | 11010001 | rr(2, d) | z:0=n-1 ; 01100110 | rex(0, 2, 0, d) | 11000001 | rr(2, d) | ib:8=n }" "asm"="rclw ${n}, {d}" "asmonly" {
  ret void
}

define void @RCL16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 2, 0, d) | 11010011 | rr(2, d)" "asm"="rclw %cl, {d}" "asmonly" {
  ret void
}

define void @RCL16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 2, 4, m.base) | 11010001 | rm(2, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 2, 4, m.base) | 11000001 | rm(2, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rclw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 11010001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 11000001 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rclw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 2, 0, 0) | 11010001 | rm(2, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 2, 0, 0) | 11000001 | rm(2, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rclw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 2, 4, m.base) | 11010011 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="rclw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 2, m.index, m.base) | 11010011 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rclw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 2, 0, 0) | 11010011 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="rclw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 2, 0, d) ; 0100 0 R:1=(2)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(2, d) | z:0=n-1 ; { if(d<4) rex(0, 2, 0, d) ; 0100 0 R:1=(2)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(2, d) | ib:8=n }" "asm"="rclb ${n}, {d}" "asmonly" {
  ret void
}

define void @RCL8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 2, 0, d) ; 0100 0 R:1=(2)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(2, d)" "asm"="rclb %cl, {d}" "asmonly" {
  ret void
}

define void @RCL8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 2, 4, m.base) | 11010000 | rm(2, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 2, 4, m.base) | 11000000 | rm(2, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rclb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11010000 | rm(2, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 2, m.index, m.base) | 11000000 | rm(2, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rclb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 2, 0, 0) | 11010000 | rm(2, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 2, 0, 0) | 11000000 | rm(2, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rclb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCL8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 2, 4, m.base) | 11010010 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="rclb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCL8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11010010 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rclb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCL8pCL(ptr "sym" %m.sym) "enc"="rex(0, 2, 0, 0) | 11010010 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="rclb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 3, 0, d) | 11010001 | rr(3, d) | z:0=n-1 ; rex(1, 3, 0, d) | 11000001 | rr(3, d) | ib:8=n }" "asm"="rcrq ${n}, {d}" "asmonly" {
  ret void
}

define void @RCR64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 3, 0, d) | 11010011 | rr(3, d)" "asm"="rcrq %cl, {d}" "asmonly" {
  ret void
}

define void @RCR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 3, 4, m.base) | 11010001 | rm(3, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 3, 4, m.base) | 11000001 | rm(3, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rcrq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 3, m.index, m.base) | 11010001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 3, m.index, m.base) | 11000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rcrq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 3, 0, 0) | 11010001 | rm(3, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 3, 0, 0) | 11000001 | rm(3, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rcrq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 3, 4, m.base) | 11010011 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="rcrq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 3, m.index, m.base) | 11010011 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rcrq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR64pCL(ptr "sym" %m.sym) "enc"="rex(1, 3, 0, 0) | 11010011 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="rcrq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 3, 0, d) | 11010001 | rr(3, d) | z:0=n-1 ; rex(0, 3, 0, d) | 11000001 | rr(3, d) | ib:8=n }" "asm"="rcrl ${n}, {d}" "asmonly" {
  ret void
}

define void @RCR32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 3, 0, d) | 11010011 | rr(3, d)" "asm"="rcrl %cl, {d}" "asmonly" {
  ret void
}

define void @RCR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 3, 4, m.base) | 11010001 | rm(3, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 3, 4, m.base) | 11000001 | rm(3, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rcrl ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11010001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 3, m.index, m.base) | 11000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rcrl ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 3, 0, 0) | 11010001 | rm(3, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 3, 0, 0) | 11000001 | rm(3, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rcrl ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 3, 4, m.base) | 11010011 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="rcrl %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11010011 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rcrl %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR32pCL(ptr "sym" %m.sym) "enc"="rex(0, 3, 0, 0) | 11010011 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="rcrl %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 3, 0, d) | 11010001 | rr(3, d) | z:0=n-1 ; 01100110 | rex(0, 3, 0, d) | 11000001 | rr(3, d) | ib:8=n }" "asm"="rcrw ${n}, {d}" "asmonly" {
  ret void
}

define void @RCR16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 3, 0, d) | 11010011 | rr(3, d)" "asm"="rcrw %cl, {d}" "asmonly" {
  ret void
}

define void @RCR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 3, 4, m.base) | 11010001 | rm(3, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 3, 4, m.base) | 11000001 | rm(3, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rcrw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 11010001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 11000001 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rcrw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 3, 0, 0) | 11010001 | rm(3, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 3, 0, 0) | 11000001 | rm(3, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rcrw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 3, 4, m.base) | 11010011 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="rcrw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 3, m.index, m.base) | 11010011 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rcrw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 3, 0, 0) | 11010011 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="rcrw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 3, 0, d) ; 0100 0 R:1=(3)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(3, d) | z:0=n-1 ; { if(d<4) rex(0, 3, 0, d) ; 0100 0 R:1=(3)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(3, d) | ib:8=n }" "asm"="rcrb ${n}, {d}" "asmonly" {
  ret void
}

define void @RCR8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 3, 0, d) ; 0100 0 R:1=(3)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(3, d)" "asm"="rcrb %cl, {d}" "asmonly" {
  ret void
}

define void @RCR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 3, 4, m.base) | 11010000 | rm(3, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 3, 4, m.base) | 11000000 | rm(3, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="rcrb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11010000 | rm(3, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 3, m.index, m.base) | 11000000 | rm(3, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="rcrb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 3, 0, 0) | 11010000 | rm(3, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 3, 0, 0) | 11000000 | rm(3, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="rcrb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RCR8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 3, 4, m.base) | 11010010 | rm(3, m.base, 4, 1, m.disp, 0)" "asm"="rcrb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @RCR8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 3, m.index, m.base) | 11010010 | rm(3, m.base, m.index, m.scale, m.disp, 0) }" "asm"="rcrb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @RCR8pCL(ptr "sym" %m.sym) "enc"="rex(0, 3, 0, 0) | 11010010 | rm(3, 16, 4, 1, 0, m.sym)" "asm"="rcrb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 4, 0, d) | 11010001 | rr(4, d) | z:0=n-1 ; rex(1, 4, 0, d) | 11000001 | rr(4, d) | ib:8=n }" "asm"="shlq ${n}, {d}" "asmonly" {
  ret void
}

define void @SHL64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 4, 0, d) | 11010011 | rr(4, d)" "asm"="shlq %cl, {d}" "asmonly" {
  ret void
}

define void @SHL64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 4, 4, m.base) | 11010001 | rm(4, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 4, 4, m.base) | 11000001 | rm(4, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shlq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 4, m.index, m.base) | 11010001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 4, m.index, m.base) | 11000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shlq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 4, 0, 0) | 11010001 | rm(4, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 4, 0, 0) | 11000001 | rm(4, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shlq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 4, 4, m.base) | 11010011 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="shlq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 4, m.index, m.base) | 11010011 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shlq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL64pCL(ptr "sym" %m.sym) "enc"="rex(1, 4, 0, 0) | 11010011 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="shlq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 4, 0, d) | 11010001 | rr(4, d) | z:0=n-1 ; rex(0, 4, 0, d) | 11000001 | rr(4, d) | ib:8=n }" "asm"="shll ${n}, {d}" "asmonly" {
  ret void
}

define void @SHL32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 4, 0, d) | 11010011 | rr(4, d)" "asm"="shll %cl, {d}" "asmonly" {
  ret void
}

define void @SHL32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 4, 4, m.base) | 11010001 | rm(4, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 4, 4, m.base) | 11000001 | rm(4, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shll ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11010001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 4, m.index, m.base) | 11000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shll ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 4, 0, 0) | 11010001 | rm(4, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 4, 0, 0) | 11000001 | rm(4, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shll ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 4, 4, m.base) | 11010011 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="shll %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11010011 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shll %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL32pCL(ptr "sym" %m.sym) "enc"="rex(0, 4, 0, 0) | 11010011 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="shll %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 4, 0, d) | 11010001 | rr(4, d) | z:0=n-1 ; 01100110 | rex(0, 4, 0, d) | 11000001 | rr(4, d) | ib:8=n }" "asm"="shlw ${n}, {d}" "asmonly" {
  ret void
}

define void @SHL16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 4, 0, d) | 11010011 | rr(4, d)" "asm"="shlw %cl, {d}" "asmonly" {
  ret void
}

define void @SHL16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 4, 4, m.base) | 11010001 | rm(4, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 4, 4, m.base) | 11000001 | rm(4, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shlw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 11010001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 11000001 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shlw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 4, 0, 0) | 11010001 | rm(4, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 4, 0, 0) | 11000001 | rm(4, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shlw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 4, 4, m.base) | 11010011 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="shlw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 4, m.index, m.base) | 11010011 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shlw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 4, 0, 0) | 11010011 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="shlw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 4, 0, d) ; 0100 0 R:1=(4)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(4, d) | z:0=n-1 ; { if(d<4) rex(0, 4, 0, d) ; 0100 0 R:1=(4)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(4, d) | ib:8=n }" "asm"="shlb ${n}, {d}" "asmonly" {
  ret void
}

define void @SHL8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 4, 0, d) ; 0100 0 R:1=(4)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(4, d)" "asm"="shlb %cl, {d}" "asmonly" {
  ret void
}

define void @SHL8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 4, 4, m.base) | 11010000 | rm(4, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 4, 4, m.base) | 11000000 | rm(4, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shlb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11010000 | rm(4, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 4, m.index, m.base) | 11000000 | rm(4, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shlb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 4, 0, 0) | 11010000 | rm(4, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 4, 0, 0) | 11000000 | rm(4, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shlb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHL8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 4, 4, m.base) | 11010010 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="shlb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHL8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11010010 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shlb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHL8pCL(ptr "sym" %m.sym) "enc"="rex(0, 4, 0, 0) | 11010010 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="shlb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 5, 0, d) | 11010001 | rr(5, d) | z:0=n-1 ; rex(1, 5, 0, d) | 11000001 | rr(5, d) | ib:8=n }" "asm"="shrq ${n}, {d}" "asmonly" {
  ret void
}

define void @SHR64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 5, 0, d) | 11010011 | rr(5, d)" "asm"="shrq %cl, {d}" "asmonly" {
  ret void
}

define void @SHR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 5, 4, m.base) | 11010001 | rm(5, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 5, 4, m.base) | 11000001 | rm(5, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shrq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 5, m.index, m.base) | 11010001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 5, m.index, m.base) | 11000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shrq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 5, 0, 0) | 11010001 | rm(5, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 5, 0, 0) | 11000001 | rm(5, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shrq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 5, 4, m.base) | 11010011 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="shrq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 5, m.index, m.base) | 11010011 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shrq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR64pCL(ptr "sym" %m.sym) "enc"="rex(1, 5, 0, 0) | 11010011 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="shrq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 5, 0, d) | 11010001 | rr(5, d) | z:0=n-1 ; rex(0, 5, 0, d) | 11000001 | rr(5, d) | ib:8=n }" "asm"="shrl ${n}, {d}" "asmonly" {
  ret void
}

define void @SHR32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 5, 0, d) | 11010011 | rr(5, d)" "asm"="shrl %cl, {d}" "asmonly" {
  ret void
}

define void @SHR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 5, 4, m.base) | 11010001 | rm(5, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 5, 4, m.base) | 11000001 | rm(5, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shrl ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11010001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 5, m.index, m.base) | 11000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shrl ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 5, 0, 0) | 11010001 | rm(5, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 5, 0, 0) | 11000001 | rm(5, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shrl ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 5, 4, m.base) | 11010011 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="shrl %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11010011 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shrl %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR32pCL(ptr "sym" %m.sym) "enc"="rex(0, 5, 0, 0) | 11010011 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="shrl %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 5, 0, d) | 11010001 | rr(5, d) | z:0=n-1 ; 01100110 | rex(0, 5, 0, d) | 11000001 | rr(5, d) | ib:8=n }" "asm"="shrw ${n}, {d}" "asmonly" {
  ret void
}

define void @SHR16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 5, 0, d) | 11010011 | rr(5, d)" "asm"="shrw %cl, {d}" "asmonly" {
  ret void
}

define void @SHR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 5, 4, m.base) | 11010001 | rm(5, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 5, 4, m.base) | 11000001 | rm(5, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shrw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 11010001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 11000001 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shrw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 5, 0, 0) | 11010001 | rm(5, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 5, 0, 0) | 11000001 | rm(5, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shrw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 5, 4, m.base) | 11010011 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="shrw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 5, m.index, m.base) | 11010011 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shrw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 5, 0, 0) | 11010011 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="shrw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 5, 0, d) ; 0100 0 R:1=(5)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(5, d) | z:0=n-1 ; { if(d<4) rex(0, 5, 0, d) ; 0100 0 R:1=(5)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(5, d) | ib:8=n }" "asm"="shrb ${n}, {d}" "asmonly" {
  ret void
}

define void @SHR8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 5, 0, d) ; 0100 0 R:1=(5)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(5, d)" "asm"="shrb %cl, {d}" "asmonly" {
  ret void
}

define void @SHR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 5, 4, m.base) | 11010000 | rm(5, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 5, 4, m.base) | 11000000 | rm(5, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="shrb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11010000 | rm(5, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 5, m.index, m.base) | 11000000 | rm(5, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="shrb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 5, 0, 0) | 11010000 | rm(5, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 5, 0, 0) | 11000000 | rm(5, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="shrb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SHR8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 5, 4, m.base) | 11010010 | rm(5, m.base, 4, 1, m.disp, 0)" "asm"="shrb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SHR8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 5, m.index, m.base) | 11010010 | rm(5, m.base, m.index, m.scale, m.disp, 0) }" "asm"="shrb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SHR8pCL(ptr "sym" %m.sym) "enc"="rex(0, 5, 0, 0) | 11010010 | rm(5, 16, 4, 1, 0, m.sym)" "asm"="shrb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR64ri(i64 "reg"="r64" %d, i64 "imm" %n) "enc"="{ rex(1, 7, 0, d) | 11010001 | rr(7, d) | z:0=n-1 ; rex(1, 7, 0, d) | 11000001 | rr(7, d) | ib:8=n }" "asm"="sarq ${n}, {d}" "asmonly" {
  ret void
}

define void @SAR64rCL(i64 "reg"="r64" %d) "enc"="rex(1, 7, 0, d) | 11010011 | rr(7, d)" "asm"="sarq %cl, {d}" "asmonly" {
  ret void
}

define void @SAR64mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(1, 7, 4, m.base) | 11010001 | rm(7, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(1, 7, 4, m.base) | 11000001 | rm(7, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="sarq ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR64xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(1, 7, m.index, m.base) | 11010001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(1, 7, m.index, m.base) | 11000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="sarq ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR64pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(1, 7, 0, 0) | 11010001 | rm(7, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(1, 7, 0, 0) | 11000001 | rm(7, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="sarq ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR64mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, 7, 4, m.base) | 11010011 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="sarq %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR64xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, 7, m.index, m.base) | 11010011 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sarq %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR64pCL(ptr "sym" %m.sym) "enc"="rex(1, 7, 0, 0) | 11010011 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="sarq %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR32ri(i64 "reg"="r32" %d, i64 "imm" %n) "enc"="{ rex(0, 7, 0, d) | 11010001 | rr(7, d) | z:0=n-1 ; rex(0, 7, 0, d) | 11000001 | rr(7, d) | ib:8=n }" "asm"="sarl ${n}, {d}" "asmonly" {
  ret void
}

define void @SAR32rCL(i64 "reg"="r32" %d) "enc"="rex(0, 7, 0, d) | 11010011 | rr(7, d)" "asm"="sarl %cl, {d}" "asmonly" {
  ret void
}

define void @SAR32mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 7, 4, m.base) | 11010001 | rm(7, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 7, 4, m.base) | 11000001 | rm(7, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="sarl ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR32xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11010001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 7, m.index, m.base) | 11000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="sarl ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR32pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 7, 0, 0) | 11010001 | rm(7, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 7, 0, 0) | 11000001 | rm(7, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="sarl ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR32mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 7, 4, m.base) | 11010011 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="sarl %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR32xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11010011 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sarl %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR32pCL(ptr "sym" %m.sym) "enc"="rex(0, 7, 0, 0) | 11010011 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="sarl %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR16ri(i64 "reg"="r16" %d, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 7, 0, d) | 11010001 | rr(7, d) | z:0=n-1 ; 01100110 | rex(0, 7, 0, d) | 11000001 | rr(7, d) | ib:8=n }" "asm"="sarw ${n}, {d}" "asmonly" {
  ret void
}

define void @SAR16rCL(i64 "reg"="r16" %d) "enc"="01100110 | rex(0, 7, 0, d) | 11010011 | rr(7, d)" "asm"="sarw %cl, {d}" "asmonly" {
  ret void
}

define void @SAR16mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 7, 4, m.base) | 11010001 | rm(7, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; 01100110 | rex(0, 7, 4, m.base) | 11000001 | rm(7, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="sarw ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR16xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 11010001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 11000001 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="sarw ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR16pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ 01100110 | rex(0, 7, 0, 0) | 11010001 | rm(7, 16, 4, 1, 0, m.sym) | z:0=n-1 ; 01100110 | rex(0, 7, 0, 0) | 11000001 | rm(7, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="sarw ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR16mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, 7, 4, m.base) | 11010011 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="sarw %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR16xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, 7, m.index, m.base) | 11010011 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sarw %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR16pCL(ptr "sym" %m.sym) "enc"="01100110 | rex(0, 7, 0, 0) | 11010011 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="sarw %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR8ri(i64 "reg"="r8" %d, i64 "imm" %n) "enc"="{ { if(d<4) rex(0, 7, 0, d) ; 0100 0 R:1=(7)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010000 | rr(7, d) | z:0=n-1 ; { if(d<4) rex(0, 7, 0, d) ; 0100 0 R:1=(7)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11000000 | rr(7, d) | ib:8=n }" "asm"="sarb ${n}, {d}" "asmonly" {
  ret void
}

define void @SAR8rCL(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 7, 0, d) ; 0100 0 R:1=(7)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 11010010 | rr(7, d)" "asm"="sarb %cl, {d}" "asmonly" {
  ret void
}

define void @SAR8mi(i64 "reg"="r64" %m.base, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ rex(0, 7, 4, m.base) | 11010000 | rm(7, m.base, 4, 1, m.disp, 0) | z:0=n-1 ; rex(0, 7, 4, m.base) | 11000000 | rm(7, m.base, 4, 1, m.disp, 0) | ib:8=n }" "asm"="sarb ${n}, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR8xi(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp, i64 "imm" %n) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11010000 | rm(7, m.base, m.index, m.scale, m.disp, 0) | z:0=n-1 ; if(m.index!=4) rex(0, 7, m.index, m.base) | 11000000 | rm(7, m.base, m.index, m.scale, m.disp, 0) | ib:8=n }" "asm"="sarb ${n}, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR8pi(ptr "sym" %m.sym, i64 "imm" %n) "enc"="{ rex(0, 7, 0, 0) | 11010000 | rm(7, 16, 4, 1, 0, m.sym) | z:0=n-1 ; rex(0, 7, 0, 0) | 11000000 | rm(7, 16, 4, 1, 0, m.sym) | ib:8=n }" "asm"="sarb ${n}, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SAR8mCL(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 7, 4, m.base) | 11010010 | rm(7, m.base, 4, 1, m.disp, 0)" "asm"="sarb %cl, {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SAR8xCL(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 7, m.index, m.base) | 11010010 | rm(7, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sarb %cl, {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SAR8pCL(ptr "sym" %m.sym) "enc"="rex(0, 7, 0, 0) | 11010010 | rm(7, 16, 4, 1, 0, m.sym)" "asm"="sarb %cl, {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @SETOr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010000 | rr(0, d)" "asm"="seto {d}" "asmonly" {
  ret void
}

define void @SETOm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010000 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="seto {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETOx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010000 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="seto {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETOp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010000 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="seto {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVO64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000000 | rr(d, s)" "asm"="cmovoq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVO64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovoq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVO64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovoq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVO64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovoq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVO32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000000 | rr(d, s)" "asm"="cmovol {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVO32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovol {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVO32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovol {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVO32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovol {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVO16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000000 | rr(d, s)" "asm"="cmovow {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVO16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovow {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVO16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovow {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVO16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovow {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JO(ptr "label" %dest) "enc"="{ 01110000 | rel:s8=dest-end ; 00001111 | 10000000 | rel:s32=dest-end }" "asm"="jo {dest}" "asmonly" {
  ret void
}

define void @SETNOr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010001 | rr(0, d)" "asm"="setno {d}" "asmonly" {
  ret void
}

define void @SETNOm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010001 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setno {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETNOx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010001 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setno {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETNOp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010001 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setno {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNO64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000001 | rr(d, s)" "asm"="cmovnoq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNO64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnoq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNO64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnoq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNO64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnoq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNO32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000001 | rr(d, s)" "asm"="cmovnol {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNO32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnol {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNO32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnol {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNO32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnol {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNO16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000001 | rr(d, s)" "asm"="cmovnow {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNO16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnow {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNO16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnow {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNO16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnow {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JNO(ptr "label" %dest) "enc"="{ 01110001 | rel:s8=dest-end ; 00001111 | 10000001 | rel:s32=dest-end }" "asm"="jno {dest}" "asmonly" {
  ret void
}

define void @SETBr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010010 | rr(0, d)" "asm"="setb {d}" "asmonly" {
  ret void
}

define void @SETBm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010010 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setb {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETBx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010010 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setb {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETBp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010010 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setb {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVB64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000010 | rr(d, s)" "asm"="cmovbq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVB64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVB64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVB64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVB32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000010 | rr(d, s)" "asm"="cmovbl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVB32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVB32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVB32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVB16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000010 | rr(d, s)" "asm"="cmovbw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVB16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVB16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVB16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JB(ptr "label" %dest) "enc"="{ 01110010 | rel:s8=dest-end ; 00001111 | 10000010 | rel:s32=dest-end }" "asm"="jb {dest}" "asmonly" {
  ret void
}

define void @SETAEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010011 | rr(0, d)" "asm"="setae {d}" "asmonly" {
  ret void
}

define void @SETAEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010011 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setae {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETAEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010011 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setae {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETAEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010011 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setae {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVAE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000011 | rr(d, s)" "asm"="cmovaeq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVAE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovaeq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVAE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovaeq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVAE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovaeq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVAE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000011 | rr(d, s)" "asm"="cmovael {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVAE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovael {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVAE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovael {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVAE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovael {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVAE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000011 | rr(d, s)" "asm"="cmovaew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVAE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovaew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVAE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovaew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVAE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovaew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JAE(ptr "label" %dest) "enc"="{ 01110011 | rel:s8=dest-end ; 00001111 | 10000011 | rel:s32=dest-end }" "asm"="jae {dest}" "asmonly" {
  ret void
}

define void @SETEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010100 | rr(0, d)" "asm"="sete {d}" "asmonly" {
  ret void
}

define void @SETEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010100 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="sete {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010100 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sete {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010100 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="sete {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000100 | rr(d, s)" "asm"="cmoveq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmoveq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmoveq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmoveq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000100 | rr(d, s)" "asm"="cmovel {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovel {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovel {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovel {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000100 | rr(d, s)" "asm"="cmovew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JE(ptr "label" %dest) "enc"="{ 01110100 | rel:s8=dest-end ; 00001111 | 10000100 | rel:s32=dest-end }" "asm"="je {dest}" "asmonly" {
  ret void
}

define void @SETNEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010101 | rr(0, d)" "asm"="setne {d}" "asmonly" {
  ret void
}

define void @SETNEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010101 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setne {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETNEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010101 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setne {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETNEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010101 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setne {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000101 | rr(d, s)" "asm"="cmovneq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovneq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovneq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovneq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000101 | rr(d, s)" "asm"="cmovnel {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnel {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnel {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnel {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000101 | rr(d, s)" "asm"="cmovnew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JNE(ptr "label" %dest) "enc"="{ 01110101 | rel:s8=dest-end ; 00001111 | 10000101 | rel:s32=dest-end }" "asm"="jne {dest}" "asmonly" {
  ret void
}

define void @SETBEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010110 | rr(0, d)" "asm"="setbe {d}" "asmonly" {
  ret void
}

define void @SETBEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010110 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setbe {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETBEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010110 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setbe {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETBEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010110 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setbe {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVBE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000110 | rr(d, s)" "asm"="cmovbeq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVBE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbeq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVBE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbeq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVBE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbeq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVBE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000110 | rr(d, s)" "asm"="cmovbel {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVBE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbel {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVBE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbel {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVBE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbel {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVBE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000110 | rr(d, s)" "asm"="cmovbew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVBE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovbew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVBE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovbew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVBE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovbew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JBE(ptr "label" %dest) "enc"="{ 01110110 | rel:s8=dest-end ; 00001111 | 10000110 | rel:s32=dest-end }" "asm"="jbe {dest}" "asmonly" {
  ret void
}

define void @SETAr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10010111 | rr(0, d)" "asm"="seta {d}" "asmonly" {
  ret void
}

define void @SETAm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10010111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="seta {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETAx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10010111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="seta {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETAp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10010111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="seta {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVA64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01000111 | rr(d, s)" "asm"="cmovaq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVA64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01000111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovaq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVA64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01000111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovaq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVA64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01000111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovaq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVA32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01000111 | rr(d, s)" "asm"="cmoval {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVA32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01000111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmoval {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVA32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01000111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmoval {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVA32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01000111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmoval {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVA16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01000111 | rr(d, s)" "asm"="cmovaw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVA16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01000111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovaw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVA16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01000111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovaw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVA16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01000111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovaw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JA(ptr "label" %dest) "enc"="{ 01110111 | rel:s8=dest-end ; 00001111 | 10000111 | rel:s32=dest-end }" "asm"="ja {dest}" "asmonly" {
  ret void
}

define void @SETSr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011000 | rr(0, d)" "asm"="sets {d}" "asmonly" {
  ret void
}

define void @SETSm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011000 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="sets {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETSx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011000 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="sets {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETSp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011000 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="sets {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVS64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001000 | rr(d, s)" "asm"="cmovsq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVS64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovsq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVS64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovsq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVS64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovsq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVS32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001000 | rr(d, s)" "asm"="cmovsl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVS32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovsl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVS32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovsl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVS32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovsl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVS16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001000 | rr(d, s)" "asm"="cmovsw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVS16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovsw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVS16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovsw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVS16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovsw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JS(ptr "label" %dest) "enc"="{ 01111000 | rel:s8=dest-end ; 00001111 | 10001000 | rel:s32=dest-end }" "asm"="js {dest}" "asmonly" {
  ret void
}

define void @SETNSr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011001 | rr(0, d)" "asm"="setns {d}" "asmonly" {
  ret void
}

define void @SETNSm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011001 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setns {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETNSx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011001 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setns {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETNSp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011001 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setns {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNS64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001001 | rr(d, s)" "asm"="cmovnsq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNS64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnsq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNS64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnsq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNS64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnsq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNS32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001001 | rr(d, s)" "asm"="cmovnsl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNS32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnsl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNS32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnsl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNS32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnsl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNS16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001001 | rr(d, s)" "asm"="cmovnsw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNS16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001001 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnsw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNS16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001001 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnsw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNS16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001001 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnsw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JNS(ptr "label" %dest) "enc"="{ 01111001 | rel:s8=dest-end ; 00001111 | 10001001 | rel:s32=dest-end }" "asm"="jns {dest}" "asmonly" {
  ret void
}

define void @SETPr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011010 | rr(0, d)" "asm"="setp {d}" "asmonly" {
  ret void
}

define void @SETPm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011010 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setp {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETPx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011010 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setp {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETPp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011010 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setp {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVP64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001010 | rr(d, s)" "asm"="cmovpq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVP64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovpq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVP64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovpq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVP64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovpq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVP32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001010 | rr(d, s)" "asm"="cmovpl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVP32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovpl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVP32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovpl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVP32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovpl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVP16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001010 | rr(d, s)" "asm"="cmovpw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVP16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001010 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovpw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVP16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001010 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovpw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVP16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001010 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovpw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JP(ptr "label" %dest) "enc"="{ 01111010 | rel:s8=dest-end ; 00001111 | 10001010 | rel:s32=dest-end }" "asm"="jp {dest}" "asmonly" {
  ret void
}

define void @SETNPr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011011 | rr(0, d)" "asm"="setnp {d}" "asmonly" {
  ret void
}

define void @SETNPm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011011 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setnp {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETNPx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011011 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setnp {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETNPp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011011 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setnp {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNP64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001011 | rr(d, s)" "asm"="cmovnpq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNP64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnpq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNP64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnpq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNP64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnpq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNP32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001011 | rr(d, s)" "asm"="cmovnpl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNP32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnpl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNP32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnpl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNP32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnpl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVNP16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001011 | rr(d, s)" "asm"="cmovnpw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVNP16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001011 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovnpw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVNP16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001011 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovnpw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVNP16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001011 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovnpw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JNP(ptr "label" %dest) "enc"="{ 01111011 | rel:s8=dest-end ; 00001111 | 10001011 | rel:s32=dest-end }" "asm"="jnp {dest}" "asmonly" {
  ret void
}

define void @SETLr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011100 | rr(0, d)" "asm"="setl {d}" "asmonly" {
  ret void
}

define void @SETLm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011100 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setl {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETLx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011100 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setl {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETLp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011100 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setl {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVL64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001100 | rr(d, s)" "asm"="cmovlq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVL64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovlq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVL64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovlq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVL64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovlq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVL32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001100 | rr(d, s)" "asm"="cmovll {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVL32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovll {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVL32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovll {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVL32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovll {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVL16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001100 | rr(d, s)" "asm"="cmovlw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVL16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovlw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVL16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovlw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVL16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovlw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JL(ptr "label" %dest) "enc"="{ 01111100 | rel:s8=dest-end ; 00001111 | 10001100 | rel:s32=dest-end }" "asm"="jl {dest}" "asmonly" {
  ret void
}

define void @SETGEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011101 | rr(0, d)" "asm"="setge {d}" "asmonly" {
  ret void
}

define void @SETGEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011101 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setge {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETGEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011101 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setge {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETGEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011101 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setge {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVGE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001101 | rr(d, s)" "asm"="cmovgeq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVGE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgeq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVGE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgeq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVGE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgeq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVGE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001101 | rr(d, s)" "asm"="cmovgel {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVGE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgel {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVGE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgel {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVGE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgel {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVGE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001101 | rr(d, s)" "asm"="cmovgew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVGE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVGE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVGE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JGE(ptr "label" %dest) "enc"="{ 01111101 | rel:s8=dest-end ; 00001111 | 10001101 | rel:s32=dest-end }" "asm"="jge {dest}" "asmonly" {
  ret void
}

define void @SETLEr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011110 | rr(0, d)" "asm"="setle {d}" "asmonly" {
  ret void
}

define void @SETLEm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011110 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setle {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETLEx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011110 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setle {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETLEp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011110 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setle {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVLE64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001110 | rr(d, s)" "asm"="cmovleq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVLE64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovleq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVLE64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovleq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVLE64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovleq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVLE32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001110 | rr(d, s)" "asm"="cmovlel {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVLE32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovlel {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVLE32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovlel {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVLE32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovlel {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVLE16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001110 | rr(d, s)" "asm"="cmovlew {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVLE16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001110 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovlew {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVLE16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001110 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovlew {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVLE16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001110 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovlew {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JLE(ptr "label" %dest) "enc"="{ 01111110 | rel:s8=dest-end ; 00001111 | 10001110 | rel:s32=dest-end }" "asm"="jle {dest}" "asmonly" {
  ret void
}

define void @SETGr(i64 "reg"="r8" %d) "enc"="{ if(d<4) rex(0, 0, 0, d) ; 0100 0 R:1=(0)>>3 X:1=(0)>>3 B:1=(d)>>3 } | 00001111 | 10011111 | rr(0, d)" "asm"="setg {d}" "asmonly" {
  ret void
}

define void @SETGm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 00001111 | 10011111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="setg {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @SETGx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 00001111 | 10011111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="setg {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @SETGp(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 00001111 | 10011111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="setg {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVG64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 01001111 | rr(d, s)" "asm"="cmovgq {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVG64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 01001111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVG64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 01001111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVG64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 01001111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVG32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 01001111 | rr(d, s)" "asm"="cmovgl {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVG32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 01001111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVG32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 01001111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVG32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 01001111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @CMOVG16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 01001111 | rr(d, s)" "asm"="cmovgw {s}, {d}" "asmonly" {
  ret void
}

define void @CmOVG16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 01001111 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="cmovgw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @CxOVG16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 01001111 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="cmovgw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @CpOVG16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 01001111 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="cmovgw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JG(ptr "label" %dest) "enc"="{ 01111111 | rel:s8=dest-end ; 00001111 | 10001111 | rel:s32=dest-end }" "asm"="jg {dest}" "asmonly" {
  ret void
}

define void @JMP(ptr "label" %dest) "enc"="{ 11101011 | rel:s8=dest-end ; 11101001 | rel:s32=dest-end }" "asm"="jmp {dest}" "asmonly" {
  ret void
}

define void @CALL(ptr "sym" %s) "enc"="11101000 | rel:s32=s-end" "asm"="callq {s}" "asmonly" "reloc"="plt32" {
  ret void
}

define void @JMPtail(ptr "sym" %s) "enc"="11101001 | rel:s32=s-end" "asm"="jmp {s}" "asmonly" "reloc"="plt32" "nodecode" {
  ret void
}

define void @CALLr(i64 "reg"="r64" %d) "enc"="rex(0, 2, 0, d) | 11111111 | rr(2, d)" "asm"="callq *{d}" "asmonly" {
  ret void
}

define void @JMPr(i64 "reg"="r64" %d) "enc"="rex(0, 4, 0, d) | 11111111 | rr(4, d)" "asm"="jmpq *{d}" "asmonly" {
  ret void
}

define void @CALLm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 2, 4, m.base) | 11111111 | rm(2, m.base, 4, 1, m.disp, 0)" "asm"="callq *{m.disp}({m.base})" "asmonly" {
  ret void
}

define void @CALLx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 2, m.index, m.base) | 11111111 | rm(2, m.base, m.index, m.scale, m.disp, 0) }" "asm"="callq *{m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @CALLp(ptr "sym" %m.sym) "enc"="rex(0, 2, 0, 0) | 11111111 | rm(2, 16, 4, 1, 0, m.sym)" "asm"="callq *{m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @JmPm(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 4, 4, m.base) | 11111111 | rm(4, m.base, 4, 1, m.disp, 0)" "asm"="jmpq *{m.disp}({m.base})" "asmonly" {
  ret void
}

define void @JxPx(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 4, m.index, m.base) | 11111111 | rm(4, m.base, m.index, m.scale, m.disp, 0) }" "asm"="jmpq *{m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @JpPp(ptr "sym" %m.sym) "enc"="rex(0, 4, 0, 0) | 11111111 | rm(4, 16, 4, 1, 0, m.sym)" "asm"="jmpq *{m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @RET() "enc"="11000011" "asm"="retq" "asmonly" {
  ret void
}

define void @UD2() "enc"="00001111 | 00001011" "asm"="ud2" "asmonly" {
  ret void
}

define void @INT3() "enc"="11001100" "asm"="int3" "asmonly" {
  ret void
}

define void @NOP() "enc"="10010000" "asm"="nop" "asmonly" {
  ret void
}

define void @PUSH64r(i64 "reg"="r64" %d) "enc"="rex(0, 0, 0, d) | 01010 o:3=d&7" "asm"="pushq {d}" "asmonly" {
  ret void
}

define void @POP64r(i64 "reg"="r64" %d) "enc"="rex(0, 0, 0, d) | 01011 o:3=d&7" "asm"="popq {d}" "asmonly" {
  ret void
}

define void @PUSH64i(i64 "imm" %c) "enc"="{ 01101010 | ib:s8=c ; 01101000 | iv:s32=c }" "asm"="pushq ${c}" "asmonly" {
  ret void
}

define void @PUSH64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 6, 4, m.base) | 11111111 | rm(6, m.base, 4, 1, m.disp, 0)" "asm"="pushq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @PUSH64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 6, m.index, m.base) | 11111111 | rm(6, m.base, m.index, m.scale, m.disp, 0) }" "asm"="pushq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @PUSH64p(ptr "sym" %m.sym) "enc"="rex(0, 6, 0, 0) | 11111111 | rm(6, 16, 4, 1, 0, m.sym)" "asm"="pushq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @POP64m(i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, 0, 4, m.base) | 10001111 | rm(0, m.base, 4, 1, m.disp, 0)" "asm"="popq {m.disp}({m.base})" "asmonly" {
  ret void
}

define void @POP64x(i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, 0, m.index, m.base) | 10001111 | rm(0, m.base, m.index, m.scale, m.disp, 0) }" "asm"="popq {m.disp}({m.base},{m.index},{m.scale})" "asmonly" {
  ret void
}

define void @POP64p(ptr "sym" %m.sym) "enc"="rex(0, 0, 0, 0) | 10001111 | rm(0, 16, 4, 1, 0, m.sym)" "asm"="popq {m.sym}(%rip)" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSWAP64r(i64 "reg"="r64" %d) "enc"="rex(1, 0, 0, d) | 00001111 | 11001 o:3=d&7" "asm"="bswapq {d}" "asmonly" {
  ret void
}

define void @BSWAP32r(i64 "reg"="r32" %d) "enc"="rex(0, 0, 0, d) | 00001111 | 11001 o:3=d&7" "asm"="bswapl {d}" "asmonly" {
  ret void
}

define void @BSF64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="bsfq {s}, {d}" "asmonly" {
  ret void
}

define void @BSF64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsfq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSF64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsfq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSF64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsfq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSF32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="bsfl {s}, {d}" "asmonly" {
  ret void
}

define void @BSF32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsfl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSF32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsfl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSF32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsfl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSF16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="bsfw {s}, {d}" "asmonly" {
  ret void
}

define void @BSF16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsfw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSF16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsfw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSF16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsfw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSR64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="rex(1, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="bsrq {s}, {d}" "asmonly" {
  ret void
}

define void @BSR64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(1, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsrq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSR64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(1, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsrq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSR64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="rex(1, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsrq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSR32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="rex(0, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="bsrl {s}, {d}" "asmonly" {
  ret void
}

define void @BSR32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="rex(0, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsrl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSR32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) rex(0, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsrl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSR32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="rex(0, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsrl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @BSR16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | rex(0, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="bsrw {s}, {d}" "asmonly" {
  ret void
}

define void @BSR16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | rex(0, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="bsrw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @BSR16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | rex(0, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="bsrw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @BSR16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | rex(0, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="bsrw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @POPCNT64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="11110011 | rex(1, d, 0, s) | 00001111 | 10111000 | rr(d, s)" "asm"="popcntq {s}, {d}" "asmonly" {
  ret void
}

define void @POPCNT64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(1, d, 4, m.base) | 00001111 | 10111000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="popcntq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @POPCNT64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(1, d, m.index, m.base) | 00001111 | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="popcntq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @POPCNT64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(1, d, 0, 0) | 00001111 | 10111000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="popcntq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @POPCNT32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 10111000 | rr(d, s)" "asm"="popcntl {s}, {d}" "asmonly" {
  ret void
}

define void @POPCNT32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 10111000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="popcntl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @POPCNT32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="popcntl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @POPCNT32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 10111000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="popcntl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @POPCNT16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | 11110011 | rex(0, d, 0, s) | 00001111 | 10111000 | rr(d, s)" "asm"="popcntw {s}, {d}" "asmonly" {
  ret void
}

define void @POPCNT16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | 11110011 | rex(0, d, 4, m.base) | 00001111 | 10111000 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="popcntw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @POPCNT16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111000 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="popcntw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @POPCNT16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | 11110011 | rex(0, d, 0, 0) | 00001111 | 10111000 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="popcntw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @LZCNT64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="11110011 | rex(1, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="lzcntq {s}, {d}" "asmonly" {
  ret void
}

define void @LZCNT64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(1, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="lzcntq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @LZCNT64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(1, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="lzcntq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @LZCNT64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(1, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="lzcntq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @LZCNT32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="lzcntl {s}, {d}" "asmonly" {
  ret void
}

define void @LZCNT32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="lzcntl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @LZCNT32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="lzcntl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @LZCNT32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="lzcntl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @LZCNT16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | 11110011 | rex(0, d, 0, s) | 00001111 | 10111101 | rr(d, s)" "asm"="lzcntw {s}, {d}" "asmonly" {
  ret void
}

define void @LZCNT16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | 11110011 | rex(0, d, 4, m.base) | 00001111 | 10111101 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="lzcntw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @LZCNT16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111101 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="lzcntw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @LZCNT16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | 11110011 | rex(0, d, 0, 0) | 00001111 | 10111101 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="lzcntw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TZCNT64rr(i64 "reg"="r64" %d, i64 "reg"="r64" %s) "enc"="11110011 | rex(1, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="tzcntq {s}, {d}" "asmonly" {
  ret void
}

define void @TZCNT64rm(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(1, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="tzcntq {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @TZCNT64rx(i64 "reg"="r64" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(1, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="tzcntq {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @TZCNT64rp(i64 "reg"="r64" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(1, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="tzcntq {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TZCNT32rr(i64 "reg"="r32" %d, i64 "reg"="r32" %s) "enc"="11110011 | rex(0, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="tzcntl {s}, {d}" "asmonly" {
  ret void
}

define void @TZCNT32rm(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="11110011 | rex(0, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="tzcntl {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @TZCNT32rx(i64 "reg"="r32" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="tzcntl {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @TZCNT32rp(i64 "reg"="r32" %d, ptr "sym" %m.sym) "enc"="11110011 | rex(0, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="tzcntl {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}

define void @TZCNT16rr(i64 "reg"="r16" %d, i64 "reg"="r16" %s) "enc"="01100110 | 11110011 | rex(0, d, 0, s) | 00001111 | 10111100 | rr(d, s)" "asm"="tzcntw {s}, {d}" "asmonly" {
  ret void
}

define void @TZCNT16rm(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "imm" %m.disp) "enc"="01100110 | 11110011 | rex(0, d, 4, m.base) | 00001111 | 10111100 | rm(d, m.base, 4, 1, m.disp, 0)" "asm"="tzcntw {m.disp}({m.base}), {d}" "asmonly" {
  ret void
}

define void @TZCNT16rx(i64 "reg"="r16" %d, i64 "reg"="r64" %m.base, i64 "reg"="r64" %m.index, i64 "imm" %m.scale, i64 "imm" %m.disp) "enc"="{ if(m.index!=4) 01100110 | 11110011 | rex(0, d, m.index, m.base) | 00001111 | 10111100 | rm(d, m.base, m.index, m.scale, m.disp, 0) }" "asm"="tzcntw {m.disp}({m.base},{m.index},{m.scale}), {d}" "asmonly" {
  ret void
}

define void @TZCNT16rp(i64 "reg"="r16" %d, ptr "sym" %m.sym) "enc"="01100110 | 11110011 | rex(0, d, 0, 0) | 00001111 | 10111100 | rm(d, 16, 4, 1, 0, m.sym)" "asm"="tzcntw {m.sym}(%rip), {d}" "asmonly" "reloc"="pc32x" {
  ret void
}
