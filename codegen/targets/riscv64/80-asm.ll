; Entries for assembly and disassembly only ("asmonly"), written by
; gen_opcodes.py: the RV64 instructions of the extensions it names that the
; rest of the description does not have. Their fixed bits and the fields of
; their operands are from riscv-opcodes, under this license:
;
; Copyright (c) 2022 RISC-V International
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Neither the name of the copyright holder nor the names of its contributors
;    may be used to endorse or promote products derived from this software without
;    specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; Operands are written in RISC-V's order. Which registers are integer and
; which floating-point, and the bits of rounding modes and orderings, were
; found with LLVM's RISC-V assembler (rustc's); each entry's words, for
; every line tried, are its.

define void @AUIPC.0(i64 "reg"="x" %rd, i64 "imm" %imm20) "enc"="imm20:20 rd:5 0010111" "asm"="auipc {rd}, {imm20}" "asmonly" {
  ret void
}

define void @JAL.0(i64 "reg"="x" %rd, ptr "label" %dest) "enc"="o_20:s1=dest>>20 o_10:10=(dest>>1)&1023 o_11:1=(dest>>11)&1 o_19:8=(dest>>12)&255 rd:5 1101111" "asm"="jal {rd}, {dest}" "asmonly" {
  ret void
}

define void @JALR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %imm12) "enc"="imm12:s12 rs1:5 000 rd:5 1100111" "asm"="jalr {rd}, {imm12}({rs1})" "asmonly" {
  ret void
}

define void @FENCE.0() "enc"="00001111111100000000000000001111" "asm"="fence iorw, iorw" "asmonly" {
  ret void
}

define void @FENCE.1() "enc"="00001111001100000000000000001111" "asm"="fence iorw, rw" "asmonly" {
  ret void
}

define void @FENCE.2() "enc"="00001111001000000000000000001111" "asm"="fence iorw, r" "asmonly" {
  ret void
}

define void @FENCE.3() "enc"="00001111000100000000000000001111" "asm"="fence iorw, w" "asmonly" {
  ret void
}

define void @FENCE.4() "enc"="00000011111100000000000000001111" "asm"="fence rw, iorw" "asmonly" {
  ret void
}

define void @FENCE.5() "enc"="00000011001100000000000000001111" "asm"="fence rw, rw" "asmonly" {
  ret void
}

define void @FENCE.6() "enc"="00000011001000000000000000001111" "asm"="fence rw, r" "asmonly" {
  ret void
}

define void @FENCE.7() "enc"="00000011000100000000000000001111" "asm"="fence rw, w" "asmonly" {
  ret void
}

define void @FENCE.8() "enc"="00000010111100000000000000001111" "asm"="fence r, iorw" "asmonly" {
  ret void
}

define void @FENCE.9() "enc"="00000010001100000000000000001111" "asm"="fence r, rw" "asmonly" {
  ret void
}

define void @FENCE.10() "enc"="00000010001000000000000000001111" "asm"="fence r, r" "asmonly" {
  ret void
}

define void @FENCE.11() "enc"="00000010000100000000000000001111" "asm"="fence r, w" "asmonly" {
  ret void
}

define void @FENCE.12() "enc"="00000001111100000000000000001111" "asm"="fence w, iorw" "asmonly" {
  ret void
}

define void @FENCE.13() "enc"="00000001001100000000000000001111" "asm"="fence w, rw" "asmonly" {
  ret void
}

define void @FENCE.14() "enc"="00000001001000000000000000001111" "asm"="fence w, r" "asmonly" {
  ret void
}

define void @FENCE.15() "enc"="00000001000100000000000000001111" "asm"="fence w, w" "asmonly" {
  ret void
}

define void @ECALL.0() "enc"="00000000000000000000000001110011" "asm"="ecall" "asmonly" {
  ret void
}

define void @MULHSU.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000001 rs2:5 rs1:5 010 rd:5 0110011" "asm"="mulhsu {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @LR_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000000 rs1:5 010 rd:5 0101111" "asm"="lr.w {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000101000000 rs1:5 010 rd:5 0101111" "asm"="lr.w.aq {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100100000 rs1:5 010 rd:5 0101111" "asm"="lr.w.rl {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000101100000 rs1:5 010 rd:5 0101111" "asm"="lr.w.aqrl {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001100 rs2:5 rs1:5 010 rd:5 0101111" "asm"="sc.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001110 rs2:5 rs1:5 010 rd:5 0101111" "asm"="sc.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001101 rs2:5 rs1:5 010 rd:5 0101111" "asm"="sc.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001111 rs2:5 rs1:5 010 rd:5 0101111" "asm"="sc.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoswap.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000110 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoswap.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoswap.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoswap.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoadd.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoadd.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoadd.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoadd.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoxor.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoxor.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoxor.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoxor.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoand.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoand.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoand.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoand.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoor.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoor.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoor.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amoor.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomin.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomin.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomin.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomin.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomax.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomax.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomax.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomax.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amominu.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amominu.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amominu.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amominu.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110000 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomaxu.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110010 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomaxu.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110001 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomaxu.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110011 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amomaxu.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000000 rs1:5 011 rd:5 0101111" "asm"="lr.d {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000101000000 rs1:5 011 rd:5 0101111" "asm"="lr.d.aq {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100100000 rs1:5 011 rd:5 0101111" "asm"="lr.d.rl {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @LR_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000101100000 rs1:5 011 rd:5 0101111" "asm"="lr.d.aqrl {rd}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001100 rs2:5 rs1:5 011 rd:5 0101111" "asm"="sc.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001110 rs2:5 rs1:5 011 rd:5 0101111" "asm"="sc.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001101 rs2:5 rs1:5 011 rd:5 0101111" "asm"="sc.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SC_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001111 rs2:5 rs1:5 011 rd:5 0101111" "asm"="sc.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoswap.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000110 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoswap.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoswap.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoswap.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoadd.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoadd.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoadd.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoadd.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoxor.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoxor.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoxor.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoxor.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoand.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoand.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoand.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoand.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoor.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoor.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoor.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amoor.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomin.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomin.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomin.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomin.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomax.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomax.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomax.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomax.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amominu.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amominu.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amominu.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amominu.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110000 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomaxu.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110010 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomaxu.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110001 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomaxu.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110011 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amomaxu.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @FMADD_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 000 rd:5 1000011" "asm"="fmadd.s {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMADD_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 001 rd:5 1000011" "asm"="fmadd.s {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMADD_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 010 rd:5 1000011" "asm"="fmadd.s {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMADD_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 011 rd:5 1000011" "asm"="fmadd.s {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMADD_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 100 rd:5 1000011" "asm"="fmadd.s {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMSUB_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FMSUB_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 000 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMSUB_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 001 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMSUB_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 010 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMSUB_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 011 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMSUB_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 100 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMSUB_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.s {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMSUB_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMSUB_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 000 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMSUB_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 001 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMSUB_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 010 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMSUB_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 011 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMSUB_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 100 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMSUB_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.s {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMADD_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMADD_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 000 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMADD_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 001 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMADD_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 010 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMADD_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 011 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMADD_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 100 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMADD_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 00 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.s {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FADD_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000000 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fadd.s {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FADD_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000000 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fadd.s {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FADD_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000000 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fadd.s {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FADD_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000000 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fadd.s {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FADD_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000000 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fadd.s {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FSUB_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000100 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fsub.s {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FSUB_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000100 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fsub.s {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FSUB_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000100 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fsub.s {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FSUB_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000100 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fsub.s {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FSUB_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000100 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fsub.s {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FMUL_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001000 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmul.s {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FMUL_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001000 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmul.s {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FMUL_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001000 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fmul.s {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FMUL_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001000 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmul.s {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FMUL_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001000 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fmul.s {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FDIV_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001100 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fdiv.s {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FDIV_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001100 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fdiv.s {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FDIV_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001100 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fdiv.s {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FDIV_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001100 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fdiv.s {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FDIV_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001100 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fdiv.s {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FSQRT_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110000000 rs1:5 000 rd:5 1010011" "asm"="fsqrt.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FSQRT_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110000000 rs1:5 001 rd:5 1010011" "asm"="fsqrt.s {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FSQRT_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110000000 rs1:5 010 rd:5 1010011" "asm"="fsqrt.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FSQRT_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110000000 rs1:5 011 rd:5 1010011" "asm"="fsqrt.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FSQRT_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110000000 rs1:5 100 rd:5 1010011" "asm"="fsqrt.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FMIN_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010100 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmin.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAX_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010100 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmax.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FCVT_W_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_W_S.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 000 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_W_S.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 010 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_W_S.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 011 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_W_S.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 100 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_W_S.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_WU_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_WU_S.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_WU_S.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_WU_S.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_WU_S.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_WU_S.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCLASS_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="111000000000 rs1:5 001 rd:5 1010011" "asm"="fclass.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_S_W.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000000 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.w {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_S_W.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000000 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.w {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_W.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000000 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.w {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_W.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000000 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.w {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_W.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000000 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.w {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_S_WU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.wu {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_S_WU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000001 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.wu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_WU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.wu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_WU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.wu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_WU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.wu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_L_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_L_S.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_L_S.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 010 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_L_S.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 011 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_L_S.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 100 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_L_S.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_LU_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_LU_S.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 000 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_LU_S.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 010 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_LU_S.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 011 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_LU_S.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 100 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_LU_S.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_S_L.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.l {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_S_L.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000010 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.l {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_L.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000010 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.l {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_L.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000010 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.l {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_L.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000010 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.l {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_S_LU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000011 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.lu {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_S_LU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000011 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.lu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_LU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000011 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.lu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_LU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000011 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.lu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_LU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100000011 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.lu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FMADD_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 000 rd:5 1000011" "asm"="fmadd.d {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMADD_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 001 rd:5 1000011" "asm"="fmadd.d {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMADD_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 010 rd:5 1000011" "asm"="fmadd.d {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMADD_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 011 rd:5 1000011" "asm"="fmadd.d {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMADD_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 100 rd:5 1000011" "asm"="fmadd.d {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMSUB_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FMSUB_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 000 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMSUB_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 001 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMSUB_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 010 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMSUB_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 011 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMSUB_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 100 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMSUB_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.d {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMSUB_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMSUB_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 000 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMSUB_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 001 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMSUB_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 010 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMSUB_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 011 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMSUB_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 100 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMSUB_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.d {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMADD_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMADD_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 000 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMADD_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 001 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMADD_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 010 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMADD_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 011 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMADD_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 100 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMADD_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 01 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.d {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FADD_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000001 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fadd.d {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FADD_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000001 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fadd.d {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FADD_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000001 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fadd.d {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FADD_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000001 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fadd.d {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FADD_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000001 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fadd.d {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FSUB_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000101 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fsub.d {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FSUB_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000101 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fsub.d {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FSUB_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000101 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fsub.d {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FSUB_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000101 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fsub.d {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FSUB_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000101 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fsub.d {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FMUL_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001001 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmul.d {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FMUL_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001001 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmul.d {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FMUL_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001001 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fmul.d {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FMUL_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001001 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmul.d {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FMUL_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001001 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fmul.d {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FDIV_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001101 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fdiv.d {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FDIV_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001101 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fdiv.d {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FDIV_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001101 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fdiv.d {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FDIV_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001101 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fdiv.d {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FDIV_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001101 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fdiv.d {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FSQRT_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110100000 rs1:5 000 rd:5 1010011" "asm"="fsqrt.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FSQRT_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110100000 rs1:5 001 rd:5 1010011" "asm"="fsqrt.d {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FSQRT_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110100000 rs1:5 010 rd:5 1010011" "asm"="fsqrt.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FSQRT_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110100000 rs1:5 011 rd:5 1010011" "asm"="fsqrt.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FSQRT_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010110100000 rs1:5 100 rd:5 1010011" "asm"="fsqrt.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FMIN_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010101 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmin.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAX_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010101 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmax.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FCVT_S_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_S_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000001 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.d {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100000 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.s {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100000 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100000 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100000 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100000 rs1:5 111 rd:5 1010011" "asm"="fcvt.d.s {rd}, {rs1}, dyn" "asmonly" {
  ret void
}

define void @FCLASS_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="111000100000 rs1:5 001 rd:5 1010011" "asm"="fclass.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_W_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_W_D.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 000 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_W_D.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 010 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_W_D.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 011 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_W_D.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 100 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_W_D.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_WU_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_WU_D.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 000 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_WU_D.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 010 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_WU_D.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 011 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_WU_D.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 100 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_WU_D.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_D_W.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100000 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.w {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_W.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100000 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.w {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_W.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100000 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.w {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_W.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100000 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.w {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_W.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100000 rs1:5 111 rd:5 1010011" "asm"="fcvt.d.w {rd}, {rs1}, dyn" "asmonly" {
  ret void
}

define void @FCVT_D_WU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100001 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.wu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_WU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100001 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.wu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_WU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100001 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.wu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_WU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100001 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.wu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_WU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100001 rs1:5 111 rd:5 1010011" "asm"="fcvt.d.wu {rd}, {rs1}, dyn" "asmonly" {
  ret void
}

define void @FCVT_L_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_L_D.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 000 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_L_D.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 010 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_L_D.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 011 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_L_D.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 100 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_L_D.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_LU_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_LU_D.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 000 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_LU_D.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 010 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_LU_D.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 011 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_LU_D.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 100 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_LU_D.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110000100011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_D_L.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100010 rs1:5 000 rd:5 1010011" "asm"="fcvt.d.l {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_D_L.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100010 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.l {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_L.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100010 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.l {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_L.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100010 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.l {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_L.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100010 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.l {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_LU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100011 rs1:5 000 rd:5 1010011" "asm"="fcvt.d.lu {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_D_LU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100011 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.lu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_LU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100011 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.lu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_LU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100011 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.lu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_LU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110100100011 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.lu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @CSRRW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %csr) "enc"="csr:12 rs1:5 001 rd:5 1110011" "asm"="csrrw {rd}, {csr}, {rs1}" "asmonly" {
  ret void
}

define void @CSRRS.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %csr) "enc"="csr:12 rs1:5 010 rd:5 1110011" "asm"="csrrs {rd}, {csr}, {rs1}" "asmonly" {
  ret void
}

define void @CSRRC.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %csr) "enc"="csr:12 rs1:5 011 rd:5 1110011" "asm"="csrrc {rd}, {csr}, {rs1}" "asmonly" {
  ret void
}

define void @CSRRWI.0(i64 "reg"="x" %rd, i64 "imm" %csr, i64 "imm" %zimm5) "enc"="csr:12 zimm5:5 101 rd:5 1110011" "asm"="csrrwi {rd}, {csr}, {zimm5}" "asmonly" {
  ret void
}

define void @CSRRSI.0(i64 "reg"="x" %rd, i64 "imm" %csr, i64 "imm" %zimm5) "enc"="csr:12 zimm5:5 110 rd:5 1110011" "asm"="csrrsi {rd}, {csr}, {zimm5}" "asmonly" {
  ret void
}

define void @CSRRCI.0(i64 "reg"="x" %rd, i64 "imm" %csr, i64 "imm" %zimm5) "enc"="csr:12 zimm5:5 111 rd:5 1110011" "asm"="csrrci {rd}, {csr}, {zimm5}" "asmonly" {
  ret void
}

define void @FENCE_I.0() "enc"="00000000000000000001000000001111" "asm"="fence.i" "asmonly" {
  ret void
}

define void @SH1ADD.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 010 rd:5 0110011" "asm"="sh1add {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SH2ADD.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 100 rd:5 0110011" "asm"="sh2add {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SH3ADD.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 110 rd:5 0110011" "asm"="sh3add {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @ADD_UW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 000 rd:5 0111011" "asm"="add.uw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SH1ADD_UW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 010 rd:5 0111011" "asm"="sh1add.uw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SH2ADD_UW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 100 rd:5 0111011" "asm"="sh2add.uw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SH3ADD_UW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 110 rd:5 0111011" "asm"="sh3add.uw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SLLI_UW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="000010 shamtd:6 rs1:5 001 rd:5 0011011" "asm"="slli.uw {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @XNOR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100000 rs2:5 rs1:5 100 rd:5 0110011" "asm"="xnor {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @ROL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 001 rd:5 0110011" "asm"="rol {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @ROR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 101 rd:5 0110011" "asm"="ror {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @ORC_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="001010000111 rs1:5 101 rd:5 0010011" "asm"="orc.b {rd}, {rs1}" "asmonly" {
  ret void
}

define void @CLZW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="011000000000 rs1:5 001 rd:5 0011011" "asm"="clzw {rd}, {rs1}" "asmonly" {
  ret void
}

define void @CTZW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="011000000001 rs1:5 001 rd:5 0011011" "asm"="ctzw {rd}, {rs1}" "asmonly" {
  ret void
}

define void @CPOPW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="011000000010 rs1:5 001 rd:5 0011011" "asm"="cpopw {rd}, {rs1}" "asmonly" {
  ret void
}

define void @ROLW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 001 rd:5 0111011" "asm"="rolw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @RORW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 101 rd:5 0111011" "asm"="rorw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @RORIW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtw) "enc"="0110000 shamtw:5 rs1:5 101 rd:5 0011011" "asm"="roriw {rd}, {rs1}, {shamtw}" "asmonly" {
  ret void
}

define void @RORI.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="011000 shamtd:6 rs1:5 101 rd:5 0010011" "asm"="rori {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @BCLR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100100 rs2:5 rs1:5 001 rd:5 0110011" "asm"="bclr {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @BEXT.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100100 rs2:5 rs1:5 101 rd:5 0110011" "asm"="bext {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @BINV.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110100 rs2:5 rs1:5 001 rd:5 0110011" "asm"="binv {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @BSET.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 001 rd:5 0110011" "asm"="bset {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @BCLRI.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="010010 shamtd:6 rs1:5 001 rd:5 0010011" "asm"="bclri {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @BEXTI.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="010010 shamtd:6 rs1:5 101 rd:5 0010011" "asm"="bexti {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @BINVI.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="011010 shamtd:6 rs1:5 001 rd:5 0010011" "asm"="binvi {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @BSETI.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %shamtd) "enc"="001010 shamtd:6 rs1:5 001 rd:5 0010011" "asm"="bseti {rd}, {rs1}, {shamtd}" "asmonly" {
  ret void
}

define void @CLMUL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 001 rd:5 0110011" "asm"="clmul {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @CLMULR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 010 rd:5 0110011" "asm"="clmulr {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @CLMULH.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 011 rd:5 0110011" "asm"="clmulh {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @PACK.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 100 rd:5 0110011" "asm"="pack {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @PACKH.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 111 rd:5 0110011" "asm"="packh {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @BREV8.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="011010000111 rs1:5 101 rd:5 0010011" "asm"="brev8 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @PACKW.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 100 rd:5 0111011" "asm"="packw {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @XPERM4.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 010 rd:5 0110011" "asm"="xperm4 {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @XPERM8.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 100 rd:5 0110011" "asm"="xperm8 {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @CZERO_EQZ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 101 rd:5 0110011" "asm"="czero.eqz {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @CZERO_NEZ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 111 rd:5 0110011" "asm"="czero.nez {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMINM_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010100 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fminm.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAXM_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010100 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmaxm.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FROUND_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 111 rd:5 1010011" "asm"="fround.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUND_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 000 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUND_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 001 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUND_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 010 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUND_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 011 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUND_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 100 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUND_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000100 rs1:5 111 rd:5 1010011" "asm"="fround.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FROUNDNX_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 111 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUNDNX_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 000 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUNDNX_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 001 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUNDNX_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 010 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUNDNX_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 011 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUNDNX_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 100 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUNDNX_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000101 rs1:5 111 rd:5 1010011" "asm"="froundnx.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FLEQ_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010000 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fleq.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLTQ_S.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010000 rs2:5 rs1:5 101 rd:5 1010011" "asm"="fltq.s {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMINM_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010101 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fminm.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAXM_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010101 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmaxm.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FROUND_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 111 rd:5 1010011" "asm"="fround.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUND_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 000 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUND_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 001 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUND_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 010 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUND_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 011 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUND_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 100 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUND_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100100 rs1:5 111 rd:5 1010011" "asm"="fround.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FROUNDNX_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 111 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUNDNX_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 000 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUNDNX_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 001 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUNDNX_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 010 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUNDNX_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 011 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUNDNX_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 100 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUNDNX_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100101 rs1:5 111 rd:5 1010011" "asm"="froundnx.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FLEQ_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010001 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fleq.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLTQ_D.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010001 rs2:5 rs1:5 101 rd:5 1010011" "asm"="fltq.d {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMADD_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FMADD_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 000 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMADD_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 001 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMADD_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 010 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMADD_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 011 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMADD_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 100 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMADD_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1000011" "asm"="fmadd.h {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FMSUB_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FMSUB_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 000 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FMSUB_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 001 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FMSUB_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 010 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FMSUB_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 011 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FMSUB_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 100 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FMSUB_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1000111" "asm"="fmsub.h {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMSUB_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMSUB_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 000 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMSUB_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 001 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMSUB_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 010 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMSUB_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 011 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMSUB_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 100 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMSUB_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1001011" "asm"="fnmsub.h {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FNMADD_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}" "asmonly" {
  ret void
}

define void @FNMADD_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 000 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, rne" "asmonly" {
  ret void
}

define void @FNMADD_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 001 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, rtz" "asmonly" {
  ret void
}

define void @FNMADD_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 010 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, rdn" "asmonly" {
  ret void
}

define void @FNMADD_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 011 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, rup" "asmonly" {
  ret void
}

define void @FNMADD_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 100 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, rmm" "asmonly" {
  ret void
}

define void @FNMADD_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2, i64 "reg"="d" %rs3) "enc"="rs3:5 10 rs2:5 rs1:5 111 rd:5 1001111" "asm"="fnmadd.h {rd}, {rs1}, {rs2}, {rs3}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FADD_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FADD_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FADD_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FADD_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FADD_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FADD_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FADD_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000010 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fadd.h {rd}, {rs1}, {rs2}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FSUB_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FSUB_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FSUB_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FSUB_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FSUB_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FSUB_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FSUB_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0000110 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fsub.h {rd}, {rs1}, {rs2}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FMUL_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMUL_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FMUL_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FMUL_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FMUL_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FMUL_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FMUL_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001010 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fmul.h {rd}, {rs1}, {rs2}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FDIV_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FDIV_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, rne" "asmonly" {
  ret void
}

define void @FDIV_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, rtz" "asmonly" {
  ret void
}

define void @FDIV_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, rdn" "asmonly" {
  ret void
}

define void @FDIV_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, rup" "asmonly" {
  ret void
}

define void @FDIV_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, rmm" "asmonly" {
  ret void
}

define void @FDIV_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0001110 rs2:5 rs1:5 111 rd:5 1010011" "asm"="fdiv.h {rd}, {rs1}, {rs2}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FSQRT_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 111 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FSQRT_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 000 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FSQRT_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 001 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FSQRT_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 010 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FSQRT_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 011 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FSQRT_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 100 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FSQRT_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010111000000 rs1:5 111 rd:5 1010011" "asm"="fsqrt.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FSGNJ_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010010 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fsgnj.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FSGNJN_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010010 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fsgnjn.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FSGNJX_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010010 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fsgnjx.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMIN_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010110 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fmin.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAX_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010110 rs2:5 rs1:5 001 rd:5 1010011" "asm"="fmax.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FEQ_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010010 rs2:5 rs1:5 010 rd:5 1010011" "asm"="feq.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLT_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010010 rs2:5 rs1:5 001 rd:5 1010011" "asm"="flt.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLE_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010010 rs2:5 rs1:5 000 rd:5 1010011" "asm"="fle.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FCLASS_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="111001000000 rs1:5 001 rd:5 1010011" "asm"="fclass.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_W_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_W_H.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 000 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_W_H.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 001 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_W_H.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 010 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_W_H.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 011 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_W_H.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 100 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_W_H.6(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.w.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_WU_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_WU_H.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_WU_H.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 001 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_WU_H.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_WU_H.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_WU_H.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_WU_H.6(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.wu.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_H_W.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_W.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_W.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_W.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_W.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_W.5(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_W.6(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.w {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_H_WU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_WU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_WU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_WU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_WU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_WU.5(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_WU.6(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.wu {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_L_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_L_H.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_L_H.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 001 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_L_H.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 010 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_L_H.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 011 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_L_H.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 100 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_L_H.6(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.l.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_LU_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_LU_H.1(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 000 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_LU_H.2(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 001 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_LU_H.3(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 010 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_LU_H.4(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 011 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_LU_H.5(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 100 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_LU_H.6(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="110001000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.lu.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_H_L.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_L.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_L.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_L.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_L.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_L.5(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_L.6(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.l {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_H_LU.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_LU.1(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_LU.2(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_LU.3(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_LU.4(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_LU.5(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_LU.6(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="110101000011 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.lu {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FMINM_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010110 rs2:5 rs1:5 010 rd:5 1010011" "asm"="fminm.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FMAXM_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="0010110 rs2:5 rs1:5 011 rd:5 1010011" "asm"="fmaxm.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FROUND_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 111 rd:5 1010011" "asm"="fround.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUND_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 000 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUND_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 001 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUND_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 010 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUND_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 011 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUND_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 100 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUND_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000100 rs1:5 111 rd:5 1010011" "asm"="fround.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FROUNDNX_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 111 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FROUNDNX_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 000 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FROUNDNX_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 001 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FROUNDNX_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 010 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FROUNDNX_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 011 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FROUNDNX_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 100 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FROUNDNX_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000101 rs1:5 111 rd:5 1010011" "asm"="froundnx.h {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FLEQ_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010010 rs2:5 rs1:5 100 rd:5 1010011" "asm"="fleq.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLTQ_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1, i64 "reg"="d" %rs2) "enc"="1010010 rs2:5 rs1:5 101 rd:5 1010011" "asm"="fltq.h {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @FLH.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1, i64 "imm" %imm12) "enc"="imm12:s12 rs1:5 001 rd:5 0000111" "asm"="flh {rd}, {imm12}({rs1})" "asmonly" {
  ret void
}

define void @FSH.0(i64 "reg"="x" %rs1, i64 "reg"="d" %rs2, i64 "imm" %off) "enc"="o_hi:s7=off>>5 rs2:5 rs1:5 001 o_lo:5=off&31 0100111" "asm"="fsh {rs2}, {off}({rs1})" "asmonly" {
  ret void
}

define void @FCVT_S_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_S_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 000 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, rne" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_S_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 001 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_S_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 010 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_S_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 011 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_S_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 100 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_S_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000000010 rs1:5 111 rd:5 1010011" "asm"="fcvt.s.h {rd}, {rs1}, dyn" "asmonly" {
  ret void
}

define void @FCVT_H_S.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_S.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_S.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_S.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_S.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_S.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_S.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000000 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.s {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @FMV_X_H.0(i64 "reg"="x" %rd, i64 "reg"="d" %rs1) "enc"="111001000000 rs1:5 000 rd:5 1010011" "asm"="fmv.x.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FMV_H_X.0(i64 "reg"="d" %rd, i64 "reg"="x" %rs1) "enc"="111101000000 rs1:5 000 rd:5 1010011" "asm"="fmv.h.x {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_D_H.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 000 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_D_H.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 000 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, rne" "asmonly" "nodecode" {
  ret void
}

define void @FCVT_D_H.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 001 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_D_H.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 010 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_D_H.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 011 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_D_H.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 100 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_D_H.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010000100010 rs1:5 111 rd:5 1010011" "asm"="fcvt.d.h {rd}, {rs1}, dyn" "asmonly" {
  ret void
}

define void @FCVT_H_D.0(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}" "asmonly" {
  ret void
}

define void @FCVT_H_D.1(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 000 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, rne" "asmonly" {
  ret void
}

define void @FCVT_H_D.2(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 001 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, rtz" "asmonly" {
  ret void
}

define void @FCVT_H_D.3(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 010 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, rdn" "asmonly" {
  ret void
}

define void @FCVT_H_D.4(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 011 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, rup" "asmonly" {
  ret void
}

define void @FCVT_H_D.5(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 100 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, rmm" "asmonly" {
  ret void
}

define void @FCVT_H_D.6(i64 "reg"="d" %rd, i64 "reg"="d" %rs1) "enc"="010001000001 rs1:5 111 rd:5 1010011" "asm"="fcvt.h.d {rd}, {rs1}, dyn" "asmonly" "nodecode" {
  ret void
}

define void @WRS_NTO.0() "enc"="00000000110100000000000001110011" "asm"="wrs.nto" "asmonly" {
  ret void
}

define void @WRS_STO.0() "enc"="00000001110100000000000001110011" "asm"="wrs.sto" "asmonly" {
  ret void
}

define void @AMOCAS_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amocas.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010110 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amocas.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010101 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amocas.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010111 rs2:5 rs1:5 010 rd:5 0101111" "asm"="amocas.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amocas.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010110 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amocas.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010101 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amocas.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010111 rs2:5 rs1:5 011 rd:5 0101111" "asm"="amocas.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoswap.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000110 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoswap.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoswap.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoswap.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoadd.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoadd.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoadd.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoadd.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoxor.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoxor.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoxor.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoxor.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoand.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoand.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoand.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoand.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoor.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoor.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoor.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amoor.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomin.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomin.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomin.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomin.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomax.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomax.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomax.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomax.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amominu.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amominu.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amominu.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amominu.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110000 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomaxu.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110010 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomaxu.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110001 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomaxu.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110011 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amomaxu.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000100 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoswap.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000110 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoswap.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000101 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoswap.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOSWAP_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000111 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoswap.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoadd.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoadd.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoadd.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOADD_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0000011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoadd.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoxor.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoxor.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoxor.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOXOR_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoxor.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoand.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoand.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoand.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOAND_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0110011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoand.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoor.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoor.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoor.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOOR_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amoor.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomin.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomin.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomin.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMIN_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomin.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomax.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomax.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomax.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAX_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1010011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomax.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amominu.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amominu.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amominu.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMINU_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amominu.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110000 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomaxu.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110010 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomaxu.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110001 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomaxu.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOMAXU_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1110011 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amomaxu.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_B.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amocas.b {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_B_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010110 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amocas.b.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_B_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010101 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amocas.b.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_B_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010111 rs2:5 rs1:5 000 rd:5 0101111" "asm"="amocas.b.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_H.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010100 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amocas.h {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_H_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010110 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amocas.h.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_H_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010101 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amocas.h.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @AMOCAS_H_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0010111 rs2:5 rs1:5 001 rd:5 0101111" "asm"="amocas.h.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @CBO_CLEAN.0(i64 "reg"="x" %rs1) "enc"="000000000001 rs1:5 010000000001111" "asm"="cbo.clean ({rs1})" "asmonly" {
  ret void
}

define void @CBO_FLUSH.0(i64 "reg"="x" %rs1) "enc"="000000000010 rs1:5 010000000001111" "asm"="cbo.flush ({rs1})" "asmonly" {
  ret void
}

define void @CBO_INVAL.0(i64 "reg"="x" %rs1) "enc"="000000000000 rs1:5 010000000001111" "asm"="cbo.inval ({rs1})" "asmonly" {
  ret void
}

define void @CBO_ZERO.0(i64 "reg"="x" %rs1) "enc"="000000000100 rs1:5 010000000001111" "asm"="cbo.zero ({rs1})" "asmonly" {
  ret void
}

define void @AES64DSM.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0011111 rs2:5 rs1:5 000 rd:5 0110011" "asm"="aes64dsm {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @AES64DS.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0011101 rs2:5 rs1:5 000 rd:5 0110011" "asm"="aes64ds {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @AES64KS1I.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "imm" %rnum) "enc"="00110001 rnum:4 rs1:5 001 rd:5 0010011" "asm"="aes64ks1i {rd}, {rs1}, {rnum}" "asmonly" {
  ret void
}

define void @AES64IM.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="001100000000 rs1:5 001 rd:5 0010011" "asm"="aes64im {rd}, {rs1}" "asmonly" {
  ret void
}

define void @AES64KS2.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0111111 rs2:5 rs1:5 000 rd:5 0110011" "asm"="aes64ks2 {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @AES64ESM.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0011011 rs2:5 rs1:5 000 rd:5 0110011" "asm"="aes64esm {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @AES64ES.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0011001 rs2:5 rs1:5 000 rd:5 0110011" "asm"="aes64es {rd}, {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SHA256SUM0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000000 rs1:5 001 rd:5 0010011" "asm"="sha256sum0 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA256SUM1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000001 rs1:5 001 rd:5 0010011" "asm"="sha256sum1 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA256SIG0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000010 rs1:5 001 rd:5 0010011" "asm"="sha256sig0 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA256SIG1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000011 rs1:5 001 rd:5 0010011" "asm"="sha256sig1 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA512SUM0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000100 rs1:5 001 rd:5 0010011" "asm"="sha512sum0 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA512SUM1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000101 rs1:5 001 rd:5 0010011" "asm"="sha512sum1 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA512SIG0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000110 rs1:5 001 rd:5 0010011" "asm"="sha512sig0 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SHA512SIG1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100000111 rs1:5 001 rd:5 0010011" "asm"="sha512sig1 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SM4ED.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2, i64 "imm" %bs) "enc"="bs:2 11000 rs2:5 rs1:5 000 rd:5 0110011" "asm"="sm4ed {rd}, {rs1}, {rs2}, {bs}" "asmonly" {
  ret void
}

define void @SM4KS.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2, i64 "imm" %bs) "enc"="bs:2 11010 rs2:5 rs1:5 000 rd:5 0110011" "asm"="sm4ks {rd}, {rs1}, {rs2}, {bs}" "asmonly" {
  ret void
}

define void @SM3P0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100001000 rs1:5 001 rd:5 0010011" "asm"="sm3p0 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @SM3P1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000100001001 rs1:5 001 rd:5 0010011" "asm"="sm3p1 {rd}, {rs1}" "asmonly" {
  ret void
}

define void @MRET.0() "enc"="00110000001000000000000001110011" "asm"="mret" "asmonly" {
  ret void
}

define void @WFI.0() "enc"="00010000010100000000000001110011" "asm"="wfi" "asmonly" {
  ret void
}

define void @SFENCE_VMA.0() "enc"="00010010000000000000000001110011" "asm"="sfence.vma" "asmonly" {
  ret void
}

define void @SFENCE_VMA.1(i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001001 rs2:5 rs1:5 000000001110011" "asm"="sfence.vma {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SRET.0() "enc"="00010000001000000000000001110011" "asm"="sret" "asmonly" {
  ret void
}

define void @SINVAL_VMA.0(i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0001011 rs2:5 rs1:5 000000001110011" "asm"="sinval.vma {rs1}, {rs2}" "asmonly" {
  ret void
}

define void @SFENCE_W_INVAL.0() "enc"="00011000000000000000000001110011" "asm"="sfence.w.inval" "asmonly" {
  ret void
}

define void @SFENCE_INVAL_IR.0() "enc"="00011000000100000000000001110011" "asm"="sfence.inval.ir" "asmonly" {
  ret void
}

define void @SSAMOSWAP_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100100 rs2:5 rs1:5 010 rd:5 0101111" "asm"="ssamoswap.w {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_W_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100110 rs2:5 rs1:5 010 rd:5 0101111" "asm"="ssamoswap.w.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_W_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100101 rs2:5 rs1:5 010 rd:5 0101111" "asm"="ssamoswap.w.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_W_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100111 rs2:5 rs1:5 010 rd:5 0101111" "asm"="ssamoswap.w.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_D.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100100 rs2:5 rs1:5 011 rd:5 0101111" "asm"="ssamoswap.d {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_D_AQ.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100110 rs2:5 rs1:5 011 rd:5 0101111" "asm"="ssamoswap.d.aq {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_D_RL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100101 rs2:5 rs1:5 011 rd:5 0101111" "asm"="ssamoswap.d.rl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @SSAMOSWAP_D_AQRL.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="0100111 rs2:5 rs1:5 011 rd:5 0101111" "asm"="ssamoswap.d.aqrl {rd}, {rs2}, ({rs1})" "asmonly" {
  ret void
}

define void @FENCE_TSO.0() "enc"="10000011001100000000000000001111" "asm"="fence.tso" "asmonly" "nodecode" {
  ret void
}

define void @SCALL.0() "enc"="00000000000000000000000001110011" "asm"="scall" "asmonly" "nodecode" {
  ret void
}

define void @JR.0(i64 "reg"="x" %rs1) "enc"="000000000000 rs1:5 000000001100111" "asm"="jr {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @FRFLAGS.0(i64 "reg"="x" %rd) "enc"="00000000000100000010 rd:5 1110011" "asm"="frflags {rd}" "asmonly" "nodecode" {
  ret void
}

define void @FSFLAGS.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000000000001 rs1:5 001 rd:5 1110011" "asm"="fsflags {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @FSFLAGSI.0(i64 "reg"="x" %rd, i64 "imm" %zimm5) "enc"="000000000001 zimm5:5 101 rd:5 1110011" "asm"="fsflagsi {rd}, {zimm5}" "asmonly" "nodecode" {
  ret void
}

define void @FRRM.0(i64 "reg"="x" %rd) "enc"="00000000001000000010 rd:5 1110011" "asm"="frrm {rd}" "asmonly" "nodecode" {
  ret void
}

define void @FSRM.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000000000010 rs1:5 001 rd:5 1110011" "asm"="fsrm {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @FSRMI.0(i64 "reg"="x" %rd, i64 "imm" %zimm5) "enc"="000000000010 zimm5:5 101 rd:5 1110011" "asm"="fsrmi {rd}, {zimm5}" "asmonly" "nodecode" {
  ret void
}

define void @FSCSR.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000000000011 rs1:5 001 rd:5 1110011" "asm"="fscsr {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @FRCSR.0(i64 "reg"="x" %rd) "enc"="00000000001100000010 rd:5 1110011" "asm"="frcsr {rd}" "asmonly" "nodecode" {
  ret void
}

define void @CSRR.0(i64 "reg"="x" %rd, i64 "imm" %csr) "enc"="csr:12 00000010 rd:5 1110011" "asm"="csrr {rd}, {csr}" "asmonly" "nodecode" {
  ret void
}

define void @ZEXT_W.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="000010000000 rs1:5 000 rd:5 0111011" "asm"="zext.w {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100000011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.0 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100000011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.1 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_2.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100000011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.2 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_3.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100000011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.3 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_4.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100001011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.4 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_5.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100001011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.5 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_6.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100001011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.6 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_7.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100001011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.7 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_8.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100010011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.8 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_9.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100010011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.9 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_10.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100010011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.10 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_11.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100010011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.11 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_12.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100011011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.12 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_13.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100011011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.13 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_14.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100011011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.14 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_15.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="100011011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.15 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_16.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110000011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.16 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_17.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110000011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.17 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_18.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110000011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.18 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_19.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110000011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.19 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_20.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110001011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.20 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_21.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110001011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.21 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_22.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110001011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.22 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_23.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110001011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.23 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_24.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110010011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.24 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_25.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110010011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.25 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_26.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110010011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.26 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_27.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110010011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.27 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_28.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110011011100 rs1:5 100 rd:5 1110011" "asm"="mop.r.28 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_29.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110011011101 rs1:5 100 rd:5 1110011" "asm"="mop.r.29 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_30.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110011011110 rs1:5 100 rd:5 1110011" "asm"="mop.r.30 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_R_31.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1) "enc"="110011011111 rs1:5 100 rd:5 1110011" "asm"="mop.r.31 {rd}, {rs1}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_0.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000001 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.0 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_1.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000011 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.1 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_2.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000101 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.2 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_3.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1000111 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.3 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_4.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100001 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.4 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_5.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100011 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.5 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_6.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100101 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.6 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @MOP_RR_7.0(i64 "reg"="x" %rd, i64 "reg"="x" %rs1, i64 "reg"="x" %rs2) "enc"="1100111 rs2:5 rs1:5 100 rd:5 1110011" "asm"="mop.rr.7 {rd}, {rs1}, {rs2}" "asmonly" "nodecode" {
  ret void
}

define void @RDCYCLE.0(i64 "reg"="x" %rd) "enc"="11000000000000000010 rd:5 1110011" "asm"="rdcycle {rd}" "asmonly" "nodecode" {
  ret void
}

define void @RDTIME.0(i64 "reg"="x" %rd) "enc"="11000000000100000010 rd:5 1110011" "asm"="rdtime {rd}" "asmonly" "nodecode" {
  ret void
}

define void @RDINSTRET.0(i64 "reg"="x" %rd) "enc"="11000000001000000010 rd:5 1110011" "asm"="rdinstret {rd}" "asmonly" "nodecode" {
  ret void
}

define void @LPAD.0(i64 "imm" %imm20) "enc"="imm20:20 000000010111" "asm"="lpad {imm20}" "asmonly" "nodecode" {
  ret void
}

