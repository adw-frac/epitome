"""Writes description entries whose encodings come from Arm's own
machine-readable specification: 25-pairs.ll, the load and store pairs.

Arm publishes the A-profile architecture as JSON (AARCHMRS, the open-source
package, under the BSD 3-clause license), from the A-Profile Architecture
Exploration Tools downloads at developer.arm.com. Download it and run:

    python3 codegen/targets/aarch64/gen_from_mrs.py path/to/Instructions.json

For each entry in ENTRIES below, the bit layout is taken from Arm's
encoding of that name: which bits are fixed, and which belong to which
field. The rest is ours: how each field is filled from the operands, the
assembly template, and the IR body that says what the instruction does
(the package has no pseudocode). The output is checked in; the code
generator reads only the .ll files.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

NOTICE = """\
; Encodings in this file are taken from Arm's A-profile Architecture Machine
; Readable Specification (AARCHMRS, {ref}), under this license:
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
"""


def layout(spec, name):
    """Arm's encoding `name`, most significant bit first: each bit '0', '1',
    or the name of the field holding it (the narrowest that does)."""
    a64 = next(s for s in spec["instructions"] if s["name"] == "A64")
    found = []

    def walk(node, chain):
        chain = chain + [node]
        if node["_type"] == "Instruction.Instruction" and node["name"] == name:
            found.append(chain)
        for c in node.get("children") or []:
            walk(c, chain)

    walk(a64, [])
    if len(found) != 1:
        sys.exit(f"{name}: {len(found)} encodings of this name in Arm's data")
    fixed = [None] * 32
    owner = [None] * 32
    for node in found[0]:
        for f in (node.get("encoding") or {}).get("values", []):
            start, width = f["range"]["start"], f["range"]["width"]
            value = f["value"]["value"].strip("'")
            for k, ch in enumerate(value):
                bit = start + width - 1 - k
                if ch in "01":
                    fixed[bit] = ch
                elif f["_type"] == "Instruction.Encodeset.Field":
                    if owner[bit] is None or owner[bit][1] > width:
                        owner[bit] = (f["name"], width)
    return [fixed[b] or (owner[b][0] if owner[b] else "?") for b in range(31, -1, -1)]


def encoding(spec, name, fields):
    """Our "enc" for Arm's encoding `name`, with `fields` saying how each of
    its fields is filled (`{"Rt": "d", "imm7": "imm7:s7=off/8"}`)."""
    bits = layout(spec, name)
    tokens = []
    k = 0
    while k < 32:
        b = bits[k]
        j = k
        while j < 32 and (bits[j] == b if b not in "01" else bits[j] in "01"):
            j += 1
        if b in "01":
            tokens.append("".join(bits[k:j]))
        else:
            if b not in fields:
                sys.exit(f"{name}: no way to fill Arm's field {b}")
            ours = fields[b]
            width = j - k
            if ":" not in ours:
                ours = f"{ours}:{width}"
            got = int(ours.split(":")[1].split("=")[0].lstrip("s"))
            if got != width:
                sys.exit(f"{name}: field {b} is {width} bits, ours says {got}")
            tokens.append(ours)
        k = j
    return " ".join(tokens)


# Load and store pairs: the size class, its IR type, register class, bytes,
# and Arm's name for its encodings.
PAIRS = [
    ("W", "i32", "w", 4, "32"),
    ("X", "i64", "x", 8, "64"),
    ("S", "float", "s", 4, "S"),
    ("D", "double", "d", 8, "D"),
    ("Q", "<2 x i64>", "q", 16, "Q"),
]


def pairs(spec):
    out = []
    for tag, ty, cls, size, arm in PAIRS + [("SW", "i32", "x", 4, "LDPSW")]:
        signed_word = tag == "SW"
        for form, arm_form in [("i", "off"), ("pre", "pre"), ("post", "post")]:
            imm = f"imm7:s7=off/{size}"
            where = {"i": "[{n}, #{off}]", "pre": "[{n}, #{off}]!", "post": "[{n}], #{off}"}[form]
            role = f' "role"="{{}}.pair.{cls}"' if form == "i" and tag in ("X", "D") else ""
            # The load.
            lname = f"LDPSW_64_ldstpair_{arm_form}" if signed_word else f"LDP_{arm}_ldstpair_{arm_form}"
            enc = encoding(spec, lname, {"Rt": "d", "Rt2": "d2", "Rn": "n", "imm7": imm})
            rty = "i64" if signed_word else ty
            mnem = "ldpsw" if signed_word else "ldp"
            wb = form != "i"
            ret = f"{{ {rty}, {rty}, ptr }}" if wb else f"{{ {rty}, {rty} }}"
            name = f"LDP{tag}{form}"
            base = '"writeback" ' if wb else ""
            body = []
            addr = "%p"
            if form == "post":
                addr = "%n"
            else:
                body.append("  %p = getelementptr i8, ptr %n, i64 %off")
            body.append(f"  %a = load {ty}, ptr {addr}")
            body.append(f"  %q = getelementptr i8, ptr {addr}, i64 {size}")
            body.append(f"  %b = load {ty}, ptr %q")
            va, vb = "%a", "%b"
            if signed_word:
                body.append("  %sa = sext i32 %a to i64")
                body.append("  %sb = sext i32 %b to i64")
                va, vb = "%sa", "%sb"
            body.append(f"  %r0 = insertvalue {ret} poison, {rty} {va}, 0")
            body.append(f"  %r1 = insertvalue {ret} %r0, {rty} {vb}, 1")
            last = "%r1"
            if wb:
                nxt = "%p" if form == "pre" else "%next"
                if form == "post":
                    body.append("  %next = getelementptr i8, ptr %n, i64 %off")
                body.append(f"  %r2 = insertvalue {ret} %r1, ptr {nxt}, 2")
                last = "%r2"
            body.append(f"  ret {ret} {last}")
            out.append(
                f'define {ret} @{name}(ptr "reg"="xsp" {base}%n, i64 "imm" %off) "enc"="{enc}" '
                f'"asm"="{mnem} {{d}}, {{d2}}, {where}" "result2"{role.format("load")} "nomatch" {{\n'
                + "\n".join(body)
                + "\n}\n"
            )
            if signed_word:
                continue
            # The store.
            sname = f"STP_{arm}_ldstpair_{arm_form}"
            enc = encoding(spec, sname, {"Rt": "t", "Rt2": "t2", "Rn": "n", "imm7": imm})
            name = f"STP{tag}{form}"
            body = []
            addr = "%n" if form == "post" else "%p"
            if form != "post":
                body.append("  %p = getelementptr i8, ptr %n, i64 %off")
            body.append(f"  store {ty} %t, ptr {addr}")
            body.append(f"  %q = getelementptr i8, ptr {addr}, i64 {size}")
            body.append(f"  store {ty} %t2, ptr %q")
            if form == "i":
                body.append("  ret void")
                rty2 = "void"
            else:
                if form == "post":
                    body.append("  %next = getelementptr i8, ptr %n, i64 %off")
                    body.append("  ret ptr %next")
                else:
                    body.append("  ret ptr %p")
                rty2 = "ptr"
            out.append(
                f'define {rty2} @{name}({ty} "reg"="{cls}" %t, {ty} "reg"="{cls}" %t2, ptr "reg"="xsp" {base}%n, '
                f'i64 "imm" %off) "enc"="{enc}" "asm"="stp {{t}}, {{t2}}, {where}"{role.format("store")} "nomatch" {{\n'
                + "\n".join(body)
                + "\n}\n"
            )
    return out


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    spec = json.load(open(sys.argv[1]))
    ref = spec["_meta"]["version"]["ref"]
    entries = pairs(spec)
    text = (
        "; The AArch64 description: load and store pairs. The conventions are in\n"
        "; 00-base.ll. This file is written by gen_from_mrs.py.\n;\n"
        + NOTICE.format(ref=ref)
        + """
; ===========================================================================
; Load and store pairs: two registers to or from two neighbouring slots,
; at an offset scaled by their size, before or after stepping the base. A
; load's second register is its second result ("result2"). They are not
; patterns: frames use them by role, to save and restore registers.

"""
        + "\n".join(entries)
        + "\n"
    )
    with open(os.path.join(HERE, "25-pairs.ll"), "w") as f:
        f.write(text)


main()
