"""Writes 15-extend.ll: AArch64 add and subtract with an extended register,
sign extension written as a pair of shifts, and the widening multiply-adds.
Encodings from the A64 instruction set's "add/subtract (extended register)"
and "data processing (3 source)" classes."""
out = ["""; The AArch64 description: arithmetic on extended registers, written by
; gen_extend.py. The conventions are in 00-base.ll.
;
; add/sub (extended register): the second operand is a 32-bit (or narrower)
; register, sign- or zero-extended and shifted left by 0 to 4:
;   sf op S 01011 00 1 Rm option imm3 Rn Rd
; with option uxtb 000, uxth 001, uxtw 010, sxtb 100, sxth 101, sxtw 110.
; The first operand and the result may be the stack pointer.
"""]
exts = [("uxtb", "000", "i8", "zext"), ("uxth", "001", "i16", "zext"), ("uxtw", "010", "i32", "zext"),
        ("sxtb", "100", "i8", "sext"), ("sxth", "101", "i16", "sext"), ("sxtw", "110", "i32", "sext")]
for opname, op, irop in [("ADD", "0", "add"), ("SUB", "1", "sub")]:
    for sf, ty, cls, w in [("1", "i64", "x", 64), ("0", "i32", "w", 32)]:
        for ext, opt, src, kind in exts:
            if w == 32 and src == "i32":
                continue  # a w-register extended to 32 bits is itself
            name = f"{opname}{'X' if w == 64 else 'W'}rx_{ext}"
            sp = cls + "sp"
            out.append(f'define {ty} @{name}({ty} "reg"="{sp}" %n, {src} "reg"="w" %m) "enc"="{sf} {op} 0 01011 00 1 m:5 {opt} 000 n:5 d:5" "asm"="{irop} {{d}}, {{n}}, {{m}}, {ext}" "dclass"="{sp}" {{')
            out.append(f"  %e = {kind} {src} %m to {ty}")
            out.append(f"  %r = {irop} {ty} %n, %e")
            out.append(f"  ret {ty} %r\n}}\n")
            out.append(f'define {ty} @{name}s({ty} "reg"="{sp}" %n, {src} "reg"="w" %m, {ty} "imm" %sh) "enc"="{sf} {op} 0 01011 00 1 m:5 {opt} imm3:3=sh%5 n:5 d:5" "asm"="{irop} {{d}}, {{n}}, {{m}}, {ext} #{{sh}}" "dclass"="{sp}" {{')
            out.append(f"  %e = {kind} {src} %m to {ty}")
            out.append(f"  %s = shl {ty} %e, %sh")
            out.append(f"  %r = {irop} {ty} %n, %s")
            out.append(f"  ret {ty} %r\n}}\n")
out.append("""; Sign extension of the low bits, written as a shift left and an arithmetic
; shift right by the same amount: sxtb, sxth and sxtw read the low bits.
""")
for name, ty, cls, sh, enc, asm in [
    ("SXTBWsh", "i32", "w", 24, "0 00 100110 0 000000 000111 n:5 d:5", "sxtb {d}, {n}"),
    ("SXTHWsh", "i32", "w", 16, "0 00 100110 0 000000 001111 n:5 d:5", "sxth {d}, {n}"),
    ("SXTBXsh", "i64", "x", 56, "1 00 100110 1 000000 000111 n:5 d:5", "sxtb {d}, {n:w}"),
    ("SXTHXsh", "i64", "x", 48, "1 00 100110 1 000000 001111 n:5 d:5", "sxth {d}, {n:w}"),
    ("SXTWXsh", "i64", "x", 32, "1 00 100110 1 000000 011111 n:5 d:5", "sxtw {d}, {n:w}"),
]:
    out.append(f'define {ty} @{name}({ty} "reg"="{cls}" %n) "enc"="{enc}" "asm"="{asm}" "nodecode" {{')
    out.append(f"  %a = shl {ty} %n, {sh}")
    out.append(f"  %r = ashr {ty} %a, {sh}")
    out.append(f"  ret {ty} %r\n}}\n")
out.append("""; Widening multiply-add and -subtract: 32-bit operands, extended, multiplied
; into 64 bits, plus or minus a 64-bit addend.
;   1 00 11011 U 01 Rm o0 Ra Rn Rd  (U: unsigned; o0: subtract)
""")
for name, u, o0, kind, op in [("SMADDL", "0", "0", "sext", "add"), ("SMSUBL", "0", "1", "sext", "sub"),
                              ("UMADDL", "1", "0", "zext", "add"), ("UMSUBL", "1", "1", "zext", "sub")]:
    mn = name.lower()
    out.append(f'define i64 @{name}(i32 "reg"="w" %n, i32 "reg"="w" %m, i64 "reg"="x" %a) "enc"="1 00 11011 {u}01 m:5 {o0} a:5 n:5 d:5" "asm"="{mn} {{d}}, {{n}}, {{m}}, {{a}}" {{')
    out.append(f"  %x = {kind} i32 %n to i64")
    out.append(f"  %y = {kind} i32 %m to i64")
    out.append(f"  %p = mul i64 %x, %y")
    out.append(f"  %r = {op} i64 %a, %p")
    out.append(f"  ret i64 %r\n}}\n")
print("\n".join(out))
