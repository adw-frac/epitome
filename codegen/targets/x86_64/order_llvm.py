#!/usr/bin/env python3
"""Finds which of an entry's alternatives llvm-mc writes, where several are
as short: assembles a line of every entry with llvm-mc, and for each entry
with alternatives of the same length, takes the first whose opcode bytes
(its pieces of literal bits) are in llvm-mc's encoding, in order.

Usage: order_llvm.py ENTRIES.ll LLVM_MC LLVM_OBJDUMP > order.txt
(order.txt: an entry's name and the opcode bytes of the alternative
llvm-mc writes.)
"""

import re
import subprocess
import sys
import tempfile

def assemble(mc, objdump, lines, prefix):
    """Assembles `lines` with llvm-mc, each at a symbol `prefix`<k>, leaving
    out those it rejects, and gives llvm-objdump's listing."""
    keep = list(range(len(lines)))
    with tempfile.TemporaryDirectory() as tmp:
        while True:
            src = '\t.text\n' + ''.join(f'{prefix}{k}:\n\t{lines[k]}\n' for k in keep)
            open(f'{tmp}/s.s', 'w').write(src)
            r = subprocess.run([mc, '-triple=x86_64-linux-gnu', '-filetype=obj', '-o', f'{tmp}/s.o', f'{tmp}/s.s'],
                               capture_output=True, text=True)
            bad = {int(n) for n in re.findall(r's\.s:(\d+):\d+: error', r.stderr)}
            if not bad:
                break
            # Line 2 + 2j is the j-th kept line's instruction.
            drop = {keep[(n - 3) // 2] for n in bad if n >= 3}
            keep = [k for k in keep if k not in drop]
        return subprocess.run([objdump, '-d', f'{tmp}/s.o'], capture_output=True, text=True).stdout


entries_ll, mc, objdump = sys.argv[1:4]

REGS = {
    'r64': ['%rax', '%rcx', '%rdx', '%rbx', '%rsp', '%rbp', '%rsi', '%rdi'] + [f'%r{i}' for i in range(8, 16)],
    'r32': ['%eax', '%ecx', '%edx', '%ebx', '%esp', '%ebp', '%esi', '%edi'] + [f'%r{i}d' for i in range(8, 16)],
    'r16': ['%ax', '%cx', '%dx', '%bx', '%sp', '%bp', '%si', '%di'] + [f'%r{i}w' for i in range(8, 16)],
    'r8': ['%al', '%cl', '%dl', '%bl', '%spl', '%bpl', '%sil', '%dil'] + [f'%r{i}b' for i in range(8, 16)],
    'x': [f'%xmm{i}' for i in range(16)], 'y': [f'%ymm{i}' for i in range(16)],
    'xe': [f'%xmm{i}' for i in range(32)], 'ye': [f'%ymm{i}' for i in range(32)], 'z': [f'%zmm{i}' for i in range(32)],
    'k': [f'%k{i}' for i in range(8)], 'mm': [f'%mm{i}' for i in range(8)], 'st': [f'%st({i})' for i in range(8)],
    'seg': ['%es', '%cs', '%ss', '%ds', '%fs', '%gs'], 'cr': [f'%cr{i}' for i in range(16)],
    'dr': [f'%dr{i}' for i in range(16)], 'tmm': [f'%tmm{i}' for i in range(8)],
}


def alternatives(enc):
    """The top-level alternatives of an encoding."""
    if not enc.startswith('{ ') or not enc.endswith(' }'):
        return [enc]
    body, out, depth, cur = enc[2:-2], [], 0, ''
    for c in body:
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
        if c == ';' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += c
    out.append(cur.strip())
    # (A single group with alternatives inside is not alternatives here.)
    return out


def opcode(alt):
    """The bytes of an alternative's pieces that are literal bits only."""
    out = []
    depth = 0
    for piece in re.split(r'\s*\|\s*', alt):
        p = re.sub(r'^\S+:0=\S+\s*', '', piece.strip())
        p = re.sub(r'^(if\(\S+\)\s*)+', '', p)
        if re.fullmatch(r'[01]{8}', p):
            out.append(int(p, 2))
    # And a VEX or EVEX prefix's map, W and pp, as 0x100 + map, 0x200 + W,
    # 0x300 + pp.
    m = re.search(r'(e?vex)[mr]?\(([^()]*)\)', alt)
    if m:
        args = [a.strip() for a in m.group(2).split(',')]
        # vex(r, x, b, map, w, v, l, pp); vexm(r, base, index, map, w, v, l,
        # pp); evexr(r, b, map, w, v, ll, pp, ...); evexm(r, base, index,
        # map, w, v, ll, pp, ...).
        k = 2 if m.group(0).startswith('evexr') else 3
        if args[k].isdigit() and args[k + 1].isdigit() and args[k + 4].isdigit():
            out += [0x100 + int(args[k]), 0x200 + int(args[k + 1]), 0x300 + int(args[k + 4])]
    return out


def contains(seq, sub):
    it = iter(seq)
    return all(b in it for b in sub)


def sample(params, asm, high, label):
    """A line of the entry: registers low (or, `high`, from 16 where the
    class has 32)."""
    text = asm
    for p in filter(None, params.split(', ')):
        kind, cls, op = re.match(r'\w+ "(\w+)"(?:="(\w+)")? %([\w.]+)', p).groups()
        if kind == 'reg':
            regs = REGS[cls]
            k = {'m.base': 6, 'm.index': 7}.get(op, (11 + int(op[1:]) if op[1:].isdigit() else 3) % len(regs))
            if high and len(regs) == 32 and not op.startswith('m.'):
                k = 16 + k % 16
            v = regs[k]
        elif kind == 'imm':
            v = {'m.disp': '64', 'm.scale': '4'}.get(op, '42')
        elif kind == 'sym':
            v = 'sym'
        else:
            v = label
        text = text.replace('{' + op + '}', v)
    return text.replace('{lb}', '{').replace('{rb}', '}')


entries = []
for line in open(entries_ll):
    m = re.match(r'define void @(\w+)\((.*?)\) "enc"="([^"]*)" "asm"="([^"]*)"', line)
    if not m:
        continue
    name, params, enc, asm = m.groups()
    alts = alternatives(enc)
    if len(alts) < 2:
        continue
    for high in (False, True):
        if high and '"xe"' not in params and '"ye"' not in params and '"z"' not in params:
            continue
        k = len(entries)
        entries.append((name, alts, sample(params, asm, high, f'e{k}')))

dump = assemble(mc, objdump, [t for _, _, t in entries], 'e')

got, cur = {}, None
for l in dump.splitlines():
    m = re.match(r'[0-9a-f]+ <e(\d+)>:', l)
    if m:
        cur = int(m.group(1))
        got[cur] = []
        continue
    m = re.match(r'\s*[0-9a-f]+:\s+((?:[0-9a-f]{2} ?)+)', l)
    if m and cur is not None:
        got[cur] += [int(b, 16) for b in m.group(1).split()]

seen = set()
for k, (name, alts, _) in enumerate(entries):
    b = got.get(k)
    if not b:
        continue
    # llvm-mc's prefix's map, W and pp, as opcode() writes them.
    pre = None
    if b[0] == 0xc5:
        pre = [0x101, 0x200, 0x300 + (b[1] & 3)]
    elif b[0] == 0xc4 and len(b) > 2:
        pre = [0x100 + (b[1] & 31), 0x200 + (b[2] >> 7), 0x300 + (b[2] & 3)]
    elif b[0] == 0x62 and len(b) > 2:
        pre = [0x100 + (b[1] & 7), 0x200 + (b[2] >> 7), 0x300 + (b[2] & 3)]
    for a in alts:
        op = opcode(a)
        tail = [x for x in op if x >= 0x100]
        op = [x for x in op if x < 0x100]
        if tail and tail != pre:
            continue
        if op and contains(b, op):
            line = f'{name}\t{" ".join(f"{x:02x}" for x in opcode(a))}'
            if line not in seen:
                seen.add(line)
                print(line)
            break
