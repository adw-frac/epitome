#!/usr/bin/env python3
"""Writes 22-atomics.ll: AArch64's atomic read-modify-write instructions
(FEAT_LSE, Armv8.1): swp, ldadd, ldclr, ldeor, ldset, ldsmax, ldsmin,
ldumax, ldumin and cas, at every size and ordering, as description
entries whose bodies are the IR they implement. Encodings are those of the
Arm Architecture Reference Manual (atomic memory operations: size 111 0 00
A R 1 Rs o3 opc 00 Rn Rt; compare and swap: size 001000 1 L 1 Rs o0 11111
Rn Rt). Run from this directory: python3 gen_atomics.py > 22-atomics.ll"""

SIZES = [  # (suffix, size bits, IR type, register kind)
    ("B", "00", "i8", "w"),
    ("H", "01", "i16", "w"),
    ("W", "10", "i32", "w"),
    ("X", "11", "i64", "x"),
]
ORDERS = [  # (mnemonic part, A, R, IR ordering, cmpxchg bucket)
    ("", "0", "0", "monotonic", 0),
    ("a", "1", "0", "acquire", 1),
    ("l", "0", "1", "release", 2),
    ("al", "1", "1", "seq_cst", 3),
]
OPS = [  # (mnemonic, o3, opc, IR operation)
    ("swp", "1", "000", "xchg"),
    ("ldadd", "0", "000", "add"),
    ("ldeor", "0", "010", "xor"),
    ("ldset", "0", "011", "or"),
    ("ldsmax", "0", "100", "max"),
    ("ldsmin", "0", "101", "min"),
    ("ldumax", "0", "110", "umax"),
    ("ldumin", "0", "111", "umin"),
]


def suffix(size):
    return "" if size in ("W", "X") else size.lower()


def main():
    out = [HEADER]
    for (s, sz, ty, r) in SIZES:
        out.append(f"\n; --- {ty}\n")
        for (mn, o3, opc, op) in OPS:
            for (o, a, rl, order, _) in ORDERS:
                name = f"{mn.upper()}{o.upper()}{s}"
                asm = f"{mn}{o}{suffix(s)} {{m}}, {{d}}, [{{n}}]"
                enc = f"{sz} 111 0 00 {a} {rl} 1 m:5 {o3} {opc} 00 n:5 d:5"
                out.append(
                    f'define {ty} @{name}({ty} "reg"="{r}" %m, ptr "reg"="xsp" %n) "feature"="lse" '
                    f'"enc"="{enc}" "asm"="{asm}" {{\n'
                    f"  %r = atomicrmw {op} ptr %n, {ty} %m {order}\n  ret {ty} %r\n}}\n\n"
                )
        # ldclr: the bits of m cleared, old & ~m; `and` with m is ldclr of ~m
        # (a recipe).
        for (o, a, rl, order, _) in ORDERS:
            name = f"LDCLR{o.upper()}{s}"
            asm = f"ldclr{o}{suffix(s)} {{m}}, {{d}}, [{{n}}]"
            enc = f"{sz} 111 0 00 {a} {rl} 1 m:5 0 001 00 n:5 d:5"
            out.append(
                f'define {ty} @{name}({ty} "reg"="{r}" %m, ptr "reg"="xsp" %n) "feature"="lse" '
                f'"enc"="{enc}" "asm"="{asm}" {{\n'
                f"  %nm = xor {ty} %m, -1\n  %r = atomicrmw and ptr %n, {ty} %nm {order}\n  ret {ty} %r\n}}\n\n"
            )
            mvn = "MVNX" if r == "x" else "MVNW"
            wide = "i64" if r == "x" else "i32"
            # The recipe works on the register's width: the inverted bits
            # above the access's size are not used.
            ext = (
                f"  %mw = zext {ty} %m to {wide}\n  %nw = call {wide} @{mvn}({wide} %mw)\n  %nm = trunc {wide} %nw to {ty}\n"
                if ty in ("i8", "i16")
                else f"  %nm = call {ty} @{mvn}({ty} %m)\n"
            )
            out.append(
                f'define {ty} @rmw.and{o}.{ty}(ptr "reg"="xsp" %n, {ty} "reg"="{r}" %m) "feature"="lse" '
                f'"recipe"="rmw.and{o}.{ty}.expand" {{\n'
                f"  %r = atomicrmw and ptr %n, {ty} %m {order}\n  ret {ty} %r\n}}\n\n"
                f"define {ty} @rmw.and{o}.{ty}.expand(ptr %n, {ty} %m) {{\n{ext}"
                f"  %r = call {ty} @{name}({ty} %nm, ptr %n)\n  ret {ty} %r\n}}\n\n"
            )
        # cas: compare and swap, the old value in and out of the first
        # register (tied to the result). cmpxchg is lowered to the
        # intrinsic (prepare.rs), its success a comparison of the result.
        for (o, a, rl, order, bucket) in ORDERS:
            name = f"CAS{o.upper()}{s}"
            asm = f"cas{o}{suffix(s)} {{d}}, {{new}}, [{{n}}]"
            enc = f"{sz} 001000 1 {a} 1 d:5 {rl} 11111 n:5 new:5"
            out.append(
                f'define {ty} @{name}({ty} "reg"="{r}" "tied" %old, {ty} "reg"="{r}" %new, ptr "reg"="xsp" %n) '
                f'"feature"="lse" "enc"="{enc}" "asm"="{asm}" {{\n'
                f"  %r = call {ty} @llvm.epitome.cmpxchg.{ty}(ptr %n, {ty} %old, {ty} %new, i32 {bucket})\n"
                f"  ret {ty} %r\n}}\n\n"
            )
    print("".join(out).rstrip() + "\n")


HEADER = """; The AArch64 description: atomic read-modify-write (FEAT_LSE). Written by
; gen_atomics.py; the conventions are in 00-base.ll.
;
; Each instruction loads the old value into its result and writes the new
; one, with the ordering in its name: none (monotonic), a (acquire), l
; (release), al (acquire and release, and sequentially consistent). An
; operation or ordering missing here (nand, the floating-point ones) is a
; compare-and-swap loop (prepare.rs); without LSE, the outline helpers.

declare i8 @llvm.epitome.cmpxchg.i8(ptr, i8, i8, i32)
declare i16 @llvm.epitome.cmpxchg.i16(ptr, i16, i16, i32)
declare i32 @llvm.epitome.cmpxchg.i32(ptr, i32, i32, i32)
declare i64 @llvm.epitome.cmpxchg.i64(ptr, i64, i64, i32)
"""

if __name__ == "__main__":
    main()
