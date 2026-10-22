#!/usr/bin/env python3
"""Writes 80-asm.ll: x86-64's integer instructions, for assembly and
disassembly ("asmonly"), from the opcode tables of the Intel SDM and the
AMD APM. The encodings are written with the fragments of 00-base.ll (rex,
rr, rm); every entry is checked against llvm-mc.

Operands: registers `d` (the destination: ModRM.rm, or the register in the
opcode) and `s` (ModRM.reg); an immediate `c`, or `n` for a shift count; a
label `dest`; a symbol `s`; a memory operand the parts `m.base`, `m.index`,
`m.scale`, `m.disp` (or `m.sym`), in one of three forms, each an entry:

    disp(base)                  no index                    ...m
    disp(base,index,scale)      an index (never rsp)        ...x
    sym(%rip)                   a symbol, PC-relative       ...p

Usage: gen_x86.py > 80-asm.ll
"""

import sys

# Operand sizes: suffix -> (class, REX.W, prefix, full immediate, name).
WIDTHS = {
    "q": ("r64", 1, "", "s32", "64"),
    "l": ("r32", 0, "", "s32", "32"),
    "w": ("r16", 0, "01100110 | ", "s16", "16"),
    "b": ("r8", 0, "", "s8", "8"),
}

ALU = ["add", "or", "adc", "sbb", "and", "sub", "xor", "cmp"]
CC = ["o", "no", "b", "ae", "e", "ne", "be", "a", "s", "ns", "p", "np", "l", "ge", "le", "g"]
SHIFTS = {"rol": 0, "ror": 1, "rcl": 2, "rcr": 3, "shl": 4, "shr": 5, "sar": 7}

out = []
names = set()


def bits(v, n=8):
    return format(v, f"0{n}b")


def entry(name, params, enc, asm, extra=""):
    assert name not in names, name
    names.add(name)
    out.append(f'define void @{name}({", ".join(params)}) "enc"="{enc}" "asm"="{asm}" "asmonly"{extra} {{\n'
               f'  ret void\n}}\n')


def reg(cls, n):
    return f'i64 "reg"="{cls}" %{n}'


IMM = 'i64 "imm" %c'
COUNT = 'i64 "imm" %n'
LABEL = 'ptr "label" %dest'
SYM = 'ptr "sym" %s'

# Memory forms: suffix, operands, assembly, rex's x and b, rm's arguments
# after the register, a guard, and the relocation.
MEMS = [
    ("m", ['i64 "reg"="r64" %m.base', 'i64 "imm" %m.disp'], "{m.disp}({m.base})",
     ("4", "m.base"), "m.base, 4, 1, m.disp, 0", "", ""),
    ("x", ['i64 "reg"="r64" %m.base', 'i64 "reg"="r64" %m.index', 'i64 "imm" %m.scale', 'i64 "imm" %m.disp'],
     "{m.disp}({m.base},{m.index},{m.scale})", ("m.index", "m.base"), "m.base, m.index, m.scale, m.disp, 0",
     "if(m.index!=4) ", ""),
    ("p", ['ptr "sym" %m.sym'], "{m.sym}(%rip)", ("0", "0"), "16, 4, 1, 0, m.sym", "", ' "reloc"="pc32x"'),
]


def rex(w, r, x, b, bregs=()):
    """REX: and with byte registers, present whenever one is spl-dil
    (without it, 4-7 are ah-bh)."""
    if bregs and w == 0:
        conds = " ".join(f"if({v}<4)" for v in bregs)
        return f"{{ {conds} rex(0, {r}, {x}, {b}) ; 0100 0 R:1=({r})>>3 X:1=({x})>>3 B:1=({b})>>3 }}"
    return f"rex({w}, {r}, {x}, {b})"


def rr(name, params, pre, w, op, r, b, asm, tail="", bregs=(), extra=""):
    """A register form: ModRM.reg `r`, ModRM.rm the register `b`."""
    entry(name, params, f"{pre}{rex(w, r, 0, b, bregs)} | {op} | rr({r}, {b}){tail}", asm, extra)


def mem(name, before, after, pre, w, op, r, asm, tail="", bregs=()):
    """The memory forms, ModRM.reg `r`; `asm` has `{M}` for the operand."""
    for sfx, params, masm, (x, b), rmargs, guard, reloc in MEMS:
        enc = f"{pre}{rex(w, r, x, b, bregs)} | {op} | rm({r}, {rmargs}){tail}"
        if guard:
            enc = f"{{ {guard}{enc} }}"
        entry(name.replace("M", sfx), before + params + after, enc, asm.replace("{M}", masm), reloc)


def imm_alts(pre, w, op8, op, r, b, immf, bregs=(), short=None):
    """op $c with a sign-extended byte if it fits (op8), else the full
    immediate; `short` is the accumulator's own opcode."""
    alts = []
    if op8:
        alts.append(f"{pre}{rex(w, r, 0, b, bregs)} | {op8} | rr({r}, {b}) | ib:s8=c")
    if short:
        alts.append(f"a:0={b} {pre}{rex(w, 0, 0, 0)} | {short} | iv:{immf}=c")
    alts.append(f"{pre}{rex(w, r, 0, b, bregs)} | {op} | rr({r}, {b}) | iv:{immf}=c")
    return "{ " + " ; ".join(alts) + " }"


def mem_imm(name, pre, w, op8, op, r, asm, immf):
    """op $c, mem: a byte immediate if it fits, else the full one."""
    for sfx, params, masm, (x, b), rmargs, guard, reloc in MEMS:
        alts = []
        for o, f in ([(op8, "ib:s8=c")] if op8 else []) + [(op, f"iv:{immf}=c")]:
            alts.append(f"{guard}{pre}{rex(w, r, x, b)} | {o} | rm({r}, {rmargs}) | {f}")
        entry(name.replace("M", sfx), params + [IMM], "{ " + " ; ".join(alts) + " }",
              asm.replace("{M}", masm), reloc)


def alu():
    for n, mn in enumerate(ALU):
        for sfx, (cls, w, pre, immf, bits_) in WIDTHS.items():
            byte = sfx == "b"
            M = mn.upper() + bits_
            mr, rm_ = bits((n << 3) | (0 if byte else 1)), bits((n << 3) | (2 if byte else 3))
            rr(f"{M}rr", [reg(cls, "d"), reg(cls, "s")], pre, w, mr, "s", "d", f"{mn}{sfx} {{s}}, {{d}}",
               bregs=("s", "d") if byte else ())
            mem(f"{M}rM", [reg(cls, "d")], [], pre, w, rm_, "d", f"{mn}{sfx} {{M}}, {{d}}",
                bregs=("d",) if byte else ())
            mem(f"{M}Mr", [], [reg(cls, "s")], pre, w, mr, "s", f"{mn}{sfx} {{s}}, {{M}}",
                bregs=("s",) if byte else ())
            short = bits((n << 3) | (4 if byte else 5))
            entry(f"{M}ri", [reg(cls, "d"), IMM],
                  imm_alts(pre, w, None if byte else "10000011", "10000000" if byte else "10000001", n, "d",
                           immf, ("d",) if byte else (), short),
                  f"{mn}{sfx} ${{c}}, {{d}}")
            mem_imm(f"{M}Mi", pre, w, None if byte else "10000011", "10000000" if byte else "10000001", n,
                    f"{mn}{sfx} ${{c}}, {{M}}", immf)


def moves():
    for sfx, (cls, w, pre, immf, bits_) in WIDTHS.items():
        byte = sfx == "b"
        M = "MOV" + bits_
        mr, rm_ = ("10001000", "10001010") if byte else ("10001001", "10001011")
        br = ("s", "d") if byte else ()
        rr(f"{M}rr", [reg(cls, "d"), reg(cls, "s")], pre, w, mr, "s", "d", f"mov{sfx} {{s}}, {{d}}", bregs=br)
        mem(f"{M}rM", [reg(cls, "d")], [], pre, w, rm_, "d", f"mov{sfx} {{M}}, {{d}}", bregs=("d",) if byte else ())
        mem(f"{M}Mr", [], [reg(cls, "s")], pre, w, mr, "s", f"mov{sfx} {{s}}, {{M}}", bregs=("s",) if byte else ())
        # mov $c, d: the register in the opcode (B0/B8 +r); for 64 bits,
        # C7 /0 with a sign-extended 32-bit immediate.
        if sfx == "q":
            enc = f"rex(1, 0, 0, d) | 11000111 | rr(0, d) | iv:s32=c"
        elif byte:
            enc = f"{rex(0, 0, 0, 'd', ('d',))} | 10110 o:3=d&7 | ib:s8=c"
        else:
            enc = f"{pre}rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:{immf}=c"
        entry(f"{M}ri", [reg(cls, "d"), IMM], enc, f"mov{sfx} ${{c}}, {{d}}")
        mem_imm(f"{M}Mi", pre, w, None, "11000110" if byte else "11000111", 0, f"mov{sfx} ${{c}}, {{M}}", immf)
    entry("MOVABS64ri", [reg("r64", "d"), 'i64 "imm" %c'], "rex(1, 0, 0, d) | 10111 o:3=d&7 | io:s64=c",
          "movabsq ${c}, {d}")
    # lea: the address, not what is there.
    for sfx in "ql":
        cls, w, pre, _, bits_ = WIDTHS[sfx]
        mem(f"LEA{bits_}rM", [reg(cls, "d")], [], pre, w, "10001101", "d", f"lea{sfx} {{M}}, {{d}}")
    # Widening moves: (mnemonic, destination, source, REX.W, opcode).
    for mn, dsfx, ssfx, op in [("movzb", "l", "b", "10110110"), ("movzb", "w", "b", "10110110"),
                               ("movzb", "q", "b", "10110110"), ("movzw", "l", "w", "10110111"),
                               ("movzw", "q", "w", "10110111"), ("movsb", "l", "b", "10111110"),
                               ("movsb", "w", "b", "10111110"), ("movsb", "q", "b", "10111110"),
                               ("movsw", "l", "w", "10111111"), ("movsw", "q", "w", "10111111")]:
        dcls, w, pre, _, dbits = WIDTHS[dsfx]
        scls = WIDTHS[ssfx][0]
        br = ("s",) if ssfx == "b" else ()
        M = f"{mn.upper()}{dbits}"
        rr(f"{M}rr", [reg(dcls, "d"), reg(scls, "s")], pre, w, f"00001111 | {op}", "d", "s",
           f"{mn}{dsfx} {{s}}, {{d}}", bregs=br)
        mem(f"{M}rM", [reg(dcls, "d")], [], pre, w, f"00001111 | {op}", "d", f"{mn}{dsfx} {{M}}, {{d}}")
    rr("MOVSLQrr", [reg("r64", "d"), reg("r32", "s")], "", 1, "01100011", "d", "s", "movslq {s}, {d}")
    mem("MOVSLQrM", [reg("r64", "d")], [], "", 1, "01100011", "d", "movslq {M}, {d}")


def test():
    for sfx, (cls, w, pre, immf, bits_) in WIDTHS.items():
        byte = sfx == "b"
        M = "TEST" + bits_
        op = "10000100" if byte else "10000101"
        rr(f"{M}rr", [reg(cls, "d"), reg(cls, "s")], pre, w, op, "s", "d", f"test{sfx} {{s}}, {{d}}",
           bregs=("s", "d") if byte else ())
        mem(f"{M}Mr", [], [reg(cls, "s")], pre, w, op, "s", f"test{sfx} {{s}}, {{M}}", bregs=("s",) if byte else ())
        entry(f"{M}ri", [reg(cls, "d"), IMM],
              imm_alts(pre, w, None, "11110110" if byte else "11110111", 0, "d", immf, ("d",) if byte else (),
                       "10101000" if byte else "10101001"),
              f"test{sfx} ${{c}}, {{d}}")
        mem_imm(f"{M}Mi", pre, w, None, "11110110" if byte else "11110111", 0, f"test{sfx} ${{c}}, {{M}}", immf)


def unary():
    # F6/F7 /r and FE/FF /r: one operand.
    ops = [("not", 2, "f7"), ("neg", 3, "f7"), ("mul", 4, "f7"), ("imul", 5, "f7"), ("div", 6, "f7"),
           ("idiv", 7, "f7"), ("inc", 0, "ff"), ("dec", 1, "ff")]
    for mn, r, grp in ops:
        for sfx, (cls, w, pre, immf, bits_) in WIDTHS.items():
            byte = sfx == "b"
            op = {"f7": "11110110" if byte else "11110111", "ff": "11111110" if byte else "11111111"}[grp]
            M = f"{mn.upper()}{bits_}"
            rr(f"{M}r", [reg(cls, "d")], pre, w, op, r, "d", f"{mn}{sfx} {{d}}", bregs=("d",) if byte else ())
            mem(f"{M}M", [], [], pre, w, op, r, f"{mn}{sfx} {{M}}")
    # imul s, d (0F AF), and imul $c, s, d (6B ib or 69 iv).
    for sfx in "qlw":
        cls, w, pre, immf, bits_ = WIDTHS[sfx]
        rr(f"IMUL{bits_}rr", [reg(cls, "d"), reg(cls, "s")], pre, w, "00001111 | 10101111", "d", "s",
           f"imul{sfx} {{s}}, {{d}}")
        mem(f"IMUL{bits_}rM", [reg(cls, "d")], [], pre, w, "00001111 | 10101111", "d", f"imul{sfx} {{M}}, {{d}}")
        entry(f"IMUL{bits_}rri", [reg(cls, "d"), reg(cls, "s"), IMM],
              f"{{ {pre}rex({w}, d, 0, s) | 01101011 | rr(d, s) | ib:s8=c ; "
              f"{pre}rex({w}, d, 0, s) | 01101001 | rr(d, s) | iv:{immf}=c }}",
              f"imul{sfx} ${{c}}, {{s}}, {{d}}")
    # Sign extensions of the accumulator.
    entry("CQTO", [], "01001000 | 10011001", "cqto")
    entry("CLTD", [], "10011001", "cltd")
    entry("CLTQ", [], "01001000 | 10011000", "cltq")
    entry("CWTL", [], "10011000", "cwtl")


def shifts():
    for mn, r in SHIFTS.items():
        for sfx, (cls, w, pre, immf, bits_) in WIDTHS.items():
            byte = sfx == "b"
            br = ("d",) if byte else ()
            M = f"{mn.upper()}{bits_}"
            one, imm, cl = ("11010000", "11000000", "11010010") if byte else ("11010001", "11000001", "11010011")
            # By 1, D1 /r; else C1 /r ib.
            entry(f"{M}ri", [reg(cls, "d"), COUNT],
                  f"{{ {pre}{rex(w, r, 0, 'd', br)} | {one} | rr({r}, d) | z:0=n-1 ; "
                  f"{pre}{rex(w, r, 0, 'd', br)} | {imm} | rr({r}, d) | ib:8=n }}",
                  f"{mn}{sfx} ${{n}}, {{d}}")
            rr(f"{M}rCL", [reg(cls, "d")], pre, w, cl, r, "d", f"{mn}{sfx} %cl, {{d}}", bregs=br)
            for s, params, masm, (x, b), rmargs, guard, reloc in MEMS:
                entry(f"{M}{s}i", params + [COUNT],
                      f"{{ {guard}{pre}{rex(w, r, x, b)} | {one} | rm({r}, {rmargs}) | z:0=n-1 ; "
                      f"{guard}{pre}{rex(w, r, x, b)} | {imm} | rm({r}, {rmargs}) | ib:8=n }}",
                      f"{mn}{sfx} ${{n}}, {masm}", reloc)
            mem(f"{M}MCL", [], [], pre, w, cl, r, f"{mn}{sfx} %cl, {{M}}")


def conditions():
    for k, cc in enumerate(CC):
        C = cc.upper()
        rr(f"SET{C}r", [reg("r8", "d")], "", 0, f"00001111 | {bits(0x90 | k)}", 0, "d", f"set{cc} {{d}}",
           bregs=("d",))
        mem(f"SET{C}M", [], [], "", 0, f"00001111 | {bits(0x90 | k)}", 0, f"set{cc} {{M}}")
        for sfx in "qlw":
            cls, w, pre, _, bits_ = WIDTHS[sfx]
            rr(f"CMOV{C}{bits_}rr", [reg(cls, "d"), reg(cls, "s")], pre, w, f"00001111 | {bits(0x40 | k)}", "d",
               "s", f"cmov{cc}{sfx} {{s}}, {{d}}")
            mem(f"CMOV{C}{bits_}rM", [reg(cls, "d")], [], pre, w, f"00001111 | {bits(0x40 | k)}", "d",
                f"cmov{cc}{sfx} {{M}}, {{d}}")
        entry(f"J{C}", [LABEL],
              f"{{ {bits(0x70 | k)} | rel:s8=dest-end ; 00001111 | {bits(0x80 | k)} | rel:s32=dest-end }}",
              f"j{cc} {{dest}}")


def control():
    entry("JMP", [LABEL], "{ 11101011 | rel:s8=dest-end ; 11101001 | rel:s32=dest-end }", "jmp {dest}")
    entry("CALL", [SYM], "11101000 | rel:s32=s-end", "callq {s}", ' "reloc"="plt32"')
    entry("JMPtail", [SYM], "11101001 | rel:s32=s-end", "jmp {s}", ' "reloc"="plt32" "nodecode"')
    rr("CALLr", [reg("r64", "d")], "", 0, "11111111", 2, "d", "callq *{d}")
    rr("JMPr", [reg("r64", "d")], "", 0, "11111111", 4, "d", "jmpq *{d}")
    mem("CALLM", [], [], "", 0, "11111111", 2, "callq *{M}")
    mem("JMPM", [], [], "", 0, "11111111", 4, "jmpq *{M}")
    entry("RET", [], "11000011", "retq")
    entry("UD2", [], "00001111 | 00001011", "ud2")
    entry("INT3", [], "11001100", "int3")
    entry("NOP", [], "10010000", "nop")
    entry("PUSH64r", [reg("r64", "d")], "rex(0, 0, 0, d) | 01010 o:3=d&7", "pushq {d}")
    entry("POP64r", [reg("r64", "d")], "rex(0, 0, 0, d) | 01011 o:3=d&7", "popq {d}")
    entry("PUSH64i", [IMM], "{ 01101010 | ib:s8=c ; 01101000 | iv:s32=c }", "pushq ${c}")
    mem("PUSH64M", [], [], "", 0, "11111111", 6, "pushq {M}")
    mem("POP64M", [], [], "", 0, "10001111", 0, "popq {M}")


def bit_counts():
    for sfx in "ql":
        cls, w, _, _, bits_ = WIDTHS[sfx]
        entry(f"BSWAP{bits_}r", [reg(cls, "d")], f"rex({w}, 0, 0, d) | 00001111 | 11001 o:3=d&7", f"bswap{sfx} {{d}}")
    for mn, pre, op in [("bsf", "", "10111100"), ("bsr", "", "10111101"), ("popcnt", "11110011 | ", "10111000"),
                        ("lzcnt", "11110011 | ", "10111101"), ("tzcnt", "11110011 | ", "10111100")]:
        for sfx in "qlw":
            cls, w, wpre, _, bits_ = WIDTHS[sfx]
            M = f"{mn.upper()}{bits_}"
            rr(f"{M}rr", [reg(cls, "d"), reg(cls, "s")], wpre + pre, w, f"00001111 | {op}", "d", "s",
               f"{mn}{sfx} {{s}}, {{d}}")
            mem(f"{M}rM", [reg(cls, "d")], [], wpre + pre, w, f"00001111 | {op}", "d", f"{mn}{sfx} {{M}}, {{d}}")


def main():
    out.append("""; x86-64's integer instructions, for assembly and disassembly ("asmonly").
; Written by gen_x86.py from the opcode tables of the Intel SDM and the AMD
; APM; every entry is checked against llvm-mc. Do not edit: change the
; script.
""")
    alu()
    moves()
    test()
    unary()
    shifts()
    conditions()
    control()
    bit_counts()
    sys.stdout.write("\n".join(out))


main()
