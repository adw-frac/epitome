"""Writes 50-vectors.ll, the vector (Advanced SIMD) part of the AArch64
description: one entry per instruction and arrangement. Run it from
anywhere:

    python3 codegen/targets/aarch64/gen_vectors.py

The description stays data: the output is checked in, and the code
generator reads only the .ll files.
"""
import os
import sys

out = []
INT = [  # arr, lanes, ebits, Q, size
    ('16b', 16, 8, 1, '00'), ('8h', 8, 16, 1, '01'), ('4s', 4, 32, 1, '10'), ('2d', 2, 64, 1, '11'),
    ('8b', 8, 8, 0, '00'), ('4h', 4, 16, 0, '01'), ('2s', 2, 32, 0, '10'),
]
FLT = [  # arr, lanes, ty, Q, sz
    ('4s', 4, 'float', 1, '0'), ('2d', 2, 'double', 1, '1'), ('2s', 2, 'float', 0, '0'),
]
def vt(lanes, e): return f'<{lanes} x {e}>'
def it(bits): return f'i{bits}'
def cls(Q): return 'q' if Q else 'v'
def bitw(Q): return '16b' if Q else '8b'
def suffix(e): return {8:'b',16:'h',32:'s',64:'d'}[e]
o = []
o.append('''; The AArch64 description: vectors. The conventions are in 00-base.ll.

; ===========================================================================
; Vectors (Advanced SIMD). 128-bit vectors live in q registers, 64-bit ones
; in d registers; templates print them with their arrangement, v3.4s. A
; vector of i1 is a mask: lanes of all ones or all zeros, as comparisons
; make them, in a q register.
;
; This file is written by gen_vectors.py (one entry per arrangement), but
; is data like the rest.
''')
for arr, n, e, Q, size in INT:
    T = vt(n, it(e)); M = vt(n, 'i1'); c = cls(Q); A = arr; B = bitw(Q)
    def three(name, U, op, ir, asm=None, sz=size, a=A):
        asm = asm or name.lower()
        o.append(f'''define {T} @{name}{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {sz} 1 m:5 {op} 1 n:5 d:5" "asm"="{asm} {{d:{a}}}, {{n:{a}}}, {{m:{a}}}" {{
  %r = {ir} {T} %n, %m
  ret {T} %r
}}
''')
    three('ADDv', 0, '10000', 'add', 'add')
    three('SUBv', 1, '10000', 'sub', 'sub')
    if e != 64:
        three('MULv', 0, '10011', 'mul', 'mul')
    three('ANDv', 0, '00011', 'and', 'and', '00', B)
    three('ORRv', 0, '00011', 'or', 'orr', '10', B)
    three('EORv', 1, '00011', 'xor', 'eor', '00', B)
    o.append(f'''define {T} @BICv{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 0 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bic {{d:{B}}}, {{n:{B}}}, {{m:{B}}}" {{
  %nm = xor {T} %m, splat ({it(e)} -1)
  %r = and {T} %n, %nm
  ret {T} %r
}}

define {T} @MVNv{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} 1 01110 00 10000 00101 10 n:5 d:5" "asm"="mvn {{d:{B}}}, {{n:{B}}}" {{
  %r = xor {T} %n, splat ({it(e)} -1)
  ret {T} %r
}}

define {T} @NEGv{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} 1 01110 {size} 10000 01011 10 n:5 d:5" "asm"="neg {{d:{A}}}, {{n:{A}}}" {{
  %r = sub {T} zeroinitializer, %n
  ret {T} %r
}}

declare {T} @llvm.abs.v{n}i{e}({T}, i1)

define {T} @ABSv{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} 0 01110 {size} 10000 01011 10 n:5 d:5" "asm"="abs {{d:{A}}}, {{n:{A}}}" {{
  %r = call {T} @llvm.abs.v{n}i{e}({T} %n, i1 false)
  ret {T} %r
}}
''')
    # shifts by a constant: immh:immb is the element size (its leading
    # one, literal bits) and the shift (the bits below it), so that a word
    # with immh zero (movi and its kin) is not read as a shift.
    L = e.bit_length() - 1
    size_bits = '0' * (6 - L) + '1'
    o.append(f'''define {T} @SHLv{arr}({T} "reg"="{c}" %n, {T} "imm" %sh) "enc"="0 {Q} 0 011110 {size_bits} sh:{L} 01010 1 n:5 d:5" "asm"="shl {{d:{A}}}, {{n:{A}}}, #{{sh}}" {{
  %r = shl {T} %n, %sh
  ret {T} %r
}}

define {T} @USHRv{arr}({T} "reg"="{c}" %n, {T} "imm" %sh) "enc"="0 {Q} 1 011110 {size_bits} amt:{L}={e}-sh 00000 1 n:5 d:5" "asm"="ushr {{d:{A}}}, {{n:{A}}}, #{{sh}}" {{
  %r = lshr {T} %n, %sh
  ret {T} %r
}}

define {T} @SSHRv{arr}({T} "reg"="{c}" %n, {T} "imm" %sh) "enc"="0 {Q} 0 011110 {size_bits} amt:{L}={e}-sh 00000 1 n:5 d:5" "asm"="sshr {{d:{A}}}, {{n:{A}}}, #{{sh}}" {{
  %r = ashr {T} %n, %sh
  ret {T} %r
}}
''')
    # comparisons give masks; the swapped ones put m in the n field.
    for name, U, op, pred, swap in [('CMEQ',1,'10001','eq',0),('CMGT',0,'00110','sgt',0),('CMGE',0,'00111','sge',0),('CMHI',1,'00110','ugt',0),('CMHS',1,'00111','uge',0),
                                     ('CMGT',0,'00110','slt',1),('CMGE',0,'00111','sle',1),('CMHI',1,'00110','ult',1),('CMHS',1,'00111','ule',1)]:
        fields = 'rm:5=n 'if swap else 'm:5 '
        nf = 'rn:5=m' if swap else 'n:5'
        asm = f'{name.lower()} {{d:{A}}}, {{m:{A}}}, {{n:{A}}}' if swap else f'{name.lower()} {{d:{A}}}, {{n:{A}}}, {{m:{A}}}'
        nd = ' "nodecode"' if swap else ''
        o.append(f'''define {M} @{name}{"s" if swap else ""}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {size} 1 {fields}{op} 1 {nf} d:5" "asm"="{asm}" "dclass"="q"{nd} {{
  %r = icmp {pred} {T} %n, %m
  ret {M} %r
}}
''')
    o.append(f'''define {T} @BSLv{arr}({M} "reg"="q" "tied" %c, {T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {{d:{B}}}, {{n:{B}}}, {{m:{B}}}"{'' if e == 8 else ' "nodecode"'} {{
  %r = select {M} %c, {T} %n, {T} %m
  ret {T} %r
}}

; A mask's lanes, all ones or zeros, as 1 or 0.
define {T} @MASKv{arr}({M} "reg"="q" %n) "enc"="0 {Q} 1 011110 {format(2*e-(e-1), '07b')} 00000 1 n:5 d:5" "asm"="ushr {{d:{A}}}, {{n:{A}}}, #{e-1}" "nodecode" {{
  %r = zext {M} %n to {T}
  ret {T} %r
}}
''')
    if e != 64:
        for name, U, op, f in [('SMAX',0,'01100','smax'),('SMIN',0,'01101','smin'),('UMAX',1,'01100','umax'),('UMIN',1,'01101','umin')]:
            o.append(f'''declare {T} @llvm.{f}.v{n}i{e}({T}, {T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {size} 1 m:5 {op} 1 n:5 d:5" "asm"="{name.lower()} {{d:{A}}}, {{n:{A}}}, {{m:{A}}}" {{
  %r = call {T} @llvm.{f}.v{n}i{e}({T} %n, {T} %m)
  ret {T} %r
}}
''')
    # saturating addition and subtraction
    for name, U, op, f in [('UQADD',1,'00001','uadd.sat'),('SQADD',0,'00001','sadd.sat'),('UQSUB',1,'00101','usub.sat'),('SQSUB',0,'00101','ssub.sat')]:
        o.append(f'''declare {T} @llvm.{f}.v{n}i{e}({T}, {T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {size} 1 m:5 {op} 1 n:5 d:5" "asm"="{name.lower()} {{d:{A}}}, {{n:{A}}}, {{m:{A}}}" {{
  %r = call {T} @llvm.{f}.v{n}i{e}({T} %n, {T} %m)
  ret {T} %r
}}
''')
    # splat from an integer register
    gcls = 'x' if e == 64 else 'w'
    imm5 = {8:'00001',16:'00010',32:'00100',64:'01000'}[e]
    o.append(f'''define {T} @DUPv{arr}({it(e)} "reg"="{gcls}" %n) "enc"="0 {Q} 0 01110000 {imm5} 0 0001 1 n:5 d:5" "asm"="dup {{d:{A}}}, {{n}}" "role"="dup.{arr}" {{
  %i = insertelement {T} poison, {it(e)} %n, i64 0
  %r = shufflevector {T} %i, {T} poison, <{n} x i32> zeroinitializer
  ret {T} %r
}}
''')
# lane moves, by lane size, 128-bit vectors
for e, lanes in [(8,16),(16,8),(32,4),(64,2)]:
    T = vt(lanes, it(e)); s = suffix(e); gcls = 'x' if e == 64 else 'w'
    k = {8:1,16:2,32:4,64:8}[e]
    Qbit = 1 if e == 64 else 0
    o.append(f'''define {it(e)} @UMOV{s}({T} "reg"="q" %n, i64 "imm" %idx) "enc"="0 {Qbit} 0 01110000 imm5:5=idx*{2*k}+{k} 0 0111 1 n:5 d:5" "asm"="{'mov' if e >= 32 else 'umov'} {{d}}, {{n:.{s}}}[{{idx}}]" {{
  %r = extractelement {T} %n, i64 %idx
  ret {it(e)} %r
}}

define {T} @INS{s}({T} "reg"="q" "tied" %old, {it(e)} "reg"="{gcls}" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*{2*k}+{k} 0 0011 1 n:5 d:5" "asm"="mov {{d:.{s}}}[{{idx}}], {{n}}" "role"="ins.{s}" {{
  %r = insertelement {T} %old, {it(e)} %n, i64 %idx
  ret {T} %r
}}
''')
# floating point vectors
for arr, n, ty, Q, sz in FLT:
    T = vt(n, ty); c = cls(Q); A = arr; M = vt(n, 'i1')
    fb = 'f32' if ty == 'float' else 'f64'
    for name, prefix, op, ir in [('FADD','0 '+str(Q)+' 0 01110 0','11010','fadd'),('FSUB','0 '+str(Q)+' 0 01110 1','11010','fsub'),
                                  ('FMUL','0 '+str(Q)+' 1 01110 0','11011','fmul'),('FDIV','0 '+str(Q)+' 1 01110 0','11111','fdiv')]:
        o.append(f'''define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="{prefix} {sz} 1 m:5 {op} 1 n:5 d:5" "asm"="{ir} {{d:{A}}}, {{n:{A}}}, {{m:{A}}}" {{
  %r = {ir} {T} %n, %m
  ret {T} %r
}}
''')
    o.append(f'''declare {T} @llvm.fmuladd.v{n}{fb}({T}, {T}, {T})

define {T} @FMLAv{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m, {T} "reg"="{c}" "tied" %a) "enc"="0 {Q} 0 01110 0 {sz} 1 m:5 11001 1 n:5 d:5" "asm"="fmla {{d:{A}}}, {{n:{A}}}, {{m:{A}}}" {{
  %r = call {T} @llvm.fmuladd.v{n}{fb}({T} %n, {T} %m, {T} %a)
  ret {T} %r
}}

define {T} @FNEGv{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} 1 01110 1 {sz} 10000 01111 10 n:5 d:5" "asm"="fneg {{d:{A}}}, {{n:{A}}}" {{
  %r = fneg {T} %n
  ret {T} %r
}}
''')
    # ordered comparisons give masks; the swapped ones put m in the n field.
    for name, U, E, pred, swap in [('FCMEQ',0,0,'oeq',0),('FCMGE',1,0,'oge',0),('FCMGT',1,1,'ogt',0),('FCMGE',1,0,'ole',1),('FCMGT',1,1,'olt',1)]:
        fields = 'rm:5=n ' if swap else 'm:5 '
        nf = 'rn:5=m' if swap else 'n:5'
        asm = f'{name.lower()} {{d:{A}}}, {{m:{A}}}, {{n:{A}}}' if swap else f'{name.lower()} {{d:{A}}}, {{n:{A}}}, {{m:{A}}}'
        nd = ' "nodecode"' if swap else ''
        o.append(f'''define {M} @{name}{"s" if swap else ""}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {E} {sz} 1 {fields}11100 1 {nf} d:5" "asm"="{asm}" "dclass"="q"{nd} {{
  %r = fcmp {pred} {T} %n, %m
  ret {M} %r
}}
''')
    B = bitw(Q)
    o.append(f'''define {T} @BSLv{arr}f({M} "reg"="q" "tied" %c, {T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 1 01110 01 1 m:5 00011 1 n:5 d:5" "asm"="bsl {{d:{B}}}, {{n:{B}}}, {{m:{B}}}" "nodecode" {{
  %r = select {M} %c, {T} %n, {T} %m
  ret {T} %r
}}
''')
    iT = vt(n, 'i32' if ty == 'float' else 'i64')
    for name, U, pre, op, ir, frm, to in [('SCVTF',0,'0',"11101",'sitofp',iT,T),('UCVTF',1,'0','11101','uitofp',iT,T),('FCVTZS',0,'1','11011','fptosi',T,iT),('FCVTZU',1,'1','11011','fptoui',T,iT)]:
        o.append(f'''define {to} @{name}v{arr}({frm} "reg"="{c}" %n) "enc"="0 {Q} {U} 01110 {pre} {sz} 10000 {op} 10 n:5 d:5" "asm"="{name.lower()} {{d:{A}}}, {{n:{A}}}" {{
  %r = {ir} {frm} %n to {to}
  ret {to} %r
}}
''')
    # splat of a floating-point register's value
    if Q:
        es = 's' if ty == 'float' else 'd'
        imm5 = '00100' if ty == 'float' else '01000'
        scls = 's' if ty == 'float' else 'd'
        o.append(f'''define {T} @DUPf{arr}({ty} "reg"="{scls}" %n) "enc"="0 1 0 01110000 {imm5} 0 0000 1 n:5 d:5" "asm"="dup {{d:{A}}}, {{n:.{es}}}[0]" {{
  %i = insertelement {T} poison, {ty} %n, i64 0
  %r = shufflevector {T} %i, {T} poison, <{n} x i32> zeroinitializer
  ret {T} %r
}}

define {ty} @DUPe{es}({T} "reg"="q" %n, i64 "imm" %idx) "enc"="01 0 11110000 imm5:5=idx*{8 if es=='s' else 16}+{4 if es=='s' else 8} 0 0000 1 n:5 d:5" "asm"="mov {{d}}, {{n:.{es}}}[{{idx}}]" {{
  %r = extractelement {T} %n, i64 %idx
  ret {ty} %r
}}

define {T} @INSf{es}({T} "reg"="q" "tied" %old, {ty} "reg"="{scls}" %n, i64 "imm" %idx) "enc"="0 1 1 01110000 imm5:5=idx*{8 if es=='s' else 16}+{4 if es=='s' else 8} 0 0000 1 n:5 d:5" "asm"="mov {{d:.{es}}}[{{idx}}], {{n:.{es}}}[0]" {{
  %r = insertelement {T} %old, {ty} %n, i64 %idx
  ret {T} %r
}}
''')
    # The same for half a register (<2 x float>): the lanes are the
    # register's low ones.
    if not Q and ty == 'float':
        o.append(f'''define {T} @DUPf{arr}({ty} "reg"="s" %n) "enc"="0 0 0 01110000 00100 0 0000 1 n:5 d:5" "asm"="dup {{d:{A}}}, {{n:.s}}[0]" {{
  %i = insertelement {T} poison, {ty} %n, i64 0
  %r = shufflevector {T} %i, {T} poison, <{n} x i32> zeroinitializer
  ret {T} %r
}}

define {ty} @DUPes{arr}({T} "reg"="v" %n, i64 "imm" %idx) "enc"="01 0 11110000 imm5:5=idx*8+4 0 0000 1 n:5 d:5" "asm"="mov {{d}}, {{n:.s}}[{{idx}}]" {{
  %r = extractelement {T} %n, i64 %idx
  ret {ty} %r
}}

define {T} @INSfs{arr}({T} "reg"="v" "tied" %old, {ty} "reg"="s" %n, i64 "imm" %idx) "enc"="0 1 1 01110000 imm5:5=idx*8+4 0 0000 1 n:5 d:5" "asm"="mov {{d:.s}}[{{idx}}], {{n:.s}}[0]" {{
  %r = insertelement {T} %old, {ty} %n, i64 %idx
  ret {T} %r
}}
''')
# widening and narrowing, half a register at a time
for (src, dst, n, e, sxt) in [('8b','8h',8,8,'0001000'),('4h','4s',4,16,'0010000'),('2s','2d',2,32,'0100000')]:
    S = vt(n, it(e)); D = vt(n, it(2*e)); W = vt(2*n, it(e)); hi = ', '.join(f'i32 {k}' for k in range(n, 2*n)); lo = ', '.join(f'i32 {k}' for k in range(n))
    for name, U, ext in [('SXTL',0,'sext'),('UXTL',1,'zext')]:
        o.append(f'''define {D} @{name}{dst}({S} "reg"="v" %n) "enc"="0 0 {U} 011110 {sxt} 10100 1 n:5 d:5" "asm"="{name.lower()} {{d:{dst}}}, {{n:{src}}}" {{
  %r = {ext} {S} %n to {D}
  ret {D} %r
}}

define {D} @{name}2{dst}({W} "reg"="q" %n) "enc"="0 1 {U} 011110 {sxt} 10100 1 n:5 d:5" "asm"="{name.lower()}2 {{d:{dst}}}, {{n:{2*n}{suffix(e)}}}" {{
  %h = shufflevector {W} %n, {W} poison, <{n} x i32> <{hi}>
  %r = {ext} {S} %h to {D}
  ret {D} %r
}}
''')
    o.append(f'''define {S} @XTN{src}({D} "reg"="q" %n) "enc"="0 0 0 01110 {{'8b':'00','4h':'01','2s':'10'}}[src] 10000 10010 10 n:5 d:5" "asm"="xtn {{d:{src}}}, {{n:{dst}}}" {{
  %r = trunc {D} %n to {S}
  ret {S} %r
}}

define {W} @XTN2{2*n}{suffix(e)}({S} "reg"="v" "tied" %lo, {D} "reg"="q" %m) "enc"="0 1 0 01110 {{'8b':'00','4h':'01','2s':'10'}}[src] 10000 10010 10 m:5 d:5" "asm"="xtn2 {{d:{2*n}{suffix(e)}}}, {{m:{dst}}}" {{
  %t = trunc {D} %m to {S}
  %r = shufflevector {S} %lo, {S} %t, <{2*n} x i32> <{', '.join(f'i32 {k}' for k in range(2*n))}>
  ret {W} %r
}}
'''.replace("{'8b':'00','4h':'01','2s':'10'}[src]", {'8b':'00','4h':'01','2s':'10'}[src]))
# halves and joins of 128-bit vectors
for n2, e, ty in [(16,8,None),(8,16,None),(4,32,None),(2,64,None),(4,32,'float')]:
    el = ty or it(e)
    W = vt(n2, el); H = vt(n2//2, el); n = n2//2
    e = f'{e}{"f" if ty else ""}'
    lo = ', '.join(f'i32 {k}' for k in range(n)); hi = ', '.join(f'i32 {k}' for k in range(n, n2)); all_ = ', '.join(f'i32 {k}' for k in range(n2))
    o.append(f'''define {H} @LOW{n2}x{e}({W} "reg"="q" %n) "enc"="0 0 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {{d:8b}}, {{n:8b}}" "nodecode" {{
  %r = shufflevector {W} %n, {W} poison, <{n} x i32> <{lo}>
  ret {H} %r
}}

define {H} @HIGH{n2}x{e}({W} "reg"="q" %n) "enc"="01 0 11110000 11000 0 0000 1 n:5 d:5" "asm"="mov {{d}}, {{n:.d}}[1]" "nodecode" {{
  %r = shufflevector {W} %n, {W} poison, <{n} x i32> <{hi}>
  ret {H} %r
}}

define {W} @JOIN{n2}x{e}({H} "reg"="v" "tied" %lo, {H} "reg"="v" %n) "enc"="0 1 1 01110000 11000 0 0000 1 n:5 d:5" "asm"="mov {{d:.d}}[1], {{n:.d}}[0]" "nodecode" {{
  %r = shufflevector {H} %lo, {H} %n, <{n2} x i32> <{all_}>
  ret {W} %r
}}
''')
# reductions: across lanes into lane 0, then out to an integer register
for arr, n, e, Q, size in INT:
    if e == 64 or not Q: continue
    T = vt(n, it(e))
    for name, U, op in [('ADDV',0,'11011'),('SMAXV',0,'01010'),('SMINV',0,'11010'),('UMAXV',1,'01010'),('UMINV',1,'11010')]:
        o.append(f'''define {T} @{name}{arr}({T} "reg"="q" %n) "enc"="0 1 {U} 01110 {size} 11000 {op} 10 n:5 d:5" "asm"="{name.lower()} {{d:{suffix(e)}}}, {{n:{arr}}}" "nomatch" {{
  ret {T} %n
}}
''')
o.append('''define <2 x i64> @ADDPd(<2 x i64> "reg"="q" %n) "enc"="01 0 11110 11 11000 11011 10 n:5 d:5" "asm"="addp {d:d}, {n:2d}" "nomatch" {
  ret <2 x i64> %n
}
''')
for red, intr_name in [('ADDV','add'),('SMAXV','smax'),('SMINV','smin'),('UMAXV','umax'),('UMINV','umin')]:
    for arr, n, e in [('16b',16,8),('8h',8,16),('4s',4,32)]:
        T = vt(n, it(e)); s = suffix(e)
        o.append(f'''declare {it(e)} @llvm.vector.reduce.{intr_name}.v{n}i{e}({T})

define {it(e)} @reduce.{intr_name}.v{n}i{e}({T} "reg"="q" %v) "recipe"="reduce.{intr_name}.v{n}i{e}.expand" {{
  %r = call {it(e)} @llvm.vector.reduce.{intr_name}.v{n}i{e}({T} %v)
  ret {it(e)} %r
}}

define {it(e)} @reduce.{intr_name}.v{n}i{e}.expand({T} %v) {{
  %t = call {T} @{red}{arr}({T} %v)
  %r = call {it(e)} @UMOV{s}({T} %t, i64 0)
  ret {it(e)} %r
}}
''')
o.append('''declare i64 @llvm.vector.reduce.add.v2i64(<2 x i64>)

define i64 @reduce.add.v2i64(<2 x i64> "reg"="q" %v) "recipe"="reduce.add.v2i64.expand" {
  %r = call i64 @llvm.vector.reduce.add.v2i64(<2 x i64> %v)
  ret i64 %r
}

define i64 @reduce.add.v2i64.expand(<2 x i64> %v) {
  %t = call <2 x i64> @ADDPd(<2 x i64> %v)
  %r = call i64 @UMOVd(<2 x i64> %t, i64 0)
  ret i64 %r
}
''')
# memory: 128-bit and 64-bit vectors
mem = [('Q','q','00','11','10',16,4, [vt(16,'i8'),vt(8,'i16'),vt(4,'i32'),vt(2,'i64'),vt(4,'float'),vt(2,'double')]),
       ('D','v','11','01','00',8,3, [vt(8,'i8'),vt(4,'i16'),vt(2,'i32'),vt(2,'float')])]
for R, c, size, ldopc, stopc, scale, sh, types in mem:
    if R == 'Q':
        ld_ui, st_ui = f'{size} 111 1 01 {ldopc}', f'{size} 111 1 01 {stopc}'
        ld_u, st_u = f'{size} 111 1 00 {ldopc}', f'{size} 111 1 00 {stopc}'
    else:
        ld_ui, st_ui = f'{size} 111 1 01 01', f'{size} 111 1 01 00'
        ld_u, st_u = f'{size} 111 1 00 01', f'{size} 111 1 00 00'
    for k, T in enumerate(types):
        tag = T.strip('<>').replace(' x ', 'x')
        nd = '' if k == 0 else ' "nodecode"'
        role_ld = f' "role"="load.q"' if (R == 'Q' and k == 0) else ''
        role_st = f' "role"="store.q"' if (R == 'Q' and k == 0) else ''
        o.append(f'''define {T} @LDR{R}ui.{tag}(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="{ld_ui} imm12:12=off/{scale} n:5 d:5" "asm"="ldr {{d}}, [{{n}}, #{{off}}]"{role_ld}{nd} {{
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load {T}, ptr %p
  ret {T} %v
}}

define void @STR{R}ui.{tag}({T} "reg"="{c}" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="{st_ui} imm12:12=off/{scale} n:5 t:5" "asm"="str {{t}}, [{{n}}, #{{off}}]"{role_st}{nd} {{
  %p = getelementptr i8, ptr %n, i64 %off
  store {T} %t, ptr %p
  ret void
}}

define {T} @LDUR{R}.{tag}(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="{ld_u} 0 off:s9 00 n:5 d:5" "asm"="ldur {{d}}, [{{n}}, #{{off}}]"{nd} {{
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load {T}, ptr %p
  ret {T} %v
}}

define void @STUR{R}.{tag}({T} "reg"="{c}" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="{st_u} 0 off:s9 00 n:5 t:5" "asm"="stur {{t}}, [{{n}}, #{{off}}]"{nd} {{
  %p = getelementptr i8, ptr %n, i64 %off
  store {T} %t, ptr %p
  ret void
}}

define {T} @LDR{R}roX.{tag}(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="{ld_u} 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {{d}}, [{{n}}, {{m}}, lsl #{sh}]"{nd} {{
  %o = shl i64 %m, {sh}
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load {T}, ptr %p
  ret {T} %v
}}

define void @STR{R}roX.{tag}({T} "reg"="{c}" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="{st_u} 1 m:5 011 1 10 n:5 t:5" "asm"="str {{t}}, [{{n}}, {{m}}, lsl #{sh}]"{nd} {{
  %o = shl i64 %m, {sh}
  %p = getelementptr i8, ptr %n, i64 %o
  store {T} %t, ptr %p
  ret void
}}

define {{ {T}, ptr }} @LDR{R}post.{tag}(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="{ld_u} 0 off:s9 01 n:5 d:5" "asm"="ldr {{d}}, [{{n}}], #{{off}}"{nd} {{
  %v = load {T}, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue {{ {T}, ptr }} poison, {T} %v, 0
  %b = insertvalue {{ {T}, ptr }} %a, ptr %next, 1
  ret {{ {T}, ptr }} %b
}}

define ptr @STR{R}post.{tag}({T} "reg"="{c}" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="{st_u} 0 off:s9 01 n:5 t:5" "asm"="str {{t}}, [{{n}}], #{{off}}"{nd} {{
  store {T} %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}}
''')
o.append('''define <2 x i64> @MOVIzero() "enc"="0 1 1 0111100000 000 1110 01 00000 d:5" "asm"="movi {d:2d}, #0" "role"="movi.zero" "nomatch" {
  ret <2 x i64> zeroinitializer
}

define <2 x i64> @MOVq(<2 x i64> "reg"="q" %n) "enc"="0 1 0 01110 10 1 m:5=n 00011 1 n:5 d:5" "asm"="mov {d:16b}, {n:16b}" "copy"="q" "nomatch" {
  ret <2 x i64> %n
}
''')
out.append("\n".join(o))

# --- appended: more shapes the legaliser makes
o = []
# lane moves on 64-bit vectors
for e, lanes in [(8,8),(16,4),(32,2)]:
    T = vt(lanes, it(e)); s = suffix(e); k = {8:1,16:2,32:4}[e]
    o.append(f'''define {it(e)} @UMOV{s}64({T} "reg"="v" %n, i64 "imm" %idx) "enc"="0 0 0 01110000 imm5:5=idx*{2*k}+{k} 0 0111 1 n:5 d:5" "asm"="{'mov' if e >= 32 else 'umov'} {{d}}, {{n:.{s}}}[{{idx}}]" "nodecode" {{
  %r = extractelement {T} %n, i64 %idx
  ret {it(e)} %r
}}

define {T} @INS{s}64({T} "reg"="v" "tied" %old, {it(e)} "reg"="w" %n, i64 "imm" %idx) "enc"="0 1 0 01110000 imm5:5=idx*{2*k}+{k} 0 0011 1 n:5 d:5" "asm"="mov {{d:.{s}}}[{{idx}}], {{n}}" "nodecode" {{
  %r = insertelement {T} %old, {it(e)} %n, i64 %idx
  ret {T} %r
}}
''')
# widening from the low half of a q register, and widening multiplies
for (src, dst, n, e, sxt, size) in [('8b','8h',8,8,'0001000','00'),('4h','4s',4,16,'0010000','01'),('2s','2d',2,32,'0100000','10')]:
    S = vt(n, it(e)); D = vt(n, it(2*e)); W = vt(2*n, it(e))
    lo = ', '.join(f'i32 {k}' for k in range(n)); hi = ', '.join(f'i32 {k}' for k in range(n, 2*n))
    for name, U, ext in [('SXTL',0,'sext'),('UXTL',1,'zext')]:
        o.append(f'''define {D} @{name}lo{dst}({W} "reg"="q" %n) "enc"="0 0 {U} 011110 {sxt} 10100 1 n:5 d:5" "asm"="{name.lower()} {{d:{dst}}}, {{n:{src}}}" "nodecode" {{
  %h = shufflevector {W} %n, {W} poison, <{n} x i32> <{lo}>
  %r = {ext} {S} %h to {D}
  ret {D} %r
}}
''')
    for name, U, ext in [('SMULL',0,'sext'),('UMULL',1,'zext')]:
        o.append(f'''define {D} @{name}v{dst}({S} "reg"="v" %n, {S} "reg"="v" %m) "enc"="0 0 {U} 01110 {size} 1 m:5 1100 00 n:5 d:5" "asm"="{name.lower()} {{d:{dst}}}, {{n:{src}}}, {{m:{src}}}" {{
  %a = {ext} {S} %n to {D}
  %b = {ext} {S} %m to {D}
  %r = mul {D} %a, %b
  ret {D} %r
}}

define {D} @{name}lo{dst}({W} "reg"="q" %n, {W} "reg"="q" %m) "enc"="0 0 {U} 01110 {size} 1 m:5 1100 00 n:5 d:5" "asm"="{name.lower()} {{d:{dst}}}, {{n:{src}}}, {{m:{src}}}" "nodecode" {{
  %hn = shufflevector {W} %n, {W} poison, <{n} x i32> <{lo}>
  %hm = shufflevector {W} %m, {W} poison, <{n} x i32> <{lo}>
  %a = {ext} {S} %hn to {D}
  %b = {ext} {S} %hm to {D}
  %r = mul {D} %a, %b
  ret {D} %r
}}

define {D} @{name}2{dst}({W} "reg"="q" %n, {W} "reg"="q" %m) "enc"="0 1 {U} 01110 {size} 1 m:5 1100 00 n:5 d:5" "asm"="{name.lower()}2 {{d:{dst}}}, {{n:{2*n}{suffix(e)}}}, {{m:{2*n}{suffix(e)}}}" {{
  %hn = shufflevector {W} %n, {W} poison, <{n} x i32> <{hi}>
  %hm = shufflevector {W} %m, {W} poison, <{n} x i32> <{hi}>
  %a = {ext} {S} %hn to {D}
  %b = {ext} {S} %hm to {D}
  %r = mul {D} %a, %b
  ret {D} %r
}}
''')
out.append("\n".join(o))

# --- appended: reductions of 64-bit vectors
o = []
o.append('''define <2 x i32> @ADDPv2s(<2 x i32> "reg"="v" %n, <2 x i32> "reg"="v" %m) "enc"="0 0 0 01110 10 1 m:5 10111 1 n:5 d:5" "asm"="addp {d:2s}, {n:2s}, {m:2s}" "nomatch" {
  ret <2 x i32> %n
}

declare i32 @llvm.vector.reduce.add.v2i32(<2 x i32>)

define i32 @reduce.add.v2i32(<2 x i32> "reg"="v" %v) "recipe"="reduce.add.v2i32.expand" {
  %r = call i32 @llvm.vector.reduce.add.v2i32(<2 x i32> %v)
  ret i32 %r
}

define i32 @reduce.add.v2i32.expand(<2 x i32> %v) {
  %t = call <2 x i32> @ADDPv2s(<2 x i32> %v, <2 x i32> %v)
  %r = call i32 @UMOVs64(<2 x i32> %t, i64 0)
  ret i32 %r
}
''')
o.append('''; Population counts: the bits set in each byte. A scalar's count is the
; bytes' counts summed (60-recipes.ll).
declare <8 x i8> @llvm.ctpop.v8i8(<8 x i8>)

define <8 x i8> @CNT8b(<8 x i8> "reg"="v" %n) "enc"="0 0 0 01110 00 10000 00101 10 n:5 d:5" "asm"="cnt {d:8b}, {n:8b}" {
  %r = call <8 x i8> @llvm.ctpop.v8i8(<8 x i8> %n)
  ret <8 x i8> %r
}

; A general register's bits into the low half of a vector register (the
; rest zero), as fmov d, x and fmov s, w do.
define <8 x i8> @FMOVvX(i64 "reg"="x" %n) "enc"="1 00 11110 01 1 00 111 000000 n:5 d:5" "asm"="fmov {d:d}, {n}" "nodecode" {
  %r = bitcast i64 %n to <8 x i8>
  ret <8 x i8> %r
}

define <8 x i8> @FMOVvW(i32 "reg"="w" %n) "enc"="0 00 11110 00 1 00 111 000000 n:5 d:5" "asm"="fmov {d:s}, {n}" "nodecode" {
  %z = zext i32 %n to i64
  %r = bitcast i64 %z to <8 x i8>
  ret <8 x i8> %r
}

; And back: a 64-bit vector's bits into a general register.
define i64 @FMOVXv(<8 x i8> "reg"="v" %n) "enc"="1 00 11110 01 1 00 110 000000 n:5 d:5" "asm"="fmov {d}, {n:d}" "nodecode" {
  %r = bitcast <8 x i8> %n to i64
  ret i64 %r
}
''')
for arr, n, e, size in [('8b',8,8,'00'),('4h',4,16,'01')]:
  T = vt(n, it(e)); s = suffix(e)
  for name, U, op, red in [('ADDV',0,'11011','add'),('SMAXV',0,'01010','smax'),('SMINV',0,'11010','smin'),('UMAXV',1,'01010','umax'),('UMINV',1,'11010','umin')]:
    o.append(f'''define {T} @{name}{arr}({T} "reg"="v" %n) "enc"="0 0 {U} 01110 {size} 11000 {op} 10 n:5 d:5" "asm"="{name.lower()} {{d:{s}}}, {{n:{arr}}}" "nomatch" {{
  ret {T} %n
}}

declare {it(e)} @llvm.vector.reduce.{red}.v{n}i{e}({T})

define {it(e)} @reduce.{red}.v{n}i{e}({T} "reg"="v" %v) "recipe"="reduce.{red}.v{n}i{e}.expand" {{
  %r = call {it(e)} @llvm.vector.reduce.{red}.v{n}i{e}({T} %v)
  ret {it(e)} %r
}}

define {it(e)} @reduce.{red}.v{n}i{e}.expand({T} %v) {{
  %t = call {T} @{name}{arr}({T} %v)
  %r = call {it(e)} @UMOV{s}64({T} %t, i64 0)
  ret {it(e)} %r
}}
''')
out.append("\n".join(o))

# --- appended: float widening and narrowing
out.append('''
define <2 x double> @FCVTL2d(<2 x float> "reg"="v" %n) "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" {
  %r = fpext <2 x float> %n to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTLlo2d(<4 x float> "reg"="q" %n) "enc"="0 0 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl {d:2d}, {n:2s}" "nodecode" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 0, i32 1>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x double> @FCVTL22d(<4 x float> "reg"="q" %n) "enc"="0 1 0 01110 0 1 10000 10111 10 n:5 d:5" "asm"="fcvtl2 {d:2d}, {n:4s}" {
  %h = shufflevector <4 x float> %n, <4 x float> poison, <2 x i32> <i32 2, i32 3>
  %r = fpext <2 x float> %h to <2 x double>
  ret <2 x double> %r
}

define <2 x float> @FCVTN2s(<2 x double> "reg"="q" %n) "enc"="0 0 0 01110 0 1 10000 10110 10 n:5 d:5" "asm"="fcvtn {d:2s}, {n:2d}" {
  %r = fptrunc <2 x double> %n to <2 x float>
  ret <2 x float> %r
}

define <4 x float> @FCVTN24s(<2 x float> "reg"="v" "tied" %lo, <2 x double> "reg"="q" %m) "enc"="0 1 0 01110 0 1 10000 10110 10 m:5 d:5" "asm"="fcvtn2 {d:4s}, {m:2d}" {
  %t = fptrunc <2 x double> %m to <2 x float>
  %r = shufflevector <2 x float> %lo, <2 x float> %t, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x float> %r
}
''')

# --- appended: lane reversals within each 64 bits, and the swap of two
# 64-bit lanes
o = []
shapes = [(arr, n, it(e), Q, size, e) for arr, n, e, Q, size in INT] + [(arr, n, ty, Q, None, 32 if ty == 'float' else 64) for arr, n, ty, Q, sz in FLT]
for arr, n, ty, Q, size, e in shapes:
    T = vt(n, ty); c = cls(Q); tag = arr + ('f' if ty in ('float', 'double') else '')
    if e < 64:
        size = {8: '00', 16: '01', 32: '10'}[e]
        g = 64 // e
        mask = ', '.join(f'i32 {(k // g) * g + (g - 1 - k % g)}' for k in range(n))
        o.append(f'''define {T} @REV64v{tag}({T} "reg"="{c}" %n) "enc"="0 {Q} 0 01110 {size} 10000 00000 10 n:5 d:5" "asm"="rev64 {{d:{arr}}}, {{n:{arr}}}"{' "nodecode"' if tag.endswith('f') else ''} {{
  %r = shufflevector {T} %n, {T} poison, <{n} x i32> <{mask}>
  ret {T} %r
}}
''')
    else:
        o.append(f'''define {T} @SWAPv{tag}({T} "reg"="q" %n) "enc"="0 1 10 1110 00 0 rm:5=n 0 1000 0 n:5 d:5" "asm"="ext {{d:16b}}, {{n:16b}}, {{n:16b}}, #8"{'' if tag == '2d' else ' "nodecode"'} {{
  %r = shufflevector {T} %n, {T} poison, <2 x i32> <i32 1, i32 0>
  ret {T} %r
}}
''')
out.append("\n".join(o))

# --- appended: tests for nonzero lanes, shifts by each lane's own amount,
# and logic on masks
o = []
for arr, n, e, Q, size in INT:
    T = vt(n, it(e)); M = vt(n, 'i1'); c = cls(Q)
    o.append(f'''define {M} @CMTSTv{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 0 01110 {size} 1 m:5 10001 1 n:5 d:5" "asm"="cmtst {{d:{arr}}}, {{n:{arr}}}, {{m:{arr}}}" "dclass"="q" {{
  %a = and {T} %n, %m
  %r = icmp ne {T} %a, zeroinitializer
  ret {M} %r
}}

define {M} @CMNEZv{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} 0 01110 {size} 1 rm:5=n 10001 1 n:5 d:5" "asm"="cmtst {{d:{arr}}}, {{n:{arr}}}, {{n:{arr}}}" "dclass"="q" "nodecode" {{
  %r = icmp ne {T} %n, zeroinitializer
  ret {M} %r
}}
''')
    for name, U in [('USHL', 1), ('SSHL', 0)]:
        f = f'llvm.aarch64.neon.{name.lower()}.v{n}i{e}'
        o.append(f'''declare {T} @{f}({T}, {T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {size} 1 m:5 01000 1 n:5 d:5" "asm"="{name.lower()} {{d:{arr}}}, {{n:{arr}}}, {{m:{arr}}}" {{
  %r = call {T} @{f}({T} %n, {T} %m)
  ret {T} %r
}}
''')
    # Shifts by a vector of amounts: ushl and sshl shift each lane left by
    # its own amount, or right by a negative one.
    for ir, name, neg in [('shl', 'USHL', False), ('lshr', 'USHL', True), ('ashr', 'SSHL', True)]:
        amount = f'%m' if not neg else '%neg'
        negate = f'  %neg = call {T} @NEGv{arr}({T} %m)\n' if neg else ''
        o.append(f'''define {T} @{ir}.v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "recipe"="{ir}.v{arr}.expand" {{
  %r = {ir} {T} %n, %m
  ret {T} %r
}}

define {T} @{ir}.v{arr}.expand({T} %n, {T} %m) {{
{negate}  %r = call {T} @{name}v{arr}({T} %n, {T} {amount})
  ret {T} %r
}}
''')
for n in [16, 8, 4, 2]:
    M = vt(n, 'i1')
    for name, ir, opc in [('ANDm', 'and', '0 01110 00'), ('ORRm', 'or', '0 01110 10'), ('EORm', 'xor', '1 01110 00')]:
        o.append(f'''define {M} @{name}{n}({M} "reg"="q" %n, {M} "reg"="q" %m) "enc"="0 1 {opc} 1 m:5 00011 1 n:5 d:5" "asm"="{name[:3].lower()} {{d:16b}}, {{n:16b}}, {{m:16b}}" "dclass"="q" "nodecode" {{
  %r = {ir} {M} %n, %m
  ret {M} %r
}}
''')
out.append("\n".join(o))

# --- appended: intrinsics of Advanced SIMD's own (from Rust's and C's
# NEON intrinsics): pairwise maximum, minimum and sum, doubling multiplies
# returning the high half, and table lookup
o = []
for arr, n, e, Q, size in INT:
    T = vt(n, it(e)); c = cls(Q)
    # (ADDPv2s is above, for reductions.)
    ops = [] if arr == '2s' else [('addp', 'ADDP', 0, '10111')]
    if e <= 32:
        ops += [('umaxp', 'UMAXP', 1, '10100'), ('uminp', 'UMINP', 1, '10101'),
                ('smaxp', 'SMAXP', 0, '10100'), ('sminp', 'SMINP', 0, '10101')]
    if e in (16, 32):
        ops += [('sqdmulh', 'SQDMULH', 0, '10110'), ('sqrdmulh', 'SQRDMULH', 1, '10110')]
    for intr, name, U, opc in ops:
        f = f'llvm.aarch64.neon.{intr}.v{n}i{e}'
        o.append(f'''declare {T} @{f}({T}, {T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} {U} 01110 {size} 1 m:5 {opc} 1 n:5 d:5" "asm"="{intr} {{d:{arr}}}, {{n:{arr}}}, {{m:{arr}}}" {{
  %r = call {T} @{f}({T} %n, {T} %m)
  ret {T} %r
}}
''')
# dup of lane 0: the first lane in every lane. (Other lanes are taken out
# and splatted from a general register, see legalize.rs.)
for arr, n, ty, Q, imm5, s_ in [(a, n, it(e), Q, {8: '00001', 16: '00010', 32: '00100', 64: '01000'}[e], suffix(e))
                                for a, n, e, Q, _ in INT] + \
        [(a, n, ty, Q, '00100' if ty == 'float' else '01000', 's' if ty == 'float' else 'd') for a, n, ty, Q, _ in FLT]:
    T = vt(n, ty); c = cls(Q)
    o.append(f'''define {T} @DUP0v{arr}{'f' if ty in ('float', 'double') else ''}({T} "reg"="{c}" %n) "enc"="0 {Q} 0 01110000 {imm5} 0 0000 1 n:5 d:5" "asm"="dup {{d:{arr}}}, {{n:.{s_}}}[0]" {{
  %r = shufflevector {T} %n, {T} poison, <{n} x i32> zeroinitializer
  ret {T} %r
}}
''')
# Absolute value and rounding of floating-point lanes.
for arr, n, ty, Q, sz in FLT:
    T = vt(n, ty); c = cls(Q); suf = 'f32' if ty == 'float' else 'f64'
    for name, intr, U, a_, op in [('FABS', 'fabs', 0, 1, '01111'), ('FRINTN', 'roundeven', 0, 0, '11000'),
                                  ('FRINTM', 'floor', 0, 0, '11001'), ('FRINTP', 'ceil', 0, 1, '11000'),
                                  ('FRINTZ', 'trunc', 0, 1, '11001'), ('FRINTA', 'round', 1, 0, '11000'),
                                  ('FRINTX', 'rint', 1, 0, '11001'), ('FRINTI', 'nearbyint', 1, 1, '11001'),
                                  ('FSQRT', 'sqrt', 1, 1, '11111')]:
        f = f'llvm.{intr}.v{n}{suf}'
        o.append(f'''declare {T} @{f}({T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n) "enc"="0 {Q} {U} 01110 {a_} {sz} 10000 {op} 10 n:5 d:5" "asm"="{name.lower()} {{d:{arr}}}, {{n:{arr}}}" {{
  %r = call {T} @{f}({T} %n)
  ret {T} %r
}}
''')
# Minimum and maximum of floating-point lanes (as the scalar ones).
for arr, n, ty, Q, sz in FLT:
    T = vt(n, ty); c = cls(Q); suf = 'f32' if ty == 'float' else 'f64'
    for name, intr, a_, op in [('FMAXNM', 'maxnum', 0, '110001'), ('FMINNM', 'minnum', 1, '110001'),
                               ('FMAX', 'maximum', 0, '111101'), ('FMIN', 'minimum', 1, '111101')]:
        f = f'llvm.{intr}.v{n}{suf}'
        o.append(f'''declare {T} @{f}({T}, {T})

define {T} @{name}v{arr}({T} "reg"="{c}" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 0 01110 {a_} {sz} 1 m:5 {op} n:5 d:5" "asm"="{name.lower()} {{d:{arr}}}, {{n:{arr}}}, {{m:{arr}}}" {{
  %r = call {T} @{f}({T} %n, {T} %m)
  ret {T} %r
}}
''')
# tbl: each lane of the indices picks a byte of the 16-byte table (one
# register), or zero past it.
for arr, n, Q in [('16b', 16, 1), ('8b', 8, 0)]:
    T = vt(n, 'i8'); c = cls(Q)
    f = f'llvm.aarch64.neon.tbl1.v{n}i8'
    o.append(f'''declare {T} @{f}(<16 x i8>, {T})

define {T} @TBL1v{arr}(<16 x i8> "reg"="q" %n, {T} "reg"="{c}" %m) "enc"="0 {Q} 001110 000 m:5 0 00 0 00 n:5 d:5" "asm"="tbl {{d:{arr}}}, {{lb}}{{n:16b}}{{rb}}, {{m:{arr}}}" {{
  %r = call {T} @{f}(<16 x i8> %n, {T} %m)
  ret {T} %r
}}
''')
out.append("\n".join(o))


def write():
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "50-vectors.ll")
    # Every entry needs Advanced SIMD.
    lines = []
    for line in "".join(out).rstrip("\n").split("\n"):
        if line.startswith("define") and '"enc"=' in line:
            line = line.replace(' "enc"=', ' "feature"="neon" "enc"=', 1)
        lines.append(line)
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n\n")


write()
