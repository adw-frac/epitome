#!/usr/bin/env python3
"""Writes x86-avx512.mlir: matrix kernels for x86-64 with AVX-512 and
AVX512-BF16, data for `mlir/src/linalg_kernels.rs`
(`--pass=linalg-to-kernels=x86-avx512`). The kernels differ only in how
many rows of C one call computes, so they are written from one template.

Usage: gen_x86_avx512.py > x86-avx512.mlir
"""

import sys

FEATURES = '+avx512f,+avx512bf16'


class Body:
    """SSA names and lines of a function's body, in MLIR's generic form."""

    def __init__(self):
        self.lines = []
        self.n = 0
        self.depth = 1

    def name(self, hint):
        self.n += 1
        return f'%{hint}{self.n}'

    def line(self, text):
        self.lines.append('  ' * self.depth + text)

    def op(self, hint, text):
        v = self.name(hint)
        self.line(f'{v} = {text}')
        return v

    def const(self, value, ty='i64'):
        return self.op('c', f'"llvm.mlir.constant"() <{{value = {value} : {ty}}}> : () -> {ty}')

    def index(self, value):
        return self.op('i', f'arith.constant {value} : index')

    def cast(self, v):
        return self.op('x', f'arith.index_cast {v} : index to i64')

    def int(self, op, a, b):
        flags = ' <{overflowFlags = 0 : i32}>' if op in ('mul', 'add') else ''
        return self.op('n', f'"llvm.{op}"({a}, {b}){flags} : (i64, i64) -> i64')

    def gep(self, p, off, elem='f32'):
        return self.op('p', f'"llvm.getelementptr"({p}, {off}) <{{elem_type = {elem}, noWrapFlags = 0 : i32, '
                       f'rawConstantIndices = array<i32: -2147483648>}}> : (!llvm.ptr, i64) -> !llvm.ptr')

    def load(self, p, ty):
        return self.op('v', f'"llvm.load"({p}) <{{alignment = 4 : i64, ordering = 0 : i64}}> : (!llvm.ptr) -> {ty}')

    def store(self, v, p, ty):
        self.line(f'"llvm.store"({v}, {p}) <{{alignment = 4 : i64, ordering = 0 : i64}}> : ({ty}, !llvm.ptr) -> ()')

    def intrinsic(self, name, args, types, ret):
        return self.op('v', f'"llvm.call_intrinsic"({", ".join(args)}) <{{intrin = "{name}"}}> : '
                       f'({", ".join(types)}) -> {ret}')

    def loop(self, lo, hi, step, carried, body):
        """`scf.for lo to hi by step`, carrying `carried` (values of type
        F); `body(iv, args)` returns what each iteration yields."""
        iv = self.name('iv')
        args = [self.name('a') for _ in carried]
        results = [self.name('r') for _ in carried]
        head = f'{results[0]}:{len(results)} = ' if len(results) > 1 else (f'{results[0]} = ' if results else '')
        operands = ', '.join([lo, hi, step] + carried)
        self.line(f'{head}"scf.for"({operands}) ({{')
        params = ', '.join([f'{iv}: index'] + [f'{a}: {F}' for a in args])
        self.line(f'^bb0({params}):')
        self.depth += 1
        yields = body(iv, args)
        types = ', '.join([F] * len(yields))
        self.line(f'"scf.yield"({", ".join(yields)}) : ({types}) -> ()')
        self.depth -= 1
        self.line(f'}}) : ({", ".join(["index"] * 3 + [F] * len(carried))}) -> ({", ".join([F] * len(carried))})')
        if len(results) > 1:
            return [f'{results[0].split(":")[0]}#{k}' for k in range(len(results))]
        return results


F = 'vector<16xf32>'
W = 'vector<16xi32>'
H = 'vector<8xi32>'


def matmul_bf16(rows):
    """C[rows, n] += A[rows, k] B[k, n], B packed as BF16 pairs in panels
    of 64 columns (k/2 rows of 64 words each). A's rows are rounded to
    BF16 into at first, a row of k/2 pairs each; then, for each panel, the
    rows x 64 block of C is in 4 rows registers while each row of pairs
    of the panel is multiplied in: four vectors of B, and a pair of A
    broadcast for each row, vdpbf16ps adding both products of a pair."""
    name = f'__epitome_avx512_matmul_bf16_r{rows}'
    b = Body()
    zero, one = b.index(0), b.index(1)
    ki = b.op('k', 'arith.index_cast %k : i64 to index')
    ni = b.op('n', 'arith.index_cast %n : i64 to index')
    c16, c64 = b.index(16), b.index(64)
    kp = b.op('h', f'arith.divui {ki}, {b.index(2)} : index')
    kw = b.int('lshr', '%k', b.const(1))
    six = b.const(6)
    # A's rows to BF16 pairs: row r at at + r k/2 words.
    def convert(kk, _):
        k64 = b.cast(kk)
        half = b.int('lshr', k64, b.const(1))
        for r in range(rows):
            ar = b.gep('%a', b.int('add', b.int('mul', b.const(r), '%lda'), k64))
            v = b.load(ar, F)
            h = b.intrinsic('llvm.epitome.x86.cvtneps2bf16.512', [v], [F], H)
            tr = b.gep('%at', b.int('add', b.int('mul', b.const(r), kw), half), 'i32')
            b.store(h, tr, H)
        return []
    b.loop(zero, ki, c16, [], convert)
    def panel(j, _):
        j64 = b.cast(j)
        bj = b.gep('%b', b.int('mul', b.int('lshr', j64, six), '%panel'), 'i32')
        cs = []
        for r in range(rows):
            for q in range(4):
                off = b.int('add', b.int('mul', b.const(r), '%ldc'), b.int('add', j64, b.const(16 * q)))
                cs.append(b.gep('%c', off))
        acc = [b.load(p, F) for p in cs]
        def step(p, acc):
            p64 = b.cast(p)
            row = b.gep(bj, b.int('mul', p64, '%ldb'), 'i32')
            bs = [b.load(b.gep(row, b.const(16 * q), 'i32') if q else row, W) for q in range(4)]
            new = []
            for r in range(rows):
                pa = b.gep('%at', b.int('add', b.int('mul', b.const(r), kw), p64), 'i32')
                s = b.op('s', f'"vector.broadcast"({b.load(pa, "i32")}) : (i32) -> {W}')
                for q in range(4):
                    new.append(b.intrinsic('llvm.epitome.x86.dpbf16ps.512', [acc[4 * r + q], s, bs[q]], [F, W, W], F))
            return new
        out = b.loop(zero, kp, one, acc, step)
        for v, p in zip(out, cs):
            b.store(v, p, F)
        return []
    b.loop(zero, ni, c64, [], panel)
    b.line('"func.return"() : () -> ()')
    kernel = (f'"epitome.kernel"() <{{op = "matmul", element = f32, weights = "bf16",\n'
              f'    indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>,\n'
              f'                     affine_map<(d0, d1, d2) -> (d0, d1)>],\n'
              f'    iterator_types = ["parallel", "parallel", "reduction"],\n'
              f'    body = ["arith.mulf", "arith.addf"],\n'
              f'    tile = array<i64: {rows}, 64>, whole_rows, pack_b = 64, transpose_a,\n'
              f'    function = @{name}}}> : () -> ()\n\n')
    head = (f'func.func private @{name}(%c: !llvm.ptr, %ldc: i64, %a: !llvm.ptr, %lda: i64, %at: !llvm.ptr, '
            f'%b: !llvm.ptr, %ldb: i64, %k: i64, %n: i64, %panel: i64) attributes {{llvm.no_inline, '
            f'llvm.passthrough = [["target-features", "{FEATURES}"]]}} {{\n')
    return kernel + head + '\n'.join(b.lines) + '\n}\n'


def main():
    sys.stdout.write("""// Kernels for x86-64 with AVX-512 and AVX512-BF16: data for
// `mlir/src/linalg_kernels.rs` (`--pass=linalg-to-kernels=x86-avx512`).
// Written by gen_x86_avx512.py; do not edit. See aarch64-sme.mlir for what
// an `epitome.kernel` says and the arguments its function takes.
//
// Matrix products in BF16 ("weights = bf16"), for B a constant, packed
// as for aarch64-sme.mlir's BF16 kernel: each 64-column panel k/2 rows of
// 64 words, a word two rows of a column (row 2i in the bottom half). A
// block of rows of A is rounded to BF16 into at (vcvtneps2bf16), each row
// k/2 pairs; vdpbf16ps adds both products of a pair of A, broadcast, and
// of a word of B into each f32 lane of C. The kernels are the same but for
// how many rows of C they keep in registers: four (16 vectors of the 32),
// then one for the rows left over. The functions alone use AVX-512
// ("target-features"), so the rest of a program needs only AVX2.

""")
    sys.stdout.write(matmul_bf16(4))
    sys.stdout.write('\n')
    sys.stdout.write(matmul_bf16(1))


main()
