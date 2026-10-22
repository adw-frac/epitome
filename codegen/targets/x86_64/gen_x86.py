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

Usage: gen_x86.py > 80-asm.ll; gen_x86.py vector > 81-vector.ll
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
     ("4", "m.base"), "m.base, 4, 1, m.disp, 0, 1", "", ""),
    ("x", ['i64 "reg"="r64" %m.base', 'i64 "reg"="r64" %m.index', 'i64 "imm" %m.scale', 'i64 "imm" %m.disp'],
     "{m.disp}({m.base},{m.index},{m.scale})", ("m.index", "m.base"), "m.base, m.index, m.scale, m.disp, 0, 1",
     "if(m.index!=4) ", ""),
    ("p", ['ptr "sym" %m.sym'], "{m.sym}(%rip)", ("0", "0"), "16, 4, 1, 0, m.sym, 1", "", ' "reloc"="pc32x"'),
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


# ---------------------------------------------------------------------------
# Vectors. pp: the implied prefix (0 none, 1 66, 2 F3, 3 F2); map: 1 0F,
# 2 0F38, 3 0F3A.

PREFIX = {0: "", 1: "01100110 | ", 2: "11110011 | ", 3: "11110010 | "}
MAPS = {1: "00001111", 2: "00001111 | 00111000", 3: "00001111 | 00111010"}


def mem_parts(rmargs):
    base, index = rmargs.split(", ")[:2]
    return base, index


def sse(name, mn, pp, mp, op, dcls="x", scls="x", w=0, store=False, imm=False, reg_form=True, mem_form=True):
    """A legacy SSE instruction, ModRM.reg the destination (or, `store`,
    the source)."""
    pre, opc = PREFIX[pp], f"{MAPS[mp]} | {bits(op)}"
    tail, ip, ia = (" | ib:8=c", [IMM], "${c}, ") if imm else ("", [], "")
    if store:
        mem(f"{name}Mr", [], [reg(scls, "s")], pre, w, opc, "s", f"{mn} {{s}}, {{M}}")
        return
    if reg_form:
        entry(f"{name}rr", [reg(dcls, "d"), reg(scls, "s")] + ip,
              f"{pre}rex({w}, d, 0, s) | {opc} | rr(d, s){tail}", f"{mn} {ia}{{s}}, {{d}}")
    if mem_form:
        mem(f"{name}rM", [reg(dcls, "d")], ip, pre, w, opc, "d", f"{mn} {ia}{{M}}, {{d}}", tail=tail)


def vex(name, mn, pp, mp, op, w, l, cls, three=True, store=False, scls=None, commute=False, swap=None):
    """A VEX instruction: d, v (vvvv, if `three`), s (ModRM.rm). As
    llvm-mc does, a commutative one (`commute`) whose s needs the
    three-byte prefix and v does not swaps them, and a move (`swap`, its
    store opcode) whose s needs it and d does not uses the store form."""
    scls = scls or cls
    v = "v" if three else "0"
    vp = [reg(cls, "v")] if three else []
    va = "{v}, " if three else ""
    opc = bits(op)
    if store:
        for sfx, params, masm, _, rmargs, guard, reloc in MEMS:
            base, index = mem_parts(rmargs)
            entry(f"{name}{sfx}r", params + [reg(cls, "s")],
                  f"{{ {guard}vexm(s, {base}, {index}, {mp}, {w}, 0, {l}, {pp}) | {opc} | rm(s, {rmargs}) }}",
                  f"{mn} {{s}}, {masm}", reloc)
        return
    plain = f"vex(d, 0, s, {mp}, {w}, {v}, {l}, {pp}) | {opc} | rr(d, s)"
    if commute:
        plain = (f"{{ if(s<8) {plain} ; if(v<8) vex(d, 0, v, {mp}, {w}, s, {l}, {pp}) | {opc} | rr(d, v) ; "
                 f"{plain} }}")
    elif swap is not None:
        plain = (f"{{ if(s<8) {plain} ; if(d<8) vex(s, 0, d, {mp}, {w}, 0, {l}, {pp}) | {bits(swap)} | rr(s, d) ; "
                 f"{plain} }}")
    entry(f"{name}rr", [reg(cls, "d")] + vp + [reg(scls, "s")], plain, f"{mn} {{s}}, {va}{{d}}")
    for sfx, params, masm, _, rmargs, guard, reloc in MEMS:
        base, index = mem_parts(rmargs)
        entry(f"{name}r{sfx}", [reg(cls, "d")] + vp + params,
              f"{{ {guard}vexm(d, {base}, {index}, {mp}, {w}, {v}, {l}, {pp}) | {opc} | rm(d, {rmargs}) }}",
              f"{mn} {masm}, {va}{{d}}", reloc)


def evex(name, mn, pp, mp, op, w, three=True, store=False, n=64, bcast=None, scls="z"):
    """An EVEX instruction on zmm registers: d, v, s; memory operands'
    byte displacements count n bytes; `bcast` (elements, their bytes) adds
    the broadcast form."""
    v = "v" if three else "0"
    vp = [reg("z", "v")] if three else []
    va = "{v}, " if three else ""
    opc = bits(op)

    def forms(bc, nn, suffix, tag):
        for sfx, params, masm, _, rmargs, guard, reloc in MEMS:
            base, index = mem_parts(rmargs)
            rma = rmargs.rsplit(", ", 1)[0] + f", {nn}"
            if store:
                entry(f"{name}{sfx}r", params + [reg("z", "s")],
                      f"{{ {guard}evexm(s, {base}, {index}, {mp}, {w}, 0, 2, {pp}, 0, 0, 0) | {opc} | rm(s, {rma}) }}",
                      f"{mn} {{s}}, {masm}", reloc)
            else:
                entry(f"{name}r{sfx}{tag}", [reg("z", "d")] + vp + params,
                      f"{{ {guard}evexm(d, {base}, {index}, {mp}, {w}, {v}, 2, {pp}, {bc}, 0, 0) | {opc} | rm(d, {rma}) }}",
                      f"{mn} {masm}{suffix}, {va}{{d}}", reloc)

    if not store:
        entry(f"{name}rr", [reg("z", "d")] + vp + [reg(scls, "s")],
              f"evexr(d, s, {mp}, {w}, {v}, 2, {pp}, 0, 0) | {opc} | rr(d, s)", f"{mn} {{s}}, {va}{{d}}")
    forms(0, n, "", "")
    if bcast:
        k, size = bcast
        forms(1, size, f"{{lb}}1to{k}{{rb}}", "b")


def vectors():
    # SSE: arithmetic in four types.
    types = [("ps", 0), ("pd", 1), ("ss", 2), ("sd", 3)]
    for mn, op in [("add", 0x58), ("mul", 0x59), ("sub", 0x5C), ("min", 0x5D), ("div", 0x5E), ("max", 0x5F),
                   ("sqrt", 0x51)]:
        for t, pp in types:
            sse(f"{mn.upper()}{t.upper()}", f"{mn}{t}", pp, 1, op)
    for mn, op in [("and", 0x54), ("andn", 0x55), ("or", 0x56), ("xor", 0x57)]:
        for t, pp in types[:2]:
            sse(f"{mn.upper()}{t.upper()}", f"{mn}{t}", pp, 1, op)
    for mn, pp, load, store in [("movaps", 0, 0x28, 0x29), ("movapd", 1, 0x28, 0x29), ("movups", 0, 0x10, 0x11),
                                ("movupd", 1, 0x10, 0x11), ("movss", 2, 0x10, 0x11), ("movsd", 3, 0x10, 0x11),
                                ("movdqa", 1, 0x6F, 0x7F), ("movdqu", 2, 0x6F, 0x7F)]:
        sse(mn.upper(), mn, pp, 1, load)
        sse(mn.upper(), mn, pp, 1, store, store=True)
    for mn, pp, op in [("ucomiss", 0, 0x2E), ("ucomisd", 1, 0x2E), ("comiss", 0, 0x2F), ("comisd", 1, 0x2F),
                       ("cvtss2sd", 2, 0x5A), ("cvtsd2ss", 3, 0x5A), ("cvtdq2ps", 0, 0x5B), ("cvttps2dq", 2, 0x5B),
                       ("unpcklps", 0, 0x14), ("unpckhps", 0, 0x15)]:
        sse(mn.upper(), mn, pp, 1, op)
    for mn, op in [("paddb", 0xFC), ("paddw", 0xFD), ("paddd", 0xFE), ("paddq", 0xD4), ("psubd", 0xFA),
                   ("psubq", 0xFB), ("pand", 0xDB), ("pandn", 0xDF), ("por", 0xEB), ("pxor", 0xEF),
                   ("pcmpeqd", 0x76), ("pmuludq", 0xF4), ("pmaddwd", 0xF5)]:
        sse(mn.upper(), mn, 1, 1, op)
    for mn, op in [("pmulld", 0x40), ("pshufb", 0x00)]:
        sse(mn.upper(), mn, 1, 2, op)
    sse("SHUFPS", "shufps", 0, 1, 0xC6, imm=True)
    sse("PSHUFD", "pshufd", 1, 1, 0x70, imm=True)
    # Between the files.
    for mn, pp in [("cvtsi2sd", 3), ("cvtsi2ss", 2)]:
        sse(f"{mn.upper()}32", f"{mn}l", pp, 1, 0x2A, "x", "r32")
        sse(f"{mn.upper()}64", f"{mn}q", pp, 1, 0x2A, "x", "r64", w=1)
    for mn, pp in [("cvttsd2si", 3), ("cvttss2si", 2)]:
        sse(f"{mn.upper()}32", mn, pp, 1, 0x2C, "r32", "x", reg_form=True)
        sse(f"{mn.upper()}64", mn, pp, 1, 0x2C, "r64", "x", w=1)
    sse("MOVDxr", "movd", 1, 1, 0x6E, "x", "r32")
    # (A quadword from memory is F3 0F 7E, to memory 66 0F D6.)
    sse("MOVQxr", "movq", 1, 1, 0x6E, "x", "r64", w=1, mem_form=False)
    sse("MOVQx", "movq", 2, 1, 0x7E, reg_form=False)
    sse("MOVQx", "movq", 1, 1, 0xD6, store=True)
    entry("MOVDrx", [reg("r32", "d"), reg("x", "s")], "01100110 | rex(0, s, 0, d) | 00001111 | 01111110 | rr(s, d)",
          "movd {s}, {d}")
    entry("MOVQrx", [reg("r64", "d"), reg("x", "s")], "01100110 | rex(1, s, 0, d) | 00001111 | 01111110 | rr(s, d)",
          "movq {s}, {d}")

    # AVX and AVX2 (VEX), on 128 and 256 bits.
    for mn, op in [("add", 0x58), ("mul", 0x59), ("sub", 0x5C), ("min", 0x5D), ("div", 0x5E), ("max", 0x5F),
                   ("and", 0x54), ("or", 0x56), ("xor", 0x57)]:
        for t, pp in types:
            if t in ("ss", "sd") and mn in ("and", "or", "xor"):
                continue
            for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
                if t in ("ss", "sd") and l == 1:
                    continue
                vex(f"V{mn.upper()}{t.upper()}{L}", f"v{mn}{t}", pp, 1, op, 0, l, cls,
                    commute=mn in ("add", "mul", "and", "or", "xor") and t in ("ps", "pd"))
    for mn, op in [("vpaddd", 0xFE), ("vpaddq", 0xD4), ("vpsubd", 0xFA), ("vpxor", 0xEF), ("vpand", 0xDB),
                   ("vpor", 0xEB), ("vpmaddwd", 0xF5)]:
        for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
            vex(f"{mn.upper()}{L}", mn, 1, 1, op, 0, l, cls, commute=mn != "vpsubd")
    for mn, op in [("vpmulld", 0x40), ("vpshufb", 0x00)]:
        for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
            vex(f"{mn.upper()}{L}", mn, 1, 2, op, 0, l, cls)
    for form, op in [("132", 0x98), ("213", 0xA8), ("231", 0xB8)]:
        for t, w in [("ps", 0), ("pd", 1)]:
            for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
                vex(f"VFMADD{form}{t.upper()}{L}", f"vfmadd{form}{t}", 1, 2, op, w, l, cls)
        for t, w in [("ss", 0), ("sd", 1)]:
            vex(f"VFMADD{form}{t.upper()}", f"vfmadd{form}{t}", 1, 2, op + 1, w, 0, "x")
    for mn, pp, load, store in [("vmovaps", 0, 0x28, 0x29), ("vmovups", 0, 0x10, 0x11), ("vmovapd", 1, 0x28, 0x29),
                                ("vmovupd", 1, 0x10, 0x11), ("vmovdqa", 1, 0x6F, 0x7F), ("vmovdqu", 2, 0x6F, 0x7F)]:
        for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
            vex(f"{mn.upper()}{L}", mn, pp, 1, load, 0, l, cls, three=False, swap=store)
            vex(f"{mn.upper()}{L}", mn, pp, 1, store, 0, l, cls, three=False, store=True)
    for mn, op in [("vbroadcastss", 0x18), ("vpbroadcastd", 0x58)]:
        for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
            vex(f"{mn.upper()}{L}", mn, 1, 2, op, 0, l, cls, three=False, scls="x")
    for l, cls, L in [(0, "x", "128"), (1, "y", "256")]:
        vex(f"VSQRTPS{L}", "vsqrtps", 0, 1, 0x51, 0, l, cls, three=False)
    entry("VZEROUPPER", [], "11000101 | 11111000 | 01110111", "vzeroupper")

    # AVX-512 (EVEX), on 512 bits.
    for mn, op in [("add", 0x58), ("mul", 0x59), ("sub", 0x5C), ("min", 0x5D), ("div", 0x5E), ("max", 0x5F)]:
        evex(f"V{mn.upper()}PSZ", f"v{mn}ps", 0, 1, op, 0, bcast=(16, 4))
        evex(f"V{mn.upper()}PDZ", f"v{mn}pd", 1, 1, op, 1, bcast=(8, 8))
    for form, op in [("132", 0x98), ("213", 0xA8), ("231", 0xB8)]:
        evex(f"VFMADD{form}PSZ", f"vfmadd{form}ps", 1, 2, op, 0, bcast=(16, 4))
        evex(f"VFMADD{form}PDZ", f"vfmadd{form}pd", 1, 2, op, 1, bcast=(8, 8))
    for mn, pp, w, load, store in [("vmovaps", 0, 0, 0x28, 0x29), ("vmovups", 0, 0, 0x10, 0x11),
                                   ("vmovapd", 1, 1, 0x28, 0x29), ("vmovupd", 1, 1, 0x10, 0x11),
                                   ("vmovdqu32", 2, 0, 0x6F, 0x7F), ("vmovdqu64", 2, 1, 0x6F, 0x7F)]:
        evex(f"{mn.upper()}Z", mn, pp, 1, load, w, three=False)
        evex(f"{mn.upper()}Z", mn, pp, 1, store, w, three=False, store=True)
    for mn, w, op in [("vpaddd", 0, 0xFE), ("vpaddq", 1, 0xD4), ("vpsubd", 0, 0xFA), ("vpxord", 0, 0xEF),
                      ("vpxorq", 1, 0xEF), ("vpandd", 0, 0xDB), ("vpord", 0, 0xEB)]:
        evex(f"{mn.upper()}Z", mn, 1, 1, op, w, bcast=(16, 4) if w == 0 else (8, 8))
    # Dot products: VNNI's bytes, and BF16's.
    evex("VPDPBUSDZ", "vpdpbusd", 1, 2, 0x50, 0, bcast=(16, 4))
    evex("VPDPWSSDZ", "vpdpwssd", 1, 2, 0x52, 0, bcast=(16, 4))
    evex("VDPBF16PSZ", "vdpbf16ps", 2, 2, 0x52, 0, bcast=(16, 4))
    evex("VCVTNE2PS2BF16Z", "vcvtne2ps2bf16", 3, 2, 0x72, 0, bcast=(16, 4))
    evex("VBROADCASTSSZ", "vbroadcastss", 1, 2, 0x18, 0, three=False, n=4, scls="xe")


def main():
    out.append("""; x86-64's instructions, for assembly and disassembly ("asmonly").
; Written by gen_x86.py from the opcode tables of the Intel SDM and the AMD
; APM; every entry is checked against llvm-mc. Do not edit: change the
; script.
""")
    if sys.argv[1:] == ["vector"]:
        vectors()
    else:
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
