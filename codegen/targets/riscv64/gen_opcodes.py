"""Writes 80-asm.ll: entries for assembly and disassembly only, for the RV64
instructions of the extensions below that the rest of the description does
not have.

Two sources, both public or observed:

- riscv-opcodes (RISC-V International, BSD 3-clause): each instruction's
  fixed bits and the fields of its operands (extensions/*, arg_lut.csv).
  It does not give assembly syntax, nor which registers are integer and
  which floating-point. So operands are written in RISC-V's order (rd,
  rs1, rs2, rs3, then immediates; loads `rd, imm(rs1)`, stores
  `rs2, imm(rs1)`, branches `rs1, rs2, label`, atomics `rd, rs2, (rs1)`),
  and immediates as the ISA manual lays them out (the I, S, B, J and U
  forms).
- LLVM's RISC-V assembler, as rustc has it (its riscv64gc-unknown-none-elf
  target, which rustup installs), on lines we write: for each template,
  the register files that it encodes as this instruction are found by
  trying them, and every entry written is one whose words, for every line
  tried, are the assembler's.

Entries are "asmonly": the assembler reads them and the disassembler writes
them, but instruction selection does not use them. Run:

    python3 codegen/targets/riscv64/gen_opcodes.py path/to/riscv-opcodes

The output is checked in; the code generator reads only the .ll files.
"""
import itertools
import os
import re
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))

# The extensions, as riscv-opcodes names their files (rv_ and rv64_ ones).
EXTENSIONS = ["i", "m", "a", "f", "d", "zicsr", "zifencei", "zba", "zbb", "zbs", "zbc", "zbkb", "zbkc", "zbkx",
              "zicond", "zfa", "f_zfa", "d_zfa", "zfh", "zfh_zfa", "zfhmin", "d_zfhmin", "zawrs", "zacas", "zabha",
              "zabha_zacas", "zicbo", "zihintntl", "zimop", "zkn", "zknd", "zkne", "zknh", "zks", "zksed",
              "zksh", "zk", "system", "s", "svinval", "zicntr", "zalasr", "zicfilp", "zicfiss"]
# What the assembler must be told the machine has.
FEATURES = ("+m,+a,+f,+d,+zicsr,+zifencei,+zba,+zbb,+zbs,+zbc,+zbkb,+zbkc,+zbkx,+zicond,+zfa,+zfh,+zawrs,"
            "+zacas,+zabha,+zicbom,+zicboz,+zicbop,+zihintntl,+zimop,+zknd,+zkne,+zknh,+zksed,+zksh,+svinval,"
            "+zicntr,+experimental-zalasr,+experimental-zicfilp,+experimental-zicfiss")
ROUNDING = [("rne", 0), ("rtz", 1), ("rdn", 2), ("rup", 3), ("rmm", 4)]
NOTICE_FILE = "LICENSE"


# ---------------------------------------------------------------------------
# riscv-opcodes


def load(root):
    args = {}
    for line in open(os.path.join(root, "arg_lut.csv")):
        m = re.match(r'"([^"]+)",\s*(\d+),\s*(\d+)', line)
        if m:
            args[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    files = {}
    for ext in EXTENSIONS:
        for prefix in ("rv_", "rv64_"):
            p = os.path.join(root, "extensions", prefix + ext)
            if os.path.exists(p):
                files[prefix + ext] = open(p).read().splitlines()
    insts = {}

    def parse(fields):
        mask = value = 0
        ops = []
        for f in fields:
            m = re.fullmatch(r"(\d+)\.\.(\d+)=(\w+)", f) or re.fullmatch(r"(\d+)()=(\w+)", f)
            if m:
                hi = int(m.group(1))
                lo = int(m.group(2)) if m.group(2) else hi
                v = int(m.group(3), 0)
                for b in range(lo, hi + 1):
                    mask |= 1 << b
                    value |= ((v >> (b - lo)) & 1) << b
            else:
                ops.append(f)
        return mask, value, ops

    pseudo = []
    for name, lines in files.items():
        for line in lines:
            line = line.split("#")[0].strip()
            if not line:
                continue
            parts = line.split()
            if parts[0] == "$import":
                continue
            if parts[0] == "$pseudo_op":
                pseudo.append((name, parts[2], parts[3:]))
                continue
            mask, value, ops = parse(parts[1:])
            insts[parts[0]] = dict(name=parts[0], mask=mask, value=value, ops=ops, pseudo=False, ext=name)
    for ext, mnem, parts in pseudo:
        if mnem in insts:
            continue
        mask, value, ops = parse(parts)
        insts[mnem] = dict(name=mnem, mask=mask, value=value, ops=ops, pseudo=True, ext=ext)
    return insts, args


# ---------------------------------------------------------------------------
# Operands: how each is written and held.

REGS = ("rd", "rs1", "rs2", "rs3")
# Immediates of one field, and whether they are signed.
SIMPLE = {"imm12": True, "imm20": False, "shamtd": False, "shamtw": False, "csr": False, "zimm": False,
          "zimm5": False, "rnum": False, "bs": False, "imm5": False}
# Fields set by the variant (a suffix or a keyword), not by an operand.
VARIANT = {"aq", "rl", "aqrl", "rm", "pred", "succ", "fm"}
XNAMES = ["zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1"] + [f"a{k}" for k in range(8)] + \
    [f"s{k}" for k in range(2, 12)] + [f"t{k}" for k in range(3, 7)]
FNAMES = [f"ft{k}" for k in range(8)] + ["fs0", "fs1"] + [f"fa{k}" for k in range(8)] + \
    [f"fs{k}" for k in range(2, 12)] + [f"ft{k}" for k in range(8, 12)]


class Operand:
    """An operand of a template: a register of file "x" or "f", an
    immediate, or a label; and the tokens of the encoding it fills, by top
    bit."""

    def __init__(self, name, kind, tokens):
        self.name, self.kind, self.tokens = name, kind, tokens

    def text(self, v):
        if self.kind == "x":
            return XNAMES[v]
        if self.kind == "f":
            return FNAMES[v]
        if self.kind == "label":
            return f".{'+' if v >= 0 else ''}{v}"
        return str(v)


def operands(ins, args, files):
    """The operands of an instruction, with register files `files` for its
    registers in order; None if it has an argument we cannot write."""
    out = []
    ops = ins["ops"]
    k = 0
    for r in REGS:
        if r in ops:
            hi, lo = args[r]
            out.append(Operand(r, files[k], {hi: (f"{r}:5", hi - lo + 1)}))
            k += 1
    s = set(ops)
    if {"bimm12hi", "bimm12lo"} <= s:
        out.append(Operand("dest", "label", {31: ("o_12:s1=dest>>12", 1), 30: ("o_10:6=(dest>>5)&63", 6),
                                             11: ("o_4:4=(dest>>1)&15", 4), 7: ("o_11:1=(dest>>11)&1", 1)}))
    elif "jimm20" in s:
        out.append(Operand("dest", "label", {31: ("o_20:s1=dest>>20", 1), 30: ("o_10:10=(dest>>1)&1023", 10),
                                             20: ("o_11:1=(dest>>11)&1", 1), 19: ("o_19:8=(dest>>12)&255", 8)}))
    elif {"imm12hi", "imm12lo"} <= s:
        out.append(Operand("off", "imm", {31: ("o_hi:s7=off>>5", 7), 11: ("o_lo:5=off&31", 5)}))
    for f, signed in SIMPLE.items():
        if f in s:
            hi, lo = args[f]
            out.append(Operand(f, "imm", {hi: (f"{f}:{'s' if signed else ''}{hi - lo + 1}", hi - lo + 1)}))
    known = set(REGS) | set(SIMPLE) | VARIANT | {"bimm12hi", "bimm12lo", "jimm20", "imm12hi", "imm12lo"}
    if s - known:
        return None
    return out


def variants(ins):
    """The suffixes and keyword operands an instruction is written with."""
    ops = set(ins["ops"])
    sfx = [""]
    if "aq" in ops or "aqrl" in ops:
        sfx = ["", ".aq", ".rl", ".aqrl"]
    tail = [""]
    if "rm" in ops:
        tail = [""] + [f", {r}" for r, _ in ROUNDING] + [", dyn"]
    if "pred" in ops:
        sets = ["iorw", "rw", "r", "w"]
        return [(sfx_, f" {p}, {q}") for sfx_ in sfx for p in sets for q in sets]
    return [(a, b) for a in sfx for b in tail]


def template(ins, ops, suffix, tail):
    """The assembly of an instruction, by RISC-V's operand order; `{name}`
    for operands. Its sample line with `values` substituted."""
    m = ins["name"] + suffix
    by = {o.name: o for o in ops}
    regs = [o for o in ops if o.kind in "xf"]
    imms = [o for o in ops if o.kind in ("imm", "label")]
    names = [o.name for o in regs]
    opcode = (ins["value"] >> 2) & 31
    if "off" in by and "rs1" in by and "rs2" in by:
        body = "{rs2}, {off}({rs1})"
    elif "dest" in by and "rs1" in by and "rs2" in by:
        body = "{rs1}, {rs2}, {dest}"
    elif "imm12" in by and "rs1" in by and "rd" in by and (opcode in (0, 1) or ins["name"] == "jalr"):
        body = "{rd}, {imm12}({rs1})"
    elif (opcode == 0x0B or ins["name"].startswith("cbo.")) and "rs1" in by:
        body = ", ".join(["{" + n + "}" for n in names if n not in ("rs1",)] + ["({rs1})"])
    elif "csr" in by:
        body = ", ".join(["{rd}", "{csr}"] + ["{" + o.name + "}" for o in ops if o.name not in ("rd", "csr")])
    else:
        body = ", ".join(["{" + o.name + "}" for o in regs + imms])
    text = (m + " " + body).strip() + tail
    return text if body else m + tail


def fill(text, ops, values):
    out = text
    for o, v in zip(ops, values):
        out = out.replace("{" + o.name + "}", o.text(v))
    return out


def encode(toks, ops, values):
    """Our encoding of an entry's tokens, for values of its operands."""
    env = {o.name: v for o, v in zip(ops, values)}
    word = 0
    pos = 32
    for t in toks:
        if re.fullmatch(r"[01]+", t):
            for ch in t:
                pos -= 1
                word |= (ch == "1") << pos
            continue
        m = re.fullmatch(r"([A-Za-z0-9_]+):(s?)(\d+)(?:=(.*))?", t)
        width = int(m.group(3))
        pos -= width
        v = eval(m.group(4) or m.group(1), {}, dict(env))
        word |= (v & ((1 << width) - 1)) << pos
    return word


def tokens(ins, ops, base):
    """The encoding: fixed bits, operands' fields, and the variant's bits
    from the base word."""
    owned = {}
    for o in ops:
        for top, (tok, width) in o.tokens.items():
            owned[top] = (tok, width)
    toks = []
    b = 31
    while b >= 0:
        if b in owned:
            tok, width = owned[b]
            toks.append(tok)
            b -= width
            continue
        bit = str(base >> b & 1)
        if toks and re.fullmatch(r"[01]+", toks[-1]):
            toks[-1] += bit
        else:
            toks.append(bit)
        b -= 1
    return toks


# Values tried for each operand kind: registers, immediates, labels.
SAMPLES = {"x": [1, 5, 10, 31, 0], "f": [1, 5, 10, 31, 0],
           "imm": [1, 0, 3, 31, 63, 100, 2047, -1, -2048, 4095, 0xfffff, 1000],
           "label": [8, 0, -8, 2048, -4096, 4094, 1048574, -1048576]}


# ---------------------------------------------------------------------------
# The assembler: rustc's.

CACHE = {}


def assemble(lines):
    """The assembler's word for each line, or None where it refuses one."""
    todo = sorted({l for l in lines if l not in CACHE})
    for part in range(0, len(todo), 20000):
        chunk = todo[part:part + 20000]
        while chunk:
            words, bad = run(chunk)
            if words is not None:
                CACHE.update(zip(chunk, words))
                break
            for k in bad:
                CACHE[chunk[k]] = None
            chunk = [l for k, l in enumerate(chunk) if k not in bad]
    return [CACHE.get(l) for l in lines]


def run(lines):
    """Assembles lines, each under a label of its own: each one's word, by
    its label (None for a line that is not one instruction); or the lines
    the assembler refused."""
    with tempfile.TemporaryDirectory() as tmp:
        with open(os.path.join(tmp, "t.s"), "w") as f:
            f.write(".option norvc\n.option norelax\n" + "".join(f"l{k}: {l}\n" for k, l in enumerate(lines))
                    + f"l{len(lines)}:\n")
        with open(os.path.join(tmp, "t.rs"), "w") as f:
            f.write('#![no_std]\ncore::arch::global_asm!(include_str!("t.s"), options(raw));\n')
        obj = os.path.join(tmp, "t.o")
        r = subprocess.run(["rustc", "--target", "riscv64gc-unknown-none-elf", "--crate-type", "lib", "--emit", "obj",
                            "-C", f"target-feature={FEATURES}", "-o", obj, os.path.join(tmp, "t.rs")],
                           capture_output=True, text=True)
        if r.returncode != 0:
            bad = {int(m.group(1)) - 3 for m in re.finditer(r"<inline asm>:(\d+):", r.stderr)}
            if not bad:
                sys.exit(r.stderr[:3000])
            return None, bad
        b = open(obj, "rb").read()
        text, at = elf_text(b), elf_labels(b)
        out = []
        for k in range(len(lines)):
            a, z = at.get(f"l{k}"), at.get(f"l{k + 1}")
            out.append(struct.unpack_from("<I", text, a)[0] if a is not None and z == a + 4 else None)
        return out, set()


def elf_labels(b):
    """The values of the object's symbols, by name."""
    shoff, = struct.unpack_from("<Q", b, 0x28)
    shentsize, shnum, _ = struct.unpack_from("<HHH", b, 0x3A)
    secs = [struct.unpack_from("<IIQQQQIIQQ", b, shoff + k * shentsize) for k in range(shnum)]
    out = {}
    for s in secs:
        if s[1] != 2:  # SHT_SYMTAB
            continue
        strtab = secs[s[6]]
        for k in range(s[5] // 24):
            name, _, _, _, value, _ = struct.unpack_from("<IBBHQQ", b, s[4] + 24 * k)
            n = b[strtab[4] + name:].split(b"\0")[0].decode()
            out[n] = value
    return out


def elf_text(b):
    shoff, = struct.unpack_from("<Q", b, 0x28)
    shentsize, shnum, shstrndx = struct.unpack_from("<HHH", b, 0x3A)
    secs = [struct.unpack_from("<IIQQQQIIQQ", b, shoff + k * shentsize) for k in range(shnum)]
    strtab = secs[shstrndx]
    for s in secs:
        name = b[strtab[4] + s[0]:].split(b"\0")[0]
        if name == b".text":
            return b[s[4]:s[4] + s[5]]
    return b""


# ---------------------------------------------------------------------------
# Main


def existing():
    """The description's own entries (not this file's): literal bits."""
    out = []
    for path in sorted(os.listdir(HERE)):
        if not path.endswith(".ll") or path == "80-asm.ll":
            continue
        for line in open(os.path.join(HERE, path)):
            m = re.match(r'define .*?@([A-Za-z0-9_.]+)\(.*?"enc"="([^"]*)"', line)
            if not m:
                continue
            mask = value = 0
            pos = 32
            for tok in m.group(2).split():
                if re.fullmatch(r"[01]+", tok):
                    for ch in tok:
                        pos -= 1
                        mask |= 1 << pos
                        value |= (ch == "1") << pos
                else:
                    pos -= int(re.match(r"[A-Za-z0-9_]+:s?(\d+)", tok).group(1))
            out.append((mask, value))
    return out


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    root = sys.argv[1]
    insts, args = load(root)
    stats = {}

    def count(k):
        stats[k] = stats.get(k, 0) + 1

    # 1. For each instruction and variant: the register files the assembler
    #    encodes as it, from a base line of each choice.
    tries = []
    for ins in insts.values():
        # Written without operands, if its operands are fields that must be
        # zero (fence.i's rd, rs1 and imm12).
        if ins["ops"] and operands(ins, args, "x" * 4) is not None:
            for suffix, tail in variants(ins):
                text = template(ins, [], suffix, tail)
                tries.append((ins, [], text, [], text))
        nregs = sum(r in ins["ops"] for r in REGS)
        for files in itertools.product("xf", repeat=nregs):
            ops = operands(ins, args, files)
            if ops is None:
                count("an operand we cannot write")
                break
            for suffix, tail in variants(ins):
                text = template(ins, ops, suffix, tail)
                base = [SAMPLES[o.kind][0] for o in ops]
                tries.append((ins, ops, text, base, fill(text, ops, base)))
    words = assemble([t[4] for t in tries])
    chosen = {}
    for (ins, ops, text, base, line), w in zip(tries, words):
        if w is None or w & ins["mask"] != ins["value"]:
            continue
        key = (ins["name"], text.split(" ")[0], re.sub(r"\{[^}]*\}", "", text))
        if key not in chosen:
            chosen[key] = (ins, ops, text, base, w)
    # 2. Each entry, checked on lines with every operand varied.
    ours = existing()
    checks = []
    for key, (ins, ops, text, base, w0) in chosen.items():
        toks = tokens(ins, ops, w0)
        lines = [(list(base), fill(text, ops, base))]
        for k, o in enumerate(ops):
            for v in SAMPLES[o.kind]:
                vals = list(base)
                vals[k] = v
                lines.append((vals, fill(text, ops, vals)))
        checks.append((ins, ops, text, toks, w0, lines))
    words = assemble([l for c in checks for _, l in c[5]])
    it = iter(words)
    entries = []
    seen_enc = set()
    for ins, ops, text, toks, w0, lines in checks:
        got = [(vals, next(it)) for vals, _ in lines]
        good = [(vals, w) for vals, w in got if w is not None]
        bad = [(vals, w) for vals, w in good if encode(toks, ops, vals) != w]
        if bad:
            count("the assembler encodes it otherwise")
            if os.environ.get("SHOW") and stats["the assembler encodes it otherwise"] < 12:
                vals, w = bad[0]
                print(f"  {fill(text, ops, vals)}: ours {encode(toks, ops, vals):08x}, theirs {w:08x}; {' '.join(toks)}",
                      file=sys.stderr)
            continue
        if len(good) < len(ops):
            count("too few lines assemble")
            continue
        if any(all(w & m == v for _, w in good) for m, v in ours):
            count("the description has it")
            continue
        shape = re.sub(r"[a-z_][a-z0-9_]*", "o", " ".join(toks))
        decode = shape not in seen_enc and not ins["pseudo"]
        seen_enc.add(shape)
        if not decode:
            count("another spelling, or a pseudo-instruction")
        entries.append(entry(ins, ops, text, toks, decode))
        count("entries")
    for k, v in sorted(stats.items(), key=lambda x: -x[1]):
        print(f"{v:6} {k}", file=sys.stderr)
    with open(os.path.join(HERE, "80-asm.ll"), "w") as f:
        f.write(NOTICE + "".join(entries))


CLASS = {"x": "x", "f": "d"}


NAMES = {}


def entry(ins, ops, text, toks, decode):
    params = []
    for o in ops:
        if o.kind == "label":
            params.append(f'ptr "label" %{o.name}')
        elif o.kind == "imm":
            params.append(f'i64 "imm" %{o.name}')
        else:
            params.append(f'i64 "reg"="{CLASS[o.kind]}" %{o.name}')
    base = re.sub(r"[^A-Za-z0-9_]", "_", text.split(" ")[0].upper())
    NAMES[base] = NAMES.get(base, -1) + 1
    name = f"{base}.{NAMES[base]}"
    attrs = '"asmonly"' + ("" if decode else ' "nodecode"')
    return (f'define void @{name}({", ".join(params)}) "enc"="{" ".join(toks)}" '
            f'"asm"="{text}" {attrs} {{\n  ret void\n}}\n\n')


NOTICE = """; Entries for assembly and disassembly only ("asmonly"), written by
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

"""


if __name__ == "__main__":
    main()
