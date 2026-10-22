#!/usr/bin/env python3
"""Writes 10-integer.ll: x86-64's integer instructions for selection, with
bodies (what each does, as IR), from tables. The encodings use the
fragments of 00-base.ll; the AT&T templates are as llvm-mc writes them
(tests/x86.rs checks every entry against it).

x86's arithmetic is two-address: the destination is also the first
source (a "tied" operand). Most of it writes the flags, which the code
generator is told ("clobbers"="flags"). `lea` adds without touching them,
three-address, for the code generator's own adds (roles addi, add).

Usage: gen_sel.py > 10-integer.ll
"""

import sys

out = []

# Width: (IR type, class, REX.W, suffix, bits).
W = {64: ('i64', 'r64', 1, 'q', 64), 32: ('i32', 'r32', 0, 'l', 32)}
CC = [('o', 0), ('no', 1), ('b', 2), ('ae', 3), ('e', 4), ('ne', 5), ('be', 6), ('a', 7), ('s', 8), ('ns', 9),
      ('p', 10), ('np', 11), ('l', 12), ('ge', 13), ('le', 14), ('g', 15)]


def bits(v, n=8):
    return format(v, f'0{n}b')


def entry(ret, name, params, enc, asm, body, attrs=''):
    """An entry: `body` is the IR lines between braces. (None is read by the
    disassembler: 80-xed.ll's entries are.)"""
    if '"nodecode"' not in attrs:
        attrs += ' "nodecode"'
    out.append(f'define {ret} @{name}({", ".join(params)}) "enc"="{enc}" "asm"="{asm}"{attrs} {{\n'
               + ''.join(f'  {line}\n' for line in body) + '}\n')


FLAGS = ' "clobbers"="flags"'


def alu():
    # add, or, adc, sbb, and, sub, xor, cmp: their numbers.
    ops = [('add', 0, 'add'), ('or', 1, 'or'), ('and', 4, 'and'), ('sub', 5, 'sub'), ('xor', 6, 'xor')]
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        zext = '' if w == 64 else ' "zext"="32"'
        for mn, n, ir in ops:
            N = mn.upper() + str(w)
            # op m, d: d = d op m (01 + 8n /r: ModRM.reg the source).
            entry(ty, f'{N}rr', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "reg"="{cls}" %m'],
                  f'rex({rw}, m, 0, d) | {bits(n * 8 + 1)} | rr(m, d)', f'{mn}{sfx} {{m}}, {{d}}',
                  [f'%r = {ir} {ty} %n, %m', f'ret {ty} %r'], FLAGS + zext)
            # op $imm, d: a byte if it fits (83 /n), else 32 bits (81 /n).
            # (The accumulator's own form, 05 + 8n, where the byte does not
            # hold the immediate: as llvm-mc writes it.)
            entry(ty, f'{N}ri', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "imm" %imm'],
                  f'{{ rex({rw}, 0, 0, d) | 10000011 | rr({n}, d) | ib:s8=imm ; '
                  f'acc:0=d rex({rw}, 0, 0, 0) | {bits(n * 8 + 5)} | iv:s32=imm ; '
                  f'rex({rw}, 0, 0, d) | 10000001 | rr({n}, d) | iv:s32=imm }}',
                  f'{mn}{sfx} ${{imm}}, {{d}}', [f'%r = {ir} {ty} %n, %imm', f'ret {ty} %r'], FLAGS + zext)
        # imul m, d (0F AF /r: ModRM.reg the destination).
        entry(ty, f'IMUL{w}rr', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "reg"="{cls}" %m'],
              f'rex({rw}, d, 0, m) | 00001111 | 10101111 | rr(d, m)', f'imul{sfx} {{m}}, {{d}}',
              ['%r = mul ' + ty + ' %n, %m', f'ret {ty} %r'], FLAGS + zext)
        # imul $imm, n, d: three-address.
        entry(ty, f'IMUL{w}rri', [f'{ty} "reg"="{cls}" %n', f'{ty} "imm" %imm'],
              f'{{ rex({rw}, d, 0, n) | 01101011 | rr(d, n) | ib:s8=imm ; '
              f'rex({rw}, d, 0, n) | 01101001 | rr(d, n) | iv:s32=imm }}',
              f'imul{sfx} ${{imm}}, {{n}}, {{d}}', [f'%r = mul {ty} %n, %imm', f'ret {ty} %r'], FLAGS + zext)
        # Shifts: by an immediate (C1 /r ib), or by cl (D3 /r).
        for mn, r, ir in [('shl', 4, 'shl'), ('shr', 5, 'lshr'), ('sar', 7, 'ashr')]:
            N = mn.upper() + str(w)
            # (By one, D1 /r, as llvm-mc writes it.)
            entry(ty, f'{N}ri', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "imm" %imm'],
                  f'{{ one:0=imm-1 rex({rw}, 0, 0, d) | 11010001 | rr({r}, d) ; '
                  f'rex({rw}, 0, 0, d) | 11000001 | rr({r}, d) | ib:8=imm }}', f'{mn}{sfx} ${{imm}}, {{d}}',
                  [f'%r = {ir} {ty} %n, %imm', f'ret {ty} %r'], FLAGS + zext)
            entry(ty, f'{N}rCL', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "reg"="rcx" %c'],
                  f'rex({rw}, 0, 0, d) | 11010011 | rr({r}, d)', f'{mn}{sfx} %cl, {{d}}',
                  [f'%r = {ir} {ty} %n, %c', f'ret {ty} %r'], FLAGS + zext)
        for mn, r, body in [('neg', 3, f'%r = sub {ty} 0, %n'), ('not', 2, f'%r = xor {ty} %n, -1')]:
            entry(ty, f'{mn.upper()}{w}r', [f'{ty} "reg"="{cls}" "tied" %n'],
                  f'rex({rw}, 0, 0, d) | 11110111 | rr({r}, d)', f'{mn}{sfx} {{d}}', [body, f'ret {ty} %r'],
                  (FLAGS if mn == 'neg' else '') + zext)


def moves():
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        zext = '' if w == 64 else ' "zext"="32"'
        entry(ty, f'MOV{w}rr', [f'{ty} "reg"="{cls}" %n'], f'rex({rw}, n, 0, d) | 10001001 | rr(n, d)',
              f'mov{sfx} {{n}}, {{d}}', [f'ret {ty} %n'], f' "copy"="{cls}"' + zext)
    # Constants: movl zero-extends (B8+r id), movq sign-extends 32 bits
    # (C7 /0 id), movabsq has all 64.
    entry('i32', 'MOV32ri', ['i32 "imm" %imm'], '{ rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:s32=imm ; '
          'rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:32=imm }', 'movl ${imm}, {d}', ['ret i32 %imm'], ' "zext"="32"')
    entry('i64', 'MOV64ri32', ['i64 "imm" %imm'], 'rex(0, 0, 0, d) | 10111 o:3=d&7 | iv:32=imm',
          'movl ${imm}, {d:r32}', ['ret i64 %imm'], ' "nodecode"')
    entry('i64', 'MOV64ri', ['i64 "imm" %imm'], 'rex(1, 0, 0, d) | 11000111 | rr(0, d) | iv:s32=imm',
          'movq ${imm}, {d}', ['ret i64 %imm'])
    entry('i64', 'MOVABS64ri', ['i64 "imm" %imm'], 'rex(1, 0, 0, d) | 10111 o:3=d&7 | io:s64=imm',
          'movabsq ${imm}, {d}', ['ret i64 %imm'])
    # Extensions. A byte register's REX is there whenever it is spl-dil.
    rex8 = lambda r, b, w=0: (f'{{ if({b}<4) rex({w}, {r}, 0, {b}) ; 0100 W:1={w} R:1=({r})>>3 X:1=0 B:1=({b})>>3 }}'
                               if w == 0 else f'rex(1, {r}, 0, {b})')
    for (mn, ext, src, op, dst, roles) in [
            ('movzbl', 'zext', 'i8', '10110110', 32, ',zext.8'), ('movzwl', 'zext', 'i16', '10110111', 32, ',zext.16'),
            ('movsbl', 'sext', 'i8', '10111110', 32, ',sext.8'), ('movswl', 'sext', 'i16', '10111111', 32, ',sext.16'),
            ('movzbl', 'zext', 'i8', '10110110', 64, ''), ('movzwl', 'zext', 'i16', '10110111', 64, ''),
            ('movsbq', 'sext', 'i8', '10111110', 64, ''), ('movswq', 'sext', 'i16', '10111111', 64, '')]:
        ty, cls, rw, sfx, _ = W[dst]
        view = 'r8' if src == 'i8' else 'r16'
        # (Zero-extending to 64 bits is the 32-bit move's: it clears the top.)
        w = 1 if dst == 64 and ext == 'sext' else 0
        d = '{d}' if w else '{d:r32}'
        pre = rex8('d', 'n', w) if src == 'i8' else f'rex({w}, d, 0, n)'
        zb = ' "zext"="' + ('8' if src == 'i8' else '16') + '"' if ext == 'zext' else ''
        role = f' "role"="{roles[1:]}"' if roles else ''
        entry(ty, f'{mn.upper()}{dst}', [f'{src} "reg"="r32" %n'], f'{pre} | 00001111 | {op} | rr(d, n)',
              f'{mn} {{n:{view}}}, {d}', [f'%r = {ext} {src} %n to {ty}', f'ret {ty} %r'], zb + role)
    # A boolean (a byte of 0 or 1, as setcc writes it) widened.
    entry('i32', 'MOVZBL1', ['i1 "reg"="r32" %n'], f'{rex8("d", "n")} | 00001111 | 10110110 | rr(d, n)',
          'movzbl {n:r8}, {d}', ['%r = zext i1 %n to i32', 'ret i32 %r'], ' "zext"="1" "role"="zext.1" "nodecode"')
    entry('i64', 'MOVZBQ1', ['i1 "reg"="r32" %n'], f'{rex8("d", "n")} | 00001111 | 10110110 | rr(d, n)',
          'movzbl {n:r8}, {d:r32}', ['%r = zext i1 %n to i64', 'ret i64 %r'], ' "zext"="1" "nodecode"')
    entry('i64', 'MOVSLQ', ['i32 "reg"="r32" %n'], 'rex(1, d, 0, n) | 01100011 | rr(d, n)', 'movslq {n}, {d}',
          ['%r = sext i32 %n to i64', 'ret i64 %r'], ' "role"="sext.32"')
    # Addresses, three-address and leaving the flags alone: the code
    # generator's adds.
    entry('ptr', 'LEA64ri', ['ptr "reg"="r64" %n', 'i64 "imm" %imm'],
          'rex(1, d, 4, n) | 10001101 | rm(d, n, 4, 1, imm, 0, 1)', 'leaq {imm}({n}), {d}',
          ['%r = getelementptr i8, ptr %n, i64 %imm', 'ret ptr %r'], ' "role"="addi"')
    entry('ptr', 'LEA64rr', ['ptr "reg"="r64" %n', 'i64 "reg"="r64" %m'],
          '{ if(m!=4) rex(1, d, m, n) | 10001101 | rm(d, n, m, 1, 0, 0, 1) }', 'leaq ({n},{m}), {d}',
          ['%r = getelementptr i8, ptr %n, i64 %m', 'ret ptr %r'], ' "role"="add"')
    entry('i64', 'LEA64add', ['i64 "reg"="r64" %n', 'i64 "reg"="r64" %m'],
          '{ if(m!=4) rex(1, d, m, n) | 10001101 | rm(d, n, m, 1, 0, 0, 1) }', 'leaq ({n},{m}), {d}',
          ['%r = add i64 %n, %m', 'ret i64 %r'], ' "nodecode"')
    entry('i64', 'LEA64addi', ['i64 "reg"="r64" %n', 'i64 "imm" %imm'],
          'rex(1, d, 4, n) | 10001101 | rm(d, n, 4, 1, imm, 0, 1)', 'leaq {imm}({n}), {d}',
          ['%r = add i64 %n, %imm', 'ret i64 %r'], ' "nodecode"')
    # A global's address, PC-relative; or its GOT entry's contents.
    entry('ptr', 'LEArip', ['ptr "sym" %s'], 'rex(1, d, 0, 0) | 10001101 | rm(d, 16, 4, 1, 0, s, 1)',
          'leaq {s}(%rip), {d}', ['ret ptr %s'], ' "reloc"="pc32x" "role"="addr" "nomatch" "nodecode"')
    entry('ptr', 'MOVgot', ['ptr "sym" %s'], 'rex(1, d, 0, 0) | 10001011 | rm(d, 16, 4, 1, 0, s, 1)',
          'movq {s}(%rip), {d}', ['ret ptr %s'], ' "reloc"="gotpcrel" "role"="got" "nomatch" "nodecode"')


def memory():
    """Loads and stores at a register plus a displacement."""
    rex8 = lambda r, x, b: (f'{{ if({r}<4) rex(0, {r}, {x}, {b}) ; 0100 0 R:1=({r})>>3 X:1=({x})>>3 B:1=({b})>>3 }}')
    # (By size, x for 8 bytes, and by the class spills and saves are in.)
    loads = [('i64', 'movq', '10001011', 1, 'load.x,load.r64', '', ''), ('i32', 'movl', '10001011', 0, 'load.w', '', '32'),
             ('i8', 'movzbl', '00001111 | 10110110', 0, 'load.b', '', '8'),
             ('i16', 'movzwl', '00001111 | 10110111', 0, 'load.h', '', '16')]
    for ty, mn, op, w, role, _, zext in loads:
        d = '{d}' if ty == 'i64' else '{d:r32}' if ty in ('i8', 'i16') else '{d}'
        cls = 'r64' if ty == 'i64' else 'r32'
        entry(ty, f'LD{ty.upper()}', ['ptr "reg"="r64" %n', 'i64 "imm" %off'],
              f'rex({w}, d, 4, n) | {op} | rm(d, n, 4, 1, off, 0, 1)', f'{mn} {{off}}({{n}}), {d}',
              ['%a = getelementptr i8, ptr %n, i64 %off', f'%r = load {ty}, ptr %a', f'ret {ty} %r'],
              f' "role"="{role}"' + (f' "zext"="{zext}"' if zext else '') + f' "dclass"="{cls}"')
    entry('ptr', 'LDP', ['ptr "reg"="r64" %n', 'i64 "imm" %off'], 'rex(1, d, 4, n) | 10001011 | rm(d, n, 4, 1, off, 0, 1)',
          'movq {off}({n}), {d}', ['%a = getelementptr i8, ptr %n, i64 %off', '%r = load ptr, ptr %a', 'ret ptr %r'],
          ' "nodecode"')
    # Sign-extending loads.
    for ty, src, mn, op, w in [('i32', 'i8', 'movsbl', '00001111 | 10111110', 0),
                               ('i32', 'i16', 'movswl', '00001111 | 10111111', 0),
                               ('i64', 'i8', 'movsbq', '00001111 | 10111110', 1),
                               ('i64', 'i16', 'movswq', '00001111 | 10111111', 1),
                               ('i64', 'i32', 'movslq', '01100011', 1)]:
        entry(ty, f'LD{src.upper()}S{ty[1:]}', ['ptr "reg"="r64" %n', 'i64 "imm" %off'],
              f'rex({w}, d, 4, n) | {op} | rm(d, n, 4, 1, off, 0, 1)', f'{mn} {{off}}({{n}}), {{d}}',
              ['%a = getelementptr i8, ptr %n, i64 %off', f'%v = load {src}, ptr %a', f'%r = sext {src} %v to {ty}',
               f'ret {ty} %r'])
    stores = [('i64', 'movq', '10001001', 1, 'store.x,store.r64', '{t}', 'r64'), ('i32', 'movl', '10001001', 0, 'store.w', '{t}', 'r32'),
              ('i16', 'movw', '10001001', 0, 'store.h', '{t:r16}', 'r32'), ('i8', 'movb', '10001000', 0, 'store.b', '{t:r8}', 'r32')]
    for ty, mn, op, w, role, t, cls in stores:
        pre = '01100110 | ' if ty == 'i16' else ''
        rx = rex8('t', 4, 'n') if ty == 'i8' else f'rex({w}, t, 4, n)'
        entry('void', f'ST{ty.upper()}', [f'{ty} "reg"="{cls}" %t', 'ptr "reg"="r64" %n', 'i64 "imm" %off'],
              f'{pre}{rx} | {op} | rm(t, n, 4, 1, off, 0, 1)', f'{mn} {t}, {{off}}({{n}})',
              ['%a = getelementptr i8, ptr %n, i64 %off', f'store {ty} %t, ptr %a', 'ret void'], f' "role"="{role}"')
    entry('void', 'STP', ['ptr "reg"="r64" %t', 'ptr "reg"="r64" %n', 'i64 "imm" %off'],
          'rex(1, t, 4, n) | 10001001 | rm(t, n, 4, 1, off, 0, 1)', 'movq {t}, {off}({n})',
          ['%a = getelementptr i8, ptr %n, i64 %off', 'store ptr %t, ptr %a', 'ret void'], ' "nodecode"')


def compares():
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        ext = [] if w == 64 else [f'%a = sext i32 %n to i64', f'%b = sext i32 %m to i64']
        a, b = ('%n', '%m') if w == 64 else ('%a', '%b')
        # cmp m, n: the flags of n - m (39 /r).
        entry('%flags', f'CMP{w}rr', [f'{ty} "reg"="{cls}" %n', f'{ty} "reg"="{cls}" %m'],
              f'rex({rw}, m, 0, n) | 00111001 | rr(m, n)', f'cmp{sfx} {{m}}, {{n}}',
              ext + [f'%f0 = insertvalue %flags poison, i64 {a}, 0', f'%f = insertvalue %flags %f0, i64 {b}, 1',
                     'ret %flags %f'], ' "sets"="zcso"')
        ext2 = [] if w == 64 else [f'%a = sext i32 %n to i64', f'%b = sext i32 %imm to i64']
        b2 = '%imm' if w == 64 else '%b'
        entry('%flags', f'CMP{w}ri', [f'{ty} "reg"="{cls}" %n', f'{ty} "imm" %imm'],
              f'{{ rex({rw}, 0, 0, n) | 10000011 | rr(7, n) | ib:s8=imm ; '
              f'acc:0=n rex({rw}, 0, 0, 0) | 00111101 | iv:s32=imm ; '
              f'rex({rw}, 0, 0, n) | 10000001 | rr(7, n) | iv:s32=imm }}', f'cmp{sfx} ${{imm}}, {{n}}',
              ext2 + [f'%f0 = insertvalue %flags poison, i64 {a}, 0', f'%f = insertvalue %flags %f0, i64 {b2}, 1',
                      'ret %flags %f'], ' "sets"="zcso"')
        # test m, n: the flags of n & m compared with 0.
        x = [f'%r = and {ty} %n, %m'] + ([] if w == 64 else ['%x = sext i32 %r to i64'])
        entry('%flags', f'TEST{w}rr', [f'{ty} "reg"="{cls}" %n', f'{ty} "reg"="{cls}" %m'],
              f'rex({rw}, m, 0, n) | 10000101 | rr(m, n)', f'test{sfx} {{m}}, {{n}}',
              x + [f'%f0 = insertvalue %flags poison, i64 {"%r" if w == 64 else "%x"}, 0',
                   '%f = insertvalue %flags %f0, i64 0, 1', 'ret %flags %f'], ' "sets"="zcso"')


def control():
    entry('void', 'JMP', ['ptr "label" %dest'], '{ 11101011 | rel:s8=dest-end ; 11101001 | rel:s32=dest-end }',
          'jmp {dest}', ['indirectbr ptr %dest, []'], ' "role"="jump"')
    entry('void', 'JCC', ['i1 "cond" %c', 'ptr "label" %dest'],
          '{ 0111 cc:4=c | rel:s8=dest-end ; 00001111 | 1000 cc:4=c | rel:s32=dest-end }', 'j{c} {dest}',
          ['br i1 %c, label %taken, label %next', 'taken:', 'indirectbr ptr %dest, []', 'next:', 'ret void'],
          ' "inverse"="JCC"')
    entry('void', 'CALL', ['ptr "sym" %s'], '11101000 | rel:s32=s-end', 'callq {s}', ['ret void'],
          ' "reloc"="plt32" "role"="call" "nomatch"')
    entry('void', 'TAILJMP', ['ptr "sym" %s'], '11101001 | rel:s32=s-end', 'jmp {s}', ['ret void'],
          ' "reloc"="plt32" "role"="tailcall" "nomatch" "nodecode"')
    entry('void', 'CALLr', ['ptr "reg"="r64" %n'], 'rex(0, 0, 0, n) | 11111111 | rr(2, n)', 'callq *{n}', ['ret void'],
          ' "role"="callr" "nomatch"')
    entry('void', 'RET', [], '11000011', 'retq', ['ret void'], ' "role"="ret"')
    entry('void', 'UD2', [], '00001111 | 00001011', 'ud2', ['unreachable'], ' "role"="trap"')
    # setcc writes a byte: 0 or 1.
    entry('i1', 'SETCC', ['i1 "cond" %c'],
          '{ if(d<4) 00001111 | 1001 cc:4=c | 11 000 rm:3=d&7 ; '
          '0100 0 0 0 B:1=d>>3 | 00001111 | 1001 cc:4=c | 11 000 rm:3=d&7 }',
          'set{c} {d:r8}', ['ret i1 %c'], ' "dclass"="r32"')
    # select: the second value, then the first moved over it if c.
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        entry(ty, f'CMOV{w}', ['i1 "cond" %c', f'{ty} "reg"="{cls}" %n', f'{ty} "reg"="{cls}" "tied" %m'],
              f'rex({rw}, d, 0, n) | 00001111 | 0100 cc:4=c | rr(d, n)', f'cmov{{c}}{sfx} {{n}}, {{d}}',
              [f'%r = select i1 %c, {ty} %n, {ty} %m', f'ret {ty} %r'], '' if w == 64 else ' "zext"="32"')
    entry('ptr', 'CMOVP', ['i1 "cond" %c', 'ptr "reg"="r64" %n', 'ptr "reg"="r64" "tied" %m'],
          'rex(1, d, 0, n) | 00001111 | 0100 cc:4=c | rr(d, n)', 'cmov{c}q {n}, {d}',
          ['%r = select i1 %c, ptr %n, ptr %m', 'ret ptr %r'], ' "nodecode"')


def division():
    """Division: rdx:rax (or edx:eax) by a register, the quotient in rax and
    the remainder in rdx: fixed registers. Recipes widen the dividend
    first (cqto, or a zero rdx)."""
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        ax, dx = ('rax', 'rdx')
        sign = 'cqto' if w == 64 else 'cltd'
        entry(ty, f'SIGN{w}', [f'{ty} "reg"="{ax}" %a'], ('01001000 | 10011001' if w == 64 else '10011001'), sign,
              [f'%r = ashr {ty} %a, {w - 1}', f'ret {ty} %r'], f' "dclass"="{dx}" "nomatch"')
        for mn, r, op, res, q in [('idiv', 7, 'sdiv', ax, 'q'), ('idiv', 7, 'srem', dx, 'r'),
                                  ('div', 6, 'udiv', ax, 'q'), ('div', 6, 'urem', dx, 'r')]:
            other = dx if res == ax else ax
            entry(ty, f'{mn.upper()}{w}{q}', [f'{ty} "reg"="{ax}" %lo', f'{ty} "reg"="{dx}" %hi', f'{ty} "reg"="{cls}" %b'],
                  f'rex({rw}, 0, 0, b) | 11110111 | rr({r}, b)', f'{mn}{sfx} {{b}}',
                  [f'%r = {op} {ty} %lo, %b', f'ret {ty} %r'],
                  f' "dclass"="{res}" "clobbers"="%{other},flags" "nomatch"' + ('' if q == 'q' else ' "nodecode"'))
    # The recipes.
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        for op, signed, mn, q in [('sdiv', True, 'IDIV', 'q'), ('srem', True, 'IDIV', 'r'),
                                  ('udiv', False, 'DIV', 'q'), ('urem', False, 'DIV', 'r')]:
            out.append(f'define {ty} @{op}.{w}({ty} "reg"="{cls}" %a, {ty} "reg"="{cls}" %b) "recipe"="{op}.{w}.expand" {{\n'
                       f'  %r = {op} {ty} %a, %b\n  ret {ty} %r\n}}\n')
            hi = f'%h = call {ty} @SIGN{w}({ty} %a)' if signed else f'%h = call {ty} @MOV{w}zero()'
            out.append(f'define {ty} @{op}.{w}.expand({ty} %a, {ty} %b) {{\n  {hi}\n'
                       f'  %r = call {ty} @{mn}{w}{q}({ty} %a, {ty} %h, {ty} %b)\n  ret {ty} %r\n}}\n')
        # rdx = 0, for unsigned division (a move, leaving the flags).
        entry(ty, f'MOV{w}zero', [], 'rex(0, 0, 0, d) | 10111 o:3=d&7 | 00000000 | 00000000 | 00000000 | 00000000',
              'movl $0, {d:r32}', [f'ret {ty} 0'], ' "nomatch" "nodecode"')


def recipes():
    """Minimum and maximum: compare, then move one over the other if it
    wins."""
    decl = []
    for w in (64, 32):
        ty, cls, rw, sfx, _ = W[w]
        for op, cc in [('smin', 'l'), ('smax', 'g'), ('umin', 'b'), ('umax', 'a')]:
            decl.append(f'declare {ty} @llvm.{op}.i{w}({ty}, {ty})\n')
            out.append(f'define {ty} @{op}.{w}({ty} "reg"="{cls}" %a, {ty} "reg"="{cls}" %b) "recipe"="{op}.{w}.expand" {{\n'
                       f'  %r = call {ty} @llvm.{op}.i{w}({ty} %a, {ty} %b)\n  ret {ty} %r\n}}\n')
            out.append(f'define {ty} @{op}.{w}.expand({ty} %a, {ty} %b) {{\n'
                       f'  %f = call %flags @CMP{w}rr({ty} %a, {ty} %b)\n'
                       f'  %c = call i1 @cc.{cc}(%flags %f)\n'
                       f'  %r = call {ty} @CMOV{w}(i1 %c, {ty} %a, {ty} %b)\n  ret {ty} %r\n}}\n')
    out.extend(decl)
    # A boolean in a register: its low byte tested.
    entry('%flags', 'TESTB1', ['i1 "reg"="r32" %n'],
          '{ acc:0=n 10101000 | 00000001 ; if(n<4) 11110110 | rr(0, n) | 00000001 ; '
          '0100 0 0 0 B:1=n>>3 | 11110110 | rr(0, n) | 00000001 }',
          'testb $1, {n:r8}', ['%x = zext i1 %n to i64', '%f0 = insertvalue %flags poison, i64 %x, 0',
                               '%f = insertvalue %flags %f0, i64 0, 1', 'ret %flags %f'], ' "sets"="zcso" "nomatch"')
    for ty, cls, w in [('i64', 'r64', 64), ('i32', 'r32', 32), ('ptr', 'r64', 'p')]:
        cm = 'CMOVP' if w == 'p' else f'CMOV{w}'
        out.append(f'define {ty} @select.{w}(i1 "reg"="r32" %c, {ty} "reg"="{cls}" %a, {ty} "reg"="{cls}" %b) '
                   f'"recipe"="select.{w}.expand" {{\n  %r = select i1 %c, {ty} %a, {ty} %b\n  ret {ty} %r\n}}\n')
        out.append(f'define {ty} @select.{w}.expand(i1 %c, {ty} %a, {ty} %b) {{\n'
                   f'  %f = call %flags @TESTB1(i1 %c)\n  %ne = call i1 @cc.ne(%flags %f)\n'
                   f'  %r = call {ty} @{cm}(i1 %ne, {ty} %a, {ty} %b)\n  ret {ty} %r\n}}\n')
    # A boolean sign-extended: 0 or -1, its zero-extension negated.
    for ty in ('i8', 'i16', 'i32', 'i64'):
        w = 1 if ty == 'i64' else 0
        d = '{d}' if ty == 'i64' else '{d}'
        entry(ty, f'ZEXT1to{ty}', ['i1 "reg"="r32" %n'],
              '{ if(n<4) rex(0, d, 0, n) | 00001111 | 10110110 | rr(d, n) ; '
              '0100 0 R:1=d>>3 0 B:1=n>>3 | 00001111 | 10110110 | rr(d, n) }',
              'movzbl {n:r8}, {d:r32}', [f'%r = zext i1 %n to {ty}', f'ret {ty} %r'], ' "nomatch"' +
              (' "dclass"="r32"' if ty in ('i8', 'i16') else ''))
        entry(ty, f'NEGx{ty}', [f'{ty} "reg"="{"r64" if w else "r32"}" "tied" %n'],
              f'rex({w}, 0, 0, d) | 11110111 | rr(3, d)', f'neg{"q" if w else "l"} {{d}}',
              [f'%r = sub {ty} 0, %n', f'ret {ty} %r'], ' "clobbers"="flags" "nomatch"' +
              (' "dclass"="r32"' if ty in ('i8', 'i16') else ''))
        cls = 'r64' if w else 'r32'
        out.append(f'define {ty} @sext.1.{ty}(i1 "reg"="r32" %n) "recipe"="sext.1.{ty}.expand" {{\n'
                   f'  %r = sext i1 %n to {ty}\n  ret {ty} %r\n}}\n')
        out.append(f'define {ty} @sext.1.{ty}.expand(i1 %n) {{\n  %z = call {ty} @ZEXT1to{ty}(i1 %n)\n'
                   f'  %r = call {ty} @NEGx{ty}({ty} %z)\n  ret {ty} %r\n}}\n')
    # The high half of a 64-bit product: rdx, of rax by a register.
    for mn, r, ext in [('imul', 5, 'sext'), ('mul', 4, 'zext')]:
        entry('i64', f'{mn.upper()}H64', ['i64 "reg"="rax" %n', 'i64 "reg"="r64" %m'],
              f'rex(1, 0, 0, m) | 11110111 | rr({r}, m)', f'{mn}q {{m}}',
              [f'%a = {ext} i64 %n to i128', f'%b = {ext} i64 %m to i128', '%p = mul i128 %a, %b',
               '%h = lshr i128 %p, 64', '%r = trunc i128 %h to i64', 'ret i64 %r'],
              ' "dclass"="rdx" "clobbers"="%rax,flags"')
    # A 32-bit value widened with zeros: its move (which clears the top).
    entry('i64', 'MOVZX32', ['i32 "reg"="r32" %n'], 'rex(0, n, 0, d) | 10001001 | rr(n, d)', 'movl {n}, {d:r32}',
          ['%r = zext i32 %n to i64', 'ret i64 %r'], ' "zext"="32"')


# Floating point (SSE2): the scalar types, their prefix, their class.
FP = {'double': ('11110010 | ', 'sd', 'd', 'q'), 'float': ('11110011 | ', 'ss', 's', 'l')}


def floats():
    out.append("""; Floating point, SSE2's scalar instructions. The flags of a comparison
; (ucomisd) are ZF, PF and CF: unordered sets all three, less than CF,
; equal ZF. Each of the eight predicates a condition tests is one condition
; code; oeq and une are two (prepare splits them: "fcmp-split").
%fflags = type { double, double }
; The flags of the operands the other way round: ucomisd n, m compares m
; with n. Its conditions test the predicates whose operands are swapped:
; olt is ogt the other way round, ugt ult.
%fflagsr = type { double, double }
""")
    for name, pred, code, cc in [('olt', 'olt', 7, 'a'), ('ole', 'ole', 3, 'ae'), ('ugt', 'ugt', 2, 'b'),
                                 ('uge', 'uge', 6, 'be')]:
        out.append(f'define i1 @cc.fr.{name}(%fflagsr %f) "cond"="{code}" "asm"="{cc}" "reads"="zcp" {{\n'
                   f'  %a = extractvalue %fflagsr %f, 0\n  %b = extractvalue %fflagsr %f, 1\n'
                   f'  %c = fcmp {pred} double %a, %b\n  ret i1 %c\n}}\n')
    for name, pred, code, cc in [('ogt', 'ogt', 7, 'a'), ('oge', 'oge', 3, 'ae'), ('ult', 'ult', 2, 'b'),
                                 ('ule', 'ule', 6, 'be'), ('ueq', 'ueq', 4, 'e'), ('one', 'one', 5, 'ne'),
                                 ('uno', 'uno', 10, 'p'), ('ord', 'ord', 11, 'np')]:
        out.append(f'define i1 @cc.f.{name}(%fflags %f) "cond"="{code}" "asm"="{cc}" "reads"="zcp" {{\n'
                   f'  %a = extractvalue %fflags %f, 0\n  %b = extractvalue %fflags %f, 1\n'
                   f'  %c = fcmp {pred} double %a, %b\n  ret i1 %c\n}}\n')
    for ty, (pre, sfx, cls, isfx) in FP.items():
        T = sfx.upper()
        wide = ['%a = fpext float %n to double', '%b = fpext float %m to double'] if ty == 'float' else []
        a, b = ('%a', '%b') if ty == 'float' else ('%n', '%m')
        p66 = '01100110 | ' if ty == 'double' else ''
        # ucomisd m, n: the flags of n against m; and the other way round.
        entry('%fflags', f'UCOMI{T}', [f'{ty} "reg"="{cls}" %n', f'{ty} "reg"="{cls}" %m'],
              f'{p66}rex(0, n, 0, m) | 00001111 | 00101110 | rr(n, m)', f'ucomi{sfx} {{m}}, {{n}}',
              wide + [f'%f0 = insertvalue %fflags poison, double {a}, 0', f'%f = insertvalue %fflags %f0, double {b}, 1',
                      'ret %fflags %f'], ' "sets"="zcp"')
        entry('%fflagsr', f'UCOMI{T}rev', [f'{ty} "reg"="{cls}" %n', f'{ty} "reg"="{cls}" %m'],
              f'{p66}rex(0, m, 0, n) | 00001111 | 00101110 | rr(m, n)', f'ucomi{sfx} {{n}}, {{m}}',
              wide + [f'%f0 = insertvalue %fflagsr poison, double {a}, 0', f'%f = insertvalue %fflagsr %f0, double {b}, 1',
                      'ret %fflagsr %f'], ' "sets"="zcp"')
        for mn, op, ir in [('add', 0x58, 'fadd'), ('sub', 0x5C, 'fsub'), ('mul', 0x59, 'fmul'), ('div', 0x5E, 'fdiv')]:
            entry(ty, f'{mn.upper()}{T}', [f'{ty} "reg"="{cls}" "tied" %n', f'{ty} "reg"="{cls}" %m'],
                  f'{pre}rex(0, d, 0, m) | 00001111 | {bits(op)} | rr(d, m)', f'{mn}{sfx} {{m}}, {{d}}',
                  [f'%r = {ir} {ty} %n, %m', f'ret {ty} %r'])
        intr = 'f64' if ty == 'double' else 'f32'
        entry(ty, f'SQRT{T}', [f'{ty} "reg"="{cls}" %n'], f'{pre}rex(0, d, 0, n) | 00001111 | 01010001 | rr(d, n)',
              f'sqrt{sfx} {{n}}, {{d}}', [f'%r = call {ty} @llvm.sqrt.{intr}({ty} %n)', f'ret {ty} %r'])
        out.append(f'declare {ty} @llvm.sqrt.{intr}({ty})\n')
        # Loads and stores.
        entry(ty, f'LD{T}', ['ptr "reg"="r64" %n', 'i64 "imm" %off'],
              f'{pre}rex(0, d, 4, n) | 00001111 | 00010000 | rm(d, n, 4, 1, off, 0, 1)', f'mov{sfx} {{off}}({{n}}), {{d}}',
              ['%a = getelementptr i8, ptr %n, i64 %off', f'%r = load {ty}, ptr %a', f'ret {ty} %r'],
              f' "role"="load.{cls}"')
        entry('void', f'ST{T}', [f'{ty} "reg"="{cls}" %t', 'ptr "reg"="r64" %n', 'i64 "imm" %off'],
              f'{pre}rex(0, t, 4, n) | 00001111 | 00010001 | rm(t, n, 4, 1, off, 0, 1)', f'mov{sfx} {{t}}, {{off}}({{n}})',
              ['%a = getelementptr i8, ptr %n, i64 %off', f'store {ty} %t, ptr %a', 'ret void'], f' "role"="store.{cls}"')
        # Between the files: the bits.
        ity, icls, w, mv = ('i64', 'r64', 1, 'movq') if ty == 'double' else ('i32', 'r32', 0, 'movd')
        entry(ty, f'MOV{T}from{ity}', [f'{ity} "reg"="{icls}" %n'],
              f'01100110 | rex({w}, d, 0, n) | 00001111 | 01101110 | rr(d, n)', f'{mv} {{n}}, {{d}}',
              [f'%r = bitcast {ity} %n to {ty}', f'ret {ty} %r'], f' "role"="move.{cls}.{icls}"')
        entry(ity, f'MOV{ity}from{T}', [f'{ty} "reg"="{cls}" %n'],
              f'01100110 | rex({w}, n, 0, d) | 00001111 | 01111110 | rr(n, d)', f'{mv} {{n}}, {{d}}',
              [f'%r = bitcast {ty} %n to {ity}', f'ret {ity} %r'], f' "role"="move.{icls}.{cls}"')
        # Conversions from integers (cvtsi2sd: signed; an unsigned 32-bit
        # value is its 64-bit register, zero-extended).
        for src, w, ext in [('i32', 0, 'sitofp'), ('i64', 1, 'sitofp'), ('i32', 1, 'uitofp')]:
            scls = 'r64' if src == 'i64' else 'r32'
            n = '{n:r64}' if (src == 'i32' and w == 1) else '{n}'
            entry(ty, f'CVT{ext.upper()}{src.upper()}{T}', [f'{src} "reg"="{scls}" %n'],
                  f'{pre}rex({w}, d, 0, n) | 00001111 | 00101010 | rr(d, n)', f'cvtsi2{sfx}{"q" if w else "l"} {n}, {{d}}',
                  [f'%r = {ext} {src} %n to {ty}', f'ret {ty} %r'])
        # To integers, truncating (an unsigned 32-bit result is the low
        # half of the 64-bit conversion).
        for dst, w, ext in [('i32', 0, 'fptosi'), ('i64', 1, 'fptosi'), ('i32', 1, 'fptoui')]:
            dcls = 'r64' if dst == 'i64' else 'r32'
            d = '{d:r64}' if (dst == 'i32' and w == 1) else '{d}'
            entry(dst, f'CVTT{ext.upper()}{T}{dst.upper()}', [f'{ty} "reg"="{cls}" %n'],
                  f'{pre}rex({w}, d, 0, n) | 00001111 | 00101100 | rr(d, n)', f'cvtt{sfx}2si {{n}}, {d}',
                  [f'%r = {ext} {ty} %n to {dst}', f'ret {dst} %r'], f' "dclass"="{dcls}"')
        # select: through the integer registers.
        out.append(f'define {ty} @select.{cls}(i1 "reg"="r32" %c, {ty} "reg"="{cls}" %a, {ty} "reg"="{cls}" %b) '
                   f'"recipe"="select.{cls}.expand" {{\n  %r = select i1 %c, {ty} %a, {ty} %b\n  ret {ty} %r\n}}\n')
        cm = 'CMOV64' if ty == 'double' else 'CMOV32'
        out.append(f'define {ty} @select.{cls}.expand(i1 %c, {ty} %a, {ty} %b) {{\n'
                   f'  %ai = call {ity} @MOV{ity}from{T}({ty} %a)\n  %bi = call {ity} @MOV{ity}from{T}({ty} %b)\n'
                   f'  %f = call %flags @TESTB1(i1 %c)\n  %ne = call i1 @cc.ne(%flags %f)\n'
                   f'  %ri = call {ity} @{cm}(i1 %ne, {ity} %ai, {ity} %bi)\n'
                   f'  %r = call {ty} @MOV{T}from{ity}({ity} %ri)\n  ret {ty} %r\n}}\n')
        # Negation and absolute value: the sign bit flipped or cleared,
        # in the integer registers.
        bitsw = 64 if ty == 'double' else 32
        sign = -(1 << (bitsw - 1))
        xor, andr, movk = (('XOR64rr', 'AND64rr', 'MOVABS64ri') if ty == 'double' else ('XOR32rr', 'AND32rr', 'MOV32ri'))
        for op, body, k in [('fneg', f'%r = fneg {ty} %a', sign), ('fabs', f'%r = call {ty} @llvm.fabs.{intr}({ty} %a)',
                                                                     (1 << (bitsw - 1)) - 1)]:
            out.append(f'define {ty} @{op}.{cls}({ty} "reg"="{cls}" %a) "recipe"="{op}.{cls}.expand" {{\n'
                       f'  {body}\n  ret {ty} %r\n}}\n')
            inst = xor if op == 'fneg' else andr
            out.append(f'define {ty} @{op}.{cls}.expand({ty} %a) {{\n'
                       f'  %ai = call {ity} @MOV{ity}from{T}({ty} %a)\n  %k = call {ity} @{movk}({ity} {k})\n'
                       f'  %x = call {ity} @{inst}({ity} %ai, {ity} %k)\n'
                       f'  %r = call {ty} @MOV{T}from{ity}({ity} %x)\n  ret {ty} %r\n}}\n')
        out.append(f'declare {ty} @llvm.fabs.{intr}({ty})\n')
        # fmuladd: a multiply, then an add (fusing is allowed, not needed).
        out.append(f'declare {ty} @llvm.fmuladd.{intr}({ty}, {ty}, {ty})\n')
        out.append(f'define {ty} @fmuladd.{cls}({ty} "reg"="{cls}" %a, {ty} "reg"="{cls}" %b, {ty} "reg"="{cls}" %c) '
                   f'"recipe"="fmuladd.{cls}.expand" {{\n  %r = call {ty} @llvm.fmuladd.{intr}({ty} %a, {ty} %b, {ty} %c)\n'
                   f'  ret {ty} %r\n}}\n')
        out.append(f'define {ty} @fmuladd.{cls}.expand({ty} %a, {ty} %b, {ty} %c) {{\n'
                   f'  %p = call {ty} @MUL{T}({ty} %a, {ty} %b)\n  %r = call {ty} @ADD{T}({ty} %p, {ty} %c)\n'
                   f'  ret {ty} %r\n}}\n')
        # An unsigned 64-bit value: converted signed if its top bit is
        # clear; else halved (keeping the low bit, for rounding),
        # converted, and doubled.
        out.append(f'define {ty} @uitofp.64.{cls}(i64 "reg"="r64" %x) "recipe"="uitofp.64.{cls}.expand" {{\n'
                   f'  %r = uitofp i64 %x to {ty}\n  ret {ty} %r\n}}\n')
        out.append(f'define {ty} @uitofp.64.{cls}.expand(i64 %x) {{\n'
                   f'  %h = call i64 @SHR64ri(i64 %x, i64 1)\n  %l = call i64 @AND64ri(i64 %x, i64 1)\n'
                   f'  %o = call i64 @OR64rr(i64 %h, i64 %l)\n'
                   f'  %f1 = call %flags @TEST64rr(i64 %x, i64 %x)\n  %n1 = call i1 @cc.l(%flags %f1)\n'
                   f'  %t = call i64 @CMOV64(i1 %n1, i64 %o, i64 %x)\n'
                   f'  %c = call {ty} @CVTSITOFPI64{T}(i64 %t)\n  %c2 = call {ty} @ADD{T}({ty} %c, {ty} %c)\n'
                   f'  %ci = call {ity} @MOV{ity}from{T}({ty} %c)\n  %c2i = call {ity} @MOV{ity}from{T}({ty} %c2)\n'
                   f'  %f2 = call %flags @TEST64rr(i64 %x, i64 %x)\n  %n2 = call i1 @cc.l(%flags %f2)\n'
                   f'  %ri = call {ity} @{"CMOV64" if ty == "double" else "CMOV32"}(i1 %n2, {ity} %c2i, {ity} %ci)\n'
                   f'  %r = call {ty} @MOV{T}from{ity}({ity} %ri)\n  ret {ty} %r\n}}\n')
    # Between the two widths.
    entry('double', 'CVTSS2SD', ['float "reg"="s" %n'], '11110011 | rex(0, d, 0, n) | 00001111 | 01011010 | rr(d, n)',
          'cvtss2sd {n}, {d}', ['%r = fpext float %n to double', 'ret double %r'])
    entry('float', 'CVTSD2SS', ['double "reg"="d" %n'], '11110010 | rex(0, d, 0, n) | 00001111 | 01011010 | rr(d, n)',
          'cvtsd2ss {n}, {d}', ['%r = fptrunc double %n to float', 'ret float %r'])


def vector_copies():
    """Copies of the vector and mask registers (the register allocator's)."""
    entry('<2 x i64>', 'MOVAPSrr', ['<2 x i64> "reg"="x" %n'], 'rex(0, d, 0, n) | 00001111 | 00101000 | rr(d, n)',
          'movaps {n}, {d}', ['ret <2 x i64> %n'], ' "copy"="x"')
    for cls, ty, l, ll in [('xe', '<2 x i64>', 0, 0), ('ye', '<4 x i64>', 1, 1)]:
        # (The store form where only it has the two-byte prefix, as llvm-mc
        # writes it.)
        entry(ty, f'VMOVAPS{cls}', [f'{ty} "reg"="{cls}" %n'],
              f'{{ if(n<8) vex(d, 0, n, 1, 0, 0, {l}, 0) | 00101000 | rr(d, n) ; '
              f'if(d<8) vex(n, 0, d, 1, 0, 0, {l}, 0) | 00101001 | rr(n, d) ; '
              f'vex(d, 0, n, 1, 0, 0, {l}, 0) | 00101000 | rr(d, n) ; '
              f'evexr(d, n, 1, 0, 0, {ll}, 0, 0, 0, 0) | 00101000 | rr(d, n) }}',
              'vmovaps {n}, {d}', [f'ret {ty} %n'], f' "copy"="{cls}" "dclass"="{cls}"')
    entry('<8 x i64>', 'VMOVAPSz', ['<8 x i64> "reg"="z" %n'], 'evexr(d, n, 1, 0, 0, 2, 0, 0, 0, 0) | 00101000 | rr(d, n)',
          'vmovaps {n}, {d}', ['ret <8 x i64> %n'], ' "copy"="z"')
    entry('i64', 'KMOVQ', ['i64 "reg"="k" %n'], 'vex(d, 0, n, 1, 1, 0, 0, 0) | 10010000 | rr(d, n)', 'kmovq {n}, {d}',
          ['ret i64 %n'], ' "copy"="k" "dclass"="k"')


def main():
    out.append("""; x86-64's integer instructions for selection. Written by gen_sel.py; do
; not edit. The conventions are those of codegen/targets/aarch64/00-base.ll,
; and docs/design/x86.md has the plan.
""")
    alu()
    moves()
    memory()
    compares()
    control()
    division()
    recipes()
    floats()
    vector_copies()
    sys.stdout.write('\n'.join(out))


main()
