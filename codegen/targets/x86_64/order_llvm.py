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
    return out


def contains(seq, sub):
    it = iter(seq)
    return all(b in it for b in sub)


entries = []
for line in open(entries_ll):
    m = re.match(r'define void @(\w+)\((.*?)\) "enc"="([^"]*)" "asm"="([^"]*)"', line)
    if not m:
        continue
    name, params, enc, asm = m.groups()
    alts = alternatives(enc)
    if len(alts) < 2:
        continue
    text = asm
    for p in filter(None, params.split(', ')):
        kind, cls, op = re.match(r'\w+ "(\w+)"(?:="(\w+)")? %([\w.]+)', p).groups()
        if kind == 'reg':
            regs = REGS[cls]
            k = {'m.base': 6, 'm.index': 7}.get(op, (11 + int(op[1:]) if op[1:].isdigit() else 3) % len(regs))
            v = regs[k]
        elif kind == 'imm':
            v = {'m.disp': '64', 'm.scale': '4'}.get(op, '42')
        elif kind == 'sym':
            v = 'sym'
        else:
            v = f'e{len(entries)}'
        text = text.replace('{' + op + '}', v)
    text = text.replace('{lb}', '{').replace('{rb}', '}')
    entries.append((name, alts, text))

with tempfile.TemporaryDirectory() as tmp:
    src = '\t.text\n' + ''.join(f'e{k}:\n\t{t}\n' for k, (_, _, t) in enumerate(entries))
    open(f'{tmp}/s.s', 'w').write(src)
    r = subprocess.run([mc, '-triple=x86_64-linux-gnu', '-filetype=obj', '-o', f'{tmp}/s.o', f'{tmp}/s.s'],
                       capture_output=True, text=True)
    dump = subprocess.run([objdump, '-d', f'{tmp}/s.o'], capture_output=True, text=True).stdout

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

for k, (name, alts, _) in enumerate(entries):
    b = got.get(k)
    if not b:
        continue
    for a in alts:
        op = opcode(a)
        if op and contains(b, op):
            print(f'{name}\t{" ".join(f"{x:02x}" for x in op)}')
            break
