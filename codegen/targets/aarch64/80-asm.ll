; Entries for assembly and disassembly only ("asmonly"), written by
; gen_mrs_asm.py: the A64 instructions (base, floating point and Advanced
; SIMD) the rest of the description does not have. Their bit layouts and
; assembly syntax are from Arm's A-profile Architecture Machine Readable
; Specification (AARCHMRS, 2026-09_rel), under this license:
;
; Copyright 2010-2026 Arm Limited or its affiliates.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Neither the name of the copyright holder nor the names of its
;    contributors may be used to endorse or promote products derived from
;    this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;
; How each operand is held in its fields is not in the open-source
; specification: it was found by assembling lines with clang and reading
; the fields back. Each entry's words, for every line tried, are clang's.

define void @ADR_only_pcreladdr.0(i64 "reg"="x" %xd, ptr "label" %label) "enc"="0 label1:2=label&3 10000 label2:s19=label>>2 xd:5" "asm"="adr {xd}, {label}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_imm.0(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0001000101 imm:12 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, #{imm}, lsl #12" "asmonly" "aliases"="mov" {
  ret void
}

define void @ADDS_32S_addsub_imm.0(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0011000100 imm:12 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, #{imm}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_imm.1(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0011000100 imm:12 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, #{imm}, lsl #0" "asmonly" "nodecode" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_imm.2(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0011000101 imm:12 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, #{imm}, lsl #12" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_imm.CMN.0(i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0011000101 imm:12 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, #{imm}, lsl #12" "asmonly" "nodecode" {
  ret void
}

define void @SUB_32_addsub_imm.0(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0101000101 imm:12 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, #{imm}, lsl #12" "asmonly" {
  ret void
}

define void @SUBS_32S_addsub_imm.0(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0111000100 imm:12 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, #{imm}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_imm.1(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0111000100 imm:12 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, #{imm}, lsl #0" "asmonly" "nodecode" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_imm.2(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0111000101 imm:12 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, #{imm}, lsl #12" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_imm.CMP.0(i64 "reg"="wsp" %wn_wsp, i64 "imm" %imm) "enc"="0111000101 imm:12 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, #{imm}, lsl #12" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_64S_addsub_imm.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1011000100 imm:12 xn_sp:5 xd:5" "asm"="adds {xd}, {xn_sp}, #{imm}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64S_addsub_imm.1(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1011000100 imm:12 xn_sp:5 xd:5" "asm"="adds {xd}, {xn_sp}, #{imm}, lsl #0" "asmonly" "nodecode" "aliases"="cmn" {
  ret void
}

define void @ADDS_64S_addsub_imm.2(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1011000101 imm:12 xn_sp:5 xd:5" "asm"="adds {xd}, {xn_sp}, #{imm}, lsl #12" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64S_addsub_imm.CMN.0(i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1011000101 imm:12 xn_sp:5 11111" "asm"="cmn {xn_sp}, #{imm}, lsl #12" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64S_addsub_imm.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1111000100 imm:12 xn_sp:5 xd:5" "asm"="subs {xd}, {xn_sp}, #{imm}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_64S_addsub_imm.1(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1111000100 imm:12 xn_sp:5 xd:5" "asm"="subs {xd}, {xn_sp}, #{imm}, lsl #0" "asmonly" "nodecode" "aliases"="cmp" {
  ret void
}

define void @SUBS_64S_addsub_imm.2(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1111000101 imm:12 xn_sp:5 xd:5" "asm"="subs {xd}, {xn_sp}, #{imm}, lsl #12" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_64S_addsub_imm.CMP.0(i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1111000101 imm:12 xn_sp:5 11111" "asm"="cmp {xn_sp}, #{imm}, lsl #12" "asmonly" "nodecode" {
  ret void
}

define void @ADDG_64_addsub_immtags.0(i64 "reg"="xsp" %xd_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %uimm6, i64 "imm" %uimm4) "enc"="10010001100 uimm6_f:5=uimm6>>4 00 uimm4:4 xn_sp:5 xd_sp:5" "asm"="addg {xd_sp}, {xn_sp}, #{uimm6}, #{uimm4}" "asmonly" {
  ret void
}

define void @SUBG_64_addsub_immtags.0(i64 "reg"="xsp" %xd_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %uimm6, i64 "imm" %uimm4) "enc"="11010001100 uimm6_f:5=uimm6>>4 00 uimm4:4 xn_sp:5 xd_sp:5" "asm"="subg {xd_sp}, {xn_sp}, #{uimm6}, #{uimm4}" "asmonly" {
  ret void
}

define void @SMAX_32_minmax_imm.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %simm) "enc"="00010001110000 simm:s8 wn:5 wd:5" "asm"="smax {wd}, {wn}, #{simm}" "asmonly" {
  ret void
}

define void @UMAX_32U_minmax_imm.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %uimm) "enc"="00010001110001 uimm:8 wn:5 wd:5" "asm"="umax {wd}, {wn}, #{uimm}" "asmonly" {
  ret void
}

define void @SMIN_32_minmax_imm.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %simm) "enc"="00010001110010 simm:s8 wn:5 wd:5" "asm"="smin {wd}, {wn}, #{simm}" "asmonly" {
  ret void
}

define void @UMIN_32U_minmax_imm.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %uimm) "enc"="00010001110011 uimm:8 wn:5 wd:5" "asm"="umin {wd}, {wn}, #{uimm}" "asmonly" {
  ret void
}

define void @SMAX_64_minmax_imm.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %simm) "enc"="10010001110000 simm:s8 xn:5 xd:5" "asm"="smax {xd}, {xn}, #{simm}" "asmonly" {
  ret void
}

define void @UMAX_64U_minmax_imm.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %uimm) "enc"="10010001110001 uimm:8 xn:5 xd:5" "asm"="umax {xd}, {xn}, #{uimm}" "asmonly" {
  ret void
}

define void @SMIN_64_minmax_imm.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %simm) "enc"="10010001110010 simm:s8 xn:5 xd:5" "asm"="smin {xd}, {xn}, #{simm}" "asmonly" {
  ret void
}

define void @UMIN_64U_minmax_imm.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %uimm) "enc"="10010001110011 uimm:8 xn:5 xd:5" "asm"="umin {xd}, {xn}, #{uimm}" "asmonly" {
  ret void
}

define void @MOVN_32_movewide.0(i64 "reg"="w" %wd, i64 "imm" %imm, i64 "imm" %shift) "enc"="0001001010 shift_f:1=shift>>4 imm:16 wd:5" "asm"="movn {wd}, #{imm}, lsl #{shift}" "asmonly" "aliases"="mov" {
  ret void
}

define void @MOVN_64_movewide.0(i64 "reg"="x" %xd, i64 "imm" %imm, i64 "imm" %shift) "enc"="100100101 shift_f:2=shift>>4 imm:16 xd:5" "asm"="movn {xd}, #{imm}, lsl #{shift}" "asmonly" "aliases"="mov" {
  ret void
}

define void @SBFM_32M_bitfield.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %immr, i64 "imm" %imms) "enc"="00010011000 immr:5 0 imms:5 wn:5 wd:5" "asm"="sbfm {wd}, {wn}, #{immr}, #{imms}" "asmonly" "aliases"="asr,sbfiz,sbfx,sxtb,sxth" {
  ret void
}

define void @SBFM_32M_bitfield.SBFIZ.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %lsb, i64 "imm" %width) "enc"="00010011000 lsb_f:5=(32-lsb) 0 width_f:5=(width-1) wn:5 wd:5" "asm"="sbfiz {wd}, {wn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @SBFM_32M_bitfield.SBFX.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %lsb, i64 "imm" %width) "enc"="00010011000 immr_f:5=lsb 0 imms_f:5=(lsb+width-1) wn:5 wd:5" "asm"="sbfx {wd}, {wn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_32M_bitfield.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %immr, i64 "imm" %imms) "enc"="00110011000 immr:5 0 imms:5 wn:5 wd:5" "asm"="bfm {wd}, {wn}, #{immr}, #{imms}" "asmonly" "aliases"="bfc,bfi,bfxil" {
  ret void
}

define void @BFM_32M_bitfield.BFXIL.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %lsb, i64 "imm" %width) "enc"="00110011000 immr_f:5=lsb 0 imms_f:5=(lsb+width-1) wn:5 wd:5" "asm"="bfxil {wd}, {wn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_32M_bitfield.BFI.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "imm" %lsb, i64 "imm" %width) "enc"="00110011000 lsb_f:5=(32-lsb) 0 width_f:5=(width-1) wn:5 wd:5" "asm"="bfi {wd}, {wn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_32M_bitfield.BFC.0(i64 "reg"="w" %wd, i64 "imm" %lsb, i64 "imm" %width) "enc"="00110011000 lsb_f:5=(32-lsb) 0 width_f:5=(width-1) 11111 wd:5" "asm"="bfc {wd}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @SBFM_64M_bitfield.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %immr, i64 "imm" %imms) "enc"="1001001101 immr:6 imms:6 xn:5 xd:5" "asm"="sbfm {xd}, {xn}, #{immr}, #{imms}" "asmonly" "aliases"="asr,sbfiz,sbfx,sxtb,sxth,sxtw" {
  ret void
}

define void @SBFM_64M_bitfield.SBFIZ.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %lsb, i64 "imm" %width) "enc"="1001001101 lsb_f:6=(64-lsb) width_f:6=(width-1) xn:5 xd:5" "asm"="sbfiz {xd}, {xn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @SBFM_64M_bitfield.SBFX.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %lsb, i64 "imm" %width) "enc"="1001001101 immr_f:6=lsb imms_f:6=(lsb+width-1) xn:5 xd:5" "asm"="sbfx {xd}, {xn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_64M_bitfield.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %immr, i64 "imm" %imms) "enc"="1011001101 immr:6 imms:6 xn:5 xd:5" "asm"="bfm {xd}, {xn}, #{immr}, #{imms}" "asmonly" "aliases"="bfc,bfi,bfxil" {
  ret void
}

define void @BFM_64M_bitfield.BFXIL.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %lsb, i64 "imm" %width) "enc"="1011001101 immr_f:6=lsb imms_f:6=(lsb+width-1) xn:5 xd:5" "asm"="bfxil {xd}, {xn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_64M_bitfield.BFI.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "imm" %lsb, i64 "imm" %width) "enc"="1011001101 lsb_f:6=(64-lsb) width_f:6=(width-1) xn:5 xd:5" "asm"="bfi {xd}, {xn}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BFM_64M_bitfield.BFC.0(i64 "reg"="x" %xd, i64 "imm" %lsb, i64 "imm" %width) "enc"="1011001101 lsb_f:6=(64-lsb) width_f:6=(width-1) 11111 xd:5" "asm"="bfc {xd}, #{lsb}, #{width}" "asmonly" "nodecode" {
  ret void
}

define void @BC_only_condbranch.0(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10000" "asm"="bc.eq {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.1(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10001" "asm"="bc.ne {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.2(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10010" "asm"="bc.cs {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.3(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10010" "asm"="bc.hs {label}" "asmonly" "nodecode" {
  ret void
}

define void @BC_only_condbranch.4(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10011" "asm"="bc.cc {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.5(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10011" "asm"="bc.lo {label}" "asmonly" "nodecode" {
  ret void
}

define void @BC_only_condbranch.6(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10100" "asm"="bc.mi {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.7(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10101" "asm"="bc.pl {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.8(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10110" "asm"="bc.vs {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.9(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 10111" "asm"="bc.vc {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.10(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11000" "asm"="bc.hi {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.11(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11001" "asm"="bc.ls {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.12(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11010" "asm"="bc.ge {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.13(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11011" "asm"="bc.lt {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.14(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11100" "asm"="bc.gt {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.15(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11101" "asm"="bc.le {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.16(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11110" "asm"="bc.al {label}" "asmonly" {
  ret void
}

define void @BC_only_condbranch.17(ptr "label" %label) "enc"="01010100 label_f:s19=label>>2 11111" "asm"="bc.nv {label}" "asmonly" {
  ret void
}

define void @CBBGT_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100000 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbgt {wt}, {wm}, {label}" "asmonly" "aliases"="cbblt" {
  ret void
}

define void @CBBGT_8_regs.CBBLT.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100000 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbblt {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBBGE_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100001 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbge {wt}, {wm}, {label}" "asmonly" "aliases"="cbble" {
  ret void
}

define void @CBBGE_8_regs.CBBLE.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100001 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbble {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBBHI_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100010 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbhi {wt}, {wm}, {label}" "asmonly" "aliases"="cbblo" {
  ret void
}

define void @CBBHI_8_regs.CBBLO.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100010 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbblo {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBBHS_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100011 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbhs {wt}, {wm}, {label}" "asmonly" "aliases"="cbbls" {
  ret void
}

define void @CBBHS_8_regs.CBBLS.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100011 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbls {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBBEQ_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100110 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbeq {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @CBBNE_8_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100111 wm:5 10 label_f:s9=label>>2 wt:5" "asm"="cbbne {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @CBHGT_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100000 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhgt {wt}, {wm}, {label}" "asmonly" "aliases"="cbhlt" {
  ret void
}

define void @CBHGT_16_regs.CBHLT.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100000 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhlt {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHGE_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100001 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhge {wt}, {wm}, {label}" "asmonly" "aliases"="cbhle" {
  ret void
}

define void @CBHGE_16_regs.CBHLE.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100001 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhle {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHHI_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100010 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhhi {wt}, {wm}, {label}" "asmonly" "aliases"="cbhlo" {
  ret void
}

define void @CBHHI_16_regs.CBHLO.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100010 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhlo {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHHS_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100011 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhhs {wt}, {wm}, {label}" "asmonly" "aliases"="cbhls" {
  ret void
}

define void @CBHHS_16_regs.CBHLS.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100011 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhls {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHEQ_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100110 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbheq {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @CBHNE_16_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100111 wm:5 11 label_f:s9=label>>2 wt:5" "asm"="cbhne {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @SVC_EX_exception.0(i64 "imm" %imm) "enc"="11010100000 imm:16 00001" "asm"="svc #{imm}" "asmonly" {
  ret void
}

define void @HVC_EX_exception.0(i64 "imm" %imm) "enc"="11010100000 imm:16 00010" "asm"="hvc #{imm}" "asmonly" {
  ret void
}

define void @SMC_EX_exception.0(i64 "imm" %imm) "enc"="11010100000 imm:16 00011" "asm"="smc #{imm}" "asmonly" {
  ret void
}

define void @BRK_EX_exception.0(i64 "imm" %imm) "enc"="11010100001 imm:16 00000" "asm"="brk #{imm}" "asmonly" {
  ret void
}

define void @HLT_EX_exception.0(i64 "imm" %imm) "enc"="11010100010 imm:16 00000" "asm"="hlt #{imm}" "asmonly" {
  ret void
}

define void @DCPS1_DC_exception.0() "enc"="11010100101000000000000000000001" "asm"="dcps1" "asmonly" {
  ret void
}

define void @DCPS1_DC_exception.1(i64 "imm" %imm) "enc"="11010100101 imm:16 00001" "asm"="dcps1 #{imm}" "asmonly" {
  ret void
}

define void @DCPS2_DC_exception.0() "enc"="11010100101000000000000000000010" "asm"="dcps2" "asmonly" {
  ret void
}

define void @DCPS2_DC_exception.1(i64 "imm" %imm) "enc"="11010100101 imm:16 00010" "asm"="dcps2 #{imm}" "asmonly" {
  ret void
}

define void @DCPS3_DC_exception.0() "enc"="11010100101000000000000000000011" "asm"="dcps3" "asmonly" {
  ret void
}

define void @DCPS3_DC_exception.1(i64 "imm" %imm) "enc"="11010100101 imm:16 00011" "asm"="dcps3 #{imm}" "asmonly" {
  ret void
}

define void @WFET_only_systeminstrswithreg.0(i64 "reg"="x" %xt) "enc"="110101010000001100010000000 xt:5" "asm"="wfet {xt}" "asmonly" {
  ret void
}

define void @WFIT_only_systeminstrswithreg.0(i64 "reg"="x" %xt) "enc"="110101010000001100010000001 xt:5" "asm"="wfit {xt}" "asmonly" {
  ret void
}

define void @NOP_HI_hints.0() "enc"="11010101000000110010000000011111" "asm"="nop" "asmonly" {
  ret void
}

define void @YIELD_HI_hints.0() "enc"="11010101000000110010000000111111" "asm"="yield" "asmonly" {
  ret void
}

define void @WFE_HI_hints.0() "enc"="11010101000000110010000001011111" "asm"="wfe" "asmonly" {
  ret void
}

define void @WFI_HI_hints.0() "enc"="11010101000000110010000001111111" "asm"="wfi" "asmonly" {
  ret void
}

define void @SEV_HI_hints.0() "enc"="11010101000000110010000010011111" "asm"="sev" "asmonly" {
  ret void
}

define void @SEVL_HI_hints.0() "enc"="11010101000000110010000010111111" "asm"="sevl" "asmonly" {
  ret void
}

define void @DGH_HI_hints.0() "enc"="11010101000000110010000011011111" "asm"="dgh" "asmonly" {
  ret void
}

define void @XPACLRI_HI_hints.0() "enc"="11010101000000110010000011111111" "asm"="xpaclri" "asmonly" {
  ret void
}

define void @PACIA1716_HI_hints.0() "enc"="11010101000000110010000100011111" "asm"="pacia1716" "asmonly" {
  ret void
}

define void @PACIB1716_HI_hints.0() "enc"="11010101000000110010000101011111" "asm"="pacib1716" "asmonly" {
  ret void
}

define void @AUTIA1716_HI_hints.0() "enc"="11010101000000110010000110011111" "asm"="autia1716" "asmonly" {
  ret void
}

define void @AUTIB1716_HI_hints.0() "enc"="11010101000000110010000111011111" "asm"="autib1716" "asmonly" {
  ret void
}

define void @ESB_HI_hints.0() "enc"="11010101000000110010001000011111" "asm"="esb" "asmonly" {
  ret void
}

define void @TSB_HC_hints.0() "enc"="11010101000000110010001001011111" "asm"="tsb csync" "asmonly" {
  ret void
}

define void @GCSB_HD_hints.0() "enc"="11010101000000110010001001111111" "asm"="gcsb dsync" "asmonly" {
  ret void
}

define void @CSDB_HI_hints.0() "enc"="11010101000000110010001010011111" "asm"="csdb" "asmonly" {
  ret void
}

define void @CLRBHB_HI_hints.0() "enc"="11010101000000110010001011011111" "asm"="clrbhb" "asmonly" {
  ret void
}

define void @PACIAZ_HI_hints.0() "enc"="11010101000000110010001100011111" "asm"="paciaz" "asmonly" {
  ret void
}

define void @PACIASP_HI_hints.0() "enc"="11010101000000110010001100111111" "asm"="paciasp" "asmonly" {
  ret void
}

define void @PACIBZ_HI_hints.0() "enc"="11010101000000110010001101011111" "asm"="pacibz" "asmonly" {
  ret void
}

define void @PACIBSP_HI_hints.0() "enc"="11010101000000110010001101111111" "asm"="pacibsp" "asmonly" {
  ret void
}

define void @AUTIAZ_HI_hints.0() "enc"="11010101000000110010001110011111" "asm"="autiaz" "asmonly" {
  ret void
}

define void @AUTIASP_HI_hints.0() "enc"="11010101000000110010001110111111" "asm"="autiasp" "asmonly" {
  ret void
}

define void @AUTIBZ_HI_hints.0() "enc"="11010101000000110010001111011111" "asm"="autibz" "asmonly" {
  ret void
}

define void @AUTIBSP_HI_hints.0() "enc"="11010101000000110010001111111111" "asm"="autibsp" "asmonly" {
  ret void
}

define void @BTI_HB_hints.0() "enc"="11010101000000110010010000011111" "asm"="bti" "asmonly" {
  ret void
}

define void @BTI_HB_hints.1() "enc"="11010101000000110010010000011111" "asm"="bti r" "asmonly" "nodecode" {
  ret void
}

define void @BTI_HB_hints.2() "enc"="11010101000000110010010001011111" "asm"="bti c" "asmonly" {
  ret void
}

define void @BTI_HB_hints.3() "enc"="11010101000000110010010010011111" "asm"="bti j" "asmonly" {
  ret void
}

define void @BTI_HB_hints.4() "enc"="11010101000000110010010011011111" "asm"="bti jc" "asmonly" {
  ret void
}

define void @PACM_HI_hints.0() "enc"="11010101000000110010010011111111" "asm"="pacm" "asmonly" {
  ret void
}

define void @CHKFEAT_HF_hints.0() "enc"="11010101000000110010010100011111" "asm"="chkfeat x16" "asmonly" {
  ret void
}

define void @HINT_HM_hints.0(i64 "imm" %imm) "enc"="11010101000000110010 imm:7 11111" "asm"="hint #{imm}" "asmonly" {
  ret void
}

define void @CLREX_BN_barriers.0() "enc"="11010101000000110011111101011111" "asm"="clrex" "asmonly" {
  ret void
}

define void @CLREX_BN_barriers.1(i64 "imm" %imm) "enc"="11010101000000110011 imm:4 01011111" "asm"="clrex #{imm}" "asmonly" {
  ret void
}

define void @DSB_BO_barriers.0() "enc"="11010101000000110011111110011111" "asm"="dsb sy" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.1() "enc"="11010101000000110011111010011111" "asm"="dsb st" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.2() "enc"="11010101000000110011110110011111" "asm"="dsb ld" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.3() "enc"="11010101000000110011101110011111" "asm"="dsb ish" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.4() "enc"="11010101000000110011101010011111" "asm"="dsb ishst" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.5() "enc"="11010101000000110011100110011111" "asm"="dsb ishld" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.6() "enc"="11010101000000110011011110011111" "asm"="dsb nsh" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.7() "enc"="11010101000000110011011010011111" "asm"="dsb nshst" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.8() "enc"="11010101000000110011010110011111" "asm"="dsb nshld" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.9() "enc"="11010101000000110011001110011111" "asm"="dsb osh" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.10() "enc"="11010101000000110011001010011111" "asm"="dsb oshst" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.11() "enc"="11010101000000110011000110011111" "asm"="dsb oshld" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.12(i64 "imm" %imm) "enc"="11010101000000110011 imm:4 10011111" "asm"="dsb #{imm}" "asmonly" "aliases"="pssbb,ssbb" {
  ret void
}

define void @DSB_BO_barriers.PSSBB.0() "enc"="11010101000000110011010010011111" "asm"="pssbb" "asmonly" "nodecode" {
  ret void
}

define void @DSB_BO_barriers.SSBB.0() "enc"="11010101000000110011000010011111" "asm"="ssbb" "asmonly" "nodecode" {
  ret void
}

define void @DMB_BO_barriers.0() "enc"="11010101000000110011111110111111" "asm"="dmb sy" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.1() "enc"="11010101000000110011111010111111" "asm"="dmb st" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.2() "enc"="11010101000000110011110110111111" "asm"="dmb ld" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.3() "enc"="11010101000000110011101010111111" "asm"="dmb ishst" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.4() "enc"="11010101000000110011011110111111" "asm"="dmb nsh" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.5() "enc"="11010101000000110011011010111111" "asm"="dmb nshst" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.6() "enc"="11010101000000110011010110111111" "asm"="dmb nshld" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.7() "enc"="11010101000000110011001110111111" "asm"="dmb osh" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.8() "enc"="11010101000000110011001010111111" "asm"="dmb oshst" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.9() "enc"="11010101000000110011000110111111" "asm"="dmb oshld" "asmonly" {
  ret void
}

define void @DMB_BO_barriers.10(i64 "imm" %imm) "enc"="11010101000000110011 imm:4 10111111" "asm"="dmb #{imm}" "asmonly" {
  ret void
}

define void @ISB_BI_barriers.0() "enc"="11010101000000110011111111011111" "asm"="isb" "asmonly" {
  ret void
}

define void @ISB_BI_barriers.1() "enc"="11010101000000110011111111011111" "asm"="isb sy" "asmonly" "nodecode" {
  ret void
}

define void @ISB_BI_barriers.2(i64 "imm" %imm) "enc"="11010101000000110011 imm:4 11011111" "asm"="isb #{imm}" "asmonly" {
  ret void
}

define void @SB_only_barriers.0() "enc"="11010101000000110011000011111111" "asm"="sb" "asmonly" {
  ret void
}

define void @DSB_BOn_barriers.0() "enc"="11010101000000110011111000111111" "asm"="dsb synxs" "asmonly" {
  ret void
}

define void @DSB_BOn_barriers.1() "enc"="11010101000000110011101000111111" "asm"="dsb ishnxs" "asmonly" {
  ret void
}

define void @DSB_BOn_barriers.2() "enc"="11010101000000110011011000111111" "asm"="dsb nshnxs" "asmonly" {
  ret void
}

define void @DSB_BOn_barriers.3() "enc"="11010101000000110011001000111111" "asm"="dsb oshnxs" "asmonly" {
  ret void
}

define void @MSR_SI_pstate.0(i64 "imm" %imm) "enc"="11010101000000000100 imm:4 01111111" "asm"="msr uao, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.1(i64 "imm" %imm) "enc"="11010101000000000100 imm:4 10011111" "asm"="msr pan, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.2(i64 "imm" %imm) "enc"="11010101000000000100 imm:4 10111111" "asm"="msr spsel, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.3(i64 "imm" %imm) "enc"="11010101000000010100000 imm:1 00011111" "asm"="msr allint, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.4(i64 "imm" %imm) "enc"="11010101000000010100001 imm:1 00011111" "asm"="msr pm, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.5(i64 "imm" %imm) "enc"="11010101000000110100 imm:4 00111111" "asm"="msr ssbs, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.6(i64 "imm" %imm) "enc"="11010101000000110100 imm:4 01011111" "asm"="msr dit, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.7(i64 "imm" %imm) "enc"="11010101000000110100 imm:4 10011111" "asm"="msr tco, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.8(i64 "imm" %imm) "enc"="11010101000000110100 imm:4 11011111" "asm"="msr daifset, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.9(i64 "imm" %imm) "enc"="11010101000000110100 imm:4 11111111" "asm"="msr daifclr, #{imm}" "asmonly" "aliases"="smstart,smstop" {
  ret void
}

define void @MSR_SI_pstate.SMSTART.0() "enc"="11010101000000110100011101111111" "asm"="smstart" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SI_pstate.SMSTART.1() "enc"="11010101000000110100001101111111" "asm"="smstart sm" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SI_pstate.SMSTART.2() "enc"="11010101000000110100010101111111" "asm"="smstart za" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SI_pstate.SMSTOP.0() "enc"="11010101000000110100011001111111" "asm"="smstop" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SI_pstate.SMSTOP.1() "enc"="11010101000000110100001001111111" "asm"="smstop sm" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SI_pstate.SMSTOP.2() "enc"="11010101000000110100010001111111" "asm"="smstop za" "asmonly" "nodecode" {
  ret void
}

define void @CFINV_M_pstate.0() "enc"="11010101000000000100000000011111" "asm"="cfinv" "asmonly" {
  ret void
}

define void @XAFLAG_M_pstate.0() "enc"="11010101000000000100000000111111" "asm"="xaflag" "asmonly" {
  ret void
}

define void @AXFLAG_M_pstate.0() "enc"="11010101000000000100000001011111" "asm"="axflag" "asmonly" {
  ret void
}

define void @SYS_CR_systeminstrs.0(i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2) "enc"="1101010100001 op1:3 cn:4 cm:4 op2:3 11111" "asm"="sys #{op1}, c{cn}, c{cm}, #{op2}" "asmonly" "aliases"="apas,at,brb,cfp,cosp,cpp,dc,dvp,gcspopcx,gcspopx,gcspushm,gcspushx,gcsss1,gic,gsb,ic,plbi,tlbi,trcit" {
  ret void
}

define void @SYS_CR_systeminstrs.1(i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2, i64 "reg"="x" %xt) "enc"="1101010100001 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="sys #{op1}, c{cn}, c{cm}, #{op2}, {xt}" "asmonly" "aliases"="apas,at,brb,cfp,cosp,cpp,dc,dvp,gcspopcx,gcspopx,gcspushm,gcspushx,gcsss1,gic,gsb,ic,plbi,tlbi,trcit" {
  ret void
}

define void @SYS_CR_systeminstrs.COSP.0(i64 "reg"="x" %xt) "enc"="110101010000101101110011110 xt:5" "asm"="cosp rctx, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.TRCIT.0(i64 "reg"="x" %xt) "enc"="110101010000101101110010111 xt:5" "asm"="trcit {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.0(i64 "reg"="x" %xt) "enc"="110101010000100001110110001 xt:5" "asm"="dc ivac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.1(i64 "reg"="x" %xt) "enc"="110101010000100001110110010 xt:5" "asm"="dc isw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.2(i64 "reg"="x" %xt) "enc"="110101010000100001110110011 xt:5" "asm"="dc igvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.3(i64 "reg"="x" %xt) "enc"="110101010000100001110110100 xt:5" "asm"="dc igsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.4(i64 "reg"="x" %xt) "enc"="110101010000100001110110101 xt:5" "asm"="dc igdvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.5(i64 "reg"="x" %xt) "enc"="110101010000100001110110110 xt:5" "asm"="dc igdsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.6(i64 "reg"="x" %xt) "enc"="110101010000100001111010010 xt:5" "asm"="dc csw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.7(i64 "reg"="x" %xt) "enc"="110101010000100001111010100 xt:5" "asm"="dc cgsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.8(i64 "reg"="x" %xt) "enc"="110101010000100001111010110 xt:5" "asm"="dc cgdsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.9(i64 "reg"="x" %xt) "enc"="110101010000100001111110010 xt:5" "asm"="dc cisw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.10(i64 "reg"="x" %xt) "enc"="110101010000100001111110100 xt:5" "asm"="dc cigsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.11(i64 "reg"="x" %xt) "enc"="110101010000100001111110110 xt:5" "asm"="dc cigdsw, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.12(i64 "reg"="x" %xt) "enc"="110101010000101101110100001 xt:5" "asm"="dc zva, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.13(i64 "reg"="x" %xt) "enc"="110101010000101101110100011 xt:5" "asm"="dc gva, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.14(i64 "reg"="x" %xt) "enc"="110101010000101101110100100 xt:5" "asm"="dc gzva, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.15(i64 "reg"="x" %xt) "enc"="110101010000101101111010001 xt:5" "asm"="dc cvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.16(i64 "reg"="x" %xt) "enc"="110101010000101101111010011 xt:5" "asm"="dc cgvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.17(i64 "reg"="x" %xt) "enc"="110101010000101101111010101 xt:5" "asm"="dc cgdvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.18(i64 "reg"="x" %xt) "enc"="110101010000101101111011001 xt:5" "asm"="dc cvau, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.19(i64 "reg"="x" %xt) "enc"="110101010000101101111100001 xt:5" "asm"="dc cvap, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.20(i64 "reg"="x" %xt) "enc"="110101010000101101111100011 xt:5" "asm"="dc cgvap, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.21(i64 "reg"="x" %xt) "enc"="110101010000101101111100101 xt:5" "asm"="dc cgdvap, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.22(i64 "reg"="x" %xt) "enc"="110101010000101101111101001 xt:5" "asm"="dc cvadp, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.23(i64 "reg"="x" %xt) "enc"="110101010000101101111101011 xt:5" "asm"="dc cgvadp, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.24(i64 "reg"="x" %xt) "enc"="110101010000101101111101101 xt:5" "asm"="dc cgdvadp, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.25(i64 "reg"="x" %xt) "enc"="110101010000101101111110001 xt:5" "asm"="dc civac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.26(i64 "reg"="x" %xt) "enc"="110101010000101101111110011 xt:5" "asm"="dc cigvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.27(i64 "reg"="x" %xt) "enc"="110101010000101101111110101 xt:5" "asm"="dc cigdvac, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.28(i64 "reg"="x" %xt) "enc"="110101010000110001111110000 xt:5" "asm"="dc cipae, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.29(i64 "reg"="x" %xt) "enc"="110101010000110001111110111 xt:5" "asm"="dc cigdpae, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.30(i64 "reg"="x" %xt) "enc"="110101010000111001111110001 xt:5" "asm"="dc cipapa, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.31(i64 "reg"="x" %xt) "enc"="110101010000111001111110101 xt:5" "asm"="dc cigdpapa, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.32(i64 "reg"="x" %xt) "enc"="110101010000101101111111000 xt:5" "asm"="dc civaoc, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.33(i64 "reg"="x" %xt) "enc"="110101010000101101111011000 xt:5" "asm"="dc cvaoc, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.34(i64 "reg"="x" %xt) "enc"="110101010000101101111011111 xt:5" "asm"="dc cgdvaoc, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DC.35(i64 "reg"="x" %xt) "enc"="110101010000101101111111111 xt:5" "asm"="dc cigdvaoc, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.CFP.0(i64 "reg"="x" %xt) "enc"="110101010000101101110011100 xt:5" "asm"="cfp rctx, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.IC.0() "enc"="11010101000010000111000100011111" "asm"="ic ialluis" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.IC.1() "enc"="11010101000010000111010100011111" "asm"="ic iallu" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.IC.2(i64 "reg"="x" %xt) "enc"="110101010000101101110101001 xt:5" "asm"="ic ivau, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.GCSPUSHX.0() "enc"="11010101000010000111011110011111" "asm"="gcspushx" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.GCSPUSHM.0(i64 "reg"="x" %xt) "enc"="110101010000101101110111000 xt:5" "asm"="gcspushm {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.0(i64 "reg"="x" %xt) "enc"="110101010000100001111000000 xt:5" "asm"="at s1e1r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.1(i64 "reg"="x" %xt) "enc"="110101010000100001111000001 xt:5" "asm"="at s1e1w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.2(i64 "reg"="x" %xt) "enc"="110101010000100001111000010 xt:5" "asm"="at s1e0r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.3(i64 "reg"="x" %xt) "enc"="110101010000100001111000011 xt:5" "asm"="at s1e0w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.4(i64 "reg"="x" %xt) "enc"="110101010000100001111001000 xt:5" "asm"="at s1e1rp, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.5(i64 "reg"="x" %xt) "enc"="110101010000100001111001001 xt:5" "asm"="at s1e1wp, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.6(i64 "reg"="x" %xt) "enc"="110101010000100001111001010 xt:5" "asm"="at s1e1a, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.7(i64 "reg"="x" %xt) "enc"="110101010000110001111000000 xt:5" "asm"="at s1e2r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.8(i64 "reg"="x" %xt) "enc"="110101010000110001111000001 xt:5" "asm"="at s1e2w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.9(i64 "reg"="x" %xt) "enc"="110101010000110001111000100 xt:5" "asm"="at s12e1r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.10(i64 "reg"="x" %xt) "enc"="110101010000110001111000101 xt:5" "asm"="at s12e1w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.11(i64 "reg"="x" %xt) "enc"="110101010000110001111000110 xt:5" "asm"="at s12e0r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.12(i64 "reg"="x" %xt) "enc"="110101010000110001111000111 xt:5" "asm"="at s12e0w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.13(i64 "reg"="x" %xt) "enc"="110101010000110001111001010 xt:5" "asm"="at s1e2a, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.14(i64 "reg"="x" %xt) "enc"="110101010000111001111000000 xt:5" "asm"="at s1e3r, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.15(i64 "reg"="x" %xt) "enc"="110101010000111001111000001 xt:5" "asm"="at s1e3w, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.AT.16(i64 "reg"="x" %xt) "enc"="110101010000111001111001010 xt:5" "asm"="at s1e3a, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.BRB.0() "enc"="11010101000010010111001010011111" "asm"="brb iall" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.BRB.1() "enc"="11010101000010010111001010111111" "asm"="brb inj" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.GCSSS1.0(i64 "reg"="x" %xt) "enc"="110101010000101101110111010 xt:5" "asm"="gcsss1 {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.GCSPOPCX.0() "enc"="11010101000010000111011110111111" "asm"="gcspopcx" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.DVP.0(i64 "reg"="x" %xt) "enc"="110101010000101101110011101 xt:5" "asm"="dvp rctx, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.CPP.0(i64 "reg"="x" %xt) "enc"="110101010000101101110011111 xt:5" "asm"="cpp rctx, {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.GCSPOPX.0() "enc"="11010101000010000111011111011111" "asm"="gcspopx" "asmonly" "nodecode" {
  ret void
}

define void @SYS_CR_systeminstrs.APAS.0(i64 "reg"="x" %xt) "enc"="110101010000111001110000000 xt:5" "asm"="apas {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYSL_RC_systeminstrs.0(i64 "reg"="x" %xt, i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2) "enc"="1101010100101 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="sysl {xt}, #{op1}, c{cn}, c{cm}, #{op2}" "asmonly" "aliases"="gcspopm,gcsss2,gicr" {
  ret void
}

define void @SYSL_RC_systeminstrs.GCSPOPM.0() "enc"="11010101001010110111011100111111" "asm"="gcspopm" "asmonly" "nodecode" {
  ret void
}

define void @SYSL_RC_systeminstrs.GCSPOPM.1(i64 "reg"="x" %xt) "enc"="110101010010101101110111001 xt:5" "asm"="gcspopm {xt}" "asmonly" "nodecode" {
  ret void
}

define void @SYSL_RC_systeminstrs.GCSSS2.0(i64 "reg"="x" %xt) "enc"="110101010010101101110111011 xt:5" "asm"="gcsss2 {xt}" "asmonly" "nodecode" {
  ret void
}

define void @MSR_SR_systemmove.0(i64 "reg"="x" %xt) "enc"="110101010001111000010000001 xt:5" "asm"="msr actlr_el3, {xt}" "asmonly" {
  ret void
}

define void @MSR_SR_systemmove.1(i64 "reg"="x" %xt) "enc"="110101010001110000010000001 xt:5" "asm"="msr actlr_el2, {xt}" "asmonly" {
  ret void
}

define void @MSR_SR_systemmove.2(i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2, i64 "reg"="x" %xt) "enc"="1101010100010 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="msr s2_{op1}_c{cn}_c{cm}_{op2}, {xt}" "asmonly" {
  ret void
}

define void @MSR_SR_systemmove.3(i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2, i64 "reg"="x" %xt) "enc"="1101010100011 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="msr s3_{op1}_c{cn}_c{cm}_{op2}, {xt}" "asmonly" {
  ret void
}

define void @MRS_RS_systemmove.0(i64 "reg"="x" %xt) "enc"="110101010011111000010000001 xt:5" "asm"="mrs {xt}, actlr_el3" "asmonly" {
  ret void
}

define void @MRS_RS_systemmove.1(i64 "reg"="x" %xt) "enc"="110101010011110000010000001 xt:5" "asm"="mrs {xt}, actlr_el2" "asmonly" {
  ret void
}

define void @MRS_RS_systemmove.2(i64 "reg"="x" %xt, i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2) "enc"="1101010100110 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="mrs {xt}, s2_{op1}_c{cn}_c{cm}_{op2}" "asmonly" {
  ret void
}

define void @MRS_RS_systemmove.3(i64 "reg"="x" %xt, i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2) "enc"="1101010100111 op1:3 cn:4 cm:4 op2:3 xt:5" "asm"="mrs {xt}, s3_{op1}_c{cn}_c{cm}_{op2}" "asmonly" {
  ret void
}

define void @SYSP_CR_syspairinstrs.0(i64 "imm" %op1, i64 "imm" %cn, i64 "imm" %cm, i64 "imm" %op2) "enc"="1101010101001 op1:3 cn:4 cm:4 op2:3 11111" "asm"="sysp #{op1}, c{cn}, c{cm}, #{op2}" "asmonly" "aliases"="tlbip" {
  ret void
}

define void @BRAAZ_64_branch_reg.0(i64 "reg"="x" %xn) "enc"="1101011000011111000010 xn:5 11111" "asm"="braaz {xn}" "asmonly" {
  ret void
}

define void @BRABZ_64_branch_reg.0(i64 "reg"="x" %xn) "enc"="1101011000011111000011 xn:5 11111" "asm"="brabz {xn}" "asmonly" {
  ret void
}

define void @BLRAAZ_64_branch_reg.0(i64 "reg"="x" %xn) "enc"="1101011000111111000010 xn:5 11111" "asm"="blraaz {xn}" "asmonly" {
  ret void
}

define void @BLRABZ_64_branch_reg.0(i64 "reg"="x" %xn) "enc"="1101011000111111000011 xn:5 11111" "asm"="blrabz {xn}" "asmonly" {
  ret void
}

define void @RET_64R_branch_reg.0(i64 "reg"="x" %xn) "enc"="1101011001011111000000 xn:5 00000" "asm"="ret {xn}" "asmonly" {
  ret void
}

define void @RETAASPPCR_64M_branch_reg.0(i64 "reg"="x" %xm) "enc"="110101100101111100001011111 xm:5" "asm"="retaasppcr {xm}" "asmonly" {
  ret void
}

define void @RETAA_64E_branch_reg.0() "enc"="11010110010111110000101111111111" "asm"="retaa" "asmonly" {
  ret void
}

define void @RETABSPPCR_64M_branch_reg.0(i64 "reg"="x" %xm) "enc"="110101100101111100001111111 xm:5" "asm"="retabsppcr {xm}" "asmonly" {
  ret void
}

define void @RETAB_64E_branch_reg.0() "enc"="11010110010111110000111111111111" "asm"="retab" "asmonly" {
  ret void
}

define void @ERET_64E_branch_reg.0() "enc"="11010110100111110000001111100000" "asm"="eret" "asmonly" {
  ret void
}

define void @ERETAA_64E_branch_reg.0() "enc"="11010110100111110000101111111111" "asm"="eretaa" "asmonly" {
  ret void
}

define void @ERETAB_64E_branch_reg.0() "enc"="11010110100111110000111111111111" "asm"="eretab" "asmonly" {
  ret void
}

define void @DRPS_64E_branch_reg.0() "enc"="11010110101111110000001111100000" "asm"="drps" "asmonly" {
  ret void
}

define void @BRAA_64P_branch_reg.0(i64 "reg"="x" %xn, i64 "reg"="xsp" %xm_sp) "enc"="1101011100011111000010 xn:5 xm_sp:5" "asm"="braa {xn}, {xm_sp}" "asmonly" {
  ret void
}

define void @BRAB_64P_branch_reg.0(i64 "reg"="x" %xn, i64 "reg"="xsp" %xm_sp) "enc"="1101011100011111000011 xn:5 xm_sp:5" "asm"="brab {xn}, {xm_sp}" "asmonly" {
  ret void
}

define void @BLRAA_64P_branch_reg.0(i64 "reg"="x" %xn, i64 "reg"="xsp" %xm_sp) "enc"="1101011100111111000010 xn:5 xm_sp:5" "asm"="blraa {xn}, {xm_sp}" "asmonly" {
  ret void
}

define void @BLRAB_64P_branch_reg.0(i64 "reg"="x" %xn, i64 "reg"="xsp" %xm_sp) "enc"="1101011100111111000011 xn:5 xm_sp:5" "asm"="blrab {xn}, {xm_sp}" "asmonly" {
  ret void
}

define void @CBGT_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100000 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbgt {wt}, {wm}, {label}" "asmonly" "aliases"="cblt" {
  ret void
}

define void @CBGT_32_regs.CBLT.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100000 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cblt {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBGE_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100001 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbge {wt}, {wm}, {label}" "asmonly" "aliases"="cble" {
  ret void
}

define void @CBGE_32_regs.CBLE.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100001 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cble {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHI_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100010 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbhi {wt}, {wm}, {label}" "asmonly" "aliases"="cblo" {
  ret void
}

define void @CBHI_32_regs.CBLO.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100010 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cblo {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHS_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100011 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbhs {wt}, {wm}, {label}" "asmonly" "aliases"="cbls" {
  ret void
}

define void @CBHS_32_regs.CBLS.0(i64 "reg"="w" %wm, i64 "reg"="w" %wt, ptr "label" %label) "enc"="01110100011 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbls {wm}, {wt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBEQ_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100110 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbeq {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @CBNE_32_regs.0(i64 "reg"="w" %wt, i64 "reg"="w" %wm, ptr "label" %label) "enc"="01110100111 wm:5 00 label_f:s9=label>>2 wt:5" "asm"="cbne {wt}, {wm}, {label}" "asmonly" {
  ret void
}

define void @CBGT_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100000 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbgt {xt}, {xm}, {label}" "asmonly" "aliases"="cblt" {
  ret void
}

define void @CBGT_64_regs.CBLT.0(i64 "reg"="x" %xm, i64 "reg"="x" %xt, ptr "label" %label) "enc"="11110100000 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cblt {xm}, {xt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBGE_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100001 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbge {xt}, {xm}, {label}" "asmonly" "aliases"="cble" {
  ret void
}

define void @CBGE_64_regs.CBLE.0(i64 "reg"="x" %xm, i64 "reg"="x" %xt, ptr "label" %label) "enc"="11110100001 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cble {xm}, {xt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHI_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100010 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbhi {xt}, {xm}, {label}" "asmonly" "aliases"="cblo" {
  ret void
}

define void @CBHI_64_regs.CBLO.0(i64 "reg"="x" %xm, i64 "reg"="x" %xt, ptr "label" %label) "enc"="11110100010 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cblo {xm}, {xt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHS_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100011 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbhs {xt}, {xm}, {label}" "asmonly" "aliases"="cbls" {
  ret void
}

define void @CBHS_64_regs.CBLS.0(i64 "reg"="x" %xm, i64 "reg"="x" %xt, ptr "label" %label) "enc"="11110100011 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbls {xm}, {xt}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBEQ_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100110 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbeq {xt}, {xm}, {label}" "asmonly" {
  ret void
}

define void @CBNE_64_regs.0(i64 "reg"="x" %xt, i64 "reg"="x" %xm, ptr "label" %label) "enc"="11110100111 xm:5 00 label_f:s9=label>>2 xt:5" "asm"="cbne {xt}, {xm}, {label}" "asmonly" {
  ret void
}

define void @CBGT_32_imm.CBGE.0(i64 "reg"="w" %wt, i64 "imm" %immp1, ptr "label" %label) "enc"="01110101000 immp1_f:6=(immp1-1) 0 label_f:s9=label>>2 wt:5" "asm"="cbge {wt}, ##{immp1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBLT_32_imm.CBLE.0(i64 "reg"="w" %wt, i64 "imm" %imms1, ptr "label" %label) "enc"="01110101001 imms1_f:6=(imms1+1) 0 label_f:s9=label>>2 wt:5" "asm"="cble {wt}, ##{imms1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHI_32_imm.CBHS.0(i64 "reg"="w" %wt, i64 "imm" %immp1, ptr "label" %label) "enc"="01110101010 immp1_f:6=(immp1-1) 0 label_f:s9=label>>2 wt:5" "asm"="cbhs {wt}, ##{immp1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBLO_32_imm.CBLS.0(i64 "reg"="w" %wt, i64 "imm" %imms1, ptr "label" %label) "enc"="01110101011 imms1_f:6=(imms1+1) 0 label_f:s9=label>>2 wt:5" "asm"="cbls {wt}, ##{imms1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBGT_64_imm.CBGE.0(i64 "reg"="x" %xt, i64 "imm" %immp1, ptr "label" %label) "enc"="11110101000 immp1_f:6=(immp1-1) 0 label_f:s9=label>>2 xt:5" "asm"="cbge {xt}, ##{immp1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBLT_64_imm.CBLE.0(i64 "reg"="x" %xt, i64 "imm" %imms1, ptr "label" %label) "enc"="11110101001 imms1_f:6=(imms1+1) 0 label_f:s9=label>>2 xt:5" "asm"="cble {xt}, ##{imms1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBHI_64_imm.CBHS.0(i64 "reg"="x" %xt, i64 "imm" %immp1, ptr "label" %label) "enc"="11110101010 immp1_f:6=(immp1-1) 0 label_f:s9=label>>2 xt:5" "asm"="cbhs {xt}, ##{immp1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @CBLO_64_imm.CBLS.0(i64 "reg"="x" %xt, i64 "imm" %imms1, ptr "label" %label) "enc"="11110101011 imms1_f:6=(imms1+1) 0 label_f:s9=label>>2 xt:5" "asm"="cbls {xt}, ##{imms1}, {label}" "asmonly" "nodecode" {
  ret void
}

define void @TBZ_only_testbranch.0(i64 "imm" %imm, ptr "label" %label) "enc"="00110110 imm:5 label_f:s14=label>>2 11111" "asm"="tbz wzr, #{imm}, {label}" "asmonly" {
  ret void
}

define void @TBZ_only_testbranch.1(i64 "reg"="w" %t, i64 "imm" %imm, ptr "label" %label) "enc"="00110110 imm:5 label_f:s14=label>>2 t:5" "asm"="tbz {t}, #{imm}, {label}" "asmonly" {
  ret void
}

define void @TBZ_only_testbranch.2(i64 "imm" %imm, ptr "label" %label) "enc"="imm1:1=(imm>>5)&1 0110110 imm2:5=imm&31 label_f:s14=label>>2 11111" "asm"="tbz xzr, #{imm}, {label}" "asmonly" {
  ret void
}

define void @TBNZ_only_testbranch.0(i64 "imm" %imm, ptr "label" %label) "enc"="00110111 imm:5 label_f:s14=label>>2 11111" "asm"="tbnz wzr, #{imm}, {label}" "asmonly" {
  ret void
}

define void @TBNZ_only_testbranch.1(i64 "reg"="w" %t, i64 "imm" %imm, ptr "label" %label) "enc"="00110111 imm:5 label_f:s14=label>>2 t:5" "asm"="tbnz {t}, #{imm}, {label}" "asmonly" {
  ret void
}

define void @TBNZ_only_testbranch.2(i64 "imm" %imm, ptr "label" %label) "enc"="imm1:1=(imm>>5)&1 0110111 imm2:5=imm&31 label_f:s14=label>>2 11111" "asm"="tbnz xzr, #{imm}, {label}" "asmonly" {
  ret void
}

define void @RCWCAS_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwcas {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCASL_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwcasl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCASA_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwcasa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCASAL_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwcasal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCAS_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwscas {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCASL_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwscasl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCASA_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwscasa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCASAL_C64_rcwcomswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xs:5 000010 xn_sp:5 xt:5" "asm"="rcwscasal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 000100 xn_sp:5 xt1:5" "asm"="ldclrp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 001100 xn_sp:5 xt1:5" "asm"="ldsetp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 100000 xn_sp:5 xt1:5" "asm"="swpp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwclrp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwswpp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwsetp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 000100 xn_sp:5 xt1:5" "asm"="ldclrpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 001100 xn_sp:5 xt1:5" "asm"="ldsetpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 100000 xn_sp:5 xt1:5" "asm"="swppl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwclrpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwswppl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwsetpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 000100 xn_sp:5 xt1:5" "asm"="ldclrpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 001100 xn_sp:5 xt1:5" "asm"="ldsetpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 100000 xn_sp:5 xt1:5" "asm"="swppa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwclrpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwswppa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwsetpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 000100 xn_sp:5 xt1:5" "asm"="ldclrpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 001100 xn_sp:5 xt1:5" "asm"="ldsetpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 100000 xn_sp:5 xt1:5" "asm"="swppal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwclrpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwswppal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwsetpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwsclrp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwsswpp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETP_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwssetp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwsclrpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwsswppl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETPL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwssetpl {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwsclrpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwsswppa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETPA_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwssetpa {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xt2:5 100100 xn_sp:5 xt1:5" "asm"="rcwsclrpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xt2:5 101000 xn_sp:5 xt1:5" "asm"="rcwsswppal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETPAL_128_memop_128.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xt2:5 101100 xn_sp:5 xt1:5" "asm"="rcwssetpal {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CAST_C64_comswap_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001100 xs:5 011111 xn_sp:5 xt:5" "asm"="cast {xs}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @CAST_C64_comswap_unpriv.1(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001100 xs:5 011111 xn_sp:5 xt:5" "asm"="cast {xs}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @CASLT_C64_comswap_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001100 xs:5 111111 xn_sp:5 xt:5" "asm"="caslt {xs}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @CASLT_C64_comswap_unpriv.1(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001100 xs:5 111111 xn_sp:5 xt:5" "asm"="caslt {xs}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @CASAT_C64_comswap_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001110 xs:5 011111 xn_sp:5 xt:5" "asm"="casat {xs}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @CASAT_C64_comswap_unpriv.1(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001110 xs:5 011111 xn_sp:5 xt:5" "asm"="casat {xs}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @CASALT_C64_comswap_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001110 xs:5 111111 xn_sp:5 xt:5" "asm"="casalt {xs}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @CASALT_C64_comswap_unpriv.1(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001110 xs:5 111111 xn_sp:5 xt:5" "asm"="casalt {xs}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @GCSSTR_64_ldst_gcs.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100100011111000011 xn_sp:5 xt:5" "asm"="gcsstr {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @GCSSTTR_64_ldst_gcs.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100100011111000111 xn_sp:5 xt:5" "asm"="gcssttr {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STG_64Spost_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001001 simm_f:s9=simm>>4 01 xn_sp:5 xt_sp:5" "asm"="stg {xt_sp}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @STG_64Soffset_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp) "enc"="1101100100100000000010 xn_sp:5 xt_sp:5" "asm"="stg {xt_sp}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STG_64Soffset_ldsttags.1(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001001 simm_f:s9=simm>>4 10 xn_sp:5 xt_sp:5" "asm"="stg {xt_sp}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STG_64Spre_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001001 simm_f:s9=simm>>4 11 xn_sp:5 xt_sp:5" "asm"="stg {xt_sp}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STZGM_64bulk_ldsttags.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100100100000000000 xn_sp:5 xt:5" "asm"="stzgm {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDG_64Loffset_ldsttags.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100101100000000000 xn_sp:5 xt:5" "asm"="ldg {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDG_64Loffset_ldsttags.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001011 simm_f:s9=simm>>4 00 xn_sp:5 xt:5" "asm"="ldg {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STZG_64Spost_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001011 simm_f:s9=simm>>4 01 xn_sp:5 xt_sp:5" "asm"="stzg {xt_sp}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @STZG_64Soffset_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp) "enc"="1101100101100000000010 xn_sp:5 xt_sp:5" "asm"="stzg {xt_sp}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STZG_64Soffset_ldsttags.1(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001011 simm_f:s9=simm>>4 10 xn_sp:5 xt_sp:5" "asm"="stzg {xt_sp}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STZG_64Spre_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001011 simm_f:s9=simm>>4 11 xn_sp:5 xt_sp:5" "asm"="stzg {xt_sp}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @ST2G_64Spost_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001101 simm_f:s9=simm>>4 01 xn_sp:5 xt_sp:5" "asm"="st2g {xt_sp}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @ST2G_64Soffset_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp) "enc"="1101100110100000000010 xn_sp:5 xt_sp:5" "asm"="st2g {xt_sp}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @ST2G_64Soffset_ldsttags.1(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001101 simm_f:s9=simm>>4 10 xn_sp:5 xt_sp:5" "asm"="st2g {xt_sp}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @ST2G_64Spre_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001101 simm_f:s9=simm>>4 11 xn_sp:5 xt_sp:5" "asm"="st2g {xt_sp}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STGM_64bulk_ldsttags.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100110100000000000 xn_sp:5 xt:5" "asm"="stgm {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STZ2G_64Spost_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001111 simm_f:s9=simm>>4 01 xn_sp:5 xt_sp:5" "asm"="stz2g {xt_sp}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @STZ2G_64Soffset_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp) "enc"="1101100111100000000010 xn_sp:5 xt_sp:5" "asm"="stz2g {xt_sp}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STZ2G_64Soffset_ldsttags.1(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001111 simm_f:s9=simm>>4 10 xn_sp:5 xt_sp:5" "asm"="stz2g {xt_sp}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STZ2G_64Spre_ldsttags.0(i64 "reg"="xsp" %xt_sp, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001111 simm_f:s9=simm>>4 11 xn_sp:5 xt_sp:5" "asm"="stz2g {xt_sp}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDGM_64bulk_ldsttags.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100111100000000000 xn_sp:5 xt:5" "asm"="ldgm {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STXP_SP32_ldstexclp.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000001 ws:5 0 wt2:5 xn_sp:5 wt1:5" "asm"="stxp {ws}, {wt1}, {wt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXP_SP32_ldstexclp.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000001 ws:5 0 wt2:5 xn_sp:5 wt1:5" "asm"="stxp {ws}, {wt1}, {wt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXP_SP32_ldstexclp.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000001 ws:5 1 wt2:5 xn_sp:5 wt1:5" "asm"="stlxp {ws}, {wt1}, {wt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXP_SP32_ldstexclp.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000001 ws:5 1 wt2:5 xn_sp:5 wt1:5" "asm"="stlxp {ws}, {wt1}, {wt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXP_LP32_ldstexclp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000011111110 wt2:5 xn_sp:5 wt1:5" "asm"="ldxp {wt1}, {wt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXP_LP32_ldstexclp.1(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000011111110 wt2:5 xn_sp:5 wt1:5" "asm"="ldxp {wt1}, {wt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXP_LP32_ldstexclp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000011111111 wt2:5 xn_sp:5 wt1:5" "asm"="ldaxp {wt1}, {wt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXP_LP32_ldstexclp.1(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10001000011111111 wt2:5 xn_sp:5 wt1:5" "asm"="ldaxp {wt1}, {wt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STXP_SP64_ldstexclp.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000001 ws:5 0 xt2:5 xn_sp:5 xt1:5" "asm"="stxp {ws}, {xt1}, {xt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXP_SP64_ldstexclp.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000001 ws:5 0 xt2:5 xn_sp:5 xt1:5" "asm"="stxp {ws}, {xt1}, {xt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXP_SP64_ldstexclp.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000001 ws:5 1 xt2:5 xn_sp:5 xt1:5" "asm"="stlxp {ws}, {xt1}, {xt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXP_SP64_ldstexclp.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000001 ws:5 1 xt2:5 xn_sp:5 xt1:5" "asm"="stlxp {ws}, {xt1}, {xt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXP_LP64_ldstexclp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000011111110 xt2:5 xn_sp:5 xt1:5" "asm"="ldxp {xt1}, {xt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXP_LP64_ldstexclp.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000011111110 xt2:5 xn_sp:5 xt1:5" "asm"="ldxp {xt1}, {xt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXP_LP64_ldstexclp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000011111111 xt2:5 xn_sp:5 xt1:5" "asm"="ldaxp {xt1}, {xt2}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXP_LP64_ldstexclp.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11001000011111111 xt2:5 xn_sp:5 xt1:5" "asm"="ldaxp {xt1}, {xt2}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STTXR_SR32_ldstexclr_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001001000 ws:5 011111 xn_sp:5 wt:5" "asm"="sttxr {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STTXR_SR32_ldstexclr_unpriv.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001001000 ws:5 011111 xn_sp:5 wt:5" "asm"="sttxr {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLTXR_SR32_ldstexclr_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001001000 ws:5 111111 xn_sp:5 wt:5" "asm"="stltxr {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLTXR_SR32_ldstexclr_unpriv.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001001000 ws:5 111111 xn_sp:5 wt:5" "asm"="stltxr {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTXR_LR32_ldstexclr_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100101011111011111 xn_sp:5 wt:5" "asm"="ldtxr {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDTXR_LR32_ldstexclr_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100101011111011111 xn_sp:5 wt:5" "asm"="ldtxr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDATXR_LR32_ldstexclr_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100101011111111111 xn_sp:5 wt:5" "asm"="ldatxr {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDATXR_LR32_ldstexclr_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100101011111111111 xn_sp:5 wt:5" "asm"="ldatxr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STTXR_SR64_ldstexclr_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001000 ws:5 011111 xn_sp:5 xt:5" "asm"="sttxr {ws}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STTXR_SR64_ldstexclr_unpriv.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001000 ws:5 011111 xn_sp:5 xt:5" "asm"="sttxr {ws}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLTXR_SR64_ldstexclr_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001000 ws:5 111111 xn_sp:5 xt:5" "asm"="stltxr {ws}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLTXR_SR64_ldstexclr_unpriv.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001001000 ws:5 111111 xn_sp:5 xt:5" "asm"="stltxr {ws}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTXR_LR64_ldstexclr_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100101011111011111 xn_sp:5 xt:5" "asm"="ldtxr {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDTXR_LR64_ldstexclr_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100101011111011111 xn_sp:5 xt:5" "asm"="ldtxr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDATXR_LR64_ldstexclr_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100101011111111111 xn_sp:5 xt:5" "asm"="ldatxr {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDATXR_LR64_ldstexclr_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100101011111111111 xn_sp:5 xt:5" "asm"="ldatxr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STXRB_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxrb {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXRB_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxrb {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXRB_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxrb {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXRB_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxrb {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXRB_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100001011111011111 xn_sp:5 wt:5" "asm"="ldxrb {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXRB_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100001011111011111 xn_sp:5 wt:5" "asm"="ldxrb {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXRB_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100001011111111111 xn_sp:5 wt:5" "asm"="ldaxrb {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXRB_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100001011111111111 xn_sp:5 wt:5" "asm"="ldaxrb {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STXRH_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxrh {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXRH_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxrh {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXRH_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxrh {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXRH_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxrh {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXRH_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100001011111011111 xn_sp:5 wt:5" "asm"="ldxrh {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXRH_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100001011111011111 xn_sp:5 wt:5" "asm"="ldxrh {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXRH_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100001011111111111 xn_sp:5 wt:5" "asm"="ldaxrh {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXRH_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100001011111111111 xn_sp:5 wt:5" "asm"="ldaxrh {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STXR_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxr {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXR_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000000 ws:5 011111 xn_sp:5 wt:5" "asm"="stxr {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXR_SR32_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxr {ws}, {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXR_SR32_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000000 ws:5 111111 xn_sp:5 wt:5" "asm"="stlxr {ws}, {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXR_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100001011111011111 xn_sp:5 wt:5" "asm"="ldxr {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXR_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100001011111011111 xn_sp:5 wt:5" "asm"="ldxr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXR_LR32_ldstexclr.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100001011111111111 xn_sp:5 wt:5" "asm"="ldaxr {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXR_LR32_ldstexclr.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100001011111111111 xn_sp:5 wt:5" "asm"="ldaxr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STXR_SR64_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000000 ws:5 011111 xn_sp:5 xt:5" "asm"="stxr {ws}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STXR_SR64_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000000 ws:5 011111 xn_sp:5 xt:5" "asm"="stxr {ws}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLXR_SR64_ldstexclr.0(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000000 ws:5 111111 xn_sp:5 xt:5" "asm"="stlxr {ws}, {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLXR_SR64_ldstexclr.1(i64 "reg"="w" %ws, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000000 ws:5 111111 xn_sp:5 xt:5" "asm"="stlxr {ws}, {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDXR_LR64_ldstexclr.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100001011111011111 xn_sp:5 xt:5" "asm"="ldxr {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDXR_LR64_ldstexclr.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100001011111011111 xn_sp:5 xt:5" "asm"="ldxr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDAXR_LR64_ldstexclr.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100001011111111111 xn_sp:5 xt:5" "asm"="ldaxr {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDAXR_LR64_ldstexclr.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100001011111111111 xn_sp:5 xt:5" "asm"="ldaxr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLLRB_SL32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100010011111011111 xn_sp:5 wt:5" "asm"="stllrb {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLLRB_SL32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100010011111011111 xn_sp:5 wt:5" "asm"="stllrb {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDLARB_LR32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100011011111011111 xn_sp:5 wt:5" "asm"="ldlarb {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDLARB_LR32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0000100011011111011111 xn_sp:5 wt:5" "asm"="ldlarb {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLLRH_SL32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100010011111011111 xn_sp:5 wt:5" "asm"="stllrh {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLLRH_SL32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100010011111011111 xn_sp:5 wt:5" "asm"="stllrh {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDLARH_LR32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100011011111011111 xn_sp:5 wt:5" "asm"="ldlarh {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDLARH_LR32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0100100011011111011111 xn_sp:5 wt:5" "asm"="ldlarh {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLLR_SL32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100010011111011111 xn_sp:5 wt:5" "asm"="stllr {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLLR_SL32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100010011111011111 xn_sp:5 wt:5" "asm"="stllr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDLAR_LR32_ldstord.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100011011111011111 xn_sp:5 wt:5" "asm"="ldlar {wt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDLAR_LR32_ldstord.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1000100011011111011111 xn_sp:5 wt:5" "asm"="ldlar {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @STLLR_SL64_ldstord.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100010011111011111 xn_sp:5 xt:5" "asm"="stllr {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @STLLR_SL64_ldstord.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100010011111011111 xn_sp:5 xt:5" "asm"="stllr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDLAR_LR64_ldstord.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100011011111011111 xn_sp:5 xt:5" "asm"="ldlar {xt}, [{xn_sp}, #0]" "asmonly" {
  ret void
}

define void @LDLAR_LR64_ldstord.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1100100011011111011111 xn_sp:5 xt:5" "asm"="ldlar {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @CASB_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000101 ws:5 011111 xn_sp:5 wt:5" "asm"="casb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASLB_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000101 ws:5 111111 xn_sp:5 wt:5" "asm"="caslb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASAB_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000111 ws:5 011111 xn_sp:5 wt:5" "asm"="casab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASALB_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00001000111 ws:5 111111 xn_sp:5 wt:5" "asm"="casalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASH_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000101 ws:5 011111 xn_sp:5 wt:5" "asm"="cash {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASLH_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000101 ws:5 111111 xn_sp:5 wt:5" "asm"="caslh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASAH_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000111 ws:5 011111 xn_sp:5 wt:5" "asm"="casah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASALH_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01001000111 ws:5 111111 xn_sp:5 wt:5" "asm"="casalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CAS_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000101 ws:5 011111 xn_sp:5 wt:5" "asm"="cas {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASL_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000101 ws:5 111111 xn_sp:5 wt:5" "asm"="casl {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASA_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000111 ws:5 011111 xn_sp:5 wt:5" "asm"="casa {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASAL_C32_comswap.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10001000111 ws:5 111111 xn_sp:5 wt:5" "asm"="casal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CAS_C64_comswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000101 xs:5 011111 xn_sp:5 xt:5" "asm"="cas {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASL_C64_comswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000101 xs:5 111111 xn_sp:5 xt:5" "asm"="casl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASA_C64_comswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000111 xs:5 011111 xn_sp:5 xt:5" "asm"="casa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @CASAL_C64_comswap.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11001000111 xs:5 111111 xn_sp:5 xt:5" "asm"="casal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STILP_32SE_ldiappstilp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10011001000 wt2:5 000010 xn_sp:5 wt1:5" "asm"="stilp {wt1}, {wt2}, [{xn_sp}, #-8]!" "asmonly" {
  ret void
}

define void @STILP_32S_ldiappstilp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10011001000 wt2:5 000110 xn_sp:5 wt1:5" "asm"="stilp {wt1}, {wt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDIAPP_32LE_ldiappstilp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10011001010 wt2:5 000010 xn_sp:5 wt1:5" "asm"="ldiapp {wt1}, {wt2}, [{xn_sp}], #8" "asmonly" {
  ret void
}

define void @LDIAPP_32L_ldiappstilp.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="10011001010 wt2:5 000110 xn_sp:5 wt1:5" "asm"="ldiapp {wt1}, {wt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STILP_64SS_ldiappstilp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11011001000 xt2:5 000010 xn_sp:5 xt1:5" "asm"="stilp {xt1}, {xt2}, [{xn_sp}, #-16]!" "asmonly" {
  ret void
}

define void @STILP_64S_ldiappstilp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11011001000 xt2:5 000110 xn_sp:5 xt1:5" "asm"="stilp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDIAPP_64LS_ldiappstilp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11011001010 xt2:5 000010 xn_sp:5 xt1:5" "asm"="ldiapp {xt1}, {xt2}, [{xn_sp}], #16" "asmonly" {
  ret void
}

define void @LDIAPP_64L_ldiappstilp.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11011001010 xt2:5 000110 xn_sp:5 xt1:5" "asm"="ldiapp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLR_32S_ldapstl_writeback.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1001100110000000000010 xn_sp:5 wt:5" "asm"="stlr {wt}, [{xn_sp}, #-4]!" "asmonly" {
  ret void
}

define void @LDAPR_32L_ldapstl_writeback.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1001100111000000000010 xn_sp:5 wt:5" "asm"="ldapr {wt}, [{xn_sp}], #4" "asmonly" {
  ret void
}

define void @STLR_64S_ldapstl_writeback.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100110000000000010 xn_sp:5 xt:5" "asm"="stlr {xt}, [{xn_sp}, #-8]!" "asmonly" {
  ret void
}

define void @LDAPR_64L_ldapstl_writeback.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100111000000000010 xn_sp:5 xt:5" "asm"="ldapr {xt}, [{xn_sp}], #8" "asmonly" {
  ret void
}

define void @STLURB_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0001100100000000000000 xn_sp:5 wt:5" "asm"="stlurb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLURB_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011001000 simm:s9 00 xn_sp:5 wt:5" "asm"="stlurb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURB_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0001100101000000000000 xn_sp:5 wt:5" "asm"="ldapurb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURB_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011001010 simm:s9 00 xn_sp:5 wt:5" "asm"="ldapurb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURSB_64_ldapstl_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0001100110000000000000 xn_sp:5 xt:5" "asm"="ldapursb {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURSB_64_ldapstl_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011001100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldapursb {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURSB_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0001100111000000000000 xn_sp:5 wt:5" "asm"="ldapursb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURSB_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011001110 simm:s9 00 xn_sp:5 wt:5" "asm"="ldapursb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLURH_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0101100100000000000000 xn_sp:5 wt:5" "asm"="stlurh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLURH_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011001000 simm:s9 00 xn_sp:5 wt:5" "asm"="stlurh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURH_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0101100101000000000000 xn_sp:5 wt:5" "asm"="ldapurh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURH_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011001010 simm:s9 00 xn_sp:5 wt:5" "asm"="ldapurh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURSH_64_ldapstl_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0101100110000000000000 xn_sp:5 xt:5" "asm"="ldapursh {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURSH_64_ldapstl_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011001100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldapursh {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURSH_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0101100111000000000000 xn_sp:5 wt:5" "asm"="ldapursh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURSH_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011001110 simm:s9 00 xn_sp:5 wt:5" "asm"="ldapursh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1001100100000000000000 xn_sp:5 wt:5" "asm"="stlur {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10011001000 simm:s9 00 xn_sp:5 wt:5" "asm"="stlur {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_32_ldapstl_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1001100101000000000000 xn_sp:5 wt:5" "asm"="ldapur {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_32_ldapstl_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10011001010 simm:s9 00 xn_sp:5 wt:5" "asm"="ldapur {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPURSW_64_ldapstl_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1001100110000000000000 xn_sp:5 xt:5" "asm"="ldapursw {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPURSW_64_ldapstl_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10011001100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldapursw {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_64_ldapstl_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100100000000000000 xn_sp:5 xt:5" "asm"="stlur {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_64_ldapstl_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001000 simm:s9 00 xn_sp:5 xt:5" "asm"="stlur {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_64_ldapstl_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1101100101000000000000 xn_sp:5 xt:5" "asm"="ldapur {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_64_ldapstl_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011001010 simm:s9 00 xn_sp:5 xt:5" "asm"="ldapur {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_B_ldapstl_simd.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0001110100000000000010 xn_sp:5 bt:5" "asm"="stlur {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_B_ldapstl_simd.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011101000 simm:s9 10 xn_sp:5 bt:5" "asm"="stlur {bt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_B_ldapstl_simd.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0001110101000000000010 xn_sp:5 bt:5" "asm"="ldapur {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_B_ldapstl_simd.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011101010 simm:s9 10 xn_sp:5 bt:5" "asm"="ldapur {bt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_Q_ldapstl_simd.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp) "enc"="0001110110000000000010 xn_sp:5 qt:5" "asm"="stlur {qt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_Q_ldapstl_simd.1(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011101100 simm:s9 10 xn_sp:5 qt:5" "asm"="stlur {qt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_Q_ldapstl_simd.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp) "enc"="0001110111000000000010 xn_sp:5 qt:5" "asm"="ldapur {qt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_Q_ldapstl_simd.1(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00011101110 simm:s9 10 xn_sp:5 qt:5" "asm"="ldapur {qt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_H_ldapstl_simd.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0101110100000000000010 xn_sp:5 ht:5" "asm"="stlur {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_H_ldapstl_simd.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011101000 simm:s9 10 xn_sp:5 ht:5" "asm"="stlur {ht}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_H_ldapstl_simd.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0101110101000000000010 xn_sp:5 ht:5" "asm"="ldapur {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_H_ldapstl_simd.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01011101010 simm:s9 10 xn_sp:5 ht:5" "asm"="ldapur {ht}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_S_ldapstl_simd.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="1001110100000000000010 xn_sp:5 st:5" "asm"="stlur {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_S_ldapstl_simd.1(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10011101000 simm:s9 10 xn_sp:5 st:5" "asm"="stlur {st}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_S_ldapstl_simd.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="1001110101000000000010 xn_sp:5 st:5" "asm"="ldapur {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_S_ldapstl_simd.1(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10011101010 simm:s9 10 xn_sp:5 st:5" "asm"="ldapur {st}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STLUR_D_ldapstl_simd.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="1101110100000000000010 xn_sp:5 dt:5" "asm"="stlur {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STLUR_D_ldapstl_simd.1(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011101000 simm:s9 10 xn_sp:5 dt:5" "asm"="stlur {dt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDAPUR_D_ldapstl_simd.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="1101110101000000000010 xn_sp:5 dt:5" "asm"="ldapur {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPUR_D_ldapstl_simd.1(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11011101010 simm:s9 10 xn_sp:5 dt:5" "asm"="ldapur {dt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDR_32_loadlit.0(i64 "reg"="w" %wt, ptr "label" %label) "enc"="00011000 label_f:s19=label>>2 wt:5" "asm"="ldr {wt}, {label}" "asmonly" {
  ret void
}

define void @LDR_S_loadlit.0(i64 "reg"="s" %st, ptr "label" %label) "enc"="00011100 label_f:s19=label>>2 st:5" "asm"="ldr {st}, {label}" "asmonly" {
  ret void
}

define void @LDR_64_loadlit.0(i64 "reg"="x" %xt, ptr "label" %label) "enc"="01011000 label_f:s19=label>>2 xt:5" "asm"="ldr {xt}, {label}" "asmonly" {
  ret void
}

define void @LDR_D_loadlit.0(i64 "reg"="d" %dt, ptr "label" %label) "enc"="01011100 label_f:s19=label>>2 dt:5" "asm"="ldr {dt}, {label}" "asmonly" {
  ret void
}

define void @LDRSW_64_loadlit.0(i64 "reg"="x" %xt, ptr "label" %label) "enc"="10011000 label_f:s19=label>>2 xt:5" "asm"="ldrsw {xt}, {label}" "asmonly" {
  ret void
}

define void @LDR_Q_loadlit.0(i64 "reg"="q" %qt, ptr "label" %label) "enc"="10011100 label_f:s19=label>>2 qt:5" "asm"="ldr {qt}, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.0(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00000" "asm"="prfm pldl1keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.1(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00001" "asm"="prfm pldl1strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.2(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00010" "asm"="prfm pldl2keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.3(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00011" "asm"="prfm pldl2strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.4(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00100" "asm"="prfm pldl3keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.5(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00101" "asm"="prfm pldl3strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.6(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00110" "asm"="prfm pldslckeep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.7(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 00111" "asm"="prfm pldslcstrm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.8(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01000" "asm"="prfm plil1keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.9(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01001" "asm"="prfm plil1strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.10(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01010" "asm"="prfm plil2keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.11(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01011" "asm"="prfm plil2strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.12(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01100" "asm"="prfm plil3keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.13(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01101" "asm"="prfm plil3strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.14(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01110" "asm"="prfm plislckeep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.15(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 01111" "asm"="prfm plislcstrm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.16(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10000" "asm"="prfm pstl1keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.17(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10001" "asm"="prfm pstl1strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.18(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10010" "asm"="prfm pstl2keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.19(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10011" "asm"="prfm pstl2strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.20(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10100" "asm"="prfm pstl3keep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.21(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10101" "asm"="prfm pstl3strm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.22(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10110" "asm"="prfm pstslckeep, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.23(ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 10111" "asm"="prfm pstslcstrm, {label}" "asmonly" {
  ret void
}

define void @PRFM_P_loadlit.24(i64 "imm" %imm5, ptr "label" %label) "enc"="11011000 label_f:s19=label>>2 imm5:5" "asm"="prfm #{imm5}, {label}" "asmonly" {
  ret void
}

define void @CPYFP_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 000001 xn:5 xd:5" "asm"="cpyfp [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 000101 xn:5 xd:5" "asm"="cpyfpwt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPRT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 001001 xn:5 xd:5" "asm"="cpyfprt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 001101 xn:5 xd:5" "asm"="cpyfpt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 010001 xn:5 xd:5" "asm"="cpyfpwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 010101 xn:5 xd:5" "asm"="cpyfpwtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPRTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 011001 xn:5 xd:5" "asm"="cpyfprtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 011101 xn:5 xd:5" "asm"="cpyfptwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 100001 xn:5 xd:5" "asm"="cpyfprn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 100101 xn:5 xd:5" "asm"="cpyfpwtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPRTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 101001 xn:5 xd:5" "asm"="cpyfprtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 101101 xn:5 xd:5" "asm"="cpyfptrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 110001 xn:5 xd:5" "asm"="cpyfpn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 110101 xn:5 xd:5" "asm"="cpyfpwtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPRTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 111001 xn:5 xd:5" "asm"="cpyfprtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFPTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001000 xs:5 111101 xn:5 xd:5" "asm"="cpyfptn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFM_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 000001 xn:5 xd:5" "asm"="cpyfm [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 000101 xn:5 xd:5" "asm"="cpyfmwt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMRT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 001001 xn:5 xd:5" "asm"="cpyfmrt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 001101 xn:5 xd:5" "asm"="cpyfmt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 010001 xn:5 xd:5" "asm"="cpyfmwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 010101 xn:5 xd:5" "asm"="cpyfmwtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMRTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 011001 xn:5 xd:5" "asm"="cpyfmrtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 011101 xn:5 xd:5" "asm"="cpyfmtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 100001 xn:5 xd:5" "asm"="cpyfmrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 100101 xn:5 xd:5" "asm"="cpyfmwtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMRTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 101001 xn:5 xd:5" "asm"="cpyfmrtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 101101 xn:5 xd:5" "asm"="cpyfmtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 110001 xn:5 xd:5" "asm"="cpyfmn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 110101 xn:5 xd:5" "asm"="cpyfmwtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMRTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 111001 xn:5 xd:5" "asm"="cpyfmrtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFMTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001010 xs:5 111101 xn:5 xd:5" "asm"="cpyfmtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFE_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 000001 xn:5 xd:5" "asm"="cpyfe [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 000101 xn:5 xd:5" "asm"="cpyfewt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFERT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 001001 xn:5 xd:5" "asm"="cpyfert [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFET_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 001101 xn:5 xd:5" "asm"="cpyfet [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 010001 xn:5 xd:5" "asm"="cpyfewn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 010101 xn:5 xd:5" "asm"="cpyfewtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFERTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 011001 xn:5 xd:5" "asm"="cpyfertwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFETWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 011101 xn:5 xd:5" "asm"="cpyfetwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFERN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 100001 xn:5 xd:5" "asm"="cpyfern [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 100101 xn:5 xd:5" "asm"="cpyfewtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFERTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 101001 xn:5 xd:5" "asm"="cpyfertrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFETRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 101101 xn:5 xd:5" "asm"="cpyfetrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 110001 xn:5 xd:5" "asm"="cpyfen [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFEWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 110101 xn:5 xd:5" "asm"="cpyfewtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFERTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 111001 xn:5 xd:5" "asm"="cpyfertn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYFETN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011001100 xs:5 111101 xn:5 xd:5" "asm"="cpyfetn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @SETP_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 000001 xn:5 xd:5" "asm"="setp [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETPT_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 000101 xn:5 xd:5" "asm"="setpt [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETPN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 001001 xn:5 xd:5" "asm"="setpn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETPTN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 001101 xn:5 xd:5" "asm"="setptn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETM_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 010001 xn:5 xd:5" "asm"="setm [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETMT_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 010101 xn:5 xd:5" "asm"="setmt [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETMN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 011001 xn:5 xd:5" "asm"="setmn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETMTN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 011101 xn:5 xd:5" "asm"="setmtn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETE_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 100001 xn:5 xd:5" "asm"="sete [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETET_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 100101 xn:5 xd:5" "asm"="setet [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETEN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 101001 xn:5 xd:5" "asm"="seten [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETETN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011001110 xs:5 101101 xn:5 xd:5" "asm"="setetn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @CPYP_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 000001 xn:5 xd:5" "asm"="cpyp [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 000101 xn:5 xd:5" "asm"="cpypwt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPRT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 001001 xn:5 xd:5" "asm"="cpyprt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 001101 xn:5 xd:5" "asm"="cpypt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 010001 xn:5 xd:5" "asm"="cpypwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 010101 xn:5 xd:5" "asm"="cpypwtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPRTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 011001 xn:5 xd:5" "asm"="cpyprtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 011101 xn:5 xd:5" "asm"="cpyptwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 100001 xn:5 xd:5" "asm"="cpyprn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 100101 xn:5 xd:5" "asm"="cpypwtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPRTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 101001 xn:5 xd:5" "asm"="cpyprtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 101101 xn:5 xd:5" "asm"="cpyptrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 110001 xn:5 xd:5" "asm"="cpypn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 110101 xn:5 xd:5" "asm"="cpypwtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPRTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 111001 xn:5 xd:5" "asm"="cpyprtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYPTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101000 xs:5 111101 xn:5 xd:5" "asm"="cpyptn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYM_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 000001 xn:5 xd:5" "asm"="cpym [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 000101 xn:5 xd:5" "asm"="cpymwt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMRT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 001001 xn:5 xd:5" "asm"="cpymrt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 001101 xn:5 xd:5" "asm"="cpymt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 010001 xn:5 xd:5" "asm"="cpymwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 010101 xn:5 xd:5" "asm"="cpymwtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMRTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 011001 xn:5 xd:5" "asm"="cpymrtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 011101 xn:5 xd:5" "asm"="cpymtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 100001 xn:5 xd:5" "asm"="cpymrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 100101 xn:5 xd:5" "asm"="cpymwtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMRTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 101001 xn:5 xd:5" "asm"="cpymrtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 101101 xn:5 xd:5" "asm"="cpymtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 110001 xn:5 xd:5" "asm"="cpymn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 110101 xn:5 xd:5" "asm"="cpymwtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMRTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 111001 xn:5 xd:5" "asm"="cpymrtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYMTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101010 xs:5 111101 xn:5 xd:5" "asm"="cpymtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYE_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 000001 xn:5 xd:5" "asm"="cpye [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEWT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 000101 xn:5 xd:5" "asm"="cpyewt [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYERT_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 001001 xn:5 xd:5" "asm"="cpyert [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYET_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 001101 xn:5 xd:5" "asm"="cpyet [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 010001 xn:5 xd:5" "asm"="cpyewn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEWTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 010101 xn:5 xd:5" "asm"="cpyewtwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYERTWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 011001 xn:5 xd:5" "asm"="cpyertwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYETWN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 011101 xn:5 xd:5" "asm"="cpyetwn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYERN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 100001 xn:5 xd:5" "asm"="cpyern [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEWTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 100101 xn:5 xd:5" "asm"="cpyewtrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYERTRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 101001 xn:5 xd:5" "asm"="cpyertrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYETRN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 101101 xn:5 xd:5" "asm"="cpyetrn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 110001 xn:5 xd:5" "asm"="cpyen [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYEWTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 110101 xn:5 xd:5" "asm"="cpyewtn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYERTN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 111001 xn:5 xd:5" "asm"="cpyertn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @CPYETN_CPY_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xs, i64 "reg"="x" %xn) "enc"="00011101100 xs:5 111101 xn:5 xd:5" "asm"="cpyetn [{xd}]!, [{xs}]!, {xn}!" "asmonly" {
  ret void
}

define void @SETGP_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 000001 xn:5 xd:5" "asm"="setgp [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGPT_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 000101 xn:5 xd:5" "asm"="setgpt [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGPN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 001001 xn:5 xd:5" "asm"="setgpn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGPTN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 001101 xn:5 xd:5" "asm"="setgptn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGM_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 010001 xn:5 xd:5" "asm"="setgm [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGMT_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 010101 xn:5 xd:5" "asm"="setgmt [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGMN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 011001 xn:5 xd:5" "asm"="setgmn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGMTN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 011101 xn:5 xd:5" "asm"="setgmtn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGE_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 100001 xn:5 xd:5" "asm"="setge [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGET_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 100101 xn:5 xd:5" "asm"="setget [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGEN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 101001 xn:5 xd:5" "asm"="setgen [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @SETGETN_SET_memcms.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xs) "enc"="00011101110 xs:5 101101 xn:5 xd:5" "asm"="setgetn [{xd}]!, {xn}!, {xs}" "asmonly" {
  ret void
}

define void @LDTADD_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 000001 xn_sp:5 wt:5" "asm"="ldtadd {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttadd" {
  ret void
}

define void @LDTADD_32_memop_unpriv.STTADD.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 000001 xn_sp:5 11111" "asm"="sttadd {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTCLR_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 000101 xn_sp:5 wt:5" "asm"="ldtclr {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttclr" {
  ret void
}

define void @LDTCLR_32_memop_unpriv.STTCLR.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 000101 xn_sp:5 11111" "asm"="sttclr {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTSET_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 001101 xn_sp:5 wt:5" "asm"="ldtset {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttset" {
  ret void
}

define void @LDTSET_32_memop_unpriv.STTSET.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 001101 xn_sp:5 11111" "asm"="sttset {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPT_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001001 ws:5 100001 xn_sp:5 wt:5" "asm"="swpt {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 000001 xn_sp:5 wt:5" "asm"="ldtaddl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttaddl" {
  ret void
}

define void @LDTADDL_32_memop_unpriv.STTADDL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 000001 xn_sp:5 11111" "asm"="sttaddl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTCLRL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 000101 xn_sp:5 wt:5" "asm"="ldtclrl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttclrl" {
  ret void
}

define void @LDTCLRL_32_memop_unpriv.STTCLRL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 000101 xn_sp:5 11111" "asm"="sttclrl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTSETL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 001101 xn_sp:5 wt:5" "asm"="ldtsetl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="sttsetl" {
  ret void
}

define void @LDTSETL_32_memop_unpriv.STTSETL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 001101 xn_sp:5 11111" "asm"="sttsetl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPTL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001011 ws:5 100001 xn_sp:5 wt:5" "asm"="swptl {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDA_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 ws:5 000001 xn_sp:5 wt:5" "asm"="ldtadda {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTCLRA_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 ws:5 000101 xn_sp:5 wt:5" "asm"="ldtclra {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTSETA_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 ws:5 001101 xn_sp:5 wt:5" "asm"="ldtseta {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPTA_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001101 ws:5 100001 xn_sp:5 wt:5" "asm"="swpta {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDAL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 ws:5 000001 xn_sp:5 wt:5" "asm"="ldtaddal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTCLRAL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 ws:5 000101 xn_sp:5 wt:5" "asm"="ldtclral {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTSETAL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 ws:5 001101 xn_sp:5 wt:5" "asm"="ldtsetal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPTAL_32_memop_unpriv.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00011001111 ws:5 100001 xn_sp:5 wt:5" "asm"="swptal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADD_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 000001 xn_sp:5 xt:5" "asm"="ldtadd {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttadd" {
  ret void
}

define void @LDTADD_64_memop_unpriv.STTADD.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 000001 xn_sp:5 11111" "asm"="sttadd {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTCLR_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 000101 xn_sp:5 xt:5" "asm"="ldtclr {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttclr" {
  ret void
}

define void @LDTCLR_64_memop_unpriv.STTCLR.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 000101 xn_sp:5 11111" "asm"="sttclr {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTSET_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 001101 xn_sp:5 xt:5" "asm"="ldtset {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttset" {
  ret void
}

define void @LDTSET_64_memop_unpriv.STTSET.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 001101 xn_sp:5 11111" "asm"="sttset {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPT_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001001 xs:5 100001 xn_sp:5 xt:5" "asm"="swpt {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 000001 xn_sp:5 xt:5" "asm"="ldtaddl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttaddl" {
  ret void
}

define void @LDTADDL_64_memop_unpriv.STTADDL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 000001 xn_sp:5 11111" "asm"="sttaddl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTCLRL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 000101 xn_sp:5 xt:5" "asm"="ldtclrl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttclrl" {
  ret void
}

define void @LDTCLRL_64_memop_unpriv.STTCLRL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 000101 xn_sp:5 11111" "asm"="sttclrl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDTSETL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 001101 xn_sp:5 xt:5" "asm"="ldtsetl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="sttsetl" {
  ret void
}

define void @LDTSETL_64_memop_unpriv.STTSETL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 001101 xn_sp:5 11111" "asm"="sttsetl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPTL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001011 xs:5 100001 xn_sp:5 xt:5" "asm"="swptl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDA_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xs:5 000001 xn_sp:5 xt:5" "asm"="ldtadda {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTCLRA_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xs:5 000101 xn_sp:5 xt:5" "asm"="ldtclra {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTSETA_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xs:5 001101 xn_sp:5 xt:5" "asm"="ldtseta {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPTA_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001101 xs:5 100001 xn_sp:5 xt:5" "asm"="swpta {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTADDAL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xs:5 000001 xn_sp:5 xt:5" "asm"="ldtaddal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTCLRAL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xs:5 000101 xn_sp:5 xt:5" "asm"="ldtclral {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTSETAL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xs:5 001101 xn_sp:5 xt:5" "asm"="ldtsetal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPTAL_64_memop_unpriv.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01011001111 xs:5 100001 xn_sp:5 xt:5" "asm"="swptal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_32_ldstnapair_offs.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="00101000000000000 wt2:5 xn_sp:5 wt1:5" "asm"="stnp {wt1}, {wt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_32_ldstnapair_offs.1(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0010100000 imm_f:s7=imm>>2 wt2:5 xn_sp:5 wt1:5" "asm"="stnp {wt1}, {wt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDNP_32_ldstnapair_offs.0(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp) "enc"="00101000010000000 wt2:5 xn_sp:5 wt1:5" "asm"="ldnp {wt1}, {wt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDNP_32_ldstnapair_offs.1(i64 "reg"="w" %wt1, i64 "reg"="w" %wt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0010100001 imm_f:s7=imm>>2 wt2:5 xn_sp:5 wt1:5" "asm"="ldnp {wt1}, {wt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STNP_S_ldstnapair_offs.0(i64 "reg"="s" %st1, i64 "reg"="s" %st2, i64 "reg"="xsp" %xn_sp) "enc"="00101100000000000 st2:5 xn_sp:5 st1:5" "asm"="stnp {st1}, {st2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_S_ldstnapair_offs.1(i64 "reg"="s" %st1, i64 "reg"="s" %st2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0010110000 imm_f:s7=imm>>2 st2:5 xn_sp:5 st1:5" "asm"="stnp {st1}, {st2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDNP_S_ldstnapair_offs.0(i64 "reg"="s" %st1, i64 "reg"="s" %st2, i64 "reg"="xsp" %xn_sp) "enc"="00101100010000000 st2:5 xn_sp:5 st1:5" "asm"="ldnp {st1}, {st2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDNP_S_ldstnapair_offs.1(i64 "reg"="s" %st1, i64 "reg"="s" %st2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0010110001 imm_f:s7=imm>>2 st2:5 xn_sp:5 st1:5" "asm"="ldnp {st1}, {st2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STNP_D_ldstnapair_offs.0(i64 "reg"="d" %dt1, i64 "reg"="d" %dt2, i64 "reg"="xsp" %xn_sp) "enc"="01101100000000000 dt2:5 xn_sp:5 dt1:5" "asm"="stnp {dt1}, {dt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_D_ldstnapair_offs.1(i64 "reg"="d" %dt1, i64 "reg"="d" %dt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0110110000 imm_f:s7=imm>>3 dt2:5 xn_sp:5 dt1:5" "asm"="stnp {dt1}, {dt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDNP_D_ldstnapair_offs.0(i64 "reg"="d" %dt1, i64 "reg"="d" %dt2, i64 "reg"="xsp" %xn_sp) "enc"="01101100010000000 dt2:5 xn_sp:5 dt1:5" "asm"="ldnp {dt1}, {dt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDNP_D_ldstnapair_offs.1(i64 "reg"="d" %dt1, i64 "reg"="d" %dt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0110110001 imm_f:s7=imm>>3 dt2:5 xn_sp:5 dt1:5" "asm"="ldnp {dt1}, {dt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STNP_64_ldstnapair_offs.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="10101000000000000 xt2:5 xn_sp:5 xt1:5" "asm"="stnp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_64_ldstnapair_offs.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1010100000 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="stnp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDNP_64_ldstnapair_offs.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="10101000010000000 xt2:5 xn_sp:5 xt1:5" "asm"="ldnp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDNP_64_ldstnapair_offs.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1010100001 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="ldnp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STNP_Q_ldstnapair_offs.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="10101100000000000 qt2:5 xn_sp:5 qt1:5" "asm"="stnp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STNP_Q_ldstnapair_offs.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1010110000 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="stnp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDNP_Q_ldstnapair_offs.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="10101100010000000 qt2:5 xn_sp:5 qt1:5" "asm"="ldnp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDNP_Q_ldstnapair_offs.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1010110001 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="ldnp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STTNP_64_ldstnapair_offs.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11101000000000000 xt2:5 xn_sp:5 xt1:5" "asm"="sttnp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTNP_64_ldstnapair_offs.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100000 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="sttnp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDTNP_64_ldstnapair_offs.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11101000010000000 xt2:5 xn_sp:5 xt1:5" "asm"="ldtnp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTNP_64_ldstnapair_offs.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100001 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="ldtnp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STTNP_Q_ldstnapair_offs.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="11101100000000000 qt2:5 xn_sp:5 qt1:5" "asm"="sttnp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTNP_Q_ldstnapair_offs.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110000 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="sttnp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDTNP_Q_ldstnapair_offs.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="11101100010000000 qt2:5 xn_sp:5 qt1:5" "asm"="ldtnp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTNP_Q_ldstnapair_offs.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110001 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="ldtnp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STGP_64_ldstpair_post.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0110100010 imm_f:s7=imm>>4 xt2:5 xn_sp:5 xt1:5" "asm"="stgp {xt1}, {xt2}, [{xn_sp}], #{imm}" "asmonly" {
  ret void
}

define void @STTP_64_ldstpair_post.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100010 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="sttp {xt1}, {xt2}, [{xn_sp}], #{imm}" "asmonly" {
  ret void
}

define void @LDTP_64_ldstpair_post.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100011 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="ldtp {xt1}, {xt2}, [{xn_sp}], #{imm}" "asmonly" {
  ret void
}

define void @STTP_Q_ldstpair_post.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110010 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="sttp {qt1}, {qt2}, [{xn_sp}], #{imm}" "asmonly" {
  ret void
}

define void @LDTP_Q_ldstpair_post.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110011 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="ldtp {qt1}, {qt2}, [{xn_sp}], #{imm}" "asmonly" {
  ret void
}

define void @STGP_64_ldstpair_off.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="01101001000000000 xt2:5 xn_sp:5 xt1:5" "asm"="stgp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STGP_64_ldstpair_off.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0110100100 imm_f:s7=imm>>4 xt2:5 xn_sp:5 xt1:5" "asm"="stgp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STTP_64_ldstpair_off.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11101001000000000 xt2:5 xn_sp:5 xt1:5" "asm"="sttp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTP_64_ldstpair_off.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100100 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="sttp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDTP_64_ldstpair_off.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp) "enc"="11101001010000000 xt2:5 xn_sp:5 xt1:5" "asm"="ldtp {xt1}, {xt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTP_64_ldstpair_off.1(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100101 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="ldtp {xt1}, {xt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STTP_Q_ldstpair_off.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="11101101000000000 qt2:5 xn_sp:5 qt1:5" "asm"="sttp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTP_Q_ldstpair_off.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110100 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="sttp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @LDTP_Q_ldstpair_off.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp) "enc"="11101101010000000 qt2:5 xn_sp:5 qt1:5" "asm"="ldtp {qt1}, {qt2}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTP_Q_ldstpair_off.1(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110101 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="ldtp {qt1}, {qt2}, [{xn_sp}, #{imm}]" "asmonly" {
  ret void
}

define void @STGP_64_ldstpair_pre.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="0110100110 imm_f:s7=imm>>4 xt2:5 xn_sp:5 xt1:5" "asm"="stgp {xt1}, {xt2}, [{xn_sp}, #{imm}]!" "asmonly" {
  ret void
}

define void @STTP_64_ldstpair_pre.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100110 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="sttp {xt1}, {xt2}, [{xn_sp}, #{imm}]!" "asmonly" {
  ret void
}

define void @LDTP_64_ldstpair_pre.0(i64 "reg"="x" %xt1, i64 "reg"="x" %xt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110100111 imm_f:s7=imm>>3 xt2:5 xn_sp:5 xt1:5" "asm"="ldtp {xt1}, {xt2}, [{xn_sp}, #{imm}]!" "asmonly" {
  ret void
}

define void @STTP_Q_ldstpair_pre.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110110 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="sttp {qt1}, {qt2}, [{xn_sp}, #{imm}]!" "asmonly" {
  ret void
}

define void @LDTP_Q_ldstpair_pre.0(i64 "reg"="q" %qt1, i64 "reg"="q" %qt2, i64 "reg"="xsp" %xn_sp, i64 "imm" %imm) "enc"="1110110111 imm_f:s7=imm>>4 qt2:5 xn_sp:5 qt1:5" "asm"="ldtp {qt1}, {qt2}, [{xn_sp}, #{imm}]!" "asmonly" {
  ret void
}

define void @LDURSB_64_ldst_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0011100010000000000000 xn_sp:5 xt:5" "asm"="ldursb {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURSB_64_ldst_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldursb {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDURSB_32_ldst_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100011000000000000 xn_sp:5 wt:5" "asm"="ldursb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURSB_32_ldst_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000110 simm:s9 00 xn_sp:5 wt:5" "asm"="ldursb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STUR_B_ldst_unscaled.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0011110000000000000000 xn_sp:5 bt:5" "asm"="stur {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STUR_B_ldst_unscaled.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100000 simm:s9 00 xn_sp:5 bt:5" "asm"="stur {bt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDUR_B_ldst_unscaled.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0011110001000000000000 xn_sp:5 bt:5" "asm"="ldur {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUR_B_ldst_unscaled.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100010 simm:s9 00 xn_sp:5 bt:5" "asm"="ldur {bt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STURH_32_ldst_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100000000000000000 xn_sp:5 wt:5" "asm"="sturh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STURH_32_ldst_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000000 simm:s9 00 xn_sp:5 wt:5" "asm"="sturh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDURH_32_ldst_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100001000000000000 xn_sp:5 wt:5" "asm"="ldurh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURH_32_ldst_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000010 simm:s9 00 xn_sp:5 wt:5" "asm"="ldurh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDURSH_64_ldst_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0111100010000000000000 xn_sp:5 xt:5" "asm"="ldursh {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURSH_64_ldst_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldursh {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDURSH_32_ldst_unscaled.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100011000000000000 xn_sp:5 wt:5" "asm"="ldursh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURSH_32_ldst_unscaled.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000110 simm:s9 00 xn_sp:5 wt:5" "asm"="ldursh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STUR_H_ldst_unscaled.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0111110000000000000000 xn_sp:5 ht:5" "asm"="stur {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STUR_H_ldst_unscaled.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100000 simm:s9 00 xn_sp:5 ht:5" "asm"="stur {ht}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDUR_H_ldst_unscaled.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0111110001000000000000 xn_sp:5 ht:5" "asm"="ldur {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUR_H_ldst_unscaled.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100010 simm:s9 00 xn_sp:5 ht:5" "asm"="ldur {ht}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDURSW_64_ldst_unscaled.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1011100010000000000000 xn_sp:5 xt:5" "asm"="ldursw {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDURSW_64_ldst_unscaled.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000100 simm:s9 00 xn_sp:5 xt:5" "asm"="ldursw {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STR_B_ldst_immpost.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100000 simm:s9 01 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @LDR_B_ldst_immpost.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100010 simm:s9 01 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @STR_H_ldst_immpost.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100000 simm:s9 01 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @LDR_H_ldst_immpost.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100010 simm:s9 01 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}], #{simm}" "asmonly" {
  ret void
}

define void @STTRB_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100000000000000010 xn_sp:5 wt:5" "asm"="sttrb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTRB_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000000 simm:s9 10 xn_sp:5 wt:5" "asm"="sttrb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRB_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100001000000000010 xn_sp:5 wt:5" "asm"="ldtrb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRB_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000010 simm:s9 10 xn_sp:5 wt:5" "asm"="ldtrb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRSB_64_ldst_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0011100010000000000010 xn_sp:5 xt:5" "asm"="ldtrsb {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRSB_64_ldst_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000100 simm:s9 10 xn_sp:5 xt:5" "asm"="ldtrsb {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRSB_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100011000000000010 xn_sp:5 wt:5" "asm"="ldtrsb {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRSB_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000110 simm:s9 10 xn_sp:5 wt:5" "asm"="ldtrsb {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STTRH_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100000000000000010 xn_sp:5 wt:5" "asm"="sttrh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTRH_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000000 simm:s9 10 xn_sp:5 wt:5" "asm"="sttrh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRH_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100001000000000010 xn_sp:5 wt:5" "asm"="ldtrh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRH_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000010 simm:s9 10 xn_sp:5 wt:5" "asm"="ldtrh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRSH_64_ldst_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0111100010000000000010 xn_sp:5 xt:5" "asm"="ldtrsh {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRSH_64_ldst_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000100 simm:s9 10 xn_sp:5 xt:5" "asm"="ldtrsh {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRSH_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100011000000000010 xn_sp:5 wt:5" "asm"="ldtrsh {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRSH_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000110 simm:s9 10 xn_sp:5 wt:5" "asm"="ldtrsh {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STTR_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1011100000000000000010 xn_sp:5 wt:5" "asm"="sttr {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTR_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000000 simm:s9 10 xn_sp:5 wt:5" "asm"="sttr {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTR_32_ldst_unpriv.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1011100001000000000010 xn_sp:5 wt:5" "asm"="ldtr {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTR_32_ldst_unpriv.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000010 simm:s9 10 xn_sp:5 wt:5" "asm"="ldtr {wt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTRSW_64_ldst_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1011100010000000000010 xn_sp:5 xt:5" "asm"="ldtrsw {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTRSW_64_ldst_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000100 simm:s9 10 xn_sp:5 xt:5" "asm"="ldtrsw {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STTR_64_ldst_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100000000000000010 xn_sp:5 xt:5" "asm"="sttr {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STTR_64_ldst_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111000000 simm:s9 10 xn_sp:5 xt:5" "asm"="sttr {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDTR_64_ldst_unpriv.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100001000000000010 xn_sp:5 xt:5" "asm"="ldtr {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDTR_64_ldst_unpriv.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111000010 simm:s9 10 xn_sp:5 xt:5" "asm"="ldtr {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @STRB_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000000 simm:s9 11 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRB_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000010 simm:s9 11 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRSB_64_ldst_immpre.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000100 simm:s9 11 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRSB_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111000110 simm:s9 11 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_B_ldst_immpre.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100000 simm:s9 11 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_B_ldst_immpre.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100010 simm:s9 11 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_Q_ldst_immpre.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100100 simm:s9 11 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_immpre.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="00111100110 simm:s9 11 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STRH_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000000 simm:s9 11 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000010 simm:s9 11 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_immpre.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000100 simm:s9 11 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111000110 simm:s9 11 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_H_ldst_immpre.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100000 simm:s9 11 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_H_ldst_immpre.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="01111100010 simm:s9 11 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000000 simm:s9 11 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_32_ldst_immpre.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000010 simm:s9 11 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_immpre.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111000100 simm:s9 11 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_S_ldst_immpre.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111100000 simm:s9 11 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_S_ldst_immpre.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="10111100010 simm:s9 11 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_64_ldst_immpre.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111000000 simm:s9 11 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_64_ldst_immpre.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111000010 simm:s9 11 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_D_ldst_immpre.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111100000 simm:s9 11 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDR_D_ldst_immpre.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="11111100010 simm:s9 11 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDADDB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="staddb" {
  ret void
}

define void @LDADDB_32_memop.STADDB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 000000 xn_sp:5 11111" "asm"="staddb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclrb" {
  ret void
}

define void @LDCLRB_32_memop.STCLRB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 000100 xn_sp:5 11111" "asm"="stclrb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steorb" {
  ret void
}

define void @LDEORB_32_memop.STEORB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 001000 xn_sp:5 11111" "asm"="steorb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsetb" {
  ret void
}

define void @LDSETB_32_memop.STSETB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 001100 xn_sp:5 11111" "asm"="stsetb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxb" {
  ret void
}

define void @LDSMAXB_32_memop.STSMAXB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 010000 xn_sp:5 11111" "asm"="stsmaxb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsminb" {
  ret void
}

define void @LDSMINB_32_memop.STSMINB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 010100 xn_sp:5 11111" "asm"="stsminb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumaxb" {
  ret void
}

define void @LDUMAXB_32_memop.STUMAXB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 011000 xn_sp:5 11111" "asm"="stumaxb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stuminb" {
  ret void
}

define void @LDUMINB_32_memop.STUMINB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 011100 xn_sp:5 11111" "asm"="stuminb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 ws:5 100000 xn_sp:5 wt:5" "asm"="swpb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLR_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwclr {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWP_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwswp {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSET_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000001 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwset {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="staddlb" {
  ret void
}

define void @LDADDLB_32_memop.STADDLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 000000 xn_sp:5 11111" "asm"="staddlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclrlb" {
  ret void
}

define void @LDCLRLB_32_memop.STCLRLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 000100 xn_sp:5 11111" "asm"="stclrlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steorlb" {
  ret void
}

define void @LDEORLB_32_memop.STEORLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 001000 xn_sp:5 11111" "asm"="steorlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsetlb" {
  ret void
}

define void @LDSETLB_32_memop.STSETLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 001100 xn_sp:5 11111" "asm"="stsetlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxlb" {
  ret void
}

define void @LDSMAXLB_32_memop.STSMAXLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 010000 xn_sp:5 11111" "asm"="stsmaxlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsminlb" {
  ret void
}

define void @LDSMINLB_32_memop.STSMINLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 010100 xn_sp:5 11111" "asm"="stsminlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumaxlb" {
  ret void
}

define void @LDUMAXLB_32_memop.STUMAXLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 011000 xn_sp:5 11111" "asm"="stumaxlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminlb {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stuminlb" {
  ret void
}

define void @LDUMINLB_32_memop.STUMINLB.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 011100 xn_sp:5 11111" "asm"="stuminlb {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPLB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 ws:5 100000 xn_sp:5 wt:5" "asm"="swplb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwclrl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwswpl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000011 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwsetl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPAB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 ws:5 100000 xn_sp:5 wt:5" "asm"="swpab {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwclra {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwswpa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000101 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwseta {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPRB_32L_memop.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100010111111110000 xn_sp:5 wt:5" "asm"="ldaprb {wt}, [{xn_sp} , #0]" "asmonly" {
  ret void
}

define void @LDAPRB_32L_memop.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0011100010111111110000 xn_sp:5 wt:5" "asm"="ldaprb {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDADDALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclralb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeoralb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPALB_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 ws:5 100000 xn_sp:5 wt:5" "asm"="swpalb {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWCLRAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwclral {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSWPAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwswpal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSETAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="00111000111 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwsetal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="staddh" {
  ret void
}

define void @LDADDH_32_memop.STADDH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 000000 xn_sp:5 11111" "asm"="staddh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclrh" {
  ret void
}

define void @LDCLRH_32_memop.STCLRH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 000100 xn_sp:5 11111" "asm"="stclrh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steorh" {
  ret void
}

define void @LDEORH_32_memop.STEORH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 001000 xn_sp:5 11111" "asm"="steorh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 001100 xn_sp:5 wt:5" "asm"="ldseth {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stseth" {
  ret void
}

define void @LDSETH_32_memop.STSETH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 001100 xn_sp:5 11111" "asm"="stseth {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxh" {
  ret void
}

define void @LDSMAXH_32_memop.STSMAXH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 010000 xn_sp:5 11111" "asm"="stsmaxh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsminh" {
  ret void
}

define void @LDSMINH_32_memop.STSMINH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 010100 xn_sp:5 11111" "asm"="stsminh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumaxh" {
  ret void
}

define void @LDUMAXH_32_memop.STUMAXH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 011000 xn_sp:5 11111" "asm"="stumaxh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stuminh" {
  ret void
}

define void @LDUMINH_32_memop.STUMINH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 011100 xn_sp:5 11111" "asm"="stuminh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 ws:5 100000 xn_sp:5 wt:5" "asm"="swph {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLR_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwsclr {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWP_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwsswp {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSET_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000001 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwsset {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="staddlh" {
  ret void
}

define void @LDADDLH_32_memop.STADDLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 000000 xn_sp:5 11111" "asm"="staddlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclrlh" {
  ret void
}

define void @LDCLRLH_32_memop.STCLRLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 000100 xn_sp:5 11111" "asm"="stclrlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steorlh" {
  ret void
}

define void @LDEORLH_32_memop.STEORLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 001000 xn_sp:5 11111" "asm"="steorlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsetlh" {
  ret void
}

define void @LDSETLH_32_memop.STSETLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 001100 xn_sp:5 11111" "asm"="stsetlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxlh" {
  ret void
}

define void @LDSMAXLH_32_memop.STSMAXLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 010000 xn_sp:5 11111" "asm"="stsmaxlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsminlh" {
  ret void
}

define void @LDSMINLH_32_memop.STSMINLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 010100 xn_sp:5 11111" "asm"="stsminlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumaxlh" {
  ret void
}

define void @LDUMAXLH_32_memop.STUMAXLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 011000 xn_sp:5 11111" "asm"="stumaxlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminlh {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stuminlh" {
  ret void
}

define void @LDUMINLH_32_memop.STUMINLH.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 011100 xn_sp:5 11111" "asm"="stuminlh {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPLH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 ws:5 100000 xn_sp:5 wt:5" "asm"="swplh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwsclrl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwsswpl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000011 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwssetl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPAH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 ws:5 100000 xn_sp:5 wt:5" "asm"="swpah {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwsclra {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwsswpa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000101 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwsseta {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPRH_32L_memop.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100010111111110000 xn_sp:5 wt:5" "asm"="ldaprh {wt}, [{xn_sp} , #0]" "asmonly" {
  ret void
}

define void @LDAPRH_32L_memop.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="0111100010111111110000 xn_sp:5 wt:5" "asm"="ldaprh {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDADDALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclralh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeoralh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPALH_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 ws:5 100000 xn_sp:5 wt:5" "asm"="swpalh {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSCLRAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 xs:5 100100 xn_sp:5 xt:5" "asm"="rcwsclral {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSWPAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 xs:5 101000 xn_sp:5 xt:5" "asm"="rcwsswpal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RCWSSETAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="01111000111 xs:5 101100 xn_sp:5 xt:5" "asm"="rcwssetal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADD_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 000000 xn_sp:5 wt:5" "asm"="ldadd {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stadd" {
  ret void
}

define void @LDADD_32_memop.STADD.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 000000 xn_sp:5 11111" "asm"="stadd {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLR_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclr {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclr" {
  ret void
}

define void @LDCLR_32_memop.STCLR.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 000100 xn_sp:5 11111" "asm"="stclr {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEOR_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeor {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steor" {
  ret void
}

define void @LDEOR_32_memop.STEOR.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 001000 xn_sp:5 11111" "asm"="steor {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSET_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 001100 xn_sp:5 wt:5" "asm"="ldset {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stset" {
  ret void
}

define void @LDSET_32_memop.STSET.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 001100 xn_sp:5 11111" "asm"="stset {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAX_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmax {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmax" {
  ret void
}

define void @LDSMAX_32_memop.STSMAX.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 010000 xn_sp:5 11111" "asm"="stsmax {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMIN_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsmin {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmin" {
  ret void
}

define void @LDSMIN_32_memop.STSMIN.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 010100 xn_sp:5 11111" "asm"="stsmin {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAX_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumax {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumax" {
  ret void
}

define void @LDUMAX_32_memop.STUMAX.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 011000 xn_sp:5 11111" "asm"="stumax {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMIN_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 011100 xn_sp:5 wt:5" "asm"="ldumin {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumin" {
  ret void
}

define void @LDUMIN_32_memop.STUMIN.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 011100 xn_sp:5 11111" "asm"="stumin {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWP_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000001 ws:5 100000 xn_sp:5 wt:5" "asm"="swp {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="staddl" {
  ret void
}

define void @LDADDL_32_memop.STADDL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 000000 xn_sp:5 11111" "asm"="staddl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclrl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stclrl" {
  ret void
}

define void @LDCLRL_32_memop.STCLRL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 000100 xn_sp:5 11111" "asm"="stclrl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeorl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="steorl" {
  ret void
}

define void @LDEORL_32_memop.STEORL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 001000 xn_sp:5 11111" "asm"="steorl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsetl" {
  ret void
}

define void @LDSETL_32_memop.STSETL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 001100 xn_sp:5 11111" "asm"="stsetl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxl" {
  ret void
}

define void @LDSMAXL_32_memop.STSMAXL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 010000 xn_sp:5 11111" "asm"="stsmaxl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stsminl" {
  ret void
}

define void @LDSMINL_32_memop.STSMINL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 010100 xn_sp:5 11111" "asm"="stsminl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stumaxl" {
  ret void
}

define void @LDUMAXL_32_memop.STUMAXL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 011000 xn_sp:5 11111" "asm"="stumaxl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminl {ws}, {wt}, [{xn_sp}]" "asmonly" "aliases"="stuminl" {
  ret void
}

define void @LDUMINL_32_memop.STUMINL.0(i64 "reg"="w" %ws, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 011100 xn_sp:5 11111" "asm"="stuminl {ws}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000011 ws:5 100000 xn_sp:5 wt:5" "asm"="swpl {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 000000 xn_sp:5 wt:5" "asm"="ldadda {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclra {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeora {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 001100 xn_sp:5 wt:5" "asm"="ldseta {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxa {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsmina {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxa {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 011100 xn_sp:5 wt:5" "asm"="ldumina {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPA_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000101 ws:5 100000 xn_sp:5 wt:5" "asm"="swpa {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPR_32L_memop.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1011100010111111110000 xn_sp:5 wt:5" "asm"="ldapr {wt}, [{xn_sp} , #0]" "asmonly" {
  ret void
}

define void @LDAPR_32L_memop.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="1011100010111111110000 xn_sp:5 wt:5" "asm"="ldapr {wt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDADDAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 000000 xn_sp:5 wt:5" "asm"="ldaddal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 000100 xn_sp:5 wt:5" "asm"="ldclral {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 001000 xn_sp:5 wt:5" "asm"="ldeoral {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 001100 xn_sp:5 wt:5" "asm"="ldsetal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 010000 xn_sp:5 wt:5" "asm"="ldsmaxal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 010100 xn_sp:5 wt:5" "asm"="ldsminal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 011000 xn_sp:5 wt:5" "asm"="ldumaxal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 011100 xn_sp:5 wt:5" "asm"="lduminal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPAL_32_memop.0(i64 "reg"="w" %ws, i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp) "enc"="10111000111 ws:5 100000 xn_sp:5 wt:5" "asm"="swpal {ws}, {wt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADD_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 000000 xn_sp:5 xt:5" "asm"="ldadd {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stadd" {
  ret void
}

define void @LDADD_64_memop.STADD.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 000000 xn_sp:5 11111" "asm"="stadd {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLR_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 000100 xn_sp:5 xt:5" "asm"="ldclr {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stclr" {
  ret void
}

define void @LDCLR_64_memop.STCLR.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 000100 xn_sp:5 11111" "asm"="stclr {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEOR_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 001000 xn_sp:5 xt:5" "asm"="ldeor {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="steor" {
  ret void
}

define void @LDEOR_64_memop.STEOR.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 001000 xn_sp:5 11111" "asm"="steor {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSET_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 001100 xn_sp:5 xt:5" "asm"="ldset {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stset" {
  ret void
}

define void @LDSET_64_memop.STSET.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 001100 xn_sp:5 11111" "asm"="stset {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAX_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 010000 xn_sp:5 xt:5" "asm"="ldsmax {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stsmax" {
  ret void
}

define void @LDSMAX_64_memop.STSMAX.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 010000 xn_sp:5 11111" "asm"="stsmax {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMIN_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 010100 xn_sp:5 xt:5" "asm"="ldsmin {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stsmin" {
  ret void
}

define void @LDSMIN_64_memop.STSMIN.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 010100 xn_sp:5 11111" "asm"="stsmin {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAX_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 011000 xn_sp:5 xt:5" "asm"="ldumax {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stumax" {
  ret void
}

define void @LDUMAX_64_memop.STUMAX.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 011000 xn_sp:5 11111" "asm"="stumax {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMIN_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 011100 xn_sp:5 xt:5" "asm"="ldumin {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stumin" {
  ret void
}

define void @LDUMIN_64_memop.STUMIN.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 011100 xn_sp:5 11111" "asm"="stumin {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWP_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 100000 xn_sp:5 xt:5" "asm"="swp {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @ST64BV0_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 101000 xn_sp:5 rt_f:4=xt>>1 0" "asm"="st64bv0 {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @ST64BV_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000001 xs:5 101100 xn_sp:5 rt_f:4=xt>>1 0" "asm"="st64bv {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 000000 xn_sp:5 xt:5" "asm"="ldaddl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="staddl" {
  ret void
}

define void @LDADDL_64_memop.STADDL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 000000 xn_sp:5 11111" "asm"="staddl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDCLRL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 000100 xn_sp:5 xt:5" "asm"="ldclrl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stclrl" {
  ret void
}

define void @LDCLRL_64_memop.STCLRL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 000100 xn_sp:5 11111" "asm"="stclrl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDEORL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 001000 xn_sp:5 xt:5" "asm"="ldeorl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="steorl" {
  ret void
}

define void @LDEORL_64_memop.STEORL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 001000 xn_sp:5 11111" "asm"="steorl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSETL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 001100 xn_sp:5 xt:5" "asm"="ldsetl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stsetl" {
  ret void
}

define void @LDSETL_64_memop.STSETL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 001100 xn_sp:5 11111" "asm"="stsetl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMAXL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 010000 xn_sp:5 xt:5" "asm"="ldsmaxl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stsmaxl" {
  ret void
}

define void @LDSMAXL_64_memop.STSMAXL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 010000 xn_sp:5 11111" "asm"="stsmaxl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDSMINL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 010100 xn_sp:5 xt:5" "asm"="ldsminl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stsminl" {
  ret void
}

define void @LDSMINL_64_memop.STSMINL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 010100 xn_sp:5 11111" "asm"="stsminl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMAXL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 011000 xn_sp:5 xt:5" "asm"="ldumaxl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stumaxl" {
  ret void
}

define void @LDUMAXL_64_memop.STUMAXL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 011000 xn_sp:5 11111" "asm"="stumaxl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDUMINL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 011100 xn_sp:5 xt:5" "asm"="lduminl {xs}, {xt}, [{xn_sp}]" "asmonly" "aliases"="stuminl" {
  ret void
}

define void @LDUMINL_64_memop.STUMINL.0(i64 "reg"="x" %xs, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 011100 xn_sp:5 11111" "asm"="stuminl {xs}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @SWPL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000011 xs:5 100000 xn_sp:5 xt:5" "asm"="swpl {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDADDA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 000000 xn_sp:5 xt:5" "asm"="ldadda {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 000100 xn_sp:5 xt:5" "asm"="ldclra {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 001000 xn_sp:5 xt:5" "asm"="ldeora {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 001100 xn_sp:5 xt:5" "asm"="ldseta {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 010000 xn_sp:5 xt:5" "asm"="ldsmaxa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 010100 xn_sp:5 xt:5" "asm"="ldsmina {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 011000 xn_sp:5 xt:5" "asm"="ldumaxa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 011100 xn_sp:5 xt:5" "asm"="ldumina {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPA_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xs:5 100000 xn_sp:5 xt:5" "asm"="swpa {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDAPR_64L_memop.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100010111111110000 xn_sp:5 xt:5" "asm"="ldapr {xt}, [{xn_sp} , #0]" "asmonly" {
  ret void
}

define void @LDAPR_64L_memop.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100010111111110000 xn_sp:5 xt:5" "asm"="ldapr {xt}, [{xn_sp}]" "asmonly" "nodecode" {
  ret void
}

define void @LDADDAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 000000 xn_sp:5 xt:5" "asm"="ldaddal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDCLRAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 000100 xn_sp:5 xt:5" "asm"="ldclral {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDEORAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 001000 xn_sp:5 xt:5" "asm"="ldeoral {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSETAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 001100 xn_sp:5 xt:5" "asm"="ldsetal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMAXAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 010000 xn_sp:5 xt:5" "asm"="ldsmaxal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDSMINAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 010100 xn_sp:5 xt:5" "asm"="ldsminal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMAXAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 011000 xn_sp:5 xt:5" "asm"="ldumaxal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDUMINAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 011100 xn_sp:5 xt:5" "asm"="lduminal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @SWPAL_64_memop.0(i64 "reg"="x" %xs, i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="11111000111 xs:5 100000 xn_sp:5 xt:5" "asm"="swpal {xs}, {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFADD_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 000000 xn_sp:5 ht:5" "asm"="ldbfadd {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAX_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 010000 xn_sp:5 ht:5" "asm"="ldbfmax {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMIN_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 010100 xn_sp:5 ht:5" "asm"="ldbfmin {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXNM_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 011000 xn_sp:5 ht:5" "asm"="ldbfmaxnm {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINNM_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 011100 xn_sp:5 ht:5" "asm"="ldbfminnm {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFADD_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 100000 xn_sp:5 11111" "asm"="stbfadd {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMAX_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 110000 xn_sp:5 11111" "asm"="stbfmax {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMIN_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 110100 xn_sp:5 11111" "asm"="stbfmin {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMAXNM_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 111000 xn_sp:5 11111" "asm"="stbfmaxnm {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMINNM_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100001 hs:5 111100 xn_sp:5 11111" "asm"="stbfminnm {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFADDL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 100000 xn_sp:5 11111" "asm"="stbfaddl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMAXL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 110000 xn_sp:5 11111" "asm"="stbfmaxl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMINL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 110100 xn_sp:5 11111" "asm"="stbfminl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMAXNML_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 111000 xn_sp:5 11111" "asm"="stbfmaxnml {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STBFMINNML_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 111100 xn_sp:5 11111" "asm"="stbfminnml {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFADDL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 000000 xn_sp:5 ht:5" "asm"="ldbfaddl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 010000 xn_sp:5 ht:5" "asm"="ldbfmaxl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 010100 xn_sp:5 ht:5" "asm"="ldbfminl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXNML_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 011000 xn_sp:5 ht:5" "asm"="ldbfmaxnml {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINNML_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100011 hs:5 011100 xn_sp:5 ht:5" "asm"="ldbfminnml {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFADDA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100101 hs:5 000000 xn_sp:5 ht:5" "asm"="ldbfadda {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100101 hs:5 010000 xn_sp:5 ht:5" "asm"="ldbfmaxa {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100101 hs:5 010100 xn_sp:5 ht:5" "asm"="ldbfmina {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXNMA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100101 hs:5 011000 xn_sp:5 ht:5" "asm"="ldbfmaxnma {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINNMA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100101 hs:5 011100 xn_sp:5 ht:5" "asm"="ldbfminnma {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFADDAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100111 hs:5 000000 xn_sp:5 ht:5" "asm"="ldbfaddal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100111 hs:5 010000 xn_sp:5 ht:5" "asm"="ldbfmaxal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100111 hs:5 010100 xn_sp:5 ht:5" "asm"="ldbfminal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMAXNMAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100111 hs:5 011000 xn_sp:5 ht:5" "asm"="ldbfmaxnmal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDBFMINNMAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="00111100111 hs:5 011100 xn_sp:5 ht:5" "asm"="ldbfminnmal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADD_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 000000 xn_sp:5 ht:5" "asm"="ldfadd {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAX_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 010000 xn_sp:5 ht:5" "asm"="ldfmax {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMIN_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 010100 xn_sp:5 ht:5" "asm"="ldfmin {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNM_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 011000 xn_sp:5 ht:5" "asm"="ldfmaxnm {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNM_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 011100 xn_sp:5 ht:5" "asm"="ldfminnm {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADD_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 100000 xn_sp:5 11111" "asm"="stfadd {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAX_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 110000 xn_sp:5 11111" "asm"="stfmax {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMIN_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 110100 xn_sp:5 11111" "asm"="stfmin {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNM_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 111000 xn_sp:5 11111" "asm"="stfmaxnm {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNM_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100001 hs:5 111100 xn_sp:5 11111" "asm"="stfminnm {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADDL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 100000 xn_sp:5 11111" "asm"="stfaddl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 110000 xn_sp:5 11111" "asm"="stfmaxl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINL_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 110100 xn_sp:5 11111" "asm"="stfminl {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNML_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 111000 xn_sp:5 11111" "asm"="stfmaxnml {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNML_16.0(i64 "reg"="h" %hs, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 111100 xn_sp:5 11111" "asm"="stfminnml {hs}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 000000 xn_sp:5 ht:5" "asm"="ldfaddl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 010000 xn_sp:5 ht:5" "asm"="ldfmaxl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 010100 xn_sp:5 ht:5" "asm"="ldfminl {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNML_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 011000 xn_sp:5 ht:5" "asm"="ldfmaxnml {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNML_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100011 hs:5 011100 xn_sp:5 ht:5" "asm"="ldfminnml {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100101 hs:5 000000 xn_sp:5 ht:5" "asm"="ldfadda {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100101 hs:5 010000 xn_sp:5 ht:5" "asm"="ldfmaxa {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100101 hs:5 010100 xn_sp:5 ht:5" "asm"="ldfmina {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100101 hs:5 011000 xn_sp:5 ht:5" "asm"="ldfmaxnma {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMA_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100101 hs:5 011100 xn_sp:5 ht:5" "asm"="ldfminnma {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100111 hs:5 000000 xn_sp:5 ht:5" "asm"="ldfaddal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100111 hs:5 010000 xn_sp:5 ht:5" "asm"="ldfmaxal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100111 hs:5 010100 xn_sp:5 ht:5" "asm"="ldfminal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100111 hs:5 011000 xn_sp:5 ht:5" "asm"="ldfmaxnmal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMAL_16.0(i64 "reg"="h" %hs, i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="01111100111 hs:5 011100 xn_sp:5 ht:5" "asm"="ldfminnmal {hs}, {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADD_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 000000 xn_sp:5 st:5" "asm"="ldfadd {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAX_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 010000 xn_sp:5 st:5" "asm"="ldfmax {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMIN_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 010100 xn_sp:5 st:5" "asm"="ldfmin {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNM_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 011000 xn_sp:5 st:5" "asm"="ldfmaxnm {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNM_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 011100 xn_sp:5 st:5" "asm"="ldfminnm {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADD_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 100000 xn_sp:5 11111" "asm"="stfadd {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAX_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 110000 xn_sp:5 11111" "asm"="stfmax {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMIN_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 110100 xn_sp:5 11111" "asm"="stfmin {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNM_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 111000 xn_sp:5 11111" "asm"="stfmaxnm {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNM_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100001 ss:5 111100 xn_sp:5 11111" "asm"="stfminnm {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADDL_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 100000 xn_sp:5 11111" "asm"="stfaddl {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXL_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 110000 xn_sp:5 11111" "asm"="stfmaxl {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINL_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 110100 xn_sp:5 11111" "asm"="stfminl {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNML_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 111000 xn_sp:5 11111" "asm"="stfmaxnml {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNML_32.0(i64 "reg"="s" %ss, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 111100 xn_sp:5 11111" "asm"="stfminnml {ss}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 000000 xn_sp:5 st:5" "asm"="ldfaddl {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 010000 xn_sp:5 st:5" "asm"="ldfmaxl {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 010100 xn_sp:5 st:5" "asm"="ldfminl {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNML_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 011000 xn_sp:5 st:5" "asm"="ldfmaxnml {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNML_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100011 ss:5 011100 xn_sp:5 st:5" "asm"="ldfminnml {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDA_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100101 ss:5 000000 xn_sp:5 st:5" "asm"="ldfadda {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXA_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100101 ss:5 010000 xn_sp:5 st:5" "asm"="ldfmaxa {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINA_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100101 ss:5 010100 xn_sp:5 st:5" "asm"="ldfmina {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMA_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100101 ss:5 011000 xn_sp:5 st:5" "asm"="ldfmaxnma {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMA_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100101 ss:5 011100 xn_sp:5 st:5" "asm"="ldfminnma {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDAL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100111 ss:5 000000 xn_sp:5 st:5" "asm"="ldfaddal {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXAL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100111 ss:5 010000 xn_sp:5 st:5" "asm"="ldfmaxal {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINAL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100111 ss:5 010100 xn_sp:5 st:5" "asm"="ldfminal {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMAL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100111 ss:5 011000 xn_sp:5 st:5" "asm"="ldfmaxnmal {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMAL_32.0(i64 "reg"="s" %ss, i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp) "enc"="10111100111 ss:5 011100 xn_sp:5 st:5" "asm"="ldfminnmal {ss}, {st}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADD_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 000000 xn_sp:5 dt:5" "asm"="ldfadd {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAX_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 010000 xn_sp:5 dt:5" "asm"="ldfmax {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMIN_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 010100 xn_sp:5 dt:5" "asm"="ldfmin {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNM_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 011000 xn_sp:5 dt:5" "asm"="ldfmaxnm {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNM_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 011100 xn_sp:5 dt:5" "asm"="ldfminnm {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADD_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 100000 xn_sp:5 11111" "asm"="stfadd {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAX_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 110000 xn_sp:5 11111" "asm"="stfmax {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMIN_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 110100 xn_sp:5 11111" "asm"="stfmin {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNM_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 111000 xn_sp:5 11111" "asm"="stfmaxnm {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNM_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100001 ds:5 111100 xn_sp:5 11111" "asm"="stfminnm {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFADDL_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 100000 xn_sp:5 11111" "asm"="stfaddl {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXL_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 110000 xn_sp:5 11111" "asm"="stfmaxl {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINL_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 110100 xn_sp:5 11111" "asm"="stfminl {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMAXNML_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 111000 xn_sp:5 11111" "asm"="stfmaxnml {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STFMINNML_64.0(i64 "reg"="d" %ds, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 111100 xn_sp:5 11111" "asm"="stfminnml {ds}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 000000 xn_sp:5 dt:5" "asm"="ldfaddl {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 010000 xn_sp:5 dt:5" "asm"="ldfmaxl {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 010100 xn_sp:5 dt:5" "asm"="ldfminl {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNML_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 011000 xn_sp:5 dt:5" "asm"="ldfmaxnml {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNML_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100011 ds:5 011100 xn_sp:5 dt:5" "asm"="ldfminnml {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDA_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100101 ds:5 000000 xn_sp:5 dt:5" "asm"="ldfadda {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXA_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100101 ds:5 010000 xn_sp:5 dt:5" "asm"="ldfmaxa {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINA_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100101 ds:5 010100 xn_sp:5 dt:5" "asm"="ldfmina {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMA_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100101 ds:5 011000 xn_sp:5 dt:5" "asm"="ldfmaxnma {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMA_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100101 ds:5 011100 xn_sp:5 dt:5" "asm"="ldfminnma {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFADDAL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100111 ds:5 000000 xn_sp:5 dt:5" "asm"="ldfaddal {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXAL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100111 ds:5 010000 xn_sp:5 dt:5" "asm"="ldfmaxal {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINAL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100111 ds:5 010100 xn_sp:5 dt:5" "asm"="ldfminal {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMAXNMAL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100111 ds:5 011000 xn_sp:5 dt:5" "asm"="ldfmaxnmal {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDFMINNMAL_64.0(i64 "reg"="d" %ds, i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp) "enc"="11111100111 ds:5 011100 xn_sp:5 dt:5" "asm"="ldfminnmal {ds}, {dt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000001 wm:5 010010 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000001 wm:5 010110 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000001 wm:5 110010 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000001 wm:5 110110 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000001 xm:5 111010 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @STRB_32B_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000001 xm:5 111110 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STRB_32BL_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000001 xm:5 011110 xn_sp:5 wt:5" "asm"="strb {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000011 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000011 wm:5 010110 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000011 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000011 wm:5 110110 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000011 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @LDRB_32B_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000011 xm:5 111110 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRB_32BL_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000011 xm:5 011110 xn_sp:5 wt:5" "asm"="ldrb {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000101 wm:5 010010 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000101 wm:5 010110 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.2(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000101 wm:5 110010 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.3(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000101 wm:5 110110 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.4(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000101 xm:5 111010 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @LDRSB_64B_ldst_regoff.5(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000101 xm:5 111110 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRSB_64BL_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000101 xm:5 011110 xn_sp:5 xt:5" "asm"="ldrsb {xt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000111 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000111 wm:5 010110 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000111 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111000111 wm:5 110110 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000111 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @LDRSB_32B_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000111 xm:5 111110 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRSB_32BL_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111000111 xm:5 011110 xn_sp:5 wt:5" "asm"="ldrsb {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100001 wm:5 010010 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100001 wm:5 010110 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.2(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100001 wm:5 110010 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.3(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100001 wm:5 110110 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.4(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100001 xm:5 111010 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @STR_B_ldst_regoff.5(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100001 xm:5 111110 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_BL_ldst_regoff.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100001 xm:5 011010 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {xm}]" "asmonly" {
  ret void
}

define void @STR_BL_ldst_regoff.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100001 xm:5 011110 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100011 wm:5 010010 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {wm}, uxtw]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100011 wm:5 010110 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.2(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100011 wm:5 110010 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {wm}, sxtw]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.3(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100011 wm:5 110110 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.4(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100011 xm:5 111010 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {xm}, sxtx]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_regoff.5(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100011 xm:5 111110 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_BL_ldst_regoff.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100011 xm:5 011010 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {xm}]" "asmonly" {
  ret void
}

define void @LDR_BL_ldst_regoff.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100011 xm:5 011110 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 010010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.1(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 010110 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, uxtw #4]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.2(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 010010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_Q_ldst_regoff.3(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 110010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.4(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 110110 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, sxtw #4]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.5(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100101 wm:5 110010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_Q_ldst_regoff.6(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100101 xm:5 011010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.7(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100101 xm:5 111010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.8(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100101 xm:5 111110 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {xm}, sxtx #4]" "asmonly" {
  ret void
}

define void @STR_Q_ldst_regoff.9(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100101 xm:5 111010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_Q_ldst_regoff.10(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100101 xm:5 011010 xn_sp:5 qt:5" "asm"="str {qt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_Q_ldst_regoff.0(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 010010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.1(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 010110 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, uxtw #4]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.2(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 010010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_Q_ldst_regoff.3(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 110010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.4(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 110110 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, sxtw #4]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.5(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="00111100111 wm:5 110010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_Q_ldst_regoff.6(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100111 xm:5 011010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.7(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100111 xm:5 111010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.8(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100111 xm:5 111110 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {xm}, sxtx #4]" "asmonly" {
  ret void
}

define void @LDR_Q_ldst_regoff.9(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100111 xm:5 111010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_Q_ldst_regoff.10(i64 "reg"="q" %qt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="00111100111 xm:5 011010 xn_sp:5 qt:5" "asm"="ldr {qt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @STRH_32_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 010010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 010110 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 010010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STRH_32_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 110010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 110110 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000001 wm:5 110010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STRH_32_ldst_regoff.6(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000001 xm:5 011010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.7(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000001 xm:5 111010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.8(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000001 xm:5 111110 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @STRH_32_ldst_regoff.9(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000001 xm:5 111010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STRH_32_ldst_regoff.10(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000001 xm:5 011010 xn_sp:5 wt:5" "asm"="strh {wt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDRH_32_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 010110 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRH_32_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 110110 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000011 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRH_32_ldst_regoff.6(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000011 xm:5 011010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.7(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000011 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.8(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000011 xm:5 111110 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @LDRH_32_ldst_regoff.9(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000011 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDRH_32_ldst_regoff.10(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000011 xm:5 011010 xn_sp:5 wt:5" "asm"="ldrh {wt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_64_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 010010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 010110 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.2(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 010010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_64_ldst_regoff.3(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 110010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.4(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 110110 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.5(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000101 wm:5 110010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_64_ldst_regoff.6(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000101 xm:5 011010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.7(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000101 xm:5 111010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.8(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000101 xm:5 111110 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_regoff.9(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000101 xm:5 111010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_64_ldst_regoff.10(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000101 xm:5 011010 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_32_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 010110 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 010010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_32_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 110110 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111000111 wm:5 110010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_32_ldst_regoff.6(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000111 xm:5 011010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.7(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000111 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.8(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000111 xm:5 111110 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @LDRSH_32_ldst_regoff.9(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000111 xm:5 111010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSH_32_ldst_regoff.10(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111000111 xm:5 011010 xn_sp:5 wt:5" "asm"="ldrsh {wt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @STR_H_ldst_regoff.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 010010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 010110 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.2(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 010010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_H_ldst_regoff.3(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 110010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.4(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 110110 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.5(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100001 wm:5 110010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_H_ldst_regoff.6(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 011010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.7(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 011110 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}, lsl #1]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.8(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 111010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.9(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 111110 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @STR_H_ldst_regoff.10(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 111010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_H_ldst_regoff.11(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100001 xm:5 011010 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_H_ldst_regoff.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 010010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 010110 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, uxtw #1]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.2(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 010010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_H_ldst_regoff.3(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 110010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.4(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 110110 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, sxtw #1]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.5(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="01111100011 wm:5 110010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_H_ldst_regoff.6(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 011010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.7(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 011110 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}, lsl #1]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.8(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 111010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.9(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 111110 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}, sxtx #1]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_regoff.10(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 111010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_H_ldst_regoff.11(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="01111100011 xm:5 011010 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @STR_32_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000001 wm:5 010010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000001 wm:5 010110 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {wm}, uxtw #2]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000001 wm:5 010010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_32_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000001 wm:5 110010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000001 wm:5 110010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_32_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000001 xm:5 011010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.6(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000001 xm:5 111010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.7(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000001 xm:5 111110 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {xm}, sxtx #2]" "asmonly" {
  ret void
}

define void @STR_32_ldst_regoff.8(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000001 xm:5 111010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_32_ldst_regoff.9(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000001 xm:5 011010 xn_sp:5 wt:5" "asm"="str {wt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_32_ldst_regoff.0(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000011 wm:5 010010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.1(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000011 wm:5 010110 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {wm}, uxtw #2]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.2(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000011 wm:5 010010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_32_ldst_regoff.3(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000011 wm:5 110010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.4(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000011 wm:5 110010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_32_ldst_regoff.5(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000011 xm:5 011010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.6(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000011 xm:5 111010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.7(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000011 xm:5 111110 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {xm}, sxtx #2]" "asmonly" {
  ret void
}

define void @LDR_32_ldst_regoff.8(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000011 xm:5 111010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_32_ldst_regoff.9(i64 "reg"="w" %wt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000011 xm:5 011010 xn_sp:5 wt:5" "asm"="ldr {wt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSW_64_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000101 wm:5 010010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000101 wm:5 010110 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {wm}, uxtw #2]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.2(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000101 wm:5 010010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSW_64_ldst_regoff.3(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000101 wm:5 110010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.4(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111000101 wm:5 110010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSW_64_ldst_regoff.5(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000101 xm:5 011010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.6(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000101 xm:5 111010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.7(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000101 xm:5 111110 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {xm}, sxtx #2]" "asmonly" {
  ret void
}

define void @LDRSW_64_ldst_regoff.8(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000101 xm:5 111010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDRSW_64_ldst_regoff.9(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111000101 xm:5 011010 xn_sp:5 xt:5" "asm"="ldrsw {xt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @STR_S_ldst_regoff.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 010010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.1(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 010110 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, uxtw #2]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.2(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 010010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_S_ldst_regoff.3(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 110010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.4(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 110110 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, sxtw #2]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.5(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100001 wm:5 110010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_S_ldst_regoff.6(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100001 xm:5 011010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.7(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100001 xm:5 111010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.8(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100001 xm:5 111110 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {xm}, sxtx #2]" "asmonly" {
  ret void
}

define void @STR_S_ldst_regoff.9(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100001 xm:5 111010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_S_ldst_regoff.10(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100001 xm:5 011010 xn_sp:5 st:5" "asm"="str {st}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_S_ldst_regoff.0(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 010010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.1(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 010110 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, uxtw #2]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.2(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 010010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_S_ldst_regoff.3(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 110010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.4(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 110110 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, sxtw #2]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.5(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="10111100011 wm:5 110010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_S_ldst_regoff.6(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100011 xm:5 011010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.7(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100011 xm:5 111010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.8(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100011 xm:5 111110 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {xm}, sxtx #2]" "asmonly" {
  ret void
}

define void @LDR_S_ldst_regoff.9(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100011 xm:5 111010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_S_ldst_regoff.10(i64 "reg"="s" %st, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10111100011 xm:5 011010 xn_sp:5 st:5" "asm"="ldr {st}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @STR_64_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 010010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 010110 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, uxtw #3]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.2(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 010010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_64_ldst_regoff.3(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 110010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.4(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 110110 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, sxtw #3]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.5(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000001 wm:5 110010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_64_ldst_regoff.6(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000001 xm:5 011010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.7(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000001 xm:5 111010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.8(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000001 xm:5 111110 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {xm}, sxtx #3]" "asmonly" {
  ret void
}

define void @STR_64_ldst_regoff.9(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000001 xm:5 111010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_64_ldst_regoff.10(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000001 xm:5 011010 xn_sp:5 xt:5" "asm"="str {xt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_64_ldst_regoff.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 010010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 010110 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, uxtw #3]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.2(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 010010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_64_ldst_regoff.3(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 110010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.4(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 110110 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, sxtw #3]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.5(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111000011 wm:5 110010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_64_ldst_regoff.6(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000011 xm:5 011010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.7(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000011 xm:5 111010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.8(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000011 xm:5 111110 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {xm}, sxtx #3]" "asmonly" {
  ret void
}

define void @LDR_64_ldst_regoff.9(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000011 xm:5 111010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_64_ldst_regoff.10(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111000011 xm:5 011010 xn_sp:5 xt:5" "asm"="ldr {xt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @RPRFM_R_ldst_regoff.0(i64 "reg"="x" %xm, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xm:5 010010 xn_sp:5 11000" "asm"="rprfm pldkeep, {xm}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RPRFM_R_ldst_regoff.1(i64 "reg"="x" %xm, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xm:5 010010 xn_sp:5 11100" "asm"="rprfm pldstrm, {xm}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RPRFM_R_ldst_regoff.2(i64 "reg"="x" %xm, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xm:5 010010 xn_sp:5 11001" "asm"="rprfm pstkeep, {xm}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RPRFM_R_ldst_regoff.3(i64 "reg"="x" %xm, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xm:5 010010 xn_sp:5 11101" "asm"="rprfm pststrm, {xm}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @RPRFM_R_ldst_regoff.4(i64 "imm" %imm6, i64 "reg"="x" %xm, i64 "reg"="xsp" %xn_sp) "enc"="11111000101 xm:5 imm61:1=(imm6>>5)&1 1 imm62:2=(imm6>>3)&3 10 xn_sp:5 11 imm63:3=imm6&7" "asm"="rprfm #{imm6}, {xm}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 010010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.1(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 010110 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, uxtw #3]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.2(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 010010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_D_ldst_regoff.3(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 110010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.4(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 110110 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, sxtw #3]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.5(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100001 wm:5 110010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @STR_D_ldst_regoff.6(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100001 xm:5 011010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.7(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100001 xm:5 111010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.8(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100001 xm:5 111110 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {xm}, sxtx #3]" "asmonly" {
  ret void
}

define void @STR_D_ldst_regoff.9(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100001 xm:5 111010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @STR_D_ldst_regoff.10(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100001 xm:5 011010 xn_sp:5 dt:5" "asm"="str {dt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_D_ldst_regoff.0(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 010010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, uxtw #0]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.1(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 010110 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, uxtw #3]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.2(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 010010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, uxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_D_ldst_regoff.3(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 110010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, sxtw #0]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.4(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 110110 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, sxtw #3]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.5(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="w" %wm) "enc"="11111100011 wm:5 110010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {wm}, sxtw]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_D_ldst_regoff.6(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100011 xm:5 011010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {xm}, lsl #0]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.7(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100011 xm:5 111010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {xm}, sxtx #0]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.8(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100011 xm:5 111110 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {xm}, sxtx #3]" "asmonly" {
  ret void
}

define void @LDR_D_ldst_regoff.9(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100011 xm:5 111010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {xm}, sxtx]" "asmonly" "nodecode" {
  ret void
}

define void @LDR_D_ldst_regoff.10(i64 "reg"="d" %dt, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="11111100011 xm:5 011010 xn_sp:5 dt:5" "asm"="ldr {dt}, [{xn_sp}, {xm}]" "asmonly" "nodecode" {
  ret void
}

define void @LDRAA_64_ldst_pac.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100000100000000001 xn_sp:5 xt:5" "asm"="ldraa {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDRAA_64_ldst_pac.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="111110000 simm1:s1=simm>>12 1 simm2:9=(simm>>3)&511 01 xn_sp:5 xt:5" "asm"="ldraa {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDRAA_64W_ldst_pac.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100000100000000011 xn_sp:5 xt:5" "asm"="ldraa {xt}, [{xn_sp}]!" "asmonly" {
  ret void
}

define void @LDRAA_64W_ldst_pac.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="111110000 simm1:s1=simm>>12 1 simm2:9=(simm>>3)&511 11 xn_sp:5 xt:5" "asm"="ldraa {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @LDRAB_64_ldst_pac.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100010100000000001 xn_sp:5 xt:5" "asm"="ldrab {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDRAB_64_ldst_pac.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="111110001 simm1:s1=simm>>12 1 simm2:9=(simm>>3)&511 01 xn_sp:5 xt:5" "asm"="ldrab {xt}, [{xn_sp}, #{simm}]" "asmonly" {
  ret void
}

define void @LDRAB_64W_ldst_pac.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="1111100010100000000011 xn_sp:5 xt:5" "asm"="ldrab {xt}, [{xn_sp}]!" "asmonly" {
  ret void
}

define void @LDRAB_64W_ldst_pac.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %simm) "enc"="111110001 simm1:s1=simm>>12 1 simm2:9=(simm>>3)&511 11 xn_sp:5 xt:5" "asm"="ldrab {xt}, [{xn_sp}, #{simm}]!" "asmonly" {
  ret void
}

define void @STR_B_ldst_pos.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0011110100000000000000 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STR_B_ldst_pos.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %pimm) "enc"="0011110100 pimm:12 xn_sp:5 bt:5" "asm"="str {bt}, [{xn_sp}, #{pimm}]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_pos.0(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp) "enc"="0011110101000000000000 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDR_B_ldst_pos.1(i64 "reg"="b" %bt, i64 "reg"="xsp" %xn_sp, i64 "imm" %pimm) "enc"="0011110101 pimm:12 xn_sp:5 bt:5" "asm"="ldr {bt}, [{xn_sp}, #{pimm}]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_pos.0(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp) "enc"="0111100110000000000000 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDRSH_64_ldst_pos.1(i64 "reg"="x" %xt, i64 "reg"="xsp" %xn_sp, i64 "imm" %pimm) "enc"="0111100110 pimm_f:12=pimm>>1 xn_sp:5 xt:5" "asm"="ldrsh {xt}, [{xn_sp}, #{pimm}]" "asmonly" {
  ret void
}

define void @STR_H_ldst_pos.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0111110100000000000000 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @STR_H_ldst_pos.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %pimm) "enc"="0111110100 pimm_f:12=pimm>>1 xn_sp:5 ht:5" "asm"="str {ht}, [{xn_sp}, #{pimm}]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_pos.0(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp) "enc"="0111110101000000000000 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}]" "asmonly" {
  ret void
}

define void @LDR_H_ldst_pos.1(i64 "reg"="h" %ht, i64 "reg"="xsp" %xn_sp, i64 "imm" %pimm) "enc"="0111110101 pimm_f:12=pimm>>1 xn_sp:5 ht:5" "asm"="ldr {ht}, [{xn_sp}, #{pimm}]" "asmonly" {
  ret void
}

define void @CRC32B_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010000 wn:5 wd:5" "asm"="crc32b {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @CRC32H_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010001 wn:5 wd:5" "asm"="crc32h {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @CRC32W_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010010 wn:5 wd:5" "asm"="crc32w {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @CRC32CB_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010100 wn:5 wd:5" "asm"="crc32cb {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @CRC32CH_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010101 wn:5 wd:5" "asm"="crc32ch {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @CRC32CW_32C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 010110 wn:5 wd:5" "asm"="crc32cw {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @SMAX_32_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 011000 wn:5 wd:5" "asm"="smax {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @UMAX_32_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 011001 wn:5 wd:5" "asm"="umax {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @SMIN_32_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 011010 wn:5 wd:5" "asm"="smin {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @UMIN_32_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010110 wm:5 011011 wn:5 wd:5" "asm"="umin {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @SUBP_64S_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "reg"="xsp" %xm_sp) "enc"="10011010110 xm_sp:5 000000 xn_sp:5 xd:5" "asm"="subp {xd}, {xn_sp}, {xm_sp}" "asmonly" {
  ret void
}

define void @IRG_64I_dp_2src.0(i64 "reg"="xsp" %xd_sp, i64 "reg"="xsp" %xn_sp) "enc"="1001101011011111000100 xn_sp:5 xd_sp:5" "asm"="irg {xd_sp}, {xn_sp}" "asmonly" {
  ret void
}

define void @IRG_64I_dp_2src.1(i64 "reg"="xsp" %xd_sp, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 000100 xn_sp:5 xd_sp:5" "asm"="irg {xd_sp}, {xn_sp}, {xm}" "asmonly" {
  ret void
}

define void @GMI_64G_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 000101 xn_sp:5 xd:5" "asm"="gmi {xd}, {xn_sp}, {xm}" "asmonly" {
  ret void
}

define void @PACGA_64P_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="xsp" %xm_sp) "enc"="10011010110 xm_sp:5 001100 xn:5 xd:5" "asm"="pacga {xd}, {xn}, {xm_sp}" "asmonly" {
  ret void
}

define void @CRC32X_64C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 010011 wn:5 wd:5" "asm"="crc32x {wd}, {wn}, {xm}" "asmonly" {
  ret void
}

define void @CRC32CX_64C_dp_2src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 010111 wn:5 wd:5" "asm"="crc32cx {wd}, {wn}, {xm}" "asmonly" {
  ret void
}

define void @SMAX_64_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 011000 xn:5 xd:5" "asm"="smax {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @UMAX_64_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 011001 xn:5 xd:5" "asm"="umax {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @SMIN_64_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 011010 xn:5 xd:5" "asm"="smin {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @UMIN_64_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010110 xm:5 011011 xn:5 xd:5" "asm"="umin {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @SUBPS_64S_dp_2src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp, i64 "reg"="xsp" %xm_sp) "enc"="10111010110 xm_sp:5 000000 xn_sp:5 xd:5" "asm"="subps {xd}, {xn_sp}, {xm_sp}" "asmonly" "aliases"="cmpp" {
  ret void
}

define void @SUBPS_64S_dp_2src.CMPP.0(i64 "reg"="xsp" %xn_sp, i64 "reg"="xsp" %xm_sp) "enc"="10111010110 xm_sp:5 000000 xn_sp:5 11111" "asm"="cmpp {xn_sp}, {xm_sp}" "asmonly" "nodecode" {
  ret void
}

define void @CLS_32_dp_1src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="0101101011000000000101 wn:5 wd:5" "asm"="cls {wd}, {wn}" "asmonly" {
  ret void
}

define void @CTZ_32_dp_1src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="0101101011000000000110 wn:5 wd:5" "asm"="ctz {wd}, {wn}" "asmonly" {
  ret void
}

define void @CNT_32_dp_1src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="0101101011000000000111 wn:5 wd:5" "asm"="cnt {wd}, {wn}" "asmonly" {
  ret void
}

define void @ABS_32_dp_1src.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="0101101011000000001000 wn:5 wd:5" "asm"="abs {wd}, {wn}" "asmonly" {
  ret void
}

define void @REV16_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000000001 xn:5 xd:5" "asm"="rev16 {xd}, {xn}" "asmonly" {
  ret void
}

define void @REV32_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000000010 xn:5 xd:5" "asm"="rev32 {xd}, {xn}" "asmonly" {
  ret void
}

define void @CLS_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000000101 xn:5 xd:5" "asm"="cls {xd}, {xn}" "asmonly" {
  ret void
}

define void @CTZ_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000000110 xn:5 xd:5" "asm"="ctz {xd}, {xn}" "asmonly" {
  ret void
}

define void @CNT_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000000111 xn:5 xd:5" "asm"="cnt {xd}, {xn}" "asmonly" {
  ret void
}

define void @ABS_64_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="1101101011000000001000 xn:5 xd:5" "asm"="abs {xd}, {xn}" "asmonly" {
  ret void
}

define void @PACIA_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000000 xn_sp:5 xd:5" "asm"="pacia {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @PACIB_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000001 xn_sp:5 xd:5" "asm"="pacib {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @PACDA_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000010 xn_sp:5 xd:5" "asm"="pacda {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @PACDB_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000011 xn_sp:5 xd:5" "asm"="pacdb {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @AUTIA_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000100 xn_sp:5 xd:5" "asm"="autia {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @AUTIB_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000101 xn_sp:5 xd:5" "asm"="autib {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @AUTDA_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000110 xn_sp:5 xd:5" "asm"="autda {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @AUTDB_64P_dp_1src.0(i64 "reg"="x" %xd, i64 "reg"="xsp" %xn_sp) "enc"="1101101011000001000111 xn_sp:5 xd:5" "asm"="autdb {xd}, {xn_sp}" "asmonly" {
  ret void
}

define void @PACIZA_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100100011111 xd:5" "asm"="paciza {xd}" "asmonly" {
  ret void
}

define void @PACIZB_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100100111111 xd:5" "asm"="pacizb {xd}" "asmonly" {
  ret void
}

define void @PACDZA_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100101011111 xd:5" "asm"="pacdza {xd}" "asmonly" {
  ret void
}

define void @PACDZB_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100101111111 xd:5" "asm"="pacdzb {xd}" "asmonly" {
  ret void
}

define void @AUTIZA_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100110011111 xd:5" "asm"="autiza {xd}" "asmonly" {
  ret void
}

define void @AUTIZB_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100110111111 xd:5" "asm"="autizb {xd}" "asmonly" {
  ret void
}

define void @AUTDZA_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100111011111 xd:5" "asm"="autdza {xd}" "asmonly" {
  ret void
}

define void @AUTDZB_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000100111111111 xd:5" "asm"="autdzb {xd}" "asmonly" {
  ret void
}

define void @XPACI_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000101000011111 xd:5" "asm"="xpaci {xd}" "asmonly" {
  ret void
}

define void @XPACD_64Z_dp_1src.0(i64 "reg"="x" %xd) "enc"="110110101100000101000111111 xd:5" "asm"="xpacd {xd}" "asmonly" {
  ret void
}

define void @PACNBIASPPC_64LR_dp_1src.0() "enc"="11011010110000011000001111111110" "asm"="pacnbiasppc" "asmonly" {
  ret void
}

define void @PACNBIBSPPC_64LR_dp_1src.0() "enc"="11011010110000011000011111111110" "asm"="pacnbibsppc" "asmonly" {
  ret void
}

define void @PACIA171615_64LR_dp_1src.0() "enc"="11011010110000011000101111111110" "asm"="pacia171615" "asmonly" {
  ret void
}

define void @PACIB171615_64LR_dp_1src.0() "enc"="11011010110000011000111111111110" "asm"="pacib171615" "asmonly" {
  ret void
}

define void @AUTIASPPCR_64LRR_dp_1src.0(i64 "reg"="x" %xn) "enc"="1101101011000001100100 xn:5 11110" "asm"="autiasppcr {xn}" "asmonly" {
  ret void
}

define void @AUTIBSPPCR_64LRR_dp_1src.0(i64 "reg"="x" %xn) "enc"="1101101011000001100101 xn:5 11110" "asm"="autibsppcr {xn}" "asmonly" {
  ret void
}

define void @PACIASPPC_64LR_dp_1src.0() "enc"="11011010110000011010001111111110" "asm"="paciasppc" "asmonly" {
  ret void
}

define void @PACIBSPPC_64LR_dp_1src.0() "enc"="11011010110000011010011111111110" "asm"="pacibsppc" "asmonly" {
  ret void
}

define void @AUTIA171615_64LR_dp_1src.0() "enc"="11011010110000011011101111111110" "asm"="autia171615" "asmonly" {
  ret void
}

define void @AUTIB171615_64LR_dp_1src.0() "enc"="11011010110000011011111111111110" "asm"="autib171615" "asmonly" {
  ret void
}

define void @AND_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010000 wm:5 0 amount:5 wn:5 wd:5" "asm"="and {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @AND_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010010 wm:5 0 amount:5 wn:5 wd:5" "asm"="and {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @AND_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010100 wm:5 0 amount:5 wn:5 wd:5" "asm"="and {wd}, {wn}, {wm}, asr #{amount}" "asmonly" {
  ret void
}

define void @AND_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010110 wm:5 0 amount:5 wn:5 wd:5" "asm"="and {wd}, {wn}, {wm}, ror #{amount}" "asmonly" {
  ret void
}

define void @BIC_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010001 wm:5 0 amount:5 wn:5 wd:5" "asm"="bic {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @BIC_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010011 wm:5 0 amount:5 wn:5 wd:5" "asm"="bic {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @BIC_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010101 wm:5 0 amount:5 wn:5 wd:5" "asm"="bic {wd}, {wn}, {wm}, asr #{amount}" "asmonly" {
  ret void
}

define void @BIC_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001010111 wm:5 0 amount:5 wn:5 wd:5" "asm"="bic {wd}, {wn}, {wm}, ror #{amount}" "asmonly" {
  ret void
}

define void @ORR_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010000 wm:5 0 amount:5 wn:5 wd:5" "asm"="orr {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010010 wm:5 0 amount:5 wn:5 wd:5" "asm"="orr {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010100 wm:5 0 amount:5 wn:5 wd:5" "asm"="orr {wd}, {wn}, {wm}, asr #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010110 wm:5 0 amount:5 wn:5 wd:5" "asm"="orr {wd}, {wn}, {wm}, ror #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORN_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010001 wm:5 0 amount:5 wn:5 wd:5" "asm"="orn {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010011 wm:5 0 amount:5 wn:5 wd:5" "asm"="orn {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010101 wm:5 0 amount:5 wn:5 wd:5" "asm"="orn {wd}, {wn}, {wm}, asr #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010111 wm:5 0 amount:5 wn:5 wd:5" "asm"="orn {wd}, {wn}, {wm}, ror #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_32_log_shift.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00101010001 wm:5 000000 wn:5 wd:5" "asm"="orn {wd}, {wn}, {wm}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_32_log_shift.MVN.0(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010001 wm:5 0 amount:5 11111 wd:5" "asm"="mvn {wd}, {wm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_32_log_shift.MVN.1(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010011 wm:5 0 amount:5 11111 wd:5" "asm"="mvn {wd}, {wm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_32_log_shift.MVN.2(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010101 wm:5 0 amount:5 11111 wd:5" "asm"="mvn {wd}, {wm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_32_log_shift.MVN.3(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101010111 wm:5 0 amount:5 11111 wd:5" "asm"="mvn {wd}, {wm}, ror #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @EOR_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010000 wm:5 0 amount:5 wn:5 wd:5" "asm"="eor {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @EOR_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010010 wm:5 0 amount:5 wn:5 wd:5" "asm"="eor {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @EOR_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010100 wm:5 0 amount:5 wn:5 wd:5" "asm"="eor {wd}, {wn}, {wm}, asr #{amount}" "asmonly" {
  ret void
}

define void @EOR_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010110 wm:5 0 amount:5 wn:5 wd:5" "asm"="eor {wd}, {wn}, {wm}, ror #{amount}" "asmonly" {
  ret void
}

define void @EON_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010001 wm:5 0 amount:5 wn:5 wd:5" "asm"="eon {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @EON_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010011 wm:5 0 amount:5 wn:5 wd:5" "asm"="eon {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @EON_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010101 wm:5 0 amount:5 wn:5 wd:5" "asm"="eon {wd}, {wn}, {wm}, asr #{amount}" "asmonly" {
  ret void
}

define void @EON_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001010111 wm:5 0 amount:5 wn:5 wd:5" "asm"="eon {wd}, {wn}, {wm}, ror #{amount}" "asmonly" {
  ret void
}

define void @EON_32_log_shift.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01001010001 wm:5 000000 wn:5 wd:5" "asm"="eon {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @ANDS_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010000 wm:5 0 amount:5 wn:5 wd:5" "asm"="ands {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010010 wm:5 0 amount:5 wn:5 wd:5" "asm"="ands {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010100 wm:5 0 amount:5 wn:5 wd:5" "asm"="ands {wd}, {wn}, {wm}, asr #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010110 wm:5 0 amount:5 wn:5 wd:5" "asm"="ands {wd}, {wn}, {wm}, ror #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_32_log_shift.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01101010000 wm:5 000000 wn:5 wd:5" "asm"="ands {wd}, {wn}, {wm}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_32_log_shift.TST.0(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010000 wm:5 0 amount:5 wn:5 11111" "asm"="tst {wn}, {wm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_32_log_shift.TST.1(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010010 wm:5 0 amount:5 wn:5 11111" "asm"="tst {wn}, {wm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_32_log_shift.TST.2(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010100 wm:5 0 amount:5 wn:5 11111" "asm"="tst {wn}, {wm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_32_log_shift.TST.3(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010110 wm:5 0 amount:5 wn:5 11111" "asm"="tst {wn}, {wm}, ror #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @BICS_32_log_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010001 wm:5 0 amount:5 wn:5 wd:5" "asm"="bics {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @BICS_32_log_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010011 wm:5 0 amount:5 wn:5 wd:5" "asm"="bics {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @BICS_32_log_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010101 wm:5 0 amount:5 wn:5 wd:5" "asm"="bics {wd}, {wn}, {wm}, asr #{amount}" "asmonly" {
  ret void
}

define void @BICS_32_log_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101010111 wm:5 0 amount:5 wn:5 wd:5" "asm"="bics {wd}, {wn}, {wm}, ror #{amount}" "asmonly" {
  ret void
}

define void @BICS_32_log_shift.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01101010001 wm:5 000000 wn:5 wd:5" "asm"="bics {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @AND_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010000 xm:5 amount:6 xn:5 xd:5" "asm"="and {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @AND_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010010 xm:5 amount:6 xn:5 xd:5" "asm"="and {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @AND_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010100 xm:5 amount:6 xn:5 xd:5" "asm"="and {xd}, {xn}, {xm}, asr #{amount}" "asmonly" {
  ret void
}

define void @AND_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010110 xm:5 amount:6 xn:5 xd:5" "asm"="and {xd}, {xn}, {xm}, ror #{amount}" "asmonly" {
  ret void
}

define void @BIC_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010001 xm:5 amount:6 xn:5 xd:5" "asm"="bic {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @BIC_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010011 xm:5 amount:6 xn:5 xd:5" "asm"="bic {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @BIC_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010101 xm:5 amount:6 xn:5 xd:5" "asm"="bic {xd}, {xn}, {xm}, asr #{amount}" "asmonly" {
  ret void
}

define void @BIC_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10001010111 xm:5 amount:6 xn:5 xd:5" "asm"="bic {xd}, {xn}, {xm}, ror #{amount}" "asmonly" {
  ret void
}

define void @ORR_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010000 xm:5 amount:6 xn:5 xd:5" "asm"="orr {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010010 xm:5 amount:6 xn:5 xd:5" "asm"="orr {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010100 xm:5 amount:6 xn:5 xd:5" "asm"="orr {xd}, {xn}, {xm}, asr #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORR_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010110 xm:5 amount:6 xn:5 xd:5" "asm"="orr {xd}, {xn}, {xm}, ror #{amount}" "asmonly" "aliases"="mov" {
  ret void
}

define void @ORN_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010001 xm:5 amount:6 xn:5 xd:5" "asm"="orn {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010011 xm:5 amount:6 xn:5 xd:5" "asm"="orn {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010101 xm:5 amount:6 xn:5 xd:5" "asm"="orn {xd}, {xn}, {xm}, asr #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010111 xm:5 amount:6 xn:5 xd:5" "asm"="orn {xd}, {xn}, {xm}, ror #{amount}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_64_log_shift.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10101010001 xm:5 000000 xn:5 xd:5" "asm"="orn {xd}, {xn}, {xm}" "asmonly" "aliases"="mvn" {
  ret void
}

define void @ORN_64_log_shift.MVN.0(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010001 xm:5 amount:6 11111 xd:5" "asm"="mvn {xd}, {xm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_64_log_shift.MVN.1(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010011 xm:5 amount:6 11111 xd:5" "asm"="mvn {xd}, {xm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_64_log_shift.MVN.2(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010101 xm:5 amount:6 11111 xd:5" "asm"="mvn {xd}, {xm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ORN_64_log_shift.MVN.3(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101010111 xm:5 amount:6 11111 xd:5" "asm"="mvn {xd}, {xm}, ror #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @EOR_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010000 xm:5 amount:6 xn:5 xd:5" "asm"="eor {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @EOR_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010010 xm:5 amount:6 xn:5 xd:5" "asm"="eor {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @EOR_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010100 xm:5 amount:6 xn:5 xd:5" "asm"="eor {xd}, {xn}, {xm}, asr #{amount}" "asmonly" {
  ret void
}

define void @EOR_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010110 xm:5 amount:6 xn:5 xd:5" "asm"="eor {xd}, {xn}, {xm}, ror #{amount}" "asmonly" {
  ret void
}

define void @EON_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010001 xm:5 amount:6 xn:5 xd:5" "asm"="eon {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @EON_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010011 xm:5 amount:6 xn:5 xd:5" "asm"="eon {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @EON_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010101 xm:5 amount:6 xn:5 xd:5" "asm"="eon {xd}, {xn}, {xm}, asr #{amount}" "asmonly" {
  ret void
}

define void @EON_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11001010111 xm:5 amount:6 xn:5 xd:5" "asm"="eon {xd}, {xn}, {xm}, ror #{amount}" "asmonly" {
  ret void
}

define void @EON_64_log_shift.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11001010001 xm:5 000000 xn:5 xd:5" "asm"="eon {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @ANDS_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010000 xm:5 amount:6 xn:5 xd:5" "asm"="ands {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010010 xm:5 amount:6 xn:5 xd:5" "asm"="ands {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010100 xm:5 amount:6 xn:5 xd:5" "asm"="ands {xd}, {xn}, {xm}, asr #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010110 xm:5 amount:6 xn:5 xd:5" "asm"="ands {xd}, {xn}, {xm}, ror #{amount}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_64_log_shift.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11101010000 xm:5 000000 xn:5 xd:5" "asm"="ands {xd}, {xn}, {xm}" "asmonly" "aliases"="tst" {
  ret void
}

define void @ANDS_64_log_shift.TST.0(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010000 xm:5 amount:6 xn:5 11111" "asm"="tst {xn}, {xm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_64_log_shift.TST.1(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010010 xm:5 amount:6 xn:5 11111" "asm"="tst {xn}, {xm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_64_log_shift.TST.2(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010100 xm:5 amount:6 xn:5 11111" "asm"="tst {xn}, {xm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ANDS_64_log_shift.TST.3(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010110 xm:5 amount:6 xn:5 11111" "asm"="tst {xn}, {xm}, ror #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @BICS_64_log_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010001 xm:5 amount:6 xn:5 xd:5" "asm"="bics {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" {
  ret void
}

define void @BICS_64_log_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010011 xm:5 amount:6 xn:5 xd:5" "asm"="bics {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" {
  ret void
}

define void @BICS_64_log_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010101 xm:5 amount:6 xn:5 xd:5" "asm"="bics {xd}, {xn}, {xm}, asr #{amount}" "asmonly" {
  ret void
}

define void @BICS_64_log_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101010111 xm:5 amount:6 xn:5 xd:5" "asm"="bics {xd}, {xn}, {xm}, ror #{amount}" "asmonly" {
  ret void
}

define void @BICS_64_log_shift.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11101010001 xm:5 000000 xn:5 xd:5" "asm"="bics {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @ADDS_32_addsub_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011000 wm:5 0 amount:5 wn:5 wd:5" "asm"="adds {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32_addsub_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011010 wm:5 0 amount:5 wn:5 wd:5" "asm"="adds {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32_addsub_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011100 wm:5 0 amount:5 wn:5 wd:5" "asm"="adds {wd}, {wn}, {wm}, asr #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32_addsub_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00101011000 wm:5 000000 wn:5 wd:5" "asm"="adds {wd}, {wn}, {wm}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32_addsub_shift.CMN.0(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011000 wm:5 0 amount:5 wn:5 11111" "asm"="cmn {wn}, {wm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32_addsub_shift.CMN.1(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011010 wm:5 0 amount:5 wn:5 11111" "asm"="cmn {wn}, {wm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32_addsub_shift.CMN.2(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011100 wm:5 0 amount:5 wn:5 11111" "asm"="cmn {wn}, {wm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32_addsub_shift.CMN.3(i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00101011000 wm:5 000000 wn:5 11111" "asm"="cmn {wn}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011000 wm:5 0 amount:5 wn:5 wd:5" "asm"="subs {wd}, {wn}, {wm}, lsl #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_32_addsub_shift.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011010 wm:5 0 amount:5 wn:5 wd:5" "asm"="subs {wd}, {wn}, {wm}, lsr #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_32_addsub_shift.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011100 wm:5 0 amount:5 wn:5 wd:5" "asm"="subs {wd}, {wn}, {wm}, asr #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_32_addsub_shift.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01101011000 wm:5 000000 wn:5 wd:5" "asm"="subs {wd}, {wn}, {wm}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_32_addsub_shift.NEGS.0(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011000 wm:5 0 amount:5 11111 wd:5" "asm"="negs {wd}, {wm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.NEGS.1(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011010 wm:5 0 amount:5 11111 wd:5" "asm"="negs {wd}, {wm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.NEGS.2(i64 "reg"="w" %wd, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011100 wm:5 0 amount:5 11111 wd:5" "asm"="negs {wd}, {wm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.NEGS.3(i64 "reg"="w" %wd, i64 "reg"="w" %wm) "enc"="01101011000 wm:5 00000011111 wd:5" "asm"="negs {wd}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.CMP.0(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011000 wm:5 0 amount:5 wn:5 11111" "asm"="cmp {wn}, {wm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.CMP.1(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011010 wm:5 0 amount:5 wn:5 11111" "asm"="cmp {wn}, {wm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32_addsub_shift.CMP.2(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011100 wm:5 0 amount:5 wn:5 11111" "asm"="cmp {wn}, {wm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_64_addsub_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011000 xm:5 amount:6 xn:5 xd:5" "asm"="adds {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64_addsub_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011010 xm:5 amount:6 xn:5 xd:5" "asm"="adds {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64_addsub_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011100 xm:5 amount:6 xn:5 xd:5" "asm"="adds {xd}, {xn}, {xm}, asr #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64_addsub_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10101011000 xm:5 000000 xn:5 xd:5" "asm"="adds {xd}, {xn}, {xm}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_64_addsub_shift.CMN.0(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011000 xm:5 amount:6 xn:5 11111" "asm"="cmn {xn}, {xm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_64_addsub_shift.CMN.1(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011010 xm:5 amount:6 xn:5 11111" "asm"="cmn {xn}, {xm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_64_addsub_shift.CMN.2(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="10101011100 xm:5 amount:6 xn:5 11111" "asm"="cmn {xn}, {xm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_64_addsub_shift.CMN.3(i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10101011000 xm:5 000000 xn:5 11111" "asm"="cmn {xn}, {xm}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011000 xm:5 amount:6 xn:5 xd:5" "asm"="subs {xd}, {xn}, {xm}, lsl #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_64_addsub_shift.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011010 xm:5 amount:6 xn:5 xd:5" "asm"="subs {xd}, {xn}, {xm}, lsr #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_64_addsub_shift.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011100 xm:5 amount:6 xn:5 xd:5" "asm"="subs {xd}, {xn}, {xm}, asr #{amount}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_64_addsub_shift.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11101011000 xm:5 000000 xn:5 xd:5" "asm"="subs {xd}, {xn}, {xm}" "asmonly" "aliases"="cmp,negs" {
  ret void
}

define void @SUBS_64_addsub_shift.NEGS.0(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011000 xm:5 amount:6 11111 xd:5" "asm"="negs {xd}, {xm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.NEGS.1(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011010 xm:5 amount:6 11111 xd:5" "asm"="negs {xd}, {xm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.NEGS.2(i64 "reg"="x" %xd, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011100 xm:5 amount:6 11111 xd:5" "asm"="negs {xd}, {xm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.NEGS.3(i64 "reg"="x" %xd, i64 "reg"="x" %xm) "enc"="11101011000 xm:5 00000011111 xd:5" "asm"="negs {xd}, {xm}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.CMP.0(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011000 xm:5 amount:6 xn:5 11111" "asm"="cmp {xn}, {xm}, lsl #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.CMP.1(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011010 xm:5 amount:6 xn:5 11111" "asm"="cmp {xn}, {xm}, lsr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_64_addsub_shift.CMP.2(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %amount) "enc"="11101011100 xm:5 amount:6 xn:5 11111" "asm"="cmp {xn}, {xm}, asr #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADD_32_addsub_ext.0(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 000 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.1(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 000000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtb" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.2(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 001 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxth #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.3(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 001000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxth" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.4(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 010 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.5(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 010000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtw" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.6(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 011 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.7(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 011000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, uxtx" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.8(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 100 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.9(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 100000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtb" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.10(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 101 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxth #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.11(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 101000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxth" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.12(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 110 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.13(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 110000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtw" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.14(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00001011001 wm:5 111 amount:3 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" {
  ret void
}

define void @ADD_32_addsub_ext.15(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00001011001 wm:5 111000 wn_wsp:5 wd_wsp:5" "asm"="add {wd_wsp}, {wn_wsp}, {wm}, sxtx" "asmonly" {
  ret void
}

define void @ADDS_32S_addsub_ext.0(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 000 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.1(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 000000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtb" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.2(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 001 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxth #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.3(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 001000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxth" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.4(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 010 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.5(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 010000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtw" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.6(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 011 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.7(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 011000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, uxtx" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.8(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 100 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.9(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 100000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtb" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.10(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 101 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxth #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.11(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 101000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxth" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.12(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 110 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.13(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 110000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtw" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.14(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 111 amount:3 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.15(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 111000 wn_wsp:5 wd:5" "asm"="adds {wd}, {wn_wsp}, {wm}, sxtx" "asmonly" "aliases"="cmn" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.0(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 000 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.1(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 000000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtb" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.2(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 001 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxth #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.3(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 001000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxth" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.4(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 010 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.5(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 010000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtw" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.6(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 011 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.7(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 011000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, uxtx" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.8(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 100 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.9(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 100000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtb" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.10(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 101 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxth #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.11(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 101000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxth" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.12(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 110 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.13(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 110000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtw" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.14(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="00101011001 wm:5 111 amount:3 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @ADDS_32S_addsub_ext.CMN.15(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="00101011001 wm:5 111000 wn_wsp:5 11111" "asm"="cmn {wn_wsp}, {wm}, sxtx" "asmonly" "nodecode" {
  ret void
}

define void @SUB_32_addsub_ext.0(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 000 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.1(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 000000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtb" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.2(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 001 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxth #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.3(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 001000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxth" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.4(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 010 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.5(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 010000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtw" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.6(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 011 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.7(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 011000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, uxtx" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.8(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 100 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.9(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 100000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtb" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.10(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 101 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxth #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.11(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 101000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxth" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.12(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 110 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.13(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 110000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtw" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.14(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01001011001 wm:5 111 amount:3 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" {
  ret void
}

define void @SUB_32_addsub_ext.15(i64 "reg"="wsp" %wd_wsp, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01001011001 wm:5 111000 wn_wsp:5 wd_wsp:5" "asm"="sub {wd_wsp}, {wn_wsp}, {wm}, sxtx" "asmonly" {
  ret void
}

define void @SUBS_32S_addsub_ext.0(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 000 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.1(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 000000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtb" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.2(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 001 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxth #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.3(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 001000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxth" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.4(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 010 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.5(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 010000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtw" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.6(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 011 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.7(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 011000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, uxtx" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.8(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 100 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.9(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 100000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtb" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.10(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 101 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxth #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.11(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 101000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxth" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.12(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 110 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.13(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 110000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtw" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.14(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 111 amount:3 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.15(i64 "reg"="w" %wd, i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 111000 wn_wsp:5 wd:5" "asm"="subs {wd}, {wn_wsp}, {wm}, sxtx" "asmonly" "aliases"="cmp" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.0(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 000 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtb #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.1(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 000000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtb" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.2(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 001 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxth #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.3(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 001000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxth" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.4(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 010 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtw #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.5(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 010000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtw" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.6(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 011 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtx #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.7(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 011000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, uxtx" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.8(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 100 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtb #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.9(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 100000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtb" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.10(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 101 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxth #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.11(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 101000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxth" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.12(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 110 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtw #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.13(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 110000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtw" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.14(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm, i64 "imm" %amount) "enc"="01101011001 wm:5 111 amount:3 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtx #{amount}" "asmonly" "nodecode" {
  ret void
}

define void @SUBS_32S_addsub_ext.CMP.15(i64 "reg"="wsp" %wn_wsp, i64 "reg"="w" %wm) "enc"="01101011001 wm:5 111000 wn_wsp:5 11111" "asm"="cmp {wn_wsp}, {wm}, sxtx" "asmonly" "nodecode" {
  ret void
}

define void @ADC_32_addsub_carry.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010000 wm:5 000000 wn:5 wd:5" "asm"="adc {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @ADCS_32_addsub_carry.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00111010000 wm:5 000000 wn:5 wd:5" "asm"="adcs {wd}, {wn}, {wm}" "asmonly" {
  ret void
}

define void @SBC_32_addsub_carry.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010000 wm:5 000000 wn:5 wd:5" "asm"="sbc {wd}, {wn}, {wm}" "asmonly" "aliases"="ngc" {
  ret void
}

define void @SBC_32_addsub_carry.NGC.0(i64 "reg"="w" %wd, i64 "reg"="w" %wm) "enc"="01011010000 wm:5 00000011111 wd:5" "asm"="ngc {wd}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @SBCS_32_addsub_carry.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01111010000 wm:5 000000 wn:5 wd:5" "asm"="sbcs {wd}, {wn}, {wm}" "asmonly" "aliases"="ngcs" {
  ret void
}

define void @SBCS_32_addsub_carry.NGCS.0(i64 "reg"="w" %wd, i64 "reg"="w" %wm) "enc"="01111010000 wm:5 00000011111 wd:5" "asm"="ngcs {wd}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @ADC_64_addsub_carry.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010000 xm:5 000000 xn:5 xd:5" "asm"="adc {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @ADCS_64_addsub_carry.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10111010000 xm:5 000000 xn:5 xd:5" "asm"="adcs {xd}, {xn}, {xm}" "asmonly" {
  ret void
}

define void @SBC_64_addsub_carry.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010000 xm:5 000000 xn:5 xd:5" "asm"="sbc {xd}, {xn}, {xm}" "asmonly" "aliases"="ngc" {
  ret void
}

define void @SBC_64_addsub_carry.NGC.0(i64 "reg"="x" %xd, i64 "reg"="x" %xm) "enc"="11011010000 xm:5 00000011111 xd:5" "asm"="ngc {xd}, {xm}" "asmonly" "nodecode" {
  ret void
}

define void @SBCS_64_addsub_carry.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11111010000 xm:5 000000 xn:5 xd:5" "asm"="sbcs {xd}, {xn}, {xm}" "asmonly" "aliases"="ngcs" {
  ret void
}

define void @SBCS_64_addsub_carry.NGCS.0(i64 "reg"="x" %xd, i64 "reg"="x" %xm) "enc"="11111010000 xm:5 00000011111 xd:5" "asm"="ngcs {xd}, {xm}" "asmonly" "nodecode" {
  ret void
}

define void @RMIF_only_rmif.0(i64 "reg"="x" %xn, i64 "imm" %shift, i64 "imm" %mask) "enc"="10111010000 shift:6 00001 xn:5 0 mask:4" "asm"="rmif {xn}, #{shift}, #{mask}" "asmonly" {
  ret void
}

define void @SETF8_only_setf.0(i64 "reg"="w" %wn) "enc"="0011101000000000000010 wn:5 01101" "asm"="setf8 {wn}" "asmonly" {
  ret void
}

define void @SETF16_only_setf.0(i64 "reg"="w" %wn) "enc"="0011101000000000010010 wn:5 01101" "asm"="setf16 {wn}" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.0(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 000000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.1(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 000100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.2(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 001000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.3(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 001000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_32_condcmp_reg.4(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 001100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.5(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 001100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_32_condcmp_reg.6(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 010000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.7(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 010100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.8(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 011000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.9(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 011100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.10(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 100000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.11(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 100100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.12(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 101000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.13(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 101100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.14(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 110000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.15(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 110100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.16(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 111000 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_reg.17(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="00111010010 wm:5 111100 wn:5 0 nzcv:4" "asm"="ccmn {wn}, {wm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.0(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 000000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.1(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 000100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.2(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 001000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.3(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 001000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_32_condcmp_reg.4(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 001100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.5(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 001100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_32_condcmp_reg.6(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 010000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.7(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 010100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.8(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 011000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.9(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 011100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.10(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 100000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.11(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 100100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.12(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 101000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.13(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 101100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.14(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 110000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.15(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 110100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.16(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 111000 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_reg.17(i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "imm" %nzcv) "enc"="01111010010 wm:5 111100 wn:5 0 nzcv:4" "asm"="ccmp {wn}, {wm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.0(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 000000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.1(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 000100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.2(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 001000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.3(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 001000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_64_condcmp_reg.4(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 001100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.5(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 001100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_64_condcmp_reg.6(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 010000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.7(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 010100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.8(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 011000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.9(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 011100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.10(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 100000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.11(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 100100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.12(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 101000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.13(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 101100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.14(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 110000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.15(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 110100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.16(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 111000 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_reg.17(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="10111010010 xm:5 111100 xn:5 0 nzcv:4" "asm"="ccmn {xn}, {xm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.0(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 000000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.1(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 000100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.2(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 001000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.3(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 001000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_64_condcmp_reg.4(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 001100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.5(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 001100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_64_condcmp_reg.6(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 010000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.7(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 010100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.8(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 011000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.9(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 011100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.10(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 100000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.11(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 100100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.12(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 101000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.13(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 101100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.14(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 110000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.15(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 110100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.16(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 111000 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_reg.17(i64 "reg"="x" %xn, i64 "reg"="x" %xm, i64 "imm" %nzcv) "enc"="11111010010 xm:5 111100 xn:5 0 nzcv:4" "asm"="ccmp {xn}, {xm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.0(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 000010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.1(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 000110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.2(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 001010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.3(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 001010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_32_condcmp_imm.4(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 001110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.5(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 001110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_32_condcmp_imm.6(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 010010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.7(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 010110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.8(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 011010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.9(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 011110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.10(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 100010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.11(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 100110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.12(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 101010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.13(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 101110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.14(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 110010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.15(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 110110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.16(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 111010 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMN_32_condcmp_imm.17(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="00111010010 imm:5 111110 wn:5 0 nzcv:4" "asm"="ccmn {wn}, #{imm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.0(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 000010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.1(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 000110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.2(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 001010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.3(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 001010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_32_condcmp_imm.4(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 001110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.5(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 001110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_32_condcmp_imm.6(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 010010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.7(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 010110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.8(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 011010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.9(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 011110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.10(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 100010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.11(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 100110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.12(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 101010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.13(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 101110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.14(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 110010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.15(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 110110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.16(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 111010 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMP_32_condcmp_imm.17(i64 "reg"="w" %wn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="01111010010 imm:5 111110 wn:5 0 nzcv:4" "asm"="ccmp {wn}, #{imm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.0(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 000010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.1(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 000110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.2(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 001010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.3(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 001010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_64_condcmp_imm.4(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 001110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.5(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 001110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMN_64_condcmp_imm.6(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 010010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.7(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 010110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.8(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 011010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.9(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 011110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.10(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 100010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.11(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 100110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.12(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 101010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.13(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 101110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.14(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 110010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.15(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 110110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.16(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 111010 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMN_64_condcmp_imm.17(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="10111010010 imm:5 111110 xn:5 0 nzcv:4" "asm"="ccmn {xn}, #{imm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.0(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 000010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.1(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 000110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.2(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 001010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.3(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 001010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_64_condcmp_imm.4(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 001110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.5(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 001110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CCMP_64_condcmp_imm.6(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 010010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.7(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 010110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.8(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 011010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.9(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 011110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.10(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 100010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.11(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 100110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.12(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 101010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.13(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 101110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.14(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 110010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.15(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 110110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.16(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 111010 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @CCMP_64_condcmp_imm.17(i64 "reg"="x" %xn, i64 "imm" %imm, i64 "imm" %nzcv) "enc"="11111010010 imm:5 111110 xn:5 0 nzcv:4" "asm"="ccmp {xn}, #{imm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @CSINC_32_condsel.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 000001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, eq" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 000101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, ne" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 001001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, cs" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 001001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, hs" "asmonly" "nodecode" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 001101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, cc" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 001101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, lo" "asmonly" "nodecode" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 010001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, mi" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 010101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, pl" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 011001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, vs" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 011101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, vc" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 100001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, hi" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 100101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, ls" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 101001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, ge" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 101101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, lt" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 110001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, gt" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 110101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, le" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.16(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 111001 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, al" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.17(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="00011010100 wm:5 111101 wn:5 wd:5" "asm"="csinc {wd}, {wn}, {wm}, nv" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_32_condsel.CINC.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 000101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 000001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 001101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 001101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 001001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 001001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 010101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 010001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 011101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 011001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 100101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 100001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 101101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 101001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 110101 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_32_condsel.CINC.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="00011010100 rm_f:5=wn 110001 rn_f:5=wn wd:5" "asm"="cinc {wd}, {wn}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 000000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, eq" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 000100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, ne" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, cs" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, hs" "asmonly" "nodecode" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, cc" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, lo" "asmonly" "nodecode" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 010000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, mi" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 010100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, pl" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 011000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, vs" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 011100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, vc" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 100000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, hi" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 100100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, ls" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 101000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, ge" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 101100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, lt" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 110000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, gt" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 110100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, le" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.16(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 111000 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, al" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.17(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 111100 wn:5 wd:5" "asm"="csinv {wd}, {wn}, {wm}, nv" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_32_condsel.CSETM.0(i64 "reg"="w" %wd) "enc"="010110101001111100010011111 wd:5" "asm"="csetm {wd}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.1(i64 "reg"="w" %wd) "enc"="010110101001111100000011111 wd:5" "asm"="csetm {wd}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.2(i64 "reg"="w" %wd) "enc"="010110101001111100110011111 wd:5" "asm"="csetm {wd}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.3(i64 "reg"="w" %wd) "enc"="010110101001111100110011111 wd:5" "asm"="csetm {wd}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.4(i64 "reg"="w" %wd) "enc"="010110101001111100100011111 wd:5" "asm"="csetm {wd}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.5(i64 "reg"="w" %wd) "enc"="010110101001111100100011111 wd:5" "asm"="csetm {wd}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.6(i64 "reg"="w" %wd) "enc"="010110101001111101010011111 wd:5" "asm"="csetm {wd}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.7(i64 "reg"="w" %wd) "enc"="010110101001111101000011111 wd:5" "asm"="csetm {wd}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.8(i64 "reg"="w" %wd) "enc"="010110101001111101110011111 wd:5" "asm"="csetm {wd}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.9(i64 "reg"="w" %wd) "enc"="010110101001111101100011111 wd:5" "asm"="csetm {wd}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.10(i64 "reg"="w" %wd) "enc"="010110101001111110010011111 wd:5" "asm"="csetm {wd}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.11(i64 "reg"="w" %wd) "enc"="010110101001111110000011111 wd:5" "asm"="csetm {wd}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.12(i64 "reg"="w" %wd) "enc"="010110101001111110110011111 wd:5" "asm"="csetm {wd}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.13(i64 "reg"="w" %wd) "enc"="010110101001111110100011111 wd:5" "asm"="csetm {wd}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.14(i64 "reg"="w" %wd) "enc"="010110101001111111010011111 wd:5" "asm"="csetm {wd}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CSETM.15(i64 "reg"="w" %wd) "enc"="010110101001111111000011111 wd:5" "asm"="csetm {wd}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 000100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 000000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 010100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 010000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 011100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 011000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 100100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 100000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 101100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 101000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 110100 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_32_condsel.CINV.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 110000 rn_f:5=wn wd:5" "asm"="cinv {wd}, {wn}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 000001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, eq" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 000101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, ne" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, cs" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, hs" "asmonly" "nodecode" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, cc" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 001101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, lo" "asmonly" "nodecode" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 010001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, mi" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 010101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, pl" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 011001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, vs" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 011101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, vc" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 100001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, hi" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 100101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, ls" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 101001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, ge" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 101101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, lt" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 110001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, gt" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 110101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, le" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.16(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 111001 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, al" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.17(i64 "reg"="w" %wd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="01011010100 wm:5 111101 wn:5 wd:5" "asm"="csneg {wd}, {wn}, {wm}, nv" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.0(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 000101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.1(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 000001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.2(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.3(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.4(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.5(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 001001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.6(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 010101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.7(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 010001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.8(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 011101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.9(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 011001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.10(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 100101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.11(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 100001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.12(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 101101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.13(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 101001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.14(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 110101 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_32_condsel.CNEG.15(i64 "reg"="w" %wd, i64 "reg"="w" %wn) "enc"="01011010100 rm_f:5=wn 110001 rn_f:5=wn wd:5" "asm"="cneg {wd}, {wn}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 000001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, eq" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 000101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, ne" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 001001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, cs" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 001001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, hs" "asmonly" "nodecode" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 001101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, cc" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 001101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, lo" "asmonly" "nodecode" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 010001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, mi" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 010101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, pl" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 011001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, vs" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 011101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, vc" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 100001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, hi" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 100101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, ls" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 101001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, ge" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 101101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, lt" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 110001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, gt" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 110101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, le" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.16(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 111001 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, al" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.17(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="10011010100 xm:5 111101 xn:5 xd:5" "asm"="csinc {xd}, {xn}, {xm}, nv" "asmonly" "aliases"="cinc,cset" {
  ret void
}

define void @CSINC_64_condsel.CSET.0(i64 "reg"="x" %xd) "enc"="100110101001111100010111111 xd:5" "asm"="cset {xd}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.1(i64 "reg"="x" %xd) "enc"="100110101001111100000111111 xd:5" "asm"="cset {xd}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.2(i64 "reg"="x" %xd) "enc"="100110101001111100110111111 xd:5" "asm"="cset {xd}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.3(i64 "reg"="x" %xd) "enc"="100110101001111100110111111 xd:5" "asm"="cset {xd}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.4(i64 "reg"="x" %xd) "enc"="100110101001111100100111111 xd:5" "asm"="cset {xd}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.5(i64 "reg"="x" %xd) "enc"="100110101001111100100111111 xd:5" "asm"="cset {xd}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.6(i64 "reg"="x" %xd) "enc"="100110101001111101010111111 xd:5" "asm"="cset {xd}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.7(i64 "reg"="x" %xd) "enc"="100110101001111101000111111 xd:5" "asm"="cset {xd}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.8(i64 "reg"="x" %xd) "enc"="100110101001111101110111111 xd:5" "asm"="cset {xd}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.9(i64 "reg"="x" %xd) "enc"="100110101001111101100111111 xd:5" "asm"="cset {xd}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.10(i64 "reg"="x" %xd) "enc"="100110101001111110010111111 xd:5" "asm"="cset {xd}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.11(i64 "reg"="x" %xd) "enc"="100110101001111110000111111 xd:5" "asm"="cset {xd}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.12(i64 "reg"="x" %xd) "enc"="100110101001111110110111111 xd:5" "asm"="cset {xd}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.13(i64 "reg"="x" %xd) "enc"="100110101001111110100111111 xd:5" "asm"="cset {xd}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.14(i64 "reg"="x" %xd) "enc"="100110101001111111010111111 xd:5" "asm"="cset {xd}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CSET.15(i64 "reg"="x" %xd) "enc"="100110101001111111000111111 xd:5" "asm"="cset {xd}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 000101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 000001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 001101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 001101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 001001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 001001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 010101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 010001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 011101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 011001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 100101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 100001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 101101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 101001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 110101 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINC_64_condsel.CINC.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="10011010100 rm_f:5=xn 110001 rn_f:5=xn xd:5" "asm"="cinc {xd}, {xn}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 000000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, eq" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 000100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, ne" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, cs" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, hs" "asmonly" "nodecode" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, cc" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, lo" "asmonly" "nodecode" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 010000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, mi" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 010100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, pl" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 011000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, vs" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 011100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, vc" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 100000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, hi" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 100100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, ls" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 101000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, ge" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 101100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, lt" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 110000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, gt" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 110100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, le" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.16(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 111000 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, al" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.17(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 111100 xn:5 xd:5" "asm"="csinv {xd}, {xn}, {xm}, nv" "asmonly" "aliases"="cinv,csetm" {
  ret void
}

define void @CSINV_64_condsel.CSETM.0(i64 "reg"="x" %xd) "enc"="110110101001111100010011111 xd:5" "asm"="csetm {xd}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.1(i64 "reg"="x" %xd) "enc"="110110101001111100000011111 xd:5" "asm"="csetm {xd}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.2(i64 "reg"="x" %xd) "enc"="110110101001111100110011111 xd:5" "asm"="csetm {xd}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.3(i64 "reg"="x" %xd) "enc"="110110101001111100110011111 xd:5" "asm"="csetm {xd}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.4(i64 "reg"="x" %xd) "enc"="110110101001111100100011111 xd:5" "asm"="csetm {xd}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.5(i64 "reg"="x" %xd) "enc"="110110101001111100100011111 xd:5" "asm"="csetm {xd}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.6(i64 "reg"="x" %xd) "enc"="110110101001111101010011111 xd:5" "asm"="csetm {xd}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.7(i64 "reg"="x" %xd) "enc"="110110101001111101000011111 xd:5" "asm"="csetm {xd}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.8(i64 "reg"="x" %xd) "enc"="110110101001111101110011111 xd:5" "asm"="csetm {xd}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.9(i64 "reg"="x" %xd) "enc"="110110101001111101100011111 xd:5" "asm"="csetm {xd}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.10(i64 "reg"="x" %xd) "enc"="110110101001111110010011111 xd:5" "asm"="csetm {xd}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.11(i64 "reg"="x" %xd) "enc"="110110101001111110000011111 xd:5" "asm"="csetm {xd}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.12(i64 "reg"="x" %xd) "enc"="110110101001111110110011111 xd:5" "asm"="csetm {xd}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.13(i64 "reg"="x" %xd) "enc"="110110101001111110100011111 xd:5" "asm"="csetm {xd}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.14(i64 "reg"="x" %xd) "enc"="110110101001111111010011111 xd:5" "asm"="csetm {xd}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CSETM.15(i64 "reg"="x" %xd) "enc"="110110101001111111000011111 xd:5" "asm"="csetm {xd}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 000100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 000000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 010100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 010000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 011100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 011000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 100100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 100000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 101100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 101000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 110100 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSINV_64_condsel.CINV.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 110000 rn_f:5=xn xd:5" "asm"="cinv {xd}, {xn}, le" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 000001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, eq" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 000101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, ne" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, cs" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, hs" "asmonly" "nodecode" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, cc" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 001101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, lo" "asmonly" "nodecode" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 010001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, mi" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 010101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, pl" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 011001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, vs" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 011101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, vc" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 100001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, hi" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 100101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, ls" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 101001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, ge" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 101101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, lt" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 110001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, gt" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 110101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, le" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.16(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 111001 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, al" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.17(i64 "reg"="x" %xd, i64 "reg"="x" %xn, i64 "reg"="x" %xm) "enc"="11011010100 xm:5 111101 xn:5 xd:5" "asm"="csneg {xd}, {xn}, {xm}, nv" "asmonly" "aliases"="cneg" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.0(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 000101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, eq" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.1(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 000001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, ne" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.2(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, cs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.3(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, hs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.4(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, cc" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.5(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 001001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, lo" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.6(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 010101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, mi" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.7(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 010001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, pl" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.8(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 011101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, vs" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.9(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 011001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, vc" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.10(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 100101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, hi" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.11(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 100001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, ls" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.12(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 101101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, ge" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.13(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 101001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, lt" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.14(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 110101 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, gt" "asmonly" "nodecode" {
  ret void
}

define void @CSNEG_64_condsel.CNEG.15(i64 "reg"="x" %xd, i64 "reg"="x" %xn) "enc"="11011010100 rm_f:5=xn 110001 rn_f:5=xn xd:5" "asm"="cneg {xd}, {xn}, le" "asmonly" "nodecode" {
  ret void
}

define void @SMADDL_64WA_dp_3src.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "reg"="x" %xa) "enc"="10011011001 wm:5 0 xa:5 wn:5 xd:5" "asm"="smaddl {xd}, {wn}, {wm}, {xa}" "asmonly" "aliases"="smull" {
  ret void
}

define void @SMSUBL_64WA_dp_3src.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "reg"="x" %xa) "enc"="10011011001 wm:5 1 xa:5 wn:5 xd:5" "asm"="smsubl {xd}, {wn}, {wm}, {xa}" "asmonly" "aliases"="smnegl" {
  ret void
}

define void @SMSUBL_64WA_dp_3src.SMNEGL.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="10011011001 wm:5 111111 wn:5 xd:5" "asm"="smnegl {xd}, {wn}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @UMADDL_64WA_dp_3src.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "reg"="x" %xa) "enc"="10011011101 wm:5 0 xa:5 wn:5 xd:5" "asm"="umaddl {xd}, {wn}, {wm}, {xa}" "asmonly" "aliases"="umull" {
  ret void
}

define void @UMSUBL_64WA_dp_3src.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm, i64 "reg"="x" %xa) "enc"="10011011101 wm:5 1 xa:5 wn:5 xd:5" "asm"="umsubl {xd}, {wn}, {wm}, {xa}" "asmonly" "aliases"="umnegl" {
  ret void
}

define void @UMSUBL_64WA_dp_3src.UMNEGL.0(i64 "reg"="x" %xd, i64 "reg"="w" %wn, i64 "reg"="w" %wm) "enc"="10011011101 wm:5 111111 wn:5 xd:5" "asm"="umnegl {xd}, {wn}, {wm}" "asmonly" "nodecode" {
  ret void
}

define void @AESE_B_cryptoaes.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000101000010010 vn:5 vd:5" "asm"="aese {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @AESD_B_cryptoaes.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000101000010110 vn:5 vd:5" "asm"="aesd {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @AESMC_B_cryptoaes.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000101000011010 vn:5 vd:5" "asm"="aesmc {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @AESIMC_B_cryptoaes.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000101000011110 vn:5 vd:5" "asm"="aesimc {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SHA1C_QSV_cryptosha3.0(i64 "reg"="q" %qd, i64 "reg"="s" %sn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 000000 sn:5 qd:5" "asm"="sha1c {qd}, {sn}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA1P_QSV_cryptosha3.0(i64 "reg"="q" %qd, i64 "reg"="s" %sn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 000100 sn:5 qd:5" "asm"="sha1p {qd}, {sn}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA1M_QSV_cryptosha3.0(i64 "reg"="q" %qd, i64 "reg"="s" %sn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 001000 sn:5 qd:5" "asm"="sha1m {qd}, {sn}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA1SU0_VVV_cryptosha3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 001100 vn:5 vd:5" "asm"="sha1su0 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA256H_QQV_cryptosha3.0(i64 "reg"="q" %qd, i64 "reg"="q" %qn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 010000 qn:5 qd:5" "asm"="sha256h {qd}, {qn}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA256H2_QQV_cryptosha3.0(i64 "reg"="q" %qd, i64 "reg"="q" %qn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 010100 qn:5 qd:5" "asm"="sha256h2 {qd}, {qn}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA256SU1_VVV_cryptosha3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01011110000 vm:5 011000 vn:5 vd:5" "asm"="sha256su1 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHA1H_SS_cryptosha2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0101111000101000000010 sn:5 sd:5" "asm"="sha1h {sd}, {sn}" "asmonly" {
  ret void
}

define void @SHA1SU1_VV_cryptosha2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0101111000101000000110 vn:5 vd:5" "asm"="sha1su1 {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @SHA256SU0_VV_cryptosha2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0101111000101000001010 vn:5 vd:5" "asm"="sha256su0 {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FMULX_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01011110010 hm:5 000111 hn:5 hd:5" "asm"="fmulx {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCMEQ_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01011110010 hm:5 001001 hn:5 hd:5" "asm"="fcmeq {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FRECPS_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01011110010 hm:5 001111 hn:5 hd:5" "asm"="frecps {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FRSQRTS_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01011110110 hm:5 001111 hn:5 hd:5" "asm"="frsqrts {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCMGE_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01111110010 hm:5 001001 hn:5 hd:5" "asm"="fcmge {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FACGE_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01111110010 hm:5 001011 hn:5 hd:5" "asm"="facge {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FABD_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01111110110 hm:5 000101 hn:5 hd:5" "asm"="fabd {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCMGT_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01111110110 hm:5 001001 hn:5 hd:5" "asm"="fcmgt {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FACGT_asisdsamefp16_only.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="01111110110 hm:5 001011 hn:5 hd:5" "asm"="facgt {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCVTNS_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111001111001101010 hn:5 hd:5" "asm"="fcvtns {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMS_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111001111001101110 hn:5 hd:5" "asm"="fcvtms {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAS_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111001111001110010 hn:5 hd:5" "asm"="fcvtas {hd}, {hn}" "asmonly" {
  ret void
}

define void @SCVTF_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111001111001110110 hn:5 hd:5" "asm"="scvtf {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCMGT_asisdmiscfp16_FZ.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111000110010 hn:5 hd:5" "asm"="fcmgt {hd}, {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asisdmiscfp16_FZ.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111000110110 hn:5 hd:5" "asm"="fcmeq {hd}, {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asisdmiscfp16_FZ.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111000111010 hn:5 hd:5" "asm"="fcmlt {hd}, {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCVTPS_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111001101010 hn:5 hd:5" "asm"="fcvtps {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZS_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111001101110 hn:5 hd:5" "asm"="fcvtzs {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRECPE_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111001110110 hn:5 hd:5" "asm"="frecpe {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRECPX_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0101111011111001111110 hn:5 hd:5" "asm"="frecpx {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTNU_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111001111001101010 hn:5 hd:5" "asm"="fcvtnu {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMU_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111001111001101110 hn:5 hd:5" "asm"="fcvtmu {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAU_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111001111001110010 hn:5 hd:5" "asm"="fcvtau {hd}, {hn}" "asmonly" {
  ret void
}

define void @UCVTF_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111001111001110110 hn:5 hd:5" "asm"="ucvtf {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCMGE_asisdmiscfp16_FZ.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111011111000110010 hn:5 hd:5" "asm"="fcmge {hd}, {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asisdmiscfp16_FZ.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111011111000110110 hn:5 hd:5" "asm"="fcmle {hd}, {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCVTPU_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111011111001101010 hn:5 hd:5" "asm"="fcvtpu {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZU_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111011111001101110 hn:5 hd:5" "asm"="fcvtzu {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRSQRTE_asisdmiscfp16_R.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0111111011111001110110 hn:5 hd:5" "asm"="frsqrte {hd}, {hn}" "asmonly" {
  ret void
}

define void @SQRDMLAH_asisdsame2_only.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01111110010 m:5 100001 n:5 d:5" "asm"="sqrdmlah {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQRDMLSH_asisdsame2_only.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01111110010 m:5 100011 n:5 d:5" "asm"="sqrdmlsh {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SUQADD_asisdmisc_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n) "enc"="0101111000100000001110 n:5 d:5" "asm"="suqadd {d}, {n}" "asmonly" {
  ret void
}

define void @SQABS_asisdmisc_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n) "enc"="0101111000100000011110 n:5 d:5" "asm"="sqabs {d}, {n}" "asmonly" {
  ret void
}

define void @CMGT_asisdmisc_Z.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0101111011100000100010 n:5 d:5" "asm"="cmgt {d}, {n}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asisdmisc_Z.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0101111011100000100110 n:5 d:5" "asm"="cmeq {d}, {n}, #0" "asmonly" {
  ret void
}

define void @CMLT_asisdmisc_Z.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0101111011100000101010 n:5 d:5" "asm"="cmlt {d}, {n}, #0" "asmonly" {
  ret void
}

define void @ABS_asisdmisc_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0101111011100000101110 n:5 d:5" "asm"="abs {d}, {n}" "asmonly" {
  ret void
}

define void @SQXTN_asisdmisc_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n) "enc"="0101111000100001010010 n:5 d:5" "asm"="sqxtn {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTNS_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111000100001101010 n:5 d:5" "asm"="fcvtns {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTMS_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111000100001101110 n:5 d:5" "asm"="fcvtms {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTAS_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111000100001110010 n:5 d:5" "asm"="fcvtas {d}, {n}" "asmonly" {
  ret void
}

define void @SCVTF_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111000100001110110 n:5 d:5" "asm"="scvtf {d}, {n}" "asmonly" {
  ret void
}

define void @FCMGT_asisdmisc_FZ.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100000110010 n:5 d:5" "asm"="fcmgt {d}, {n}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asisdmisc_FZ.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100000110110 n:5 d:5" "asm"="fcmeq {d}, {n}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asisdmisc_FZ.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100000111010 n:5 d:5" "asm"="fcmlt {d}, {n}, #0.0" "asmonly" {
  ret void
}

define void @FCVTPS_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100001101010 n:5 d:5" "asm"="fcvtps {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTZS_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100001101110 n:5 d:5" "asm"="fcvtzs {d}, {n}" "asmonly" {
  ret void
}

define void @FRECPE_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100001110110 n:5 d:5" "asm"="frecpe {d}, {n}" "asmonly" {
  ret void
}

define void @FRECPX_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0101111010100001111110 n:5 d:5" "asm"="frecpx {d}, {n}" "asmonly" {
  ret void
}

define void @USQADD_asisdmisc_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n) "enc"="0111111000100000001110 n:5 d:5" "asm"="usqadd {d}, {n}" "asmonly" {
  ret void
}

define void @SQNEG_asisdmisc_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n) "enc"="0111111000100000011110 n:5 d:5" "asm"="sqneg {d}, {n}" "asmonly" {
  ret void
}

define void @CMGE_asisdmisc_Z.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0111111011100000100010 n:5 d:5" "asm"="cmge {d}, {n}, #0" "asmonly" {
  ret void
}

define void @CMLE_asisdmisc_Z.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0111111011100000100110 n:5 d:5" "asm"="cmle {d}, {n}, #0" "asmonly" {
  ret void
}

define void @NEG_asisdmisc_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n) "enc"="0111111011100000101110 n:5 d:5" "asm"="neg {d}, {n}" "asmonly" {
  ret void
}

define void @SQXTUN_asisdmisc_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n) "enc"="0111111000100001001010 n:5 d:5" "asm"="sqxtun {d}, {n}" "asmonly" {
  ret void
}

define void @UQXTN_asisdmisc_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n) "enc"="0111111000100001010010 n:5 d:5" "asm"="uqxtn {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTXN_asisdmisc_N.0(i64 "reg"="s" %d, i64 "reg"="d" %n) "enc"="0111111001100001011010 n:5 d:5" "asm"="fcvtxn {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTNU_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111000100001101010 n:5 d:5" "asm"="fcvtnu {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTMU_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111000100001101110 n:5 d:5" "asm"="fcvtmu {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTAU_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111000100001110010 n:5 d:5" "asm"="fcvtau {d}, {n}" "asmonly" {
  ret void
}

define void @UCVTF_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111000100001110110 n:5 d:5" "asm"="ucvtf {d}, {n}" "asmonly" {
  ret void
}

define void @FCMGE_asisdmisc_FZ.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111010100000110010 n:5 d:5" "asm"="fcmge {d}, {n}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asisdmisc_FZ.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111010100000110110 n:5 d:5" "asm"="fcmle {d}, {n}, #0.0" "asmonly" {
  ret void
}

define void @FCVTPU_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111010100001101010 n:5 d:5" "asm"="fcvtpu {d}, {n}" "asmonly" {
  ret void
}

define void @FCVTZU_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111010100001101110 n:5 d:5" "asm"="fcvtzu {d}, {n}" "asmonly" {
  ret void
}

define void @FRSQRTE_asisdmisc_R.0(i64 "reg"="s" %d, i64 "reg"="s" %n) "enc"="0111111010100001110110 n:5 d:5" "asm"="frsqrte {d}, {n}" "asmonly" {
  ret void
}

define void @FMAXNMP_asisdpair_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0101111000110000110010 vn:5 d:5" "asm"="fmaxnmp {d}, {vn:2h}" "asmonly" {
  ret void
}

define void @FADDP_asisdpair_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0101111000110000110110 vn:5 d:5" "asm"="faddp {d}, {vn:2h}" "asmonly" {
  ret void
}

define void @FMAXP_asisdpair_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0101111000110000111110 vn:5 d:5" "asm"="fmaxp {d}, {vn:2h}" "asmonly" {
  ret void
}

define void @FMINNMP_asisdpair_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0101111010110000110010 vn:5 d:5" "asm"="fminnmp {d}, {vn:2h}" "asmonly" {
  ret void
}

define void @FMINP_asisdpair_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0101111010110000111110 vn:5 d:5" "asm"="fminp {d}, {vn:2h}" "asmonly" {
  ret void
}

define void @FMAXNMP_asisdpair_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0111111000110000110010 vn:5 d:5" "asm"="fmaxnmp {d}, {vn:2s}" "asmonly" {
  ret void
}

define void @FADDP_asisdpair_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0111111000110000110110 vn:5 d:5" "asm"="faddp {d}, {vn:2s}" "asmonly" {
  ret void
}

define void @FMAXP_asisdpair_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0111111000110000111110 vn:5 d:5" "asm"="fmaxp {d}, {vn:2s}" "asmonly" {
  ret void
}

define void @FMINNMP_asisdpair_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0111111010110000110010 vn:5 d:5" "asm"="fminnmp {d}, {vn:2s}" "asmonly" {
  ret void
}

define void @FMINP_asisdpair_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0111111010110000111110 vn:5 d:5" "asm"="fminp {d}, {vn:2s}" "asmonly" {
  ret void
}

define void @SQDMLAL_asisddiff_only.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01011110011 m:5 100100 n:5 d:5" "asm"="sqdmlal {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQDMLSL_asisddiff_only.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01011110011 m:5 101100 n:5 d:5" "asm"="sqdmlsl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQDMULL_asisddiff_only.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01011110011 m:5 110100 n:5 d:5" "asm"="sqdmull {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQADD_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01011110001 m:5 000011 n:5 d:5" "asm"="sqadd {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQSUB_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01011110001 m:5 001011 n:5 d:5" "asm"="sqsub {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMGT_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 001101 n:5 d:5" "asm"="cmgt {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMGE_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 001111 n:5 d:5" "asm"="cmge {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SSHL_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 010001 n:5 d:5" "asm"="sshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQSHL_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01011110001 m:5 010011 n:5 d:5" "asm"="sqshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SRSHL_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 010101 n:5 d:5" "asm"="srshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQRSHL_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01011110001 m:5 010111 n:5 d:5" "asm"="sqrshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @ADD_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 100001 n:5 d:5" "asm"="add {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMTST_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01011110111 m:5 100011 n:5 d:5" "asm"="cmtst {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQDMULH_asisdsame_only.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01011110011 m:5 101101 n:5 d:5" "asm"="sqdmulh {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FMULX_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01011110001 m:5 110111 n:5 d:5" "asm"="fmulx {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FCMEQ_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01011110001 m:5 111001 n:5 d:5" "asm"="fcmeq {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FRECPS_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01011110001 m:5 111111 n:5 d:5" "asm"="frecps {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FRSQRTS_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01011110101 m:5 111111 n:5 d:5" "asm"="frsqrts {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @UQADD_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01111110001 m:5 000011 n:5 d:5" "asm"="uqadd {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @UQSUB_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01111110001 m:5 001011 n:5 d:5" "asm"="uqsub {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMHI_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 001101 n:5 d:5" "asm"="cmhi {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMHS_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 001111 n:5 d:5" "asm"="cmhs {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @USHL_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 010001 n:5 d:5" "asm"="ushl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @UQSHL_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01111110001 m:5 010011 n:5 d:5" "asm"="uqshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @URSHL_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 010101 n:5 d:5" "asm"="urshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @UQRSHL_asisdsame_only.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "reg"="b" %m) "enc"="01111110001 m:5 010111 n:5 d:5" "asm"="uqrshl {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SUB_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 100001 n:5 d:5" "asm"="sub {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @CMEQ_asisdsame_only.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "reg"="d" %m) "enc"="01111110111 m:5 100011 n:5 d:5" "asm"="cmeq {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SQRDMULH_asisdsame_only.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="h" %m) "enc"="01111110011 m:5 101101 n:5 d:5" "asm"="sqrdmulh {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FCMGE_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01111110001 m:5 111001 n:5 d:5" "asm"="fcmge {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FACGE_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01111110001 m:5 111011 n:5 d:5" "asm"="facge {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FABD_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01111110101 m:5 110101 n:5 d:5" "asm"="fabd {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FCMGT_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01111110101 m:5 111001 n:5 d:5" "asm"="fcmgt {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @FACGT_asisdsame_only.0(i64 "reg"="s" %d, i64 "reg"="s" %n, i64 "reg"="s" %m) "enc"="01111110101 m:5 111011 n:5 d:5" "asm"="facgt {d}, {n}, {m}" "asmonly" {
  ret void
}

define void @SSHR_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0101111101 shift_f:6=(64-shift) 000001 n:5 d:5" "asm"="sshr {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0101111101 shift_f:6=(64-shift) 000101 n:5 d:5" "asm"="ssra {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0101111101 shift_f:6=(64-shift) 001001 n:5 d:5" "asm"="srshr {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0101111101 shift_f:6=(64-shift) 001101 n:5 d:5" "asm"="srsra {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SHL_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0101111101 shift:6 010101 n:5 d:5" "asm"="shl {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asisdshf_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "imm" %shift) "enc"="0101111100001 shift:3 011101 n:5 d:5" "asm"="sqshl {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0101111100001 shift_f:3=(8-shift) 100101 n:5 d:5" "asm"="sqshrn {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0101111100001 shift_f:3=(8-shift) 100111 n:5 d:5" "asm"="sqrshrn {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SCVTF_asisdshf_C.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "imm" %fbits) "enc"="010111110001 fbits_f:4=(16-fbits) 111001 n:5 d:5" "asm"="scvtf {d}, {n}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asisdshf_C.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "imm" %fbits) "enc"="010111110001 fbits_f:4=(16-fbits) 111111 n:5 d:5" "asm"="fcvtzs {d}, {n}, #{fbits}" "asmonly" {
  ret void
}

define void @USHR_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift_f:6=(64-shift) 000001 n:5 d:5" "asm"="ushr {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift_f:6=(64-shift) 000101 n:5 d:5" "asm"="usra {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift_f:6=(64-shift) 001001 n:5 d:5" "asm"="urshr {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift_f:6=(64-shift) 001101 n:5 d:5" "asm"="ursra {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift_f:6=(64-shift) 010001 n:5 d:5" "asm"="sri {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asisdshf_R.0(i64 "reg"="d" %d, i64 "reg"="d" %n, i64 "imm" %shift) "enc"="0111111101 shift:6 010101 n:5 d:5" "asm"="sli {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asisdshf_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "imm" %shift) "enc"="0111111100001 shift:3 011001 n:5 d:5" "asm"="sqshlu {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asisdshf_R.0(i64 "reg"="b" %d, i64 "reg"="b" %n, i64 "imm" %shift) "enc"="0111111100001 shift:3 011101 n:5 d:5" "asm"="uqshl {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0111111100001 shift_f:3=(8-shift) 100001 n:5 d:5" "asm"="sqshrun {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0111111100001 shift_f:3=(8-shift) 100011 n:5 d:5" "asm"="sqrshrun {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0111111100001 shift_f:3=(8-shift) 100101 n:5 d:5" "asm"="uqshrn {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asisdshf_N.0(i64 "reg"="b" %d, i64 "reg"="h" %n, i64 "imm" %shift) "enc"="0111111100001 shift_f:3=(8-shift) 100111 n:5 d:5" "asm"="uqrshrn {d}, {n}, #{shift}" "asmonly" {
  ret void
}

define void @UCVTF_asisdshf_C.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "imm" %fbits) "enc"="011111110001 fbits_f:4=(16-fbits) 111001 n:5 d:5" "asm"="ucvtf {d}, {n}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asisdshf_C.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "imm" %fbits) "enc"="011111110001 fbits_f:4=(16-fbits) 111111 n:5 d:5" "asm"="fcvtzu {d}, {n}, #{fbits}" "asmonly" {
  ret void
}

define void @SQDMLAL_asisdelem_L.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0101111101 index1:2=index&3 m:4 0011 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqdmlal {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLSL_asisdelem_L.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0101111101 index1:2=index&3 m:4 0111 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqdmlsl {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULL_asisdelem_L.0(i64 "reg"="s" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0101111101 index1:2=index&3 m:4 1011 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqdmull {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULH_asisdelem_R.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0101111101 index1:2=index&3 m:4 1100 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqdmulh {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMULH_asisdelem_R.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0101111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqrdmulh {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLA_asisdelem_RH_H.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0101111100 index1:2=index&3 vm:4 0001 index2:1=(index>>2)&1 0 hn:5 hd:5" "asm"="fmla {hd}, {hn}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLS_asisdelem_RH_H.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0101111100 index1:2=index&3 vm:4 0101 index2:1=(index>>2)&1 0 hn:5 hd:5" "asm"="fmls {hd}, {hn}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMUL_asisdelem_RH_H.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0101111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 hn:5 hd:5" "asm"="fmul {hd}, {hn}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLAH_asisdelem_R.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0111111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqrdmlah {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLSH_asisdelem_R.0(i64 "reg"="h" %d, i64 "reg"="h" %n, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0111111101 index1:2=index&3 m:4 1111 index2:1=(index>>2)&1 0 n:5 d:5" "asm"="sqrdmlsh {d}, {n}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMULX_asisdelem_RH_H.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0111111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 hn:5 hd:5" "asm"="fmulx {hd}, {hn}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UZP1_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 000110 vn:5 vd:5" "asm"="uzp1 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @TRN1_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 001010 vn:5 vd:5" "asm"="trn1 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ZIP1_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 001110 vn:5 vd:5" "asm"="zip1 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UZP2_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 010110 vn:5 vd:5" "asm"="uzp2 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @TRN2_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 011010 vn:5 vd:5" "asm"="trn2 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ZIP2_asimdperm_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 011110 vn:5 vd:5" "asm"="zip2 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @EXT_asimdext_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="00101110000 vm:5 00 index:s3 0 vn:5 vd:5" "asm"="ext {vd:8b}, {vn:8b}, {vm:8b}, #{index}" "asmonly" {
  ret void
}

define void @EXT_asimdext_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101110000 vm:5 0 index:s4 0 vn:5 vd:5" "asm"="ext {vd:16b}, {vn:16b}, {vm:16b}, #{index}" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="00001110000 index:4 1000001 vn:5 vd:5" "asm"="dup {vd:8b}, {vn:.b}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:4 1000001 vn:5 vd:5" "asm"="dup {vd:16b}, {vn:.b}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="00001110000 index:3 10000001 vn:5 vd:5" "asm"="dup {vd:4h}, {vn:.h}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:3 10000001 vn:5 vd:5" "asm"="dup {vd:8h}, {vn:.h}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="00001110000 index:2 100000001 vn:5 vd:5" "asm"="dup {vd:2s}, {vn:.s}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:2 100000001 vn:5 vd:5" "asm"="dup {vd:4s}, {vn:.s}[{index}]" "asmonly" {
  ret void
}

define void @DUP_asimdins_DV_v.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:1 1000000001 vn:5 vd:5" "asm"="dup {vd:2d}, {vn:.d}[{index}]" "asmonly" {
  ret void
}

define void @SMOV_asimdins_W_w.0(i64 "reg"="w" %wd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="00001110000 index:4 1001011 vn:5 wd:5" "asm"="smov {wd}, {vn:.b}[{index}]" "asmonly" {
  ret void
}

define void @SMOV_asimdins_W_w.1(i64 "reg"="w" %wd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="00001110000 index:3 10001011 vn:5 wd:5" "asm"="smov {wd}, {vn:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMOV_asimdins_X_x.0(i64 "reg"="x" %xd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:4 1001011 vn:5 xd:5" "asm"="smov {xd}, {vn:.b}[{index}]" "asmonly" {
  ret void
}

define void @SMOV_asimdins_X_x.1(i64 "reg"="x" %xd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:3 10001011 vn:5 xd:5" "asm"="smov {xd}, {vn:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMOV_asimdins_X_x.2(i64 "reg"="x" %xd, i64 "reg"="q" %vn, i64 "imm" %index) "enc"="01001110000 index:2 100001011 vn:5 xd:5" "asm"="smov {xd}, {vn:.s}[{index}]" "asmonly" {
  ret void
}

define void @INS_asimdins_IV_v.0(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:4 10 index2:4 1 vn:5 vd:5" "asm"="ins {vd:.b}[{index1}], {vn:.b}[{index2}]" "asmonly" "aliases"="mov" {
  ret void
}

define void @INS_asimdins_IV_v.1(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:3 100 index2:3 01 vn:5 vd:5" "asm"="ins {vd:.h}[{index1}], {vn:.h}[{index2}]" "asmonly" "aliases"="mov" {
  ret void
}

define void @INS_asimdins_IV_v.2(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:2 1000 index2:2 001 vn:5 vd:5" "asm"="ins {vd:.s}[{index1}], {vn:.s}[{index2}]" "asmonly" "aliases"="mov" {
  ret void
}

define void @INS_asimdins_IV_v.3(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:1 10000 index2:1 0001 vn:5 vd:5" "asm"="ins {vd:.d}[{index1}], {vn:.d}[{index2}]" "asmonly" "aliases"="mov" {
  ret void
}

define void @INS_asimdins_IV_v.MOV.0(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:4 10 index2:4 1 vn:5 vd:5" "asm"="mov {vd:.b}[{index1}], {vn:.b}[{index2}]" "asmonly" "nodecode" {
  ret void
}

define void @INS_asimdins_IV_v.MOV.1(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:3 100 index2:3 01 vn:5 vd:5" "asm"="mov {vd:.h}[{index1}], {vn:.h}[{index2}]" "asmonly" "nodecode" {
  ret void
}

define void @INS_asimdins_IV_v.MOV.2(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:2 1000 index2:2 001 vn:5 vd:5" "asm"="mov {vd:.s}[{index1}], {vn:.s}[{index2}]" "asmonly" "nodecode" {
  ret void
}

define void @INS_asimdins_IV_v.MOV.3(i64 "reg"="q" %vd, i64 "imm" %index1, i64 "reg"="q" %vn, i64 "imm" %index2) "enc"="01101110000 index1:1 10000 index2:1 0001 vn:5 vd:5" "asm"="mov {vd:.d}[{index1}], {vn:.d}[{index2}]" "asmonly" "nodecode" {
  ret void
}

define void @FMAXNM_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 000001 vn:5 vd:5" "asm"="fmaxnm {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMAXNM_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 000001 vn:5 vd:5" "asm"="fmaxnm {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMLA_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 000011 vn:5 vd:5" "asm"="fmla {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMLA_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 000011 vn:5 vd:5" "asm"="fmla {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FADD_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 000101 vn:5 vd:5" "asm"="fadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FADD_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 000101 vn:5 vd:5" "asm"="fadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMULX_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 000111 vn:5 vd:5" "asm"="fmulx {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMULX_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 000111 vn:5 vd:5" "asm"="fmulx {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FCMEQ_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 001001 vn:5 vd:5" "asm"="fcmeq {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FCMEQ_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 001001 vn:5 vd:5" "asm"="fcmeq {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMAX_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 001101 vn:5 vd:5" "asm"="fmax {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMAX_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 001101 vn:5 vd:5" "asm"="fmax {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FRECPS_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 001111 vn:5 vd:5" "asm"="frecps {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FRECPS_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 001111 vn:5 vd:5" "asm"="frecps {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMINNM_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 000001 vn:5 vd:5" "asm"="fminnm {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMINNM_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 000001 vn:5 vd:5" "asm"="fminnm {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMLS_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 000011 vn:5 vd:5" "asm"="fmls {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMLS_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 000011 vn:5 vd:5" "asm"="fmls {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FSUB_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 000101 vn:5 vd:5" "asm"="fsub {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FSUB_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 000101 vn:5 vd:5" "asm"="fsub {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FAMAX_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 000111 vn:5 vd:5" "asm"="famax {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FAMAX_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 000111 vn:5 vd:5" "asm"="famax {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMIN_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 001101 vn:5 vd:5" "asm"="fmin {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMIN_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 001101 vn:5 vd:5" "asm"="fmin {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FRSQRTS_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 001111 vn:5 vd:5" "asm"="frsqrts {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FRSQRTS_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 001111 vn:5 vd:5" "asm"="frsqrts {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMAXNMP_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 000001 vn:5 vd:5" "asm"="fmaxnmp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMAXNMP_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 000001 vn:5 vd:5" "asm"="fmaxnmp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FADDP_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 000101 vn:5 vd:5" "asm"="faddp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FADDP_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 000101 vn:5 vd:5" "asm"="faddp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMUL_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 000111 vn:5 vd:5" "asm"="fmul {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMUL_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 000111 vn:5 vd:5" "asm"="fmul {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FCMGE_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 001001 vn:5 vd:5" "asm"="fcmge {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FCMGE_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 001001 vn:5 vd:5" "asm"="fcmge {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FACGE_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 001011 vn:5 vd:5" "asm"="facge {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FACGE_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 001011 vn:5 vd:5" "asm"="facge {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMAXP_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 001101 vn:5 vd:5" "asm"="fmaxp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMAXP_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 001101 vn:5 vd:5" "asm"="fmaxp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FDIV_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 001111 vn:5 vd:5" "asm"="fdiv {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FDIV_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 001111 vn:5 vd:5" "asm"="fdiv {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMINNMP_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 000001 vn:5 vd:5" "asm"="fminnmp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMINNMP_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 000001 vn:5 vd:5" "asm"="fminnmp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FABD_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 000101 vn:5 vd:5" "asm"="fabd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FABD_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 000101 vn:5 vd:5" "asm"="fabd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FAMIN_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 000111 vn:5 vd:5" "asm"="famin {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FAMIN_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 000111 vn:5 vd:5" "asm"="famin {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FCMGT_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 001001 vn:5 vd:5" "asm"="fcmgt {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FCMGT_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 001001 vn:5 vd:5" "asm"="fcmgt {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FACGT_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 001011 vn:5 vd:5" "asm"="facgt {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FACGT_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 001011 vn:5 vd:5" "asm"="facgt {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMINP_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 001101 vn:5 vd:5" "asm"="fminp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMINP_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 001101 vn:5 vd:5" "asm"="fminp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FSCALE_asimdsamefp16_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 001111 vn:5 vd:5" "asm"="fscale {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FSCALE_asimdsamefp16_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 001111 vn:5 vd:5" "asm"="fscale {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FRINTN_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001100010 vn:5 vd:5" "asm"="frintn {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTN_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001100010 vn:5 vd:5" "asm"="frintn {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTM_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001100110 vn:5 vd:5" "asm"="frintm {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTM_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001100110 vn:5 vd:5" "asm"="frintm {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTNS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001101010 vn:5 vd:5" "asm"="fcvtns {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTNS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001101010 vn:5 vd:5" "asm"="fcvtns {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTMS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001101110 vn:5 vd:5" "asm"="fcvtms {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTMS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001101110 vn:5 vd:5" "asm"="fcvtms {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTAS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001110010 vn:5 vd:5" "asm"="fcvtas {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTAS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001110010 vn:5 vd:5" "asm"="fcvtas {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @SCVTF_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001111001110110 vn:5 vd:5" "asm"="scvtf {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @SCVTF_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001111001110110 vn:5 vd:5" "asm"="scvtf {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCMGT_asimdmiscfp16_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111000110010 vn:5 vd:5" "asm"="fcmgt {vd:4h}, {vn:4h}, #0.0" "asmonly" {
  ret void
}

define void @FCMGT_asimdmiscfp16_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111000110010 vn:5 vd:5" "asm"="fcmgt {vd:8h}, {vn:8h}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asimdmiscfp16_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111000110110 vn:5 vd:5" "asm"="fcmeq {vd:4h}, {vn:4h}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asimdmiscfp16_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111000110110 vn:5 vd:5" "asm"="fcmeq {vd:8h}, {vn:8h}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asimdmiscfp16_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111000111010 vn:5 vd:5" "asm"="fcmlt {vd:4h}, {vn:4h}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asimdmiscfp16_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111000111010 vn:5 vd:5" "asm"="fcmlt {vd:8h}, {vn:8h}, #0.0" "asmonly" {
  ret void
}

define void @FABS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111000111110 vn:5 vd:5" "asm"="fabs {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FABS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111000111110 vn:5 vd:5" "asm"="fabs {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTP_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111001100010 vn:5 vd:5" "asm"="frintp {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTP_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111001100010 vn:5 vd:5" "asm"="frintp {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTZ_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111001100110 vn:5 vd:5" "asm"="frintz {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTZ_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111001100110 vn:5 vd:5" "asm"="frintz {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTPS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111001101010 vn:5 vd:5" "asm"="fcvtps {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTPS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111001101010 vn:5 vd:5" "asm"="fcvtps {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111001101110 vn:5 vd:5" "asm"="fcvtzs {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111001101110 vn:5 vd:5" "asm"="fcvtzs {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRECPE_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111011111001110110 vn:5 vd:5" "asm"="frecpe {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRECPE_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011111001110110 vn:5 vd:5" "asm"="frecpe {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTA_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001100010 vn:5 vd:5" "asm"="frinta {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTA_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001100010 vn:5 vd:5" "asm"="frinta {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTX_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001100110 vn:5 vd:5" "asm"="frintx {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTX_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001100110 vn:5 vd:5" "asm"="frintx {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTNU_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001101010 vn:5 vd:5" "asm"="fcvtnu {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTNU_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001101010 vn:5 vd:5" "asm"="fcvtnu {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTMU_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001101110 vn:5 vd:5" "asm"="fcvtmu {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTMU_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001101110 vn:5 vd:5" "asm"="fcvtmu {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTAU_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001110010 vn:5 vd:5" "asm"="fcvtau {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTAU_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001110010 vn:5 vd:5" "asm"="fcvtau {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @UCVTF_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001111001110110 vn:5 vd:5" "asm"="ucvtf {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @UCVTF_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001111001110110 vn:5 vd:5" "asm"="ucvtf {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCMGE_asimdmiscfp16_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111000110010 vn:5 vd:5" "asm"="fcmge {vd:4h}, {vn:4h}, #0.0" "asmonly" {
  ret void
}

define void @FCMGE_asimdmiscfp16_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111000110010 vn:5 vd:5" "asm"="fcmge {vd:8h}, {vn:8h}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asimdmiscfp16_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111000110110 vn:5 vd:5" "asm"="fcmle {vd:4h}, {vn:4h}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asimdmiscfp16_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111000110110 vn:5 vd:5" "asm"="fcmle {vd:8h}, {vn:8h}, #0.0" "asmonly" {
  ret void
}

define void @FNEG_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111000111110 vn:5 vd:5" "asm"="fneg {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FNEG_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111000111110 vn:5 vd:5" "asm"="fneg {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTI_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111001100110 vn:5 vd:5" "asm"="frinti {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRINTI_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111001100110 vn:5 vd:5" "asm"="frinti {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTPU_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111001101010 vn:5 vd:5" "asm"="fcvtpu {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTPU_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111001101010 vn:5 vd:5" "asm"="fcvtpu {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111001101110 vn:5 vd:5" "asm"="fcvtzu {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111001101110 vn:5 vd:5" "asm"="fcvtzu {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRSQRTE_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111001110110 vn:5 vd:5" "asm"="frsqrte {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FRSQRTE_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111001110110 vn:5 vd:5" "asm"="frsqrte {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @FSQRT_asimdmiscfp16_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011111001111110 vn:5 vd:5" "asm"="fsqrt {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @FSQRT_asimdmiscfp16_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011111001111110 vn:5 vd:5" "asm"="fsqrt {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @SDOT_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 100101 vn:5 vd:5" "asm"="sdot {vd:2s}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SDOT_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 100101 vn:5 vd:5" "asm"="sdot {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FCVTN_asimdsame2_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 111101 vn:5 vd:5" "asm"="fcvtn {vd:8b}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FCVTN_asimdsame2_H.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 111101 vn:5 vd:5" "asm"="fcvtn2 {vd:16b}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FDOT_asimdsame2_DD.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 111111 vn:5 vd:5" "asm"="fdot {vd:2s}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @FDOT_asimdsame2_DD.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 111111 vn:5 vd:5" "asm"="fdot {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FCVTN_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 111101 vn:5 vd:5" "asm"="fcvtn {vd:8b}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FCVTN_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 111101 vn:5 vd:5" "asm"="fcvtn {vd:16b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FDOT_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 111111 vn:5 vd:5" "asm"="fdot {vd:4h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @FDOT_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 111111 vn:5 vd:5" "asm"="fdot {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @USDOT_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110100 vm:5 100111 vn:5 vd:5" "asm"="usdot {vd:2s}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @USDOT_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 100111 vn:5 vd:5" "asm"="usdot {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdsame2_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 100001 vn:5 vd:5" "asm"="sqrdmlah {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdsame2_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 100001 vn:5 vd:5" "asm"="sqrdmlah {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdsame2_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 100001 vn:5 vd:5" "asm"="sqrdmlah {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdsame2_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 100001 vn:5 vd:5" "asm"="sqrdmlah {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdsame2_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 100011 vn:5 vd:5" "asm"="sqrdmlsh {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdsame2_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 100011 vn:5 vd:5" "asm"="sqrdmlsh {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdsame2_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 100011 vn:5 vd:5" "asm"="sqrdmlsh {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdsame2_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 100011 vn:5 vd:5" "asm"="sqrdmlsh {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UDOT_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 100101 vn:5 vd:5" "asm"="udot {vd:2s}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UDOT_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 100101 vn:5 vd:5" "asm"="udot {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 110001 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:4h}, #0" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 110011 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:4h}, #90" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 110101 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:4h}, #180" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 110111 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:4h}, #270" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 110001 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:8h}, #0" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 110011 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:8h}, #90" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 110101 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:8h}, #180" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.7(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 110111 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:8h}, #270" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.8(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 110001 vn:5 vd:5" "asm"="fcmla {vd:2s}, {vn:2s}, {vm:2s}, #0" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.9(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 110011 vn:5 vd:5" "asm"="fcmla {vd:2s}, {vn:2s}, {vm:2s}, #90" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.10(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 110101 vn:5 vd:5" "asm"="fcmla {vd:2s}, {vn:2s}, {vm:2s}, #180" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.11(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 110111 vn:5 vd:5" "asm"="fcmla {vd:2s}, {vn:2s}, {vm:2s}, #270" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.12(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 110001 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:4s}, #0" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.13(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 110011 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:4s}, #90" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.14(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 110101 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:4s}, #180" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.15(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 110111 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:4s}, #270" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.16(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 110001 vn:5 vd:5" "asm"="fcmla {vd:2d}, {vn:2d}, {vm:2d}, #0" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.17(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 110011 vn:5 vd:5" "asm"="fcmla {vd:2d}, {vn:2d}, {vm:2d}, #90" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.18(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 110101 vn:5 vd:5" "asm"="fcmla {vd:2d}, {vn:2d}, {vm:2d}, #180" "asmonly" {
  ret void
}

define void @FCMLA_asimdsame2_C.19(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 110111 vn:5 vd:5" "asm"="fcmla {vd:2d}, {vn:2d}, {vm:2d}, #270" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 111001 vn:5 vd:5" "asm"="fcadd {vd:4h}, {vn:4h}, {vm:4h}, #90" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 111101 vn:5 vd:5" "asm"="fcadd {vd:4h}, {vn:4h}, {vm:4h}, #270" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 111001 vn:5 vd:5" "asm"="fcadd {vd:8h}, {vn:8h}, {vm:8h}, #90" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 111101 vn:5 vd:5" "asm"="fcadd {vd:8h}, {vn:8h}, {vm:8h}, #270" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 111001 vn:5 vd:5" "asm"="fcadd {vd:2s}, {vn:2s}, {vm:2s}, #90" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110100 vm:5 111101 vn:5 vd:5" "asm"="fcadd {vd:2s}, {vn:2s}, {vm:2s}, #270" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 111001 vn:5 vd:5" "asm"="fcadd {vd:4s}, {vn:4s}, {vm:4s}, #90" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.7(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 111101 vn:5 vd:5" "asm"="fcadd {vd:4s}, {vn:4s}, {vm:4s}, #270" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.8(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 111001 vn:5 vd:5" "asm"="fcadd {vd:2d}, {vn:2d}, {vm:2d}, #90" "asmonly" {
  ret void
}

define void @FCADD_asimdsame2_C.9(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 111101 vn:5 vd:5" "asm"="fcadd {vd:2d}, {vn:2d}, {vm:2d}, #270" "asmonly" {
  ret void
}

define void @BFDOT_asimdsame2_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110010 vm:5 111111 vn:5 vd:5" "asm"="bfdot {vd:2s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @BFDOT_asimdsame2_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 111111 vn:5 vd:5" "asm"="bfdot {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @BFMLAL_asimdsame2_F_.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110110 vm:5 111111 vn:5 vd:5" "asm"="bfmlalb {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @BFMLAL_asimdsame2_F_.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110110 vm:5 111111 vn:5 vd:5" "asm"="bfmlalt {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @FMLALLBB_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110000 vm:5 110001 vn:5 vd:5" "asm"="fmlallbb {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLALLBT_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110010 vm:5 110001 vn:5 vd:5" "asm"="fmlallbt {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLALB_asimdsame2_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110110 vm:5 111111 vn:5 vd:5" "asm"="fmlalb {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLALLTB_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110000 vm:5 110001 vn:5 vd:5" "asm"="fmlalltb {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLALLTT_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110010 vm:5 110001 vn:5 vd:5" "asm"="fmlalltt {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SMMLA_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 101001 vn:5 vd:5" "asm"="smmla {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @USMMLA_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110100 vm:5 101011 vn:5 vd:5" "asm"="usmmla {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLALT_asimdsame2_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110110 vm:5 111111 vn:5 vd:5" "asm"="fmlalt {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @BFMMLA_asimdsame2_E.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110010 vm:5 111011 vn:5 vd:5" "asm"="bfmmla {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UMMLA_asimdsame2_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110100 vm:5 101001 vn:5 vd:5" "asm"="ummla {vd:4s}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @REV16_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000000110 vn:5 vd:5" "asm"="rev16 {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @REV16_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000000110 vn:5 vd:5" "asm"="rev16 {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000001010 vn:5 vd:5" "asm"="saddlp {vd:4h}, {vn:8b}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000001010 vn:5 vd:5" "asm"="saddlp {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000001010 vn:5 vd:5" "asm"="saddlp {vd:2s}, {vn:4h}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000001010 vn:5 vd:5" "asm"="saddlp {vd:4s}, {vn:8h}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000001010 vn:5 vd:5" "asm"="saddlp {vd:1d}, {vn:2s}" "asmonly" {
  ret void
}

define void @SADDLP_asimdmisc_P.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000001010 vn:5 vd:5" "asm"="saddlp {vd:2d}, {vn:4s}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000001110 vn:5 vd:5" "asm"="suqadd {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000001110 vn:5 vd:5" "asm"="suqadd {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000001110 vn:5 vd:5" "asm"="suqadd {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000001110 vn:5 vd:5" "asm"="suqadd {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000001110 vn:5 vd:5" "asm"="suqadd {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000001110 vn:5 vd:5" "asm"="suqadd {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @SUQADD_asimdmisc_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000001110 vn:5 vd:5" "asm"="suqadd {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000010010 vn:5 vd:5" "asm"="cls {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000010010 vn:5 vd:5" "asm"="cls {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000010010 vn:5 vd:5" "asm"="cls {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000010010 vn:5 vd:5" "asm"="cls {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000010010 vn:5 vd:5" "asm"="cls {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @CLS_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000010010 vn:5 vd:5" "asm"="cls {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @CNT_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000010110 vn:5 vd:5" "asm"="cnt {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000011010 vn:5 vd:5" "asm"="sadalp {vd:4h}, {vn:8b}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000011010 vn:5 vd:5" "asm"="sadalp {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000011010 vn:5 vd:5" "asm"="sadalp {vd:2s}, {vn:4h}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000011010 vn:5 vd:5" "asm"="sadalp {vd:4s}, {vn:8h}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000011010 vn:5 vd:5" "asm"="sadalp {vd:1d}, {vn:2s}" "asmonly" {
  ret void
}

define void @SADALP_asimdmisc_P.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000011010 vn:5 vd:5" "asm"="sadalp {vd:2d}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000011110 vn:5 vd:5" "asm"="sqabs {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000011110 vn:5 vd:5" "asm"="sqabs {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000011110 vn:5 vd:5" "asm"="sqabs {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000011110 vn:5 vd:5" "asm"="sqabs {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000011110 vn:5 vd:5" "asm"="sqabs {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000011110 vn:5 vd:5" "asm"="sqabs {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQABS_asimdmisc_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000011110 vn:5 vd:5" "asm"="sqabs {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000100010 vn:5 vd:5" "asm"="cmgt {vd:8b}, {vn:8b}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000100010 vn:5 vd:5" "asm"="cmgt {vd:16b}, {vn:16b}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000100010 vn:5 vd:5" "asm"="cmgt {vd:4h}, {vn:4h}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000100010 vn:5 vd:5" "asm"="cmgt {vd:8h}, {vn:8h}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000100010 vn:5 vd:5" "asm"="cmgt {vd:2s}, {vn:2s}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000100010 vn:5 vd:5" "asm"="cmgt {vd:4s}, {vn:4s}, #0" "asmonly" {
  ret void
}

define void @CMGT_asimdmisc_Z.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000100010 vn:5 vd:5" "asm"="cmgt {vd:2d}, {vn:2d}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000100110 vn:5 vd:5" "asm"="cmeq {vd:8b}, {vn:8b}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000100110 vn:5 vd:5" "asm"="cmeq {vd:16b}, {vn:16b}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000100110 vn:5 vd:5" "asm"="cmeq {vd:4h}, {vn:4h}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000100110 vn:5 vd:5" "asm"="cmeq {vd:8h}, {vn:8h}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000100110 vn:5 vd:5" "asm"="cmeq {vd:2s}, {vn:2s}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000100110 vn:5 vd:5" "asm"="cmeq {vd:4s}, {vn:4s}, #0" "asmonly" {
  ret void
}

define void @CMEQ_asimdmisc_Z.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000100110 vn:5 vd:5" "asm"="cmeq {vd:2d}, {vn:2d}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100000101010 vn:5 vd:5" "asm"="cmlt {vd:8b}, {vn:8b}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100000101010 vn:5 vd:5" "asm"="cmlt {vd:16b}, {vn:16b}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100000101010 vn:5 vd:5" "asm"="cmlt {vd:4h}, {vn:4h}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100000101010 vn:5 vd:5" "asm"="cmlt {vd:8h}, {vn:8h}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000101010 vn:5 vd:5" "asm"="cmlt {vd:2s}, {vn:2s}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000101010 vn:5 vd:5" "asm"="cmlt {vd:4s}, {vn:4s}, #0" "asmonly" {
  ret void
}

define void @CMLT_asimdmisc_Z.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000101010 vn:5 vd:5" "asm"="cmlt {vd:2d}, {vn:2d}, #0" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001010010 vn:5 vd:5" "asm"="sqxtn {vd:8b}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111001100001010010 vn:5 vd:5" "asm"="sqxtn {vd:4h}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001010010 vn:5 vd:5" "asm"="sqxtn {vd:2s}, {vn:2d}" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001010010 vn:5 vd:5" "asm"="sqxtn2 {vd:16b}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001010010 vn:5 vd:5" "asm"="sqxtn2 {vd:8h}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQXTN_asimdmisc_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001010010 vn:5 vd:5" "asm"="sqxtn2 {vd:4s}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTN_asimdmisc_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001011010 vn:5 vd:5" "asm"="fcvtn {vd:4h}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTN_asimdmisc_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001011010 vn:5 vd:5" "asm"="fcvtn2 {vd:8h}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTL_asimdmisc_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001011110 vn:5 vd:5" "asm"="fcvtl {vd:4s}, {vn:4h}" "asmonly" {
  ret void
}

define void @FCVTL_asimdmisc_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001011110 vn:5 vd:5" "asm"="fcvtl2 {vd:4s}, {vn:8h}" "asmonly" {
  ret void
}

define void @FRINTN_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001100010 vn:5 vd:5" "asm"="frintn {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTN_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001100010 vn:5 vd:5" "asm"="frintn {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTN_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001100010 vn:5 vd:5" "asm"="frintn {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINTM_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001100110 vn:5 vd:5" "asm"="frintm {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTM_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001100110 vn:5 vd:5" "asm"="frintm {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTM_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001100110 vn:5 vd:5" "asm"="frintm {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTNS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001101010 vn:5 vd:5" "asm"="fcvtns {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTNS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001101010 vn:5 vd:5" "asm"="fcvtns {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTNS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001101010 vn:5 vd:5" "asm"="fcvtns {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTMS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001101110 vn:5 vd:5" "asm"="fcvtms {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTMS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001101110 vn:5 vd:5" "asm"="fcvtms {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTMS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001101110 vn:5 vd:5" "asm"="fcvtms {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTAS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001110010 vn:5 vd:5" "asm"="fcvtas {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTAS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001110010 vn:5 vd:5" "asm"="fcvtas {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTAS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001110010 vn:5 vd:5" "asm"="fcvtas {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINT32Z_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001111010 vn:5 vd:5" "asm"="frint32z {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINT32Z_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001111010 vn:5 vd:5" "asm"="frint32z {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINT32Z_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001111010 vn:5 vd:5" "asm"="frint32z {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINT64Z_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111000100001111110 vn:5 vd:5" "asm"="frint64z {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINT64Z_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111000100001111110 vn:5 vd:5" "asm"="frint64z {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINT64Z_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111001100001111110 vn:5 vd:5" "asm"="frint64z {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCMGT_asimdmisc_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000110010 vn:5 vd:5" "asm"="fcmgt {vd:2s}, {vn:2s}, #0.0" "asmonly" {
  ret void
}

define void @FCMGT_asimdmisc_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000110010 vn:5 vd:5" "asm"="fcmgt {vd:4s}, {vn:4s}, #0.0" "asmonly" {
  ret void
}

define void @FCMGT_asimdmisc_FZ.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000110010 vn:5 vd:5" "asm"="fcmgt {vd:2d}, {vn:2d}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asimdmisc_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000110110 vn:5 vd:5" "asm"="fcmeq {vd:2s}, {vn:2s}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asimdmisc_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000110110 vn:5 vd:5" "asm"="fcmeq {vd:4s}, {vn:4s}, #0.0" "asmonly" {
  ret void
}

define void @FCMEQ_asimdmisc_FZ.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000110110 vn:5 vd:5" "asm"="fcmeq {vd:2d}, {vn:2d}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asimdmisc_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000111010 vn:5 vd:5" "asm"="fcmlt {vd:2s}, {vn:2s}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asimdmisc_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000111010 vn:5 vd:5" "asm"="fcmlt {vd:4s}, {vn:4s}, #0.0" "asmonly" {
  ret void
}

define void @FCMLT_asimdmisc_FZ.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000111010 vn:5 vd:5" "asm"="fcmlt {vd:2d}, {vn:2d}, #0.0" "asmonly" {
  ret void
}

define void @FABS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100000111110 vn:5 vd:5" "asm"="fabs {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FABS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100000111110 vn:5 vd:5" "asm"="fabs {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FABS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100000111110 vn:5 vd:5" "asm"="fabs {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINTP_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001100010 vn:5 vd:5" "asm"="frintp {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTP_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001100010 vn:5 vd:5" "asm"="frintp {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTP_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100001100010 vn:5 vd:5" "asm"="frintp {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINTZ_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001100110 vn:5 vd:5" "asm"="frintz {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTZ_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001100110 vn:5 vd:5" "asm"="frintz {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTZ_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100001100110 vn:5 vd:5" "asm"="frintz {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTPS_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001101010 vn:5 vd:5" "asm"="fcvtps {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTPS_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001101010 vn:5 vd:5" "asm"="fcvtps {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTPS_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100001101010 vn:5 vd:5" "asm"="fcvtps {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @URECPE_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001110010 vn:5 vd:5" "asm"="urecpe {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @URECPE_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001110010 vn:5 vd:5" "asm"="urecpe {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRECPE_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001110110 vn:5 vd:5" "asm"="frecpe {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRECPE_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001110110 vn:5 vd:5" "asm"="frecpe {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRECPE_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111011100001110110 vn:5 vd:5" "asm"="frecpe {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @BFCVTN_asimdmisc_4S.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0000111010100001011010 vn:5 vd:5" "asm"="bfcvtn {vd:4h}, {vn:4s}" "asmonly" {
  ret void
}

define void @BFCVTN_asimdmisc_4S.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0100111010100001011010 vn:5 vd:5" "asm"="bfcvtn2 {vd:8h}, {vn:4s}" "asmonly" {
  ret void
}

define void @REV32_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000000010 vn:5 vd:5" "asm"="rev32 {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @REV32_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000000010 vn:5 vd:5" "asm"="rev32 {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @REV32_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000000010 vn:5 vd:5" "asm"="rev32 {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @REV32_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000000010 vn:5 vd:5" "asm"="rev32 {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000001010 vn:5 vd:5" "asm"="uaddlp {vd:4h}, {vn:8b}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000001010 vn:5 vd:5" "asm"="uaddlp {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000001010 vn:5 vd:5" "asm"="uaddlp {vd:2s}, {vn:4h}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000001010 vn:5 vd:5" "asm"="uaddlp {vd:4s}, {vn:8h}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000001010 vn:5 vd:5" "asm"="uaddlp {vd:1d}, {vn:2s}" "asmonly" {
  ret void
}

define void @UADDLP_asimdmisc_P.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000001010 vn:5 vd:5" "asm"="uaddlp {vd:2d}, {vn:4s}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000001110 vn:5 vd:5" "asm"="usqadd {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000001110 vn:5 vd:5" "asm"="usqadd {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000001110 vn:5 vd:5" "asm"="usqadd {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000001110 vn:5 vd:5" "asm"="usqadd {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000001110 vn:5 vd:5" "asm"="usqadd {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000001110 vn:5 vd:5" "asm"="usqadd {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @USQADD_asimdmisc_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000001110 vn:5 vd:5" "asm"="usqadd {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000010010 vn:5 vd:5" "asm"="clz {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000010010 vn:5 vd:5" "asm"="clz {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000010010 vn:5 vd:5" "asm"="clz {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000010010 vn:5 vd:5" "asm"="clz {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000010010 vn:5 vd:5" "asm"="clz {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @CLZ_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000010010 vn:5 vd:5" "asm"="clz {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000011010 vn:5 vd:5" "asm"="uadalp {vd:4h}, {vn:8b}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000011010 vn:5 vd:5" "asm"="uadalp {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000011010 vn:5 vd:5" "asm"="uadalp {vd:2s}, {vn:4h}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000011010 vn:5 vd:5" "asm"="uadalp {vd:4s}, {vn:8h}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000011010 vn:5 vd:5" "asm"="uadalp {vd:1d}, {vn:2s}" "asmonly" {
  ret void
}

define void @UADALP_asimdmisc_P.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000011010 vn:5 vd:5" "asm"="uadalp {vd:2d}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000011110 vn:5 vd:5" "asm"="sqneg {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000011110 vn:5 vd:5" "asm"="sqneg {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000011110 vn:5 vd:5" "asm"="sqneg {vd:4h}, {vn:4h}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000011110 vn:5 vd:5" "asm"="sqneg {vd:8h}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000011110 vn:5 vd:5" "asm"="sqneg {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000011110 vn:5 vd:5" "asm"="sqneg {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQNEG_asimdmisc_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000011110 vn:5 vd:5" "asm"="sqneg {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000100010 vn:5 vd:5" "asm"="cmge {vd:8b}, {vn:8b}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000100010 vn:5 vd:5" "asm"="cmge {vd:16b}, {vn:16b}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000100010 vn:5 vd:5" "asm"="cmge {vd:4h}, {vn:4h}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000100010 vn:5 vd:5" "asm"="cmge {vd:8h}, {vn:8h}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000100010 vn:5 vd:5" "asm"="cmge {vd:2s}, {vn:2s}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000100010 vn:5 vd:5" "asm"="cmge {vd:4s}, {vn:4s}, #0" "asmonly" {
  ret void
}

define void @CMGE_asimdmisc_Z.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000100010 vn:5 vd:5" "asm"="cmge {vd:2d}, {vn:2d}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100000100110 vn:5 vd:5" "asm"="cmle {vd:8b}, {vn:8b}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100000100110 vn:5 vd:5" "asm"="cmle {vd:16b}, {vn:16b}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000100110 vn:5 vd:5" "asm"="cmle {vd:4h}, {vn:4h}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000100110 vn:5 vd:5" "asm"="cmle {vd:8h}, {vn:8h}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000100110 vn:5 vd:5" "asm"="cmle {vd:2s}, {vn:2s}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000100110 vn:5 vd:5" "asm"="cmle {vd:4s}, {vn:4s}, #0" "asmonly" {
  ret void
}

define void @CMLE_asimdmisc_Z.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000100110 vn:5 vd:5" "asm"="cmle {vd:2d}, {vn:2d}, #0" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001001010 vn:5 vd:5" "asm"="sqxtun {vd:8b}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100001001010 vn:5 vd:5" "asm"="sqxtun {vd:4h}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001001010 vn:5 vd:5" "asm"="sqxtun {vd:2s}, {vn:2d}" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001001010 vn:5 vd:5" "asm"="sqxtun2 {vd:16b}, {vn:8h}" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001001010 vn:5 vd:5" "asm"="sqxtun2 {vd:8h}, {vn:4s}" "asmonly" {
  ret void
}

define void @SQXTUN_asimdmisc_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001001010 vn:5 vd:5" "asm"="sqxtun2 {vd:4s}, {vn:2d}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001010010 vn:5 vd:5" "asm"="uqxtn {vd:8b}, {vn:8h}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100001010010 vn:5 vd:5" "asm"="uqxtn {vd:4h}, {vn:4s}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001010010 vn:5 vd:5" "asm"="uqxtn {vd:2s}, {vn:2d}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001010010 vn:5 vd:5" "asm"="uqxtn2 {vd:16b}, {vn:8h}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001010010 vn:5 vd:5" "asm"="uqxtn2 {vd:8h}, {vn:4s}" "asmonly" {
  ret void
}

define void @UQXTN_asimdmisc_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001010010 vn:5 vd:5" "asm"="uqxtn2 {vd:4s}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTXN_asimdmisc_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100001011010 vn:5 vd:5" "asm"="fcvtxn {vd:2s}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTXN_asimdmisc_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001011010 vn:5 vd:5" "asm"="fcvtxn2 {vd:4s}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINTA_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001100010 vn:5 vd:5" "asm"="frinta {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTA_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001100010 vn:5 vd:5" "asm"="frinta {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTA_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001100010 vn:5 vd:5" "asm"="frinta {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINTX_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001100110 vn:5 vd:5" "asm"="frintx {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTX_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001100110 vn:5 vd:5" "asm"="frintx {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTX_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001100110 vn:5 vd:5" "asm"="frintx {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTNU_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001101010 vn:5 vd:5" "asm"="fcvtnu {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTNU_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001101010 vn:5 vd:5" "asm"="fcvtnu {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTNU_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001101010 vn:5 vd:5" "asm"="fcvtnu {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTMU_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001101110 vn:5 vd:5" "asm"="fcvtmu {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTMU_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001101110 vn:5 vd:5" "asm"="fcvtmu {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTMU_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001101110 vn:5 vd:5" "asm"="fcvtmu {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTAU_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001110010 vn:5 vd:5" "asm"="fcvtau {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTAU_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001110010 vn:5 vd:5" "asm"="fcvtau {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTAU_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001110010 vn:5 vd:5" "asm"="fcvtau {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINT32X_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001111010 vn:5 vd:5" "asm"="frint32x {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINT32X_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001111010 vn:5 vd:5" "asm"="frint32x {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINT32X_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001111010 vn:5 vd:5" "asm"="frint32x {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FRINT64X_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001111110 vn:5 vd:5" "asm"="frint64x {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINT64X_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001111110 vn:5 vd:5" "asm"="frint64x {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINT64X_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001111110 vn:5 vd:5" "asm"="frint64x {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @F1CVTL_asimdmisc_V.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111000100001011110 vn:5 vd:5" "asm"="f1cvtl {vd:8h}, {vn:8b}" "asmonly" {
  ret void
}

define void @F1CVTL_asimdmisc_V.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111000100001011110 vn:5 vd:5" "asm"="f1cvtl2 {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @RBIT_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100000010110 vn:5 vd:5" "asm"="rbit {vd:8b}, {vn:8b}" "asmonly" {
  ret void
}

define void @RBIT_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100000010110 vn:5 vd:5" "asm"="rbit {vd:16b}, {vn:16b}" "asmonly" {
  ret void
}

define void @F2CVTL_asimdmisc_V.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111001100001011110 vn:5 vd:5" "asm"="f2cvtl {vd:8h}, {vn:8b}" "asmonly" {
  ret void
}

define void @F2CVTL_asimdmisc_V.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111001100001011110 vn:5 vd:5" "asm"="f2cvtl2 {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @FCMGE_asimdmisc_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000110010 vn:5 vd:5" "asm"="fcmge {vd:2s}, {vn:2s}, #0.0" "asmonly" {
  ret void
}

define void @FCMGE_asimdmisc_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000110010 vn:5 vd:5" "asm"="fcmge {vd:4s}, {vn:4s}, #0.0" "asmonly" {
  ret void
}

define void @FCMGE_asimdmisc_FZ.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000110010 vn:5 vd:5" "asm"="fcmge {vd:2d}, {vn:2d}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asimdmisc_FZ.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100000110110 vn:5 vd:5" "asm"="fcmle {vd:2s}, {vn:2s}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asimdmisc_FZ.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100000110110 vn:5 vd:5" "asm"="fcmle {vd:4s}, {vn:4s}, #0.0" "asmonly" {
  ret void
}

define void @FCMLE_asimdmisc_FZ.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100000110110 vn:5 vd:5" "asm"="fcmle {vd:2d}, {vn:2d}, #0.0" "asmonly" {
  ret void
}

define void @FRINTI_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001100110 vn:5 vd:5" "asm"="frinti {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRINTI_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001100110 vn:5 vd:5" "asm"="frinti {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRINTI_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100001100110 vn:5 vd:5" "asm"="frinti {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FCVTPU_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001101010 vn:5 vd:5" "asm"="fcvtpu {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FCVTPU_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001101010 vn:5 vd:5" "asm"="fcvtpu {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FCVTPU_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100001101010 vn:5 vd:5" "asm"="fcvtpu {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @URSQRTE_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001110010 vn:5 vd:5" "asm"="ursqrte {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @URSQRTE_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001110010 vn:5 vd:5" "asm"="ursqrte {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRSQRTE_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001110110 vn:5 vd:5" "asm"="frsqrte {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FRSQRTE_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001110110 vn:5 vd:5" "asm"="frsqrte {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FRSQRTE_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100001110110 vn:5 vd:5" "asm"="frsqrte {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @FSQRT_asimdmisc_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001111110 vn:5 vd:5" "asm"="fsqrt {vd:2s}, {vn:2s}" "asmonly" {
  ret void
}

define void @FSQRT_asimdmisc_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001111110 vn:5 vd:5" "asm"="fsqrt {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @FSQRT_asimdmisc_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100001111110 vn:5 vd:5" "asm"="fsqrt {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @BF1CVTL_asimdmisc_V.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111010100001011110 vn:5 vd:5" "asm"="bf1cvtl {vd:8h}, {vn:8b}" "asmonly" {
  ret void
}

define void @BF1CVTL_asimdmisc_V.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111010100001011110 vn:5 vd:5" "asm"="bf1cvtl2 {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @BF2CVTL_asimdmisc_V.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0010111011100001011110 vn:5 vd:5" "asm"="bf2cvtl {vd:8h}, {vn:8b}" "asmonly" {
  ret void
}

define void @BF2CVTL_asimdmisc_V.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="0110111011100001011110 vn:5 vd:5" "asm"="bf2cvtl2 {vd:8h}, {vn:16b}" "asmonly" {
  ret void
}

define void @SADDLV_asimdall_only.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0000111000110000001110 vn:5 d:5" "asm"="saddlv {d}, {vn:8b}" "asmonly" {
  ret void
}

define void @SADDLV_asimdall_only.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0100111000110000001110 vn:5 d:5" "asm"="saddlv {d}, {vn:16b}" "asmonly" {
  ret void
}

define void @FMAXNMV_asimdall_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0000111000110000110010 vn:5 d:5" "asm"="fmaxnmv {d}, {vn:4h}" "asmonly" {
  ret void
}

define void @FMAXNMV_asimdall_only_H.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0100111000110000110010 vn:5 d:5" "asm"="fmaxnmv {d}, {vn:8h}" "asmonly" {
  ret void
}

define void @FMAXV_asimdall_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0000111000110000111110 vn:5 d:5" "asm"="fmaxv {d}, {vn:4h}" "asmonly" {
  ret void
}

define void @FMAXV_asimdall_only_H.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0100111000110000111110 vn:5 d:5" "asm"="fmaxv {d}, {vn:8h}" "asmonly" {
  ret void
}

define void @FMINNMV_asimdall_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0000111010110000110010 vn:5 d:5" "asm"="fminnmv {d}, {vn:4h}" "asmonly" {
  ret void
}

define void @FMINNMV_asimdall_only_H.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0100111010110000110010 vn:5 d:5" "asm"="fminnmv {d}, {vn:8h}" "asmonly" {
  ret void
}

define void @FMINV_asimdall_only_H.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0000111010110000111110 vn:5 d:5" "asm"="fminv {d}, {vn:4h}" "asmonly" {
  ret void
}

define void @FMINV_asimdall_only_H.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0100111010110000111110 vn:5 d:5" "asm"="fminv {d}, {vn:8h}" "asmonly" {
  ret void
}

define void @UADDLV_asimdall_only.0(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0010111000110000001110 vn:5 d:5" "asm"="uaddlv {d}, {vn:8b}" "asmonly" {
  ret void
}

define void @UADDLV_asimdall_only.1(i64 "reg"="h" %d, i64 "reg"="q" %vn) "enc"="0110111000110000001110 vn:5 d:5" "asm"="uaddlv {d}, {vn:16b}" "asmonly" {
  ret void
}

define void @FMAXNMV_asimdall_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0110111000110000110010 vn:5 d:5" "asm"="fmaxnmv {d}, {vn:4s}" "asmonly" {
  ret void
}

define void @FMAXV_asimdall_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0110111000110000111110 vn:5 d:5" "asm"="fmaxv {d}, {vn:4s}" "asmonly" {
  ret void
}

define void @FMINNMV_asimdall_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0110111010110000110010 vn:5 d:5" "asm"="fminnmv {d}, {vn:4s}" "asmonly" {
  ret void
}

define void @FMINV_asimdall_only_SD.0(i64 "reg"="s" %d, i64 "reg"="q" %vn) "enc"="0110111010110000111110 vn:5 d:5" "asm"="fminv {d}, {vn:4s}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 000000 vn:5 vd:5" "asm"="saddl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 000000 vn:5 vd:5" "asm"="saddl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 000000 vn:5 vd:5" "asm"="saddl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 000000 vn:5 vd:5" "asm"="saddl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 000000 vn:5 vd:5" "asm"="saddl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SADDL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 000000 vn:5 vd:5" "asm"="saddl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 000100 vn:5 vd:5" "asm"="saddw {vd:8h}, {vn:8h}, {vm:8b}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 000100 vn:5 vd:5" "asm"="saddw {vd:4s}, {vn:4s}, {vm:4h}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 000100 vn:5 vd:5" "asm"="saddw {vd:2d}, {vn:2d}, {vm:2s}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 000100 vn:5 vd:5" "asm"="saddw2 {vd:8h}, {vn:8h}, {vm:16b}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 000100 vn:5 vd:5" "asm"="saddw2 {vd:4s}, {vn:4s}, {vm:8h}" "asmonly" {
  ret void
}

define void @SADDW_asimddiff_W.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 000100 vn:5 vd:5" "asm"="saddw2 {vd:2d}, {vn:2d}, {vm:4s}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 001000 vn:5 vd:5" "asm"="ssubl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 001000 vn:5 vd:5" "asm"="ssubl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 001000 vn:5 vd:5" "asm"="ssubl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 001000 vn:5 vd:5" "asm"="ssubl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 001000 vn:5 vd:5" "asm"="ssubl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SSUBL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 001000 vn:5 vd:5" "asm"="ssubl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 001100 vn:5 vd:5" "asm"="ssubw {vd:8h}, {vn:8h}, {vm:8b}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 001100 vn:5 vd:5" "asm"="ssubw {vd:4s}, {vn:4s}, {vm:4h}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 001100 vn:5 vd:5" "asm"="ssubw {vd:2d}, {vn:2d}, {vm:2s}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 001100 vn:5 vd:5" "asm"="ssubw2 {vd:8h}, {vn:8h}, {vm:16b}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 001100 vn:5 vd:5" "asm"="ssubw2 {vd:4s}, {vn:4s}, {vm:8h}" "asmonly" {
  ret void
}

define void @SSUBW_asimddiff_W.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 001100 vn:5 vd:5" "asm"="ssubw2 {vd:2d}, {vn:2d}, {vm:4s}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 010000 vn:5 vd:5" "asm"="addhn {vd:8b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 010000 vn:5 vd:5" "asm"="addhn {vd:4h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 010000 vn:5 vd:5" "asm"="addhn {vd:2s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 010000 vn:5 vd:5" "asm"="addhn2 {vd:16b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 010000 vn:5 vd:5" "asm"="addhn2 {vd:8h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ADDHN_asimddiff_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 010000 vn:5 vd:5" "asm"="addhn2 {vd:4s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 010100 vn:5 vd:5" "asm"="sabal {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 010100 vn:5 vd:5" "asm"="sabal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 010100 vn:5 vd:5" "asm"="sabal {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 010100 vn:5 vd:5" "asm"="sabal2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 010100 vn:5 vd:5" "asm"="sabal2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SABAL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 010100 vn:5 vd:5" "asm"="sabal2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 011000 vn:5 vd:5" "asm"="subhn {vd:8b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 011000 vn:5 vd:5" "asm"="subhn {vd:4h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 011000 vn:5 vd:5" "asm"="subhn {vd:2s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 011000 vn:5 vd:5" "asm"="subhn2 {vd:16b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 011000 vn:5 vd:5" "asm"="subhn2 {vd:8h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SUBHN_asimddiff_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 011000 vn:5 vd:5" "asm"="subhn2 {vd:4s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 011100 vn:5 vd:5" "asm"="sabdl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 011100 vn:5 vd:5" "asm"="sabdl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 011100 vn:5 vd:5" "asm"="sabdl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 011100 vn:5 vd:5" "asm"="sabdl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 011100 vn:5 vd:5" "asm"="sabdl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SABDL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 011100 vn:5 vd:5" "asm"="sabdl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 100000 vn:5 vd:5" "asm"="smlal {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 100000 vn:5 vd:5" "asm"="smlal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 100000 vn:5 vd:5" "asm"="smlal {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 100000 vn:5 vd:5" "asm"="smlal2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 100000 vn:5 vd:5" "asm"="smlal2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SMLAL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 100000 vn:5 vd:5" "asm"="smlal2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQDMLAL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 100100 vn:5 vd:5" "asm"="sqdmlal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQDMLAL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 100100 vn:5 vd:5" "asm"="sqdmlal {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQDMLAL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 100100 vn:5 vd:5" "asm"="sqdmlal2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQDMLAL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 100100 vn:5 vd:5" "asm"="sqdmlal2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 101000 vn:5 vd:5" "asm"="smlsl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101000 vn:5 vd:5" "asm"="smlsl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 101000 vn:5 vd:5" "asm"="smlsl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 101000 vn:5 vd:5" "asm"="smlsl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101000 vn:5 vd:5" "asm"="smlsl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SMLSL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101000 vn:5 vd:5" "asm"="smlsl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQDMLSL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101100 vn:5 vd:5" "asm"="sqdmlsl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQDMLSL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 101100 vn:5 vd:5" "asm"="sqdmlsl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQDMLSL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101100 vn:5 vd:5" "asm"="sqdmlsl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQDMLSL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101100 vn:5 vd:5" "asm"="sqdmlsl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQDMULL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 110100 vn:5 vd:5" "asm"="sqdmull {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQDMULL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 110100 vn:5 vd:5" "asm"="sqdmull {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQDMULL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 110100 vn:5 vd:5" "asm"="sqdmull2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQDMULL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 110100 vn:5 vd:5" "asm"="sqdmull2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @PMULL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 111000 vn:5 vd:5" "asm"="pmull {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @PMULL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110111 vm:5 111000 vn:5 vd:5" "asm"="pmull {vd:1q}, {vn:1d}, {vm:1d}" "asmonly" {
  ret void
}

define void @PMULL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 111000 vn:5 vd:5" "asm"="pmull2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @PMULL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 111000 vn:5 vd:5" "asm"="pmull2 {vd:1q}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 000000 vn:5 vd:5" "asm"="uaddl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 000000 vn:5 vd:5" "asm"="uaddl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000000 vn:5 vd:5" "asm"="uaddl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 000000 vn:5 vd:5" "asm"="uaddl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 000000 vn:5 vd:5" "asm"="uaddl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UADDL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000000 vn:5 vd:5" "asm"="uaddl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 000100 vn:5 vd:5" "asm"="uaddw {vd:8h}, {vn:8h}, {vm:8b}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 000100 vn:5 vd:5" "asm"="uaddw {vd:4s}, {vn:4s}, {vm:4h}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000100 vn:5 vd:5" "asm"="uaddw {vd:2d}, {vn:2d}, {vm:2s}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 000100 vn:5 vd:5" "asm"="uaddw2 {vd:8h}, {vn:8h}, {vm:16b}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 000100 vn:5 vd:5" "asm"="uaddw2 {vd:4s}, {vn:4s}, {vm:8h}" "asmonly" {
  ret void
}

define void @UADDW_asimddiff_W.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000100 vn:5 vd:5" "asm"="uaddw2 {vd:2d}, {vn:2d}, {vm:4s}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 001000 vn:5 vd:5" "asm"="usubl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 001000 vn:5 vd:5" "asm"="usubl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 001000 vn:5 vd:5" "asm"="usubl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 001000 vn:5 vd:5" "asm"="usubl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 001000 vn:5 vd:5" "asm"="usubl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @USUBL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 001000 vn:5 vd:5" "asm"="usubl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 001100 vn:5 vd:5" "asm"="usubw {vd:8h}, {vn:8h}, {vm:8b}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 001100 vn:5 vd:5" "asm"="usubw {vd:4s}, {vn:4s}, {vm:4h}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 001100 vn:5 vd:5" "asm"="usubw {vd:2d}, {vn:2d}, {vm:2s}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 001100 vn:5 vd:5" "asm"="usubw2 {vd:8h}, {vn:8h}, {vm:16b}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 001100 vn:5 vd:5" "asm"="usubw2 {vd:4s}, {vn:4s}, {vm:8h}" "asmonly" {
  ret void
}

define void @USUBW_asimddiff_W.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 001100 vn:5 vd:5" "asm"="usubw2 {vd:2d}, {vn:2d}, {vm:4s}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 010000 vn:5 vd:5" "asm"="raddhn {vd:8b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 010000 vn:5 vd:5" "asm"="raddhn {vd:4h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 010000 vn:5 vd:5" "asm"="raddhn {vd:2s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 010000 vn:5 vd:5" "asm"="raddhn2 {vd:16b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 010000 vn:5 vd:5" "asm"="raddhn2 {vd:8h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @RADDHN_asimddiff_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 010000 vn:5 vd:5" "asm"="raddhn2 {vd:4s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 010100 vn:5 vd:5" "asm"="uabal {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 010100 vn:5 vd:5" "asm"="uabal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 010100 vn:5 vd:5" "asm"="uabal {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 010100 vn:5 vd:5" "asm"="uabal2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 010100 vn:5 vd:5" "asm"="uabal2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UABAL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 010100 vn:5 vd:5" "asm"="uabal2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 011000 vn:5 vd:5" "asm"="rsubhn {vd:8b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 011000 vn:5 vd:5" "asm"="rsubhn {vd:4h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 011000 vn:5 vd:5" "asm"="rsubhn {vd:2s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 011000 vn:5 vd:5" "asm"="rsubhn2 {vd:16b}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 011000 vn:5 vd:5" "asm"="rsubhn2 {vd:8h}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @RSUBHN_asimddiff_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 011000 vn:5 vd:5" "asm"="rsubhn2 {vd:4s}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 011100 vn:5 vd:5" "asm"="uabdl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 011100 vn:5 vd:5" "asm"="uabdl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 011100 vn:5 vd:5" "asm"="uabdl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 011100 vn:5 vd:5" "asm"="uabdl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 011100 vn:5 vd:5" "asm"="uabdl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UABDL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 011100 vn:5 vd:5" "asm"="uabdl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 100000 vn:5 vd:5" "asm"="umlal {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 100000 vn:5 vd:5" "asm"="umlal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 100000 vn:5 vd:5" "asm"="umlal {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 100000 vn:5 vd:5" "asm"="umlal2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 100000 vn:5 vd:5" "asm"="umlal2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UMLAL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 100000 vn:5 vd:5" "asm"="umlal2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 101000 vn:5 vd:5" "asm"="umlsl {vd:8h}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 101000 vn:5 vd:5" "asm"="umlsl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 101000 vn:5 vd:5" "asm"="umlsl {vd:2d}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 101000 vn:5 vd:5" "asm"="umlsl2 {vd:8h}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 101000 vn:5 vd:5" "asm"="umlsl2 {vd:4s}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UMLSL_asimddiff_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 101000 vn:5 vd:5" "asm"="umlsl2 {vd:2d}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SHADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 000001 vn:5 vd:5" "asm"="shadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQADD_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 000011 vn:5 vd:5" "asm"="sqadd {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SRHADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 000101 vn:5 vd:5" "asm"="srhadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SHSUB_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 001001 vn:5 vd:5" "asm"="shsub {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQSUB_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 001011 vn:5 vd:5" "asm"="sqsub {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 010011 vn:5 vd:5" "asm"="sqshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SRSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 010101 vn:5 vd:5" "asm"="srshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQRSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 010111 vn:5 vd:5" "asm"="sqrshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SABD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 011101 vn:5 vd:5" "asm"="sabd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SABA_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 011111 vn:5 vd:5" "asm"="saba {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @MLA_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 100101 vn:5 vd:5" "asm"="mla {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SMAXP_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101001 vn:5 vd:5" "asm"="smaxp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SMINP_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101011 vn:5 vd:5" "asm"="sminp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQDMULH_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101101 vn:5 vd:5" "asm"="sqdmulh {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQDMULH_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101101 vn:5 vd:5" "asm"="sqdmulh {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQDMULH_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 101101 vn:5 vd:5" "asm"="sqdmulh {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQDMULH_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101101 vn:5 vd:5" "asm"="sqdmulh {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110011 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @ADDP_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 101111 vn:5 vd:5" "asm"="addp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMAXNM_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 110001 vn:5 vd:5" "asm"="fmaxnm {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMAXNM_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 110001 vn:5 vd:5" "asm"="fmaxnm {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMAXNM_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 110001 vn:5 vd:5" "asm"="fmaxnm {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMULX_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 110111 vn:5 vd:5" "asm"="fmulx {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMULX_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 110111 vn:5 vd:5" "asm"="fmulx {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMULX_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 110111 vn:5 vd:5" "asm"="fmulx {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMAX_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 111101 vn:5 vd:5" "asm"="fmax {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMAX_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 111101 vn:5 vd:5" "asm"="fmax {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMAX_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 111101 vn:5 vd:5" "asm"="fmax {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FRECPS_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 111111 vn:5 vd:5" "asm"="frecps {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FRECPS_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 111111 vn:5 vd:5" "asm"="frecps {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FRECPS_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110011 vm:5 111111 vn:5 vd:5" "asm"="frecps {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMLAL_asimdsame_F.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110001 vm:5 111011 vn:5 vd:5" "asm"="fmlal {vd:2s}, {vn:2h}, {vm:2h}" "asmonly" {
  ret void
}

define void @FMLAL_asimdsame_F.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110001 vm:5 111011 vn:5 vd:5" "asm"="fmlal {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMINNM_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 110001 vn:5 vd:5" "asm"="fminnm {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMINNM_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 110001 vn:5 vd:5" "asm"="fminnm {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMINNM_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 110001 vn:5 vd:5" "asm"="fminnm {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMLS_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 110011 vn:5 vd:5" "asm"="fmls {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMLS_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 110011 vn:5 vd:5" "asm"="fmls {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMLS_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 110011 vn:5 vd:5" "asm"="fmls {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FAMAX_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 110111 vn:5 vd:5" "asm"="famax {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FAMAX_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 110111 vn:5 vd:5" "asm"="famax {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FAMAX_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 110111 vn:5 vd:5" "asm"="famax {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMIN_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 111101 vn:5 vd:5" "asm"="fmin {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMIN_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 111101 vn:5 vd:5" "asm"="fmin {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMIN_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 111101 vn:5 vd:5" "asm"="fmin {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FRSQRTS_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 111111 vn:5 vd:5" "asm"="frsqrts {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FRSQRTS_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 111111 vn:5 vd:5" "asm"="frsqrts {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FRSQRTS_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 111111 vn:5 vd:5" "asm"="frsqrts {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMLSL_asimdsame_F.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110101 vm:5 111011 vn:5 vd:5" "asm"="fmlsl {vd:2s}, {vn:2h}, {vm:2h}" "asmonly" {
  ret void
}

define void @FMLSL_asimdsame_F.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110101 vm:5 111011 vn:5 vd:5" "asm"="fmlsl {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @ORN_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00001110111 vm:5 000111 vn:5 vd:5" "asm"="orn {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @ORN_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01001110111 vm:5 000111 vn:5 vd:5" "asm"="orn {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UHADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000001 vn:5 vd:5" "asm"="uhadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQADD_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 000011 vn:5 vd:5" "asm"="uqadd {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @URHADD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000101 vn:5 vd:5" "asm"="urhadd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UHSUB_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 001001 vn:5 vd:5" "asm"="uhsub {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQSUB_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 001011 vn:5 vd:5" "asm"="uqsub {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 010011 vn:5 vd:5" "asm"="uqshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @URSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 010101 vn:5 vd:5" "asm"="urshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UQRSHL_asimdsame_only.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 010111 vn:5 vd:5" "asm"="uqrshl {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UABD_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 011101 vn:5 vd:5" "asm"="uabd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UABA_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 011111 vn:5 vd:5" "asm"="uaba {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @MLS_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 100101 vn:5 vd:5" "asm"="mls {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @PMUL_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 100111 vn:5 vd:5" "asm"="pmul {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @PMUL_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 100111 vn:5 vd:5" "asm"="pmul {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UMAXP_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 101001 vn:5 vd:5" "asm"="umaxp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @UMINP_asimdsame_only.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 101011 vn:5 vd:5" "asm"="uminp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110011 vm:5 101101 vn:5 vd:5" "asm"="sqrdmulh {vd:4h}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 101101 vn:5 vd:5" "asm"="sqrdmulh {vd:8h}, {vn:8h}, {vm:8h}" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 101101 vn:5 vd:5" "asm"="sqrdmulh {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdsame_only.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 101101 vn:5 vd:5" "asm"="sqrdmulh {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMAXNMP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 110001 vn:5 vd:5" "asm"="fmaxnmp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMAXNMP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 110001 vn:5 vd:5" "asm"="fmaxnmp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMAXNMP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 110001 vn:5 vd:5" "asm"="fmaxnmp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FADDP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 110101 vn:5 vd:5" "asm"="faddp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FADDP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 110101 vn:5 vd:5" "asm"="faddp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FADDP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 110101 vn:5 vd:5" "asm"="faddp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FACGE_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 111011 vn:5 vd:5" "asm"="facge {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FACGE_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 111011 vn:5 vd:5" "asm"="facge {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FACGE_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 111011 vn:5 vd:5" "asm"="facge {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMAXP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 111101 vn:5 vd:5" "asm"="fmaxp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMAXP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 111101 vn:5 vd:5" "asm"="fmaxp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMAXP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110011 vm:5 111101 vn:5 vd:5" "asm"="fmaxp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMLAL2_asimdsame_F.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110001 vm:5 110011 vn:5 vd:5" "asm"="fmlal2 {vd:2s}, {vn:2h}, {vm:2h}" "asmonly" {
  ret void
}

define void @FMLAL2_asimdsame_F.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110001 vm:5 110011 vn:5 vd:5" "asm"="fmlal2 {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @FMINNMP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 110001 vn:5 vd:5" "asm"="fminnmp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMINNMP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 110001 vn:5 vd:5" "asm"="fminnmp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMINNMP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 110001 vn:5 vd:5" "asm"="fminnmp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FABD_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 110101 vn:5 vd:5" "asm"="fabd {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FABD_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 110101 vn:5 vd:5" "asm"="fabd {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FABD_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 110101 vn:5 vd:5" "asm"="fabd {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FAMIN_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 110111 vn:5 vd:5" "asm"="famin {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FAMIN_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 110111 vn:5 vd:5" "asm"="famin {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FAMIN_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 110111 vn:5 vd:5" "asm"="famin {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FACGT_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 111011 vn:5 vd:5" "asm"="facgt {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FACGT_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 111011 vn:5 vd:5" "asm"="facgt {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FACGT_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 111011 vn:5 vd:5" "asm"="facgt {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FMINP_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 111101 vn:5 vd:5" "asm"="fminp {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FMINP_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 111101 vn:5 vd:5" "asm"="fminp {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FMINP_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 111101 vn:5 vd:5" "asm"="fminp {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @FSCALE_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 111111 vn:5 vd:5" "asm"="fscale {vd:2s}, {vn:2s}, {vm:2s}" "asmonly" {
  ret void
}

define void @FSCALE_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 111111 vn:5 vd:5" "asm"="fscale {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @FSCALE_asimdsame_only.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 111111 vn:5 vd:5" "asm"="fscale {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @BIT_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 000111 vn:5 vd:5" "asm"="bit {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @BIT_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 000111 vn:5 vd:5" "asm"="bit {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @FMLSL2_asimdsame_F.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110101 vm:5 110011 vn:5 vd:5" "asm"="fmlsl2 {vd:2s}, {vn:2h}, {vm:2h}" "asmonly" {
  ret void
}

define void @FMLSL2_asimdsame_F.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110101 vm:5 110011 vn:5 vd:5" "asm"="fmlsl2 {vd:4s}, {vn:4h}, {vm:4h}" "asmonly" {
  ret void
}

define void @BIF_asimdsame_only.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="00101110111 vm:5 000111 vn:5 vd:5" "asm"="bif {vd:8b}, {vn:8b}, {vm:8b}" "asmonly" {
  ret void
}

define void @BIF_asimdsame_only.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="01101110111 vm:5 000111 vn:5 vd:5" "asm"="bif {vd:16b}, {vn:16b}, {vm:16b}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MOVI_asimdimm_L_sl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 001001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 010001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 011001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.6(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MOVI_asimdimm_L_sl.7(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 001001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.8(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 010001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_sl.9(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 011001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:2s}, #{imm8}" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:2s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @ORR_asimdimm_L_sl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 001101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:2s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 010101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:2s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 011101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:2s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4s}, #{imm8}" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.6(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @ORR_asimdimm_L_sl.7(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 001101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.8(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 010101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_sl.9(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 011101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_hl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4h}, #{imm8}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_hl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MOVI_asimdimm_L_hl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 101001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_hl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:8h}, #{imm8}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_L_hl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:8h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MOVI_asimdimm_L_hl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 101001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:8h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_hl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4h}, #{imm8}" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_hl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @ORR_asimdimm_L_hl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 101101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:4h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_hl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:8h}, #{imm8}" "asmonly" {
  ret void
}

define void @ORR_asimdimm_L_hl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:8h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @ORR_asimdimm_L_hl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 101101 imm82:5=imm8&31 vd:5" "asm"="orr {vd:8h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_M_sm.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 110001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, msl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_M_sm.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 110101 imm82:5=imm8&31 vd:5" "asm"="movi {vd:2s}, #{imm8}, msl #16" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_M_sm.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 110001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, msl #8" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_M_sm.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 110101 imm82:5=imm8&31 vd:5" "asm"="movi {vd:4s}, #{imm8}, msl #16" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_N_b.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0000111100000 imm81:3=(imm8>>5)&7 111001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:8b}, #{imm8}" "asmonly" {
  ret void
}

define void @MOVI_asimdimm_N_b.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0100111100000 imm81:3=(imm8>>5)&7 111001 imm82:5=imm8&31 vd:5" "asm"="movi {vd:16b}, #{imm8}" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MVNI_asimdimm_L_sl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 001001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 010001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 011001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.6(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 000001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MVNI_asimdimm_L_sl.7(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 001001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.8(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 010001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_sl.9(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 011001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:2s}, #{imm8}" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:2s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @BIC_asimdimm_L_sl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 001101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:2s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 010101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:2s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 011101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:2s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4s}, #{imm8}" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.6(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 000101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4s}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @BIC_asimdimm_L_sl.7(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 001101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4s}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.8(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 010101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4s}, #{imm8}, lsl #16" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_sl.9(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 011101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4s}, #{imm8}, lsl #24" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_hl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4h}, #{imm8}" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_hl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MVNI_asimdimm_L_hl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 101001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_hl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:8h}, #{imm8}" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_L_hl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 100001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:8h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @MVNI_asimdimm_L_hl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 101001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:8h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_hl.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4h}, #{imm8}" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_hl.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @BIC_asimdimm_L_hl.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 101101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:4h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_hl.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:8h}, #{imm8}" "asmonly" {
  ret void
}

define void @BIC_asimdimm_L_hl.4(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 100101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:8h}, #{imm8}, lsl #0" "asmonly" "nodecode" {
  ret void
}

define void @BIC_asimdimm_L_hl.5(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 101101 imm82:5=imm8&31 vd:5" "asm"="bic {vd:8h}, #{imm8}, lsl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_M_sm.0(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 110001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, msl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_M_sm.1(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0010111100000 imm81:3=(imm8>>5)&7 110101 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:2s}, #{imm8}, msl #16" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_M_sm.2(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 110001 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, msl #8" "asmonly" {
  ret void
}

define void @MVNI_asimdimm_M_sm.3(i64 "reg"="q" %vd, i64 "imm" %imm8) "enc"="0110111100000 imm81:3=(imm8>>5)&7 110101 imm82:5=imm8&31 vd:5" "asm"="mvni {vd:4s}, #{imm8}, msl #16" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SSRA_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111101 shift_f:6=(64-shift) 000101 vn:5 vd:5" "asm"="ssra {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SRSHR_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111101 shift_f:6=(64-shift) 001001 vn:5 vd:5" "asm"="srshr {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SRSRA_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111101 shift_f:6=(64-shift) 001101 vn:5 vd:5" "asm"="srsra {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift:3 011101 vn:5 vd:5" "asm"="sqshl {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift:3 011101 vn:5 vd:5" "asm"="sqshl {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift:4 011101 vn:5 vd:5" "asm"="sqshl {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift:4 011101 vn:5 vd:5" "asm"="sqshl {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift:5 011101 vn:5 vd:5" "asm"="sqshl {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift:5 011101 vn:5 vd:5" "asm"="sqshl {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHL_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111101 shift:6 011101 vn:5 vd:5" "asm"="sqshl {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 100001 vn:5 vd:5" "asm"="shrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 100001 vn:5 vd:5" "asm"="shrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 100001 vn:5 vd:5" "asm"="shrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 100001 vn:5 vd:5" "asm"="shrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 100001 vn:5 vd:5" "asm"="shrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 100001 vn:5 vd:5" "asm"="shrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 100011 vn:5 vd:5" "asm"="rshrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 100011 vn:5 vd:5" "asm"="rshrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 100011 vn:5 vd:5" "asm"="rshrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 100011 vn:5 vd:5" "asm"="rshrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 100011 vn:5 vd:5" "asm"="rshrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @RSHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 100011 vn:5 vd:5" "asm"="rshrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 100101 vn:5 vd:5" "asm"="sqshrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 100101 vn:5 vd:5" "asm"="sqshrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 100101 vn:5 vd:5" "asm"="sqshrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 100101 vn:5 vd:5" "asm"="sqshrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 100101 vn:5 vd:5" "asm"="sqshrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 100101 vn:5 vd:5" "asm"="sqshrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift_f:3=(8-shift) 100111 vn:5 vd:5" "asm"="sqrshrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift_f:4=(16-shift) 100111 vn:5 vd:5" "asm"="sqrshrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift_f:5=(32-shift) 100111 vn:5 vd:5" "asm"="sqrshrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift_f:3=(8-shift) 100111 vn:5 vd:5" "asm"="sqrshrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift_f:4=(16-shift) 100111 vn:5 vd:5" "asm"="sqrshrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift_f:5=(32-shift) 100111 vn:5 vd:5" "asm"="sqrshrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SSHLL_asimdshf_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0000111100001 shift:3 101001 vn:5 vd:5" "asm"="sshll {vd:8h}, {vn:8b}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SSHLL_asimdshf_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="000011110001 shift:4 101001 vn:5 vd:5" "asm"="sshll {vd:4s}, {vn:4h}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SSHLL_asimdshf_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00001111001 shift:5 101001 vn:5 vd:5" "asm"="sshll {vd:2d}, {vn:2s}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SSHLL_asimdshf_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0100111100001 shift:3 101001 vn:5 vd:5" "asm"="sshll2 {vd:8h}, {vn:16b}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SSHLL_asimdshf_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="010011110001 shift:4 101001 vn:5 vd:5" "asm"="sshll2 {vd:4s}, {vn:8h}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SSHLL_asimdshf_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01001111001 shift:5 101001 vn:5 vd:5" "asm"="sshll2 {vd:2d}, {vn:4s}, #{shift}" "asmonly" "aliases"="sxtl" {
  ret void
}

define void @SCVTF_asimdshf_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="000011110001 fbits_f:4=(16-fbits) 111001 vn:5 vd:5" "asm"="scvtf {vd:4h}, {vn:4h}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_asimdshf_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="010011110001 fbits_f:4=(16-fbits) 111001 vn:5 vd:5" "asm"="scvtf {vd:8h}, {vn:8h}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_asimdshf_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="00001111001 fbits_f:5=(32-fbits) 111001 vn:5 vd:5" "asm"="scvtf {vd:2s}, {vn:2s}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_asimdshf_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="01001111001 fbits_f:5=(32-fbits) 111001 vn:5 vd:5" "asm"="scvtf {vd:4s}, {vn:4s}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_asimdshf_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="0100111101 fbits_f:6=(64-fbits) 111001 vn:5 vd:5" "asm"="scvtf {vd:2d}, {vn:2d}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdshf_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="000011110001 fbits_f:4=(16-fbits) 111111 vn:5 vd:5" "asm"="fcvtzs {vd:4h}, {vn:4h}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdshf_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="010011110001 fbits_f:4=(16-fbits) 111111 vn:5 vd:5" "asm"="fcvtzs {vd:8h}, {vn:8h}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdshf_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="00001111001 fbits_f:5=(32-fbits) 111111 vn:5 vd:5" "asm"="fcvtzs {vd:2s}, {vn:2s}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdshf_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="01001111001 fbits_f:5=(32-fbits) 111111 vn:5 vd:5" "asm"="fcvtzs {vd:4s}, {vn:4s}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_asimdshf_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="0100111101 fbits_f:6=(64-fbits) 111111 vn:5 vd:5" "asm"="fcvtzs {vd:2d}, {vn:2d}, #{fbits}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 000101 vn:5 vd:5" "asm"="usra {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 000101 vn:5 vd:5" "asm"="usra {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 000101 vn:5 vd:5" "asm"="usra {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 000101 vn:5 vd:5" "asm"="usra {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 000101 vn:5 vd:5" "asm"="usra {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 000101 vn:5 vd:5" "asm"="usra {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @USRA_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift_f:6=(64-shift) 000101 vn:5 vd:5" "asm"="usra {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @URSHR_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift_f:6=(64-shift) 001001 vn:5 vd:5" "asm"="urshr {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @URSRA_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift_f:6=(64-shift) 001101 vn:5 vd:5" "asm"="ursra {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 010001 vn:5 vd:5" "asm"="sri {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 010001 vn:5 vd:5" "asm"="sri {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 010001 vn:5 vd:5" "asm"="sri {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 010001 vn:5 vd:5" "asm"="sri {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 010001 vn:5 vd:5" "asm"="sri {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 010001 vn:5 vd:5" "asm"="sri {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SRI_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift_f:6=(64-shift) 010001 vn:5 vd:5" "asm"="sri {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift:3 010101 vn:5 vd:5" "asm"="sli {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift:3 010101 vn:5 vd:5" "asm"="sli {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift:4 010101 vn:5 vd:5" "asm"="sli {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift:4 010101 vn:5 vd:5" "asm"="sli {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift:5 010101 vn:5 vd:5" "asm"="sli {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift:5 010101 vn:5 vd:5" "asm"="sli {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SLI_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift:6 010101 vn:5 vd:5" "asm"="sli {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift:3 011001 vn:5 vd:5" "asm"="sqshlu {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift:3 011001 vn:5 vd:5" "asm"="sqshlu {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift:4 011001 vn:5 vd:5" "asm"="sqshlu {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift:4 011001 vn:5 vd:5" "asm"="sqshlu {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift:5 011001 vn:5 vd:5" "asm"="sqshlu {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift:5 011001 vn:5 vd:5" "asm"="sqshlu {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHLU_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift:6 011001 vn:5 vd:5" "asm"="sqshlu {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift:3 011101 vn:5 vd:5" "asm"="uqshl {vd:8b}, {vn:8b}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift:3 011101 vn:5 vd:5" "asm"="uqshl {vd:16b}, {vn:16b}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift:4 011101 vn:5 vd:5" "asm"="uqshl {vd:4h}, {vn:4h}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift:4 011101 vn:5 vd:5" "asm"="uqshl {vd:8h}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift:5 011101 vn:5 vd:5" "asm"="uqshl {vd:2s}, {vn:2s}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift:5 011101 vn:5 vd:5" "asm"="uqshl {vd:4s}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHL_asimdshf_R.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111101 shift:6 011101 vn:5 vd:5" "asm"="uqshl {vd:2d}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 100001 vn:5 vd:5" "asm"="sqshrun {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 100001 vn:5 vd:5" "asm"="sqshrun {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 100001 vn:5 vd:5" "asm"="sqshrun {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 100001 vn:5 vd:5" "asm"="sqshrun2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 100001 vn:5 vd:5" "asm"="sqshrun2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQSHRUN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 100001 vn:5 vd:5" "asm"="sqshrun2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 100011 vn:5 vd:5" "asm"="sqrshrun {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 100011 vn:5 vd:5" "asm"="sqrshrun {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 100011 vn:5 vd:5" "asm"="sqrshrun {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 100011 vn:5 vd:5" "asm"="sqrshrun2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 100011 vn:5 vd:5" "asm"="sqrshrun2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @SQRSHRUN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 100011 vn:5 vd:5" "asm"="sqrshrun2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 100101 vn:5 vd:5" "asm"="uqshrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 100101 vn:5 vd:5" "asm"="uqshrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 100101 vn:5 vd:5" "asm"="uqshrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 100101 vn:5 vd:5" "asm"="uqshrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 100101 vn:5 vd:5" "asm"="uqshrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @UQSHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 100101 vn:5 vd:5" "asm"="uqshrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift_f:3=(8-shift) 100111 vn:5 vd:5" "asm"="uqrshrn {vd:8b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift_f:4=(16-shift) 100111 vn:5 vd:5" "asm"="uqrshrn {vd:4h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift_f:5=(32-shift) 100111 vn:5 vd:5" "asm"="uqrshrn {vd:2s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift_f:3=(8-shift) 100111 vn:5 vd:5" "asm"="uqrshrn2 {vd:16b}, {vn:8h}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift_f:4=(16-shift) 100111 vn:5 vd:5" "asm"="uqrshrn2 {vd:8h}, {vn:4s}, #{shift}" "asmonly" {
  ret void
}

define void @UQRSHRN_asimdshf_N.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift_f:5=(32-shift) 100111 vn:5 vd:5" "asm"="uqrshrn2 {vd:4s}, {vn:2d}, #{shift}" "asmonly" {
  ret void
}

define void @USHLL_asimdshf_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0010111100001 shift:3 101001 vn:5 vd:5" "asm"="ushll {vd:8h}, {vn:8b}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @USHLL_asimdshf_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="001011110001 shift:4 101001 vn:5 vd:5" "asm"="ushll {vd:4s}, {vn:4h}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @USHLL_asimdshf_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="00101111001 shift:5 101001 vn:5 vd:5" "asm"="ushll {vd:2d}, {vn:2s}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @USHLL_asimdshf_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="0110111100001 shift:3 101001 vn:5 vd:5" "asm"="ushll2 {vd:8h}, {vn:16b}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @USHLL_asimdshf_L.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="011011110001 shift:4 101001 vn:5 vd:5" "asm"="ushll2 {vd:4s}, {vn:8h}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @USHLL_asimdshf_L.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %shift) "enc"="01101111001 shift:5 101001 vn:5 vd:5" "asm"="ushll2 {vd:2d}, {vn:4s}, #{shift}" "asmonly" "aliases"="uxtl" {
  ret void
}

define void @UCVTF_asimdshf_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="001011110001 fbits_f:4=(16-fbits) 111001 vn:5 vd:5" "asm"="ucvtf {vd:4h}, {vn:4h}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_asimdshf_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="011011110001 fbits_f:4=(16-fbits) 111001 vn:5 vd:5" "asm"="ucvtf {vd:8h}, {vn:8h}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_asimdshf_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="00101111001 fbits_f:5=(32-fbits) 111001 vn:5 vd:5" "asm"="ucvtf {vd:2s}, {vn:2s}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_asimdshf_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="01101111001 fbits_f:5=(32-fbits) 111001 vn:5 vd:5" "asm"="ucvtf {vd:4s}, {vn:4s}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_asimdshf_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="0110111101 fbits_f:6=(64-fbits) 111001 vn:5 vd:5" "asm"="ucvtf {vd:2d}, {vn:2d}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdshf_C.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="001011110001 fbits_f:4=(16-fbits) 111111 vn:5 vd:5" "asm"="fcvtzu {vd:4h}, {vn:4h}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdshf_C.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="011011110001 fbits_f:4=(16-fbits) 111111 vn:5 vd:5" "asm"="fcvtzu {vd:8h}, {vn:8h}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdshf_C.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="00101111001 fbits_f:5=(32-fbits) 111111 vn:5 vd:5" "asm"="fcvtzu {vd:2s}, {vn:2s}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdshf_C.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="01101111001 fbits_f:5=(32-fbits) 111111 vn:5 vd:5" "asm"="fcvtzu {vd:4s}, {vn:4s}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_asimdshf_C.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "imm" %fbits) "enc"="0110111101 fbits_f:6=(64-fbits) 111111 vn:5 vd:5" "asm"="fcvtzu {vd:2d}, {vn:2d}, #{fbits}" "asmonly" {
  ret void
}

define void @SMLAL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 0010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smlal {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMLAL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 0010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smlal {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SMLAL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 0010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smlal2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMLAL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 0010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smlal2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLAL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 0011 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmlal {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLAL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 0011 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmlal {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLAL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 0011 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmlal2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLAL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 0011 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmlal2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SMLSL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 0110 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smlsl {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMLSL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 0110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smlsl {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SMLSL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 0110 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smlsl2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMLSL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 0110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smlsl2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLSL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 0111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmlsl {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLSL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 0111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmlsl {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLSL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 0111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmlsl2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMLSL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 0111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmlsl2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @MUL_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 1000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mul {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MUL_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 1000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mul {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MUL_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 1000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mul {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @MUL_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 1000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mul {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SMULL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 1010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smull {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMULL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 1010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smull {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SMULL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 1010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="smull2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SMULL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 1010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="smull2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 1011 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmull {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 1011 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmull {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 1011 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmull2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 1011 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmull2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULH_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 1100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmulh {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULH_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 1100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqdmulh {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULH_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 1100 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmulh {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQDMULH_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 1100 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqdmulh {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmulh {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmulh {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 m:5 1101 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmulh {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMULH_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 m:5 1101 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmulh {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SDOT_asimdelem_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 vm:5 1110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sdot {vd:2s}, {vn:8b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @SDOT_asimdelem_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 vm:5 1110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sdot {vd:4s}, {vn:16b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @FDOT_asimdelem_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111100 index1:1=index&1 vm:5 0000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fdot {vd:2s}, {vn:8b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @FDOT_asimdelem_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111100 index1:1=index&1 vm:5 0000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fdot {vd:4s}, {vn:16b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @FMLA_asimdelem_RH_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111100 index1:2=index&3 vm:4 0001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmla {vd:4h}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLA_asimdelem_RH_H.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111100 index1:2=index&3 vm:4 0001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmla {vd:8h}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLS_asimdelem_RH_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111100 index1:2=index&3 vm:4 0101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmls {vd:4h}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLS_asimdelem_RH_H.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111100 index1:2=index&3 vm:4 0101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmls {vd:8h}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMUL_asimdelem_RH_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmul {vd:4h}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMUL_asimdelem_RH_H.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmul {vd:8h}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @SUDOT_asimdelem_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111100 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sudot {vd:2s}, {vn:8b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @SUDOT_asimdelem_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111100 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sudot {vd:4s}, {vn:16b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @FDOT_asimdelem_G.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111101 index1:2=index&3 vm:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fdot {vd:4h}, {vn:8b}, {vm:2b}[{index}]" "asmonly" {
  ret void
}

define void @FDOT_asimdelem_G.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111101 index1:2=index&3 vm:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fdot {vd:8h}, {vn:16b}, {vm:2b}[{index}]" "asmonly" {
  ret void
}

define void @BFDOT_asimdelem_E.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111101 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="bfdot {vd:2s}, {vn:4h}, {vm:2h}[{index}]" "asmonly" {
  ret void
}

define void @BFDOT_asimdelem_E.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111101 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="bfdot {vd:4s}, {vn:8h}, {vm:2h}[{index}]" "asmonly" {
  ret void
}

define void @FMLA_asimdelem_R_SD.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01001111110 vm:5 0001 index:1 0 vn:5 vd:5" "asm"="fmla {vd:2d}, {vn:2d}, {vm:.d}[{index}]" "asmonly" {
  ret void
}

define void @FMLS_asimdelem_R_SD.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01001111110 vm:5 0101 index:1 0 vn:5 vd:5" "asm"="fmls {vd:2d}, {vn:2d}, {vm:.d}[{index}]" "asmonly" {
  ret void
}

define void @FMUL_asimdelem_R_SD.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01001111110 vm:5 1001 index:1 0 vn:5 vd:5" "asm"="fmul {vd:2d}, {vn:2d}, {vm:.d}[{index}]" "asmonly" {
  ret void
}

define void @FMLAL_asimdelem_LH.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111110 index1:2=index&3 vm:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlal {vd:2s}, {vn:2h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLAL_asimdelem_LH.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111110 index1:2=index&3 vm:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlal {vd:4s}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLSL_asimdelem_LH.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111110 index1:2=index&3 vm:4 0100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlsl {vd:2s}, {vn:2h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLSL_asimdelem_LH.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111110 index1:2=index&3 vm:4 0100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlsl {vd:4s}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @USDOT_asimdelem_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111110 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="usdot {vd:2s}, {vn:8b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @USDOT_asimdelem_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111110 index1:1=index&1 vm:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="usdot {vd:4s}, {vn:16b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @BFMLAL_asimdelem_F.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111111 index1:2=index&3 vm:4 1111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="bfmlalb {vd:4s}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @BFMLAL_asimdelem_F.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111111 index1:2=index&3 vm:4 1111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="bfmlalt {vd:4s}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @MLA_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mla {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MLA_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 0000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mla {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MLA_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 0000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mla {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @MLA_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 0000 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mla {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMLAL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 0010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umlal {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMLAL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 0010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umlal {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMLAL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 0010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umlal2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMLAL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 0010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umlal2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @MLS_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 0100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mls {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MLS_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 0100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="mls {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @MLS_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 0100 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mls {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @MLS_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 0100 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="mls {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMLSL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 0110 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umlsl {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMLSL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 0110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umlsl {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMLSL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 0110 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umlsl2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMLSL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 0110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umlsl2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMULL_asimdelem_L.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 1010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umull {vd:4s}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMULL_asimdelem_L.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 1010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umull {vd:2d}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UMULL_asimdelem_L.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 1010 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="umull2 {vd:4s}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @UMULL_asimdelem_L.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 1010 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="umull2 {vd:2d}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmlah {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 1101 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmlah {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 1101 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmlah {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLAH_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 1101 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmlah {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @UDOT_asimdelem_D.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 vm:5 1110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="udot {vd:2s}, {vn:8b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @UDOT_asimdelem_D.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 vm:5 1110 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="udot {vd:4s}, {vn:16b}, {vm:4b}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdelem_R.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111101 index1:2=index&3 m:4 1111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmlsh {vd:4h}, {vn:4h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdelem_R.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111101 index1:2=index&3 m:4 1111 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="sqrdmlsh {vd:8h}, {vn:8h}, {m:.h}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdelem_R.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0010111110 index1:1=index&1 m:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmlsh {vd:2s}, {vn:2s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @SQRDMLSH_asimdelem_R.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %m, i64 "imm" %index) "enc"="0110111110 index1:1=index&1 m:5 1111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="sqrdmlsh {vd:4s}, {vn:4s}, {m:.s}[{index}]" "asmonly" {
  ret void
}

define void @FMULX_asimdelem_RH_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmulx {vd:4h}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMULX_asimdelem_RH_H.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111100 index1:2=index&3 vm:4 1001 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmulx {vd:8h}, {vn:8h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111101 index:1 vm:5 000100 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:.h}[{index}], #0" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111101 index:1 vm:5 001100 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:.h}[{index}], #90" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.2(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111101 index:1 vm:5 010100 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:.h}[{index}], #180" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.3(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111101 index:1 vm:5 011100 vn:5 vd:5" "asm"="fcmla {vd:4h}, {vn:4h}, {vm:.h}[{index}], #270" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.4(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111101 index1:1=index&1 vm:5 0001 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:.h}[{index}], #0" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.5(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111101 index1:1=index&1 vm:5 0011 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:.h}[{index}], #90" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.6(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111101 index1:1=index&1 vm:5 0101 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:.h}[{index}], #180" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.7(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111101 index1:1=index&1 vm:5 0111 index2:1=(index>>1)&1 0 vn:5 vd:5" "asm"="fcmla {vd:8h}, {vn:8h}, {vm:.h}[{index}], #270" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.8(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101111100 vm:5 0001 index:1 0 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:.s}[{index}], #0" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.9(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101111100 vm:5 0011 index:1 0 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:.s}[{index}], #90" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.10(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101111100 vm:5 0101 index:1 0 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:.s}[{index}], #180" "asmonly" {
  ret void
}

define void @FCMLA_advsimd_elt.11(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101111100 vm:5 0111 index:1 0 vn:5 vd:5" "asm"="fcmla {vd:4s}, {vn:4s}, {vm:.s}[{index}], #270" "asmonly" {
  ret void
}

define void @FMULX_asimdelem_R_SD.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="01101111110 vm:5 1001 index:1 0 vn:5 vd:5" "asm"="fmulx {vd:2d}, {vn:2d}, {vm:.d}[{index}]" "asmonly" {
  ret void
}

define void @FMLAL2_asimdelem_LH.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111110 index1:2=index&3 vm:4 1000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlal2 {vd:2s}, {vn:2h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLAL2_asimdelem_LH.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111110 index1:2=index&3 vm:4 1000 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlal2 {vd:4s}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLSL2_asimdelem_LH.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111110 index1:2=index&3 vm:4 1100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlsl2 {vd:2s}, {vn:2h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLSL2_asimdelem_LH.1(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111110 index1:2=index&3 vm:4 1100 index2:1=(index>>2)&1 0 vn:5 vd:5" "asm"="fmlsl2 {vd:4s}, {vn:4h}, {vm:.h}[{index}]" "asmonly" {
  ret void
}

define void @FMLALB_asimdelem_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0000111111 index1:3=index&7 vm:3 0000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlalb {vd:8h}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @FMLALLBB_asimdelem_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111100 index1:3=index&7 vm:3 1000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlallbb {vd:4s}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @FMLALLBT_asimdelem_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0010111101 index1:3=index&7 vm:3 1000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlallbt {vd:4s}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @FMLALT_asimdelem_H.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0100111111 index1:3=index&7 vm:3 0000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlalt {vd:8h}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @FMLALLTB_asimdelem_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111100 index1:3=index&7 vm:3 1000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlalltb {vd:4s}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @FMLALLTT_asimdelem_J.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %index) "enc"="0110111101 index1:3=index&7 vm:3 1000 index2:1=(index>>3)&1 0 vn:5 vd:5" "asm"="fmlalltt {vd:4s}, {vn:16b}, {vm:.b}[{index}]" "asmonly" {
  ret void
}

define void @SM3TT1A_VVV4_crypto3_imm2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %imm2) "enc"="11001110010 vm:5 10 imm2:2 00 vn:5 vd:5" "asm"="sm3tt1a {vd:4s}, {vn:4s}, {vm:.s}[{imm2}]" "asmonly" {
  ret void
}

define void @SM3TT1B_VVV4_crypto3_imm2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %imm2) "enc"="11001110010 vm:5 10 imm2:2 01 vn:5 vd:5" "asm"="sm3tt1b {vd:4s}, {vn:4s}, {vm:.s}[{imm2}]" "asmonly" {
  ret void
}

define void @SM3TT2A_VVV4_crypto3_imm2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %imm2) "enc"="11001110010 vm:5 10 imm2:2 10 vn:5 vd:5" "asm"="sm3tt2a {vd:4s}, {vn:4s}, {vm:.s}[{imm2}]" "asmonly" {
  ret void
}

define void @SM3TT2B_VVV_crypto3_imm2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %imm2) "enc"="11001110010 vm:5 10 imm2:2 11 vn:5 vd:5" "asm"="sm3tt2b {vd:4s}, {vn:4s}, {vm:.s}[{imm2}]" "asmonly" {
  ret void
}

define void @SHA512H_QQV_cryptosha512_3.0(i64 "reg"="q" %qd, i64 "reg"="q" %qn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 100000 qn:5 qd:5" "asm"="sha512h {qd}, {qn}, {vm:2d}" "asmonly" {
  ret void
}

define void @SHA512H2_QQV_cryptosha512_3.0(i64 "reg"="q" %qd, i64 "reg"="q" %qn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 100001 qn:5 qd:5" "asm"="sha512h2 {qd}, {qn}, {vm:2d}" "asmonly" {
  ret void
}

define void @SHA512SU1_VVV2_cryptosha512_3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 100010 vn:5 vd:5" "asm"="sha512su1 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @RAX1_VVV2_cryptosha512_3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 100011 vn:5 vd:5" "asm"="rax1 {vd:2d}, {vn:2d}, {vm:2d}" "asmonly" {
  ret void
}

define void @SM3PARTW1_VVV4_cryptosha512_3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 110000 vn:5 vd:5" "asm"="sm3partw1 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SM3PARTW2_VVV4_cryptosha512_3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 110001 vn:5 vd:5" "asm"="sm3partw2 {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @SM4EKEY_VVV4_cryptosha512_3.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm) "enc"="11001110011 vm:5 110010 vn:5 vd:5" "asm"="sm4ekey {vd:4s}, {vn:4s}, {vm:4s}" "asmonly" {
  ret void
}

define void @EOR3_VVV16_crypto4.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "reg"="q" %va) "enc"="11001110000 vm:5 0 va:5 vn:5 vd:5" "asm"="eor3 {vd:16b}, {vn:16b}, {vm:16b}, {va:16b}" "asmonly" {
  ret void
}

define void @BCAX_VVV16_crypto4.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "reg"="q" %va) "enc"="11001110001 vm:5 0 va:5 vn:5 vd:5" "asm"="bcax {vd:16b}, {vn:16b}, {vm:16b}, {va:16b}" "asmonly" {
  ret void
}

define void @SM3SS1_VVV4_crypto4.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "reg"="q" %va) "enc"="11001110010 vm:5 0 va:5 vn:5 vd:5" "asm"="sm3ss1 {vd:4s}, {vn:4s}, {vm:4s}, {va:4s}" "asmonly" {
  ret void
}

define void @XAR_VVV2_crypto3_imm6.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn, i64 "reg"="q" %vm, i64 "imm" %imm6) "enc"="11001110100 vm:5 imm6:6 vn:5 vd:5" "asm"="xar {vd:2d}, {vn:2d}, {vm:2d}, #{imm6}" "asmonly" {
  ret void
}

define void @SHA512SU0_VV2_cryptosha512_2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="1100111011000000100000 vn:5 vd:5" "asm"="sha512su0 {vd:2d}, {vn:2d}" "asmonly" {
  ret void
}

define void @SM4E_VV4_cryptosha512_2.0(i64 "reg"="q" %vd, i64 "reg"="q" %vn) "enc"="1100111011000000100001 vn:5 vd:5" "asm"="sm4e {vd:4s}, {vn:4s}" "asmonly" {
  ret void
}

define void @SCVTF_S32_float2fix.0(i64 "reg"="s" %sd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110000000101 fbits_f:5=(32-fbits) wn:5 sd:5" "asm"="scvtf {sd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_S32_float2fix.0(i64 "reg"="s" %sd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110000000111 fbits_f:5=(32-fbits) wn:5 sd:5" "asm"="ucvtf {sd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_32S_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn, i64 "imm" %fbits) "enc"="00011110000110001 fbits_f:5=(32-fbits) sn:5 wd:5" "asm"="fcvtzs {wd}, {sn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_32S_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn, i64 "imm" %fbits) "enc"="00011110000110011 fbits_f:5=(32-fbits) sn:5 wd:5" "asm"="fcvtzu {wd}, {sn}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_D32_float2fix.0(i64 "reg"="d" %dd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110010000101 fbits_f:5=(32-fbits) wn:5 dd:5" "asm"="scvtf {dd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_D32_float2fix.0(i64 "reg"="d" %dd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110010000111 fbits_f:5=(32-fbits) wn:5 dd:5" "asm"="ucvtf {dd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_32D_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn, i64 "imm" %fbits) "enc"="00011110010110001 fbits_f:5=(32-fbits) dn:5 wd:5" "asm"="fcvtzs {wd}, {dn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_32D_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn, i64 "imm" %fbits) "enc"="00011110010110011 fbits_f:5=(32-fbits) dn:5 wd:5" "asm"="fcvtzu {wd}, {dn}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_H32_float2fix.0(i64 "reg"="h" %hd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110110000101 fbits_f:5=(32-fbits) wn:5 hd:5" "asm"="scvtf {hd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_H32_float2fix.0(i64 "reg"="h" %hd, i64 "reg"="w" %wn, i64 "imm" %fbits) "enc"="00011110110000111 fbits_f:5=(32-fbits) wn:5 hd:5" "asm"="ucvtf {hd}, {wn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_32H_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn, i64 "imm" %fbits) "enc"="00011110110110001 fbits_f:5=(32-fbits) hn:5 wd:5" "asm"="fcvtzs {wd}, {hn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_32H_float2fix.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn, i64 "imm" %fbits) "enc"="00011110110110011 fbits_f:5=(32-fbits) hn:5 wd:5" "asm"="fcvtzu {wd}, {hn}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_S64_float2fix.0(i64 "reg"="s" %sd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111000000010 fbits_f:6=(64-fbits) xn:5 sd:5" "asm"="scvtf {sd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_S64_float2fix.0(i64 "reg"="s" %sd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111000000011 fbits_f:6=(64-fbits) xn:5 sd:5" "asm"="ucvtf {sd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_64S_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn, i64 "imm" %fbits) "enc"="1001111000011000 fbits_f:6=(64-fbits) sn:5 xd:5" "asm"="fcvtzs {xd}, {sn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_64S_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn, i64 "imm" %fbits) "enc"="1001111000011001 fbits_f:6=(64-fbits) sn:5 xd:5" "asm"="fcvtzu {xd}, {sn}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_D64_float2fix.0(i64 "reg"="d" %dd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111001000010 fbits_f:6=(64-fbits) xn:5 dd:5" "asm"="scvtf {dd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_D64_float2fix.0(i64 "reg"="d" %dd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111001000011 fbits_f:6=(64-fbits) xn:5 dd:5" "asm"="ucvtf {dd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_64D_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn, i64 "imm" %fbits) "enc"="1001111001011000 fbits_f:6=(64-fbits) dn:5 xd:5" "asm"="fcvtzs {xd}, {dn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_64D_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn, i64 "imm" %fbits) "enc"="1001111001011001 fbits_f:6=(64-fbits) dn:5 xd:5" "asm"="fcvtzu {xd}, {dn}, #{fbits}" "asmonly" {
  ret void
}

define void @SCVTF_H64_float2fix.0(i64 "reg"="h" %hd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111011000010 fbits_f:6=(64-fbits) xn:5 hd:5" "asm"="scvtf {hd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @UCVTF_H64_float2fix.0(i64 "reg"="h" %hd, i64 "reg"="x" %xn, i64 "imm" %fbits) "enc"="1001111011000011 fbits_f:6=(64-fbits) xn:5 hd:5" "asm"="ucvtf {hd}, {xn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZS_64H_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn, i64 "imm" %fbits) "enc"="1001111011011000 fbits_f:6=(64-fbits) hn:5 xd:5" "asm"="fcvtzs {xd}, {hn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTZU_64H_float2fix.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn, i64 "imm" %fbits) "enc"="1001111011011001 fbits_f:6=(64-fbits) hn:5 xd:5" "asm"="fcvtzu {xd}, {hn}, #{fbits}" "asmonly" {
  ret void
}

define void @FCVTNS_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000100000000000 sn:5 wd:5" "asm"="fcvtns {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNU_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000100001000000 sn:5 wd:5" "asm"="fcvtnu {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAS_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000100100000000 sn:5 wd:5" "asm"="fcvtas {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAU_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000100101000000 sn:5 wd:5" "asm"="fcvtau {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPS_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000101000000000 sn:5 wd:5" "asm"="fcvtps {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPU_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000101001000000 sn:5 wd:5" "asm"="fcvtpu {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMS_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000110000000000 sn:5 wd:5" "asm"="fcvtms {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMU_32S_float2int.0(i64 "reg"="w" %wd, i64 "reg"="s" %sn) "enc"="0001111000110001000000 sn:5 wd:5" "asm"="fcvtmu {wd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNS_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001100000000000 dn:5 wd:5" "asm"="fcvtns {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNU_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001100001000000 dn:5 wd:5" "asm"="fcvtnu {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAS_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001100100000000 dn:5 wd:5" "asm"="fcvtas {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAU_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001100101000000 dn:5 wd:5" "asm"="fcvtau {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPS_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001101000000000 dn:5 wd:5" "asm"="fcvtps {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPU_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001101001000000 dn:5 wd:5" "asm"="fcvtpu {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMS_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001110000000000 dn:5 wd:5" "asm"="fcvtms {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMU_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001110001000000 dn:5 wd:5" "asm"="fcvtmu {wd}, {dn}" "asmonly" {
  ret void
}

define void @FJCVTZS_32D_float2int.0(i64 "reg"="w" %wd, i64 "reg"="d" %dn) "enc"="0001111001111110000000 dn:5 wd:5" "asm"="fjcvtzs {wd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNS_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011100000000000 hn:5 wd:5" "asm"="fcvtns {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTNU_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011100001000000 hn:5 wd:5" "asm"="fcvtnu {wd}, {hn}" "asmonly" {
  ret void
}

define void @SCVTF_H32_float2int.0(i64 "reg"="h" %hd, i64 "reg"="w" %wn) "enc"="0001111011100010000000 wn:5 hd:5" "asm"="scvtf {hd}, {wn}" "asmonly" {
  ret void
}

define void @UCVTF_H32_float2int.0(i64 "reg"="h" %hd, i64 "reg"="w" %wn) "enc"="0001111011100011000000 wn:5 hd:5" "asm"="ucvtf {hd}, {wn}" "asmonly" {
  ret void
}

define void @FCVTAS_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011100100000000 hn:5 wd:5" "asm"="fcvtas {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAU_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011100101000000 hn:5 wd:5" "asm"="fcvtau {wd}, {hn}" "asmonly" {
  ret void
}

define void @FMOV_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011100110000000 hn:5 wd:5" "asm"="fmov {wd}, {hn}" "asmonly" {
  ret void
}

define void @FMOV_H32_float2int.0(i64 "reg"="h" %hd, i64 "reg"="w" %wn) "enc"="0001111011100111000000 wn:5 hd:5" "asm"="fmov {hd}, {wn}" "asmonly" {
  ret void
}

define void @FCVTPS_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011101000000000 hn:5 wd:5" "asm"="fcvtps {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPU_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011101001000000 hn:5 wd:5" "asm"="fcvtpu {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMS_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011110000000000 hn:5 wd:5" "asm"="fcvtms {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMU_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011110001000000 hn:5 wd:5" "asm"="fcvtmu {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZS_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011111000000000 hn:5 wd:5" "asm"="fcvtzs {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZU_32H_float2int.0(i64 "reg"="w" %wd, i64 "reg"="h" %hn) "enc"="0001111011111001000000 hn:5 wd:5" "asm"="fcvtzu {wd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTNS_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000100000000000 sn:5 xd:5" "asm"="fcvtns {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNU_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000100001000000 sn:5 xd:5" "asm"="fcvtnu {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAS_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000100100000000 sn:5 xd:5" "asm"="fcvtas {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAU_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000100101000000 sn:5 xd:5" "asm"="fcvtau {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPS_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000101000000000 sn:5 xd:5" "asm"="fcvtps {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPU_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000101001000000 sn:5 xd:5" "asm"="fcvtpu {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMS_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000110000000000 sn:5 xd:5" "asm"="fcvtms {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMU_64S_float2int.0(i64 "reg"="x" %xd, i64 "reg"="s" %sn) "enc"="1001111000110001000000 sn:5 xd:5" "asm"="fcvtmu {xd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNS_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001100000000000 dn:5 xd:5" "asm"="fcvtns {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNU_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001100001000000 dn:5 xd:5" "asm"="fcvtnu {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAS_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001100100000000 dn:5 xd:5" "asm"="fcvtas {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAU_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001100101000000 dn:5 xd:5" "asm"="fcvtau {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPS_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001101000000000 dn:5 xd:5" "asm"="fcvtps {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPU_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001101001000000 dn:5 xd:5" "asm"="fcvtpu {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMS_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001110000000000 dn:5 xd:5" "asm"="fcvtms {xd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMU_64D_float2int.0(i64 "reg"="x" %xd, i64 "reg"="d" %dn) "enc"="1001111001110001000000 dn:5 xd:5" "asm"="fcvtmu {xd}, {dn}" "asmonly" {
  ret void
}

define void @FMOV_64VX_float2int.0(i64 "reg"="x" %xd, i64 "reg"="q" %vn) "enc"="1001111010101110000000 vn:5 xd:5" "asm"="fmov {xd}, {vn:.d}[1]" "asmonly" {
  ret void
}

define void @FMOV_V64I_float2int.0(i64 "reg"="q" %vd, i64 "reg"="x" %xn) "enc"="1001111010101111000000 xn:5 vd:5" "asm"="fmov {vd:.d}[1], {xn}" "asmonly" {
  ret void
}

define void @FCVTNS_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011100000000000 hn:5 xd:5" "asm"="fcvtns {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTNU_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011100001000000 hn:5 xd:5" "asm"="fcvtnu {xd}, {hn}" "asmonly" {
  ret void
}

define void @SCVTF_H64_float2int.0(i64 "reg"="h" %hd, i64 "reg"="x" %xn) "enc"="1001111011100010000000 xn:5 hd:5" "asm"="scvtf {hd}, {xn}" "asmonly" {
  ret void
}

define void @UCVTF_H64_float2int.0(i64 "reg"="h" %hd, i64 "reg"="x" %xn) "enc"="1001111011100011000000 xn:5 hd:5" "asm"="ucvtf {hd}, {xn}" "asmonly" {
  ret void
}

define void @FCVTAS_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011100100000000 hn:5 xd:5" "asm"="fcvtas {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAU_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011100101000000 hn:5 xd:5" "asm"="fcvtau {xd}, {hn}" "asmonly" {
  ret void
}

define void @FMOV_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011100110000000 hn:5 xd:5" "asm"="fmov {xd}, {hn}" "asmonly" {
  ret void
}

define void @FMOV_H64_float2int.0(i64 "reg"="h" %hd, i64 "reg"="x" %xn) "enc"="1001111011100111000000 xn:5 hd:5" "asm"="fmov {hd}, {xn}" "asmonly" {
  ret void
}

define void @FCVTPS_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011101000000000 hn:5 xd:5" "asm"="fcvtps {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPU_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011101001000000 hn:5 xd:5" "asm"="fcvtpu {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMS_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011110000000000 hn:5 xd:5" "asm"="fcvtms {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMU_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011110001000000 hn:5 xd:5" "asm"="fcvtmu {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZS_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011111000000000 hn:5 xd:5" "asm"="fcvtzs {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZU_64H_float2int.0(i64 "reg"="x" %xd, i64 "reg"="h" %hn) "enc"="1001111011111001000000 hn:5 xd:5" "asm"="fcvtzu {xd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTNS_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001101010000000 dn:5 sd:5" "asm"="fcvtns {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAS_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001111010000000 dn:5 sd:5" "asm"="fcvtas {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPS_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110010000000 dn:5 sd:5" "asm"="fcvtps {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMS_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110100000000 dn:5 sd:5" "asm"="fcvtms {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTZS_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110110000000 dn:5 sd:5" "asm"="fcvtzs {sd}, {dn}" "asmonly" {
  ret void
}

define void @SCVTF_sisd_32D.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="0001111001111100000000 sn:5 dd:5" "asm"="scvtf {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNU_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001101011000000 dn:5 sd:5" "asm"="fcvtnu {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTAU_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001111011000000 dn:5 sd:5" "asm"="fcvtau {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTPU_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110011000000 dn:5 sd:5" "asm"="fcvtpu {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTMU_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110101000000 dn:5 sd:5" "asm"="fcvtmu {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTZU_sisd_32D.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="0001111001110111000000 dn:5 sd:5" "asm"="fcvtzu {sd}, {dn}" "asmonly" {
  ret void
}

define void @UCVTF_sisd_32D.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="0001111001111101000000 sn:5 dd:5" "asm"="ucvtf {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNS_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011101010000000 hn:5 sd:5" "asm"="fcvtns {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAS_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011111010000000 hn:5 sd:5" "asm"="fcvtas {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPS_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110010000000 hn:5 sd:5" "asm"="fcvtps {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMS_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110100000000 hn:5 sd:5" "asm"="fcvtms {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZS_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110110000000 hn:5 sd:5" "asm"="fcvtzs {sd}, {hn}" "asmonly" {
  ret void
}

define void @SCVTF_sisd_32H.0(i64 "reg"="h" %hd, i64 "reg"="s" %sn) "enc"="0001111011111100000000 sn:5 hd:5" "asm"="scvtf {hd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNU_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011101011000000 hn:5 sd:5" "asm"="fcvtnu {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAU_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011111011000000 hn:5 sd:5" "asm"="fcvtau {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPU_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110011000000 hn:5 sd:5" "asm"="fcvtpu {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMU_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110101000000 hn:5 sd:5" "asm"="fcvtmu {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZU_sisd_32H.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011110111000000 hn:5 sd:5" "asm"="fcvtzu {sd}, {hn}" "asmonly" {
  ret void
}

define void @UCVTF_sisd_32H.0(i64 "reg"="h" %hd, i64 "reg"="s" %sn) "enc"="0001111011111101000000 sn:5 hd:5" "asm"="ucvtf {hd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTNS_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011101010000000 hn:5 dd:5" "asm"="fcvtns {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAS_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011111010000000 hn:5 dd:5" "asm"="fcvtas {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPS_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110010000000 hn:5 dd:5" "asm"="fcvtps {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMS_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110100000000 hn:5 dd:5" "asm"="fcvtms {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZS_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110110000000 hn:5 dd:5" "asm"="fcvtzs {dd}, {hn}" "asmonly" {
  ret void
}

define void @SCVTF_sisd_64H.0(i64 "reg"="h" %hd, i64 "reg"="d" %dn) "enc"="1001111011111100000000 dn:5 hd:5" "asm"="scvtf {hd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNU_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011101011000000 hn:5 dd:5" "asm"="fcvtnu {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTAU_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011111011000000 hn:5 dd:5" "asm"="fcvtau {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTPU_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110011000000 hn:5 dd:5" "asm"="fcvtpu {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTMU_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110101000000 hn:5 dd:5" "asm"="fcvtmu {dd}, {hn}" "asmonly" {
  ret void
}

define void @FCVTZU_sisd_64H.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="1001111011110111000000 hn:5 dd:5" "asm"="fcvtzu {dd}, {hn}" "asmonly" {
  ret void
}

define void @UCVTF_sisd_64H.0(i64 "reg"="h" %hd, i64 "reg"="d" %dn) "enc"="1001111011111101000000 dn:5 hd:5" "asm"="ucvtf {hd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNS_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000101010000000 sn:5 dd:5" "asm"="fcvtns {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAS_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000111010000000 sn:5 dd:5" "asm"="fcvtas {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPS_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110010000000 sn:5 dd:5" "asm"="fcvtps {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMS_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110100000000 sn:5 dd:5" "asm"="fcvtms {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTZS_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110110000000 sn:5 dd:5" "asm"="fcvtzs {dd}, {sn}" "asmonly" {
  ret void
}

define void @SCVTF_sisd_64S.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="1001111000111100000000 dn:5 sd:5" "asm"="scvtf {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVTNU_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000101011000000 sn:5 dd:5" "asm"="fcvtnu {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTAU_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000111011000000 sn:5 dd:5" "asm"="fcvtau {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTPU_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110011000000 sn:5 dd:5" "asm"="fcvtpu {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTMU_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110101000000 sn:5 dd:5" "asm"="fcvtmu {dd}, {sn}" "asmonly" {
  ret void
}

define void @FCVTZU_sisd_64S.0(i64 "reg"="d" %dd, i64 "reg"="s" %sn) "enc"="1001111000110111000000 sn:5 dd:5" "asm"="fcvtzu {dd}, {sn}" "asmonly" {
  ret void
}

define void @UCVTF_sisd_64S.0(i64 "reg"="s" %sd, i64 "reg"="d" %dn) "enc"="1001111000111101000000 dn:5 sd:5" "asm"="ucvtf {sd}, {dn}" "asmonly" {
  ret void
}

define void @FCVT_HS_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="s" %sn) "enc"="0001111000100011110000 sn:5 hd:5" "asm"="fcvt {hd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTN_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100100010000 sn:5 sd:5" "asm"="frintn {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTP_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100100110000 sn:5 sd:5" "asm"="frintp {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTM_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100101010000 sn:5 sd:5" "asm"="frintm {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTZ_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100101110000 sn:5 sd:5" "asm"="frintz {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTA_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100110010000 sn:5 sd:5" "asm"="frinta {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTX_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100111010000 sn:5 sd:5" "asm"="frintx {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINTI_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000100111110000 sn:5 sd:5" "asm"="frinti {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINT32Z_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000101000010000 sn:5 sd:5" "asm"="frint32z {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINT32X_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000101000110000 sn:5 sd:5" "asm"="frint32x {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINT64Z_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000101001010000 sn:5 sd:5" "asm"="frint64z {sd}, {sn}" "asmonly" {
  ret void
}

define void @FRINT64X_S_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn) "enc"="0001111000101001110000 sn:5 sd:5" "asm"="frint64x {sd}, {sn}" "asmonly" {
  ret void
}

define void @BFCVT_BS_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="s" %sn) "enc"="0001111001100011010000 sn:5 hd:5" "asm"="bfcvt {hd}, {sn}" "asmonly" {
  ret void
}

define void @FCVT_HD_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="d" %dn) "enc"="0001111001100011110000 dn:5 hd:5" "asm"="fcvt {hd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTN_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100100010000 dn:5 dd:5" "asm"="frintn {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTP_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100100110000 dn:5 dd:5" "asm"="frintp {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTM_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100101010000 dn:5 dd:5" "asm"="frintm {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTZ_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100101110000 dn:5 dd:5" "asm"="frintz {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTA_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100110010000 dn:5 dd:5" "asm"="frinta {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTX_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100111010000 dn:5 dd:5" "asm"="frintx {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINTI_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001100111110000 dn:5 dd:5" "asm"="frinti {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINT32Z_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001101000010000 dn:5 dd:5" "asm"="frint32z {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINT32X_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001101000110000 dn:5 dd:5" "asm"="frint32x {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINT64Z_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001101001010000 dn:5 dd:5" "asm"="frint64z {dd}, {dn}" "asmonly" {
  ret void
}

define void @FRINT64X_D_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn) "enc"="0001111001101001110000 dn:5 dd:5" "asm"="frint64x {dd}, {dn}" "asmonly" {
  ret void
}

define void @FMOV_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100000010000 hn:5 hd:5" "asm"="fmov {hd}, {hn}" "asmonly" {
  ret void
}

define void @FABS_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100000110000 hn:5 hd:5" "asm"="fabs {hd}, {hn}" "asmonly" {
  ret void
}

define void @FNEG_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100001010000 hn:5 hd:5" "asm"="fneg {hd}, {hn}" "asmonly" {
  ret void
}

define void @FSQRT_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100001110000 hn:5 hd:5" "asm"="fsqrt {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCVT_SH_floatdp1.0(i64 "reg"="s" %sd, i64 "reg"="h" %hn) "enc"="0001111011100010010000 hn:5 sd:5" "asm"="fcvt {sd}, {hn}" "asmonly" {
  ret void
}

define void @FCVT_DH_floatdp1.0(i64 "reg"="d" %dd, i64 "reg"="h" %hn) "enc"="0001111011100010110000 hn:5 dd:5" "asm"="fcvt {dd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTN_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100100010000 hn:5 hd:5" "asm"="frintn {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTP_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100100110000 hn:5 hd:5" "asm"="frintp {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTM_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100101010000 hn:5 hd:5" "asm"="frintm {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTZ_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100101110000 hn:5 hd:5" "asm"="frintz {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTA_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100110010000 hn:5 hd:5" "asm"="frinta {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTX_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100111010000 hn:5 hd:5" "asm"="frintx {hd}, {hn}" "asmonly" {
  ret void
}

define void @FRINTI_H_floatdp1.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn) "enc"="0001111011100111110000 hn:5 hd:5" "asm"="frinti {hd}, {hn}" "asmonly" {
  ret void
}

define void @FCMPE_S_floatcmp.0(i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 001000 sn:5 10000" "asm"="fcmpe {sn}, {sm}" "asmonly" {
  ret void
}

define void @FCMPE_SZ_floatcmp.0(i64 "reg"="s" %sn) "enc"="0001111000100000001000 sn:5 11000" "asm"="fcmpe {sn}, #0.0" "asmonly" {
  ret void
}

define void @FCMPE_D_floatcmp.0(i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 001000 dn:5 10000" "asm"="fcmpe {dn}, {dm}" "asmonly" {
  ret void
}

define void @FCMPE_DZ_floatcmp.0(i64 "reg"="d" %dn) "enc"="0001111001100000001000 dn:5 11000" "asm"="fcmpe {dn}, #0.0" "asmonly" {
  ret void
}

define void @FCMP_H_floatcmp.0(i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001000 hn:5 00000" "asm"="fcmp {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCMP_HZ_floatcmp.0(i64 "reg"="h" %hn) "enc"="0001111011100000001000 hn:5 01000" "asm"="fcmp {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCMPE_H_floatcmp.0(i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001000 hn:5 10000" "asm"="fcmpe {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCMPE_HZ_floatcmp.0(i64 "reg"="h" %hn) "enc"="0001111011100000001000 hn:5 11000" "asm"="fcmpe {hn}, #0.0" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.0(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 000001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.1(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 000101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.2(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.3(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_S_floatccmp.4(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.5(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_S_floatccmp.6(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 010001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.7(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 010101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.8(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 011001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.9(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 011101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.10(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 100001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.11(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 100101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.12(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 101001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.13(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 101101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.14(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 110001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.15(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 110101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.16(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 111001 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMP_S_floatccmp.17(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 111101 sn:5 0 nzcv:4" "asm"="fccmp {sn}, {sm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.0(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 000001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.1(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 000101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.2(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.3(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_S_floatccmp.4(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.5(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 001101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_S_floatccmp.6(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 010001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.7(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 010101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.8(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 011001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.9(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 011101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.10(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 100001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.11(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 100101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.12(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 101001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.13(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 101101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.14(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 110001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.15(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 110101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.16(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 111001 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMPE_S_floatccmp.17(i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "imm" %nzcv) "enc"="00011110001 sm:5 111101 sn:5 1 nzcv:4" "asm"="fccmpe {sn}, {sm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.0(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 000001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.1(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 000101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.2(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.3(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_D_floatccmp.4(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.5(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_D_floatccmp.6(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 010001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.7(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 010101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.8(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 011001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.9(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 011101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.10(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 100001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.11(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 100101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.12(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 101001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.13(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 101101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.14(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 110001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.15(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 110101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.16(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 111001 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMP_D_floatccmp.17(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 111101 dn:5 0 nzcv:4" "asm"="fccmp {dn}, {dm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.0(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 000001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.1(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 000101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.2(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.3(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_D_floatccmp.4(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.5(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 001101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_D_floatccmp.6(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 010001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.7(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 010101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.8(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 011001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.9(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 011101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.10(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 100001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.11(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 100101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.12(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 101001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.13(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 101101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.14(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 110001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.15(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 110101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.16(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 111001 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMPE_D_floatccmp.17(i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "imm" %nzcv) "enc"="00011110011 dm:5 111101 dn:5 1 nzcv:4" "asm"="fccmpe {dn}, {dm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.0(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 000001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.1(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 000101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.2(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.3(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_H_floatccmp.4(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.5(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMP_H_floatccmp.6(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 010001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.7(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 010101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.8(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 011001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.9(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 011101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.10(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 100001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.11(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 100101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.12(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 101001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.13(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 101101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.14(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 110001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.15(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 110101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.16(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 111001 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMP_H_floatccmp.17(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 111101 hn:5 0 nzcv:4" "asm"="fccmp {hn}, {hm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.0(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 000001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, eq" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.1(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 000101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, ne" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.2(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, cs" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.3(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_H_floatccmp.4(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, cc" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.5(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 001101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCCMPE_H_floatccmp.6(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 010001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, mi" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.7(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 010101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, pl" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.8(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 011001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, vs" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.9(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 011101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, vc" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.10(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 100001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, hi" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.11(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 100101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, ls" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.12(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 101001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, ge" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.13(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 101101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, lt" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.14(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 110001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, gt" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.15(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 110101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, le" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.16(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 111001 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, al" "asmonly" {
  ret void
}

define void @FCCMPE_H_floatccmp.17(i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "imm" %nzcv) "enc"="00011110111 hm:5 111101 hn:5 1 nzcv:4" "asm"="fccmpe {hn}, {hm}, #{nzcv}, nv" "asmonly" {
  ret void
}

define void @FMAX_S_floatdp2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 010010 sn:5 sd:5" "asm"="fmax {sd}, {sn}, {sm}" "asmonly" {
  ret void
}

define void @FMIN_S_floatdp2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 010110 sn:5 sd:5" "asm"="fmin {sd}, {sn}, {sm}" "asmonly" {
  ret void
}

define void @FMAXNM_S_floatdp2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 011010 sn:5 sd:5" "asm"="fmaxnm {sd}, {sn}, {sm}" "asmonly" {
  ret void
}

define void @FMINNM_S_floatdp2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 011110 sn:5 sd:5" "asm"="fminnm {sd}, {sn}, {sm}" "asmonly" {
  ret void
}

define void @FNMUL_S_floatdp2.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm) "enc"="00011110001 sm:5 100010 sn:5 sd:5" "asm"="fnmul {sd}, {sn}, {sm}" "asmonly" {
  ret void
}

define void @FMAX_D_floatdp2.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 010010 dn:5 dd:5" "asm"="fmax {dd}, {dn}, {dm}" "asmonly" {
  ret void
}

define void @FMIN_D_floatdp2.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 010110 dn:5 dd:5" "asm"="fmin {dd}, {dn}, {dm}" "asmonly" {
  ret void
}

define void @FMAXNM_D_floatdp2.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 011010 dn:5 dd:5" "asm"="fmaxnm {dd}, {dn}, {dm}" "asmonly" {
  ret void
}

define void @FMINNM_D_floatdp2.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 011110 dn:5 dd:5" "asm"="fminnm {dd}, {dn}, {dm}" "asmonly" {
  ret void
}

define void @FNMUL_D_floatdp2.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm) "enc"="00011110011 dm:5 100010 dn:5 dd:5" "asm"="fnmul {dd}, {dn}, {dm}" "asmonly" {
  ret void
}

define void @FMUL_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 000010 hn:5 hd:5" "asm"="fmul {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FDIV_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 000110 hn:5 hd:5" "asm"="fdiv {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FADD_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001010 hn:5 hd:5" "asm"="fadd {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FSUB_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001110 hn:5 hd:5" "asm"="fsub {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FMAX_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 010010 hn:5 hd:5" "asm"="fmax {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FMIN_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 010110 hn:5 hd:5" "asm"="fmin {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FMAXNM_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 011010 hn:5 hd:5" "asm"="fmaxnm {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FMINNM_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 011110 hn:5 hd:5" "asm"="fminnm {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FNMUL_H_floatdp2.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 100010 hn:5 hd:5" "asm"="fnmul {hd}, {hn}, {hm}" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 000011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, eq" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.1(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 000111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, ne" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.2(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, cs" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.3(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, hs" "asmonly" "nodecode" {
  ret void
}

define void @FCSEL_H_floatsel.4(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, cc" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.5(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 001111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, lo" "asmonly" "nodecode" {
  ret void
}

define void @FCSEL_H_floatsel.6(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 010011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, mi" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.7(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 010111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, pl" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.8(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 011011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, vs" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.9(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 011111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, vc" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.10(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 100011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, hi" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.11(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 100111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, ls" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.12(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 101011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, ge" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.13(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 101111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, lt" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.14(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 110011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, gt" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.15(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 110111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, le" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.16(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 111011 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, al" "asmonly" {
  ret void
}

define void @FCSEL_H_floatsel.17(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm) "enc"="00011110111 hm:5 111111 hn:5 hd:5" "asm"="fcsel {hd}, {hn}, {hm}, nv" "asmonly" {
  ret void
}

define void @FMSUB_S_floatdp3.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "reg"="s" %sa) "enc"="00011111000 sm:5 1 sa:5 sn:5 sd:5" "asm"="fmsub {sd}, {sn}, {sm}, {sa}" "asmonly" {
  ret void
}

define void @FNMADD_S_floatdp3.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "reg"="s" %sa) "enc"="00011111001 sm:5 0 sa:5 sn:5 sd:5" "asm"="fnmadd {sd}, {sn}, {sm}, {sa}" "asmonly" {
  ret void
}

define void @FNMSUB_S_floatdp3.0(i64 "reg"="s" %sd, i64 "reg"="s" %sn, i64 "reg"="s" %sm, i64 "reg"="s" %sa) "enc"="00011111001 sm:5 1 sa:5 sn:5 sd:5" "asm"="fnmsub {sd}, {sn}, {sm}, {sa}" "asmonly" {
  ret void
}

define void @FMSUB_D_floatdp3.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "reg"="d" %da) "enc"="00011111010 dm:5 1 da:5 dn:5 dd:5" "asm"="fmsub {dd}, {dn}, {dm}, {da}" "asmonly" {
  ret void
}

define void @FNMADD_D_floatdp3.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "reg"="d" %da) "enc"="00011111011 dm:5 0 da:5 dn:5 dd:5" "asm"="fnmadd {dd}, {dn}, {dm}, {da}" "asmonly" {
  ret void
}

define void @FNMSUB_D_floatdp3.0(i64 "reg"="d" %dd, i64 "reg"="d" %dn, i64 "reg"="d" %dm, i64 "reg"="d" %da) "enc"="00011111011 dm:5 1 da:5 dn:5 dd:5" "asm"="fnmsub {dd}, {dn}, {dm}, {da}" "asmonly" {
  ret void
}

define void @FMADD_H_floatdp3.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "reg"="h" %ha) "enc"="00011111110 hm:5 0 ha:5 hn:5 hd:5" "asm"="fmadd {hd}, {hn}, {hm}, {ha}" "asmonly" {
  ret void
}

define void @FMSUB_H_floatdp3.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "reg"="h" %ha) "enc"="00011111110 hm:5 1 ha:5 hn:5 hd:5" "asm"="fmsub {hd}, {hn}, {hm}, {ha}" "asmonly" {
  ret void
}

define void @FNMADD_H_floatdp3.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "reg"="h" %ha) "enc"="00011111111 hm:5 0 ha:5 hn:5 hd:5" "asm"="fnmadd {hd}, {hn}, {hm}, {ha}" "asmonly" {
  ret void
}

define void @FNMSUB_H_floatdp3.0(i64 "reg"="h" %hd, i64 "reg"="h" %hn, i64 "reg"="h" %hm, i64 "reg"="h" %ha) "enc"="00011111111 hm:5 1 ha:5 hn:5 hd:5" "asm"="fnmsub {hd}, {hn}, {hm}, {ha}" "asmonly" {
  ret void
}
